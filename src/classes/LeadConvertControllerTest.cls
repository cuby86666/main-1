/*************************************************************************
@Created By:     Jewelslyn
@Description:    Test class for Lead Conversion using Feedback loop
**************************************************************************/

/*************************************************************************
@Modified By:     Jewelslyn
@Modified Date:   22 Sep 2017
@Description:    Modified class to include Updating the contact to Disti account 
if a contact is identified based on Lead's Email and associated to a different Account
**************************************************************************/

@isTest
public class LeadConvertControllerTest {
    public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser3@testorg.com.test';
    
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_EUR = 'EUR';
    private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
    private static final Double EXCH_RATE_USD = 2.0;
    private static final Double EXCH_RATE_EUR = 0.9;
    private static final Double EXCH_RATE_DEFAULT = EXCH_RATE_USD; // @default
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final Double LOCKED_EXCHANGE_RATE = 1.5;
    private static final Double ONE_YEAR_PIECES = 1500;
    private static final Date EXPECTED_CLOSE_DATE = Date.newInstance(2016, 05, 30);
    private static final string DISTRIBUTOR_TRACKING_NUMBER= 'c014562';
    
     @testSetup
    static void setup(){
        map<id,string> mapUserName=new map<id,String>();
        LeadOwnerAssignmentHandler.init();
        List<LeadCountrySettings__c> leadCountrySettings = new list<LeadCountrySettings__c>();
        leadCountrySettings.add(new LeadCountrySettings__c(country_Code__c='TCN', Country__c='Test Country',Name='TestCountry'));
        leadCountrySettings.add(new LeadCountrySettings__c(State_Code__c='TST', State__c='Test State',Name='TestState'));
        insert leadCountrySettings;
        
       
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        
        
        // insert a test user
        
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
        insert u;
        
        // insert approvers
        List<Approvers_Matrix__c> amcs = new List<Approvers_Matrix__c>();
        amcs.add(new Approvers_Matrix__c(Type__c = 'Regional VP', criteria_2__c = 'EMEA', Approver__c = u.Id,Threshold_1__c=0));
        amcs.add(new Approvers_Matrix__c(Type__c = 'Regional VP', criteria_2__c = 'Americas', Approver__c = u.Id,Threshold_1__c=0));
        amcs.add(new Approvers_Matrix__c(Type__c = 'Regional Controller', criteria_2__c = 'EMEA', Approver__c = u.Id,Threshold_1__c=0));
        amcs.add(new Approvers_Matrix__c(Type__c = 'Regional Controller', criteria_2__c = 'Americas', Approver__c = u.Id,Threshold_1__c=0));
        insert amcs;
        
        user u1=[select id, name from user where name=:label.Lead_Default_Owner];
        if(!mapUserName.containskey(u1.Id)){
            mapUserName.put(u1.Id,u1.Name);
        }
        
        // insert FX Rates
        // There is a workflow which sets Opportunity.Locked_Exchange_Rate__c to 
        // Opportunity.Currency__r.Exchange_Rate__c, which refers to FX_Rates__c.Exchange_Rate__c
        List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_USD, Currency_Code__c = CCY_CODE_USD, CurrencyIsoCode = CCY_CODE_USD, Exchange_Rate__c = EXCH_RATE_USD));
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_EUR, Currency_Code__c = CCY_CODE_EUR, CurrencyIsoCode = CCY_CODE_EUR, Exchange_Rate__c = EXCH_RATE_EUR));
        insert fxrs;
        
        Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
        fxRates.put(CCY_CODE_USD, fxrs.get(0));
        fxRates.put(CCY_CODE_EUR, fxrs.get(1));
        
        //Insert Accounts
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',country__c='Test Country',state_province__c='Test State');        
        insert a;
        Account a1 = new Account(Name = 'Test Account1', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',country__c='Test Country',state_province__c='Test State');        
        insert a1;
        
        //Insert Contact   
        Contact con3 = new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_3,AccountId=a1.Id);        
        insert con3;
        
        
        
        //Insert Lead to Convert
        List<Lead> listLeadToConvert=new list<lead>();
        string accountId=a.Id;
        listLeadToConvert.add(new Lead(FirstName='Test',LastName='Lead3', Company='Test compan3',
                                  RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE,Account_Id__c= accountId,
                              status='Open',country='Test Country', city='Test City',email=TEST_USER_EMAIL_3,ownerId=u.Id                                 
                                 ));
        listLeadToConvert.add(new Lead(FirstName='Test',LastName='Lead4', Company='Test compan3',
                                  RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Sent to Distributor',country='Test Country', city='Test City',email=TEST_USER_EMAIL_2,
                                 Distributor_Tracking_Number__c=DISTRIBUTOR_TRACKING_NUMBER,Manual_Update_Check__c=True
                                 )); 
        listLeadToConvert.add(new Lead(FirstName='Test',LastName='Lead3', Company='Test compan3',
                                  RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                                status='Accepted by Disti',email=TEST_USER_EMAIL_2,Manual_Update_Check__c=True
                                 ));
        
       insert listLeadToConvert;
        
        //Insert Lead Activity
        Lead_Activity__c ldActivity=new Lead_Activity__c(Action__c='Ordered',Object__c='SAMPLE',Specific_Interest__c='PCF8593T/1,118',
                                        Specific_Interest_Description__c='Low power clock and calendar',
                                        Order_Status__c='PENDING',Related_to_Lead__c=listLeadToConvert[0].Id);
        
         //Insert Opportunity
        OpportunityTrigger.fetchOppRecordTypes();
        Opportunity o = new Opportunity(Name = 'Test Oppty', AccountId = a.Id, Industry_Segment__c = 'Industrial', StageName = 'Initial Engagement');
        o.RecordTypeId = OpportunityTrigger.sfdcrecordtype_Id;
        o.Distributor_Tracking_Number__c=DISTRIBUTOR_TRACKING_NUMBER;
        o.Lead_Id__c=listLeadToConvert[2].Id;
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = EXPECTED_CLOSE_DATE;
        o.Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE; // Enabled for MN type, hidden for SFDC type. Admin can edit it no matter what type it is.
        o.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        o.One_Year_Pieces__c= ONE_YEAR_PIECES;
        o.X2010_Pieces__c = 0;
        o.X2011_Pieces__c = 0;
        o.X2012_Pieces__c = 0;
        o.X2013_Pieces__c = 0;
        o.X2014_Pieces__c = 0;
        o.X2015_Pieces__c = 0;
        o.X2016_Pieces__c = 1000;
        o.X2017_Pieces__c = 2000;
        o.X2018_Pieces__c = 3000;
        o.X2019_Pieces__c = 100;
        o.X2020_Pieces__c = 200;
        o.X2021_Pieces__c = 300;
        o.X2022_Pieces__c = 400;
        o.X2023_Pieces__c = 500;
        o.X2024_Pieces__c = 600;
        o.X2025_Pieces__c = 700;
        o.X2026_Pieces__c = 800;
        o.X2027_Pieces__c = 900;
        o.X2028_Pieces__c = 1000;
        o.X2029_Pieces__c = 1100;
        o.X2030_Pieces__c = 1200;
        insert o;
    
        // Insert an OpportunityShare record
        OpportunityShare os = new OpportunityShare();
        os.OpportunityId = o.Id; 
        os.OpportunityAccessLevel = 'Edit';
        os.UserOrGroupId = u.Id;
        insert os;      
    }
    @isTest
    static void testReturnLead(){
        Test.startTest();
        lead listreturnLead=[select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                         Distributor_Tracking_Number__c,RecordTypeId,Account_Id__c,Description,street,city,
                                         country,state,company,PostalCode from lead where  status='Open'];
        LeadConvertController.getLeadActivities(listreturnLead.Id);
        Test.stopTest();
    }
    @isTest
    static void testfetchOppty(){
        Test.startTest();
        lead listreturnLead=[select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                         Distributor_Tracking_Number__c,RecordTypeId,Account_Id__c,Description,street,city,
                                         country,state,company,PostalCode from lead where  status='Open'];        
        LeadConvertController.fetchOpportunity('test',listreturnLead.Id,listreturnLead.Account_Id__c);        
        Test.stopTest();
    }
    
    @isTest
    static void testfetchOppList(){
        Test.startTest();
        lead listreturnLead=[select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                         Distributor_Tracking_Number__c,RecordTypeId,Account_Id__c,Description,street,city,
                                         country,state,company,PostalCode from lead where  status='Open'];        
        LeadConvertController.fetchOppList(listreturnLead.Id,listreturnLead.Account_Id__c);        
        Test.stopTest();
    }
    @isTest
    static void testlistLeadAccount(){
        Test.startTest();
        lead listreturnLead=[select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                         Distributor_Tracking_Number__c,RecordTypeId,Account_Id__c,Description,street,city,
                                         country,state,company,PostalCode from lead where  status='Open'];        
        LeadConvertController.listLeadAccount(listreturnLead.Id,listreturnLead.OwnerId);        
        Test.stopTest();
    }
    @isTest
    static void testgetDependentOptionsImpl(){
        Test.startTest();                
        LeadConvertController.getDependentOptionsImpl('Opportunity','Industry_Segment__c','Sub_Segment__c');        
        Test.stopTest();
    }
     @isTest
    static void testlistOfSearchAccRecords(){
        Test.startTest();
        lead listreturnLead=[select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                         Distributor_Tracking_Number__c,RecordTypeId,Account_Id__c,Description,street,city,
                                         country,state,company,PostalCode from lead where  status='Open'];        
        LeadConvertController.listOfSearchAccRecords('test',listreturnLead.Id,listreturnLead.OwnerId);        
        Test.stopTest();
    }
    @isTest
    static void testconvertLead(){
        Test.startTest();
        lead listreturnLead=[select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                         Distributor_Tracking_Number__c,RecordTypeId,Account_Id__c,Description,street,city,
                                         country,state,company,PostalCode from lead where  status='Open'];
        opportunity opp=[select id,StageName from opportunity where StageName = 'Initial Engagement'];
        string closeDate=string.valueOf(system.today());        
       try{
       LeadConvertController.convertLead(true,false,'test','test',opp.Id,listreturnLead.Id,closeDate,
                                         listreturnLead.Account_Id__c,'Industrial','Factory Automation');   
         }  
       catch(Exception e) 
        {

        }   
        Test.stopTest();
    }
    
     @isTest
    static void testconvertLead1(){
        Test.startTest();
        lead listreturnLead=[select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                         Distributor_Tracking_Number__c,RecordTypeId,Account_Id__c,Description,street,city,
                                         country,state,company,PostalCode from lead where  status='Sent to Distributor'];
        opportunity opp=[select id,StageName from opportunity where StageName = 'Initial Engagement'];
        string closeDate=string.valueOf(system.today());    
        try{    
        LeadConvertController.convertLead(false,true,'test','test',opp.Id,listreturnLead.Id,closeDate,
                                         listreturnLead.Account_Id__c,'Industrial','Factory Automation');   
        }   
         catch(Exception e) 
        {

        }  
        Test.stopTest();
    }
}