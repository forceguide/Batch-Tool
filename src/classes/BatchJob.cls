public with sharing class BatchJob{
	
	public Batch_Job__c		batchJob 	{get; set;}

	/*
	*	Constructor
	*/
	public BatchJob(Batch_Job__c batchJob){
		this.batchJob = batchJob;
	}

	/*
	*	Method used to abort the job
	*/
	public void abortJob(){
		System.abortJob(batchJob.AsyncApexJobId__c);
		batchJob.Status__c = 'Aborted'; 
		update batchJob;
	}

	/*
	*	Method used to abort the job
	*/
	public void scheduleBatch(){
		if (batchJob.Next_Run__c != null){
			update batchJob;
			new Scheduler(batchJob.Next_Run__c,batchJob.Apex_Class__c);
		}
	}

	public void executeBatchJob(){ 
		new BatchManagerTool().reprioritizeBatchJobs(); 
		// Update the batch job with its id 
		batchJob.AsyncApexJobId__c = BatchJobHelper.execute(batchJob.Apex_Class__c);
		batchJob.StartTime__c = System.now(); 
		update batchJob; 
	}
}