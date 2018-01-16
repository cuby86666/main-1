global class ModelNDesignRegistrationsProcessJob implements Schedulable, Database.Batchable<SObject> {
	
	private Id schedJobId; 
		
	global ModelNDesignRegistrationsProcessJob() {} // Implement no-arg constructor in order for Job Scheduler to see it.
	
	global ModelNDesignRegistrationsProcessJob(Id schedJobId) {
		this.schedJobId = schedJobId;
	} 
	
	global void execute(SchedulableContext sc) {
		p('execute(schedule)');
		Integer batchSize = Integer.valueOf(((List<Model_N_Stage_Setting__mdt>)new ModelNStageSettingsSelector().selectWhere('Name__c = \'Batch_Size\'')).get(0).Value__c);
		Database.executeBatch(new ModelNDesignRegistrationsProcessJob(sc.getTriggerId()), batchSize);	
	}
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		p('start');
		/*
		Database.QueryLocator mnStageQueryLocator = new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {MnStages.STATUS_QUEUED});
		List<MnStage__c> mnStages = new List<MnStage__c>(); 
		
		for (Database.QueryLocatorIterator it = mnStageQueryLocator.iterator(); it.hasNext();) {
			MnStage__c mnStage = (MnStage__c)it.next();	
		//	mnStage.Status__c = MnStages.STATUS_PROCESSING;
			mnStages.add(mnStage);
		} 
		
		update mnStages;
		
		return mnStageQueryLocator;
		 */
		return new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {MnStages.STATUS_QUEUED});
	}
	
	global void execute(Database.BatchableContext bc, List<MnStage__c> scope) {
		p('execute(batch)');
		try {
			MnStages mnStages = new MnStages(scope);
			mnStages.processData();
		
			for (MnStage__c ms : scope) {
				ms.Sched_Job_ID__c = this.schedJobId;
				ms.Batch_Job_ID__c = bc.getJobId();	
			}
		
			update scope;	
		} catch (Exception e) {
			String message = 'Exception type caught: ' + e.getTypeName() + '<br>' +
			                 'Message: ' + e.getMessage() + '<br>' +
			                 'Cause: ' + e.getCause() + '<br>' +
			                 'Line number: ' + e.getLineNumber() + '<br>' +
			                 'Stack trace: ' + e.getStackTraceString();
			                 
			notify(new List<String> {'globalsales.appsupport@nxp.com'}, message);
		}
	}
	
	global void finish(Database.BatchableContext bc) {
		p('finish');	
		AsyncApexJob apexJob = new AsyncApexJobsSelector().selectByIdWithCreatedBy(new Set<Id> {bc.getJobId()}).get(0);
		
		if (apexJob.Status != 'Completed') {
			String message = 'Scheduled Job Id: ' + this.schedJobId + ', Batch Job Id: ' + bc.getJobId() + '<br><br>' +
		                 	 'Total Batches: ' + apexJob.TotalJobItems + ', Batches Processed: ' + apexJob.JobItemsProcessed + ', Failures: ' + apexJob.NumberOfErrors;
		
			notify(new List<String> {apexJob.CreatedBy.Email}, message);		
		}
	}
	
	@TestVisible
	private static void notify(List<String> toAddresses, String message) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('no.reply@nxp.com');
        mail.setSenderDisplayName('Model N Design Registrations Process Job');
        mail.setSubject('Model N Design Registrations Process Job Failed');
        mail.setHtmlBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});	
	}
	
	private static void p(String msg) {
		CommonUtils.p(ModelNDesignRegistrationsProcessJob.class, '//-c', msg);
   	}
    
}