/***************************************************************************************************
@Created By :      Amrutha R
@Created Date:     23 Jun 2016
@Description:      Test class for CommunityCaseNotificationAfter48hrs.
****************************************************************************************************/
// 3rdJan2017 Balaji - Repositioned StartTest() and StopTest() methods in CommunityCaseNotificationAfter48hrsTest3 method to fix the test failure
/***************************************************************************************************
@Last Modified By  :   Shridevi badiger
@Last Modified Date:   24 Jul 2017
@Description       :   Modified by shridevi as part of SIR 750-Improve code coverage for community classes
****************************************************************************************************/
@isTest
public class CommunityCaseNotificationAfter48hrsTest 
{
    //positive case: where email notification is sent to assigned to
    static testmethod void CommunityCaseNotificationAfter48hrsTest1()
    {
        CommunityCaseCloneControllerTest.fetchRecordTypes();
        
        Test.startTest();
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = CommunityCaseCloneControllerTest.createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = CommunityCaseCloneControllerTest.createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact= CommunityCaseCloneControllerTest.createContact();
            objContact.AccountID = objChildAccount.Id;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='Marketing';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='test';
            insert objContact;
            system.assert(objContact.Id!=null);
        
            User objUser= CommunityCaseCloneControllerTest.createUser();
            objUser.contactId=objContact.Id;
            insert objUser;
            system.assert(objUser.Id!=null);
        
            Case objCase ;
            system.runAs(objStandardUser)
            {
                
                objCase= new Case(RecordTypeID = CommunityCaseCloneControllerTest.tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', assigned_to__c=objStandardUser.id,
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Self Service Portal',Case_Owner_Name__c='test'); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
            }
            List<Case> lstcases= new List<Case>();
            CommunityCaseNotificationAfter48hrs batchController = new CommunityCaseNotificationAfter48hrs();
            Database.BatchableContext bc;
            lstcases.add(objCase);
            batchController.start(bc);
            batchController.execute(bc, lstcases);
            batchController.finish(bc);
            system.assertEquals(1, CommunityCaseNotificationAfter48hrs.mails.size());
        }
        Test.stopTest();
    }
    
    //negative case: where email notification is not sent to assigned to
    static testmethod void CommunityCaseNotificationAfter48hrsTest2()
    {
        CommunityCaseCloneControllerTest.fetchRecordTypes();
        
        Test.startTest();
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = CommunityCaseCloneControllerTest.createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = CommunityCaseCloneControllerTest.createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact= CommunityCaseCloneControllerTest.createContact();
            objContact.AccountID = objChildAccount.Id;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='Marketing';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='test';
            insert objContact;
            system.assert(objContact.Id!=null);
        
            User objUser= CommunityCaseCloneControllerTest.createUser();
            objUser.contactId=objContact.Id;
            insert objUser;
            system.assert(objUser.Id!=null);
        
            Case objCase ;
            system.runAs(objStandardUser)
            {
                
                objCase= new Case(RecordTypeID = CommunityCaseCloneControllerTest.tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Self Service Portal',Case_Owner_Name__c='test'); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
            }
            List<Case> lstcases= new List<Case>();
            CommunityCaseNotificationAfter48hrs batchController = new CommunityCaseNotificationAfter48hrs();
            Database.BatchableContext bc;
            lstcases.add(objCase);
            batchController.start(bc);
            batchController.execute(bc, lstcases);
            batchController.finish(bc);
            system.assertEquals(1, CommunityCaseNotificationAfter48hrs.mails.size());
        }
        Test.stopTest();
    }
    
    //bulk case: where email notification is sent to assigned to for one case and not sent to another case
    static testmethod void CommunityCaseNotificationAfter48hrsTest3()
    {
        CommunityCaseCloneControllerTest.fetchRecordTypes();
        
        
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = CommunityCaseCloneControllerTest.createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = CommunityCaseCloneControllerTest.createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
//            Test.startTest();
            Contact objContact= CommunityCaseCloneControllerTest.createContact();
            objContact.AccountID = objChildAccount.Id;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='Marketing';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='test';
            insert objContact;
            system.assert(objContact.Id!=null);
        
            User objUser= CommunityCaseCloneControllerTest.createUser();
            objUser.contactId=objContact.Id;
            insert objUser;
            system.assert(objUser.Id!=null);
        
            Case objCase1,objcase2 ;
            Test.startTest();            
            objCase1= new Case(RecordTypeID = CommunityCaseCloneControllerTest.tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                           Product_Category__c = 'RF', Product_Sub__c = 'Mixers', assigned_to__c=objStandardUser.id,
                           email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                           Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                           Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                           Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                           Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                           Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Self Service Portal',Case_Owner_Name__c='test'); 
            Insert objCase1;
            Test.stopTest();            
            system.assert(objCase1.Id!=null);
            objCase2= new Case(RecordTypeID = CommunityCaseCloneControllerTest.tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                           Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                           email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Self Service Portal',Case_Owner_Name__c='test'); 
 
            Insert objCase2;
            system.assert(objCase2.Id!=null);
            List<Case> lstcases= new List<Case>();
            CommunityCaseNotificationAfter48hrs batchController = new CommunityCaseNotificationAfter48hrs();
            Database.BatchableContext bc;
            lstcases.add(objCase1);
            lstcases.add(objCase2);
            batchController.start(bc);
            batchController.execute(bc, lstcases);
            batchController.finish(bc);
            system.assertEquals(2, CommunityCaseNotificationAfter48hrs.mails.size());
//            Test.stopTest();
        }
       
    }
}