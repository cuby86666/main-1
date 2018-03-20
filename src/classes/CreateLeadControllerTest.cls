/*************************************************************************
@Created By:     Jewelslyn
@Description:    Test class for create Lead
**************************************************************************/

@isTest
public class CreateLeadControllerTest {
	public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser3@testorg.com.test';
    
    
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
                               NXP_GID__c='12145',country__c='Test Country',state_province__c='Test State',Role__c='Distributor');        
        insert a;
        
        //Insert Contact   
        Contact con3 = new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_3,AccountId=a.Id);        
        insert con3;
        
        //Insert Case
        case c1=new Case(contactId=con3.id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = TEST_USER_EMAIL_3, JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Web_Region__c = 'Test_region',mag__c='RMP',  
                          		origin = 'Web',Case_Owner_Name__c='test',SuppliedEmail = 'test@test.com');
        insert c1;
        
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
    @isTest
    static void testGetContactDetails(){
        Test.startTest();
        case caseReturns=[Select id,ContactEmail,Product_Name__r.Name,Product_Sub__c,AccountId,Account.Customer_Category__c,
                    OwnerId,CaseNumber,Owner.Type from case where Product_Sub__c =: 'Mixers' ];
        CreateLeadController.getContactDetails(caseReturns.Id);
        Test.stopTest();
    }
    @isTest
    static void testFetchDistiAccSearch(){
      	Test.startTest();
        Account acc=[select id, Name,Role__c from Account where Role__c='Distributor'];
        CreateLeadController.fetchDistiAccSearch('test');
        CreateLeadController.fetchDistiAccounts();
        Test.stopTest();
    }
    @isTest
    static void testGetselectOptions(){
      Test.startTest();
       //(sObject)lead ;
        //sObject lead;
        //CreateLeadController.getselectOptions(Lead.sObjectType,'Industry');
        CreateLeadController.getDependentOptionsImpl('Account','Country__c','State_Province__c');
      Test.stopTest();
    }
    @isTest
    static void testFetchRegion(){
       Test.startTest();
        CreateLeadController.fetchRegion('countryValu');
        Test.stopTest();
    }
    @isTest
    static void testCreateLead(){
      Test.startTest();
        case caseReturns=[Select id,ContactEmail,Product_Name__r.Name,Product_Sub__c,AccountId,Account.Customer_Category__c,
                    OwnerId,CaseNumber,Owner.Type,Product_Type_Number__c from case where Product_Sub__c =: 'Mixers' ];
        contact con=[select id, email from contact where email = :TEST_USER_EMAIL_3];
        CreateLeadController.createLead(caseReturns.Id,'Test First', 'Test Last','Test product','test@test.com',
                                       'Test Comp','projctDesc','timeLineValueCas','volme','competitor','industryValue',
                                       'conPhone','conMobPhone','caseNumber','shareWithDisti','NXPNotes','countryValu',
                                       'stateValu','proLV3','postalCode','accDistiName','test','test','test');
      Test.stopTest();
    }
    @isTest
    static void testCreateLeadNullCase(){
      Test.startTest();
        case caseReturns=[Select id,ContactEmail,Product_Name__r.Name,Product_Sub__c,AccountId,Account.Customer_Category__c,
                    OwnerId,CaseNumber,Owner.Type,Product_Type_Number__c,mag__c from case where Product_Sub__c =: 'Mixers' ];
        contact con=[select id, email from contact where email = :TEST_USER_EMAIL_3];
        CreateLeadController.createLead(caseReturns.Id,'Test First', 'Test Last',null,'test@test.com',
                                       'Test Comp','projctDesc',null,null,null,null,
                                       null,null,'caseNumber',null,'NXPNotes','countryValu',
                                       null,'null',null,null,null,'test','test');
      Test.stopTest();
    }

}