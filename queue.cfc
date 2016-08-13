component synchronized="true" accessors="true"{

	property name="tasks" setter="false";
	property name="priorTasks" setter="false";

	public function init(){
		variables.tasks = [];
		variables.priorTasks = [];
	}

	public function addTask(required Task task){
		variables.tasks.append(task);
	}

	public function getNextTask(){
		if(variables.tasks.len()){
			var task = variables.tasks[1];
			variables.priorTasks.append(task);
			arrayDeleteAt(variables.tasks, 1);
			return task;			
		} else {
			return nullValue();
		}
	}

	public function countTasks(){
		return variables.tasks.len();
	}

}