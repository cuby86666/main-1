/*
@Created By :       Nisha Agrawal
@Created Date:      16 Oct 2012
@Description:       Test Class for Trigger AfterUpdate_Account

@Modified By :      Nisha Agrawal
@Modified Date:     08 Nov 2012
@Description:       To remove the side effect of Validation Rule - DB Fields Admin Only on Account. 

*/

@isTest
private class AfterUpdate_AccountTest 
{
    //Case - Status_of_D_B_Cleansing__c = 'Can\'t Upload'
    
     private static final String TEST_USER_EMAIL = String.valueOf(Datetime.now().getTime()) + '@testorg.com';
     private static final String TEST_USER_NAME = TEST_USER_EMAIL + '@testorg.com.test';
    
    static testMethod void AfterUpdate_AccountTest1() 
    {
        //prepare test data        
        //get profile
        List<Profile> lstProfiles = [Select Id, Name From Profile Where Name = 'System Administrator' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            
            User objUser = new User(alias = 'UTest', email=TEST_USER_EMAIL , emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', username= TEST_USER_NAME);
                                 
            insert objUser;
            
            //assert the user
            system.assert(objUser.Id != null);
            
            //get the record type for account
            List<RecordType> lstRecordTypes = [Select Id, DeveloperName, SobjectType  
                                               From RecordType
                                               Where SobjectType = 'Account' and DeveloperName = 'Child_Account' and IsActive=true
                                               Limit 1];
            RecordType childAccount;
            if(lstRecordTypes.size() > 0)
            {
                childAccount = lstRecordTypes[0];
            }
            
            system.runAs(objUser)
            {
                Account objAccount = new Account(Name='Unit Test Account', RecordTypeId = childAccount.Id);
                insert objAccount;
                
                //start the Test       
                Test.startTest();
                
                objAccount.Status_of_D_B_Cleansing__c = 'Can\'t Upload';
                update objAccount;
                
                //fetch the task 
                List<Task> lstTasks = [Select Id , Subject, Priority , ActivityDate , IsReminderSet, ReminderDateTime
                                        From Task 
                                        Where OwnerId =: objUser.Id and WhatId =: objAccount.Id Limit 1];
                //assert the results
                system.assert(lstTasks.size() > 0);
                
                Task objTask = lstTasks[0];
                system.assert(objTask.Priority == 'High');
                system.assert(objTask.IsReminderSet == true);
                //system.assert(objTask.ActivityDate == Date.today().addDays(30));
                //system.assert(objTask.ReminderDateTime == Date.today().addDays(15));
                
                //stop the test
                Test.stopTest();
            }           
        }
    }
    
    //Case - Status_of_D_B_Cleansing__c = 'Please Review'
    
   /* static testMethod void AfterUpdate_AccountTest2() 
    {
        //prepare test data        
        //get profile
        List<Profile> lstProfiles = [Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            
            User objUser = new User(alias = 'UTest', email='unit.test@test.com', emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', username= 'unit.test@test.com');
                                 
            insert objUser;
            
            //assert the user
            system.assert(objUser.Id != null);
            
            //get the record type for account
            List<RecordType> lstRecordTypes = [Select Id, DeveloperName, SobjectType  
                                               From RecordType
                                               Where SobjectType = 'Account' and DeveloperName = 'Child_Account' and IsActive=true
                                               Limit 1];
            RecordType childAccount;
            if(lstRecordTypes.size() > 0)
            {
                childAccount = lstRecordTypes[0];
            }
            
            system.runAs(objUser)
            {
                Account objAccount = new Account(Name='Unit Test Account', RecordTypeId = childAccount.Id);
                insert objAccount;
                
                //start the Test       
                Test.startTest();
                
                objAccount.Status_of_D_B_Cleansing__c = 'Please Review';
                update objAccount;
                
                //fetch the task 
                List<Task> lstTasks = [Select Id , Subject, Priority , ActivityDate , IsReminderSet, ReminderDateTime
                                        From Task 
                                        Where OwnerId =: objUser.Id and WhatId =: objAccount.Id Limit 1];
                //assert the results
                system.assert(lstTasks.size() > 0);
                
                Task objTask = lstTasks[0];
                system.assert(objTask.Priority == 'High');
                system.assert(objTask.IsReminderSet == false);
                system.assert(objTask.ActivityDate == Date.today().addDays(30));
                                
                //stop the test
                Test.stopTest();
            }           
        }
    }*/
}