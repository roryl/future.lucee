<cfscript>
timer type="outline" {
	//A fake datastore to mimic a database
	storage = [];

	//A fake HTTP request to get some data between 0 and 100
	function geHTTPData(){	
		sleep(50);
		return randRange(0,100);
	}

	//A fake function to save data to a database
	function saveToDatabase(value){		
		sleep(100);
		storage.append(value);
	}

	//A future which gets 10 numbers from the HTTP request
	getAll = new future(function(this){		
		
		for(i=1; i <= 10; i++){
			var data = geHTTPData();			
			this.reply(data);
		}

	});
	
	//A future which waits on getAll before proceeding
	putAll = new future(function(this){		
		
		var data = this.yield(getAll);			
		while(!isNull(data)){
			saveToDatabase(data * -1);				
			var data = this.yield(getAll);
		}	
		
	});

	writeDump(putAll.get());
	writeDump(storage);
}
</cfscript>