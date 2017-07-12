@IsTest
public class CMD_Request_Scan_Schedule_Test{
    static testmethod void testConvert() { 
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        //schedule the job
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new CMD_Request_Scan_Schedule());

        List<CronTrigger> lstCrons = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                    FROM CronTrigger WHERE id = :jobId Limit 1];

        System.assert(lstCrons.size() > 0);
        System.assert(lstCrons[0].CronExpression == CRON_EXP);        
        System.assert(lstCrons[0].TimesTriggered == 0);
        Test.stopTest();
    }
}