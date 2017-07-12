trigger BeforeInsert_Rebate on eRebate__c (before insert) 
{
    RebateTrigger.updateRebateCurrency(Trigger.new);
    
    RebateTrigger.populateApprovers(Trigger.new);
}