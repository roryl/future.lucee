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
	function myMethodTest(){

		var future1 = new future(function(){
			sleep(1000);
			return 10;
		});

		var future2 = new future(function(){
			sleep(2000);
			return 5;
		});

		var when = new when(
			future1,
			future2			
		);

		var future = when.any(function(future){
			return future.get();
		});

		writeDump(future.get());

		var future = when.all(function(){
			return "all done";
		});

		writeDump(future.get());

		writeDump(when.get());

	}
	
}
