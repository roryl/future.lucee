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