/*************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      @3 Oct 2013
@Description:       Test Class for the Class UnlockSapCmdRecordsBatchSchedulable
*************************************************************************************/

@isTest
private class UnlockSapCmdRecordsBatchSchedulableTest 
{
	static testMethod void UnlockSapCmdRecordsBatchSchedulableTest1() 
    {
       //start the test
        Test.startTest();
        
        String strCronExpression = '0 0 0-23 ? * 2-6';
                
        //schedule the job
        String jobId = System.schedule('TEST_BATCH_SCHEDULE', strCronExpression , new UnlockSapCmdRecordsBatchSchedulable());
        
        // Get the information from the CronTrigger API object
        List<CronTrigger> lstCrons = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
										FROM CronTrigger 
										WHERE id = :jobId
										Limit 1];
		//assert if record found
		System.assert(lstCrons.size() > 0);
									
		//asert if cron expression is same
        System.assert(lstCrons[0].CronExpression == strCronExpression);
        
        //assert Job has not run yet
        System.assert(lstCrons[0].TimesTriggered == 0);
        
        //Stop the test
        Test.stopTest(); 
    }
}