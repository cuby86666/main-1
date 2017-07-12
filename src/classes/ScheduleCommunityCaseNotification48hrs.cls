/*********************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     23 Mar 2015
Description :      Class to schedule CommunityCaseNotificationAfter48hrs class
***************************************************************************************************/

global class ScheduleCommunityCaseNotification48hrs implements Schedulable
{
	global void execute(SchedulableContext sc) 
    {
        CommunityCaseNotificationAfter48hrs c= new CommunityCaseNotificationAfter48hrs();
		database.executebatch(c);
    }
}