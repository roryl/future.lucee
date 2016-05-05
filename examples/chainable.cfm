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