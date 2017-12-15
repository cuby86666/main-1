global class ModelNDesignRegistrationsProcessJob implements Database.Batchable<SObject> {
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		p('start');
		return new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {MnStages.STATUS_QUEUED});
	}
	
	global void execute(Database.BatchableContext bc, List<MnStage__c> scope) {
		p('execute');
		//MnStages mnStages = new MnStages(scope.deepClone(true, true, true));
		MnStages mnStages = new MnStages(scope);
		mnStages.processData();		
	}
	
	global void finish(Database.BatchableContext bc) {
		p('finish');	
	}
	
	private static void p(String msg) {
		CommonUtils.p(ModelNDesignRegistrationsProcessJob.class, '//-c', msg);
   	}
    
}