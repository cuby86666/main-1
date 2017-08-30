/* Last ModifiedBy : Baji
   Last ModifiedDate : 29 May 2017
   Description : Removed the commented code
*/

/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
private class OpportunityTriggerTest{
    private static final ID SFDC_RECORD_TYPE_ID;
    private static final ID MN_RECORD_TYPE_ID;
    private static final String TEST_USER_PROFILE = 'Standard User';
    private static final String TEST_USER_EMAIL = 'testuser@testorg.com.test';
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    private static final String CBG_NON_AUTOMOTIVE = 'Non-Automotive';
    private static final String CBG_DEFAULT = CBG_NON_AUTOMOTIVE; // @default
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_EUR = 'EUR';
    private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
    private static final Double EXCH_RATE_USD = 1.0;
    private static final Double EXCH_RATE_EUR = 0.9;
    private static final Double EXCH_RATE_DEFAULT = EXCH_RATE_USD; // @default
    private static final Decimal UNIT_PRICE = 2;
    private static final Double COMP_MULT = 2.5;
    private static final Double UP_CM = UNIT_PRICE * COMP_MULT;
    private static final Integer TOTAL_YEARLY_PIECES_LIFETIME = 9800;
    private static final Integer TOTAL_YEARLY_PIECES_SHORT_LIVED = 3100;
    private static final Double CLAIM_VALUE_LIFETIME = ((TOTAL_YEARLY_PIECES_LIFETIME * UP_CM) / EXCH_RATE_DEFAULT);
    private static final Double CLAIM_VALUE_SHORT_LIVED = ((TOTAL_YEARLY_PIECES_SHORT_LIVED * UP_CM) / EXCH_RATE_DEFAULT);
    private static final Double CLAIM_VALUE_DEFAULT = CLAIM_VALUE_SHORT_LIVED; // @default (CBG_AUTOMOTIVE ? CLAIM_VALUE_LIFETIME : CLAIM_VALUE_SHORT_LIVED) 
    private static final Double ONE_YEAR_PROD = 500;
    private static final Double CLAIM_VALUE_MN = (ONE_YEAR_PROD * 3);
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final String STAGE_NAME = 'Initial Engagement';
    private static final String DATA_ADMIN_ID = '00520000001EuBkAAK';
    
    private static List<OpportunityLineItem> opptyProds;
    private static OpportunityLineItem opptyProd;
    
    static {
        OpportunityTrigger.fetchOppRecordTypes();
        SFDC_RECORD_TYPE_ID = OpportunityTrigger.sfdcrecordtype_Id;
        MN_RECORD_TYPE_ID = OpportunityTrigger.mnRecordType_Id;
        
        opptyProds = [select Id, OpportunityId, Product_Design_Win_Claim_Value_USD1__c, BL__c, Legacy_3_Year_Prod__c,
                             Prod_Lost__c, Prod_Lost_Cancelled__c, Prod_Cancelled_Claim_Value_excl_Thrust__c,
                             X2010_Value__c, X2011_Value__c, X2012_Value__c, X2013_Value__c, 
                             X2014_Value__c, X2015_Value__c, X2016_Value__c, X2017_Value__c, 
                             X2018_Value__c, X2019_Value__c, X2020_Value__c, X2021_Value__c, 
                             X2022_Value__c, X2023_Value__c, X2024_Value__c, X2025_Value__c,
                             Opportunity.RecordTypeId, Opportunity.Production_Date__c,
                             Opportunity.Account.CMD_Industry_Segment__c,
                             Product2.BL__c, PricebookEntry.Product2.BL__c
                        from OpportunityLineItem 
                       where opportunity.name = 'Test Oppty']; 
        
        for (OpportunityLineItem oli : opptyProds) {
          //  if (oli.BL__c == BL_DEFAULT) {
                opptyProd = oli;
                break;
           // }
        }
    }
    
