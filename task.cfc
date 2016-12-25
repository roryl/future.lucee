component accessors="true" {

	property name="task";
	property name="onSuccess";
	property name="onError";
	property name="finally";
	property name="error";	
	property name="result";
	property name="thread";	
	property name="status" setter="false";

	public function init(required function task, function onSuccess, function onError, function onFinally){
		variables.task = arguments.task;
		if(structKeyExists(arguments,"onSuccess")){variables.onSuccess = arguments.onSuccess;}
		if(structKeyExists(arguments,"onerror")){variables.onerror = arguments.onerror;}
		if(structKeyExists(arguments,"onfinally")){variables.onfinally = arguments.onfinally;}

		variables.status = "new";		
	}

	public function hasOnSuccess(){
		return variables.keyExists("onSuccess");
	}

	public function hasOnError(){
		return variables.keyExists("onError");
	}

	public function hasOnFinally(){
		return variables.keyExists("onFinally");
	}

	public function hasError(){
		return variables.keyExists("error");
	}

	public function isRunning(){
		return variables.status == "running";
	}

	public function isCompleted(){
		return variables.status == "completed";
	}

	public function isKilled(){
		return variables.status == "killed";
	}

	public void function kill(){
		if(structKeyExists(variables,"thread")){
			variables.status = "killed";
			variables.thread.kill();
		} else {
			variables.status = "killed";
		}
	}

	public void function setRunning(required thread thread){
		variables.thread = arguments.thread;
		variables.status = "running";
	}

	public void function setCompleted(){
		variables.status = "completed";
	}

	public function run(){
		variables.result = evaluate("variables.task()");
	}

	public function runError(error){
		variables.error = arguments.error;
		if(hasOnError()){
			evaluate("variables.onError(variables.error)");
		}
	}

	public function runFinally(){
		if(hasOnFinally()){
			evaluate("variables.onFinally()");
		}
	}

	public function getResult(timeout=0){
		var start = getTickCount();
		while(!this.isCompleted()){
			sleep(50);
			var currentTime = getTickCount();
			if(timeout > 0)
			{
				if((currentTime - start) > timeout){
					throw("Did not complete the thread before the timeout #timeout# was reached")
				}				
			}
		}
		if(this.hasError()){
			throw(variables.error);
		}
		return variables.result?: nullValue();
	}

}