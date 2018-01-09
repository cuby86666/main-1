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
			System.debug('///////// exception: ' + e);	
		}
	}
	
	global void finish(Database.BatchableContext bc) {
		p('finish');	
		System.debug('///////// finish is called');
		//notify(this.schedJobId, bc.getJobId());
	}
	
	private static void notify(Id schedJobId, Id batchJobId) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'jason.mw.tsai@nxp.com'});
        mail.setReplyTo('no.reply@nxp.com');
        mail.setSenderDisplayName('Model N Design Registrations Process Job');
        mail.setSubject('Model N Design Registrations Process Job Failed');
        //mail.setPlainTextBody('Batch job has completed with '+ job.TotalJobItems + ' batches with ' + job.NumberOfErrors + ' failures.' );
        mail.setPlainTextBody('This is a test. Scheduled Job Id: ' + schedJobId + ', Batch Job Id: ' + batchJobId);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});	
	}
	
	private static void p(String msg) {
		CommonUtils.p(ModelNDesignRegistrationsProcessJob.class, '//-c', msg);
   	}
    
}