    @testSetup
    static void setup() {
      
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',Signed_ARIA__c = true,
            ProfileId = p.Id, UserName = TEST_USER_EMAIL);
        insert u;
        
        
        // insert approvers
        List<Approvers_Matrix__c> amcs = new List<Approvers_Matrix__c>();
        amcs.add(new Approvers_Matrix__c(Type__c='Sales Director Approver', criteria_1__c ='Automotive', Criteria_2__c='EMEA', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c='Sales Director Approver', criteria_1__c='EMS', Criteria_2__c='Japan', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c='Regional VP Approver', Criteria_2__c='EMEA', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c='Regional VP Approver', Criteria_2__c='Americas', Approver__c = u.Id, Threshold_1__c = 0));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver', criteria_1__c ='R77', Threshold_1__c = 1000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver', criteria_1__c ='R90', Threshold_1__c = 1000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver', criteria_1__c ='R69', Threshold_1__c = 1000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver', criteria_1__c ='R70', Threshold_1__c = 1000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver', criteria_1__c ='R01', Threshold_1__c = 1000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver-STAR', criteria_1__c ='RMP',Threshold_1__c = 1000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver-STAR', criteria_1__c ='RBM', Threshold_1__c = 1000,Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver-STAR', criteria_1__c ='R90',Threshold_1__c = 1000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver-STAR', criteria_1__c ='R69', Threshold_1__c = 1000,Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver-STAR', criteria_1__c ='R70',Threshold_1__c = 1000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver-STAR', criteria_1__c ='R82', Threshold_1__c = 1000,Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver-STAR', criteria_1__c ='R66',Threshold_1__c = 1000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='MAG Approver-STAR', criteria_1__c ='R83', Threshold_1__c = 1000,Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver', criteria_1__c ='BLHS', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver', criteria_1__c ='BLRF', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver', criteria_1__c ='BL01', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver', criteria_1__c ='BL04', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver', criteria_1__c ='BL03', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver', criteria_1__c ='BL05', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver-STAR', criteria_1__c ='BL01', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver-STAR', criteria_1__c ='BL21', Threshold_1__c = 1500000, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver-STAR', criteria_1__c ='BL04', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver-STAR', criteria_1__c ='BL03', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver-STAR', criteria_1__c ='BL08', Threshold_1__c = 1500, Approver__c = u.Id));
        amcs.add(new Approvers_Matrix__c(Type__c='BL Approver-STAR', criteria_1__c ='BL02', Threshold_1__c = 1500, Approver__c = u.Id));
        insert amcs;

        
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
        
        // Insert an account
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA');
        a.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
         insert a;
        
        // Insert products
     
         Product2 prods = new Product2(Name = 'Test Product' ,  IsActive = true, BL__c = 'BL01', MAG__c = 'R01');
         insert prods;
        
        // Insert an opportunity
        Opportunity o = new Opportunity(Name = 'Test Oppty', AccountId = a.Id, StageName = 'Initial Engagement',Design_win_approval_process__c='open');
        o.RecordTypeId = SFDC_RECORD_TYPE_ID;
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = PRODUCTION_DATE - 60;
        o.Locked_Exchange_Rate__c = 1.00; // Enabled for MN type, hidden for SFDC type. Admin can edit it no matter what type it is.
        o.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        o.X2010_Pieces__c = 0;
        o.X2011_Pieces__c = 0;
        o.X2012_Pieces__c = 0;
        o.X2013_Pieces__c = 0;
        o.X2014_Pieces__c = 0;
        o.X2015_Pieces__c = 0;
        o.X2016_Pieces__c = 1000;
        o.X2017_Pieces__c = 1000;
        o.X2018_Pieces__c = 1000;
        o.X2019_Pieces__c = 400;
        o.X2020_Pieces__c = 0;
        o.X2021_Pieces__c = 0;
        o.X2022_Pieces__c = 500;
        o.X2023_Pieces__c = 500;
        o.X2024_Pieces__c = 600;
        o.X2025_Pieces__c = 800;
        o.X2026_Pieces__c = 600;
        o.X2027_Pieces__c = 700;
        o.X2028_Pieces__c = 800;
        o.X2029_Pieces__c = 900;
        o.X2030_Pieces__c = 1000;
        insert o;
        
        //must create opportunity schedules before creating opportunity products
        List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
        
        // Insert Opportunity Schedule
        for (Integer i = 0 ; i < 4 ; i ++) {
            OpportunitySchedule__c opptySched = new OpportunitySchedule__c(
                Opportunity__c = o.Id, 
                Sched_Date__c = PRODUCTION_DATE, 
                Oppty_Sched_Qty__c = 250, 
                Frozen_Oppty_Sched_Qty__c = 250
            );
            opptyScheds.add(opptySched);
        }
        insert opptyScheds;
             
