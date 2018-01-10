/*********************************************************************************************
@Created By :      Amrutha R
@Created Date :    29 Oct 2015
Description :      Test class for Communitycasesurveycontroller class.
****************************************************************************************************/
/***************************************************************************************************
@Modified By :       Amrutha
@Modified Date:      22 Apr 2016
@Description:        Added test method- email to case owner based on survey feedback
*******************************************************************************************************/
// 3rdJan2017 Balaji - Repositioned StartTest() and StopTest() methods in CommunityCaseSurveyControllerTest1 and CommunityCaseSurveyControllerTest4 methods to fix the test failure
/***************************************************************************************************
@Last Modified By  :   Shridevi badiger
@Last Modified Date:   24 Jul 2017
@Description       :   Modified by shridevi as part of SIR 750-Improve code coverage for community classes
****************************************************************************************************/
@isTest
public class CommunityCaseSurveyControllerTest 
{
    //Positive case to submit survey
    static testmethod void CommunityCaseSurveyControllerTest1()
    {
//        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingnew7@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingnew7@test.com');
        insert objUser;
        
        CommunityCaseCloneControllerTest.fetchRecordTypes();
        Account objOtherAccount = CommunityCaseCloneControllerTest.createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = CommunityCaseCloneControllerTest.createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
            
        Contact objContact= CommunityCaseCloneControllerTest.createContact();
        objContact.Email='test1@test.com';
        objContact.AccountID = objTechServiceAccount.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        
        Survey_question__c objSurveyQues1= new Survey_question__c();
        objSurveyQues1.Name='Resolved ?';
        objSurveyQues1.Question__c='How satisfied are you with the answer you received?';
        objSurveyQues1.Type__c='Picklist';
        objSurveyQues1.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues1;
        
        Survey_question__c objSurveyQues2= new Survey_question__c();
        objSurveyQues2.Name='Resolution Time ?';
        objSurveyQues2.Question__c='How satisfied are you with the request resolution time?';
        objSurveyQues2.Type__c='Picklist';
        objSurveyQues2.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues2;
        
        Survey_question__c objSurveyQues3= new Survey_question__c();
        objSurveyQues3.Name='Support Person ?';
        objSurveyQues3.Question__c='How satisfied are you with the support person’s ability to answer your question?';
        objSurveyQues3.Type__c='Picklist';
        objSurveyQues3.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues3;
        
        Survey_question__c objSurveyQues4= new Survey_question__c();
        objSurveyQues4.Name='Like Our Support ?';
        objSurveyQues4.Question__c='If someone asks you about our support, would you say “Yes, you should use it” ?';
        objSurveyQues4.Type__c='Picklist';
        objSurveyQues4.Value__c='Yes, Probably Yes, Probably No, No';
        insert objSurveyQues4;
        
        Survey_question__c objSurveyQues5= new Survey_question__c();
        objSurveyQues5.Name='Comments';
        objSurveyQues5.Question__c='Any additional comments you would like to share with us?';
        objSurveyQues5.Type__c='Textarea';
        insert objSurveyQues5;
                
        system.runAs(objUser)
        {
            Case objCase = new Case();
            objCase= new Case(RecordTypeID = CommunityCaseCloneControllerTest.tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',Survey_Flag__c='True', origin = 'Self Service Portal',Case_Owner_Name__c='test'); 
            Test.startTest();
            Insert objCase;
            Test.stopTest();
            system.assert(objCase.Id!=null);
            PageReference pageRef = Page.CommunityCaseSurvey;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('caseId', objCase.id);
            CommunityCaseSurveyController comSurvey= new CommunityCaseSurveyController();
            comSurvey.getQuesValues();
            comSurvey.getQuesValues1();
            comSurvey.strResolved='Satisfied';
            comSurvey.strResolutionTime='Satisfied';
            comSurvey.strSupportPerson='Satisfied';
            comSurvey.strLikeOurSupport='Yes';
            comSurvey.strComment='test';
            comSurvey.submitSurvey();
        }
//        test.stopTest();
    }
    
    //Negative case to submit survey- caseid is null
    static testmethod void CommunityCaseSurveyControllerTest2()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingnew7@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingnew7@test.com');
        insert objUser;
        
        Survey_question__c objSurveyQues1= new Survey_question__c();
        objSurveyQues1.Name='Resolved ?';
        objSurveyQues1.Question__c='How satisfied are you with the answer you received?';
        objSurveyQues1.Type__c='Picklist';
        objSurveyQues1.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues1;
        
        Survey_question__c objSurveyQues2= new Survey_question__c();
        objSurveyQues2.Name='Resolution Time ?';
        objSurveyQues2.Question__c='How satisfied are you with the request resolution time?';
        objSurveyQues2.Type__c='Picklist';
        objSurveyQues2.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues2;
        
        Survey_question__c objSurveyQues3= new Survey_question__c();
        objSurveyQues3.Name='Support Person ?';
        objSurveyQues3.Question__c='How satisfied are you with the support person’s ability to answer your question?';
        objSurveyQues3.Type__c='Picklist';
        objSurveyQues3.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues3;
        
        Survey_question__c objSurveyQues4= new Survey_question__c();
        objSurveyQues4.Name='Like Our Support ?';
        objSurveyQues4.Question__c='If someone asks you about our support, would you say “Yes, you should use it” ?';
        objSurveyQues4.Type__c='Picklist';
        objSurveyQues4.Value__c='Yes, Probably Yes, Probably No, No';
        insert objSurveyQues4;
        
        Survey_question__c objSurveyQues5= new Survey_question__c();
        objSurveyQues5.Name='Comments';
        objSurveyQues5.Question__c='Any additional comments you would like to share with us?';
        objSurveyQues5.Type__c='Picklist';
        objSurveyQues5.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues5;
                
        system.runAs(objUser)
        {
            CommunityCaseSurveyController comSurvey= new CommunityCaseSurveyController();
            comSurvey.getQuesValues();
            comSurvey.getQuesValues1();
            comSurvey.strResolved='Satisfied';
            comSurvey.strResolutionTime='Satisfied';
            comSurvey.strSupportPerson='Satisfied';
            comSurvey.strLikeOurSupport='Yes';
            comSurvey.strComment='test';
            comSurvey.submitSurvey();
        }
        test.stopTest();
    }
    
