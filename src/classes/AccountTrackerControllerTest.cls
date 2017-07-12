@isTest
private class AccountTrackerControllerTest 
    {
        private static final String PARENT_ACCOUNT_RECORD_TYPE='Parent_Account';
        private static final ID PARENT_ACCOUNT_RECORD_TYPE_ID;
        private static Recordtype rt;
        static
        {
            rt=[Select Id, DeveloperName From RecordType Where IsActive=true AND (SobjectType = 'Account' and (DeveloperName =:PARENT_ACCOUNT_RECORD_TYPE))];
            PARENT_ACCOUNT_RECORD_TYPE_ID=rt.id;
        }
        @isTest
        static void testAccountTrackerController()
        {
            Test.startTest();
            PageReference pageRef = Page.AccountTracker;
            // Insert an account
            Account testAccount = new Account(Name = 'Test Account', Region__c = 'EMEA', RecordTypeId=PARENT_ACCOUNT_RECORD_TYPE_ID);
            insert testAccount;
            // Insert Custom Setting for top Account  
            Top_Accounts__c top = new Top_Accounts__c();
            top.Name = 'Test Account';
            top.Account_Name__c = 'Test Account';
            insert top;
            List<SelectOption> test_options = new List<SelectOption>();
            test_options.add(new SelectOption(top.Name,top.Account_Name__c));
            Test.setCurrentPageReference(new PageReference('AccountTracker'));
            AccountTrackerController controller = new AccountTrackerController();
            controller.selectedAccountName='Test Account';
            controller.getlstAccountName();
            controller.launchTracker();
            System.assertNotEquals(null,controller.launchTracker());
            test.stopTest();
        }
    }