/*  
  
   @Last Modified By   : Shridevi Badiger
   @Last Modified Date : 20-Oct-2016
   @Description : SIR 1329-test the functionality to Populate value for Contact Service Level field.

**********************************************************************
 @Last Modified By   : Shridevi Badiger
 @Last Modified Date : 20-Mar-2017
 @Description : SIR 324-test the functionality to Populate value for Contact Service Level field with new values and custom setting.

**********************************************************************/
@isTest
public class ContactClassTest{
    private static final String ACCOUNT_CHILDACCOUNT = 'Child_Account';
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    
    public static RecordType childAccount;
    public static RecordType parentAccount;
    public static User objUser{get;set;}
    public static List<Account> lstChildAccount=new list<Account>();
    public static Contact objContact1{get;set;}
    public static Account objChildAccount{get;set;}

    private static void CreateContactServiceLevelCriteria()
    {
        list<Contact_Service_Level_Criteria__c> lstCSLC=new list<Contact_Service_Level_Criteria__c>();
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='toni@zollikofer.eu',Contact_Service_Level__c='A-DirectCust'));
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='CN.ABB.COM',Contact_Service_Level__c='A-DirectCust'));
        lstCSLC.add(new Contact_Service_Level_Criteria__c(Criteria_Field_Name__c='Email',Criteria_Field_Value__c='CN.BOSCH.COM',Contact_Service_Level__c='A-DirectCust'));
        
        insert lstCSLC;
    
    }
    
    private static void fetchRecordTypes()
    {
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and
                               (SobjectType = 'Account' and (DeveloperName =: ACCOUNT_CHILDACCOUNT or DeveloperName =: ACCOUNT_ParentACCOUNT) 
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
        }
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
                                            Name = 'Bosch Japan', Region__c = 'Japan',
                                             Sales_Area__c = 'Japan ID', Industry_Segment__c = 'Mobile',
                                             Country__c = 'Japan',customer_category__c=customerCategory);
        return objChildAccount;    
    }
     //Added By Shridevi as part of SIR 1329-to create conatcts
   // @future
    private static Contact createTestContact(id AccountId)    
    {   
       
       objContact1=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@CN.BOSCH.COM', AccountID = AccountId,CanAllowPortalSelfReg=false,contact_service_level__c=''); 
        
    
         return objContact1 ;
     }
     //Added by Shridevi as part of SIR 324.
   public static void createCustomSetting()
    {
            list<TS_customer_category_with_CSL_values__c> listCustomerCategorySetting=new list<TS_customer_category_with_CSL_values__c>(); //Custom Setting for Contact Fields
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier1',contact_service_level__c='A1_Tier_1'));
            
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier2',contact_service_level__c='A1_Tier_2'));
            
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier3',contact_service_level__c='A1_Tier_3'));
            
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier4 - TMMA',contact_service_level__c='A1_NXP'));
            
            listCustomerCategorySetting.add(new TS_customer_category_with_CSL_values__c(Name='Tier4 - RoM',contact_service_level__c='B1_Tier_4_ROM'));
            
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
        Account objParentAccount = createParentAccount();
        insert objParentAccount;
        system.assert(objParentAccount.id!=null);
        
        lstChildAccount.add(createChildAccount(objParentAccount.id,'Tier1'));
        lstChildAccount.add(createChildAccount(objParentAccount.id,'Tier2'));
        insert lstChildAccount;
        lstChildAccount=[select id,customer_category__c,name from account where id in:lstChildAccount];
        
        system.debug(lstChildAccount);
        
        lstContact.add(createTestContact( lstChildAccount[0].id));
        lstContact.add(createTestContact( lstChildAccount[1].id));
        lstContact.add(createTestContact( lstChildAccount[0].id));
        test.starttest();
        //system.debug('acc 2:'+lstChildAccount[1]);
        lstContact[0].Email='test@zollikofer.eu';
        lstContact[1].Email='toni@zollikofer.eu';
        lstContact[2].Email='shridevi@CN.ABB.COM';
        lstContact[2].AccountId=null;
        
        insert lstContact;
        
        lstContact=[select id,name,Email,AccountID,contact_service_level__c from contact where id in:lstContact];
          
        System.debug(lstContact[0].contact_service_level__c);
        System.debug(lstContact[1].contact_service_level__c);
        system.assert(lstContact[0].contact_service_level__c=='A1_Tier_1');
      
        system.assert(lstContact[1].contact_service_level__c=='A-DirectCust');  
        system.assert(lstContact[2].contact_service_level__c=='A-DirectCust'); 
        lstContact[0].Email='test@test.eu';
        lstContact[0].AccountId=null;
        update lstContact;
        lstContact=[select id,name,Email,AccountID,contact_service_level__c from contact where id in:lstContact];
        system.assert(lstContact[0].contact_service_level__c=='B2-OtherCompany'); 
        test.stoptest();
    }  
}