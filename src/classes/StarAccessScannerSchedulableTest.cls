/************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      24 Jul 2017
@Description:       Test Class for the Class StarAccessScannerSchedulable
**************************************************************************/
@isTest
private class StarAccessScannerSchedulableTest 
{
	static testMethod void StarAccessScannerSchedulableTest1() 
    {
        //start the test
        Test.startTest();
        
        String strCronExpression = '0 0 1 ? * 1';
                
        //schedule the job
        String jobId = System.schedule('TEST_BATCH_SCHEDULE', strCronExpression , new StarAccessScannerSchedulable());
        
        // Get the information from the CronTrigger API object
        List<CronTrigger> lstCrons = [SELECT Id,  CronJobDetail.Name, CronExpression, TimesTriggered, NextFireTime
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