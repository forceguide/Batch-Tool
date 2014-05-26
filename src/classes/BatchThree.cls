global class BatchThree extends BatchRunner implements Database.Batchable<sObject>{
   	
   	global override Database.QueryLocator start(Database.BatchableContext BC){
      	return Database.getQueryLocator('SELECT Id, Name FROM Account WHERE Name=\'Edge Communications\'');
   	}

   	global override void execute(Database.BatchableContext BC, List<sObject> scope){
        Account account = (Account)scope[0];
        Contact con = new Contact(LastName='Contact'+String.valueOf(System.now()),FirstName='Batch Three',AccountId=account.Id);
        insert con;
    }

   	global override void finish(Database.BatchableContext BC){ 
   	} 
}