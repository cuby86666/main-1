/*********************************************************************************************
@Modified By :       Amrutha R
@Modified Date :     26 Mar 2015
Description :       Test Class for community case controller
********************************************************************************************/

/*********************************************************************************************
@Modified By :       Venkateshwar G
@Modified Date :     24 June 2015
Description :       Test Class for communityEmailNotificationcontroller SIR 797
********************************************************************************************/
// 3rdJan2017 Balaji - Repositioned StartTest() and StopTest() methods in CommunityCaseControllerTest1,
// CommunityCaseControllerTest3, CommunityCaseControllerTest51 and CommunityCaseControllerTest6 methods to fix the test failure

@isTest
public class CommunityCaseControllerTest 
{
    private static final String CASE_TSCOMMUNITY = 'TS_Community';
    private static final String CASE_TSWEBMASTER = 'TS_Webmaster';
    private static final String ACCOUNT_CHILDACCOUNT = 'Child_Account';
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    
    public static RecordType tsCommunity;
    public static RecordType webMaster;
    public static RecordType childAccount;
    public static RecordType parentAccount;
    
    
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
    
    //Method to create a 'NXP Community' Parent Account
    public Static Account objAccount;    
    public static Account createNxpCommunityAccountRecord()
    {
        objAccount = new Account(RecordTypeID= parentAccount.ID,
                                 Name = 'NXP Community', Customer_Category__c= 'Longtail');
        return  objAccount;
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
    
    /***************************************************************************
      Case-
    ****************************************************************************/

    static testmethod void CommunityCaseControllerTest1()
    {
        fetchRecordTypes();
        
        
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
        
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
        
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
        
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
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
        
//            Test.startTest();
            Case objCase ;
            system.runAs(objStandardUser)
            {
                
                objCase= new Case(RecordTypeID = tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', assigned_to__c=objStandardUser.id,
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test'); 
                Test.startTest();
                Insert objCase;
                Test.stopTest();
                system.assert(objCase.Id!=null);
                Attachment objAttach=new Attachment();
                objAttach.Body=Blob.valueOf('Unit Test Attachment Body');
                objAttach.parentid= objCase.id;
                objAttach.name='test';
                insert objAttach;
                
                ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCase);
                CommunityCaseController communityCaseCtrl = new CommunityCaseController(stdCtrl);
                
                PageReference redirectToCaseSubmitPage =communityCaseCtrl.redirectToCaseSubmitPage();
                PageReference redirecttostandardPage =communityCaseCtrl.redirecttostandardpage();

                PageReference redirectToAddAttachmentPage = communityCaseCtrl.redirectToAddAttachment();
                
                ApexPages.currentPage().getParameters().put('msg', 'test');
                ApexPages.currentPage().getParameters().put('msg2', 'test');
                ApexPages.currentPage().getHeaders().put('Referer','CommunitiesCaseComment');
                
                communityCaseCtrl.Init();
                
                Attachment objAttachment=  new attachment();
                objAttachment.Body=Blob.valueOf('Unit Test Attachment Body');
                communityCaseCtrl.myAttachment= objAttachment;
                communityCaseCtrl.uploadAttachment();
                communityCaseCtrl.getLstAttachment();
                communityCaseCtrl.saveCase();
                communityCaseCtrl.saveComment();
                communityCaseCtrl.addAttachment();
                communityCaseCtrl.addComment();
                communityCaseCtrl.getPageReference1();
                communityCaseCtrl.getPageReference();
                
            }
            EmailMessage objEmail=new EmailMessage();
            objEmail.FromAddress = 'test@example.com';
            objEmail.ToAddress = 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
            objEmail.Subject = 'Test email';
            objEmail.TextBody = 'Hello';
            objEmail.ParentId = objCase.Id; // The inserted test Case Id that you created above
            objEmail.Incoming = true;

            insert objEmail;
            system.assert(objEmail.Id!=null);
            
            
            
            CommunityCaseController communityCaseCtrl1 = new CommunityCaseController();
            ApexPages.currentPage().getParameters().put('id', objEmail.id);
            communityCaseCtrl1.getEmailDetails();
         
        }
//        Test.stopTest();
    }
    
