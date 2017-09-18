/***********************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      24 July 2017
@Description:       Schedulable Class to execute StarAccessScanner Class
***********************************************************************************/

global with sharing class StarAccessScannerSchedulable implements Schedulable 
{
	global void execute(SchedulableContext SC) 
	{
		StarAccessScanner scannerBatch = new StarAccessScanner();
		Database.executeBatch(scannerBatch, 200);			
	}	
}