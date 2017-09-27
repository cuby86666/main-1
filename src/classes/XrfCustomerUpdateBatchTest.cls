/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
public class XrfCustomerUpdateBatchTest
{
    private static final string TYPE_MN_OPPTY='Model N Oppty';
    private static final string TYPE_SFDC_OPPTY='SFDC Oppty';
    private static final String TEST_USER_PROFILE = 'Standard User';
    private static final String TEST_USER_EMAIL = 'testuser@testorg.com.test';
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    private static final String CBG_NON_AUTOMOTIVE = 'Non-Automotive';
    private static final String CBG_DEFAULT = CBG_NON_AUTOMOTIVE; // @default
    private static final String MAG_SHORT_LIVED;
    private static final String MAG_LIFETIME;
    private static final String MAG_DEFAULT;
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_EUR = 'EUR';
    private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
    private static final Double EXCH_RATE_USD = 2.0;
    private static final Double EXCH_RATE_EUR = 0.9;
    private static final Double EXCH_RATE_DEFAULT = EXCH_RATE_USD; // @default
    private static final Decimal UNIT_PRICE = 2;
    private static final Double COMP_MULT = 5;
    private static final Double UP_CM = UNIT_PRICE * COMP_MULT;
    private static final Integer TOTAL_YEARLY_PIECES_LIFETIME = 13800;
    private static final Double CLAIM_VALUE_LIFETIME = ((TOTAL_YEARLY_PIECES_LIFETIME * UP_CM) / EXCH_RATE_DEFAULT);
    private static final Double CLAIM_VALUE_SHORT_LIVED;
    private static final Double CLAIM_VALUE_DEFAULT;
    private static final Double ONE_YEAR_PROD = 1500;
    private static final Double ONE_YEAR_PIECES = 500;
    private static final Double LOCKED_EXCHANGE_RATE = 1.5;    
    private static final Double CLAIM_VALUE_MN = ((UP_CM *ONE_YEAR_PIECES * 3) / LOCKED_EXCHANGE_RATE);    
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final String PROD_LOST = 'Lost';
    private static final String PROD_CANCELLED = 'Cancelled';
    private static final String STAGE_NAME = 'Initial Engagement';

    @testSetup
    static void setup()
    {
        OpportunityTrigger.fetchOppRecordTypes();
       
   
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL);
        insert u;
        
        // insert approvers
        List<Approvers_Matrix__c> amcs = new List<Approvers_Matrix__c>();
        amcs.add(new Approvers_Matrix__c(Type__c = 'Regional VP', criteria_2__c = 'EMEA', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c = 'Regional VP', criteria_2__c = 'Americas', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c = 'Regional Controller', criteria_2__c = 'EMEA', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c = 'Regional Controller', criteria_2__c = 'Americas', Approver__c = u.Id, Threshold_1__c = 0));
        insert amcs;
        
