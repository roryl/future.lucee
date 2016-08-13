<cfscript>
overall = new future(function(){

	future = new future(function(this){	
		sleep(1000);
		return 10;
	}).then(new future(function(this, priorFuture){
		sleep(1000);
		priorValue = priorFuture.get();
		return "20" + priorValue;
	}));

	sleep(2000);
	return 50 + future.get();
});


echo("The result was: #overall.get()# and took #overall.elapsed()# ms to finish");
</cfscript>