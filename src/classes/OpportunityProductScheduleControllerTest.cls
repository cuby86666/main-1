/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
private class OpportunityProductScheduleControllerTest {
    private static final String TYPE_PARENT_ACC = 'Parent_Account'; 
    private static final String TYPE_CHILD_ACC = 'Child_Account';
    private static final ID SFDC_RECORD_TYPE_ID;
    private static final ID MN_RECORD_TYPE_ID;
    private static ID PARENT_RECORD_TYPE_ID;
    private static ID CHILD_RECORD_TYPE_ID;
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
    private static final Double NEW_COMP_MULT = 2;
    private static final Double UP_CM = UNIT_PRICE * COMP_MULT;
    private static final Integer TOTAL_YEARLY_PIECES_LIFETIME = 13800;
    private static final Double CLAIM_VALUE_LIFETIME = ((TOTAL_YEARLY_PIECES_LIFETIME * UP_CM) / EXCH_RATE_DEFAULT);
    private static final Double CLAIM_VALUE_SHORT_LIVED;
    private static final Double CLAIM_VALUE_DEFAULT;
    private static final Double ONE_YEAR_PROD = 1500;
    private static final Double LOCKED_EXCHANGE_RATE = 1.5;
    private static final Double CLAIM_VALUE_MN = ((ONE_YEAR_PROD * 3) / LOCKED_EXCHANGE_RATE);
    //private static final Double CLAIM_VALUE_MN = (ONE_YEAR_PROD / LOCKED_EXCHANGE_RATE); // SIR 1069: Change from 3 years to 1 year
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 02, 30);
    private static final String PROD_LOST = 'Lost';
    private static final String PROD_CANCELLED = 'Cancelled';
    private static final String STAGE_NAME = 'COMMITMENT';//'Initial Engagement';
    private static final String STAGE_WON = 'Commitment';
    private static final String OPPTY_LOST = 'Lost';
    private static final String OPPTY_CANCELLED = 'Cancelled';
    private static String DW_APPROVAL_STATUS_OPEN = 'Open';
    private static String DW_APPROVAL_STATUS_LOST = 'Lost';
    private static final Double SHARE = 100;
    private static final Double NEW_SHARE = 80;
    private static final Integer SCHED_QTY = 1500;
    
    private static List<Opportunity> opptyList;
    private static Opportunity opptyOpen;
    private static Opportunity opptyWon;
    
    private static Opportunity opptyTest;
    private static OpportunitySchedulingWrapper.OpportunityScheduleExists opptyExistsTest;
    
    private static OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView opptyProdSchedInitTest;
    private static List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> lstopptyProdSchedView;
     private static List<OpportunityLineItem> olis;
    
    private static OpportunitySchedulingWrapper.OpportunityScheduleView dispOpptySchedTabTest;
    private static OpportunitySchedulingWrapper.OppotunityProductScheduleView opptyProdSchedTabTest;
    private static OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView opptyProdInitDtTestTest;
    private static List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
    private static List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstDispOpptySchedTabTest = new List<OpportunitySchedulingWrapper.OpportunityScheduleView>();
    private static List<PricebookEntry> pbes;
    private static List<Product2> prods;
    private static OpportunityLineItem opptyProdSfdc;
    private static OpportunitySchedule__c opptySchedSfdc;
    
    static{
        SFDC_RECORD_TYPE_ID = OpportunitiesSelector.getSfdcRecordTypeId();
        MN_RECORD_TYPE_ID = OpportunitiesSelector.getMnRecordTypeId();
        fetchAccountRecordTypes();
   }
    public static void fetchAccountRecordTypes(){
        for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = TRUE AND SobjectType = 'Account' AND (DeveloperName =: TYPE_PARENT_ACC OR DeveloperName =: TYPE_CHILD_ACC)]){
            if(rt.DeveloperName == TYPE_PARENT_ACC){
                PARENT_RECORD_TYPE_ID = rt.Id;
            }
            else if(rt.DeveloperName == TYPE_CHILD_ACC){
                CHILD_RECORD_TYPE_ID = rt.Id;
            }
        }
    }
    @testSetup
    public static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name =: TEST_USER_PROFILE];
        
        // Insert a test user
        User u = new User(
            Alias = 'test',
            Email = TEST_USER_EMAIL,
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, 
            UserName = TEST_USER_EMAIL
        );
        insert u;
        
        // Insert FX Rates
      /*  List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_USD, Currency_Code__c = CCY_CODE_USD, CurrencyIsoCode = CCY_CODE_USD, Exchange_Rate__c = EXCH_RATE_USD));
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_EUR, Currency_Code__c = CCY_CODE_EUR, CurrencyIsoCode = CCY_CODE_EUR, Exchange_Rate__c = EXCH_RATE_EUR));
        insert fxrs;
        
        Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
        fxRates.put(CCY_CODE_USD, fxrs.get(0));
        fxRates.put(CCY_CODE_EUR, fxrs.get(1));*/
        
        // Insert Parent Account
        Account parentAcc = new Account(Name = 'Test Account', Region__c = 'EMEA', RecordTypeId = PARENT_RECORD_TYPE_ID);
        parentAcc.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        insert parentAcc;
        
        parentAcc = [SELECT Id FROM Account WHERE RecordTypeId =: PARENT_RECORD_TYPE_ID LIMIT 1];
        
        // Insert Child Account
        Account childAcc = new Account(Name = 'Test Account', Region__c = 'EMEA', RecordTypeId = CHILD_RECORD_TYPE_ID, ParentId = parentAcc.Id);
        childAcc.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        insert childAcc;
                
        // Insert products
            prods = new List<Product2>();
        
        for (Integer i = 0; i < 4; i++) {
            Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
                prods.add(new Product2(Name = 'Test Product' + i, MAG__c = MAG_SHORT_LIVED, IsActive = true));
            } else {
                prods.add(new Product2(Name = 'Test Product' + i, MAG__c = MAG_LIFETIME, IsActive = true));
            }            
        }
        insert prods;
                
          opptyTest = new Opportunity(
            Name = 'Test Oppty',
            RecordTypeId = SFDC_RECORD_TYPE_ID,
            AccountId = childAcc.Id,
            Industry_Segment__c = 'AFC',
            StageName = STAGE_NAME,
            CurrencyIsoCode = CCY_CODE_DEFAULT,
            Production_Date__c = PRODUCTION_DATE,
            CloseDate = PRODUCTION_DATE - 30
        );
        insert opptyTest;

        //List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id in :prods and CurrencyIsoCode = :CCY_CODE_DEFAULT];

       /* List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        
        for (PricebookEntry pbe : pbes) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyTest.Id, PricebookEntryId = pbe.Id);
            oli.UnitPrice = UNIT_PRICE;
            oli.Component_Multiplier__c = COMP_MULT;
            oli.Legacy_1_Year_Prod__c = ONE_YEAR_PROD; 
            oli.Share__c = SHARE;
            olis.add(oli);
        }
        
        insert olis;  */     
    }
    
    static List<OpportunitySchedule__c> createOpportunitySchedules(Opportunity oppty) {
        //List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
        List<Double> yearQtys = new List<Double>{2000, 3000, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200};
        Integer prodQtr = ((oppty.Production_Date__c.month() - 1) / 3) + 1;
        OpportunitySchedule__c opptySched;
        
        if (prodQtr == 1) {
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
            opptyScheds.add(opptySched);
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 04, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
            opptyScheds.add(opptySched);
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 07, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
            opptyScheds.add(opptySched);
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
            opptyScheds.add(opptySched);    
        } else if (prodQtr == 2) {
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 04, 01), Oppty_Sched_Qty__c = 200, Frozen_Oppty_Sched_Qty__c = 200);
            opptyScheds.add(opptySched);
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 07, 01), Oppty_Sched_Qty__c = 400, Frozen_Oppty_Sched_Qty__c = 400);
            opptyScheds.add(opptySched);
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = 400, Frozen_Oppty_Sched_Qty__c = 400);
            opptyScheds.add(opptySched);
        } else if (prodQtr == 3) {
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 07, 01), Oppty_Sched_Qty__c = 500, Frozen_Oppty_Sched_Qty__c = 500);
            opptyScheds.add(opptySched);
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = 500, Frozen_Oppty_Sched_Qty__c = 500);
            opptyScheds.add(opptySched);
        } else if (prodQtr == 4) {
            opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = 1000, Frozen_Oppty_Sched_Qty__c = 1000);
            opptyScheds.add(opptySched);
        }
        
        for (Integer i = 0; i < yearQtys.size(); i++) {
            Double quarterQty = yearQtys[i] / 4;
            Integer year = 2017 + i;
            
            for (Integer j = 0; j < 4; j++) {
                Integer month = 1 + (3 * j);
                Date schedDate = Date.newInstance(year, month, 1);
                opptySched = new OpportunitySchedule__c();
                opptySched.Opportunity__c = oppty.ID;
                opptySched.Sched_Date__c = schedDate;
                opptySched.Oppty_Sched_Qty__c = quarterQty;
                opptySched.Frozen_Oppty_Sched_Qty__c = quarterQty;
                opptyScheds.add(opptySched);    
            }   
        }
        
        insert opptyScheds;
        return opptyScheds;
    }
    
        
    static void createOpptyProdSchedulesetup() {
      createOpportunitySchedules(opptyTest);
            olis = new List<OpportunityLineItem>();
         pbes = [select Id from PricebookEntry where Product2Id in :prods and CurrencyIsoCode = :CCY_CODE_DEFAULT];
        for (PricebookEntry pbe : pbes) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyTest.Id, PricebookEntryId = pbe.Id);
            oli.UnitPrice = UNIT_PRICE;
            oli.Component_Multiplier__c = COMP_MULT;
            oli.Price_Erosion_Rate__c = 0;
            oli.Share__c = 100;
            olis.add(oli);
        }
        
        insert olis;
        
        lstopptyProdSchedView = new List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>();
        OpportunitySchedulingWrapper.OppotunityProductScheduleView dispDta1= new OpportunitySchedulingWrapper.OppotunityProductScheduleView();
        dispDta1.quarterdate='2016Q1';
        dispDta1.oppValues = opptyTest;
        dispDta1.prodPrice = 10;
        dispDta1.prodShare = 85;
        dispDta1.oliRecord =olis[1];
        lstopptyProdSchedView.add(dispDta1);
        OpportunitySchedulingWrapper.OppotunityProductScheduleView dispDta2 = new OpportunitySchedulingWrapper.OppotunityProductScheduleView();
        dispDta2.prodPrice = 15;
        dispDta2.prodShare =85;
        dispDta2.quarterdate='2016Q2';
        dispDta2.oppValues = opptyTest; 
        dispDta1.oliRecord =olis[1];
        lstopptyProdSchedView.add(dispDta2);
        OpportunitySchedulingWrapper.OppotunityProductScheduleView dispDta3 = new OpportunitySchedulingWrapper.OppotunityProductScheduleView();
        dispDta3.prodPrice = 20;
        dispDta3.prodShare =95;
        dispDta3.quarterdate='2016Q3';
        dispDta3.oppValues = opptyTest;
        dispDta1.oliRecord =olis[1];
        lstopptyProdSchedView.add(dispDta3);
        OpportunitySchedulingWrapper.OppotunityProductScheduleView dispDta4 = new OpportunitySchedulingWrapper.OppotunityProductScheduleView();
        dispDta4.prodPrice = 20;
        dispDta4.prodShare =95;
        dispDta4.quarterdate='2016Q4';
        dispDta4.oppValues = opptyTest;
        dispDta4.oliRecord =olis[1];
        lstopptyProdSchedView.add(dispDta4);
        
    }
    
     // To test to display the Oppty Prod Schedules when the there is initial load
    static testmethod void OpptyProdSchedInitTestCase1() 
    {
        setup();
        createOpptyProdSchedulesetup();
        Test.StartTest();
        opptyProdSchedInitTest = OpportunityProductScheduleController.getOpptyLineItemValuesClass(opptyTest.Id);
        Test.StopTest();
    }
    
   // To test if there are no Oppty Schedules hence direct to step1:Oppty Schedule Page
    static testmethod void OpptyProdSchedLineItemOnChangeTestCase1() 
    {
        setup();
        createOpptyProdSchedulesetup();
        Test.StartTest();
        lstopptyProdSchedView = OpportunityProductScheduleController.getOpptyProdSchedDisplayClass(opptyTest.Id,prods[1].name);
        Test.StopTest();
    }
    
    //To test if to Update the records
        static testmethod void OpptyProdSchedUpdateTestCase1() 
    {
        setup();
        createOpptyProdSchedulesetup();
        Test.StartTest();
        String JSONStringlstDispOpptyProdSchedTabTest = JSON.serialize(lstopptyProdSchedView);
        Boolean isSave;
        isSave = OpportunityProductScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest,prods[0].name);
        System.assert(isSave== true);
        Test.StopTest();
    }

    //Test method to upate the default display save function for Oppty Prod Schedules.
      static testmethod void OpptyProdSchedUpdateTestCase2() 
    {
        setup();
        createOpptyProdSchedulesetup();
        Test.StartTest();
        for(OpportunitySchedulingWrapper.OppotunityProductScheduleView oppProSchWrap : lstopptyProdSchedView){
         oppProSchWrap.oliRecord = olis[0];
        }
        String JSONStringlstDispOpptyProdSchedTabTest = JSON.serialize(lstopptyProdSchedView);
        Boolean isSave;
        isSave = OpportunityProductScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest, null);
        System.assert(isSave== true);
        Test.StopTest();
    }
        
    //Test method to validate the data if share or price value is not met as defined.
      static testmethod void OpptyProdSchedUpdateTestCase3() 
    {
        setup();
        createOpptyProdSchedulesetup();
        Test.StartTest();
        for(OpportunitySchedulingWrapper.OppotunityProductScheduleView oppProSchWrap : lstopptyProdSchedView){
         oppProSchWrap.oliRecord = olis[0];
        }
        lstopptyProdSchedView[0].prodShare =0;
        String JSONStringlstDispOpptyProdSchedTabTest = JSON.serialize(lstopptyProdSchedView);
        Boolean isSave;
        isSave = OpportunityProductScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest, null);
        System.assert(isSave== false);
        Test.StopTest();
    }

  //Test method to check if no Update if there is no change in the valsues of Prod Share and Schedule price.  
       static testmethod void OpptyProdSchedUpdateTestCase4() 
    {
        setup();
        createOpptyProdSchedulesetup();
        Test.StartTest();
        lstopptyProdSchedView = OpportunityProductScheduleController.getOpptyProdSchedDisplayClass(opptyTest.Id,prods[1].name);
        String JSONStringlstDispOpptyProdSchedTabTest = JSON.serialize(lstopptyProdSchedView);
        Boolean isSave;
        isSave = OpportunityProductScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest, null);
        System.assert(isSave== true);
        Test.StopTest();
    }
}