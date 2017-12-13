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
	
	private List<MnStage__c> mnStages;  
	
	public MnStages(List<MnStage__c> mnStages) {
		super(mnStages);
		
		this.mnStages = (List<MnStage__c>)this.records;
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new MnStages(sObjectList);
		}
	}
	
	public Map<Id, Boolean> checkOpptyProdsExisted() {
		p('checkOpptyProdsExisted');
		Map<Id, Boolean> result = new Map<Id, Boolean>(); // MnStage__c.Id -> Oppty Prod Existed
		Set<String> legacyIds = new Set<String>();
		
		for (MnStage__c ms : this.mnStages) {
			result.put(ms.Id, false);
			legacyIds.add(ms.Reg_Part_OID__c);
		}
		
		List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(legacyIds);
		
		for (MnStage__c ms : this.mnStages) {
			for (OpportunityLineItem oli : opptyProds) {
				if (ms.Reg_Part_OID__c == oli.Legacy_Id__c) {
					result.put(ms.Id, true);
					break;
				} 	
			}	
		}
		
		return result;
	}
	
	public Map<Id, Id> findPricebookEntries() {
		p('findPricebookEntries');
		Map<Id, Id> result = new Map<Id, Id>(); // MnStage__c.Id -> PricebookEntry.Id
		
		Set<String> prodBasicTypes = new Set<String>();
		Set<String> prodSalesItems = new Set<String>();
		
		for (MnStage__c ms : this.mnStages) {
			if (ms.Part_Is_Root__c) {
				prodBasicTypes.add(ms.Part_Root__c);		
			} else {
				prodSalesItems.add(ms.Part_12NC__c);	
			}
		}
		
		List<PricebookEntry> pricebookEntries = new PricebookEntriesSelector().selectByProdBasicTypeOrSalesItemWithProduct(prodBasicTypes, prodSalesItems); 
		
		for (MnStage__c ms : this.mnStages) {
			for (PricebookEntry pe : pricebookEntries) {
				if (ms.Part_Is_Root__c) {
					if (ms.Part_Root__c == pe.Product2.Basic_Type__c && 
				    	ms.Currency_Code__c == pe.CurrencyIsoCode) {
						result.put(ms.Id, pe.Id);
						break;    	
					}
				} else {
					if (ms.Part_12NC__c == pe.Product2.Sales_Item__c && 
				    	ms.Currency_Code__c == pe.CurrencyIsoCode) {
						result.put(ms.Id, pe.Id);
						break;    	
					}	
				}
			}	
		} 	
		
		return result;
	}

}