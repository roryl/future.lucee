<cfscript>
ping = new future(function(this){
	sleep(500);
	sleep(500);
	var result = this.yield(); //pauses execution to the main thread
	sleep(500)
	return "20" + result;
});

ping.call("10");
echo(ping.get());
// echo("The result was: #pong.get()# and took #pong.elapsed()# ms to finish.");
</cfscript>