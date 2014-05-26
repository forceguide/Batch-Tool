@isTest
private class BatchClassTest {
	
	// Run batch One class
	static testMethod void test_BatchOne() {
		Test.startTest();
		BatchOne batch = new BatchOne();
		Database.executebatch(batch,10);
		Test.stopTest();
	}

	// Run batch Two class
	static testMethod void test_BatchTwo() {
		Test.startTest();
		BatchOne batch = new BatchOne();
		Database.executebatch(batch,10);
		Test.stopTest();
	}

	// Run batch Three class
	static testMethod void test_BatchThree() {
		Test.startTest();
		BatchOne batch = new BatchOne();
		Database.executebatch(batch,10);
		Test.stopTest();
	}

	// Run batch Four class
	static testMethod void test_BatchFour() {
		Test.startTest();
		BatchOne batch = new BatchOne();
		Database.executebatch(batch,10);
		Test.stopTest();
	}

	// Run batch Five class
	static testMethod void test_BatchFive() {
		Test.startTest();
		BatchOne batch = new BatchOne();
		Database.executebatch(batch,10);
		Test.stopTest();
	}
}