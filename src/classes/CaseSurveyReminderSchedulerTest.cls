@IsTest
private class CaseSurveyReminderSchedulerTest{
private final static String CASE_TSCOMMUNITY = 'TS_COMMUNITY';
private Static RecordType tsCommunity;     
     private static void fetchRecordTypes()
    {    
        
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType Where IsActive=true and  
                              (SobjectType = 'Case' and (DeveloperName =: CASE_TSCOMMUNITY))
                                Limit 1])
            
        if(rt.DeveloperName == CASE_TSCOMMUNITY)
        {
            tsCommunity = rt;
        }
    }
    static testmethod void testCaseSurvey() { 
    
        Test.startTest();
        fetchRecordTypes();
       List<Case> lstCases=new List<Case>();
         For(integer i=1; i< 3; i++)
        {
           lstCases.add(new Case(RecordTypeID = tsCommunity.Id, Status= 'Close', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test'+i+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 

'test_country',CreatedDate=system.now().adddays(-7),
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Web_Region__c = 'Test_region',  origin = 

'Web',Case_Owner_Name__c='test',SuppliedEmail = 'test@test.com')); 
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        lstCases=[select id,closeddate,createddate,SuppliedEmail from case where id in:lstCases];
      
        System.debug(lstCases);
       
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        //schedule the job
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new CaseSurveyReminderScheduler());

        List<CronTrigger> lstCrons = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                    FROM CronTrigger WHERE id = :jobId Limit 1];

        System.assert(lstCrons.size() > 0);
        System.assert(lstCrons[0].CronExpression == CRON_EXP);        
        System.assert(lstCrons[0].TimesTriggered == 0);
        
        CaseSurveyReminderScheduler csrs=new CaseSurveyReminderScheduler();
        csrs.execute(null);
        Test.stopTest();
    }
}