    //Negative case to submit survey- survey already submitted for a case
    static testmethod void CommunityCaseSurveyControllerTest3()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingnew7@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingnew7@test.com');
        insert objUser;
        
        CommunityCaseCloneControllerTest.fetchRecordTypes();
        Account objOtherAccount = CommunityCaseCloneControllerTest.createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = CommunityCaseCloneControllerTest.createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
            
        Contact objContact= CommunityCaseCloneControllerTest.createContact();
        objContact.Email='test1@test.com';
        objContact.AccountID = objTechServiceAccount.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        
        Survey_question__c objSurveyQues1= new Survey_question__c();
        objSurveyQues1.Name='Resolved ?';
        objSurveyQues1.Question__c='How satisfied are you with the answer you received?';
        objSurveyQues1.Type__c='Picklist';
        objSurveyQues1.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues1;
        
        Survey_question__c objSurveyQues2= new Survey_question__c();
        objSurveyQues2.Name='Resolution Time ?';
        objSurveyQues2.Question__c='How satisfied are you with the request resolution time?';
        objSurveyQues2.Type__c='Picklist';
        objSurveyQues2.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues2;
        
        Survey_question__c objSurveyQues3= new Survey_question__c();
        objSurveyQues3.Name='Support Person ?';
        objSurveyQues3.Question__c='How satisfied are you with the support person’s ability to answer your question?';
        objSurveyQues3.Type__c='Picklist';
        objSurveyQues3.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues3;
        
        Survey_question__c objSurveyQues4= new Survey_question__c();
        objSurveyQues4.Name='Like Our Support ?';
        objSurveyQues4.Question__c='If someone asks you about our support, would you say “Yes, you should use it” ?';
        objSurveyQues4.Type__c='Picklist';
        objSurveyQues4.Value__c='Yes, Probably Yes, Probably No, No';
        insert objSurveyQues4;
        
        Survey_question__c objSurveyQues5= new Survey_question__c();
        objSurveyQues5.Name='Comments';
        objSurveyQues5.Question__c='Any additional comments you would like to share with us?';
        objSurveyQues5.Type__c='Picklist';
        objSurveyQues5.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues5;
                
