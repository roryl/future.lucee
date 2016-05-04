/**
 * Used to syncronize the results from multiple futures
 */
component {

	public function init(){

		variables.futures = [];
		for(var future in arguments){
			if(!isInstanceOf(arguments[future],"future"))
			{
				throw("All values passed to when must be futures");
			}
			variables.futures.append(arguments[future]);
		}	
	}

	public future function any(required function task){

		var task = arguments.task;
		var future = new future(function(){
			outer: while(true){
				for(var future in variables.futures){
					if(future.isDone()){
						return task(future);						
					}
				}
				sleep(50);				
			}
		});
		return future;
	}

	public future function all(required function task){

		var task = arguments.task;
		var future = new future(function(){

			outer: while(true){
				for(var future in variables.futures){
					if(!future.isDone()){
						break outer;
					}
				}
				break;
			}
			return task(variables.futures);
		});
		return future;
	}

	public array function get(){
		var out = [];
		for(var future in variables.futures){
			out.append(future.get());
		}
		return out;
	}

	// public function done(){
	// 	thread name="#variables.name#" action="join";		
	// }


}