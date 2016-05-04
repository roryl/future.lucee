# future.lucee
A Futures Implementation for Lucee

Lucee has multiple concurrency features between async functions, tasks and thread {}, but working with the underlying thread implementation is cumbersome to work with. A Future provides syntactic suger over the use of thread {}.

##How to Use
Future.lucee is a single class, future.cfc. The basic use is to create a new future and pass a closure to it that will be executed.

```coldfusion
<cfscript>
future = new future(function(){
	sleep(2000);
	return "some value"
});

//Blocks the thread and waits for the result
echo(future.get());
</cfscript>
```

##Why to Use
A future is useful in the scenario where you have a background task that you want to execute, but will need the result of the task at some point during the request. For example, say you have to make an HTTP request to a third party resouce to get some data, and do some local querying for other data, and then when these are both complete, output them to the browser.

You don't need to use a future when you do not care about the result of the task. In this case, a simple thread {} will suffice.

##Thread Saftey
The closure passed to the future contains references to the scopes of where it was created. Be careful about race conditions when accessing the variables scope or global scope. You should `var` any local variables inside the closure to ensure no race conditions with the calling page. You should lock {} any access to global scopes

##Limitations
Future makes use of the Lucee thread tag which cannot support nested threads. Therefore any code blocks passed to future will error with `"could not create a thread within a child thread"` if there was a nested future. If you need to do further parallel processing within the executing code, make use of one of Lucee's parallel functions: map(), each(), every(), reduce(), some(), filter()

The example nestedMap.cfm shows how to do this.
