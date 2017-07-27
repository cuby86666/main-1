public class OpportunitiesSelector extends ApplicationSelector {

	public Schema.SObjectType getSObjectType() {
		return Opportunity.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Opportunity.Id,
			Opportunity.Program__c 
		};
	}
	
	public List<Opportunity> selectById(Set<Id> ids) {
		System.debug('//- OpportunitiesSelector.selectById');
		return (List<Opportunity>)selectSObjectsById(ids);
	}
	
	public List<Opportunity> selectByIdWithProducts(Set<Id> ids) {
		System.debug('//- OpportunitiesSelector.selectByIdWithProducts');
		fflib_QueryFactory opptiesQueryFactory = newQueryFactory();	
		
		new OpportunityLineItemsSelector().
			addQueryFactorySubselect(opptiesQueryFactory, CommonUtils.getChildRelationshipName(getSObjectType(), OpportunityLineItem.sObjectType)).
			selectField(OpportunityLineItem.OpportunityId.getDescribe().getRelationshipName() + '.' + Opportunity.Program__c);	
		
		return (List<Opportunity>)Database.query(opptiesQueryFactory.setCondition('Id in :ids').toSOQL());
	}
    
}