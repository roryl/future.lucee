<cfscript>
future = new future(function(){
	
	tasks = [
		"one",
		"two",
		"three"
	];
	var result = tasks.map(function(value){
		return value;
	},true);
	return result;
});

//Blocks the currently executing thread and waits for the result to finish
writeDump(future.get());
</cfscript>