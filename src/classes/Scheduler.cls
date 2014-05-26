global class Scheduler implements Schedulable {

	private DateTime scheduleDateTime;
	private String className;

	/*
	*	Constrcutor
	*/
	public Scheduler(String className){
		this.className = className;
	}
	
	/*
	*	Constrcutor taking schedule date time and class name as a parameter
	*/
	public Scheduler(DateTime scheduleDateTime, String className){
		this.scheduleDateTime = scheduleDateTime;
		this.className = className;
		execute();
	}

	/*
	*	creates a schedule job
	*/
	global void execute(SchedulableContext ctx) {
		BatchJobHelper.execute(this.className);
		
	}

	global void execute(){ 
		System.schedule(this.className+'-'+System.now(),createCronString(),new Scheduler(this.className));
	}

	/*
	*	@Description: Method used to create a cronString
	*/
	private String createCronString(){ 
		String cronString = '';
		// Check scheduled datetine is not null
		if (this.scheduleDateTime != null){
			cronString = String.valueOf(this.scheduleDateTime.second())+' '+
						 String.valueOf(this.scheduleDateTime.minute())+' '+
						 String.valueOf(this.scheduleDateTime.hour())+' '+
						 String.valueOf(this.scheduleDateTime.day())+' '+
						 String.valueOf(this.scheduleDateTime.month())+' '+  
						 '?'; 
		}
		return cronString; 
	}
}