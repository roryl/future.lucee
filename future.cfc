/**
 * Implements a future to allow for asyncrhonous code execution
 * 
 */
component accessors="true" {

	property name="name" hint="The unique name for the background thread";
	property name="taskError" hint="Any exception received while executing the task";	

	public function init(required function task, function success, function error, function finally){

		variables.name = hash(serialize(task));
		variables.running = false;
		variables.sleeping = false;
		variables.task = task;
		variables.done = false;
		variables.canceled = false;
		variables.startTime = getTickCount();
		variables.yields = [];
		variables.data = [];
		variables.resumeallyields = false;
		
		if(structKeyExists(arguments,"success")){variables.success = arguments.success;}
		if(structKeyExists(arguments,"error")){variables.error = arguments.error;}
		if(structKeyExists(arguments,"finally")){variables.finally = arguments.finally;}

		thread name="#variables.name#" action="run" {
			thread action="sleep" name="#variables.name#" duration="10";
			variables.running = true;

			if(structKeyExists(variables,"prior")){
				//Block the execution of this thread untilt he prior future is complete
				variables.prior.get();				
			}

			try {

				if(structKeyExists(variables,"prior")){
					variables.taskLineNumber = callStackGet()[1].lineNumber + 1;
					variables.result = variables.task(this, variables.prior);
				} else {
					variables.taskLineNumber = callStackGet()[1].lineNumber + 1;
					variables.result = variables.task(this);														
				}								
				variables.done = true;
				variables.endTime = getTickCount();
			} catch (any e){
				writeLog("error thrown");
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
			if(!isNull(variables.yieldFrom)){
				variables.yieldFrom.resume();
			}			
		}
	}

	public function then(required future future){
		future._setPrior(this);
		return future;
	}	

	public function get(required numeric milliseconds=0){

		// if(structKeyExists(variables,"taskLineNumber")){
		// 	for(var call in callStackGet()){
		// 		if(call.lineNumber == variables.taskLineNumber){
		// 			writeLog("Do call get from within a future, this will cause an infinite loop if calling get on itself. Instead use then() or yeild() features");
		// 			throw(message = "Do call get from within a future, this will cause an infinite loop if calling get on itself. Instead use then() or yeild() features");
		// 		}
		// 	}			
		// }
		// 
		
		variables.resumeallyields = true;

		if(isCanceled()){
			throw("The thread was canceled, cannot get the result");
		}

		if(variables.sleeping){			
			this.resume();
		}

		thread action="join" name="#variables.name#" timeout="#arguments.milliseconds#";				
		
		if(structKeyExists(variables,"taskError")){
			throw(variables.taskError);
		}

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

	public boolean function isSleeping(){
		return variables.sleeping;
	}

	public boolean function isRunning(){
		return variables.running;
	}

	public function elapsed(){
		if(isDone() or isCanceled()){
			return variables.endTime - variables.startTime;
		} else {
			return getTickCount() - variables.startTime;
		}
	}	


	public function resume(){
		variables.sleeping = false;
	}

	public function call(data){
		//Calling the future directly
		if(!isNull(data)){
			variables.data.append(data);			
		}
		this.resume();
	}

	public function reply(data){
		if(!isNull(variables.yieldFrom)){
			//Calling the last future to yield to this one
			if(!isNull(data)){
				variables.yieldFrom.call(data);
			}
			variables.yieldFrom.resume();
		} else {
			throw("Cannot reply because there was not future which yielded to this one.")
		}
	}

	public function hasData(){
		return variables.data.len() > 0;
	}

	public function yield(future yieldTo){
		
		//If there is a waiting call, we return the call data immediately
		if(this.hasData()){
			var out = variables.data[1];
			variables.data.deleteAt(1);
			return out;
		} else {

			writeLog("No data, should yield");
			
			if(isNull(arguments.yieldTo)){
				_yieldBack();		
			} else {
				_yieldTo(yieldTo);				
			}

			if(this.hasData()){
				var out = variables.data[1];
				variables.data.deleteAt(1);
				return out;
			}
		}
	}	

	public function _yieldBack(){
		if(!isNull(variables.yieldFrom)){
			writeLog("yielding to #variables.yieldFrom.getName()# from #this.getName()#");

			variables.yieldFrom._yieldFrom(this);
			variables.yieldFrom.resume();
			variables.sleeping = true;
			
			while(!variables.yieldFrom.isDone()){
				if(variables.sleeping IS false){
					break;
				}
				// sleep(10);
				this._sleep(10);				
			}
		} else {

			writeLog("Yielded to main thread");
			// return;
			
			//Yielding to the main thread			
			variables.sleeping = true;
			while(variables.sleeping AND variables.resumeallyields is false){
				writeLog("sleeping for main thread");
				sleep(10);
				// this._sleep(10);
			}
			// throw("Nothing to yeild back to. You must define a future to yield to, unless another future yeilded to this.");							
		}
	}

	public function _yieldTo(required future yieldTo){
		writeLog("yielding to #yieldTo.getName()# from #this.getName()#");
		yieldTo._yieldFrom(this);
		yieldTo.resume();	
		variables.sleeping = true;			
		
		while(!yieldTo.isDone()){
			if(variables.sleeping IS false){
				break;
			}
			// sleep(10)
			this._sleep(10);					
		}
	}

	public function _yieldFrom(future yieldFrom){
		variables.yieldFrom = arguments.yieldFrom;
	}

	public void function _sleep(duration=10){
		variables.sleeping = true;
		while(variables.sleeping){
			sleep(arguments.duration);
		}		
	}

	public function _setPrior(future){
		variables.prior = arguments.future;
	}

}