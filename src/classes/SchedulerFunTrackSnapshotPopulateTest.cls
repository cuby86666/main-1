/*********************************************************************************************
@Created By :      Balaji G
@CreatedDate :     11 July 2016
Description :      Test Class for SchedulerFunnelTrackerSnapshotPopulate class
****************************************************************************************************/
@isTest 
public class SchedulerFunTrackSnapshotPopulateTest
{
  public static testmethod void testSchedulerFunnelTrackerSnapshotPopulate()
    {
         Test.StartTest();
         SchedulableContext  sc;
         SchedulerFunnelTrackerSnapshotPopulate myClass = new SchedulerFunnelTrackerSnapshotPopulate(); 
         myClass.execute(sc);   
         String chron = '0 0 * * * ?';        
         system.schedule('Test Sched', chron, myClass);
         Test.StopTest();
    }
}