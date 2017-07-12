/**********************************************************************************************
@Modified By :    Baji    
@Modified Date :  April 04, 2016  
@Description :    SIR 698 - To Dispach the Emails to the recipeints based on the group name selected by CMD officer 
                  when CMD request status is changed to completed (for first time)
************************************************************************************************/
trigger CMD_Request_AfterTrigger on CMD_Request__c (after update) {
   CMD_Request_Trigger.DispatchEmail( Trigger.New ,Trigger.oldmap); // SIR 698    
}