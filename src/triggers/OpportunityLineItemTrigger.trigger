trigger OpportunityLineItemTrigger on OpportunityLineItem (after delete, after insert, after update, before delete, before insert, before update) {
	TriggerFactory.createTriggerDispatcher(OpportunityLineItem.sObjectType);    
}