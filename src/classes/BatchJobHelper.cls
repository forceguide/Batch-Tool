public with sharing class BatchJobHelper {

	/*
	*	Create a Map of status by its batch job
	*/
	public static Map<String, List<BatchJob>> mapStatusByBatchJob(List<String> pickListValues){
		Map<String, List<BatchJob>> mapStatusByBatchJob = initBatchJobs(pickListValues);

		// Get all the batch jobs
		List<Batch_Job__c> rsBatchJobs = [SELECT Id, Apex_Class__c, Next_Run__c, Parent_Batch_Job__c, Parent_Batch_Job__r.Status__c, 
											AsyncApexJobId__c, Time_Taken__c, Order__c, Status__c 
												FROM Batch_Job__c ORDER BY Order__c];

		// create a map status by batch job
		for (Batch_Job__c batchJob : rsBatchJobs){
			// Put the list into the map
			if (mapStatusByBatchJob.get(batchJob.Status__c) != null){
				List<BatchJob> batchJobList = mapStatusByBatchJob.get(batchJob.Status__c);
				batchJobList.add(new BatchJob(batchJob));
				mapStatusByBatchJob.put(batchJob.Status__c,batchJobList);
			}
		}

		return mapStatusByBatchJob; 
	}

	/*
	*	@Description : Method used to initialize the batch jobs
	*	@Return : void 
	*/
	private static Map<String, List<BatchJob>> initBatchJobs(List<String> pickListValues){
		Map<String, List<BatchJob>> mapStatusByBatchJob = new Map<String, List<BatchJob>>();

		// Put all the status values in the map 
		for (String pickVal : pickListValues){
			mapStatusByBatchJob.put(pickVal, new List<BatchJob>());
		}
		return mapStatusByBatchJob;  
	}

	/*
	*	Get the asyncjobId and update its status
	*/
	public static void updateStatus(){
		Set<Id> asyncJobIds = new Set<Id>();
		Map<Id, Id> mapAsyncJobIdByBatchJobId = new Map<Id, Id>();

		// Get all the batch jobs
		Map<Id, Batch_Job__c> mapBatchJobs = new Map<Id, Batch_Job__c>([SELECT Id, Apex_Class__c, Parent_Batch_Job__c, Parent_Batch_Job__r.Status__c, 
																				AsyncApexJobId__c, Next_Run__c, Order__c, Status__c 
																			FROM Batch_Job__c ORDER BY Order__c]);

		if (!mapBatchJobs.isEmpty()){
			// Get aysnc job ids 
			for (Batch_Job__c batchJob : mapBatchJobs.values()){
				asyncJobIds.add(batchJob.AsyncApexJobId__c);
				if (!String.isBlank(batchJob.AsyncApexJobId__c)) mapAsyncJobIdByBatchJobId.put(batchJob.AsyncApexJobId__c, batchJob.Id);
			}
			
			// Get the aysncJobIds 
			List<AsyncApexJob> rsAysncJobs = [SELECT Id, Status FROM AsyncApexJob WHERE Id IN: asyncJobIds];

			// Update the batch job record status 
			for (AsyncApexJob apexJob : rsAysncJobs){
				mapBatchJobs.get(mapAsyncJobIdByBatchJobId.get(apexJob.Id)).Status__c = apexJob.Status;
			}

			// update records 
			if (!mapBatchJobs.values().isEmpty()) update mapBatchJobs.values();
		}
	}

	/*
	*	@Description : Method used to trigger the batch job
	*	@Return String returns the apex jobs Id
	*/
	public static String execute(String className){
		Type classType = Type.forName(className);
		BatchRunner batchRun = (BatchRunner)JSON.deserialize('{}',classType);

		// Update the batch job with its id 
		return Database.executeBatch(batchRun,200);
	}
}