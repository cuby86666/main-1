/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
private class OpportunityProductTest {
    private static final String TYPE_PARENT_ACC = 'Parent_Account'; 
    private static final String TYPE_CHILD_ACC = 'Child_Account';
    private static final ID SFDC_RECORD_TYPE_ID;
    private static final ID MN_RECORD_TYPE_ID;
    private static ID PARENT_RECORD_TYPE_ID;
    private static ID CHILD_RECORD_TYPE_ID;
    private static final String TEST_USER_PROFILE = 'Standard User';
    private static final String TEST_USER_EMAIL = 'testuser@testorg.com.test';
    private static final String TEST_SYSTEM_ADMIN_EMAIL = 'testsystemadmin@testorg.com.test';
    private static final String TEST_INTEGRATION_USER_EMAIL = 'testintegrationuser@testorg.com.test';
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    private static final String CBG_NON_AUTOMOTIVE = 'Non-Automotive';
    private static final String CBG_DEFAULT = CBG_NON_AUTOMOTIVE; // @default
    private static final String MAG_SHORT_LIVED;
    private static final String MAG_LIFETIME;
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
    private static final Double ONE_YEAR_PROD = 1500;
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final String PROD_LOST = 'Lost';
    private static final String PROD_CANCELLED = 'Cancelled';
    private static final String STAGE_NAME = 'Initial Engagement';
    private static final String STAGE_WON = 'Commitment';
    private static final String OPPTY_LOST = 'Lost';
    private static final String OPPTY_CANCELLED = 'Cancelled';
    private static final String OPPTY_PROD_LOST = 'Lost';
    private static String DW_APPROVAL_STATUS_OPEN = 'Open';
    private static String DW_APPROVAL_STATUS_LOST = 'Lost';
    private static final Double SHARE = 100;
    private static final Double NEW_SHARE = 80;
    private static final Integer NUM_Q = 12;
    
    private static List<Opportunity> opptyList;
    private static Opportunity opptySfdc;
    private static Opportunity opptyMn;
    private static Opportunity opptyOpen;
    private static Opportunity opptyWon;
    private static OpportunityLineItem opptyProdSfdc;
    private static OpportunityLineItem opptyProdMn;
    
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
        
        // Insert system admin
        User systemAdmin = new User(
            Alias = 'test',
            Email = TEST_SYSTEM_ADMIN_EMAIL,
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = CommonUtils.getSystemAdminProfileID(), 
            UserName = TEST_SYSTEM_ADMIN_EMAIL
        );
        insert systemAdmin;
        
