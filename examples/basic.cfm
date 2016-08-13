<cfscript>
future = new future(function(){
	sleep(2000);
	return "some value"
});

/* Code here executes concurrently with the future */

echo("The time before get was #now()# <br />");
//Blocks the currently executing thread and waits for the result to finish
echo("The value returned was: <strong>#future.get()#</strong> <br />");
echo("The time after get was #now()# <br />");
a
request.bar = "";
thread name="foo" {
	request.bar = "baz";
}

thread action="join" name="foo";
echo(request.bar);
writeDump(now());
</cfscript>