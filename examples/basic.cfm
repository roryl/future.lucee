<cfscript>
future = new future(function(){
	sleep(2000);
	return "some value"
});

//Blocks the currently executing thread and waits for the result to finish
echo("The time before get was #now()# <br />");
echo("The value returned was: <strong>#future.get()#</strong> <br />");
echo("The time after get was #now()# <br />");
</cfscript>