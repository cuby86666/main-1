/*****************************************************************************************************************
@Modified By :       Scarlett Kang
@Modified Date:    Oct 23 2015
@Description:      1511 Release - SIR 517, Rebate Product MAG detail is not updated when user update Rebate product
***************************************************************************************************************************/
trigger AfterTrigger_RebateProduct on eRebate_Product__c (after insert, after update, after delete, after undelete) 
{
    if(Trigger.isInsert)
    {
        RebateTrigger.populateMarketingManagersAndBU(Trigger.New);
    }
    else if(Trigger.isDelete)
    {
        RebateTrigger.populateMarketingManagersAndBU(Trigger.Old);
    }
    else if(Trigger.isUndelete)
    {
        RebateTrigger.populateMarketingManagersAndBU(Trigger.New);
    }
    else if(Trigger.isUpdate)
    {
        RebateTrigger.populateCorpControllerApprovers(Trigger.New , Trigger.OldMap);
        /***1511 Release - SIR 517, added by Scarlett***/
        RebateTrigger.populateMarketingManagersAndBU(Trigger.New);
        /***1511 Release - SIR 517, added by Scarlett - END***/
    }
    
}