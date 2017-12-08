public class MnStages extends ApplicationDomain {
	
	public enum Status {QUEUED, PROCESSING, COMPLETED, FAILED, INVALID, IGNORED, ABORTED}
	
	public static final Map<Status, String> STATUSES = new Map<Status, String> {
		Status.QUEUED => 'Queued',
		Status.PROCESSING => 'Processing',
		Status.COMPLETED => 'Completed',
		Status.FAILED => 'Failed',
		Status.INVALID => 'Invalid',
		Status.IGNORED => 'Ignored',
		Status.ABORTED => 'Aborted'
	};
	
	public MnStages(List<MnStage__c> mnStages) {
		super(mnStages);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new MnStages(sObjectList);
		}
	}
	
	public Map<Id, Boolean> checkOpptyProdExisted() {
		Map<Id, Boolean> result = new Map<Id, Boolean>(); // MnStage__c.Id -> Oppty Prod Existed
		Set<String> legacyIds = new Set<String>();
		
		for (MnStage__c ms : (List<MnStage__c>)this.records) {
			result.put(ms.Id, false);
			legacyIds.add(ms.Reg_Part_OID__c);
		}
		
		List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(legacyIds);
		
		for (MnStage__c ms : (List<MnStage__c>)this.records) {
			for (OpportunityLineItem oli : opptyProds) {
				if (ms.Reg_Part_OID__c == oli.Legacy_Id__c) {
					result.put(ms.Id, true);
					break;
				} 	
			}	
		}
		
		return result;
	}
	
}