<cfscript>
getArray = new future(function(){
	sleep(1000);//Impersonate a web request to get an array

	var myArray = ["1", "2", "3"];
	myArray.map(function(item){
		var item = arguments.item;
		var getItemFuture = new future(function(){
			sleep(1000);
			return item * 10;
		});
		return getItemFuture;
	});


	

});
</cfscript>