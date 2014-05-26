global abstract class BatchRunner implements Database.Batchable<sObject> {

  	// Standard interface methods for Database.Batchable
  	global abstract Database.QueryLocator start(Database.BatchableContext ctx);
  	global abstract void execute(Database.BatchableContext ctx, List<sObject> scope);
  	global abstract void finish(Database.BatchableContext ctx);

}