        system.runAs(objUser)
        {
            Case objCase = new Case();
            objCase= new Case(RecordTypeID = CommunityCaseCloneControllerTest.tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',Survey_Flag__c='False', origin = 'Self Service Portal',Case_Owner_Name__c='test'); 
 
            Insert objCase;
            system.assert(objCase.Id!=null);
            PageReference pageRef = Page.CommunityCaseSurvey;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('caseId', objCase.id);
            CommunityCaseSurveyController comSurvey= new CommunityCaseSurveyController();
            comSurvey.getQuesValues();
            comSurvey.getQuesValues1();
            comSurvey.strResolved='Satisfied';
            comSurvey.strResolutionTime='Satisfied';
            comSurvey.strSupportPerson='Satisfied';
            comSurvey.strLikeOurSupport='Yes';
            comSurvey.strComment='test';
            comSurvey.submitSurvey();
        }
        test.stopTest();
    }
    
    //Negative case to submit survey- Dissatisfied
    static testmethod void CommunityCaseSurveyControllerTest4()
    {
//        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingnew7@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingnew7@test.com');
        insert objUser;
        
        CommunityCaseCloneControllerTest.fetchRecordTypes();
        Account objOtherAccount = CommunityCaseCloneControllerTest.createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = CommunityCaseCloneControllerTest.createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
            
        Contact objContact= CommunityCaseCloneControllerTest.createContact();
        objContact.Email='test1@test.com';
        objContact.AccountID = objTechServiceAccount.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        
        Survey_question__c objSurveyQues1= new Survey_question__c();
        objSurveyQues1.Name='Resolved ?';
        objSurveyQues1.Question__c='How satisfied are you with the answer you received?';
        objSurveyQues1.Type__c='Picklist';
        objSurveyQues1.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues1;
        
        Survey_question__c objSurveyQues2= new Survey_question__c();
        objSurveyQues2.Name='Resolution Time ?';
        objSurveyQues2.Question__c='How satisfied are you with the request resolution time?';
        objSurveyQues2.Type__c='Picklist';
        objSurveyQues2.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues2;
        
        Survey_question__c objSurveyQues3= new Survey_question__c();
        objSurveyQues3.Name='Support Person ?';
        objSurveyQues3.Question__c='How satisfied are you with the support person’s ability to answer your question?';
        objSurveyQues3.Type__c='Picklist';
        objSurveyQues3.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues3;
        
        Survey_question__c objSurveyQues4= new Survey_question__c();
        objSurveyQues4.Name='Like Our Support ?';
        objSurveyQues4.Question__c='If someone asks you about our support, would you say “Yes, you should use it” ?';
        objSurveyQues4.Type__c='Picklist';
        objSurveyQues4.Value__c='Yes, Probably Yes, Probably No, No';
        insert objSurveyQues4;
        
        Survey_question__c objSurveyQues5= new Survey_question__c();
        objSurveyQues5.Name='Comments';
        objSurveyQues5.Question__c='Any additional comments you would like to share with us?';
        objSurveyQues5.Type__c='Picklist';
        objSurveyQues5.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        insert objSurveyQues5;
                
        system.runAs(objUser)
        {
            Case objCase = new Case();
            objCase= new Case(RecordTypeID = CommunityCaseCloneControllerTest.tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', assigned_to__c=objUser.id,
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region', origin = 'Self Service Portal',Case_Owner_Name__c='test'); 
            Test.startTest();
            Insert objCase;
            Test.stopTest();
            system.assert(objCase.Id!=null);
            PageReference pageRef = Page.CommunityCaseSurvey;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('caseId', objCase.id);
            CommunityCaseSurveyController comSurvey= new CommunityCaseSurveyController();
            comSurvey.getQuesValues();
            comSurvey.getQuesValues1();
            comSurvey.strResolved='Dissatisfied';
            comSurvey.strResolutionTime='Satisfied';
            comSurvey.strSupportPerson='Satisfied';
            comSurvey.strLikeOurSupport='Yes';
            comSurvey.strComment='test';
            comSurvey.submitSurvey();
        }
//        test.stopTest();
    }
}