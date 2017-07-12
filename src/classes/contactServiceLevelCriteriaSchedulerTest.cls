@IsTest
public class contactServiceLevelCriteriaSchedulerTest{
    static testmethod void testCSL() { 
        Test.startTest();
        list<Contact_Service_Level_Criteria__c> lstCSLC=new list<Contact_Service_Level_Criteria__c>();
        lstCSLC=CreateContactServiceLevelCriteria();
        
        contact objContact1=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@CN.BOSCH.COM',CanAllowPortalSelfReg=false,contact_service_level__c=''); 
        
    
        insert objContact1;
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        //schedule the job
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new contactServiceLevelCriteriaScheduler());

        List<CronTrigger> lstCrons = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                    FROM CronTrigger WHERE id = :jobId Limit 1];

        System.assert(lstCrons.size() > 0);
        System.assert(lstCrons[0].CronExpression == CRON_EXP);        
        System.assert(lstCrons[0].TimesTriggered == 0);
        
        contactServiceLevelCriteriaBatch CSLB=new contactServiceLevelCriteriaBatch();
        CSLB.execute(null,lstCSLC);
        Test.stopTest();
    }
    
     private static list<Contact_Service_Level_Criteria__c>CreateContactServiceLevelCriteria()
    {
        list<Contact_Service_Level_Criteria__c> lstCSLC=new list<Contact_Service_Level_Criteria__c>();
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='toni@zollikofer.eu',Contact_Service_Level__c='A-DirectCust'));
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='CN.ABB.COM',Contact_Service_Level__c='A-DirectCust'));
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='CN.BOSCH.COM',Contact_Service_Level__c='A-DirectCust'));
        
        insert lstCSLC;
        return lstCSLC;
    
    }
}