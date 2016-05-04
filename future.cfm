<cfscript>
someValue = "test closure";
task = new future(function(){
	sleep(2000);
	return someValue;
});

//Do some other processing
sleep(3000);

writeDump(task.getName());
writeDump(task.get());
</cfscript>