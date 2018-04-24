/** 
 * This  class will have the test methods written for the Opportunity Scheduling    
   and Production Management related operations.    
------------------------------------------------------------------------------------    
 * Created By   : Venkateshwar G    
 * Created Date : MAR 09,2017   
 * Description  : This class will have the functionality written for the Opportunity Scheduling     
                  and Production Management related operations. 
------------------------------------------------------------------------------------
*/
@isTest
private class OpportunityScheduleControllerTest {
    private static final String TYPE_PARENT_ACC = 'Parent_Account'; 
    private static final String TYPE_CHILD_ACC = 'Child_Account';
    private static final ID SFDC_RECORD_TYPE_ID;
    private static final ID MN_RECORD_TYPE_ID;
    private static ID PARENT_RECORD_TYPE_ID;
    private static ID CHILD_RECORD_TYPE_ID;
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
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 02, 30);//(2018, 04, 30);
    private static final String PROD_LOST = 'Lost';
    private static final String PROD_CANCELLED = 'Cancelled';
    private static final String STAGE_NAME = 'Initial Engagement';
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
    private static Opportunity opptyTestMN;
    private static Opportunity opptyTestModelN;
    private static Account childAcct;
    
    private static OpportunitySchedulingWrapper.OpportunityScheduleExists opptyExistsTest;
    private static OpportunitySchedulingWrapper.OpportunityScheduleView dispOpptySchedTabTest;
    private static OpportunitySchedulingWrapper.OppotunityProductScheduleView opptyProdSchedTabTest;
    private static OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView opptyProdInitDtTestTest;
    private static List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
    private static List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstDispOpptySchedTabTest = new List<OpportunitySchedulingWrapper.OpportunityScheduleView>();
    
    private static OpportunityLineItem opptyProdSfdc;
    private static OpportunitySchedule__c opptySchedSfdc;
    
    private static List<OpportunityLineItem> olis;
    private static List<PricebookEntry> pbes;
    private static List<Product2> prods;
    private static OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView opptyProdSchedInitTest;
    private static List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> lstopptyProdSchedView;
    private static Set<OpportunitySchedulingWrapper.OppotunityProductScheduleView> setopptyProdSchedView = new Set<OpportunitySchedulingWrapper.OppotunityProductScheduleView>();
    private static User u;


    
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
         u = new User(
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
        
      

        // Insert Parent Account
        Account parentAcc = new Account(Name = 'Test Account', Region__c = 'EMEA', RecordTypeId = PARENT_RECORD_TYPE_ID);
        parentAcc.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        insert parentAcc;
        
        parentAcc = [SELECT Id FROM Account WHERE RecordTypeId =: PARENT_RECORD_TYPE_ID LIMIT 1];
        
        // Insert Child Account
        Account childAcc = new Account(Name = 'Test Account', Region__c = 'EMEA', RecordTypeId = CHILD_RECORD_TYPE_ID, ParentId = parentAcc.Id, Customer_Category__c ='Tier 4 - TMMA');
        childAcc.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        insert childAcc;
         childAcct = childAcc;       
        // Insert products
       // List<Product2> 
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
            StageName = STAGE_NAME,
            CurrencyIsoCode = CCY_CODE_DEFAULT,
            Production_Date__c = PRODUCTION_DATE,
            CloseDate = PRODUCTION_DATE - 30,
            Bypass_Validation_Sched_Start_Date__c = true
        );
        insert opptyTest;
        
       
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
    
        static List<OpportunitySchedulingWrapper.OpportunityScheduleView> createOpportunitySchedulesWrapper(Opportunity oppty) {
        
        lstDispOpptySchedTabTest = new List<OpportunitySchedulingWrapper.OpportunityScheduleView>();
        OpportunitySchedulingWrapper.OpportunityScheduleView dispDta1 = new OpportunitySchedulingWrapper.OpportunityScheduleView();
        dispDta1.quantities = 100;
        dispDta1.comment ='abc';
        dispDta1.quarterdate='2019Q2';
        dispDta1.oppValues = opptyTest;
        lstDispOpptySchedTabTest.add(dispDta1);
        OpportunitySchedulingWrapper.OpportunityScheduleView dispDta2 = new OpportunitySchedulingWrapper.OpportunityScheduleView();
        dispDta2.quantities = 200;
        dispDta2.comment ='abc';
        dispDta2.quarterdate='2019Q3';
        dispDta2.oppValues = opptyTest; 
        lstDispOpptySchedTabTest.add(dispDta2);
        OpportunitySchedulingWrapper.OpportunityScheduleView dispDta3 = new OpportunitySchedulingWrapper.OpportunityScheduleView();
        dispDta3.quantities = 300;
        dispDta3.comment ='abc';
        dispDta3.quarterdate='2019Q4';
        dispDta3.oppValues = opptyTest;
        lstDispOpptySchedTabTest.add(dispDta3);
        OpportunitySchedulingWrapper.OpportunityScheduleView dispDta4 = new OpportunitySchedulingWrapper.OpportunityScheduleView();
        dispDta4.quantities = 200;
        dispDta4.comment ='abc';
        dispDta4.quarterdate='2020Q1';
        dispDta4.oppValues = opptyTest;
        lstDispOpptySchedTabTest.add(dispDta4);
            
        return lstDispOpptySchedTabTest;
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
    
    //Test method to test if there are no Oppty Schedules hence direct to Oppty Schedule create window
    static testmethod void OpptyDispatcherTestCase1() 
    {
        setup();
        Test.StartTest();
        opptyExistsTest = OpportunityScheduleController.getOpptyScheduleInfoClass(opptyTest.Id);
        system.assertEquals(false,opptyExistsTest.isOpptySchedule);
        Test.StopTest();
    }
     
    //Test method to test if there are  Oppty Schedules hence direct to Oppty Schedule Edit window
     static testmethod void OpptyDispatcherTestCase2() 
    {
        setup();
        List<OpportunitySchedule__c> lstOpptySched = createOpportunitySchedules(opptyTest);
        Test.StartTest();
        opptyExistsTest = OpportunityScheduleController.getOpptyScheduleInfoClass(opptyTest.Id);
        system.assertEquals(true,opptyExistsTest.isOpptySchedule);
        Test.StopTest();
    }
 
    
    //Test method to initialise Oppty Sched Edit window: If directed from step1 to step2
    static testmethod void OpptyScheduleEditInitTestCase1() 
    {
        setup();
        Test.StartTest();
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        Date ExpCloseDateTest = Date.newInstance(2019, 04, 15);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        String stgExpCloseDateTest = string.valueOf(ExpCloseDateTest);
        string stglstWrp;
        lstDispOpptySchedTabTest = new List<OpportunitySchedulingWrapper.OpportunityScheduleView>();
        Opportunity oppTest = new Opportunity();
        lstDispOpptySchedTabTest = OpportunityScheduleController.getOpportunityScheduleDisplayValues(opptyTest.Id, 4, 1000,stgProdDateTest,stgExpCloseDateTest,stglstWrp,true);
        system.assert(lstDispOpptySchedTabTest.size()==4);
        Test.StopTest();
    }
    
    //Test method to to dispaly Oppty Sched Edit window if Production date is changed.
    static testmethod void OpptyScheduleEditInitTestCase2() 
    {
        setup();
        Test.StartTest();
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        Date ExpCloseDateTest = Date.newInstance(2019, 04, 15);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        String stgExpCloseDateTest = string.valueOf(ExpCloseDateTest);
        List<OpportunitySchedule__c> lstOpptySched = createOpportunitySchedules(opptyTest);
        string stglstWrp;
        lstDispOpptySchedTabTest= createOpportunitySchedulesWrapper(opptyTest); 
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);
        lstDispOpptySchedTabTest = OpportunityScheduleController.getOpportunityScheduleDisplayValues(opptyTest.Id, 4, 1000,stgProdDateTest,stgExpCloseDateTest,JSONStringlstDispOpptySchedTabTest,true);
        system.assert(lstDispOpptySchedTabTest.size()==4);
        Test.StopTest();
    }
    
        //Test method to to dispaly Oppty Sched Edit window if Production date is changed to null.
    static testmethod void OpptyScheduleEditInitTestCase3() 
    {
        setup();
        Test.StartTest();
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        List<OpportunitySchedule__c> lstOpptySched = createOpportunitySchedules(opptyTest);
        string stglstWrp;
        lstDispOpptySchedTabTest= createOpportunitySchedulesWrapper(opptyTest); 
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);
        lstDispOpptySchedTabTest = OpportunityScheduleController.getOpportunityScheduleDisplayValues(opptyTest.Id, 4, 1000,null,null,JSONStringlstDispOpptySchedTabTest,true);
        system.assert(lstDispOpptySchedTabTest.size()==4);
        Test.StopTest();
    }
    
    //Test method to initialise Oppty Schedule Edit dispaly: If directed to step2 by having Oppty Sched already existing
    static testmethod void OpptyScheduleEditInitTestCase4() 
    {
        setup();
        Test.StartTest();
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        Date ExpCloseDateTest = Date.newInstance(2019, 04, 15);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        String stgExpCloseDateTest = string.valueOf(ExpCloseDateTest);
        string stglstWrp;
        List<OpportunitySchedule__c> lstOpptySched = createOpportunitySchedules(opptyTest);
        Opportunity oppTest = new Opportunity();
        lstDispOpptySchedTabTest = OpportunityScheduleController.getOpportunityScheduleDisplayValues(opptyTest.Id, 4, 1000,stgProdDateTest,stgExpCloseDateTest,stglstWrp,false);
        system.assert(lstDispOpptySchedTabTest != null);
        Test.StopTest();
    }
    
    // Test method to add quarter if already Oppty Sched there in display
        static testmethod void OpptyScheduleEditInitTestCase5() 
    {
        setup();
        Test.StartTest();
        Date ExpCloseDateTest = Date.newInstance(2019, 04, 15);
        String stgExpCloseDateTest = string.valueOf(ExpCloseDateTest);
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        string stglstWrp;
        lstDispOpptySchedTabTest= createOpportunitySchedulesWrapper(opptyTest); 
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);
        lstDispOpptySchedTabTest = OpportunityScheduleController.getQuarterAddedToOpptySched(JSONStringlstDispOpptySchedTabTest,stgProdDateTest);
        system.assert(lstDispOpptySchedTabTest != null);
        Test.StopTest();
    }
    
        // Test method to add quarter if already Oppty Sched there in display with last quarter
        static testmethod void OpptyScheduleEditInitTestCase6() 
    {
        setup();
        Test.StartTest();
        Date ExpCloseDateTest = Date.newInstance(2019, 04, 15);
        String stgExpCloseDateTest = string.valueOf(ExpCloseDateTest);
        Date ProdDateTest = Date.newInstance(2019, 01, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        List<OpportunitySchedule__c> lstOpptySched = createOpportunitySchedules(opptyTest);
        string stglstWrp;
        lstDispOpptySchedTabTest= createOpportunitySchedulesWrapper(opptyTest); 
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);
        lstDispOpptySchedTabTest = OpportunityScheduleController.getOpportunityScheduleDisplayValues(opptyTest.Id, 4, 1000,stgProdDateTest,stgExpCloseDateTest,JSONStringlstDispOpptySchedTabTest,true);
        String JSONStringlstDispOpptySchedTabTestlstQtr = JSON.serialize(lstDispOpptySchedTabTest);
        lstDispOpptySchedTabTest = OpportunityScheduleController.getQuarterAddedToOpptySched(JSONStringlstDispOpptySchedTabTestlstQtr,stgProdDateTest);
        system.assert(lstDispOpptySchedTabTest.size()==5);
        Test.StopTest();
    }
    
    //Test method to add quarter if no Oppty Sched Exists in display
    static testmethod void OpptyScheduleEditInitTestCase7() 
    {
        setup();
        Test.StartTest();
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        string stglstWrp;
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);        
        lstDispOpptySchedTabTest = OpportunityScheduleController.getQuarterAddedToOpptySched(JSONStringlstDispOpptySchedTabTest,stgProdDateTest);
        system.assert(lstDispOpptySchedTabTest != null);
        Test.StopTest();
    }
    
