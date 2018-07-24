/*  
  
   @Last Modified By   : Shridevi Badiger
   @Last Modified Date : 20-Oct-2016
   @Description : SIR 1329-test the functionality to Populate value for Contact Service Level field.

**********************************************************************
 @Last Modified By   : Shridevi Badiger
 @Last Modified Date : 20-Mar-2017
 @Description : SIR 324-test the functionality to Populate value for Contact Service Level field with new values and custom setting.
**********************************************************************
 @Last Modified By   : Shridevi Badiger
 @Last Modified Date : 25-Aug-2017
 @Description : SIR 828-Increased the code coverage of ContactClass

**********************************************************************/
/*************************************************************************************************************
@Modified By :   Harish Gowda N.
@Modified Date:  23 May 2018
@Description:    To Update User region of a contact based on the Community web country as part of SFDC-1611. 
**************************************************************************************************************/
@isTest
public class ContactClassTest{
    private static final String ACCOUNT_CHILDACCOUNT = 'Child_Account';
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
   // private static final String Hub_countryAndRegion = 'Country_and_Region';
     private static Hub_Foundation__c testHubFoundation;
     private static Hub_Foundation__c testHubFoundation2;
     private static Hub_Foundation__c testHubFoundation3;
     private static Hub_Foundation__c testHubFoundation4;
     private static Hub_Foundation__c testHubFoundation5;
     private static Hub_Foundation__c testHubFoundation6; 
    public static RecordType childAccount;
    public static RecordType parentAccount;
     //public static RecordType countryAndRegion;
    public static User objUser{get;set;}
    public static List<Account> lstChildAccount=new list<Account>();
    public static Contact objContact1{get;set;}
    public static Account objChildAccount{get;set;}
   // public static String recordTypeId ;

