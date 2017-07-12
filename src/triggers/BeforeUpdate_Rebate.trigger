trigger BeforeUpdate_Rebate on eRebate__c (before update) 
{
    RebateTrigger.updateRebateCurrency(Trigger.new);  
        
    RebateTrigger.populateApprovers(Trigger.new);
    
    RebateTrigger.populateBLMarketingApproversFromRebate(Trigger.New , Trigger.oldMap);
}