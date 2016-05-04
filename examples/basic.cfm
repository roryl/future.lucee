<cfscript>
future = new future(function(){
	sleep(2000);
	return "some value"
});

//Blocks the currently executing thread and waits for the result to finish
echo(future.get());
</cfscript>