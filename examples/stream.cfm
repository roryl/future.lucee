<cfscript>
timer type="outline" {

	storage = [];


	writeLog("stream test");

	function geHTTPData(){	
		// sleep(randRange(10,50));
		sleep(50);
		return randRange(0,100);
	}


	function saveToDatabase(value){
		// sleep(randRange(10,50));
		sleep(100);
		storage.append(value);
	}



	getAll = new future(function(this){		
		for(i=1; i <= 10; i++){
			var data = geHTTPData();			
			this.reply(data);
		}
	});
	
	
	putAll = new future(function(this){
		var working = 0;		
				
		data = this.yield(getAll);			
		while(!isNull(data)){
			saveToDatabase(data * -1);				
			data = this.yield(getAll);
		}			
		
	});
	
	writeDump(now());
	
	writeDump(putAll.get());

	writeDump(now());
}

// sleep(1000);
// writeDump(queue);
writeDump(storage);



</cfscript>