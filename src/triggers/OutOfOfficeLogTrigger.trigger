trigger OutOfOfficeLogTrigger on Out_Of_Office_Log__c(before insert,before update) 
{
    if(Trigger.isInsert)
    {
                OutOfOfficeHelper.checkForOverlap(Trigger.new);
    }
}