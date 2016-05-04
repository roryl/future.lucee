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
		variables.done = false;
		variables.canceled = false;
		variables.startTime = getTickCount();
		// writeDump(callStackGet());
		
		if(structKeyExists(arguments,"success")){variables.success = arguments.success;}
		if(structKeyExists(arguments,"error")){variables.error = arguments.error;}
		if(structKeyExists(arguments,"finally")){variables.finally = arguments.finally;}	

		thread name="#variables.name#" action="run" {
			thread action="sleep" name="#variables.name#" duration="10";

			if(structKeyExists(variables,"prior")){
				//Block the execution of this thread untilt he prior future is complete
				variables.prior.get();				
			}

			try {

				if(structKeyExists(variables,"prior")){
					variables.result = variables.task(variables.prior);									
				} else {
					variables.result = variables.task();														
				}								
				variables.done = true;
				variables.endTime = getTickCount();
			} catch (any e){
				variables.taskError = e;
				variables.done = true;
				
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
						variables.finally(result=variables.result);
					}
				}
			}			
		}
	}

	public function then(required future future){
		future.setPrior(this);
		return future;
	}

	public function setPrior(future){
		variables.prior = arguments.future;
	}

	public function get(required numeric milliseconds=0){
		
		if(isCanceled()){
			throw("The thread was canceled, cannot get the result");
		}

		if(structKeyExists(variables,"taskError")){
			throw(variables.taskError);
		}

		thread action="join" name="#variables.name#" timeout="#arguments.milliseconds#";				

		if(!isDone()){
			throw("Did not complete the thread before the timeout #milliseconds# was reached");
		}

		if(!isNull(variables.result)){			
			return variables.result;
		}
	}

	public function hasError(){
		thread action="join" name="#variables.name#";	
		return structKeyExists(variables,"taskError");
	}

	public boolean function cancel(){
		if(isDone()){
			return false;
		} else {
			thread action="terminate" name="#variables.name#";
			variables.done = true;
			variables.canceled = true;
			return true;
		}
	}

	public boolean function isDone(){
		return variables.done;
	}

	public boolean function isCanceled(){
		return variables.canceled;	
	}

	public function elapsed(){
		if(isDone() or isCanceled()){
			return variables.endTime - variables.startTime;
		} else {
			return getTickCount() - variables.startTime;
		}
	}

}