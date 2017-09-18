/***************************************************************************************************
@Modified By :       Amrutha
@Modified Date:      06 Apr 2016
@Description:        Modified according to changes in siteLoginController
******************************************************************************************************/
/***************************************************************************************************
@Modified By :       Shridevi
@Modified Date:      04 Aug 2017
@Description:        Modified to remove the usage of the pages which are deleted as part of SIR 750
******************************************************************************************************/
@isTest
public class SiteLoginControllerTest 
{   
     private static final String CASE_TSCOMMUNITY = 'TS_Community';
    private static final String CASE_TSWEBMASTER = 'TS_Webmaster';
    private static final String ACCOUNT_CHILDACCOUNT = 'Child_Account';
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    
    public static RecordType tsCommunity;
    public static RecordType webMaster;
    public static RecordType childAccount;
    public static RecordType parentAccount;
    
    
    private static void fetchRecordTypes()
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
    
    private Static Account objAccount;
    private static Account createNxpCommunityAccountRecord()
    {
        objAccount = new Account(RecordTypeID= parentAccount.ID,
                                                Name = 'NXP Community', Customer_Category__c= 'Longtail');
        return  objAccount;
    }
    
    private static User CreateUser()
    {
        
        Profile objProfile= [SELECT Id FROM Profile WHERE name='NXP Customer Community Login User' Limit 1];
        User objUser = new User(Alias = 'standt', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                      LocaleSidKey='en_US', ProfileId = objProfile.Id,
                    TimeZoneSidKey='America/Los_Angeles');
        return objUser;
    }
    
    public static testmethod void SiteLoginControllerTest1 () 
    {
        fetchRecordTypes();
        Test.startTest();
        // Instantiate a new controller with all parameters in the page
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.CommunitySignUpUrl__c= '/community/CommunitiesEmailVerfication';
        setting.InternalUserSignInUrl__c= '/community/CommunitiesEmailVerfication';
        insert setting;
        system.assert(setting.Id!=null);
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                               Phone = '8123978919', email = 'test1@test.com', AccountID = objNxpCommunityAccount.id,
                                               Community_web_country__c='test',Company__c='test');
        insert objContact;
        system.assert(objContact.id!=null);
        
        User objUser= createUser();
        objUser.ContactId= objContact.id;
        objUser.Email= 'test@salesforce.com';
        objUser.Username= 'test@salesforce.com';
        insert objUser;
        system.assert(objUser.id!=null);
        
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456';
        //Below line is modified by shridevi for redirecting to login page instead of CustomCommunityLogin page since the page has been deleted.
        PageReference pageRef = new PageReference('/community'+Label.Community_Login_URL);
        System.debug(pageRef);
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('startUrl', '/CommunityMicrocontroller');      
        System.assertEquals(controller.login(),null); 
        
        User objUser1=[select id,email,Email_verification_status__c from user where Email_verification_status__c=null LIMIT 1];
        ApexPages.currentPage().getParameters().put('email', objUser1.Email);
        //controller.resendEmailVerification(); 
        
        //controller.SignUpPage();    
        test.stopTest();
    }  
    

     
    public static testmethod void SiteLoginControllerTest2 () 
    {
        fetchRecordTypes();
        Test.startTest();
        // Instantiate a new controller with all parameters in the page
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.InternalUserSignInUrl__c= '/community/CommunitiesEmailVerfication';
        insert setting;
        system.assert(setting.Id!=null);
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                               Phone = '8123978919', email = 'test1@test.com', AccountID = objNxpCommunityAccount.id,
                                               Community_web_country__c='test',Company__c='test');
        insert objContact;
        system.assert(objContact.id!=null);
        
        User objUser= createUser();
        objUser.ContactId= objContact.id;
        objUser.Email= 'test@salesforce.com';
        objUser.Username= 'test@salesforce.com';
        objUser.Email_verification_status__c='Activation pending';
        insert objUser;
        system.assert(objUser.id!=null);
        
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
       // PageReference pageRef = Page.CustomCommunityLogin;
       //Below line is modified by shridevi for redirecting to login page instead of CustomCommunityLogin page since the page has been deleted.
        PageReference pageRef = new PageReference('/community'+Label.Community_Login_URL);
         Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('startUrl', '/CommunityMicrocontroller');      
        System.assertEquals(controller.login(),null); 
        
        User objUser1=[select id,email,Email_verification_status__c from user where Email_verification_status__c='Activation pending' LIMIT 1];
        ApexPages.currentPage().getParameters().put('email', objUser1.Email);
       // controller.resendEmailVerification(); 
        test.stopTest();                       
    }  
     
    public static testmethod void SiteLoginControllerTest3 () 
    {
        fetchRecordTypes();
        Test.startTest();
        // Instantiate a new controller with all parameters in the page
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.InternalUserSignInUrl__c= '/community/CommunitiesEmailVerfication';
        insert setting;
        system.assert(setting.Id!=null);
        
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@nxp.com';
        controller.password = '123456'; 
        //PageReference pageRef = Page.CustomCommunityLogin;
        //Below line is modified by shridevi for redirecting to login page instead of CustomCommunityLogin page since the page has been deleted.
         PageReference pageRef = new PageReference('/community'+Label.Community_Login_URL);
         
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('startUrl', '/CommunityMicrocontroller');      
        controller.login();
        
        test.stopTest();                       
    }
     
    public static testmethod void SiteLoginControllerTest4 () 
    {
        Test.startTest();
        // Instantiate a new controller with all parameters in the page
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.InternalUserSignInUrl__c= '/community/CommunitiesEmailVerfication';
        insert setting;
        system.assert(setting.Id!=null);
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
       // PageReference pageRef = Page.CustomCommunityLogin;
       //Below line is modified by shridevi for redirecting to login page instead of CustomCommunityLogin page since the page has been deleted.
         PageReference pageRef = new PageReference('/community'+Label.Community_Login_URL);
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('startUrl', '/_ui/chatter/service/ChatterAnswersUi');      
        System.assertEquals(controller.login(),null); 
        test.stopTest();
                            
    }
    
}