        List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_USD, Currency_Code__c = CCY_CODE_USD, CurrencyIsoCode = CCY_CODE_USD, Exchange_Rate__c = EXCH_RATE_USD));
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_EUR, Currency_Code__c = CCY_CODE_EUR, CurrencyIsoCode = CCY_CODE_EUR, Exchange_Rate__c = EXCH_RATE_EUR));
        insert fxrs;
        
        Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
        fxRates.put(CCY_CODE_USD, fxrs.get(0));
        fxRates.put(CCY_CODE_EUR, fxrs.get(1));
        
        Map<Integer,Account> mapAccount = new Map<Integer,Account>();
        
        // Insert an account
        Account a = new Account(Name = 'Test0 Account', Region__c = 'EMEA');
        a.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        a.Customer_Category__c = 'Tier 4 - TMMA';
        insert a;
        mapAccount.put(0,a);

        // Insert an account (Tier1)
        Account a1 = new Account(Name = 'Test1 Account', Region__c = 'EMEA');
        a1.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        a1.Customer_Category__c = 'Tier 1';
        insert a1;
        mapAccount.put(1,a1);

        // Insert an account (Tier2)
        Account a2 = new Account(Name = 'Test2 Account', Region__c = 'EMEA');
        a2.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        a2.Customer_Category__c = 'Tier 2';
        insert a2;
        mapAccount.put(2,a2);

        // Insert an account (Tier3)
        Account a3 = new Account(Name = 'Test3 Account', Region__c = 'EMEA');
        a3.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        a3.Customer_Category__c = 'Tier 3';
        insert a3;
        mapAccount.put(3,a3);

        // Insert an account
        Account a4 = new Account(Name = 'Test4 Account', Region__c = 'EMEA');
        a3.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        a3.Customer_Category__c = 'Tier 4 - ROM';
        insert a4;
        
        // Insert an Unknown account
        Account b = new Account(Name = 'Unknown', Region__c = 'EMEA');
        b.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        insert b;
        
        /*
        Cross_Reference_Customer__c cust=new Cross_Reference_Customer__c(Customer_Name__c='Test Account',
                                         Customer_Location__c='EMEA',Child_Account__c=a.Id);
        */
        List<Cross_Reference_Customer__c> lstCrossRef = new List<Cross_Reference_Customer__c>();
        for (Integer i = 0; i <= 3; i++) {
            System.debug('@@@@@ ' + 'Test' + i + ' Account' + '-EMEA');
            Cross_Reference_Customer__c cust = new Cross_Reference_Customer__c(Customer_Name__c='Test' + i + ' Account',
                                         Customer_Location__c='EMEA',Child_Account__c=mapAccount.get(i).Id);
            lstCrossRef.add(cust);
        }
        
        insert lstCrossRef;
        
        list<Opportunity> listOpp=new list<opportunity>();
        listOpp.add(new Opportunity(Name = 'Test Oppty1', AccountId = a4.Id,
                                      StageName = 'Initial Engagement', Legacy_End_Customer_Name_and_Location__c='Test1 Account-EMEA',
                                  RecordTypeId = OpportunityTrigger.mnRecordType_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                    One_Year_Pieces__c= ONE_YEAR_PIECES));
        
        listOpp.add(new Opportunity(Name = 'Test Oppty2', AccountId = a4.Id,
                                      StageName = 'Initial Engagement', Legacy_End_Customer_Name_and_Location__c='Test2 Account-EMEA',
                                  RecordTypeId = OpportunityTrigger.mnRecordType_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                   X2010_Pieces__c = 0,One_Year_Pieces__c= ONE_YEAR_PIECES));

        listOpp.add(new Opportunity(Name = 'Test Oppty3',  AccountId = a.Id, MN_Account_Id_Old__c = null, 
                                      StageName = 'Discovery', Legacy_End_Customer_Name_and_Location__c='Unknown-EMEA',
                                  RecordTypeId = OpportunityTrigger.mnRecordType_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                    One_Year_Pieces__c= ONE_YEAR_PIECES));        

        listOpp.add(new Opportunity(Name = 'Test Oppty4',  AccountId = a.Id, MN_Account_Id_Old__c = a4.Id, 
                                      StageName = 'Lost', Legacy_End_Customer_Name_and_Location__c='Unknown-EMEA',
                                  RecordTypeId = OpportunityTrigger.mnRecordType_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                   One_Year_Pieces__c= ONE_YEAR_PIECES));        

        listOpp.add(new Opportunity(Name = 'Test Oppty11',  
                                      StageName = 'Initial Engagement', AccountId = a1.Id, MN_Account_Id_Old__c = a4.Id,
                                    Legacy_End_Customer_Name_and_Location__c='Te Account-EMEA',
                                  RecordTypeId = OpportunityTrigger.mnRecordType_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                    One_Year_Pieces__c= ONE_YEAR_PIECES));

        listOpp.add(new Opportunity(Name = 'Test Oppty12',  
                                      StageName = 'Initial Engagement', AccountId = a2.Id, MN_Account_Id_Old__c = a4.Id,
                                    Legacy_End_Customer_Name_and_Location__c='Te Account-EMEA',
                                  RecordTypeId = OpportunityTrigger.mnRecordType_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                    One_Year_Pieces__c= ONE_YEAR_PIECES));

        listOpp.add(new Opportunity(Name = 'Test Oppty13',  
                                      StageName = 'Initial Engagement', AccountId = a3.Id, MN_Account_Id_Old__c = a4.Id,
                                    Legacy_End_Customer_Name_and_Location__c='Te Account-EMEA',
                                  RecordTypeId = OpportunityTrigger.mnRecordType_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                    One_Year_Pieces__c= ONE_YEAR_PIECES));

        listOpp.add(new Opportunity(Name = 'Test Remove Account Oppty', MN_Account_Id_Old__c = '001D000000j3LbOIAU',
                                      StageName = 'Initial Engagement', AccountId = a3.Id, Legacy_End_Customer_Name_and_Location__c='Te Account-EMEA',
                                  RecordTypeId = OpportunityTrigger.mnRecordType_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                    One_Year_Pieces__c= ONE_YEAR_PIECES));
        
        insert listOpp;
        
        // Insert an OpportunityShare record
        
        
        Product2 prod=new Product2(Name = 'Test Product' , MAG__c = MAG_SHORT_LIVED, IsActive = true);        
        insert prod;
        
        List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id =:prod.Id and CurrencyIsoCode = :CCY_CODE_DEFAULT];
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();

        for (opportunity opp : listOpp) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbes[0].Id);
            oli.UnitPrice = UNIT_PRICE;
            oli.Component_Multiplier__c = COMP_MULT;
            //oli.Legacy_1_Year_Prod__c = ONE_YEAR_PROD; 
            olis.add(oli);
        }
        
        insert olis;
        
        Opportunity opp2 = new Opportunity(Name = 'Test Oppty5',  AccountId = a.Id, MN_Account_Id_Old__c = b.Id, 
                                      StageName = 'Discovery', Legacy_End_Customer_Name_and_Location__c='Unknown-EMEA',
                                  RecordTypeId = OpportunityTrigger.mnRecordType_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                           One_Year_Pieces__c= ONE_YEAR_PIECES);
        insert opp2;
        
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp2.Id, PricebookEntryId = pbes[0].Id);
        oli2.UnitPrice = UNIT_PRICE;
        oli2.Component_Multiplier__c = COMP_MULT;
        oli2.Prod_Lost_Cancelled__c = 'Lost';
        oli2.Prod_Lost__c = true;
        insert oli2;
    }

    @isTest
    static void XrfCustomerUpdateBatchTest1()
    {
        Test.startTest();
        XrfCustomerUpdateBatch c = new XrfCustomerUpdateBatch();
        database.executebatch(c);
        Test.stopTest();
        Integer crossRef = 0;
        Integer NonCrossRef = 0;
        List<Opportunity> lstOppty2 = [Select Id, Name, MN_Account_Id_Old__c from Opportunity];
        for (Opportunity o : lstOppty2) {
            if (o.MN_Account_Id_Old__c == null)
                NonCrossRef++;
            else
                crossRef++;
        }
        System.assert(NonCrossRef == 7);
        System.assert(crossRef == 2);
    }
    
    @isTest
    static void XrfCustomerUpdateBatchTest2()
    {
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2030';
        //schedule the job
        String jobId = System.schedule('testXrfCustomerUpdateBatch', CRON_EXP, new XrfCustomerUpdateBatch());

        List<CronTrigger> lstCrons = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                    FROM CronTrigger WHERE id = :jobId Limit 1];

        System.assert(lstCrons.size() > 0);
        System.assert(lstCrons[0].CronExpression == CRON_EXP);        
        System.assert(lstCrons[0].TimesTriggered == 0);
        Test.stopTest();
    }
}