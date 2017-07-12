/* 
 * @created by : Baji
 * @created date : 11 Mar, 2015
 * Description : To improve the code coverage
*/ 
@isTest
global class Approval_History_ScheduleTest{
    static testmethod void Approval_History_ScheduleTestMethod() { 
        Test.startTest();
        //String strCronExpression = '0 0 0 3 9 ? 2022';
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        //schedule the job
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new Approval_History_Schedule());
        // Get the information from the CronTrigger API object
        List<CronTrigger> lstCrons = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                    FROM CronTrigger WHERE id = :jobId Limit 1];
        //assert if record found
        System.assert(lstCrons.size() > 0);
        
        //asert if cron expression is same
        System.assert(lstCrons[0].CronExpression == CRON_EXP);
        
        //assert Job has not run yet
        System.assert(lstCrons[0].TimesTriggered == 0);
        Test.stopTest();
    }
}