        List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id = :prods.id and CurrencyIsoCode = :CCY_CODE_DEFAULT];
                
        // Insert opportunity products
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        
        for (PricebookEntry pbe : pbes) {
          OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pbe.Id);
          oli.UnitPrice = UNIT_PRICE;
          oli.Component_Multiplier__c = COMP_MULT;
          oli.Legacy_1_Year_Prod__c = ONE_YEAR_PROD; 
          olis.add(oli);
        }
        
        insert olis;
        
        
    }
    
    // Regional VP = No, Sales Director = No, MAG Approver = No, BL Approver = No
    @isTest
    static void testOpptyApproversDefault() {
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        
        oppty = [select stageName,Design_Win_Approval_Process__c,BL__c,MAG__c,Regional_VP_Approver__c,Sales_Director_Approver__c,MAG_Approver_1__c,BL_Approver_1__c 
                 from Opportunity where id = :oppty.Id];
        
        System.assertEquals('Open', oppty.Design_Win_Approval_Process__c); 
        System.assertEquals('Initial Engagement', oppty.stageName); 
        System.assertEquals(null, oppty.Regional_VP_Approver__c);
        System.assertEquals(null, oppty.Sales_Director_Approver__c);
        System.assertEquals(null, oppty.MAG_Approver_1__c);
        System.assertEquals(null, oppty.BL_Approver_1__c); 
        
    }
    
    
    
    static Map<ID, OpportunityLineItem> getOpportunityProductClaimValues(List<OpportunityLineItem> opptyLineItems) {
        Set<ID> opptyLineItemIDs = new Set<ID>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
          opptyLineItemIDs.add(oli.Id);
        }
        
        Map<ID, OpportunityLineItem> result = new Map<ID, OpportunityLineItem>(
            [select BL__c,MAG__c,Claim_Value_USD__c, Prod_Cancelled_Claim_Value_excl_Thrust__c
               from OpportunityLineItem
              where Id in :opptyLineItemIDs]
        );
                    
      return result;
    }
    
    static Map<ID, Opportunity> getOpportunityClaimValues(List<OpportunityLineItem> opptyLineItems) {
      Set<ID> opptyIDs = new Set<ID>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
            opptyIDs.add(oli.OpportunityId);
        }
        
        Map<ID, Opportunity> result = new Map<ID, Opportunity>(
            [select Opp_Design_Win_Claim_Value_USD__c, X2016_Pieces__c
               from Opportunity
              where Id in :opptyIDs]
        );
        
        return result;
    }
    
    static Boolean isAuto() {
        return (opptyProd.Opportunity.Account.CMD_Industry_Segment__c == CBG_AUTOMOTIVE) ? true : false;
    }
   
    @isTest
    static void testMNOpptyLegacyOwneronUpdatePositive() {
    
     opptyProd.Opportunity.Legacy_Opportunity_Owner__c = TEST_USER_EMAIL;
     opptyProd.Opportunity.RecordTypeId = MN_RECORD_TYPE_ID;
     Test.startTest();
     update opptyProd.Opportunity;
     Test.stopTest();
     
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        
        oppty = [select Owner.email from opportunity where Name = 'Test Oppty' limit 1];
                 
        System.assertEquals(TEST_USER_EMAIL, oppty.Owner.email);        
    
    }
    
    @isTest
    static void testMNOpptyLegacyOwneronUpdateNegative() {
    
     opptyProd.Opportunity.Legacy_Opportunity_Owner__c = 'abcuser@abcorg.com.abc';
     opptyProd.Opportunity.RecordTypeId = MN_RECORD_TYPE_ID;
     Test.startTest();
     update opptyProd.Opportunity;
     Test.stopTest();
     
     List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        
      oppty = [select Ownerid from opportunity where Name = 'Test Oppty' limit 1];
                 
        System.assertEquals(DATA_ADMIN_ID, oppty.Ownerid); 
    
    }
    
    @isTest
    static void testMNOpptyLegacyOwneronInsertPositive() {
    
     Opportunity o = new Opportunity(Name = 'Test MN Oppty', StageName = 'Initial Engagement',Design_win_approval_process__c='open');
        o.RecordTypeId = MN_RECORD_TYPE_ID;
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = PRODUCTION_DATE - 60;
        o.Locked_Exchange_Rate__c = 1.00; // Enabled for MN type, hidden for SFDC type. Admin can edit it no matter what type it is.
        o.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        o.Legacy_Opportunity_Owner__c = TEST_USER_EMAIL;
        o.One_Year_Pieces__c = 10000;
        
        Test.startTest();
        insert o;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        
        oppty = [select Owner.email from opportunity where Name = 'Test MN Oppty' limit 1];
                 
        System.assertEquals(TEST_USER_EMAIL, oppty.Owner.email);
        
   }

    @isTest
    static void testMNOpptyLegacyOwneronInsertNegative() {
     opptyProd.Opportunity.Legacy_Opportunity_Owner__c = 'abcuser@abcorg.com.abc';
      Opportunity o = new Opportunity(Name = 'Test MN Oppty', StageName = 'Initial Engagement',Design_win_approval_process__c='open');
        o.RecordTypeId = MN_RECORD_TYPE_ID;
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = PRODUCTION_DATE - 60;
        o.Locked_Exchange_Rate__c = 1.00; // Enabled for MN type, hidden for SFDC type. Admin can edit it no matter what type it is.
        o.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        o.Legacy_Opportunity_Owner__c = 'abcuser@abcorg.com.abc';
        o.One_Year_Pieces__c = 10000;
    
         Test.startTest();
         insert o;
         
         OpportunitySchedule__c opptySched = new OpportunitySchedule__c(
            Opportunity__c = o.Id, 
            Sched_Date__c = Date.newInstance(2017, 01, 01), 
            Oppty_Sched_Qty__c = 250, 
            Frozen_Oppty_Sched_Qty__c = 250
         );
         insert opptySched;
         Test.stopTest();
         
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        
        oppty = [select Ownerid from opportunity where Name = 'Test MN Oppty' limit 1];
                 
        System.assertEquals(DATA_ADMIN_ID, oppty.Ownerid); 
    
    }
  
    static testMethod void testAutomotiveSegment() 
    {
      //opptyProd.Opportunity.Industry_Segment__c = 'Automotive & Transportation'; //J comment out since the picklist values may be invalid if any changes.
      opptyProd.Opportunity.Production_Date__c  = Date.newInstance(2016, 03, 15);
      opptyProd.Opportunity.CloseDate = Date.newInstance(2016, 01, 20);
      
      Test.startTest();
      update opptyProd.Opportunity;
      Test.stopTest();
    }
    
}