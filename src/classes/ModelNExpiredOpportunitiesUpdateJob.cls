global class ModelNExpiredOpportunitiesUpdateJob implements Database.Batchable<SObject>, System.Schedulable {
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
    	String openAndExpiredModelNOpptys = 'select Id, Name, StageName, Expiration_Date__c from Opportunity where RecordType.Name = \'Model N Oppty\' and StageName not in (\'Cancelled\', \'AOP\') and IsClosed = false and Expiration_Date__c < TODAY';  
      	return Database.getQueryLocator(openAndExpiredModelNOpptys);
    }
    
	global void execute(System.SchedulableContext sc) {
   		Database.executeBatch(new ModelNExpiredOpportunitiesUpdateJob());     
    }	

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.debug('//J ModelNExpiredOpportunitiesUpdateJob starts');	
		
		OpportunityHelper.modelNExpiredOpportunitiesUpdate(scope);
        
		System.debug('//J ModelNExpiredOpportunitiesUpdateJob ends');	
   }

   global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
              				  FROM AsyncApexJob 
              			     WHERE Id = :bc.getJobId()];       
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'globalsales.appsupport@nxp.com'});
        mail.setReplyTo('no.reply@nxp.com');
        mail.setSenderDisplayName('Model N Daily Job');
        mail.setSubject('Model N Expired Opportunities Batch Job');
        mail.setPlainTextBody('Batch job has completed with '+ job.TotalJobItems + ' batches with ' + job.NumberOfErrors + ' failures.' );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
   }
}