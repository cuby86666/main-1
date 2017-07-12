/*********************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     23 Mar 2015
Description :      Test Class for ScheduleCommunityCaseNotification48hrs class
****************************************************************************************************/
@isTest 
public class ScheduleComCaseNotification48hrsTest 
{
	public static testmethod void scheduleAccountContactMappingBatchTest1()
    {
         test.starttest();
         SchedulableContext  sc;
         ScheduleCommunityCaseNotification48hrs myClass = new ScheduleCommunityCaseNotification48hrs (); 
         myClass.execute(sc);   
         String chron = '0 0 * * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
        
    }
}