    static testmethod void CommunityCaseControllerTest2()
    {
        fetchRecordTypes();
        
        
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
        
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
        
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
        
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Contact objContact= createContact();
            objContact.Email='test1@test.com';
            objContact.AccountID = objNxpCommunityAccount.Id;
            insert objContact;
            system.assert(objContact.Id!=null);
        
            User objUser= createUser();
            objUser.contactId=objContact.Id;
            insert objUser;
            system.assert(objUser.Id!=null);
            
            Test.startTest();
            Case objCase = new Case();
            system.runAs(objUser)
            {
                
                objCase= new Case(RecordTypeID = tsCommunity.Id,contactId=objContact.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', ownerid=objUser.id,
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test'); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
                
                
                
                ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCase);
                CommunityCaseController communityCaseCtrl = new CommunityCaseController(stdCtrl);

                
                PageReference redirectToCaseSubmitPage =communityCaseCtrl.redirectToCaseSubmitPage();
                PageReference redirecttostandardPage =communityCaseCtrl.redirecttostandardpage();

                PageReference redirectToAddAttachmentPage = communityCaseCtrl.redirectToAddAttachment();
     
                ApexPages.currentPage().getParameters().put('msg', 'test');
                ApexPages.currentPage().getParameters().put('msg2', 'test');
                ApexPages.currentPage().getHeaders().put('Referer','CommunitiesCaseSubmit');

                communityCaseCtrl.Init();
                communityCaseCtrl.saveCase();
                communityCaseCtrl.saveComment();
                communityCaseCtrl.addAttachment();
                communityCaseCtrl.addComment();
                
            }
                
                EmailMessage objEmail=new EmailMessage();
                objEmail.FromAddress = 'test@example.com';
                objEmail.ToAddress = 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
                objEmail.Subject = 'Test email';
                objEmail.TextBody = 'Hello';
                objEmail.ParentId = objCase.Id; // The inserted test Case Id that you created above
                objEmail.Incoming = true;

                insert objEmail;
                system.assert(objEmail.Id!=null);
                CommunityCaseController communityCaseCtrl1 = new CommunityCaseController();
                ApexPages.currentPage().getParameters().put('id', objEmail.id);
                communityCaseCtrl1.getEmailDetails();
                
        }
        Test.stopTest();
    }
    
    static testmethod void CommunityCaseControllerTest3()
    {
        fetchRecordTypes();
        
//        Test.startTest();
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
        
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
        
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
        
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
        
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            
                Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test'); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
            
                Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
                CommunitySettings__c setting = new CommunitySettings__c();
                setting.Name = 'CommunityUrl';
                setting.Question_Post__c= 10;
                insert setting;
                system.assert(setting.Id!=null);
            
                Question objQue1=new Question();
                objQue1.CommunityId= objCom.id;
                objQue1.title='t';
                objQue1.body='test';
                objQue1.Product_Category__c='Interface Products';
                objQue1.Product_Sub_Category__c='General';
                Test.startTest();
                insert objQue1;
                system.assert(objQue1.Id!=null);
                PageReference pageRef = Page.CommunitySubmitQuestion;
                Test.setCurrentPageReference(pageRef);
                System.currentPageReference().getParameters().put('strQuesId', objque1.id);
                ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCase);
                CommunityCaseController communityCaseCtrl = new CommunityCaseController(stdCtrl);
                communityCaseCtrl.escalateToCase();
                communityCaseCtrl.saveCase();
                communityCaseCtrl.getPageReference();
                communityCaseCtrl.getPageReference1();
                Test.stopTest();            
        }
//        Test.stopTest();
    }
    
    static testmethod void CommunityCaseControllerTest4()
    {
        Profile testProfile = [SELECT Id 
                           FROM profile
                           WHERE Name = 'NXP Community Profile' 
                           LIMIT 1];

        User testUser = new User(LastName = 'test user 1', 
                             Username = 'test.user.1@example.com', 
                             Email = 'test.1@example.com', 
                             Alias = 'testu1', 
                             TimeZoneSidKey = 'GMT', 
                             LocaleSidKey = 'en_GB', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             ProfileId = testProfile.Id, 
                             LanguageLocaleKey = 'en_US');
        system.runas(testUser)
        {
            ApexPages.StandardController stdCtrl;
            CommunityCaseController communityCaseCtrl = new CommunityCaseController(stdCtrl);
            communityCaseCtrl.getPageReference();
            communityCaseCtrl.getPageReference1();
        }
        
    }
 /****************Added the test method for the functionality check of Email notificaton to Case Customeer when Customer Replies for the case closed more than 30 days**************************/   
   static testmethod void CommunityCaseControllerTest5()
    {
        fetchRecordTypes();
        
        Test.startTest();
        {
                Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test'); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
                EmailMessage objEmail=new EmailMessage();
                objEmail.FromAddress = 'test@example.com';
                objEmail.ToAddress = 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
                objEmail.Subject = 'Test email';
                objEmail.TextBody = 'Hello';
                objEmail.ParentId = objCase.Id; // The inserted test Case Id that you created above
                objEmail.Incoming = true;

                insert objEmail;   
                system.assert(objEmail.Id!=null);
                
                
        }
        Test.stopTest();
    }
    static testmethod void CommunityCaseControllerTest51()
    {
        fetchRecordTypes();
        
//        Test.startTest();
        {
                Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test');
                Test.startTest();               
 
                Insert objCase;
                Test.stopTest();
                system.assert(objCase.Id!=null);
              
                
                objCase.Status='Close';
                Update objCase;
                System.assertEquals(objCase.Status,'Close');
                
                EmailMessage objEmailSend=new EmailMessage();
                objEmailSend.FromAddress = 'test@example.com';
                objEmailSend.ToAddress = 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
                objEmailSend.Subject = 'Test email';
                objEmailSend.TextBody = 'Hello';
                objEmailSend.ParentId = objCase.Id; // The inserted test Case Id that you created above
                objEmailSend.Incoming = true;
                insert objEmailSend;
                system.assert(objEmailSend.Id!=null);
        }
//        Test.stopTest();
    }
static testmethod void CommunityCaseControllerTest6()
    {
        fetchRecordTypes();
        
//        Test.startTest();
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
                Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test'); 
                Test.startTest();
                Insert objCase;
                Test.stopTest();
                system.assert(objCase.Id!=null);

                
                objCase.Status='Close';
                Update objCase;
                EmailMessage objEmailSend=new EmailMessage();
                objEmailSend.ToAddress = 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
                objEmailSend.Subject = 'Test email';
                objEmailSend.TextBody = 'Hello';
                objEmailSend.ParentId = objCase.Id; // The inserted test Case Id that you created above
                objEmailSend.Incoming = true;
                insert objEmailSend;
                
                system.assert(objEmailSend.Id!=null);
        }
//        Test.stopTest();
    }
}