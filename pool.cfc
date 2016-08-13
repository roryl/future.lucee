component syncrhonized="true" accessors="true"{

	property name="threads";
	property name="maxsize";
	property name="queue";	

	public function init(poolsize=5, maxsize=10){

		variables.poolsize = arguments.poolsize;
		variables.maxsize = arguments.maxsize;
		variables.queue = new queue();

		if(isNull(application.pool)){
			variables.threads = [];
			application.pool = this;			
			for(var i= 1; i <= poolsize; i++){
				this.new();
			}
			return this;
		} else {
			return application.pool;
		}
	}

	public numeric function countThreads(){
		return variables.threads.len();
	}

	public numeric function countSleeping(){
		var sleeping = 0
		for(var thread in variables.threads){
			if(thread.isSleeping()){
				sleeping++;
			}
		}
		return sleeping;
	}

	public function hasFreeThread(){
		return countThreads() < countSleeping();
	}

	public boolean function isAtMaxThreads(){
		return countThreads() >= variables.maxSize;
	}

	public function resize(){
		while(!this.hasFreeThread() and !this.isAtMaxThreads()){
			this.new();
		}
	}

	public function new(){
		var newThread = new thread(this, variables.queue);
		variables.threads.append(newThread);
		return newThread;
	}

	public function killAll(){
		for(var thread in threads){
			thread.kill();
		}
	}

	private function findAvailableThread(){
		 for(var thread in variables.threads){
		 	if(thread.isSleeping() and !thread.hasCurrentTask()){
		 		return thread;
		 	}
		 }
		 return nullValue();
	}

	public function getThread(){
		return findAvailableThread();
	}



}