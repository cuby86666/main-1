@isTest
public class OpportunityCloneControllerTest {
    private static final string TYPE_MN_OPPTY='Model N Oppty';
    private static final string TYPE_SFDC_OPPTY='SFDC Oppty';
    private static final String TEST_USER_PROFILE = 'NXP Sales Cloud User';
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
    private static final Date PRODUCTION_DATE = Date.today().AddDays(60);
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
        
        // Insert an account
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA');
        a.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        a.Customer_Category__c = 'Tier 4 - TMMA';
        a.OwnerId = u.Id;
        insert a;

        // Insert an Unknown account
        Account b = new Account(Name = 'Unknown', Region__c = 'EMEA');
        b.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        insert b;
        
        Cross_Reference_Customer__c cust=new Cross_Reference_Customer__c(Customer_Name__c='Test Account',
                                         Customer_Location__c='EMEA',Child_Account__c=a.Id);
        insert cust;
        
        //opportunity
        list<Opportunity> listOpp=new list<opportunity>();
        listOpp.add(new Opportunity(Name = 'Test Oppty1', OwnerId = u.Id,
                                      StageName = 'Initial Engagement', Legacy_End_Customer_Name_and_Location__c='Test Account-EMEA',
                                  RecordTypeId = OpportunityTrigger.sfdcrecordtype_Id, Production_Date__c = PRODUCTION_DATE,
                                    CloseDate = PRODUCTION_DATE - 60,Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE,
                                   Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT,
                                   One_Year_Pieces__c= ONE_YEAR_PIECES));        
        insert listOpp;
        
        //product
        List<Product2> lstProducts = new List<Product2>();
        for (Integer i = 0; i < 2; i++) {
            Product2 prod=new Product2(Name = 'Test Product' + i , MAG__c = MAG_SHORT_LIVED, IsActive = true);            
            lstProducts.add(prod);
        }
        insert lstProducts;
               
