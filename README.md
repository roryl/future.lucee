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
