@isTest
private class TaskTriggerTest {
    private static final ID SFDC_RECORD_TYPE_ID;
    private static final String TEST_USER_PROFILE = 'System Administrator';
    private static final String TEST_USER_EMAIL = 'testuser@testorg.com.test';
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_EUR = 'EUR';
    private static final Double EXCH_RATE_USD = 1.0;
    private static final Double EXCH_RATE_EUR = 0.9;
    private static final Integer TASK_COUNT_DEFAULT = 5;
        
    static {
        SFDC_RECORD_TYPE_ID = OpportunitiesSelector.getSfdcRecordTypeId();
    }
    
    @testSetup
    static void setup() {
    	Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL);
        insert u;
        
        // insert approvers
        List<Approvers_Matrix__c> amcs = new List<Approvers_Matrix__c>();
        amcs.add(new Approvers_Matrix__c(Type__c='Regional VP', criteria_2__c='EMEA', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c='Regional VP', criteria_2__c='Americas', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c='Regional Controller', criteria_2__c='EMEA', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c='Regional Controller', criteria_2__c='Americas', Approver__c = u.Id, Threshold_1__c = 0));
        insert amcs;
        
        // insert FX Rates
        // There is a workflow which sets Opportunity.Locked_Exchange_Rate__c to 
        // Opportunity.Currency__r.Exchange_Rate__c, which refers to FX_Rates__c.Exchange_Rate__c
        List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_USD, Currency_Code__c = CCY_CODE_USD, CurrencyIsoCode = CCY_CODE_USD, Exchange_Rate__c = EXCH_RATE_USD));
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_EUR, Currency_Code__c = CCY_CODE_EUR, CurrencyIsoCode = CCY_CODE_EUR, Exchange_Rate__c = EXCH_RATE_EUR));
        insert fxrs;
        
        Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
        fxRates.put(CCY_CODE_USD, fxrs.get(0));
        fxRates.put(CCY_CODE_EUR, fxrs.get(1));
        
        // Insert an account
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA');
        insert a;
        
        // Insert an opportunity
        Opportunity o = new Opportunity(Name = 'Test Oppty', AccountId = a.Id, StageName = 'Initial Engagement');
        o.RecordTypeId = SFDC_RECORD_TYPE_ID;
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = PRODUCTION_DATE - 60;
        o.Currency__c = fxRates.get(CCY_CODE_USD).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o.CurrencyIsoCode = CCY_CODE_USD; // CurrencyIsoCode and Currency__c are correlated.
        insert o;
        
        // Insert a customer project
        Customer_Project__c cp = new Customer_Project__c();
        cp.Opportunity__c = o.Id;
        insert cp;
        
        // Insert tasks
        List<Task> tasks = new List<Task>();
        
        for (Integer i = 1; i <= TASK_COUNT_DEFAULT; i++) {
            Task t = new Task();
            t.OwnerId = u.Id;
            t.Subject = 'task ' + i;
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            t.WhatId = cp.Id; 
            tasks.add(t);
        }
        
        insert tasks;
    }
    
    @isTest
    static void testTaskDueDateSetAsToday() {
        Test.startTest();
        Task t = [select ActivityDate from Task where Subject = 'task 1'];
        t.ActivityDate = null;
        update t;
        Test.stopTest();
        
        t = [select ActivityDate from Task where Subject = 'task 1'];
        
        System.assertEquals(Date.today(), t.ActivityDate);
    }
    
    @isTest
    static void testTaskDueDateNotSetAsToday() {
        Date aDate = Date.newInstance(2100, 10, 30);
        
        Test.startTest();
        Task t = [select ActivityDate from Task where Subject = 'task 1'];
        t.ActivityDate = aDate;
        update t;
        Test.stopTest();
        
        t = [select ActivityDate from Task where Subject = 'task 1'];
        
        System.assertEquals(aDate, t.ActivityDate);
    }
    
    @isTest
    static void testTaskStatusCompletedAndDateNull() {
        Test.startTest();
        Task t = [select Status, Completed_Date__c from Task where Subject = 'task 1'];
        t.Status = 'Completed';
        t.Completed_Date__c = null;
        update t;
        Test.stopTest();
        
        t = [select Completed_Date__c from Task where Subject = 'task 1'];
        
        System.assertEquals(Date.today(), t.Completed_Date__c);        
    }
    
    @isTest
    static void testTaskStatusCompletedAndDateNotNull() {
        Date aDate = Date.newInstance(2100, 10, 30);
        
        Test.startTest();
        Task t = [select Status, Completed_Date__c from Task where Subject = 'task 1'];
        t.Status = 'Completed';
        t.Completed_Date__c = aDate;
        update t;
        Test.stopTest();
        
        t = [select Status, Completed_Date__c from Task where Subject = 'task 1'];
        
        System.assertEquals('Completed', t.Status);
        System.assertEquals(aDate, t.Completed_Date__c);      
    }
    
    @isTest
    static void testTaskStatusNotCompletedAndDateNotNull() {
        Date aDate = Date.newInstance(2100, 10, 30);
        
        Test.startTest();
        Task t = [select Status, Completed_Date__c from Task where Subject = 'task 1'];
        t.Status = 'Not Started';
        t.Completed_Date__c = aDate;
        update t;
        Test.stopTest();
        
        t = [select Status from Task where Subject = 'task 1'];
        
        System.assertEquals('Completed', t.Status);        
    }
    
    @isTest
    static void testTaskStatusNotCompletedAndDateNull() {
        Date aDate = Date.newInstance(2100, 10, 30);
        
        Test.startTest();
        Task t = [select Status, Completed_Date__c from Task where Subject = 'task 1'];
        t.Status = 'Not Started';
        t.Completed_Date__c = null;
        update t;
        Test.stopTest();
        
        t = [select Status, Completed_Date__c from Task where Subject = 'task 1'];
        
        System.assertEquals('Not Started', t.Status);  
        System.assertEquals(null, t.Completed_Date__c);
    }
    
    @isTest
    static void testTaskUndelete() {
        Test.startTest();
        List<Task> tasks = [select Id from Task];
        delete tasks;
        undelete tasks;
        Test.stopTest();
        
        Integer count = [select count() from Task];
        
        System.assertEquals(TASK_COUNT_DEFAULT, count);
    }
    
    @isTest
    static void testCustProjTotalActions() {
        Test.startTest();
        User u = [select Id from User where Email = :TEST_USER_EMAIL];
        Customer_Project__c cp = [select Id from Customer_Project__c];
        
        Task t = new Task();
        t.OwnerId = u.Id;
        t.Subject = 'task test';
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.WhatId = cp.Id;
        insert t;
        Test.stopTest();
        
        cp = [select Total_Actions__c from Customer_Project__c];
        
        System.assertEquals((TASK_COUNT_DEFAULT + 1), cp.Total_Actions__c);
    }
    
    @isTest
    static void testCustProjActionsClosedOnTime() {
        Test.startTest();
        List<Task> tasks = [select ActivityDate, Completed_Date__c from Task];
        Integer count = 0;
        
        for (Task t : tasks) {
            if (Math.mod(count, 2) == 0) {
                t.ActivityDate = Date.today();
                t.Completed_Date__c = Date.today() - 1;
            } else {
                t.ActivityDate = Date.today();
                t.Completed_Date__c = Date.today() + 1;
            }
            
            count++;
        }
        
        update tasks; 
        Test.stopTest();
        
        Customer_Project__c cp = [select Actions_Closed__c from Customer_Project__c];
        
        System.assertEquals(3, cp.Actions_Closed__c);
    }
    
    @isTest
    static void testCustProjActivityTrue() {
        Test.startTest();
        List<Task> tasks = [select Id from Task where Subject != 'task 1'];
        delete tasks;
        
        Task t = [select Completed_Date__c from Task where Subject = 'task 1'];
        t.Completed_Date__c = null;
        update t;
        Test.stopTest();
        
        Customer_Project__c cp = [select Activity__c from Customer_Project__c];
        
        System.assertEquals(true, cp.Activity__c);
    }
    
    @isTest
    static void testCustProjActivityFalse() {
        Test.startTest();
        List<Task> tasks = [select Completed_Date__c from Task];
        
        for (Task t : tasks) {
            t.Completed_Date__c = Date.today();    
        }
        
        update tasks;
        Test.stopTest();
        
        Customer_Project__c cp = [select Activity__c from Customer_Project__c];
        
        System.assertEquals(false, cp.Activity__c);
    }
}