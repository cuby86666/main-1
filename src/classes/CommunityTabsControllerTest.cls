/***************************************************************************************************
@Created By :      Amrutha R
@Created Date:     01 June 2015
@Description:      Test class for CommunityTabsController
*******************************************************************************************************/

@isTest
public class CommunityTabsControllerTest 
{
    //case: positive case to update contact information
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    public static RecordType parentAccount;
    
    
    private static void fetchRecordType()
    {
        parentAccount=[Select Id, DeveloperName
                            From RecordType Where IsActive=true and
                            (SobjectType = 'Account' and 
                            DeveloperName =: ACCOUNT_ParentACCOUNT 
                            )
                            limit 1];
    } 
    
    private static Account createNxpCommunityParentAccount()
    {
        //Method to create a 'NXP Community' Parent Account
        Account objNxpCommunityParentAccount;
        objNxpCommunityParentAccount = new Account(RecordTypeID= parentAccount.ID,
                                                Name = 'NXP Community', Customer_Category__c= 'Longtail');
        return  objNxpCommunityParentAccount;
    } 
    
    //Method to create a  Contact
    private static Contact createContact()
    {
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@test.com', AccountID = objNxpCommunityParentAcc.Id);              
                
        return objContact;        
        
    }
    
    private static User CreateUser()
    {
        Contact objContact= createContact();
        insert objContact;
        system.assert(objContact.Id!=null);
        
        Profile objProfile= [SELECT Id FROM Profile WHERE name='NXP Customer Community Login User' Limit 1];
        User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',
                                contactId=objContact.Id);
        return objUser;
    }
    
    //Method to create Public Domain object records
    private static List<Public_Domain__c> createPublicDomainRecords()
    {
        List<Public_Domain__c> lstPublicDomains = new List<Public_Domain__c>();
        
        lstPublicDomains.add(new Public_Domain__c(Domain_Name__c='gmail.com',Enable_Contact_Support_Filter__c='Yes'));
        lstPublicDomains.add(new Public_Domain__c(Domain_Name__c='yahoo.com',Enable_Contact_Support_Filter__c='No'));
        lstPublicDomains.add(new Public_Domain__c(Domain_Name__c='hotmail.com',Enable_Contact_Support_Filter__c='No'));
        
        return lstPublicDomains;
    }
    
    //test method where user email is not in public domain list
    static testmethod void CommunityTabsControllerTest1()
    {
        Test.startTest();
        fetchRecordType();
        
        User objUser= createUser();
        objUser.Email='test@yahoo.com';
        objUser.Username='test@yahoo.com';
        insert objUser;
        system.assert(objUser.Id!=null);
        
        List<Public_Domain__c> lstPublicDomains = createPublicDomainRecords();        
        if(lstPublicDomains.size() > 0)
        {
            Insert lstPublicDomains;
        }
        
        //assert record ids        
        for(Public_Domain__c objPublicDomain:lstPublicDomains)
        {
            system.assert(objPublicDomain.Id != null);
        }
        
        system.runAs(objUser)
        {
            CommunitiesSuccessStoriesController controller1;
            CommunityTabsController CommTabCntrl1= new CommunityTabsController(controller1);
            CommunityQuestionViewController controller2;
            CommunityTabsController CommTabCntrl2= new CommunityTabsController(controller2);
            CommunityForumQuestionListController controller3;
            CommunityTabsController CommTabCntrl3= new CommunityTabsController(controller3);
            CommunityForumController controller4;
            CommunityTabsController CommTabCntrl4= new CommunityTabsController(controller4);
            CommunityEditReplyController controller5;
            CommunityTabsController CommTabCntrl5= new CommunityTabsController(controller5);
            SubmitCaseController controller6;
            CommunityTabsController CommTabCntrl6= new CommunityTabsController(controller6);
            CommunityTabsController CommTabCntrl= new CommunityTabsController();
            CommTabCntrl.userid=objuser.id;
            CommTabCntrl.getpublicDomain();
            system.assertEquals(false, CommTabCntrl.getpublicDomain());
        }
        test.stopTest();
    }
    
    //test method where user email is in public domain list
    static testmethod void CommunityTabsControllerTest2()
    {
        Test.startTest();
        fetchRecordType();
        
        User objUser= createUser();
        objUser.Email='test@gmail.com';
        objUser.Username='test@gmail.com';
        insert objUser;
        system.assert(objUser.Id!=null);
        
        List<Public_Domain__c> lstPublicDomains = createPublicDomainRecords();        
        if(lstPublicDomains.size() > 0)
        {
            Insert lstPublicDomains;
        }
        
        //assert record ids        
        for(Public_Domain__c objPublicDomain:lstPublicDomains)
        {
            system.assert(objPublicDomain.Id != null);
        }
        
        system.runAs(objUser)
        {
            CommunityFAQviewController controller1;
            CommunityTabsController CommTabCntrl1= new CommunityTabsController(controller1);
            CommunityFAQController controller2;
            CommunityTabsController CommTabCntrl2= new CommunityTabsController(controller2);
            ApexPages.StandardController controller3;
            CommunityTabsController CommTabCntrl3= new CommunityTabsController(controller3);
            CommunityAllleaderDisplayController  controller4;
            CommunityTabsController CommTabCntrl4= new CommunityTabsController(controller4);
            CommunityOverviewController controller5;
            CommunityTabsController CommTabCntrl5= new CommunityTabsController(controller5);
            CommunityTabsController CommTabCntrl= new CommunityTabsController();
            CommTabCntrl.getpublicDomain();
            system.assertEquals(true, CommTabCntrl.getpublicDomain());
        }
        test.stopTest();
    }
}