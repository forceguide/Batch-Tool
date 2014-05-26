@isTest(seeAllData=false)
private class BatchJobControllerTest{
		

	/*
	*	Method used to test the saveRecord method
	*/
	static testMethod void test_saveRecord(){
		Test.startTest();
		BatchJobController cls = new BatchJobController(new ApexPages.standardController(new Batch_Job__c(Apex_Class__c='BatchOne',Order__c=1,Parent_Batch_Job__c=null)));
		System.assertNotEquals(null,cls.saveRecord());


		// Test with same order number for the another class
		cls = new BatchJobController(new ApexPages.standardController(new Batch_Job__c(Apex_Class__c='BatchTwo',Order__c=1,Parent_Batch_Job__c=null)));
		cls.saveRecord();
		List<Apexpages.Message> messages = ApexPages.getMessages();
		System.assertEquals(1, messages.size());

		// Test with invalid class name
		cls = new BatchJobController(new ApexPages.standardController(new Batch_Job__c(Apex_Class__c='Test class',Order__c=2,Parent_Batch_Job__c=null)));
		cls.saveRecord();
		messages = ApexPages.getMessages();
		System.assertEquals(2, messages.size());

		// Test with child execution order less than parent execution order
		cls = new BatchJobController(new ApexPages.standardController(new Batch_Job__c(Apex_Class__c='BatchTwo',Order__c=2,Parent_Batch_Job__c=null)));
		cls.saveRecord();
		System.assertNotEquals(null,cls.saveRecord()); 

		Test.StopTest();
	}
}