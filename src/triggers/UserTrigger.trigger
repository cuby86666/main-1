/***************************************************************************************************************************
@Created By : 	Nisha Agrawal
@Created Date: 	Jun 20, 2018
@Description: 	Trigger on User object to 
				1. Provide Read/Edit access to Lead records to Disti Lead Portal users when new user onboarded
------------------------------------------------------------------------------------------------------------------------
Modified By : 		Nisha Agrawal
@Modified Date : 	Jul 30, 2018
Description : 		Modified to Provide Edit access to Lead records to Disti Lead Portal users when promoted to Regional User role
*****************************************************************************************************************************/

trigger UserTrigger on User (after insert, after update) 
{
    if(trigger.IsAfter && trigger.IsInsert)
    {
        UserTriggerHandler.IsFirstRun_LP = true;        
		UserTriggerHandler.shareLeadRecordsToLPUsers(trigger.new, trigger.oldMap);        
    }
    else if(trigger.IsAfter && trigger.IsUpdate)
    {
		UserTriggerHandler.shareLeadRecordsToLPUsers(trigger.new, trigger.oldMap);        
    }
}