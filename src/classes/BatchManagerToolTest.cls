@isTest(seeAllData=false)
public with sharing class BatchManagerToolTest {
	
	private static List<Batch_Job__c> batchJobList;
	private static Boolean testDataCreated = false;

	/*
	*	Create Test Data
	*/
	private static void setUpTestData(){
		batchJobList = new List<Batch_Job__c>{ new Batch_Job__c(Apex_Class__c='BatchOne',Order__c=1,Parent_Batch_Job__c=null),
											   new Batch_Job__c(Apex_Class__c='BatchTwo',Order__c=2,Parent_Batch_Job__c=null),
											   new Batch_Job__c(Apex_Class__c='BatchThree',Order__c=3,Parent_Batch_Job__c=null)
											};
		insert batchJobList;

		// Create batch manager settings 
		Batch_Manager_Settings__c batchSettings = new Batch_Manager_Settings__c(Maximum_Jobs_Run_Concurrently__c=1);
		insert batchSettings;

		testDataCreated = true;
	}


	/*
	*	Mrthod used to test startJobs
	*/
	static testMethod void test_startBatchJobs(){
		Test.startTest();
		if (!testDataCreated) setUpTestData();
		BatchManagerTool cls = new BatchManagerTool();
		cls.startBatchJobs();
		System.assertNotEquals(null,cls.batchJobsList.size());

		// Loop through batch jobs list and check the waiting jobs size
		for(BatchManagerTool.BatchTool batch : cls.batchJobsList){
			if (batch.status == 'Waiting'){
				System.assertEquals(2,batch.batchJobsList.size());

				if (batch.batchJobsList.size() == 2){
					batch.batchJobsList[0].executeBatchJob();
					batch.batchJobsList[1].batchJob.Next_Run__c = System.now().addHours(1);
					batch.batchJobsList[1].scheduleBatch();
					batch.batchJobsList[0].abortJob();
				}
			}
		}

		// Test Batch Job as well

		Test.stopTest();
	}

	/*
	*	Mrthod used to test abortJobs
	*/
	static testMethod void test_abortBatchJobs(){
		Test.startTest();
		if (!testDataCreated) setUpTestData();
		BatchManagerTool cls = new BatchManagerTool();
		cls.startBatchJobs();
		System.assertNotEquals(null,cls.batchJobsList.size());

		// Loop through batch jobs list and check the waiting jobs size
		for(BatchManagerTool.BatchTool batch : cls.batchJobsList){
			if (batch.status == 'Waiting'){
				System.assertEquals(2,batch.batchJobsList.size());
			}
		}
		cls.abortBatchJobs();
		List<Batch_Job__c> rsBatchJobs = [SELECT Id FROM Batch_Job__c WHERE Status__c='Aborted' ORDER BY Order__c];
		System.assertEquals(1,rsBatchJobs.size());
		Test.stopTest();
	}
}