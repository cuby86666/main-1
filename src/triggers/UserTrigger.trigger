/****************************************************************************************
@Created By : 	Nisha Agrawal
@Created Date: 	Jun 20, 2018
@Description: 	Trigger on User object to 
				1. Provide Read/Edit access to Lead records to Disti Lead Portal users
****************************************************************************************/

trigger UserTrigger on User (after insert) 
{
    if(trigger.IsAfter && trigger.IsInsert)
    {
		UserTriggerHandler.shareLeadRecordsToLPUsers(trigger.new);        
    }
}