public class OpportunityProductSchedulesSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return OpportunityProductSchedule__c.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			OpportunityProductSchedule__c.Id,
			OpportunityProductSchedule__c.Frozen_Prod_Sched_Price__c,
			OpportunityProductSchedule__c.Opportunity__c,
			OpportunityProductSchedule__c.Oppty_Prod_ID_Full__c, 
			OpportunityProductSchedule__c.Prod_Sched_Price__c,
			OpportunityProductSchedule__c.Sched_Date__c
		};
	}
	
	public List<OpportunityProductSchedule__c> selectByOpptyId(Set<Id> opptyIds) {
		p('selectByOpptyId');
		return (List<OpportunityProductSchedule__c>)Database.query(newQueryFactory().setCondition('Opportunity__c in :opptyIds').toSOQL());	
	}
	
	public List<OpportunityProductSchedule__c> selectByOpptyIdAndOpptyProdId(Set<Id> opptyIds, Set<Id> opptyProdIds) {
		p('selectByOpptyId');
		return (List<OpportunityProductSchedule__c>)Database.query(newQueryFactory().setCondition('Opportunity__c in :opptyIds and Oppty_Prod_ID_Full__c in :opptyProdIds').toSOQL());	
	}
    
}