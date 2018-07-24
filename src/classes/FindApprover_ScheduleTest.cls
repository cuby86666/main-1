@isTest
public class FindApprover_ScheduleTest {
    static testmethod void testFindAppproverScheduler() {
        Test.startTest();    
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new FindApprover_Schedule());
        
        List<CronTrigger> lstCrons = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                    FROM CronTrigger WHERE Id = :jobId Limit 1];
        
        System.assert(lstCrons.size() > 0);
        System.assert(lstCrons[0].CronExpression == CRON_EXP);
        System.assert(lstCrons[0].TimesTriggered == 0);
        
        Test.stopTest();
        
        AsyncApexJob pending = [SELECT Id FROM AsyncApexJob WHERE apexClass.Name = 'FindApprover'];
    	system.abortJob(pending.Id);
    }
}