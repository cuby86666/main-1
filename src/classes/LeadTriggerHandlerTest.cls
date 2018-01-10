/*************************************************************************
@Created By:     Jewelslyn
@Description:    Test class for Lead trigger Handler.
**************************************************************************/

@isTest
public class LeadTriggerHandlerTest {

    public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser3@testorg.com.test';
    public static final String TEST_USER_EMAIL_4 = 'testuser4@testorg.com.test';
    
    public static list<User> listUser=new list<user>();
    public static list<contact> listContact=new list<contact>();
    
     @testSetup
    static void setup(){
        map<id,string> mapUserName=new map<id,String>();
        LeadOwnerAssignmentHandler.init();
        List<LeadCountrySettings__c> leadCountrySettings = new list<LeadCountrySettings__c>();
        leadCountrySettings.add(new LeadCountrySettings__c(country_Code__c='TCN', Country__c='Test Country',Name='TestCountry',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(State_Code__c='TST', State__c='Test State',Name='TestState',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(State_Code__c='TSN', State__c='Test State1',Name='TestState1',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(country_Code__c='TCT', Country__c='Test Country1',Name='TestCountry1',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(Name='NovaSilva',NovaSilva_Email__c='test@test1.com'));
        insert leadCountrySettings;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
        listUser.add(u);
        User u2 = new User(Alias = 'test1', Email = TEST_USER_EMAIL_1, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_1);
        listUser.add(u2);
        insert listUser;
        
        // Insert  accounts
        List<account> listAcc=new list<Account>();
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',country__c='Test Country',state_province__c='Test State'));                
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - ROM',
                                NXP_GID__c='12345',country__c='Test Country',state_province__c='Test State'));                
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12245')); 
        insert listAcc;
        
        // Insert contacts
        
        for(account a:listAcc){
            listContact.add(new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_0,AccountId=a.Id));                
        	listContact.add(new Contact(FirstName='Test1',LastName='Contact1',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_1,AccountId=a.Id));                
        	//listContact.add(new Contact(FirstName='Test2',LastName='Contact2',  Title = 'strTitle',
                                  //email = TEST_USER_EMAIL_2,AccountId=a.Id));
        }                
        insert listContact;
        
        //Insert Leads
        list<lead> listLead=new list<lead>();
        listLead.add(new lead(FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='TCN', state='TST',email=TEST_USER_EMAIL_3));
        listLead.add(new lead(FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='TUP', state='TUS',email=TEST_USER_EMAIL_2,
                             distributor_contact__c=listContact[0].Id));
        listLead.add(new lead(FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Accepted by Disti',country='TUP', state='TUS',email=TEST_USER_EMAIL_1,
                             distributor_contact__c=listContact[0].Id));
        listLead.add(new lead(FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Accepted by Disti',country='TUP', state='TUS',email=TEST_USER_EMAIL_4
                             ));
        listLead.add(new lead(FirstName='Test',LastName='Lead', Company='Test company',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='open',country='TUP', state='TUS',email=TEST_USER_EMAIL_0
                             ));
        insert listLead;
    }
    @isTest
    static void testCountrymapping(){
        Test.starttest();
        list<lead> countryUpLead=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company from Lead
                                          where RecordType.Name='Uncategorized Leads'];
        
        for(lead ld:countryUpLead){
            ld.country='TCT';
        }
        update countryUpLead;
        Test.stopTest();
        
    }
    @isTest
    static void testRandomNumberGen(){
        Test.starttest();
        lead ranNumGenLead=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company from Lead
                                          where email=:TEST_USER_EMAIL_2];
        
        contact con=new Contact(FirstName='Test2',LastName='Contact2',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_2);        
        ranNumGenLead.distributor_contact__c=con.Id;                    
        update ranNumGenLead;
		Test.stopTest();        
    }
    @isTest
    static void testUpdtDistCon(){
        Test.starttest();
        
        lead updtDistCon=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company,
                            			  Disti_Feedback_Email_Address__c from Lead                            
                                          where email=:TEST_USER_EMAIL_1];               
        updtDistCon.Disti_Feedback_Email_Address__c=TEST_USER_EMAIL_2;                    
        update updtDistCon;
		Test.stopTest();        
    }
    @isTest
    static void testinsertContactRole(){
        lead ldConvert=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company,
                            			  Disti_Feedback_Email_Address__c from Lead                            
                                          where email=:TEST_USER_EMAIL_4];
        String convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;
        contact con=new Contact(FirstName='Test2',LastName='Contact2',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_4);
        Database.LeadConvert lc = new database.LeadConvert();
		lc.setLeadId(ldConvert.id);
        lc.setContactId(con.Id);
		lc.setDoNotCreateOpportunity(false);
		lc.setConvertedStatus(convertedStatus);

		Database.LeadConvertResult lcr = Database.convertLead(lc);
		System.assert(lcr.isSuccess());
            
    }
     @isTest
    static void testemailToMultipleDistis(){
        Test.starttest();
        lead ldToDistis=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company,
                            			  Disti_Feedback_Email_Address__c,CC_Address__c,Note_To_Disti__c from Lead                            
                                          where status='open' and RecordTypeId=:LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE];
        contact con=new Contact(FirstName='Test2',LastName='Contact2',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_2);
        insert Con;        
        ldToDistis.Distributor_Contact__c=con.Id;
        ldToDistis.CC_Address__c=TEST_USER_EMAIL_0;
        ldToDistis.Note_To_Disti__c='Test';
        update ldToDistis;
        Test.stopTest(); 
    }
}