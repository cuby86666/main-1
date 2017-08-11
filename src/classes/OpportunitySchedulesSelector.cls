public class OpportunitySchedulesSelector extends ApplicationSelector {
    
	public override Schema.SObjectType getSObjectType() {
		return OpportunitySchedule__c.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			OpportunitySchedule__c.Frozen_Oppty_Sched_Qty__c,
			OpportunitySchedule__c.Opportunity__c,
			OpportunitySchedule__c.Oppty_Sched_Qty__c, 
			OpportunitySchedule__c.Sched_Date__c
		};
	}
	
	public override String getOrderBy() {
		return OpportunitySchedule__c.Opportunity__c + ', ' + OpportunitySchedule__c.Sched_Date__c;
	} 
	
	public List<OpportunitySchedule__c> selectByOpptyId(Set<Id> opptyIds) {
		p('selectByOpptyId');
		return (List<OpportunitySchedule__c>)Database.query(newQueryFactory().setCondition('Opportunity__c in :opptyIds').toSOQL());	
	}   
    
}