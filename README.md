# future.lucee
A Futures Implementation for Lucee

Lucee has multiple concurrency features between async functions, tasks and thread, but working with the underlying thread implementation is complicated.

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

##Limitations
Future makes use of the Lucee thread tag which cannot support nested threads. Therefore any code blocks passed to future will error with `"could not create a thread within a child thread"` if there was a nested future. If you need to do further parallel processing within the executing code, make use of one of Lucee's parallel functions: map(), each(), every(), reduce(), some(), filter()

The example nestedMap.cfm shows how to do this.
