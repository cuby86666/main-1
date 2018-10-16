/*************************************************************************
@Created By:     Manikanta
@Description:    Test class for CreatePotentialLead
**************************************************************************/

@istest
public class CreatePotentialLeadTest {

	public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser3@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser4@testorg.com.test';
    
    
    @testSetup
    static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
        insert u;
        
        //Insert Accounts
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',country__c='Austria',state_province__c='Test State',Role__c='Distributor');        
        insert a;
        
        //Insert Contact   
        Contact con3 = new Contact(FirstName='Test',LastName='Contact', Title = 'strTitle',
                                  email = TEST_USER_EMAIL_3,AccountId=a.Id);        
        insert con3;
        
        //Insert Product
        
        Product2 Prod = new Product2 (Name='Test',Product_Type__c='Test');
        insert Prod;
        
        //Insert Live chat Transcript 	
        
        
      //LiveChatTranscript lvc = new LiveChatTranscript(contactid=con3.id,LiveChatVisitorid ='00096621');
        //insert lvc;
       
        List<LeadCountrySettings__c> leadCountrySettings = new list<LeadCountrySettings__c>();
        leadCountrySettings.add(new LeadCountrySettings__c(country_Code__c='TCN', Country__c='countryValu',Name='TestCountry',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(State_Code__c='TST', State__c='stateValu',Name='TestState',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(State_Code__c='TSN', State__c='stateValu',Name='TestState1',
                                                          Region__c='EMEA'));
        leadCountrySettings.add(new LeadCountrySettings__c(country_Code__c='TCT', Country__c='countryVal',Name='TestCountry1',
                                                          Region__c='EMEA'));
        insert leadCountrySettings;
    }

  
     @istest
    static  void testgetContactDetails(){
        Test.startTest();
        Contact contactReturns = [select Id,firstname,lastname,email,phone from contact where email =: TEST_USER_EMAIL_3];
        CreatePotentialLead.getContactDetails(contactReturns.Id);
         Test.stopTest();
    }
    

    
    /*
        @istest
    static  void testgetChckDetails(){
        Test.startTest();
        Contact contactReturns1 = [select Id,firstname,lastname,email from contact where email =: TEST_USER_EMAIL_3];
        LiveChatTranscript transReturns = [select Id,name from LiveChatTranscript where contactid =: contactReturns1.id];
       CreateLeadController1.getContactDetails(contactReturns1.Id);
       Test.stopTest();
    }

*/
    
    
             @istest
    static  void testgetPrdDetails(){
        Test.startTest();
        Product2 ProductReturns = [select Id,name from Product2 where name='Test'];
        String Prod1 = ProductReturns.name;
        CreatePotentialLead.getPrdDetails(Prod1);
        
        Test.stopTest();
    }
    
     @istest
    
        static  void testfetchproducts(){
        Test.startTest();
        List<Product2> productReturns = [select Id,name from Product2 ];
        CreatePotentialLead.fetchproducts();
         Test.stopTest();
    }
    
     @istest
    
        static  void testfetchprdSearch(){
        Test.startTest();
		String searchKey = 'x' + '%'; 
        List<Product2> productReturns = [select Id,name from Product2 where name like: searchKey];
        CreatePotentialLead.fetchprdSearch(searchKey );
         Test.stopTest();
    }

    
    @isTest
    static void testgetselectOptions(){
      Test.startTest();
        Lead ld = new Lead();
       CreatePotentialLead.getselectOptions(ld,'Industry');
         
        CreatePotentialLead.getDependentOptionsImpl('Account','Country__c','State_Province__c');
        CreatePotentialLead.getprdDependentOptionsImpl('Case','Product__c', 'Product_Category__c');
        CreatePotentialLead.getprddDependentOptionsImpl('Case','Product_Category__c','Product_Sub__c');
        
        
      Test.stopTest();
    }
    
    @isTest
    static void testfetchRegion(){
       Test.startTest();
        
        CreatePotentialLead.fetchRegion('countryValu');
        Test.stopTest();
    }
    
    @isTest
    static void testCreateLead(){
      Test.startTest();
        Contact ContactReturns=[select Id,firstname,lastname,email,phone,community_web_country__c from contact where email =: TEST_USER_EMAIL_3 ];
       // contact con=[select id, email from contact where email = :TEST_USER_EMAIL_3];
        CreatePotentialLead.createLead(ContactReturns.Id,'TestFirst', 'TestLast','test@test.com',
                                       'projctDesc','EMSI','1234455','YES','NO',
                                       'NXPNotes','countryValu',
                                       'stateValu','postalCode','prodlv1','prodlv2','prodlv3','prodname','prodId','transid','company');
             
      Test.stopTest();
    }
  @isTest
    static void testCreateLeadNullCase(){
      Test.startTest();
       Contact ContactReturns=[select Id,firstname,lastname,email,phone,community_web_country__c from contact where email =: TEST_USER_EMAIL_3 ];
        
       
        
         CreatePotentialLead.createLead(ContactReturns.Id,'TestFirst', 'TestLast','test@test.com',
                                       null,null,null,null,null,
                                       'NXPNotes','countryValu',
                                       'stateValu',null,null,null,null,null,null,null,null);
      Test.stopTest();
    }
   

}