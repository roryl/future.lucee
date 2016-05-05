/**
* My xUnit Test
*/
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
	}

	// executes after every test case
	function teardown( currentMethod ){
	}

/*********************************** TEST CASES BELOW ***********************************/
	
	// Remember that test cases MUST start or end with the keyword 'test'
	function basicFutureTest(){
		
		var future = new future(function(){
			return "foo";
		});
		expect(future.get()).toBe("foo");
		expect(future.get()).toBe("foo");		
	}

	function futureErrorsTest(){
		var future = new future(function(){
			throw("an error");
		});
		expect(future.hasError()).toBeTrue();
		expect(function(){future.get()}).toThrow(message="an error");
	}

	function futureSuccessTest(){

		var future = new future(
			task:function(){
				return 10;
			},
			success: function(result){
				expect(result).tobe(10);
			}
		);
		expect(future.get()).toBe(10);
	}

	function futureFinallyTest(){

		var future = new future(
			task:function(){
				return 10;
			},
			finally: function(result){
				expect(result).tobe(10);
			}
		);
		expect(future.get()).toBe(10);
	}

	function futureErrorFuncTest(){

		var future = new future(
			task:function(){
				throw("an error");
			},
			error: function(result){
				expect(result).tobe("an error");
			}
		);
		expect(function(){future.get()}).toThrow(message="an error");
	}

	function futureAllFuncsTest(){

		var future = new future(
			task:function(){
				return 10;
			},
			success: function(result){
				expect(result).tobe(10);
			},
			finally: function(result){
				expect(result).tobe(10);
			}			
		);		

	}

	function basicExampleTest(){
		include template="/examples/basic.cfm";
	}

	function nestedExampleTest(){		
		expect(function(){
			include template="/examples/nested.cfm";
		}).toThrow( message="could not create a thread within a child thread");
	}

	function parallelExampleTest(){

		include template="/examples/parallel.cfm";			
		// expect(function(){
		// }).toThrow(message="could not create a thread within a child thread");
	}

	function basicExampleTest(){
		include template="/examples/nestedMap.cfm";
	}

	function cancelTest(){		
		var future = new future(function(){
			sleep(1000);
			return "foo";
		});		
		expect(future.isDone()).toBeFalse();
		expect(future.cancel()).toBeTrue();
		expect(future.isDone()).toBeTrue();	
		expect(future.isCanceled()).toBeTrue();	
	}

	function timoutTest(){		
		var future = new future(function(){
			sleep(1000);
			return "foo";
		});		
		
		expect(function(){
			future.get(50);			
		}).toThrow(message="Did not complete the thread before the timeout 50 was reached");
	}

	function elapsedTest(){
		var future = new future(function(){
			sleep(1000);
			return "foo";
		});		
		sleep(50);
		echo(future.elapsed());
		future.get();
		expect(future.elapsed() > 1000).toBeTrue();
	}

	function sleepTest(){

		timer type="outline"{
			thread action="run" name="outer" {
				thread action="sleep" name="outer" duration="50";
				sleep(50);
			}			
			thread action="join" name="outer";
		}
	}

	function recursiveGetErrorTest(){

		writeLog("new recursiveGetErrorTest");
		var future = new future(function(this){
			this.get();
			sleep(1000);
			return 10;
		});
		expect(future.hasError()).toBeTrue();
		// future.get();
	}

	function thenTest(){

		startStartTime = getTickCount();
		writeLog("new thenTest");
		include template="/examples/chainable.cfm";

		var future = new future(function(){
			sleep(1000);
			return 10;
		}).then(new future(function(this, prior){
			sleep(1000);
			prior = prior.get();
			return "20" + prior;
		}));

		startTime = getTickCount();
		writeDump((startTime - startStartTime) / 1000);

		writeDump(future.get());

		endTime = getTickCount();
		writeDump((endTime - startTime) / 1000);

		// writeDump(result.get());
		writeDump(future.get());

		// .then(new future(function(prior){
		// 	sleep(1000);
		// 	return prior + 10;
		// })).get();
		// writeDump(future);
	}

	function manualThenTest(){

		var firstFuture = new future(function(){
			sleep(1000);
			return 10;
		});

		var secondFuture = new future(function(){
			prior = firstFuture.get();			
			sleep(1000);
			return "20" + prior;
		});
				
		try {
		} catch(any e){
			writeDump(e);
			abort;
		}
		
		
	}

	function yeildTest(){

		writeLog("new yieldTest");

		var firstFuture = new future(function(this){
			sleep(1000);
			this.yield();			
			sleep(1000);
			return 10;
		});

		var secondFuture = new future(function(this){
			this.yield(firstFuture);
			sleep(500);
			this.yield();
			return "20";
		});

		// secondFuture.sleep();
		// secondFuture.run();
		writeDump(secondFuture.get());
		writeDump(secondFuture.isDone());

	}
	
}