    private static void CreateContactServiceLevelCriteria()
    {
        list<Contact_Service_Level_Criteria__c> lstCSLC=new list<Contact_Service_Level_Criteria__c>();
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='toni@zollikofer.eu',Contact_Service_Level__c='A-DirectCust'));
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='CN.ABB.COM',Contact_Service_Level__c='A-DirectCust'));
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='CN.BOSCH.COM',Contact_Service_Level__c='A-DirectCust'));
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='nxp.com',Contact_Service_Level__c='A1-Internal'));
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='abc.nxp.com',Contact_Service_Level__c='A1-InternalUser'));
        
        insert lstCSLC;
    
    }
    
    private static void fetchRecordTypes()
    {
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and
                               ((SobjectType = 'Account' or SobjectType = 'Hub_Foundation__c') and (DeveloperName =: ACCOUNT_CHILDACCOUNT or DeveloperName =: ACCOUNT_ParentACCOUNT) 
                              )
                              Limit 2])
        {
            if(rt.DeveloperName == ACCOUNT_CHILDACCOUNT)
            {
                childAccount = rt;
            }
            else if(rt.DeveloperName == ACCOUNT_ParentACCOUNT)
            {
                parentAccount = rt; 
            } 
          /*  else if(rt.DeveloperName == Hub_countryAndRegion)
            {
                countryAndRegion = rt; 
            } */
        }
    }
     //Added By Harish Gowda as part of SFDC-1161 -to Create a hub foundation
     
    private static void makeTestHubFoundations()
    {
        RecordType recId = [Select Id, DeveloperName From RecordType Where DeveloperName = 'Country_and_Region' and SobjectType = 'Hub_Foundation__c'];
         Id recTypeId = recId.id; 
 testHubFoundation = new Hub_Foundation__c 
        (
            Country__c = 'India' ,
            Region__c = 'AP - GC' ,
            Alpha_2_Code__c = 'TT' ,
            Alpha_3_Code__c = 'AAA' ,
            RecordTypeid = recTypeId
        );
        insert testHubFoundation ;
        
        testHubFoundation2 = new Hub_Foundation__c 
        (
            Country__c = 'Test Country 2' ,
            Region__c = 'AP - JAPAN' ,
            Alpha_2_Code__c = 'TA' ,
            Alpha_3_Code__c = 'BBB' ,
            RecordTypeid = recTypeId
            );
        insert testHubFoundation2 ;
        
        testHubFoundation3 = new Hub_Foundation__c 
        (
            Country__c = 'India' ,
            Region__c = 'AP - SAP' ,
            Alpha_2_Code__c = 'TB' ,
            Alpha_3_Code__c = 'CCC' ,
            RecordTypeid = recTypeId
        );
        insert testHubFoundation3 ;
        
        testHubFoundation4 = new Hub_Foundation__c 
        (
            Country__c = 'India' ,
            Region__c = 'AP - KOREA' ,
            Alpha_2_Code__c = 'TC' ,
            Alpha_3_Code__c = 'DDD' ,
            RecordTypeid = recTypeId
        );
        insert testHubFoundation4 ;
        
        testHubFoundation5 = new Hub_Foundation__c 
        (
            Country__c = 'India' ,
            Region__c = 'AM - AMEC' ,
            Alpha_2_Code__c = 'TD' ,
            Alpha_3_Code__c = 'EEE' ,
            RecordTypeid = recTypeId
        );
        insert testHubFoundation5 ;
        
        testHubFoundation6 = new Hub_Foundation__c 
        (
            Country__c = 'India' ,
            Region__c = 'EU - EMEA' ,
            Alpha_2_Code__c = 'TE' ,
            Alpha_3_Code__c = 'FFF' ,
            RecordTypeid = recTypeId
        );
        insert testHubFoundation6 ;
    }
    //Added By Shridevi as part of SIR 1329-to create parent account
    private static Account createParentAccount()
    {
        fetchRecordTypes();
        //Method to create a Parent Account
        Account objParentAccount;
        objParentAccount = new Account(RecordTypeID= parentAccount.ID,
                                                Name = 'Bosch', Customer_Category__c= 'Channel');
        return  objParentAccount;
    }
    //Added By Shridevi as part of SIR 1329-to create user
    private static void createTestUser()
    {
   //  UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
   //,UserRoleId = portalRole.Id
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        system.assert(objProfile.Id != null);
        
        objUser= new User(alias = 'nUser' , email= 'testing@test.com', emailencodingkey='UTF-8', lastname='test',languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', username= 'prakhartest' + datetime.now().millisecond() +'@test.com' );
            
        insert objUser;
    }
 
    
//Added By Shridevi as part of SIR 1329-to create child account
     private static Account createChildAccount(ID parentAccountId,string customerCategory)
    {
       
        objChildAccount = new Account(RecordTypeID= childAccount.ID,ParentId =parentAccountId,ownerId=objUser.id,  
                                            Name = 'Bosch Japan', Region__c = 'Japan',Role__c='Distributor',
                                             Sales_Area__c = 'Japan ID', Industry_Segment__c = 'Mobile',
                                             Country__c = 'Japan',customer_category__c=customerCategory);
        return objChildAccount;    
    }
     //Added By Shridevi as part of SIR 1329-to create conatcts
   // @future
    private static Contact createTestContact(id AccountId)    
    {   
       
       objContact1=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@CN.BOSCH.COM', AccountID = AccountId,CanAllowPortalSelfReg=false,contact_service_level__c='',Mailingcountry='DEU',Community_web_country__c='AAA',User_region__c='SAP'); 
        
    
         return objContact1 ;
     }

//Added By Harish Gowda as part of SFDC-1161 -to Create list of contacts with the data from hub foundation
          
     private static void createTestContactList(id AccountId)    
    {   
       
       List<Contact> lstContact = new List<Contact>();
       
       lstContact.add(new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test11@CN.BOSCH.COM', AccountID = AccountId,CanAllowPortalSelfReg=false,contact_service_level__c='',Mailingcountry='AAA',Community_web_country__c='AAA'));
       lstContact.add(new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test12@CN.BOSCH.COM', AccountID = AccountId,CanAllowPortalSelfReg=false,contact_service_level__c='',Mailingcountry='BBB',Community_web_country__c='BBB'));                                  
      lstContact.add(new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test13@CN.BOSCH.COM', AccountID = AccountId,CanAllowPortalSelfReg=false,contact_service_level__c='',Mailingcountry='CCC',Community_web_country__c='CCC'));
      lstContact.add(new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test14@CN.BOSCH.COM', AccountID = AccountId,CanAllowPortalSelfReg=false,contact_service_level__c='',Mailingcountry='DDD',Community_web_country__c='DDD')); 
      lstContact.add(new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test15@CN.BOSCH.COM', AccountID = AccountId,CanAllowPortalSelfReg=false,contact_service_level__c='',Mailingcountry='EEE',Community_web_country__c='EEE'));                                                                       
      lstContact.add(new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test16@CN.BOSCH.COM', AccountID = AccountId,CanAllowPortalSelfReg=false,contact_service_level__c='',Mailingcountry='FFF',Community_web_country__c='FFF')); 
        
        insert lstContact;                               
     }
     
     //Added by Shridevi as part of SIR 324.
   public static void createCustomSetting()
    {
            list<TS_customer_category_with_CSL_values__c> listCustomerCategorySetting=new list<TS_customer_category_with_CSL_values__c>(); //Custom Setting for Contact Fields
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier1',contact_service_level__c='A1_Tier_1'));
            
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier2',contact_service_level__c='A1_Tier_2'));
            
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier3',contact_service_level__c='A1_Tier_3'));
            
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier4 - TMMA',contact_service_level__c='A1_NXP'));
            
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier4 - ROM',contact_service_level__c='B1_Tier_4_ROM'));
            
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier4 - Long Tail',contact_service_level__c='B1_Tier_4_Longtail'));
            
            insert listCustomerCategorySetting;
    }
   //Added By Shridevi as part of SIR 1329-to test the functionality to Populate value for Contact Service Level field.   
 @isTest
    public static void TestCSLIdentification()
    { 
        List<Contact> lstContact=new List<Contact>();
        createTestUser();
        createCustomSetting();
        CreateContactServiceLevelCriteria();
         makeTestHubFoundations();
        Account objParentAccount = createParentAccount();
        insert objParentAccount;
        system.assert(objParentAccount.id!=null);
        
        lstChildAccount.add(createChildAccount(objParentAccount.id,'Tier1'));
        lstChildAccount.add(createChildAccount(objParentAccount.id,'Tier2'));
        lstChildAccount.add(createChildAccount(objParentAccount.id,'Tier 4 - ROM'));
       // lstChildAccount[2].Role__c='Distributor';
        insert lstChildAccount;
       //  lstChildAccount[2].Role__c='Distributor';
      //   update lstChildAccount[2];
        lstChildAccount=[select id,customer_category__c,Role__c,name from account where id in:lstChildAccount];
        
        system.debug(lstChildAccount);
        
        lstContact.add(createTestContact( lstChildAccount[0].id));
        lstContact.add(createTestContact( lstChildAccount[1].id));
        lstContact.add(createTestContact( lstChildAccount[0].id));
        lstContact.add(createTestContact( lstChildAccount[0].id));
        lstContact.add(createTestContact( lstChildAccount[2].id));
        lstContact.add(createTestContact( lstChildAccount[2].id));
      //  lstContact.add(createTestContactList);       
        
        test.starttest();
        //system.debug('acc 2:'+lstChildAccount[1]);
        lstContact[0].Email='test@zollikofer.eu';
        lstContact[1].Email='toni@zollikofer.eu';
        lstContact[2].Email='shridevi@CN.ABB.COM';
        lstContact[2].AccountId=null;
        lstContact[3].Email='shridevi@test.abc.nxp.com';
        lstContact[3].AccountId=null;
        lstContact[5].Email='shridevi@test.abc.nxp.com.in';
        
        insert lstContact;
        
        lstContact=[select id,name,Email,AccountID,contact_service_level__c from contact where id in:lstContact];
          
        System.debug(lstContact[0].contact_service_level__c);
        System.debug(lstContact[3].contact_service_level__c);
        System.debug(lstContact[1].contact_service_level__c);
        System.debug(lstContact[4].contact_service_level__c);
        
        system.assert(lstContact[0].contact_service_level__c=='A1_Tier_1');
        system.assert(lstContact[1].contact_service_level__c=='A-DirectCust');  
        system.assert(lstContact[2].contact_service_level__c=='A-DirectCust'); 
        system.assert(lstContact[3].contact_service_level__c=='A1-InternalUser'); 
        system.assert(lstContact[4].contact_service_level__c=='A3_Distributor'); 
        
        lstContact[0].Email='test@test.eu';
        lstContact[0].AccountId=null;
        lstContact[3].AccountId=null;
        update lstContact;
        lstContact=[select id,name,Email,AccountID,contact_service_level__c from contact where id in:lstContact];
        system.assert(lstContact[0].contact_service_level__c=='B2-OtherCompany'); 
        createTestContactList(objParentAccount.id);
        test.stoptest();
        
    }
   
   
    }