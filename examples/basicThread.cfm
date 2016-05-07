<cfscript>
request.result = "";
thread name="foo" {
	sleep(2000);
	request.result = "some value";
}

echo("The time before get was #now()# <br />");
//Blocks the currently executing thread and waits for the result to finish
thread action="join" name="foo";
echo("The value returned was: <strong>#request.result#</strong> <br />");
echo("The time after get was #now()# <br />");
</cfscript>