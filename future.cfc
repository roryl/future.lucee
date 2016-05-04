/**
 * Implements a future to allow for asyncrhonous code execution
 * 
 */
component accessors="true" {

	property name="name" hint="The unique name for the background thread";
	property name="taskError" hint="Any exception received while executing the task";	

	public function init(required function task, function success, function error, function finally){

		variables.name = hash(serialize(task));
		variables.task = task;
		
		if(structKeyExists(arguments,"success")){variables.success = arguments.success;}
		if(structKeyExists(arguments,"error")){variables.error = arguments.error;}
		if(structKeyExists(arguments,"finally")){variables.finally = arguments.finally;}	

		thread name="#variables.name#" action="run" {			
			try {
				variables.result = variables.task();				
			} catch (any e){
				variables.taskError = e;
				if(structKeyExists(variables,"error")){
					variables.error(variables.taskError);
				}
			} finally {
				if(!structKeyExists(variables,"error")){
					if(structKeyExists(variables,"success")){
						variables.success(variables.result);						
					}
				}

				if(structKeyExists(variables,"finally")){

					if(structKeyExists(variables,"error")){
						variables.finally(error=variables.error);						
					} else {
						variables.finally(result=variables.error);
					}
				}
			}
			
		}
	}

	public function get(){
		thread action="join" name="#variables.name#";		
		if(structKeyExists(variables,"taskError")){
			throw(variables.taskError);
		}
		return variables.result;
	}

	public function hasError(){
		thread action="join" name="#variables.name#";	
		return structKeyExists(variables,"taskError");
	}

}