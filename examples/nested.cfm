<cfscript>
future = new future(function(){	
	sleep(1000);	
	var secondFuture = new future(function(){
		sleep(1000);				
		return "5";
	});

	var thirdFuture = new future(function(){
		sleep(1000);				
		return "3";
	});

	return secondFuture.get() + thirdFuture.get() ;	
	// return "some value";
});

//Blocks the currently executing thread and waits for the result to finish
echo(future.get());
</cfscript>