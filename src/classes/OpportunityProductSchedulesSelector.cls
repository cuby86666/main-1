public class OpportunityProductSchedulesSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return OpportunityProductSchedule__c.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			OpportunityProductSchedule__c.Id,
			OpportunityProductSchedule__c.Frozen_Oppty_Sched_Qty__c,
			OpportunityProductSchedule__c.Frozen_Prod_Sched_Price__c,
			OpportunityProductSchedule__c.Opportunity__c,
			OpportunityProductSchedule__c.Oppty_Prod_ID_Full__c,
			OpportunityProductSchedule__c.Oppty_Sched_Qty__c, 
			OpportunityProductSchedule__c.Prod_Sched_Price__c,
			OpportunityProductSchedule__c.Sched_Date__c
		};
	}
	
	public override String getOrderBy() {
		return String.valueOf(OpportunityProductSchedule__c.Sched_Date__c);
	}
	
	public List<OpportunityProductSchedule__c> selectByOpptyId(Set<Id> opptyIds) {
		p('selectByOpptyId');
		return (List<OpportunityProductSchedule__c>)Database.query(newQueryFactory().setCondition('Opportunity__c in :opptyIds').toSOQL());	
	}
	
	public Map<Id, List<OpportunityProductSchedule__c>> selectByOpptyIdGroupByOpptyId(Set<Id> opptyIds) {
		p('selectByOpptyIdGroupByOpptyId');
		Map<Id, List<OpportunityProductSchedule__c>> result = new Map<Id, List<OpportunityProductSchedule__c>>();
        
        for (OpportunityProductSchedule__c ops : selectByOpptyId(opptyIds)) {
            if (result.containsKey(ops.Opportunity__c)) {
            	result.get(ops.Opportunity__c).add(ops);
            } else {
            	result.put(ops.Opportunity__c, new List<OpportunityProductSchedule__c> {ops});
            }
        }
        
        return result;	
	}
	
	public List<OpportunityProductSchedule__c> selectByOpptyIdAndOpptyProdId(Set<Id> opptyIds, Set<Id> opptyProdIds) {
		p('selectByOpptyId');
		return (List<OpportunityProductSchedule__c>)Database.query(newQueryFactory().setCondition('Opportunity__c in :opptyIds and Oppty_Prod_ID_Full__c in :opptyProdIds').toSOQL());	
	}
    
}