//Test method to save the Oppty Scheds
    static testmethod void OpptyScheduleEditSaveTestCase1() 
    {
        setup();
        Test.StartTest();
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        string stglstWrp;
        lstDispOpptySchedTabTest= createOpportunitySchedulesWrapper(opptyTest); 
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);
        opptyTest.Production_Date__c = Date.newInstance(2019, 01, 01);
        Boolean isQtyGrtZero = OpportunityScheduleController.sumOpptySchedQtyCheck(JSONStringlstDispOpptySchedTabTest);
        opptyExistsTest = OpportunityScheduleController.saveOpptySchedule(opptyTest.Id, JSONStringlstDispOpptySchedTabTest,opptyTest);
        system.assert(opptyExistsTest.oppValues != null);
        system.assert(opptyExistsTest.isOpptySchedule == true);
        Test.StopTest();
    }
    
    //Test method to save the Oppty Scheds with Total Quantity =0.
    static testmethod void OpptyScheduleEditSaveTestCase2() 
    {
        setup();
        Boolean isQtyZero;
        OpportunitySchedulingWrapper.OpportunityScheduleExists opptySchedExistsTest;
        Test.StartTest();
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        string stglstWrp;
        lstDispOpptySchedTabTest= createOpportunitySchedulesWrapper(opptyTest); 
        for(OpportunitySchedulingWrapper.OpportunityScheduleView dispOpptySchedWrap : lstDispOpptySchedTabTest){
         dispOpptySchedWrap.quantities =0;
        }
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);
        opptyTest.Production_Date__c = Date.newInstance(2019, 01, 01);
        isQtyZero = OpportunityScheduleController.sumOpptySchedQtyCheck(JSONStringlstDispOpptySchedTabTest);
        opptySchedExistsTest = OpportunityScheduleController.saveOpptySchedule(opptyTest.Id, JSONStringlstDispOpptySchedTabTest,opptyTest);       
        Test.StopTest();
        system.assert(isQtyZero == true);
        system.assert(opptySchedExistsTest.isOpptySchedule == false);
    }
    
    //Test method to save the Oppty Scheds with Total Quantity =0.
    static testmethod void OpptyScheduleEditSaveTestCmmtCase1() 
    {
        setup();
        Boolean isQtyZero;
        opptyTest.StageName ='Commitment';
        update opptyTest;
        OpportunitySchedulingWrapper.OpportunityScheduleExists opptySchedExistsTest;
        Test.StartTest();
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        string stglstWrp;
        lstDispOpptySchedTabTest= createOpportunitySchedulesWrapper(opptyTest); 
        for(OpportunitySchedulingWrapper.OpportunityScheduleView dispOpptySchedWrap : lstDispOpptySchedTabTest){
         dispOpptySchedWrap.quantities =0;
        }
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);
        isQtyZero = OpportunityScheduleController.sumOpptySchedQtyCheck(JSONStringlstDispOpptySchedTabTest);                
        opptySchedExistsTest = OpportunityScheduleController.saveOpptySchedule(opptyTest.Id, JSONStringlstDispOpptySchedTabTest,opptyTest);       
        Test.StopTest();
        system.assert(opptySchedExistsTest.isOpptySchedule == true);
    }
    
    // Test method to insert if new sched quarter, edit if existing sched quarter and deleting existing sched if there is no quarter in that display
    static testmethod void OpptyScheduleEditSaveTestCase3() 
    {
        setup();
        Test.StartTest();
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        string stglstWrp;
        lstDispOpptySchedTabTest= createOpportunitySchedulesWrapper(opptyTest); 
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);
        opptyTest.Production_Date__c = Date.newInstance(2019, 01, 01);
        Boolean isQtyGrtZero = OpportunityScheduleController.sumOpptySchedQtyCheck(JSONStringlstDispOpptySchedTabTest);
        opptyExistsTest = OpportunityScheduleController.saveOpptySchedule(opptyTest.Id, JSONStringlstDispOpptySchedTabTest,opptyTest);
        system.assert(opptyExistsTest.oppValues != null);
        lstDispOpptySchedTabTest= createOpportunitySchedulesWrapper(opptyTest); 
        lstDispOpptySchedTabTest.remove(3);
        lstDispOpptySchedTabTest[0].quarterdate ='2019Q1';
        lstDispOpptySchedTabTest[1].quarterdate ='2019Q2';
        lstDispOpptySchedTabTest[2].quarterdate ='2019Q3';
        OpportunitySchedulingWrapper.OpportunityScheduleView dispDta5 = new OpportunitySchedulingWrapper.OpportunityScheduleView();
        dispDta5.quantities = 100;
        dispDta5.comment ='abc';
        dispDta5.quarterdate='2019Q4';
        dispDta5.oppValues = opptyTest;
        lstDispOpptySchedTabTest.add(dispDta5);
        String JSONStringlstDispOpptySchedTabTestNew = JSON.serialize(lstDispOpptySchedTabTest);
        Boolean isQtyGrtZeroisTrue = OpportunityScheduleController.sumOpptySchedQtyCheck(JSONStringlstDispOpptySchedTabTestNew);
        opptyExistsTest = OpportunityScheduleController.saveOpptySchedule(opptyTest.Id, JSONStringlstDispOpptySchedTabTestNew,opptyTest);
        system.assert(opptyExistsTest.oppValues != null);
        Test.StopTest();
    }
    
    //Test method to check if Production date change align in different quarter
    static testmethod void OpptySchedulePageDateCheckTestCase1() 
    {
        setup();
        Test.StartTest();
        Date oldDate = opptyTest.Production_Date__c;
        String stgOldDate = string.valueOf(oldDate);
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        Boolean isSameqtr = OpportunityScheduleController.checkIfSameQuarterProdDateChange(stgProdDateTest, stgOldDate);
        system.assert(isSameqtr == false);
        Test.StopTest();
    }
    
    //Test method to check if Production date change align in same quarter
    static testmethod void OpptySchedulePageDateCheckTestCase2() 
    {
        setup();
        Test.StartTest();
        Date oldDate = opptyTest.Production_Date__c;
        String stgOldDate = string.valueOf(oldDate);
        Date ProdDateTest = Date.newInstance(2016, 01, 30);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        Boolean isSameqtr = OpportunityScheduleController.checkIfSameQuarterProdDateChange(stgProdDateTest, stgOldDate);
        system.assert(isSameqtr == true);
        Test.StopTest();
    }
    
    //Test method for Re-Establish function
    static testmethod void OpptyScheduleReestablishTestCase1() 
    {
        setup();
        Test.StartTest();
        List<OpportunitySchedule__c> lstOpptySched = createOpportunitySchedules(opptyTest);
        Integer CountB4ReEstablish = lstOpptySched.size();
        OpportunityScheduleController.reEstablishOpptySchedules(opptyTest.Id);
        List<OpportunitySchedule__c> lstOpptySchedReEstbd= [Select Id from OpportunitySchedule__c where Opportunity__c =:opptyTest.Id];
        Integer CountAftrReEstablish = lstOpptySchedReEstbd.size();
        system.assert(CountB4ReEstablish != CountAftrReEstablish);
        Test.StopTest();
    }
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // To test to display the Oppty Prod Schedules when the there is initial load
    static testmethod void OpptyProdSchedInitTestCase1() 
    {
        setup();
        createOpptyProdSchedulesetup();
        Test.StartTest();
        opptyProdSchedInitTest = OpportunityScheduleController.getOpptyLineItemValuesClass(opptyTest.Id);
        system.assert(opptyProdSchedInitTest != null);
        Test.StopTest();
    }
    
   // To test if there are no Oppty Schedules hence direct to step1:Oppty Schedule Page
    static testmethod void OpptyProdSchedLineItemOnChangeTestCase1() 
    {
        setup();
        createOpptyProdSchedulesetup();
        Test.StartTest();
        opptyTest.StageName='Commitment';
        update opptyTest;
        lstopptyProdSchedView = OpportunityScheduleController.getOpptyProdSchedDisplayClass(opptyTest.Id,prods[1].Id);
        system.assert(lstopptyProdSchedView != null);
        Test.StopTest();
    }
    
    //To test if to Update the records
        static testmethod void OpptyProdSchedUpdateTestCase1() 
    {
        setup();
        createOpptyProdSchedulesetup();
        OpportunitySchedulingWrapper.OpptyProdSchedSave opptyProdSchedTest;
        Test.StartTest();
        String JSONStringlstDispOpptyProdSchedTabTest = JSON.serialize(lstopptyProdSchedView);
        Boolean isSave;
        opptyProdSchedTest = OpportunityScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest,prods[0].Id);
        System.assert(opptyProdSchedTest.isOpptyProdSchedSave == true);
        lstopptyProdSchedView = OpportunityScheduleController.getUpdatedForeCastValue(opptyTest.Id,prods[0].Id);
        System.assert(lstopptyProdSchedView!=null);
        opptyProdSchedTest = OpportunityScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest,prods[0].Id);
        System.assert(opptyProdSchedTest.isOpptyProdSchedSave == true);
        Test.StopTest();
    }

    //Test method to update the default display save function for Oppty Prod Schedules.
      static testmethod void OpptyProdSchedUpdateTestCase2() 
    {
        setup();
        createOpptyProdSchedulesetup();
        OpportunitySchedulingWrapper.OpptyProdSchedSave opptyProdSchedTest;        
        Test.StartTest();        
        lstopptyProdSchedView = OpportunityScheduleController.getOpptyProdSchedDisplayClass(opptyTest.Id,prods[0].Id);
        for(OpportunitySchedulingWrapper.OppotunityProductScheduleView oppProSchWrap : lstopptyProdSchedView){
         oppProSchWrap.oliRecord = olis[0];
        }
        String JSONStringlstDispOpptyProdSchedTabTest = JSON.serialize(lstopptyProdSchedView);
        Boolean isSave;
        opptyProdSchedTest = OpportunityScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest,null);
        System.assert(opptyProdSchedTest.isOpptyProdSchedSave == false);// As the prod price and share values are null hence the validation fails and will not update the records.
        Test.StopTest();
    }
        
    //Test method to validate the data if share or price value is not met as defined.
      static testmethod void OpptyProdSchedUpdateTestCase3() 
    {
        setup();
        createOpptyProdSchedulesetup();
        OpportunitySchedulingWrapper.OpptyProdSchedSave opptyProdSchedTest;                
        Test.StartTest();
        for(OpportunitySchedulingWrapper.OppotunityProductScheduleView oppProSchWrap : lstopptyProdSchedView){
         oppProSchWrap.oliRecord = olis[0];
        }
        lstopptyProdSchedView[0].prodShare =0;
        String JSONStringlstDispOpptyProdSchedTabTest = JSON.serialize(lstopptyProdSchedView);
        Boolean isSave;
        opptyProdSchedTest = OpportunityScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest, null);
        System.assert(opptyProdSchedTest.isOpptyProdSchedSave == false);
        Test.StopTest();
    }

  //Test method to check if no Update if there is no change in the valsues of Prod Share and Schedule price.  
       static testmethod void OpptyProdSchedUpdateTestCase4() 
    {
        setup();
        createOpptyProdSchedulesetup();
        OpportunitySchedulingWrapper.OpptyProdSchedSave opptyProdSchedTest;                        
        Test.StartTest();
        lstopptyProdSchedView = OpportunityScheduleController.getOpptyProdSchedDisplayClass(opptyTest.Id,prods[1].Id);
        String JSONStringlstDispOpptyProdSchedTabTest = JSON.serialize(lstopptyProdSchedView);
        Boolean isSave;
        opptyProdSchedTest = OpportunityScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest, null);
        System.assert(opptyProdSchedTest.isOpptyProdSchedSave == false);
        Test.StopTest();
    }
    
    
     static testmethod void OpptyTMMAOverrideReestablishTestCase1() 
    {
        
        Test.StartTest();
        setup();
        opptyTestModelN = new Opportunity(
            Name = 'Test Oppty MN',
            RecordTypeId = MN_RECORD_TYPE_ID,
            AccountId = childAcct.Id,
            StageName = STAGE_NAME,
            CurrencyIsoCode = CCY_CODE_DEFAULT,
            Production_Date__c = PRODUCTION_DATE,
            CloseDate = PRODUCTION_DATE - 30,
            One_Year_Pieces__c =4            
        );
        insert opptyTestModelN;
        List<OpportunitySchedule__c> lstOpptySchedBeforeReEstbd= [Select Id from OpportunitySchedule__c where Opportunity__c =:opptyTestModelN.Id];
        Integer CountB4ReEstablish = lstOpptySchedBeforeReEstbd.size();
        Opportunity opptyTmmaCheckB4 = [Select Id, TMMA_Override__c From Opportunity where Id=:opptyTestModelN.Id];
        OpportunityScheduleController.reEstablishOpptySchedules(opptyTestModelN.Id);
        List<OpportunitySchedule__c> lstOpptySchedAfterReEstbd= [Select Id from OpportunitySchedule__c where Opportunity__c =:opptyTestModelN.Id];
        Integer CountAftrReEstablish = lstOpptySchedAfterReEstbd.size();
        system.assert(CountB4ReEstablish != CountAftrReEstablish);
        Test.StopTest();
        Opportunity opptyTmmaCheckAftr = [Select Id, TMMA_Override__c From Opportunity where Id=:opptyTestModelN.Id];
        system.assert(opptyTmmaCheckAftr.TMMA_Override__c== true);
    }
 
    // Test method to catch the exception while save operation on Oppty Schedule
    static testmethod void OpptyScheduleEditSaveExceptionTestCase1() 
    {
        setup();
        opptyTest.OwnerId = u.Id;
        update opptyTest;
        createOpptyProdSchedulesetup();
        olis[0].Component_Multiplier__c = 0;
        update olis;
        Test.StartTest();
        System.runAs(u){
        Opportunity ownerOppty = [Select Id from Opportunity where OwnerId =: u.id];
        system.assert(ownerOppty != null);
        Date ProdDateTest = Date.newInstance(2019, 04, 30);
        Date ExpCloseDateTest = Date.newInstance(2019, 04, 15);
        String stgProdDateTest = string.valueOf(ProdDateTest);
        String stgExpCloseDateTest = string.valueOf(ExpCloseDateTest);
        String stglstWrp;           
        lstDispOpptySchedTabTest = OpportunityScheduleController.getOpportunityScheduleDisplayValues(ownerOppty.Id, 4, 1000,stgProdDateTest,stgExpCloseDateTest,stglstWrp,false);
        String JSONStringlstDispOpptySchedTabTest = JSON.serialize(lstDispOpptySchedTabTest);
        opptyTest.Production_Date__c = Date.newInstance(2017, 01, 01);    
        try {
         opptyExistsTest = OpportunityScheduleController.saveOpptySchedule(ownerOppty.Id, JSONStringlstDispOpptySchedTabTest,opptyTest);
         system.assert(opptyExistsTest.isOpptySchedule == true);
         }
        catch(Exception e){
                system.assert(e.getMessage()!=null);
                system.assert(opptyExistsTest == null);  
        }   
        }
        Test.StopTest();
    }  
    
    // Test method to catch the exception while save operation on Oppty Product Schedule
    static testmethod void OpptyProdSchedSaveExceptionTestCase1() 
    {
        setup();
        createOpptyProdSchedulesetup();
        Test.StartTest();
        opptyTest.StageName='Commitment';
        update opptyTest;
        lstopptyProdSchedView = OpportunityScheduleController.getOpptyProdSchedDisplayClass(opptyTest.Id,prods[1].Id);
        system.assert(lstopptyProdSchedView != null);   
        OpportunitySchedulingWrapper.OpptyProdSchedSave opptyProdSchedTest;
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
        dispDta2.quarterdate='2016Q1';
        dispDta2.oppValues = opptyTest; 
        dispDta2.oliRecord =olis[1];
        lstopptyProdSchedView.add(dispDta2);
        String JSONStringlstDispOpptyProdSchedTabTest = JSON.serialize(lstopptyProdSchedView);
        Boolean isSave;
        try{
        opptyProdSchedTest = OpportunityScheduleController.updateDWOpptyProdSchedule(opptyTest.Id,JSONStringlstDispOpptyProdSchedTabTest,prods[0].Id);
        System.assert(opptyProdSchedTest.isOpptyProdSchedSave == false);
        }
        catch(Exception e){
          system.assert(e.getMessage()!=null);
          system.assert(opptyProdSchedTest == null);   
        }
            
        Test.StopTest();
    }

}