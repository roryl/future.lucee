<cfscript>
future = new future(function(){
	sleep(2000);
	return "some value"
});

tasks = [
	new future(function(){
		sleep(2000);
		return "some value"
	}),
	new future(function(){
		sleep(2000);
		return "some value"
	}),
	new future(function(){
		sleep(2000);
		return "some value"
	})
]

values = tasks.map(function(result){
	return result.get();
}, true);

writeDump(values);

//Blocks the currently executing thread and waits for the result to finish
echo(future.get());
</cfscript>