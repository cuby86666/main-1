public class OpportunityLineItems extends ApplicationDomain {

	public OpportunityLineItems(List<OpportunityLineItem> opptyProds) {
		super(opptyProds);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new OpportunityLineItems(sObjectList);
		}
	}
	
	public override void onBeforeInsert() {
		System.debug('//- OpportunityLineItems.onBeforeInsert');
		updatePrograms();
	}
	
	public void updatePrograms(fflib_ISObjectUnitOfWork uow) {
		for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)records) {
			opptyProd.Program__c = opptyProd.Opportunity.Program__c;
			uow.registerDirty(opptyProd);	
		}
	}
	
	private void updatePrograms() {
		Set<Id> opptyIds = new Set<Id>();
		
		for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)records) {
			opptyIds.add(opptyProd.OpportunityId);
		}
		
		Map<Id, Opportunity> opptys = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
		
		for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)records) {
			opptyProd.Program__c = opptys.get(opptyProd.OpportunityId).Program__c;	
		}	
	}
    
}