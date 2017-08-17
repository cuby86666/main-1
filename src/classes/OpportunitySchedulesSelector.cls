public class OpportunitySchedulesSelector extends ApplicationSelector {
    
	public override Schema.SObjectType getSObjectType() {
		return OpportunitySchedule__c.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			OpportunitySchedule__c.Id,
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
	
	public List<OpportunityScheduleValueSummary> selectSchedValueByOpptyIdGroupByOpptyId(Set<Id> opptyIds) {
		p('selectSchedValueByOpptyIdGroupByOpptyId');
		List<OpportunityScheduleValueSummary> result = new List<OpportunityScheduleValueSummary>();
		
		List<AggregateResult> schedValues = 
            [select Opportunity__c opptyId, sum(Frozen_Oppty_Sched_Qty__c) totalFrozenSchedQty, count(Id) totalCount
               from OpportunitySchedule__c 
              where Opportunity__c in :opptyIds 
             group by Opportunity__c];
         	 
		for (AggregateResult ar : schedValues) {
			result.add(new OpportunityScheduleValueSummary(ar));	
		}         	 	
		
		return result;
	}  
	
	public class OpportunityScheduleValueSummary {
		private AggregateResult result;
		
		private OpportunityScheduleValueSummary(AggregateResult result) {
			this.result = result;	
		}
		
		public Id opptyId { 
			get { return (Id)result.get('opptyId'); } 
		}
		
		public Double totalFrozenSchedQty { 
			get { return (Double)result.get('totalFrozenSchedQty'); } 
		}
		
		public Integer totalCount { 
			get { return (Integer)result.get('totalCount'); } 
		}
	}
    
}