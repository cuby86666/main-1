/*********************************************************************************************
@Created By :      Balaji G
@CreatedDate :     11 July 2016
Description :      Release 1607 SIR960 Class to schedule FunnelTrackerSnapshotPopulateBatch class
***************************************************************************************************/

global class SchedulerFunnelTrackerSnapshotPopulate implements Schedulable
{
  global void execute(SchedulableContext sc) 
    {
        FunnelTrackerSnapshotPopulateBatch c= new FunnelTrackerSnapshotPopulateBatch();
    database.executebatch(c);
    }
}