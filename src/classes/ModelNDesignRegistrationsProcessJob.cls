global class ModelNDesignRegistrationsProcessJob implements Schedulable, Database.Batchable<SObject> {
	
	private static final String STATUS_HOLDING = MnStages.STATUS_HOLDING;
	private static final String STATUS_QUEUED = MnStages.STATUS_QUEUED;
	private static final String STATUS_PROCESSING = MnStages.STATUS_PROCESSING;
	private static final String STATUS_FAILED = MnStages.STATUS_FAILED;
	
	private static final Integer RECORD_COUNT_LIMIT = 10000; // Process 10000 records at a time to avoid hitting governors and limits 
		
	private Id schedJobId;
			
	global ModelNDesignRegistrationsProcessJob() {} // Added no-argument constructor for the Job Scheduler to see this class
	
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
		if (isJobActive(bc.getJobId())) return new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {null}); // Skip processing
		
		Database.QueryLocator result;
		
		if (isSerialMode()) {
			result = new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {STATUS_HOLDING, STATUS_QUEUED}, RECORD_COUNT_LIMIT); 	
		} else {
			result = new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {STATUS_QUEUED}, RECORD_COUNT_LIMIT);
		} 
		
		
		List<MnStage__c> mnStages = new List<MnStage__c>(); 
		
		for (Database.QueryLocatorIterator it = result.iterator(); it.hasNext();) {
			MnStage__c mnStage = (MnStage__c)it.next();	
			mnStage.Status__c = STATUS_PROCESSING;
			mnStage.Message__c = null;
			mnStage.Opportunity__c = null;
			mnStage.Sched_Job_ID__c = this.schedJobId;
			mnStage.Batch_Job_ID__c = bc.getJobId();
			mnStages.add(mnStage);
		} 
		
		update mnStages;
		
		return result;
	}
	
	global void execute(Database.BatchableContext bc, List<MnStage__c> scope) {
		p('execute(batch)');
		try {
			MnStages.newInstance((List<MnStage__c>)new MnStagesSelector().selectSObjectsById(new Map<Id, MnStage__c>(scope).keySet())).processData();
		} catch (Exception e) {
			String message = 'Scheduled Job Id: ' + this.schedJobId + '<br><br>' +
							 'Exception type caught: ' + e.getTypeName() + '<br>' +
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
		
		if (apexJob.Status != 'Completed' || apexJob.NumberOfErrors > 0) {
			updateStatus(bc.getJobId(), apexJob.ExtendedStatus);
			
			String message = 'Scheduled Job Id: ' + this.schedJobId + ', Batch Job Id: ' + bc.getJobId() + '<br><br>' +
		                 	 'Total Batches: ' + apexJob.TotalJobItems + ', Batches Processed: ' + apexJob.JobItemsProcessed + ', Failures: ' + apexJob.NumberOfErrors;
		
			notify(new List<String> {apexJob.CreatedBy.Email}, message);		
		}
	}
	
	public static Boolean isSerialMode() {
		p('isSerialMode');
		return Boolean.valueOf(((List<Model_N_Stage_Setting__mdt>)new ModelNStageSettingsSelector().selectWhere('Name__c = \'Serial_Mode\'')).get(0).Value__c);	
	}
	
	private Boolean isJobActive(Id jobId) {
		p('isJobActive');
		String condition = 'Id != \'' + jobId + '\' and ParentJobId != \'' + jobId + '\' and JobType = \'BatchApex\' and ApexClass.Name = \'' + ModelNDesignRegistrationsProcessJob.class + '\' and '; 
		
		if (isSerialMode()) {
			return new AsyncApexJobsSelector().selectWhere(condition + 'Status in (\'Holding\', \'Queued\', \'Preparing\', \'Processing\')').size() > 0;	
		} else {
			return new AsyncApexJobsSelector().selectWhere(condition + 'Status in (\'Holding\', \'Queued\', \'Preparing\')').size() > 0;	
		}	
	}
	
	@TestVisible 
	private void updateStatus(Id jobId, String message) {
		p('updateStatus');
		List<MnStage__c> mnStages = new MnStagesSelector().selectByStatus(new Set<String> {STATUS_PROCESSING});
		List<MnStage__c> mnStagesUpdated = new List<MnStage__c>(); 
		
		for (MnStage__c ms : mnStages) {
			if (ms.Batch_Job_ID__c == jobId) {
				ms.Status__c = STATUS_FAILED;
				ms.Message__c = message;
				mnStagesUpdated.add(ms);	
			}	
		}
		
		update mnStagesUpdated;
	}
	
	@TestVisible
	private static void notify(List<String> toAddresses, String message) {
		p('notify');
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