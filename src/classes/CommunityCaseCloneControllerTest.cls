/***************************************************************************************************
@Created By :      Amrutha R
@Created Date:     25 Jul 2016
@Description:      Test class for CommunityCaseCloneController.
****************************************************************************************************/
/***************************************************************************************************
@Last Modified By  :   Shridevi badiger
@Last Modified Date:   24 Jul 2017
@Description       :   Modified by shridevi as part of SIR 750-Improve code coverage for community classes
****************************************************************************************************/
@isTest
public class CommunityCaseCloneControllerTest 
{
     //----Added by shridevi as part of SIR 750----------------------------------------------
    private static final String CASE_TSCOMMUNITY = 'TS_Community';
    private static final String CASE_TSWEBMASTER = 'TS_Webmaster';
    private static final String ACCOUNT_CHILDACCOUNT = 'Child_Account';
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    
    public static RecordType tsCommunity;
    public static RecordType webMaster;
    public static RecordType childAccount;
    public static RecordType parentAccount;
    public Static Account objAccount;    
    
    public static void fetchRecordTypes()
    {
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              ((SobjectType = 'Case' and (DeveloperName =: CASE_TSCOMMUNITY or DeveloperName =: CASE_TSWEBMASTER)) or
                               (SobjectType = 'Account' and (DeveloperName =: ACCOUNT_CHILDACCOUNT or DeveloperName =: ACCOUNT_ParentACCOUNT)) 
                              )
                              Limit 4])
        {
            if(rt.DeveloperName == CASE_TSCOMMUNITY)
            {
                tsCommunity = rt;
            }
            else if(rt.DeveloperName == CASE_TSWEBMASTER)
            {
                webMaster = rt;
            }
            else if(rt.DeveloperName == ACCOUNT_CHILDACCOUNT)
            {
                childAccount = rt;
            }
            else if(rt.DeveloperName == ACCOUNT_ParentACCOUNT)
            {
                parentAccount = rt; 
            }            
        }
    } 
     
    
    public static Account createParentAccount()
    {
        //Method to create a Parent Account
        Account objParentAccount;
        objParentAccount = new Account(RecordTypeID= parentAccount.ID,
                                                Name = 'Bosch', Customer_Category__c= 'Longtail');
        return  objParentAccount;
    }
    
     public static Account createChildAccount(ID parentAccountId)
    {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        system.assert(objProfile.Id != null);
        
        User objUser= new User(alias = 'nUser' , email= 'testing@test.com', emailencodingkey='UTF-8', lastname='test',languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id,UserRoleId = portalRole.Id, timezonesidkey='America/Los_Angeles', username= 'prakhartest' + datetime.now().millisecond() +'@test.com' );
            
        insert objUser;
        
        //Method to create a Child Account
        Account objChildAccount;
        objChildAccount = new Account(RecordTypeID= childAccount.ID,ParentId = parentAccountId, ownerId=objUser.id, 
                                            Name = 'Bosch Japan', Region__c = 'Japan',
                                             Sales_Area__c = 'Japan ID', Industry_Segment__c = 'Mobile',
                                             Country__c = 'Japan');
        return objChildAccount;    
    }
    //Method to create a  Contact
    public static Contact createContact()
    {
        Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@test.com');              
                
        return objContact;        
        
    }
    
  
    
    public static User CreateUser()
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='NXP Customer Community Login User' Limit 1];
        User objUser = new User(Alias = 'standt', Email='test1@test.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='test1@test.com'
                                );
        return objUser;
    }
    
     //Method to create a 'Other' Parent Account    
    public static Account createOtherAccountRecord()
    {
        objAccount = new Account(RecordTypeID= parentAccount.ID,
                                 Name = 'Other', Customer_Category__c= 'Longtail');
        return  objAccount;
    }
    
    //Method to create a TechService Child Account
    public static Account createTechServiceAccountRecord(ID parentAccountId)
    {
        objAccount = new Account(RecordTypeID= childAccount.ID,ParentId = parentAccountId,  
                                 Name = 'Technical Services', Region__c = 'Japan',
                                 Sales_Area__c = 'Japan ID', Industry_Segment__c = 'Mobile',
                                 Country__c = 'Austria');
        return objAccount;    
    }
    //--------------------------------------------------------------------------------------
    //positive case: Clone case is created
    static testmethod void CommunityCaseCloneControllerTest1()
    {
        fetchRecordTypes();
        
        //Test.startTest();
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact= createContact();
            objContact.AccountID = objChildAccount.Id;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='Marketing';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='test';
            insert objContact;
            system.assert(objContact.Id!=null);
        
            User objUser= createUser();
            objUser.contactId=objContact.Id;
            insert objUser;
            system.assert(objUser.Id!=null);
            //Test.stopTest();
            
            Case objCase ;
            system.runAs(objStandardUser)
            {
               
                objCase= new Case(RecordTypeID = tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', assigned_to__c=objStandardUser.id,
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',SuppliedEmail = 'test1@nxp.com',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Self Service Portal',ownerid=userinfo.getuserid()); 
 
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
        fetchRecordTypes();
        
        //Test.startTest();
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact= createContact();
            objContact.AccountID = objChildAccount.Id;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='Marketing';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='test';
            insert objContact;
            system.assert(objContact.Id!=null);
        
            User objUser= createUser();
            objUser.contactId=objContact.Id;
            insert objUser;
            system.assert(objUser.Id!=null);
            //Test.stopTest();
            
            Case objCase ;
            system.runAs(objStandardUser)
            {
                
                objCase= new Case(RecordTypeID = tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
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