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
		p('onBeforeInsert');
		OpportunityProductClaimValue.setOpportunityProductClaimValues((List<OpportunityLineItem>)this.records);
		updatePrograms();
	}
	
	public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
		p('onBeforeUpdate');
		OpportunityProductClaimValue.bypassOpportunityProductMnUpdateForTmmaOverride((Map<Id, OpportunityLineItem>)existingRecords, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)this.records));
		OpportunityProductClaimValue.setOpportunityProductClaimValues((List<OpportunityLineItem>)this.records);	
	}
	
	public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
		p('onAfterUpdate');
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		OpportunityProductClaimValue.updateTmmaOverrideIfOpportunityProductMnUpdatedByTmma((Map<ID, OpportunityLineItem>)existingRecords, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)this.records), uow);
		
		uow.commitWork();
	}
	
	public void updatePrograms(fflib_ISObjectUnitOfWork uow) {
		p('updatePrograms(uow)');
		for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
			opptyProd.Program__c = opptyProd.Opportunity.Program__c;
			uow.registerDirty(opptyProd);	
		}
	}
	
	private void updatePrograms() {
		p('updatePrograms');
		Set<Id> opptyIds = new Set<Id>();
		
		for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
			opptyIds.add(opptyProd.OpportunityId);
		}
		
		Map<Id, Opportunity> opptys = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
		
		for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
			opptyProd.Program__c = opptys.get(opptyProd.OpportunityId).Program__c;	
		}	
	}
    
}