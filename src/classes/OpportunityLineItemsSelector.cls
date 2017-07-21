public class OpportunityLineItemsSelector extends ApplicationSelector {

	public Schema.SObjectType getSObjectType() {
		return OpportunityLineItem.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			OpportunityLineItem.Id,
			OpportunityLineItem.Program__c,
			OpportunityLineItem.OpportunityId
		};
	}
	
	public List<OpportunityLineItem> selectById(Set<Id> ids) {
		System.debug('//- OpportunityLineItemsSelector.selectById');
		return (List<OpportunityLineItem>)selectSObjectsById(ids);
	}
    
}