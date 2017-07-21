public class Opportunities extends ApplicationDomain {
	
	public Opportunities(List<Opportunity> oppties) {
		super(oppties);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new Opportunities(sObjectList);
		}
	}
	
	public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
		System.debug('//- Opportunities.onAfterUpdate');
		updateOpptyProdPrograms((Map<Id, Opportunity>)existingRecords);
	}
	
	private void updateOpptyProdPrograms(Map<Id, Opportunity> existingRecords) {
		Set<Id> opptyIds = new Set<Id>();
		
		for (Opportunity oppty : (List<Opportunity>)records) {
			Opportunity oldOppty = existingRecords.get(oppty.Id);
			
			if (oppty.Program__c != oldOppty.Program__c) {
				opptyIds.add(oppty.Id);	
			}
		}
		
		if (opptyIds.size() > 0) {
			List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
        
	        for (Opportunity oppty : new OpportunitiesSelector().selectByIdWithProducts(opptyIds)) {
	        	opptyProds.addAll(oppty.OpportunityLineItems);
	        }
	        
	        if (opptyProds.size() > 0) {
	        	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
	        	new OpportunityLineItems(opptyProds).updatePrograms(uow);	
	        	uow.commitWork();
	        }	
		}	
	}
    
}