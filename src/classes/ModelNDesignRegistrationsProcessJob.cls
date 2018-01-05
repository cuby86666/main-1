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
		return new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {MnStages.STATUS_QUEUED});
	}
	
	global void execute(Database.BatchableContext bc, List<MnStage__c> scope) {
		p('execute(batch)');
		MnStages mnStages = new MnStages(scope);
		mnStages.processData();
		
		for (MnStage__c ms : scope) {
			ms.Sched_Job_ID__c = this.schedJobId;
			ms.Batch_Job_ID__c = bc.getJobId();	
		}
		
		update scope;		
	}
	
	global void finish(Database.BatchableContext bc) {
		p('finish');	
	}
	
	private static void p(String msg) {
		CommonUtils.p(ModelNDesignRegistrationsProcessJob.class, '//-c', msg);
   	}
    
}