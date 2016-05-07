# future.lucee (beta)
A Futures Implementation for Lucee

Lucee has multiple concurrency features between async functions, tasks and thread {}, but working with the underlying thread implementation is cumbersome to work with. A Future provides syntactic suger over the use of thread {} by executing a closure within a thread and giving back a handle to check on completion to deal with the result.

**This library is currently in beta and is not ready for mission critical workloads**

##Futures Quickstart
Future.lucee is a single class, future.cfc. The basic use is to create a new future and pass a closure to it that will be executed.

```coldfusion
<cfscript>
future = new future(function(){
	sleep(2000);
	return "some value"
});

/* Code here executes concurrently with the future */

echo("The time before get was #now()# <br />");
//Blocks the currently executing thread and waits for the result to finish
echo("The value returned was: <strong>#future.get()#</strong> <br />");
echo("The time after get was #now()# <br />");
</cfscript>
```

The output of this basic example is:

```
The time before get was {ts '2016-05-07 16:42:19'} 
The value returned was: some value 
The time after get was {ts '2016-05-07 16:42:21'} 
```

Calling `get()` on a future blocks the thread to wait on a response value from the future.


This future above is simply syntactic sugar over manually handling threads. The exact same functionality would be traditionnaly managed with the `thread {}` tag like so:

```coldfusion
<cfscript>
request.result = "";
thread name="foo" {
	sleep(2000);
	request.result = "some value";
}

echo("The time before get was #now()# <br />");
//Blocks the currently executing thread and waits for the result to finish
thread action="join" name="foo";
echo("The value returned was: <strong>#request.result#</strong> <br />");
echo("The time after get was #now()# <br />");
</cfscript>
```

For simple cases, Futures provide a better experience for handling the results of aynchronous processing than the traditional threading approach.

##Why to Use
A future is useful in the scenario where there is a background task will execute, but the thread creating the future will need the result of the future at some point during the request. For example, say there is a long running HTTP request to a third party resouce to get some data. A future can be created, the page can continue processing other items, and the page can get the value of the future when it is complete. 

A future is not necessary when the page does not care about the result and it can coplete in the background, in those cases, a simple thread {} will suffice.

##Features
###Futures can execute callbacks
Future can optionally take callbacks which will be called at the appropriate time. All of the callbacks execute asynchronously in the thread created by the future. The constructor signature is:
```
public function init(required function task, 
		     function success, 
		     function error, 
		     function finally){
```
####task()
The primary closure to execute asyncronously from the page thread. 

####success(any result)
A closure which will recieve the result of the task if there was any

####error(any error)
A closure which will receive the result of the error when executing the task

####finally(any error) or finally(any result)
A closure which will always execute and receives either an error, or the result of the task. The value is passed as a named parameter. To have the closure check if it was a result or an error, in the body of the closure use: `structKeyExists(arguments,"error")` or `structKeyExists(arguments,"result")`

###Futures are chainable
Futures can be chained using the then() function which will pause execution of the next future until the first future completes. Chainable futures would be used when you want to return control to the calling page that created the chain, but each future must execute sequentially.

```coldfusion
<cfscript>
future = new future(function(this){	
	sleep(1000);
	return 10;
}).then(new future(function(this, priorFuture){
	sleep(1000);
	priorValue = priorFuture.get();
	return "20" + priorValue;
}));

echo("The result was: #future.get()# and took #future.elapsed()# ms to finish");
</cfscript>
```

Each future in the chain gets a reference to the priorFuture so that errors or the data can be checked. When using the Then mehtod, the prior future is guaranteed to have completed.

What is going on behind the scenes is when the second future executes, it calls get() on the first. This is a convenience over manually setting up a chain of futures by referencing previous futures. But ordering the execution of futures is also possible like so:

```coldfusion
var firstFuture = new future(function(){
	sleep(1000);
	return 10;
});

var secondFuture = new future(function(){
	prior = firstFuture.get(); //Blocks untilt he return of the firstFuture	
	sleep(1000);
	return "20" + prior;
});
```

The echo produces `The result was: 30 and took 2019 ms to finish` which we can see that it took the time for both futures to complete.

###Yielding Futures
Futures can yeild processing control to another future. This is useful for interleaving execution between futures. Take this example below that executes back and forth between ping and pong

```coldfusion
<cfscript>
ping = new future(function(this){
	sleep(500);
	this.yield(pong);
	sleep(500);
	this.yield(); //yields back to pong
	return "20";
});

pong = new future(function(this){
	sleep(1000);
	this.yield(); //yields back to ping
	sleep(1000);	
	return 10 + ping.get();
});
echo("The result was: #pong.get()# and took #pong.elapsed()# ms to finish.");
</cfscript>
```

This outputs `The result was: 30 and took 2525 ms to finish.`

We can see that by interleaving, total sleep time was about 500 ms less than the total sleep time of 3000 ms. This is because the first 500ms executed concurrently together, the pong yielded to ping.

###Streaming Futures
Futures can cooperatievely multi-task, pass messages and enable realtime streaming workloads. Streaming is best illustrated by thinking about video streaming. In order to stream a video to a client, the video client and the server cooperate to pass data when the client is ready. In the case of youtube for example, the server does not send too much more video than the client is ready for. Youtube stays ahead of the client but a few seconds, but does not send all of the data. This way if the user pauses the video, youtube did not send wasted data.

Though in Lucee, Futures wouldn't be used to implement a video streaming server, imagine a situation wherein a lot of HTTP requests need to be made, and then that data processed and put into a database. If done sequentially, then the total time to complete will be all of the HTTP requests plus all of the database inserts. One could also use a number of queueing strategies and watchers in which one process adds items to a shared queue that another process takes items off. But setting that up manually is not trivial. Lucee Futures provide mechanisms to `yeild()` and `reply()` messages to enable these streaming workloads.

This example below makes fake HTTP requests and fake data inserts to illustrate a streaming scenario. 

```coldfusion
<cfscript>
timer type="outline" {
	//A fake datastore to mimic a database
	storage = [];

	//A fake HTTP request to get some data between 0 and 100
	function geHTTPData(){	
		// sleep(randRange(10,50));
		sleep(50);
		return randRange(0,100);
	}

	//A fake function to save data to a database
	function saveToDatabase(value){
		// sleep(randRange(10,50));
		sleep(100);
		storage.append(value);
	}

	//A future which gets 10 numbers from the HTTP request
	getAll = new future(function(this){		
		for(i=1; i <= 10; i++){
			var data = geHTTPData();			
			this.reply(data);
		}
	});
	
	//A future which waits on getAll before proceeding
	putAll = new future(function(this){
		var data = this.yield(getAll);			
		while(!isNull(data)){
			saveToDatabase(data * -1);				
			var data = this.yield(getAll);
		}
	});

	writeDump(putAll.get());
	writeDump(storage);
}
</cfscript>
```


##Thread Saftey
The closure passed to the future contains references to the scopes of where it was created. Be careful about race conditions when accessing the variables scope or global scope. You should `var` any local variables inside the closure to ensure no race conditions with the calling page. You should lock {} any access to global scopes if two futures are acessing them.

##Limitations
Future makes use of the Lucee thread tag which cannot support nested threads. Therefore any code blocks passed to future will error with `"could not create a thread within a child thread"` if there was a nested future. To do nested parallel processing within the executing code, make use of one of Lucee's parallel functions: map(), each(), every(), reduce(), some(), filter()

The example nestedMap.cfm shows how to do this. 
