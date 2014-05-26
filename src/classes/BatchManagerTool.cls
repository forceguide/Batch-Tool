/*
*	Class used to run the batch job
*/
public with sharing class BatchManagerTool {
	
	public List<BatchTool> 				batchJobsList 	{get; set;}
	public Batch_Manager_Settings__c	batchSettings 	{get{
																return Batch_Manager_Settings__c.getOrgDefaults();
															}set;}

	private final Integer MAX_JOBS_RUN = 5; // if max jobs is entered in the custom settings, it defaults to 5
	public Boolean initJob {get; set;}

	public BatchManagerTool(){
		initJob = false;
	}

	/*
	*	@Description : Method used to get all the picklist values
	*	@Return : List of status picklist values from the batch job sobject
	*/
	public List<String> getPickListValues(){
		List<String> statusList = new List<String>();

		// Get the picklist values
		for (Schema.PicklistEntry pickVal : Batch_Job__c.Status__c.getDescribe().getPicklistValues()){
			statusList.add(pickVal.getLabel());
		}	
		return statusList;
	}

	/*
	*	@Description : Method used to start all the batch jobs (MAX 5)
	*	@Return PageReference null
	*/
	public pageReference startBatchJobs(){
		Integer maxJobsRun = getMaxJobsRun();

		// Start the actual jobs
		List<Batch_Job__c> rsBatchJobs = [SELECT Id, Apex_Class__c, AsyncApexJobId__c, Time_Taken__c, Order__c, Status__c 
											FROM Batch_Job__c WHERE Status__c='Waiting' ORDER BY Order__c];

		// start the batch jobs
		if (rsBatchJobs != null){
			Integer numberOfJobsRunConcurrently = (rsBatchJobs.size() > maxJobsRun ? maxJobsRun : rsBatchJobs.size());
			
			for (Integer i=0;i<numberOfJobsRunConcurrently;i++){
				rsBatchJobs[i].AsyncApexJobId__c = BatchJobHelper.execute(rsBatchJobs[i].Apex_Class__c);
				rsBatchJobs[i].StartTime__c = System.now(); 
			}

			// Update the batch Jobs
			if (!rsBatchJobs.isEmpty()) update rsBatchJobs;

			initJob = true;

			// Refresh the batch jobs
			refreshBatchJobs();
		}

		return null;
	}

	/*
	*	@Description : Method used to abort all the batch jobs
	*	@Return pageReference  null
	*/
	public pageReference abortBatchJobs(){
		// Start the actual jobs
		List<Batch_Job__c> rsBatchJobs = [SELECT Id, Apex_Class__c, AsyncApexJobId__c, Time_Taken__c, Order__c, Status__c 
											FROM Batch_Job__c WHERE Status__c='Queued' OR Status__c='Preparing' OR 
												Status__c='Processing' ORDER BY Order__c];

		// start the batch jobs
		for (Batch_Job__c batchJob : rsBatchJobs){
			System.abortJob(batchJob.AsyncApexJobId__c);
			batchJob.Status__c = 'Aborted'; 
		}

		// Update the batch Jobs
		if (!rsBatchJobs.isEmpty()) update rsBatchJobs;

		initJob = false;

		refreshBatchJobs();

		return null;
	}


	/*
	*	@Description : Method used to get the max number of jobs run 
	*				   It defaults to 5 if user not mentioned in the custom settings
	*	@Return Integer Maximum number of jobs run concurrently
	*/
	private Integer getMaxJobsRun(){
		Integer maxJobsRun = 0;

		// Check if custom settings is not null 
		if (batchSettings != null && batchSettings.Maximum_Jobs_Run_Concurrently__c != null 
				&& batchSettings.Maximum_Jobs_Run_Concurrently__c <=5) maxJobsRun = Integer.valueOf(batchSettings.Maximum_Jobs_Run_Concurrently__c);
		else maxJobsRun = MAX_JOBS_RUN; 

		return maxJobsRun;
	}


	/*
	*	@Description : Method used to get the batch jobs by its status
	*/
	public PageReference refreshBatchJobs(){
		this.batchJobsList = new List<BatchTool>();

		// Update status of the batchjob
		BatchJobHelper.updateStatus();


		// Get the map
		Map<String, List<BatchJob>> mapStatusByBatchJob =  BatchJobHelper.mapStatusByBatchJob(getPickListValues());


		if (initJob){
			// Check if number of queued or processing jobs less than user specified value (number of jobs run concurrrently) in the custom settings
			Integer totalJobsInProgress = mapStatusByBatchJob.get('Queued').size() + mapStatusByBatchJob.get('Preparing').size() + mapStatusByBatchJob.get('Processing').size();
			
			// Update job stati
			if (totalJobsInProgress < getMaxJobsRun() && mapStatusByBatchJob.get('Waiting').size() > 0){
				Integer noOfJobsCanRun = ((getMaxJobsRun() - totalJobsInProgress) <= mapStatusByBatchJob.get('Waiting').size() ? (getMaxJobsRun() - totalJobsInProgress) 
												: mapStatusByBatchJob.get('Waiting').size());

				// Do not worry about soql and dml statements limit, because max 5 jobs can run
				if (noOfJobsCanRun > 0) {
					for (Integer i=0;i<noOfJobsCanRun;i++){
						if(mapStatusByBatchJob.get('Waiting')[i].batchJob.AsyncApexJobId__c == null) mapStatusByBatchJob.get('Waiting')[i].executeBatchJob();
					}
				}
			}
		}
			
		// Create a list 
		for (String status : mapStatusByBatchJob.keySet()){
			this.batchJobsList.add(new BatchTool(status,mapStatusByBatchJob.get(status)));
		}
		return null;
	} 

	/*
	*	@Description : Method used to reprioritise the batch
	*/
	public void reprioritizeBatchJobs(){
		Map<String, List<BatchJob>> mapStatusByBatchJob =  BatchJobHelper.mapStatusByBatchJob(getPickListValues());
		// Check if number of queued or processing jobs less than user specified value (number of jobs run concurrrently) in the custom settings
		Integer totalJobsInProgress = mapStatusByBatchJob.get('Queued').size() + mapStatusByBatchJob.get('Preparing').size() + mapStatusByBatchJob.get('Processing').size();

		if (totalJobsInProgress == getMaxJobsRun()){
			List<BatchJob> batchJobsList = new List<BatchJob>();

			// Add batch jobs to the list
			if (mapStatusByBatchJob.get('Queued').size() > 0) batchJobsList.addAll(mapStatusByBatchJob.get('Queued'));
			if (mapStatusByBatchJob.get('Preparing').size() > 0) batchJobsList.addAll(mapStatusByBatchJob.get('Preparing'));
			if (mapStatusByBatchJob.get('Processing').size() > 0) batchJobsList.addAll(mapStatusByBatchJob.get('Processing'));


			// Loop through batch jobs and abort the jobs with the lease priority
			if (batchJobsList.size() > 0){
				// Get the batch job with the least priority and abort it
				Integer orderNo = 0;
				for (BatchJob batch : batchJobsList){
					orderNo = (Integer.valueOf(batch.batchJob.Order__c) < orderNo ? Integer.valueOf(batch.batchJob.Order__c) : orderNo);
				}

				// Abort the batch job
				for (BatchJob batch : batchJobsList){
					if (Integer.valueOf(batch.batchJob.Order__c) == orderNo) batch.abortJob();
				}
			}
		}
	}

	public class BatchTool{
		public String 			status 				{get; set;}
		public List<BatchJob>	batchJobsList 		{get; set;}	

		/*
		*	Constructor
		*/	
		public BatchTool(String status, List<BatchJob> batchJobsList){
			this.status = status;
			this.batchJobsList = batchJobsList;
		}
	}
}