        //get price book entry
        List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id =: lstProducts and CurrencyIsoCode = :CCY_CODE_DEFAULT];
        
        //opportunity schedule
        List<OpportunitySchedule__c> lstOppSched = new List<OpportunitySchedule__c>();
        for (opportunity oppty : listOpp) {
            OpportunitySchedule__c opptySched = new OpportunitySchedule__c();
            opptySched.Oppty_Sched_Qty__c = 1000;
            opptySched.Frozen_Oppty_Sched_Qty__c = 1000;
            opptySched.Sched_Date__c = oppty.Production_Date__c;
            opptySched.opportunity__c = oppty.Id;
            lstOppSched.add(opptySched);
        }
        insert lstOppSched;
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();

        for (PricebookEntry pbe : pbes) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = listOpp.get(0).Id, PricebookEntryId = pbe.Id);
            oli.UnitPrice = UNIT_PRICE;
            oli.Component_Multiplier__c = COMP_MULT;
            olis.add(oli);
        }
        insert olis;
    }

    @isTest
    static void testOpportunityCloneAll() {
        List<Opportunity> lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 1);
        OpportunityCloneController.OpportunityWrapper wrapper = 
            OpportunityCloneController.getOpptyProdsByOpptyId(lstOppty.get(0).Id, OpportunityCloneController.FUNC_CLONE);
        if (wrapper.lstOpptyScheds != null && wrapper.lstOpptyScheds.size() > 0) {
            OpportunitySchedule__c opptySched = wrapper.lstOpptyScheds.get(0);
        }
        wrapper.lstWrappers.get(0).isSelected = true;
        wrapper.newOpptyName = 'CloneTest';
        String strWrapper = System.JSON.serialize(wrapper);
        Test.startTest();
        String strOpptyId = OpportunityCloneController.doCloneAndSpinOff(strWrapper, OpportunityCloneController.FUNC_CLONE);
        lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 2);
        Test.stopTest();
    }

    @isTest
    static void testOpportunitySpinOff() {
        List<Opportunity> lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 1);
        OpportunityCloneController.OpportunityWrapper wrapper = 
            OpportunityCloneController.getOpptyProdsByOpptyId(lstOppty.get(0).Id, OpportunityCloneController.FUNC_SPINOFF);
        wrapper.lstWrappers.get(0).isSelected = true;
        wrapper.newOpptyName = 'SpinOffTest';
        String strWrapper = System.JSON.serialize(wrapper);
        Test.startTest();
        String strOpptyId = OpportunityCloneController.doCloneAndSpinOff(strWrapper, OpportunityCloneController.FUNC_SPINOFF);
        lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 2);
        Test.stopTest();
    }
    
    @isTest
    static void testOpportunityCloneException() {
        List<Opportunity> lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 1);
        OpportunityCloneController.OpportunityWrapper wrapper = 
            OpportunityCloneController.getOpptyProdsByOpptyId(lstOppty.get(0).Id, OpportunityCloneController.FUNC_CLONE);
        wrapper.lstWrappers.get(0).isSelected = true;
        
        OpportunityCloneController.OpportunityCloneWrapper myclone = 
            new OpportunityCloneController.OpportunityCloneWrapper(wrapper.oppty.Id, false);
        myclone.clonedSObjectOpptyScheds = null;
        
        Test.startTest();
        try {
            OpportunityCloneController.doCloneAndSpinOff(wrapper, OpportunityCloneController.FUNC_CLONE, myclone);
        } catch (Exception err) {
            System.assert(err.getMessage() != null);
        }
        lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 1);
        Test.stopTest();
    }
    
    @isTest
    static void testOpportunityCloneProductionDateBeforeToday() {
        List<Opportunity> lstOppty = [Select Id, CloseDate, Production_Date__c from Opportunity order by CreatedDate];
        System.assert(lstOppty.size() == 1);
        Opportunity oppty = lstOppty.get(0);
        oppty.CloseDate = Date.today().addDays(-5);
        oppty.Production_Date__c = Date.today().addDays(-4);
        update oppty;
        OpportunityCloneController.OpportunityWrapper wrapper = OpportunityCloneController.getOpptyProdsByOpptyId(lstOppty.get(0).Id, OpportunityCloneController.FUNC_CLONE);
        wrapper.lstWrappers.get(0).isSelected = true;
        wrapper.newOpptyName = 'CloneTest';
        String strWrapper = System.JSON.serialize(wrapper);
        Test.startTest();
        OpportunityCloneController.doCloneAndSpinOff(strWrapper, OpportunityCloneController.FUNC_CLONE);
        lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 2);
        Test.stopTest();
    }

    @isTest
    static void testReOpenCancelledOpportunity() {
        List<Opportunity> lstOppty = [Select Id, StageName, CloseDate, Production_Date__c from Opportunity order by CreatedDate];
        System.assert(lstOppty.size() == 1);
        Opportunity oppty = lstOppty.get(0);
        oppty.CloseDate = Date.today().addDays(-5);
        oppty.Production_Date__c = Date.today().addDays(-4);
        oppty.StageName = 'Cancelled';
        update oppty;
        OpportunityCloneController.OpportunityWrapper wrapper = OpportunityCloneController.getOpptyProdsByOpptyId(lstOppty.get(0).Id, OpportunityCloneController.FUNC_REOPEN);
        wrapper.lstWrappers.get(0).isSelected = true;
        wrapper.newOpptyName = 'ReOpenTest';
        String strWrapper = System.JSON.serialize(wrapper);
        Test.startTest();
        OpportunityCloneController.doCloneAndSpinOff(strWrapper, OpportunityCloneController.FUNC_REOPEN);
        lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 1);
        Test.stopTest();
    }

    @isTest
    static void testOpportunityCloneQtyPerSys() {
        List<Opportunity> lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 1);
        //find lineitem
        List<OpportunityLineItem> lstOpptyProd = [Select Id, Component_Multiplier__c from OpportunityLineItem];
        for (OpportunityLineItem prod : lstOpptyProd) {
            prod.Component_Multiplier__c = 1.5;
        }
        
        update lstOpptyProd;

        OpportunityCloneController.OpportunityWrapper wrapper = 
            OpportunityCloneController.getOpptyProdsByOpptyId(lstOppty.get(0).Id, OpportunityCloneController.FUNC_CLONE);
        wrapper.lstWrappers.get(0).isSelected = true;
        wrapper.newOpptyName = 'CloneTest';
        String strWrapper = System.JSON.serialize(wrapper);
        Test.startTest();
        String strOpptyId = OpportunityCloneController.doCloneAndSpinOff(strWrapper, OpportunityCloneController.FUNC_CLONE);
        lstOppty = [Select Id from Opportunity];
        System.assert(lstOppty.size() == 2);
        Test.stopTest();
    }
}