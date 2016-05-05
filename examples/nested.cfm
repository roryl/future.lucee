<cfscript>
future = new future(function(){	
	sleep(1000);

	var otherFuture = new future(function(){
		sleep(1000);
		return "other value";
	});

	return "some value";
});

//Blocks the currently executing thread and waits for the result to finish
echo(future.get());
writeDump(future);
</cfscript>