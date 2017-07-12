trigger Customer_AfterTrigger on Customer__c (before insert) {
    if(Trigger.isInsert)
    {
        CustomerTrigger_SAP_CMD_Request.syncGidBackToRequests(Trigger.new); 
    }
}