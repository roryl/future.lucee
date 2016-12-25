component {

	property pool;
	property currentTask;
	property priorTasks;
	property name;
	property thread;	
	property killed;
	property name="sleeping";

	public function init(pool pool, queue queue){

		if(arguments.keyExists("pool")){variables.pool = arguments.pool};
		if(arguments.keyExists("queue")){variables.queue = arguments.queue};

		variables.priorTasks = [];		
		variables.sleeping = false;

		var name = "thread_" & replaceNoCase(createUUID(),"-","","all");
		variables.name = name;
		thread name="#name#" {
			while(true){
				variables.sleeping = false;				
				checkQueue();
				if(!this.hasCurrentTask()){
					writeLog(file="futures", text="sleeping task");
					variables.sleeping = true;
					thread name="#thread.name#" action="sleep" duration="50";
				} else {
					variables.sleeping = false;
					
					var task = variables.currentTask;
					task.setRunning(this);

					try {
						task.run();
					} catch(any e){
						task.runError(e);
					} finally {
						task.runFinally();
					}

					task.setCompleted();
					completeCurrentTask();
				}
			}
			// do {
			// 	if(isNull(variables.currentTask)){
			// 		sleep(500);
			// 	} else {

			// 	}
			// } while(true);
		}
		evaluate("variables.thread = #name#");

		//Ensure that the thread gets into a sleeping state before returning
		while(!this.isSleeping()){
			sleep(10);
		}
		
		return this;
	}

	private void function completeCurrentTask(){
		variables.priorTasks.append(variables.currentTask);
		variables.currentTask = nullValue();
		checkQueue();
	}

	private void function checkQueue(){
		if(variables.keyExists("queue")){
			var nextTask = variables.queue.getNextTask();
			if(!isNull(nextTask)){
				variables.currentTask = nextTask;
			}
		}
	}

	public function getPriorTasks(){
		return variables.priorTasks;
	}

	public function setCurrentTask(required Task Task){

		lock timeout="5" scope="application" {
			if(!this.isSleeping()){ throw("Tasks can only be added to a sleeping thread");}
			if(this.isTerminated()){throw("Cannot add a task to a terminated thread");}
			if(this.isCompleted()){throw("Cannot add a task to a completed thread");}
			if(this.isWaiting()){throw("Cannot add a task to a waiting thread");}
			if(this.hasCurrentTask()){throw("Cannot add a task to a thread which has a current task")}
			variables.currentTask = arguments.task;			
		}
	}

	public boolean function hasCurrentTask(){
		return variables.keyExists("currentTask");
	}

	/**
	 * Returns the status of the running thread, it can be one of the following
	 * NOT_STARTED -  The thread has been queued but is not processing yet.
	 * RUNNNG - The thread is running normally.
	 * TERMINATED - The thread stopped running as a result of one of the following actions:
	 * 		A cfthread tag with a terminate action stopped the thread.
	 * 		An error occurred in the thread that caused it to terminate.
	 * 		A ColdFusion administrator stopped the thread from the Server Monitor.
	 * COMPLETED -The thread ended normally.
	 * WAITING - The thread has run a cfthread tag with action="join", and one or more of the threads being joined have not yet completed.
	 * SLEEPING - The thread is waiting for a task to be supplied. This is not a native Lucee thread implementation
	 * @return {string} [description]
	 */
	public string function getStatus(){
		return variables.thread.status;					
	}

	public boolean function isSleeping(){
		return variables.sleeping;				
	}

	public boolean function isRunning(){
		return getStatus() == "RUNNING";
	}

	public boolean function isNotStarted(){
		return getStatus() == "NOT_STARTED";
	}

	public boolean function isTerminated(){
		return getStatus() == "TERMINATED";
	}

	public boolean function isCompleted(){
		return getStatus() == "COMPLETED";
	}

	public boolean function isWaiting(){
		return getStatus() == "WAITING";
	}

	public void function kill(){				
		thread action="terminate" name="#variables.name#";

		//Must wait on terminating the thread because termination does not appear to be syncrhonous
		while(isRunning()){
			sleep(50);
		}
		variables.sleeping = false;
	}

	

}