        // Insert integration user
        User integrationUser = new User(
            Alias = 'test',
            Email = TEST_INTEGRATION_USER_EMAIL,
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = CommonUtils.getIntegrationUserProfileID(), 
            UserName = TEST_INTEGRATION_USER_EMAIL
        );
        insert integrationUser;    
        
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
        createSfdcOpportunityProducts(u, fxRates, childAcc, STAGE_NAME, prods);
        createSfdcOpportunityProducts(u, fxRates, childAcc, STAGE_WON, prods);
        createMnOpportunityProducts(u, fxRates, childAcc, OPPTY_LOST, prods);
        Test.stopTest();
    }

    static void createSfdcOpportunityProducts(User u, Map<String, FX_Rates__c> fxRates, Account a, String opptyStageName, List<Product2> prods){   
        // Insert SFDC Opportunity        
        Opportunity oppty = new Opportunity(
            Name = 'Test Oppty',
            RecordTypeId = OpportunitiesSelector.getSfdcRecordTypeId(),
            AccountId = a.Id,
            StageName = opptyStageName,
            CurrencyIsoCode = CCY_CODE_DEFAULT,
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
        
        List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id in :prods and CurrencyIsoCode = :CCY_CODE_DEFAULT];
        
        // Insert opportunity products
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        
        for (PricebookEntry pbe : pbes) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id);
            oli.UnitPrice = UNIT_PRICE;
            oli.Component_Multiplier__c = COMP_MULT;
            oli.Legacy_1_Year_Prod__c = ONE_YEAR_PROD; 
            oli.Share__c = SHARE;
            olis.add(oli);
        }
        
        insert olis;       
    }
    
    static void createMnOpportunityProducts(User u, Map<String, FX_Rates__c> fxRates, Account a, String opptyStageName, List<Product2> prods){
        // Insert Mn Opportunity
        Opportunity oppty = new Opportunity(
            Name = 'Test Oppty',
            RecordTypeId = OpportunitiesSelector.getMnRecordTypeId(),
            AccountId = a.Id,
            StageName = opptyStageName,
            CurrencyIsoCode = CCY_CODE_DEFAULT,
            Production_Date__c = PRODUCTION_DATE,
            CloseDate = PRODUCTION_DATE - 30,
            One_Year_Pieces__c = 1000
        );
        
        if (opptyStageName == OPPTY_LOST) {
            oppty.Expiration_Date__c = Date.today();
            oppty.Lost_Reason__c = 'Lost';
            oppty.Lost_Description__c = 'Lost Description';
        }

        insert oppty;
        
        // Insert an OpportunityShare record
        OpportunityShare os = new OpportunityShare();
        os.OpportunityId = oppty.Id; 
        os.OpportunityAccessLevel = 'Edit';
        os.UserOrGroupId = u.Id;
        insert os;  
        
        PricebookEntry pbe = [select Id from PricebookEntry where Product2Id in :prods and CurrencyIsoCode = :CCY_CODE_DEFAULT LIMIT 1];

        // Insert Opportunity Product
        OpportunityLineItem opptyProd = new OpportunityLineItem(
            OpportunityId = oppty.Id,
            PricebookEntryId = pbe.Id,
            UnitPrice = UNIT_PRICE,
            Component_Multiplier__c = COMP_MULT,
            Legacy_1_Year_Prod__c = ONE_YEAR_PROD, 
            Share__c = SHARE
        );
        
        insert opptyProd;    
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
    static void testOpptyProdSchedShareAndFrozenShare(){
        Map<ID, Opportunity> opptys = new Map<ID, Opportunity>();
        List<OpportunityLineItem> opptyProds;
        List<OpportunityProductSchedule__c> opptyProdScheds;
       
        opptyProdSfdc = [
            SELECT  Id, Share__c, OpportunityId 
            FROM    OpportunityLineItem 
            WHERE   Opportunity.RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND 
                    Opportunity.StageName = :STAGE_NAME 
            LIMIT   1
        ];
        
        system.assertEquals(SHARE, opptyProdSfdc.Share__c);
        
        // Update Share of Opportunity Product. (Before Design Win)
        opptyProdSfdc.Share__c = NEW_SHARE;
        update opptyProdSfdc;
        system.assertEquals(NEW_SHARE, opptyProdSfdc.Share__c);

        opptyProds = new List<OpportunityLineItem>{opptyProdSfdc};
        opptys = getOppty(OpportunitiesSelector.getSfdcRecordTypeId(), opptyProds);
        opptyProdScheds = getOpptyProdScheds(opptyProds);
        
        for(OpportunityProductSchedule__c opptyProdSched : opptyProdScheds){
            system.assertEquals(NEW_SHARE, opptyProdSched.Share__c);
            system.assertEquals(NEW_SHARE, opptyProdSched.Frozen_Share__c);
        }
        
        // Update Opportunity Stage to Commitment
        opptySfdc = opptys.get(opptyProdSfdc.OpportunityId);
        opptySfdc.StageName = STAGE_WON;
        update opptySfdc;
   
        system.assertEquals(STAGE_WON, opptySfdc.StageName);
        
        // Update Opportunity Product Share. (After Design Win)
        opptyProdSfdc.Share__c = SHARE;
        update opptyProdSfdc;
        
        system.assertEquals(SHARE, opptyProdSfdc.Share__c);
        
        opptyProdScheds = getOpptyProdScheds(opptyProds);
        
        for(OpportunityProductSchedule__c opptyProdSched : opptyProdScheds){
            system.assertEquals(NEW_SHARE, opptyProdSched.Share__c);
            system.assertEquals(SHARE, opptyProdSched.Frozen_Share__c);
        }
    }
    
    @isTest
    static void testOpptyProdSchedQtyPerSys(){
        Map<ID, Opportunity> opptys = new Map<ID, Opportunity>();
        List<OpportunityLineItem> opptyProds;
        List<OpportunityProductSchedule__c> opptyProdScheds;
       
        opptyProdSfdc = [
            SELECT  Id, Component_Multiplier__c, OpportunityId
            FROM    OpportunityLineItem 
            WHERE   Opportunity.RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND 
                    Opportunity.StageName = :STAGE_NAME 
            LIMIT   1
        ];
        
        system.assertEquals(COMP_MULT, opptyProdSfdc.Component_Multiplier__c);
        
        // Update Componet Multiplier of Opportunity Product
        opptyProdSfdc.Component_Multiplier__c = NEW_COMP_MULT;
        update opptyProdSfdc;
        system.assertEquals(NEW_COMP_MULT, opptyProdSfdc.Component_Multiplier__c);
        
        opptyProds = new List<OpportunityLineItem>{opptyProdSfdc};
        opptyProdScheds = getOpptyProdScheds(opptyProds);
        
        for(OpportunityProductSchedule__c opptyProdSched : opptyProdScheds){
            system.assertEquals(NEW_COMP_MULT, opptyProdSched.Qty_Per_Sys__c);
        }
    }
    
    @isTest
    static void testUpdateOpptyProdSchedPrice(){
        Decimal unitPrice;
        Decimal priceErosionRate;
        Integer schedDateIndex;
        Date productionDate;
        Date schedDate;
        Integer numberDaysBetween;
        OpportunityLineItem opptyProdOpen;
        OpportunityLineItem opptyProdWon;
        List<OpportunityLineItem> opptyProds;
        List<OpportunityLineItem> opptyProdUpdated;
        List<OpportunityProductSchedule__c> opptyProdScheds;
        Map<ID, OpportunityLineItem> opptyProdPriceAndPriceErosion = new Map<ID, OpportunityLineItem>();
        
        opptyOpen = [
            SELECT  Id,
                    StageName,
                    Production_Date__c
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
        
        opptyProdOpen = [
            SELECT  Id, OpportunityId, Opportunity.StageName, Opportunity.Production_Date__c, UnitPrice, Price_Erosion_Rate__c 
            FROM    OpportunityLineItem 
            WHERE   OpportunityId = :opptyOpen.Id
            LIMIT   1
        ];

        opptyProdWon = [
            SELECT  Id, OpportunityId, Opportunity.StageName, Opportunity.Production_Date__c, UnitPrice, Price_Erosion_Rate__c 
            FROM    OpportunityLineItem 
            WHERE   OpportunityId = :opptyWon.Id
            LIMIT   1
        ];
        
        opptyProdOpen.UnitPrice = UNIT_PRICE + 1.5;
        opptyProdWon.UnitPrice = UNIT_PRICE + 1.5;
        
        opptyProds = new List<OpportunityLineItem>{opptyProdOpen, opptyProdWon};
        update opptyProds;
        
        opptyProdPriceAndPriceErosion = getOpptyProdPriceAndPriceErosion(opptyProds);
        opptyProdScheds = getOpptyProdSchedSchedPriceAndFrozenProdSchedPrice(opptyProds);
        
        for (OpportunityLineItem opptyProd : opptyProds) {
            if (opptyProd.Opportunity.StageName != STAGE_WON) { 
                for (OpportunityProductSchedule__c opptyProdSched : opptyProdScheds) {
                    if (opptyProdSched.Oppty_Prod_ID_Full__c == opptyProd.Id) {
                        unitPrice = opptyProdPriceAndPriceErosion.get(opptyProd.Id).UnitPrice;
                        priceErosionRate = opptyProdPriceAndPriceErosion.get(opptyProd.Id).Price_Erosion_Rate__c;
                        productionDate = opptyProd.Opportunity.Production_Date__c;
                        schedDate = opptyProdSched.Sched_Date__c;
                        numberDaysBetween = productionDate.daysBetween(schedDate);
                        schedDateIndex = (Integer)Math.floor((Integer)Math.ceil(numberDaysBetween / 30) / 3);
                        
                        system.assertEquals(OpportunityLineItems.calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, schedDateIndex), opptyProdSched.Prod_Sched_Price__c);
                        system.assertEquals(OpportunityLineItems.calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, schedDateIndex), opptyProdSched.Frozen_Prod_Sched_Price__c);
                        
                        break;
                    }
                }
                
                if (opptyProd.Opportunity.StageName != STAGE_WON) { 
                    for (OpportunityProductSchedule__c opptyProdSched : opptyProdScheds) {
                        if (opptyProdSched.Oppty_Prod_ID_Full__c == opptyProd.Id) {
                            unitPrice = opptyProdPriceAndPriceErosion.get(opptyProd.Id).UnitPrice;
                            priceErosionRate = opptyProdPriceAndPriceErosion.get(opptyProd.Id).Price_Erosion_Rate__c;
                            productionDate = opptyProd.Opportunity.Production_Date__c;
                            schedDate = opptyProdSched.Sched_Date__c;
                            numberDaysBetween = productionDate.daysBetween(schedDate);
                            schedDateIndex = (Integer)Math.floor((Integer)Math.ceil(numberDaysBetween / 30) / 3);
                            
                            system.assertEquals(OpportunityLineItems.calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, schedDateIndex), 
                                                opptyProdSched.Frozen_Prod_Sched_Price__c);
                            
                            break;
                        }
                    }
                }
            }
        }
    }
    
    @isTest
    static void testDeleteAllOpptyProdScheds(){
        OpportunityLineItem opptyProd;
        List<OpportunityLineItem> opptyProds;
        List<OpportunityProductSchedule__c> opptyProdScheds;
        
        opptySfdc = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_NAME
            LIMIT   1
        ];
        
        opptyProdSfdc = [
            SELECT  Id
            FROM    OpportunityLineItem 
            WHERE   OpportunityId = :opptySfdc.Id
            LIMIT   1
        ];
        
        delete opptyProdSfdc;
        
        opptyProdScheds = [
            SELECT Id, Opportunity__c, Oppty_Prod_ID_Full__c 
            FROM OpportunityProductSchedule__c 
            WHERE Opportunity__c = :opptySfdc.Id AND Oppty_Prod_ID_Full__c = :opptyProdSfdc.Id
        ];
        
        system.assertEquals(0, opptyProdScheds.size());
    }

    @isTest
    static void testUpdateSfdcOpptyProdLostCancelledInfo(){
        Map<ID, OpportunityLineItem> opptyProdLostCancelledInfo= new Map<ID, OpportunityLineItem>();
        List<OpportunityLineItem> opptyProds;

        opptySfdc = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_NAME
            LIMIT   1
        ];
        
        opptyProdSfdc = [
            SELECT  Id,
                    Prod_Lost_Cancelled__c, 
                    Prod_Lost_Cancelled_Date__c, 
                    Prod_Lost_Reason__c,
                    Prod_Lost__c // Prod_Lost__c will be obsoleted in the near future
            FROM    OpportunityLineItem 
            WHERE   OpportunityId = :opptySfdc.Id
            LIMIT   1
        ];
        
        system.assertEquals(null, opptyProdSfdc.Prod_Lost_Cancelled_Date__c);
        
        opptyProdSfdc.Prod_Lost_Cancelled__c = OPPTY_PROD_LOST;
        opptyProdSfdc.Prod_Lost_Reason__c = 'Test Lost Cancelled Reason';
        update opptyProdSfdc;
        
        opptyProds = new List<OpportunityLineItem>{opptyProdSfdc};
        opptyProdLostCancelledInfo = getOpptyProdLostCancelledInfo(opptyProds);
        
        system.assertEquals(date.today(), opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost_Cancelled_Date__c);
        system.assertEquals(true, opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost__c);// Prod_Lost__c will be obsoleted in the near future
        
        opptyProdSfdc.Prod_Lost_Cancelled__c = null;
        update opptyProdSfdc;
    
        opptyProds = new List<OpportunityLineItem>{opptyProdSfdc};
        opptyProdLostCancelledInfo = getOpptyProdLostCancelledInfo(opptyProds);
        
        system.assertEquals(null, opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost_Cancelled_Date__c);
        system.assertEquals(null, opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost_Reason__c);
        system.assertEquals(false, opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost__c);// Prod_Lost__c will be obsoleted in the near future
    }
    
    @isTest
    static void testLastBusinessModifiedInfo(){
        Map<ID, OpportunityLineItem> opptyProdLastBusinessInfo = new Map<ID, OpportunityLineItem>();
        List<OpportunityLineItem> opptyProdsUpdated;
        
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :TEST_USER_PROFILE LIMIT 1];
        User admin = [SELECT Id FROM User WHERE ProfileId = :CommonUtils.getSystemAdminProfileID() AND isActive = true LIMIT 1];
        User igUser = [SELECT Id FROM User WHERE ProfileId = :CommonUtils.getIntegrationUserProfileID() AND isActive = true LIMIT 1];
    
        opptySfdc = [
            SELECT  Id, Last_Business_Modified_By_Id__c, Last_Business_Modified_Date__c
            FROM    Opportunity
            LIMIT 1
        ];
        
        opptyProdSfdc = [SELECT Id, LastUpdatedById__c, LastUpdatedDate__c FROM OpportunityLineItem LIMIT 1];
        
        system.assertNotEquals(null, opptyProdSfdc.LastUpdatedById__c);
        system.assertNotEquals(null, opptyProdSfdc.LastUpdatedDate__c);  
        
        system.runAs(testUser) {
            update opptyProdSfdc;
        }
        
        opptyProdsUpdated = new List<OpportunityLineItem>{opptyProdSfdc};
        opptyProdLastBusinessInfo = getOpptyProdLastBusinessInfo(opptyProdsUpdated);
        
        system.assertEquals(testUser.Id, opptyProdLastBusinessInfo.get(opptyProdSfdc.Id).LastUpdatedById__c);
        
        system.runAs(admin) {
            update opptyProdSfdc;
        }
    }
    
    @isTest
    static void testDeleteLostCancelledOpptyProdScheds(){
        List<OpportunityLineItem> opptyprods;
        List<OpportunityProductSchedule__c> opptyProdScheds;
        
        opptySfdc = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_NAME
            LIMIT   1
        ];
        
        opptyProdSfdc = [
            SELECT  Id,
                    Prod_Lost_Cancelled__c, 
                    Prod_Lost_Cancelled_Date__c, 
                    Prod_Lost_Reason__c,
                    OpportunityId
            FROM    OpportunityLineItem 
            WHERE   OpportunityId = :opptySfdc.Id AND Prod_Lost_Cancelled__c != 'Lost' AND Prod_Lost_Cancelled__c != 'Cancelled'
            LIMIT   1
        ];
        
        opptyprods = new List<OpportunityLineItem>{opptyProdSfdc};
        opptyProdScheds = getOpptyProdScheds(opptyprods);
        
        system.assert(opptyProdScheds.size() > 0);
        
        opptyProdSfdc.Prod_Lost_Cancelled__c = 'Lost';
        update opptyProdSfdc;
        
        opptyprods = new List<OpportunityLineItem>{opptyProdSfdc};
        opptyProdScheds = getOpptyProdScheds(opptyprods);
        
        system.assert(opptyProdScheds.size() == 0);
    }
    
    @isTest
    static void testCreateOpptyProdSchedsForReOpenOpptyProd(){
        List<OpportunityLineItem> opptyprods;
        List<OpportunityProductSchedule__c> opptyProdScheds;
        
        opptySfdc = [
            SELECT  Id,
                    StageName
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND
                    StageName =: STAGE_NAME
            LIMIT   1
        ];
        
        opptyProdSfdc = [
            SELECT  Id,
                    Prod_Lost_Cancelled__c, 
                    Prod_Lost_Cancelled_Date__c, 
                    Prod_Lost_Reason__c,
                    OpportunityId
            FROM    OpportunityLineItem 
            WHERE   OpportunityId = :opptySfdc.Id AND Prod_Lost_Cancelled__c != 'Lost' AND Prod_Lost_Cancelled__c != 'Cancelled'
            LIMIT   1
        ];

        opptyProdSfdc.Prod_Lost_Cancelled__c = 'Lost';
        update opptyProdSfdc;
        
        opptyprods = new List<OpportunityLineItem>{opptyProdSfdc};
        opptyProdScheds = getOpptyProdScheds(opptyprods);
        
        system.assert(opptyProdScheds.size() == 0);
        
        opptyProdSfdc.Prod_Lost_Cancelled__c = null;
        update opptyProdSfdc;
        
        opptyprods = new List<OpportunityLineItem>{opptyProdSfdc};
        opptyProdScheds = getOpptyProdScheds(opptyprods);
        
        system.assert(opptyProdScheds.size() > 0);
    }
    
    @isTest
    static void testMnOpptyProdDefaultLostCancelledInfo(){
        Map<ID, Opportunity> opptyLostCancelledInfo = new Map<ID, Opportunity>();
        List<OpportunityLineItem> opptyProds;
        
        opptyProdMn = [
            SELECT  Id,
                    Prod_Lost__c,
                    Prod_Lost_Cancelled__c,
                    Prod_Lost_Cancelled_Date__c,
                    Prod_Lost_Reason__c,
                    Prod_Lost_Cancelled_Reason__c,
                    Opportunity.Lost_Date__c,
                    Opportunity.Lost_Description__c,
                    Opportunity.Lost_Reason__c
            FROM    OpportunityLineItem 
            WHERE   Opportunity.RecordTypeId = :OpportunitiesSelector.getMnRecordTypeId() AND Opportunity.StageName = :OPPTY_LOST
            LIMIT   1
        ];
        
        opptyProds = new List<OpportunityLineItem>{opptyProdMn};
        opptyLostCancelledInfo = getOpptyLostCancelledInfo(opptyProds);
        
        system.assert(opptyProdMn != null);
        system.assertEquals(true, opptyProdMn.Prod_Lost__c);
        system.assertEquals(opptyLostCancelledInfo.get(opptyProdMn.OpportunityId).Lost_Date__c, opptyProdMn.Prod_Lost_Cancelled_Date__c);
        system.assertEquals(opptyLostCancelledInfo.get(opptyProdMn.OpportunityId).Lost_Reason__c, opptyProdMn.Prod_Lost_Cancelled_Reason__c);
    }
    
    @isTest
    static void testMnOpptyProdLostCancelledInfo() {
    	final Date EXP_DATE = Date.newInstance(1970, 01, 01);
    	 
    	Test.startTest();
    	Opportunity oppty = (Opportunity)new OpportunitiesSelector().selectWhere('Opportunity.RecordTypeId = \'' + OpportunitiesSelector.getMnRecordTypeId() + '\' and Opportunity.StageName = \'' + OPPTY_LOST + '\'').get(0);
    	oppty.StageName = Opportunities.STAGE_DISCOVERY;
    	oppty.Lost_Date__c = EXP_DATE;
    	update oppty;
    	
    	oppty = new OpportunitiesSelector().selectById(new Set<Id> {oppty.Id}).get(0);
    	oppty.StageName = Opportunities.STAGE_LOST;
    	update oppty;
    	Test.stopTest();
    	
    	OpportunityLineItem opptyProd = new OpportunityLineItemsSelector().selectByOpptyIdWithOpportunity(new Set<Id> {oppty.Id}).get(0);
    	System.assertEquals(EXP_DATE, opptyProd.Prod_Lost_Cancelled_Date__c);	
    }
    
    @isTest
    static void testOpptyProdSchedCurrency(){
        Test.startTest();
        Opportunity oppty = [
            select Id, StageName
              from Opportunity
             where RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() 
               and StageName = :STAGE_NAME        
        ];
        
        List<OpportunityLineItem> opptyProds = [select Id from OpportunityLineItem where OpportunityId = :oppty.Id];
        
        delete opptyProds;
        
        oppty.CurrencyIsoCode = CCY_CODE_EUR;
        update oppty;
        
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true); 
        insert prod;
        
        PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :prod.Id and CurrencyIsoCode = :CCY_CODE_EUR limit 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppty.Id, PricebookEntryId = pbe.Id);
        oli.UnitPrice = UNIT_PRICE;
        oli.Component_Multiplier__c = COMP_MULT;
        insert oli;
        Test.stopTest();
        
        OpportunityProductSchedule__c opptyProdSched = [
            select CurrencyIsoCode 
              from OpportunityProductSchedule__c 
             where Opportunity__c = :oppty.Id 
               and Oppty_Prod_ID_Full__c = :oli.Id
            limit 1
        ];
        
        System.assertEquals(CCY_CODE_EUR, opptyProdSched.CurrencyIsoCode);
    }
    
    static Map<ID,  Opportunity> getOppty(ID RecordTypeID, List<OpportunityLineItem> opptyProds){
        Set<ID> opptyIDs = new Set<ID>();
        
        for(OpportunityLineItem opptyProd : opptyProds){
            opptyIDs.add(opptyProd.OpportunityId);
        }
        
        Map<ID, Opportunity> result = new Map<ID, Opportunity>(
            [SELECT Id, StageName FROM Opportunity 
             WHERE RecordTypeId = :RecordTypeID AND Id in :opptyIDs]
        );
        
        return result;
    }
    
    static List<OpportunityProductSchedule__c> getOpptyProdScheds(List<OpportunityLineItem> opptyProds){
        Set<ID> opptyProdIDs = new Set<ID>();
        
        for(OpportunityLineItem opptyProd : opptyProds){
            opptyProdIDs.add(opptyProd.Id);
        }
        
        Set<ID> opptyIDs = getOpptyIDs(opptyProds);
        
        List<OpportunityProductSchedule__c> result = [
            SELECT  Id, Share__c, Frozen_Share__c, Qty_Per_Sys__c 
            FROM    OpportunityProductSchedule__c 
            WHERE   Opportunity__c in :opptyIDs
            AND     Oppty_Prod_ID_Full__c in :opptyProdIDs
        ];
        
        return result;
    }
    
    static Map<ID, OpportunityLineItem> getOpptyProdPriceAndPriceErosion(List<OpportunityLineItem> opptyProds){
        Set<ID> oliIDs = new Set<ID>();
        
        for (OpportunityLineItem opptyProd : opptyProds) {
            oliIDs.add(opptyProd.Id);
        }
        
        Map<ID, OpportunityLineItem> result = new Map<ID, OpportunityLineItem>(
            [SELECT Id, UnitPrice, Price_Erosion_Rate__c 
             FROM OpportunityLineItem 
             WHERE Id in :oliIDs]
        );
        
        return result;
    }
    
    static List<OpportunityProductSchedule__c> getOpptyProdSchedSchedPriceAndFrozenProdSchedPrice(List<OpportunityLineItem> opptyProds){
        Set<ID> oliIDs = new Set<ID>();
        
        for (OpportunityLineItem opptyProd : opptyProds) {
            oliIDs.add(opptyProd.Id);
        }
        
        Set<ID> opptyIDs = getOpptyIDs(opptyProds);
        
        List<OpportunityProductSchedule__c> result = [
             SELECT Id, Sched_Date__c, Oppty_Prod_ID_Full__c, Prod_Sched_Price__c, Frozen_Prod_Sched_Price__c 
             FROM   OpportunityProductSchedule__c
             WHERE  Opportunity__c in :opptyIDs
             AND    Oppty_Prod_ID_Full__c in :oliIDs
        ];
        
        return result;
    }
    
    static Map<ID, OpportunityLineItem> getOpptyProdLostCancelledInfo(List<OpportunityLineItem> opptyProds){
        Set<ID> oliIDs = new Set<ID>();
        
        for (OpportunityLineItem opptyProd : opptyProds) {
            oliIDs.add(opptyProd.Id);
        }
        
        Map<ID, OpportunityLineItem> result = new Map<ID, OpportunityLineItem>(
            [SELECT Id, Prod_Lost_Cancelled__c, Prod_Lost_Cancelled_Date__c, Prod_Lost_Reason__c, Prod_Lost__c // Prod_Lost__c will be obsoleted in the near future
             FROM OpportunityLineItem 
             WHERE Id in :oliIDs]
        );
        
        return result;
    }
    
    static Map<ID, OpportunityLineItem> getOpptyProdLastBusinessInfo(List<OpportunityLineItem> opptyProds){
        Set<ID> oliIDs = new Set<ID>();
        Map<ID, OpportunityLineItem> result = new Map<ID, OpportunityLineItem>();
        
        for (OpportunityLineItem opptyProd : opptyProds) {
            oliIDs.add(opptyProd.Id);
        }
        
        result = new Map<ID, OpportunityLineItem>([
            SELECT Id, LastUpdatedById__c, LastUpdatedDate__c
            FROM OpportunityLineItem
            WHERE Id in :oliIDs
        ]);
        
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
    
    private static Map<ID, Opportunity> getOpptyLostCancelledInfo(List<OpportunityLineItem> opptyProds){
        Set<ID> opptyIDs = new Set<ID>();
        
        for (OpportunityLineItem opptyProd : opptyProds) {
            opptyIDs.add(opptyProd.OpportunityId);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id,
                    RecordTypeId,
                    StageName,
                    Lost_Date__c,
                    Lost_Description__c,
                    Lost_Reason__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    }
    
    private static Set<Id> getOpptyIds(List<OpportunityLineItem> opptyLineItems) {
    	Set<Id> result = new Set<Id>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
            result.add(oli.OpportunityId);
        }
        
        return result;
    }
}