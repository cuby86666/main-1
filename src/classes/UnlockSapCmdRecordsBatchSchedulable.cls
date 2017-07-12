/*********************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      22 Oct 2013
@Description:       Schedulable Class to execute UnlockSapCmdRecordsBatch Class
***********************************************************************************/

global with sharing class UnlockSapCmdRecordsBatchSchedulable implements Schedulable 
{
	global void execute(SchedulableContext SC) 
	{
		UnlockSapCmdRecordsBatch updateBatch = new UnlockSapCmdRecordsBatch();
		Database.executeBatch(updateBatch, 25);
	}
}