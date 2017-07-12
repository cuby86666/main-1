/***************************************************************************************************
@Created By :      Amrutha R
@Created Date:     25 Jul 2016
@Description:      Test class for CommunityCaseCloneController.
****************************************************************************************************/

@isTest
public class CommunityCaseCloneControllerTest 
{
	//positive case: Clone case is created
  	static testmethod void CommunityCaseCloneControllerTest1()
    {
        CommunityCaseControllerTest.fetchRecordTypes();
        
        //Test.startTest();
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = CommunityCaseControllerTest.createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = CommunityCaseControllerTest.createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact= CommunityCaseControllerTest.createContact();
            objContact.AccountID = objChildAccount.Id;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='Marketing';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='test';
            insert objContact;
            system.assert(objContact.Id!=null);
        
            User objUser= CommunityCaseControllerTest.createUser();
            objUser.contactId=objContact.Id;
            insert objUser;
            system.assert(objUser.Id!=null);
        	//Test.stopTest();
            
            Case objCase ;
            system.runAs(objStandardUser)
            {
               
                objCase= new Case(RecordTypeID = CommunityCaseControllerTest.tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', assigned_to__c=objStandardUser.id,
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',SuppliedEmail = 'test1@nxp.com',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',ownerid=userinfo.getuserid()); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
            }
            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(objCase);
            CommunityCaseCloneController caseCloneController= new CommunityCaseCloneController(stdController);
            PageReference pageRef= caseCloneController.saveClonedCase();
            System.assert(pageRef!=null);
            system.assertEquals(objCase.Assigned_to__c, caseCloneController.objCloneCase.Assigned_to__c);
            system.assertEquals('Clone', caseCloneController.objCloneCase.origin);
            system.assertEquals(objCase.ownerId, caseCloneController.objCloneCase.ownerId);
            system.assertEquals(objCase.SuppliedEmail, caseCloneController.objCloneCase.SuppliedEmail);
			pageRef= caseCloneController.cancelClone();
            System.assert(pageRef!=null);
        }
        Test.stopTest();
    }
    
    //negative case: where clone funtionality fails 
    static testmethod void CommunityCaseCloneControllerTest2()
    {
        CommunityCaseControllerTest.fetchRecordTypes();
        
        //Test.startTest();
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = CommunityCaseControllerTest.createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = CommunityCaseControllerTest.createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact= CommunityCaseControllerTest.createContact();
            objContact.AccountID = objChildAccount.Id;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='Marketing';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='test';
            insert objContact;
            system.assert(objContact.Id!=null);
        
            User objUser= CommunityCaseControllerTest.createUser();
            objUser.contactId=objContact.Id;
            insert objUser;
            system.assert(objUser.Id!=null);
        	//Test.stopTest();
            
            Case objCase ;
            system.runAs(objStandardUser)
            {
                
                objCase= new Case(RecordTypeID = CommunityCaseControllerTest.tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test'); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
            }
            Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(objCase);
            CommunityCaseCloneController caseCloneController= new CommunityCaseCloneController(stdController);
            PageReference pageRef= caseCloneController.saveClonedCase();
            System.assert(pageRef==null);
   			pageRef= caseCloneController.cancelClone();
            System.assert(pageRef!=null);
        }
        Test.stopTest();
    }
    
}