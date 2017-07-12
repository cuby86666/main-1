trigger OpportunityScheduleTrigger on OpportunitySchedule__c (after delete, after insert, after update, before delete, before insert, before update) {
	TriggerFactory.createTriggerDispatcher(OpportunitySchedule__c.sObjectType);    
}