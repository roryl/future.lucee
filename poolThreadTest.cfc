component extends="testbox.system.BaseSpec"{
	
/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all test cases
	function beforeTests(){
	}

	// executes after all test cases
	function afterTests(){
	}

	// executes before every test case
	function setup( currentMethod ){
		setting requesttimeout="10";
		structDelete(application,"pool");
	}

	// executes after every test case
	function teardown( currentMethod ){
		structDelete(application,"pool");
	}

/*********************************** TEST CASES BELOW ***********************************/

	function poolTest(){
		var pool = new pool();		
		myThread = pool.new();
		assert(myThread.isRunning(), "The new thread should be running");
		myThread.kill();
	}

	function poolMultipleThreadsTest(){
		var pool = new pool(3);
		assert(pool.countThreads() == 3, "There should have been three threads in the pool");
	}

	function threadKillTest(){
		var thread = new thread();
		sleep(500);		

		assert(thread.isSleeping(), "The thread should have been sleeping (waiting on a task)")
		thread.kill();
		assert(thread.isTerminated(), "The thread should have been terminated");
	}

	function threadTest(){
		var thread = new thread();
		sleep(500);		

		assert(thread.isSleeping(), "The thread should have been sleeping (waiting on a task)")
		thread.kill();
		assert(thread.isTerminated(), "The thread should have been terminated");
	}

	function taskTest(){
		var task = new task(function(){
			//do something
		});
	}

	function executeTaskTest(){

		var counter = 0;
		var task = new task(function(){
			counter++;
		});

		var myThread = new thread();				
		myThread.setCurrentTask(task);

		task.getResult();
		assert(counter == 1, "The counter should have incremented by 1");		
		myThread.kill();
	}

	function errorTaskTest(){

		var counter = 0;
		var task = new task(function(){
			throw("found an error");
		});

		var myThread = new thread();				
		myThread.setCurrentTask(task);

		try {
			task.getResult();			
		}catch (any e){
			assert(e.message == "found an error", "Should have been the message 'found an error'");
		}
		// writeDump(task.getError());
		// assert(counter == 1, "The counter should have incremented by 1");		
		myThread.kill();
	}

	function queueTest(){

		var queue = new queue();
		var myThread = new thread(queue=queue);
		var counter = 0;
		var task = new task(function(){
			counter++;
		});
		queue.addTask(task);
		task.getResult();
		assert(counter == 1, "The counter should have been 1");
		assert(queue.getPriorTasks().len() == 1, "The len of prior tasks should have been 1");
	}

	function findAvailableThreadTest(){

		var pool = new pool();
		var pool2 = new pool();
		myThread = pool.getThread();
		writeDump(myThread.getStatus());
		pool.killAll();
	}

	function countSleepingTest(){
		var pool = new pool();
		assert(pool.countSleeping() == 5, "Should be 5 threads sleeping");
	}

	function resizeTest(){
		var pool = new pool(1, 2);
		var task = new task(function(){
			sleep(2000);
		});
		pool.resize();
		assert(pool.countThreads() == 2, "should have been 2 threads in the pool");
	}

	function nestedThreadTest(){

		//Tried to see if nested threads work with lucee admin tasks, but they do not seem to
		server.counter = 0;
		thread type="task" name="foo" {
			server.counter++;
			server.counter++;
			
			thread name="bar" {
				server.counter++;
			}

		}
		sleep(100);
		// thread action="join" name="foo";
		// writeDump(server.counter);
	}

}