/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
private class OpportunityScheduleTest {
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
    private static final Double PRICE_EROSION_RATE = 5;
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
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
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
    private static final Integer NEW_SCHED_QTY = 5000;
    
    private static List<Opportunity> opptyList;
    private static Opportunity opptyOpen;
    private static Opportunity opptyWon;
    private static OpportunityLineItem opptyProdSfdc;
    private static OpportunitySchedule__c opptySchedSfdc;
    private static Set<ID> opptyProdSchedIDs = new Set<ID>();
    
    static{
        SFDC_RECORD_TYPE_ID = OpportunitiesSelector.getSfdcRecordTypeId();
        MN_RECORD_TYPE_ID = OpportunitiesSelector.getMnRecordTypeId();
        fetchAccountRecordTypes();
        
     }
    
    @testSetup
    static void setup(){
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
        List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_USD, Currency_Code__c = CCY_CODE_USD, CurrencyIsoCode = CCY_CODE_USD, Exchange_Rate__c = EXCH_RATE_USD));
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_EUR, Currency_Code__c = CCY_CODE_EUR, CurrencyIsoCode = CCY_CODE_EUR, Exchange_Rate__c = EXCH_RATE_EUR));
        insert fxrs;
        
        Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
        fxRates.put(CCY_CODE_USD, fxrs.get(0));
        fxRates.put(CCY_CODE_EUR, fxrs.get(1));
        
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
        List<Product2> prods = new List<Product2>();
        
        for (Integer i = 0; i < 4; i++) {
            Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
                prods.add(new Product2(Name = 'Test Product' + i, MAG__c = MAG_SHORT_LIVED, IsActive = true));
            } else {
                prods.add(new Product2(Name = 'Test Product' + i, MAG__c = MAG_LIFETIME, IsActive = true));
            }            
        }
        insert prods;
        
        Test.startTest();
        createOpportunityProducts(SFDC_RECORD_TYPE_ID, u, fxRates, childAcc, STAGE_NAME, prods);
        createOpportunityProducts(SFDC_RECORD_TYPE_ID, u, fxRates, childAcc, STAGE_WON, prods);
        Test.stopTest();
    }

    static void createOpportunityProducts(ID recordTypeID, User u, Map<String, FX_Rates__c> fxRates, Account a, String opptyStageName, List<Product2> prods){   
        // Insert SFDC Opportunity        
        Opportunity oppty = new Opportunity(
            Name = 'Test Oppty',
            RecordTypeId = recordTypeID,
            AccountId = a.Id,
            Industry_Segment__c = 'AFC',
            StageName = opptyStageName,
            CurrencyIsoCode = CCY_CODE_EUR,
            Production_Date__c = PRODUCTION_DATE,
            CloseDate = PRODUCTION_DATE - 30
        );

        insert oppty;
        
        // Insert an OpportunityShare record
        OpportunityShare os = new OpportunityShare();
        os.OpportunityId = oppty.Id; 
        os.OpportunityAccessLevel = 'Edit';
        os.UserOrGroupId = u.Id;
        insert os;  
        
        createOpportunitySchedules(oppty);
        
        List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id in :prods and CurrencyIsoCode = :CCY_CODE_EUR];
        
        // Insert opportunity products
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        
        for (PricebookEntry pbe : pbes) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id);
            oli.UnitPrice = UNIT_PRICE;
            oli.Component_Multiplier__c = COMP_MULT;
            oli.Legacy_1_Year_Prod__c = ONE_YEAR_PROD; 
            oli.Share__c = SHARE;
            oli.Price_Erosion_Rate__c = PRICE_EROSION_RATE;
            olis.add(oli);
        }
        
        insert olis;       

        //createOpportunityProdSchedules(oppty, olis);
    }

    static void createOpportunitySchedules(Opportunity oppty) {
        List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
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
    }
    
    @isTest
    static void testOpptySchedFrozenOpptySchedQty(){    
        OpportunitySchedule__c opptySchedOpen;
        OpportunitySchedule__c opptySchedWon;
        List<OpportunitySchedule__c> opptyScheds;
        List<OpportunitySchedule__c> opptySchedsUpdated = new List<OpportunitySchedule__c>();
        Map<ID, OpportunitySchedule__c> opptySchedOpptySchedQtyAndFrozenOpptySchedQty;
        
        opptyOpen = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_NAME
        ];
        
        opptyWon = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_WON
        ];
        
        opptySchedOpen = [
            SELECT  Id, Opportunity__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
            FROM    OpportunitySchedule__c
            WHERE   Opportunity__c = :opptyOpen.Id
            LIMIT   1
        ];
        
        opptySchedWon = [
            SELECT  Id, Opportunity__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
            FROM    OpportunitySchedule__c
            WHERE   Opportunity__c = :opptyWon.Id
            LIMIT   1
        ];

        // Update Opportunity Schedule
        opptySchedOpen.Oppty_Sched_Qty__c = SCHED_QTY;
        opptySchedsUpdated.add(opptySchedOpen);
        
        opptySchedWon.Oppty_Sched_Qty__c = SCHED_QTY;
        opptySchedsUpdated.add(opptySchedWon);
        
        update opptySchedsUpdated;
        
        opptyScheds = new List<OpportunitySchedule__c>{opptySchedOpen, opptySchedWon};
        opptySchedOpptySchedQtyAndFrozenOpptySchedQty = getOpptySchedOpptySchedQtyAndFrozenOpptySchedQty(opptyScheds);
                
        system.assertEquals(SCHED_QTY, opptySchedOpptySchedQtyAndFrozenOpptySchedQty.get(opptySchedOpen.Id).Oppty_Sched_Qty__c);
        system.assertEquals(SCHED_QTY, opptySchedOpptySchedQtyAndFrozenOpptySchedQty.get(opptySchedOpen.Id).Frozen_Oppty_Sched_Qty__c);
        system.assertEquals(SCHED_QTY, opptySchedOpptySchedQtyAndFrozenOpptySchedQty.get(opptySchedWon.Id).Oppty_Sched_Qty__c);
        system.assertEquals(opptySchedWon.Frozen_Oppty_Sched_Qty__c, opptySchedOpptySchedQtyAndFrozenOpptySchedQty.get(opptySchedWon.Id).Frozen_Oppty_Sched_Qty__c);
    }
    
    @isTest
    static void testCreateOpportunityProductSchedule(){ // create new Oppty Prod Sched when new oppty sched is created
        Decimal unitPrice;
        Decimal priceErosionRate;
        Integer schedIndex;
        Date schedDate;
        Integer numberDaysBetween;
        Map<ID, OpportunitySchedule__c> opptySchedSchedDate;
        List<OpportunityLineItem> opptyProdsOpen;
        List<OpportunitySchedule__c> opptyScheds;
        List<OpportunitySchedule__c> opptySchedsAll;
        List<OpportunityProductSchedule__c> opptyProdSchedsNew;
        List<OpportunityProductSchedule__c> opptyProdSchedList;
        Set<ID> opptyProdIDs = new Set<ID>();
        Set<ID> opptyIDs = new Set<ID>();
        
        Map<ID, List<OpportunityProductSchedule__c>> opptySchedAndOpptyProdSchedList = new Map<ID, List<OpportunityProductSchedule__c>>();
        
        Map<ID, List<OpportunityProductSchedule__c>> opptyProdAndOpptyProdSched = new Map<ID, List<OpportunityProductSchedule__c>>();
        
        opptyOpen = [
            SELECT  Id,
                    StageName,
                    CurrencyIsoCode
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_NAME
        ];
        
        opptyIDs.add(opptyOpen.Id);
        
        opptyProdsOpen = [
            SELECT  Id, OpportunityId, Opportunity.Production_Date__c, UnitPrice, Price_Erosion_Rate__c 
            FROM    OpportunityLineItem 
            WHERE   OpportunityId = :opptyOpen.Id
        ];
       
        for (OpportunityLineItem opptyProd : opptyProdsOpen){
            opptyProdIDs.add(opptyProd.Id);
        }
        
        OpportunitySchedule__c newOpptySched = new OpportunitySchedule__c(
            Opportunity__c = opptyOpen.Id,
            Sched_Date__c = Date.newInstance(2200, 01, 01),
            Oppty_Sched_Qty__c = 1500,
            Frozen_Oppty_Sched_Qty__c = 1500
        );
        insert newOpptySched;
        
        opptyScheds = new List<OpportunitySchedule__c>{newOpptySched};
        opptySchedSchedDate = getOpptySchedSchedDate(opptyScheds);

        opptyProdSchedsNew = [
            SELECT  Id, Opportunity__c, Sched_Date__c, Oppty_Prod_ID_Full__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c, 
                    Prod_Sched_Price__c, Frozen_Prod_Sched_Price__c, CurrencyIsoCode
            FROM    OpportunityProductSchedule__c
            WHERE   Opportunity__c = :opptyOpen.Id AND Oppty_Prod_ID_Full__c in :opptyProdIDs AND Sched_Date__c = :opptySchedSchedDate.get(newOpptySched.Id).Sched_Date__c
        ];
        
        system.assertEquals(opptyProdsOpen.size(), opptyProdSchedsNew.size());
 
        for (OpportunityProductSchedule__c opptyProdSchedNew : opptyProdSchedsNew) {
            system.assertEquals(newOpptySched.Oppty_Sched_Qty__c, opptyProdSchedNew.Oppty_Sched_Qty__c);
            system.assertEquals(newOpptySched.Oppty_Sched_Qty__c, opptyProdSchedNew.Frozen_Oppty_Sched_Qty__c);
        }
        
        opptyProdAndOpptyProdSched = getOpptyProdAndOpptyProdSched(opptyIDs, opptyProdsOpen);
        
        for (OpportunityLineItem opptyProd : opptyProdsOpen) {
            unitPrice = opptyProd.UnitPrice;
            priceErosionRate = opptyProd.Price_Erosion_Rate__c;
            
            if (opptyProdAndOpptyProdSched.containsKey(opptyProd.Id)) {
                opptyProdSchedList = opptyProdAndOpptyProdSched.get(opptyProd.Id);
                
                schedIndex = 0;
                
                for (OpportunityProductSchedule__c opptyProdSched : opptyProdSchedList) {
                    system.assertEquals(OpportunityLineItems.calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, schedIndex),
                        opptyProdSched.Prod_Sched_Price__c);
                    system.assertEquals(OpportunityLineItems.calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, schedIndex),
                        opptyProdSched.Frozen_Prod_Sched_Price__c);         
                        
                    system.assertEquals(opptyOpen.CurrencyIsoCode, opptyProdSched.CurrencyIsoCode);     
                    
                    schedIndex++;
                }
            }
        }
    }
    
    @isTest
    static void testDeleteOneOpptySched(){
        Opportunity opptySfdc;
        OpportunitySchedule__c opptySchedDeleted;
        List<OpportunityProductSchedule__c> opptyProdSchedDeleted;
        List<OpportunitySchedule__c> opptySchedsAll;
        List<OpportunityLineItem> opptyProdsOpen;
        List<OpportunityProductSchedule__c> opptyProdSchedList;
        Set<ID> opptyIDs = new Set<ID>();
        Map<ID, List<OpportunityProductSchedule__c>> opptyProdAndOpptyProdSched = new Map<ID, List<OpportunityProductSchedule__c>>();
        Decimal unitPrice;
        Decimal priceErosionRate;
        Integer schedIndex;
        
        opptySfdc = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_NAME
        ];
        
        opptyIDs.add(opptySfdc.Id);
        
        opptyProdsOpen = [
            SELECT  Id, OpportunityId, Opportunity.Production_Date__c, UnitPrice, Price_Erosion_Rate__c 
            FROM    OpportunityLineItem 
            WHERE   OpportunityId = :opptySfdc.Id
        ];
        
        opptySchedDeleted = [
            SELECT  Id, Opportunity__c, Sched_Date__c 
            FROM    OpportunitySchedule__c
            WHERE   Opportunity__c = :opptySfdc.Id 
            ORDER BY Sched_Date__c DESC LIMIT 1
        ];
        
        delete opptySchedDeleted;
        
        opptyProdSchedDeleted = [
            SELECT  Id, Opportunity__c, Sched_Date__c, Oppty_Prod_ID_Full__c 
            FROM    OpportunityProductSchedule__c
            WHERE   Opportunity__c =: opptySfdc.Id AND Sched_Date__c = :opptySchedDeleted.Sched_Date__c
        ];
        
        system.assertEquals(0, opptyProdSchedDeleted.size());
        
        opptySchedsAll = [
            SELECT  Id, Sched_Date__c, Opportunity__c
            FROM    OpportunitySchedule__c
            WHERE   Opportunity__c = :opptySfdc.Id 
            ORDER BY Sched_Date__c ASC
        ];
        
        opptyProdAndOpptyProdSched = getOpptyProdAndOpptyProdSched(opptyIDs, opptyProdsOpen);
        
        for (OpportunityLineItem opptyProd : opptyProdsOpen) {
            unitPrice = opptyProd.UnitPrice;
            priceErosionRate = opptyProd.Price_Erosion_Rate__c;
            
            if (opptyProdAndOpptyProdSched.containsKey(opptyProd.Id)) {
                opptyProdSchedList = opptyProdAndOpptyProdSched.get(opptyProd.Id);
                
                schedIndex = 0;
                
                for (OpportunityProductSchedule__c opptyProdSched : opptyProdSchedList) {
                    system.assertEquals(OpportunityLineItems.calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, schedIndex),
                        opptyProdSched.Prod_Sched_Price__c);
                    system.assertEquals(OpportunityLineItems.calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, schedIndex),
                        opptyProdSched.Frozen_Prod_Sched_Price__c);                 
                    
                    schedIndex++;
                }
            }
        }
    }
    
    @isTest
    static void testOpportunityProductScheduleOpptySchedQtyAndFrozenOpptySchedQty(){
        OpportunitySchedule__c opptySchedOpen;
        OpportunitySchedule__c opptySchedWon;
        List<OpportunitySchedule__c> opptySchedsUpdated;
        Map<ID, OpportunitySchedule__c> opptySchedOpptySchedQtyAndFrozenOpptySchedQty;
        Map<Id, Map<Id, OpportunityProductSchedule__c>> opptySchedAndOpptyProdSched;
        
        opptyOpen = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_NAME
            LIMIT   1
        ];
        
        opptyWon = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_WON
            LIMIT   1
        ];
        
        opptySchedOpen = [
            SELECT  Id, Opportunity__c, Opportunity__r.StageName, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
            FROM    OpportunitySchedule__c
            WHERE   Opportunity__c = :opptyOpen.Id
            ORDER BY Sched_Date__c
            LIMIT   1
        ];
        
        opptySchedWon = [
            SELECT  Id, Opportunity__c, Opportunity__r.StageName, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
            FROM    OpportunitySchedule__c
            WHERE   Opportunity__c = :opptyWon.Id
            ORDER BY Sched_Date__c
            LIMIT   1
        ];
        
        opptySchedOpen.Oppty_Sched_Qty__c = NEW_SCHED_QTY;
        opptySchedWon.Oppty_Sched_Qty__c = NEW_SCHED_QTY;
        opptySchedWon.Frozen_Oppty_Sched_Qty__c = NEW_SCHED_QTY;

        opptySchedsUpdated = new List<OpportunitySchedule__c>{opptySchedOpen, opptySchedWon};
        update opptySchedsUpdated;
        
        opptySchedOpptySchedQtyAndFrozenOpptySchedQty = getOpptySchedOpptySchedQtyAndFrozenOpptySchedQty(opptySchedsUpdated);
        opptySchedAndOpptyProdSched = getOpptySchedAndOpptyProdSched(opptySchedsUpdated);
        
        for (OpportunitySchedule__c opptySchedUpdated : opptySchedsUpdated) {
            for (ID opptyProdSchedID : opptyProdSchedIDs) {
                if (opptySchedAndOpptyProdSched.get(opptySchedUpdated.Id).ContainsKey(opptyProdSchedID)) {
                    // Before DW
                    if (opptySchedUpdated.Opportunity__r.StageName != STAGE_WON) {
                        if (opptySchedUpdated.Sched_Date__c == opptySchedAndOpptyProdSched.get(opptySchedUpdated.Id).get(opptyProdSchedID).Sched_Date__c) {
                            system.assertEquals(opptySchedOpptySchedQtyAndFrozenOpptySchedQty.get(opptySchedUpdated.Id).Oppty_Sched_Qty__c, 
                                                opptySchedAndOpptyProdSched.get(opptySchedUpdated.Id).get(opptyProdSchedID).Oppty_Sched_Qty__c);
                            system.assertEquals(opptySchedOpptySchedQtyAndFrozenOpptySchedQty.get(opptySchedUpdated.Id).Oppty_Sched_Qty__c, 
                                                opptySchedAndOpptyProdSched.get(opptySchedUpdated.Id).get(opptyProdSchedID).Frozen_Oppty_Sched_Qty__c);
                        }
                    }
                    
                    // After DW
                    if (opptySchedUpdated.Opportunity__r.StageName == STAGE_WON) {
                        if (opptySchedUpdated.Sched_Date__c == opptySchedAndOpptyProdSched.get(opptySchedUpdated.Id).get(opptyProdSchedID).Sched_Date__c) {
                            system.assertEquals(opptySchedOpptySchedQtyAndFrozenOpptySchedQty.get(opptySchedUpdated.Id).Oppty_Sched_Qty__c, 
                                                opptySchedAndOpptyProdSched.get(opptySchedUpdated.Id).get(opptyProdSchedID).Oppty_Sched_Qty__c);
                            system.assertEquals(opptySchedOpptySchedQtyAndFrozenOpptySchedQty.get(opptySchedUpdated.Id).Frozen_Oppty_Sched_Qty__c, 
                                                opptySchedAndOpptyProdSched.get(opptySchedUpdated.Id).get(opptyProdSchedID).Frozen_Oppty_Sched_Qty__c);
                        } 
                    }
                }
            }
        }
    }

    @isTest
    static void testUpdateOpptyProdSchedShedDate(){
        Opportunity opptySfdc;
        OpportunitySchedule__c opptySchedUpdated;
        List<OpportunitySchedule__c> opptySchedUpdatedList;
        List<OpportunityProductSchedule__c> opptyProdSchedUpdatedList;
        OpportunityProductSchedule__c opptyProdSchedBeforeUpdated;
        OpportunityProductSchedule__c opptyProdSchedUpdated;
        Map<ID, OpportunitySchedule__c> opptySchedSchedDate = new Map<ID, OpportunitySchedule__c>();
        Map<ID, OpportunityProductSchedule__c> opptyProdSchedSchedDate = new  Map<ID, OpportunityProductSchedule__c>();
        
        opptySfdc = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_NAME
        ];
        
        opptySchedUpdated = [
            SELECT  Id, Opportunity__c, Sched_Date__c 
            FROM    OpportunitySchedule__c
            WHERE   Opportunity__c = :opptySfdc.Id
            ORDER BY Sched_Date__c ASC LIMIT 1
        ];
        
        opptyProdSchedBeforeUpdated = [
            SELECT  Id, Sched_Date__c
            FROM    OpportunityProductSchedule__c
            WHERE   Opportunity__c = :opptySfdc.Id AND Sched_Date__c = :opptySchedUpdated.Sched_Date__c
            LIMIT   1
        ];
        
        opptySchedUpdated.Sched_Date__c = PRODUCTION_DATE + 10;
        update opptySchedUpdated;
        
        opptySchedUpdatedList = new List<OpportunitySchedule__c>{opptySchedUpdated};
        opptySchedSchedDate = getOpptySchedSchedDate(opptySchedUpdatedList);
        
        system.assertEquals(PRODUCTION_DATE + 10, opptySchedSchedDate.get(opptySchedUpdated.Id).Sched_Date__c);
        
        opptyProdSchedUpdatedList = new List<OpportunityProductSchedule__c>{opptyProdSchedBeforeUpdated};
        opptyProdSchedSchedDate = getOpptyProdSchedSchedDate(opptyProdSchedUpdatedList);
        
        system.assertEquals(opptySchedSchedDate.get(opptySchedUpdated.Id).Sched_Date__c, opptyProdSchedSchedDate.get(opptyProdSchedBeforeUpdated.Id).Sched_Date__c);
    }

    static Map<ID, OpportunitySchedule__c> getOpptySchedOpptySchedQtyAndFrozenOpptySchedQty(List<OpportunitySchedule__c> opptyScheds){
        Set<ID> opptySchedIDs = new Set<ID>();
        
        for (OpportunitySchedule__c opptySched : opptyScheds) {
            opptySchedIDs.add(opptySched.Id);
        }
        
        Map<ID, OpportunitySchedule__c> result = new Map<ID, OpportunitySchedule__c>(
            [SELECT Id, Opportunity__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c
             FROM   OpportunitySchedule__c
             WHERE  Id = :opptySchedIDs
            ]
        );
        
        return result;
    }
    
    static OpportunitySchedule__c getOpptySchedOpptySchedQty(Id opptySchedId){
        OpportunitySchedule__c result = [
            SELECT  Id, Opportunity__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
            FROM    OpportunitySchedule__c
            WHERE   Id = :opptySchedId
        ];

        return result;
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
    
    static Map<ID, OpportunitySchedule__c> getOpptySchedSchedDate(List<OpportunitySchedule__c> opptyScheds){
        Set<ID> opptySchedIDs = new Set<ID>();
        
        for (OpportunitySchedule__c opptySched : opptyScheds) {
            opptySchedIDs.add(opptySched.Id);
        }
        
        Map<ID, OpportunitySchedule__c> result = new Map<ID, OpportunitySchedule__c>(
            [SELECT Id, Sched_Date__c 
             FROM   OpportunitySchedule__c 
             WHERE  Id in :opptySchedIDs]
        );
        
        return result;        
    }
    
    static Map<ID, OpportunityProductSchedule__c> getOpptyProdSchedSchedDate(List<OpportunityProductSchedule__c> opptyProdScheds){
        Set<ID> opsIDs = new Set<ID>();
        
        for (OpportunityProductSchedule__c opptyProdSched : opptyProdScheds) {
            opsIDs.add(opptyProdSched.Id);
        }
        
        Map<ID, OpportunityProductSchedule__c> result = new Map<ID, OpportunityProductSchedule__c>(
            [SELECT Id, Sched_Date__c 
             FROM   OpportunityProductSchedule__c 
             WHERE  Id in :opsIDs]
        );
        
        return result;        
    }
    
    private static Map<Id, Map<Id, OpportunityProductSchedule__c>> getOpptySchedAndOpptyProdSched(List<OpportunitySchedule__c> opptySchedsDeleted){
        Set<ID> opptyIDs = new Set<ID>();
        // Opporunity Schedule Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        Map<Id, Map<Id, OpportunityProductSchedule__c>> result = new Map<Id, Map<Id, OpportunityProductSchedule__c>>();
        List<OpportunityProductSchedule__c> opptyOpptyScheds;
        opptyProdSchedIDs = new Set<ID>();
        
        for(OpportunitySchedule__c opptySchedDeleted : opptySchedsDeleted) {
            opptyIDs.add(opptySchedDeleted.Opportunity__c);
        }
        
        opptyOpptyScheds = [
            SELECT  Id, Opportunity__c, Oppty_Prod_ID_Full__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c
            FROM    OpportunityProductSchedule__c 
            WHERE   Opportunity__c in :opptyIDs
        ];
        
        for(OpportunitySchedule__c opptySchedDeleted : opptySchedsDeleted) {
            for (OpportunityProductSchedule__c opptyProdSched : opptyOpptyScheds) {
                opptyProdSchedIDs.add(opptyProdSched.Id);     
                
                if(opptySchedDeleted.Opportunity__c == opptyProdSched.Opportunity__c && opptySchedDeleted.Sched_Date__c == opptyProdSched.Sched_Date__c){
                    if (result.containsKey(opptySchedDeleted.Id)) {
                        result.get(opptySchedDeleted.Id).put(opptyProdSched.Id, opptyProdSched);
                    }
                    else {
                        result.put(opptySchedDeleted.Id, new Map<ID, OpportunityProductSchedule__c> {opptyProdSched.Id => opptyProdSched});
                    }
                }
            }
        }
        
        return result;
    }
    
    private static Map<ID, List<OpportunityProductSchedule__c>> getOpptyProdAndOpptyProdSched(Set<ID> opptyIDs, List<OpportunityLineItem> opptyProds){
        Map<ID, List<OpportunityProductSchedule__c>> result = new Map<ID, List<OpportunityProductSchedule__c>>();
        List<OpportunityProductSchedule__c> opptyProdScheds;

        opptyProdScheds = [
            SELECT  Id, Opportunity__c, Oppty_Prod_ID_Full__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c, Prod_Sched_Price__c, Frozen_Prod_Sched_Price__c, CurrencyIsoCode
            FROM    OpportunityProductSchedule__c 
            WHERE   Opportunity__c in :opptyIDs
            Order By Sched_Date__c ASC
        ];
        
        for (OpportunityLineItem opptyProd : opptyProds) {
            for (OpportunityProductSchedule__c opptyProdSched : opptyProdScheds) {
                if (opptyProd.Id == opptyProdSched.Oppty_Prod_ID_Full__c) {
                    if (result.containsKey(opptyProd.Id)) {
                        result.get(opptyProd.Id).add(opptyProdSched);
                    }
                    else {
                        result.put(opptyProd.Id, new List<OpportunityProductSchedule__c> {opptyProdSched});
                    }
                }
            }
        }
        
        return result;
    }
}