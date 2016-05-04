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
		}).toThrow(message="could not create a thread within a child thread");
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

	
}
