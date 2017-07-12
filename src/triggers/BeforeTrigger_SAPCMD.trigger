/**************************************************************
@Created By :       Nisha Agrawal
@Created Date:      30 Sep 2013
@Description:       To generate Funloc record for SAP CMD 
****************************************************************/

trigger BeforeTrigger_SAPCMD on SAP_CMD__c (before insert) 
{
    SapCmdTrigger.generateFunLocAndCopyCustomerAddress(Trigger.new);
}