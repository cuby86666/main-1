/***************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      11 Jun 2013
@Description:       To sync Customer from Customer Hub to SF-CRM Account object. 
*******************************************************************************************************/

trigger AfterTrigger_Customer on Customer__c (after insert, after update) 
{
    if(Trigger.isInsert)
    {
        CustomerTrigger.syncCustomerToSfCrm(Trigger.new); 
    }
    else if(Trigger.isUpdate)
    {
        //if (CustomerTrigger.IsFirstRun_AfterUpdate)
        //{
            CustomerTrigger.syncCustomerOnUpdateToSfCrm(Trigger.new, Trigger.oldMap); 
        //}
    }
}