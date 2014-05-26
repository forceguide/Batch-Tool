public with sharing class BatchJobController {
	public ApexPages.StandardController 		stdController 	{get; set;}
	
	/*
	*	@Description : Constructor taking standard controller as a parameter
	*/
	public BatchJobController(ApexPages.StandardController controller) {
		stdController = controller;
	}


	/*
	*	@Description : Method used to save the batch job record
	*	@Return PageReference Detail page of the record
	*/ 
	public PageReference saveRecord(){
		try{
			Boolean hasError = false;

			Batch_Job__c batchJob = (Batch_Job__c)stdController.getRecord();

            System.Type classType = System.Type.forName(null,batchJob.Apex_Class__c);
            
            BatchRunner batchRunnerInstance;

            try{
            	batchRunnerInstance = (BatchRunner) JSON.deserialize('{}',classType);
            }catch(Exception ex){}
            
            

            if (batchRunnerInstance == null) {
               	hasError = true;// important to check 
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, batchJob.Apex_Class__c+' is not a valid batch class.'));
            }

			if(hasError) return null;

			// Create a schecule if Next run is not null 
			if (batchJob.Next_Run__c != null) new Scheduler(batchJob.Next_Run__c,batchJob.Apex_Class__c);

			// Upsert batch job
			upsert batchJob;

			return new ApexPages.StandardController(batchJob).view();
		}catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
		}

		return null;
	}
}