/**
 *  Modified by: Balaji G
 *  For: Release 2016.9 SIR# 958 
 *  Description: Adjusted test data to comply with validation rule - Competitor, Loss/Cancelled Reason and
 *               Description required for Lost/Cancelled Opportunities
 */
@isTest
private class OpportunityProductClaimValueTest {
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
    private static final Double ONE_YEAR_PIECES = 1500;
    private static final Double LOCKED_EXCHANGE_RATE = 1.5;
    private static final Double CLAIM_VALUE_MN = ((UP_CM * ONE_YEAR_PIECES) / LOCKED_EXCHANGE_RATE); // SIR 1069: Change from 3 years to 1 year
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final String PROD_LOST = 'Lost';
    private static final String PROD_CANCELLED = 'Cancelled';
        
    private static List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
    private static List<OpportunityLineItem> opptyProdsMN = new List<OpportunityLineItem>();
    private static OpportunityLineItem opptyProd;
    private static OpportunityLineItem opptyProdLT;
    private static OpportunityLineItem opptyProdMN;
    
    // TMMA
    private static final Date EXPECTED_CLOSE_DATE = PRODUCTION_DATE - 60;
    
    static {
        Opportunity_Claim_Value_MAG_Setting__mdt claimValueMagSetting = 
            [select MAG__c 
               from Opportunity_Claim_Value_MAG_Setting__mdt 
              where Claim_Value_Quarters__c != 'Lifetime'
                and IsActive__c = true
              limit 1];
        
        MAG_SHORT_LIVED = claimValueMagSetting.MAG__c;
        MAG_DEFAULT = MAG_SHORT_LIVED; // @default
       
        claimValueMagSetting = 
            [select MAG__c 
               from Opportunity_Claim_Value_MAG_Setting__mdt 
              where Claim_Value_Quarters__c = 'Lifetime'
                and IsActive__c = true
              limit 1];
        
        MAG_LIFETIME = claimValueMagSetting.MAG__c;     
        
        List<OpportunityLineItem> olis =
            [select Id, OpportunityId, Claim_Value_USD__c,
            		Price_Erosion_Rate__c, Share__c, MAG__c,
                    Prod_Lost_Cancelled__c, Lost_Cancelled_Claim_Value_USD__c, Lost_Cancelled_LT_Value_USD__c,
                    Opportunity.RecordTypeId, Opportunity.Production_Date__c,
                    Opportunity.Account.CMD_Industry_Segment__c,
                    Product2.MAG__c, PricebookEntry.Product2.MAG__c
               from OpportunityLineItem]; 
        
        for (OpportunityLineItem oli : olis) {
            if (oli.opportunity.RecordTypeId == OpportunitiesSelector.getSfdcRecordTypeId()) {
                opptyProds.add(oli);    
            } else if (oli.opportunity.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId()) {
                opptyProdsMN.add(oli);
            }
        }
        
        for (OpportunityLineItem oli : opptyProds) {
            if (oli.MAG__c == MAG_DEFAULT) {
                opptyProd = oli;
            } 
            
            if (oli.MAG__c == MAG_LIFETIME) {
            	opptyProdLT = oli;
            }
        }
        
        for (OpportunityLineItem oli : opptyProdsMN) {
            if (oli.MAG__c == MAG_DEFAULT) {
                opptyProdMN = oli;
                break;
            }
        }
        
        if (opptyProd != null) {
            Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
            CLAIM_VALUE_SHORT_LIVED = getOpportunityClaimValue(oppty, new Set<ID>{opptyProd.Id});
            CLAIM_VALUE_DEFAULT = CLAIM_VALUE_SHORT_LIVED; // @default (CBG_AUTOMOTIVE ? CLAIM_VALUE_LIFETIME : CLAIM_VALUE_SHORT_LIVED)
        }
    }
    
    @testSetup
    static void setup() {
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
        createOpportunityProducts(OpportunitiesSelector.getSfdcRecordTypeId(), u, fxRates, a, prods);
        Test.stopTest();
        
        createOpportunityProducts(OpportunitiesSelector.getMnRecordTypeId(), u, fxRates, a, prods);
    }
    
    static void createOpportunityProducts(ID recordTypeID, User u, Map<String, FX_Rates__c> fxRates, Account a, List<Product2> prods) {
        // Insert an opportunity
        Opportunity o;
        
        if (recordTypeID == OpportunitiesSelector.getMnRecordTypeId()) {
        	o = new Opportunity(Name = 'Test Oppty', AccountId = a.Id, StageName = 'Initial Engagement'); //Todo: Not set AccountId for code coverage	
        } else {
        	o = new Opportunity(Name = 'Test Oppty', AccountId = a.Id, StageName = 'Initial Engagement');
        }
        
        o.RecordTypeId = recordTypeID;
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = PRODUCTION_DATE - 60;
        o.Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE; // Enabled for MN type, hidden for SFDC type. Admin can edit it no matter what type it is.
        o.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        o.One_Year_Pieces__c= ONE_YEAR_PIECES;
        o.Bypass_Validation_Sched_Start_Date__c = true;
        insert o;
        
        if (recordTypeID == OpportunitiesSelector.getSfdcRecordTypeId()) {
        	// For direct oppty, oppty scheds are manually created.
        	createOpportunitySchedules(o);	
        } 
        
        System.debug('//J ========== after insert oppty');
        
        // Insert an OpportunityShare record
        OpportunityShare os = new OpportunityShare();
        os.OpportunityId = o.Id; 
        os.OpportunityAccessLevel = 'Edit';
        os.UserOrGroupId = u.Id;
        insert os;
         
        List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id in :prods and CurrencyIsoCode = :CCY_CODE_DEFAULT];
        
        // Insert opportunity products
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        
        for (PricebookEntry pbe : pbes) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pbe.Id);
            oli.UnitPrice = UNIT_PRICE;
            oli.Component_Multiplier__c = COMP_MULT;
            oli.Price_Erosion_Rate__c = 0;
            oli.Share__c = 100;
            olis.add(oli);
        }
        
        insert olis;
        
        System.debug('//J ========== after insert oppty prods');    
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
    static void testOpptyProdClaimValueDefault() {
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(CLAIM_VALUE_DEFAULT, opptyProdClaimValues.get(opptyProd.Id).Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyProdClaimValueInvalidMAG() {
        // It will not throw an exception in the context of tests.
        String mag = '_MAG_'; 
        Product2 prod = new Product2(Name = 'Test Product', MAG__c = mag, IsActive = true); 
        insert prod;
        
        PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :prod.Id and CurrencyIsoCode = :CCY_CODE_DEFAULT limit 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyProd.OpportunityId, PricebookEntryId = pbe.Id);
        oli.UnitPrice = UNIT_PRICE;
        oli.Component_Multiplier__c = COMP_MULT;
        
        Test.startTest();
        insert oli;
        Test.stopTest();
        
        opptyProd = [select Id from OpportunityLineItem where MAG__c = :mag];
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(CLAIM_VALUE_LIFETIME, opptyProdClaimValues.get(opptyProd.Id).Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyProdClaimValueAccountChanged() {
        // Change Account.CMD_Industry_Segment__c (CBG) should not change claim value.
        opptyProd.Opportunity.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
        
        Test.startTest();
        update opptyProd.Opportunity.Account;
        update opptyProd.Opportunity;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(CLAIM_VALUE_DEFAULT, opptyProdClaimValues.get(opptyProd.Id).Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyProdClaimValueAccountIsNull() {
        opptyProd.Opportunity.AccountId = null;
        
        Test.startTest();
        update opptyProd.Opportunity;
        update opptyProd;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(CLAIM_VALUE_LIFETIME, opptyProdClaimValues.get(opptyProd.Id).Claim_Value_USD__c);
    }
   
    @isTest
    static void testOpptyProdClaimValueProductChanged() {
        Opportunity_Claim_Value_Setting__mdt claimValueSetting = [select Cross_Update_Allowed__c from Opportunity_Claim_Value_Setting__mdt where MasterLabel = 'Setting'];
        Boolean crossUpdateAllowed = claimValueSetting.Cross_Update_Allowed__c; 
        
        opptyProd.Product2.MAG__c = MAG_LIFETIME;
        
        Test.startTest();
        update opptyProd.Product2;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        Double opptyProdClaimValue = opptyProdClaimValues.get(opptyProd.Id).Claim_Value_USD__c;  
        
        if (crossUpdateAllowed) {
            System.assertEquals(CLAIM_VALUE_LIFETIME, opptyProdClaimValue);   
        } else {
            System.assertEquals(CLAIM_VALUE_DEFAULT, opptyProdClaimValue);    
        }
    }
   
    @isTest
    static void testOpptyProdClaimValueProductCancelled() {
        opptyProd.Prod_Lost_Cancelled__c = PROD_CANCELLED;
        opptyProd.Prod_Lost_Cancelled_Reason__c='No Bid';
        opptyProd.Prod_Lost_Reason__c='TEST';
        opptyProd.Competitor__c='TEST';     //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule   
        Test.startTest();
        update opptyProd;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(0, opptyProdClaimValues.get(opptyProd.Id).Claim_Value_USD__c);
        System.assertEquals(CLAIM_VALUE_DEFAULT, opptyProdClaimValues.get(opptyProd.Id).Lost_Cancelled_Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyProdClaimValueProductLost() {
        opptyProd.Prod_Lost_Cancelled__c = PROD_LOST;
        opptyProd.Prod_Lost_Cancelled_Reason__c='Price';
        opptyProd.Prod_Lost_Reason__c='TEST';
        opptyProd.Competitor__c='TEST';            //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule     
                
        Test.startTest();
        update opptyProd;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(0, opptyProdClaimValues.get(opptyProd.Id).Claim_Value_USD__c);
        System.assertEquals(CLAIM_VALUE_DEFAULT, opptyProdClaimValues.get(opptyProd.Id).Lost_Cancelled_Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyProdClaimValueLifetimeProductCancelled() {
        opptyProd.Prod_Lost_Cancelled__c = PROD_CANCELLED;
        opptyProd.Prod_Lost_Cancelled_Reason__c='No Bid';
        opptyProd.Prod_Lost_Reason__c='TEST';
        opptyProd.Competitor__c='TEST';     //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule   
        Test.startTest();
        update opptyProd;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(0, opptyProdClaimValues.get(opptyProd.Id).LT_Value_USD__c);
        System.assertEquals(CLAIM_VALUE_LIFETIME, opptyProdClaimValues.get(opptyProd.Id).Lost_Cancelled_LT_Value_USD__c);
    }
    
    @isTest
    static void testOpptyProdClaimValueLifetimeProductLost() {
        opptyProd.Prod_Lost_Cancelled__c = PROD_LOST;
        opptyProd.Prod_Lost_Cancelled_Reason__c='Price';
        opptyProd.Prod_Lost_Reason__c='TEST';
        opptyProd.Competitor__c='TEST';            //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule     
                
        Test.startTest();
        update opptyProd;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(0, opptyProdClaimValues.get(opptyProd.Id).LT_Value_USD__c);
        System.assertEquals(CLAIM_VALUE_LIFETIME, opptyProdClaimValues.get(opptyProd.Id).Lost_Cancelled_LT_Value_USD__c);
    }
    
    @isTest
    static void testOpptyProdClaimValueMultiProducts1() {
        // One short-lived product, one lifetime product
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>();
        OpportunityLineItem opptyProdShortLived;
        OpportunityLineItem opptyProdLifetime;
        
        for (OpportunityLineItem oli : opptyProds) {
            if (oli.Product2.MAG__c == MAG_SHORT_LIVED && opptyProdShortLived == null) {
                opptyProdShortLived = oli;
                opptyLineItems.add(opptyProdShortLived); 
            } else if (oli.Product2.MAG__c == MAG_LIFETIME && opptyProdLifetime == null) {
                opptyProdLifetime = oli;
                opptyLineItems.add(opptyProdLifetime);
            }
            
            if (opptyLineItems.size() == 2) break;
        }
        
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        Double totalClaimValue = 0;
        
        for (ID olid : opptyProdClaimValues.keySet()) {
            totalClaimValue += opptyProdClaimValues.get(olid).Claim_Value_USD__c;
        }
        
        System.assertEquals(isAuto() ? (CLAIM_VALUE_LIFETIME * 2) : (CLAIM_VALUE_SHORT_LIVED + CLAIM_VALUE_LIFETIME), totalClaimValue);
    }
    
    @isTest
    static void testOpptyProdClaimValueMultiProducts2() {
        // Two short-lived products
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>();
                
        for (OpportunityLineItem oli : opptyProds) {
            if (oli.Product2.MAG__c == MAG_SHORT_LIVED) {
                opptyLineItems.add(oli); 
            } 
            
            if (opptyLineItems.size() == 2) break;
        }
        
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        Double totalClaimValue = 0;
        
        for (ID olid : opptyProdClaimValues.keySet()) {
            totalClaimValue += opptyProdClaimValues.get(olid).Claim_Value_USD__c;
        }
        
        System.assertEquals(isAuto() ? (CLAIM_VALUE_LIFETIME * 2) : (CLAIM_VALUE_SHORT_LIVED * 2), totalClaimValue);
    }
    
    @isTest
    static void testOpptyProdClaimValueMultiProducts3() {
        // Two lifetime products
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>();
                
        for (OpportunityLineItem oli : opptyProds) {
            if (oli.Product2.MAG__c == MAG_LIFETIME) {
                opptyLineItems.add(oli); 
            } 
            
            if (opptyLineItems.size() == 2) break;
        }
        
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        Double totalClaimValue = 0;
        
        for (ID olid : opptyProdClaimValues.keySet()) {
            totalClaimValue += opptyProdClaimValues.get(olid).Claim_Value_USD__c;
        }
        
        System.assertEquals((CLAIM_VALUE_LIFETIME * 2), totalClaimValue);
    }
    
    @isTest
    static void testOpptyProdClaimValueMn() {
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProdMN};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(CLAIM_VALUE_MN, opptyProdClaimValues.get(opptyProdMN.Id).Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyProdClaimValueExchRateChangedMn() {
        Test.startTest();
        Double exchRate = 2.00;
        opptyProdMN.Opportunity.Locked_Exchange_Rate__c = exchRate;
        update opptyProdMN.Opportunity;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProdMN};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals((CLAIM_VALUE_MN * LOCKED_EXCHANGE_RATE / exchRate), opptyProdClaimValues.get(opptyProdMN.Id).Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyProdClaimValueShareChanged() {
        Test.startTest();
        List<OpportunityLineItem> opptyProdsDeleted = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : opptyProds) {
            if (oli !== opptyProd) {
                opptyProdsDeleted.add(oli);
            }
        }
        
        delete opptyProdsDeleted;
        
        opptyProd.Share__c = 50;
        update opptyProd;
        
        opptyProd = [select OpportunityId, Share__c from OpportunityLineItem where Id = :opptyProd.Id];
        
		Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
		Test.stopTest();
        
        System.assertEquals((CLAIM_VALUE_DEFAULT / 2), oppty.Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyClaimValueDefault() {
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        Decimal opptyClaimValue = getOpportunityClaimValue(oppty, getOpptyProdIDs(oppty.Id));
        
        System.assertEquals(opptyClaimValue, oppty.Claim_Value_USD__c); 
    }
    
    @isTest
    static void testOpptyClaimValueMN() {
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProdMN};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        System.assertEquals((CLAIM_VALUE_MN * 4), opptyClaimValues.get(opptyProdMN.OpportunityId).Claim_Value_USD__c);    
    }
    
    @isTest
    static void testOpptyClaimValueOpptyProdAdded() {
        Product2 prod = createShortLivedProduct(); 
        insert prod;
        
        PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :prod.Id and CurrencyIsoCode = :CCY_CODE_DEFAULT limit 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyProd.OpportunityId, PricebookEntryId = pbe.Id);
        oli.UnitPrice = UNIT_PRICE;
        oli.Component_Multiplier__c = COMP_MULT;
        
        Test.startTest();
        insert oli;
        Test.stopTest();
        
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        Decimal opptyClaimValue = getOpportunityClaimValue(oppty, getOpptyProdIDs(oppty.Id));
        
        System.assertEquals(opptyClaimValue, oppty.Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyClaimValueOpptyProdEdited() {
        Double upCM = 0;
        
        for (OpportunityLineItem oli : opptyProds) {
            if (oli.MAG__c == MAG_SHORT_LIVED) {
                oli.UnitPrice = 1;
                oli.Component_Multiplier__c = 2;
                upCM = oli.UnitPrice * oli.Component_Multiplier__c;
                
                Test.startTest();
                update oli;
                Test.stopTest();
                
                break;
            }
        }
        
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        Decimal opptyClaimValue = getOpportunityClaimValue(oppty, getOpptyProdIDs(oppty.Id));
        
        System.assertEquals(opptyClaimValue, oppty.Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyClaimValueOpptyProdDeleted() {
        for (OpportunityLineItem oli : opptyProds) {
            if (oli.MAG__c == MAG_SHORT_LIVED) {
                Test.startTest();
                delete oli;
                Test.stopTest();
                
                break;
            }
        }
        
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        Decimal opptyClaimValue = getOpportunityClaimValue(oppty, getOpptyProdIDs(oppty.Id));
        
        System.assertEquals(opptyClaimValue, oppty.Claim_Value_USD__c); 
    }
    
    @isTest
    static void testOpptyClaimValueOpptyProdAllDeleted() {
        Test.startTest();
        List<OpportunityLineItem> opptyProdsDeleted = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : opptyProds) {
            opptyProdsDeleted.add(oli);    
        }
        
        delete opptyProdsDeleted;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        System.assertEquals(0, opptyClaimValues.get(opptyProd.OpportunityId).Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyClaimValueOpptyProdCancelled() {
        Test.startTest();
        List<OpportunityLineItem> opptyProdsDeleted = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : opptyProds) {
            if (oli !== opptyProd) {
                opptyProdsDeleted.add(oli);
            }
        }
        
        delete opptyProdsDeleted;
        
        opptyProd.Prod_Lost_Cancelled__c = PROD_CANCELLED;
        opptyProd.Prod_Lost_Cancelled_Reason__c='No Bid';
        opptyProd.Prod_Lost_Reason__c='TEST';
        opptyProd.Competitor__c='TEST';          //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule      
        update opptyProd;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        oppty = [select Claim_Value_USD__c, Lost_Cancelled_Claim_Value_USD__c from Opportunity where id = :oppty.Id];
        
        System.assertEquals(0, oppty.Claim_Value_USD__c); 
        System.assertEquals(CLAIM_VALUE_DEFAULT, oppty.Lost_Cancelled_Claim_Value_USD__c); 
    }
    
    @isTest
    static void testOpptyClaimValueOpptyProdLost() {
        List<OpportunityLineItem> opptyProdsDeleted = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : opptyProds) {
            if (oli !== opptyProd) {
                opptyProdsDeleted.add(oli);
            }
        }

		Test.startTest();        
        delete opptyProdsDeleted;
        opptyProd.Prod_Lost_Cancelled__c = PROD_LOST;
        opptyProd.Prod_Lost_Cancelled_Reason__c='Price';
        opptyProd.Prod_Lost_Reason__c='TEST';
        opptyProd.Competitor__c='TEST';              //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule  
        update opptyProd;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        oppty = [select Claim_Value_USD__c, Lost_Cancelled_Claim_Value_USD__c from Opportunity where id = :oppty.Id];
        
        System.assertEquals(0, oppty.Claim_Value_USD__c); 
        System.assertEquals(CLAIM_VALUE_DEFAULT, oppty.Lost_Cancelled_Claim_Value_USD__c); 
    }
    
    @isTest
    static void testOpptyClaimValueOpptySchedDeleted() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        
        OpportunitySchedule__c opptySched = 
        	[select Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c, Sched_Date__c 
        	   from OpportunitySchedule__c 
    		  where Opportunity__c = :oppty.Id
    		    and Sched_Date__c = :Date.newInstance(2030, 10, 01)];
    		    
        delete opptySched;
        Test.stopTest();
        
        oppty = getOpportunity(oppty.Id);
        
        System.assertEquals(((CLAIM_VALUE_SHORT_LIVED * 2) + (CLAIM_VALUE_LIFETIME * 2) - ((300 * 2 * UP_CM) / EXCH_RATE_DEFAULT)), oppty.Claim_Value_USD__c); 	
    }
    
    @isTest
    static void testOpptyClaimValueLifetime() {
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        oppty = [select LT_Value_USD__c from Opportunity where id = :oppty.Id];
        
        System.assertEquals((CLAIM_VALUE_LIFETIME * 4), oppty.LT_Value_USD__c);  
    }
    
    @isTest
    static void testOpptyClaimValueLifetimeOpptyProdCancelled() {
        Test.startTest();
        for (OpportunityLineItem oli : opptyProds) {
            oli.Prod_Lost_Cancelled__c = PROD_CANCELLED;
            oli.Prod_Lost_Cancelled_Reason__c='No Bid';
            oli.Prod_Lost_Reason__c='TEST';
            oli.Competitor__c='TEST';              //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule               
        }
        
        update opptyProds;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        oppty = [select LT_Value_USD__c, Lost_Cancelled_LT_Value_USD__c from Opportunity where id = :oppty.Id];
        
        System.assertEquals(0, oppty.LT_Value_USD__c); 
        System.assertEquals((CLAIM_VALUE_LIFETIME * 4), oppty.Lost_Cancelled_LT_Value_USD__c); 
    }
    
    @isTest
    static void testOpptyClaimValueLifetimeOpptyProdLost() {
        Test.startTest();
        for (OpportunityLineItem oli : opptyProds) {
            oli.Prod_Lost_Cancelled__c = PROD_LOST;
            oli.Prod_Lost_Cancelled_Reason__c='Price';
            oli.Prod_Lost_Reason__c='TEST';
            oli.Competitor__c='TEST';           //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule         
        }
        
        update opptyProds;
        Test.stopTest();
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        oppty = [select LT_Value_USD__c, Lost_Cancelled_LT_Value_USD__c from Opportunity where id = :oppty.Id];
        
        System.assertEquals(0, oppty.LT_Value_USD__c);  
        System.assertEquals((CLAIM_VALUE_LIFETIME * 4), oppty.Lost_Cancelled_LT_Value_USD__c);
    }
    
    @isTest
    static void testOpptyClaimValueQuantityChanged() {
        delete opptyProds;
        
        Product2 prod = createShortLivedProduct(); 
        insert prod;
        
        PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :prod.Id and CurrencyIsoCode = :CCY_CODE_DEFAULT limit 1];
        
        Test.startTest();
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyProd.OpportunityId, PricebookEntryId = pbe.Id);
        oli.UnitPrice = UNIT_PRICE;
        oli.Component_Multiplier__c = COMP_MULT;
        insert oli;
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        
        OpportunitySchedule__c opptySched = 
        	[select Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
        	   from OpportunitySchedule__c 
    		  where Opportunity__c = :oppty.Id
    		    and Sched_Date__c = :Date.newInstance(2016, 04, 01)];
    		    
		opptySched.Oppty_Sched_Qty__c += 1000;
		opptySched.Frozen_Oppty_Sched_Qty__c += 1000;
		update opptySched;
        Test.stopTest();        
        
        update oli;
        
        oppty = getOpportunity(oppty.Id);
        Decimal opptyClaimValue = getOpportunityClaimValue(oppty, new Set<Id>{oli.Id});
        
        System.assertEquals((CLAIM_VALUE_DEFAULT + ((1000 * UP_CM) / EXCH_RATE_DEFAULT)), oppty.Claim_Value_USD__c);  
    }
    
    @isTest
    static void testOpptyClaimValueExchRateChanged() {
        Test.startTest();
        List<OpportunityLineItem> opptyProdsDeleted = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : opptyProds) {
            if (oli !== opptyProd) {
                opptyProdsDeleted.add(oli);
            }
        }
        
        delete opptyProdsDeleted;
        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        Double exchRate = 2;
        FX_Rates__c fxRate = [select Exchange_Rate__c from FX_Rates__c where CurrencyIsoCode = :CCY_CODE_DEFAULT];
        fxRate.Exchange_Rate__c = exchRate;
        update fxRate;
        
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        update oppty; // Testing only. In production, when exchange rate changes in FX_Rates__c, oppty will not change.
        
        oppty = getOpportunity(oppty.Id);
        Decimal opptyClaimValue = getOpportunityClaimValue(oppty, new Set<Id>{opptyProd.Id});
        Test.stopTest();
        
        System.assertEquals(opptyClaimValue, oppty.Claim_Value_USD__c);
    }
    
    @isTest
    static void testOpptyClaimValueExchRateChangedMn() {
        Test.startTest();
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProdMN};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        Double exchRate = 2;
        Opportunity oppty = opptyClaimValues.get(opptyProdMN.OpportunityId);
        oppty.Locked_Exchange_Rate__c = exchRate;
        update oppty;
        
        oppty = [select Claim_Value_USD__c from Opportunity where id = :oppty.Id];
        Test.stopTest();
        
        System.assertEquals(((CLAIM_VALUE_MN * LOCKED_EXCHANGE_RATE / exchRate) * 4), oppty.Claim_Value_USD__c);  
    }
    
    @isTest
    static void testMnOpptySchedCreated() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProdMN.OpportunityId);
    	
        List<OpportunitySchedule__c> opptyScheds = 
        	[select Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c, Sched_Date__c 
        	   from OpportunitySchedule__c 
    		  where Opportunity__c = :oppty.Id];
    	Test.stopTest();
    	
    	System.assertEquals(4, opptyScheds.size());	
    }
    
    @isTest
    static void testMnOpptySchedUpdatedOpptyOneYearPiecesChanged() {
    	Test.startTest();
    	User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
	    	Opportunity oppty = getOpportunity(opptyProdMN.OpportunityId);
	    	oppty.One_Year_Pieces__c = 1001;
	    	update oppty;
	    	
	    	OpportunitySchedule__c opptySched = 
	        	[select Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
	        	   from OpportunitySchedule__c 
	    		  where Opportunity__c = :oppty.Id
	    		    and Sched_Date__c = :Date.newInstance(2017, 1, 1)];
	    		  
			Double schedQty1 = opptySched.Oppty_Sched_Qty__c;
			Double frozenSchedQty1 = opptySched.Frozen_Oppty_Sched_Qty__c;	
			
			oppty.One_Year_Pieces__c = 1;
			Opportunities.resetUpdateEventEntry();
	    	update oppty;
        
	    	OpportunitySchedule__c opptySched2 = 
	        	[select Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
	        	   from OpportunitySchedule__c 
	    		  where Opportunity__c = :oppty.Id
	    		    and Sched_Date__c = :PRODUCTION_DATE];
	    		  
			Double schedQty2 = opptySched2.Oppty_Sched_Qty__c;
			Double frozenSchedQty2 = opptySched2.Frozen_Oppty_Sched_Qty__c;
			
			System.assertEquals(250, schedQty1);	
	    	System.assertEquals(250, frozenSchedQty1);
	    	System.assertEquals(1, schedQty2);	
	    	System.assertEquals(1, frozenSchedQty2);
        }	    		  
    	Test.stopTest();
    }
    
    @isTest
    static void testMnOpptySchedUpdatedOpptyProductionDateChanged() {
    	Test.startTest();
    	User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
	    	Opportunity oppty = getOpportunity(opptyProdMN.OpportunityId);
	    	oppty.Bypass_Validation_Sched_Start_Date__c = true;
	    	oppty.Production_Date__c = Date.newInstance(2017, 7, 30);
	    	update oppty;
	    	
	    	Date newSchedDate = Date.newInstance(2018, 4, 1);
	    	
	        OpportunitySchedule__c opptySched = 
	        	[select Sched_Date__c 
	        	   from OpportunitySchedule__c 
	    		  where Opportunity__c = :oppty.Id
	    		    and Sched_Date__c = :newSchedDate];
	    		    
			System.assertEquals(newSchedDate, opptySched.Sched_Date__c);    		    
        }
    	Test.stopTest();
    }
    
    @isTest
    static void testOpptyClaimValuePriceErosionRateNonZero() {
        Test.startTest();
        List<OpportunityLineItem> opptyProdsDeleted = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : opptyProds) {
            if (oli !== opptyProdLT) {
                opptyProdsDeleted.add(oli);
            }
        }
        
        delete opptyProdsDeleted;
        
        opptyProdLT.Price_Erosion_Rate__c = 2;
        update opptyProdLT;
        
        opptyProdLT = [select OpportunityId, Price_Erosion_Rate__c from OpportunityLineItem where Id = :opptyProdLT.Id];
        
		Opportunity oppty = getOpportunity(opptyProdLT.OpportunityId);
		Test.stopTest();
        
        System.assertEquals(Math.roundToLong(61199.1658532), Math.roundToLong(oppty.Claim_Value_USD__c));
    }
    
    @isTest
    static void testOpptyClaimValueQuantityProductionDateChanged() {
        List<OpportunityLineItem> opptyProdsDeleted = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : opptyProds) {
            if (oli !== opptyProd) {
                opptyProdsDeleted.add(oli);
            }
        }
        
        delete opptyProdsDeleted;
         
        Test.startTest();  
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        
        List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :oppty.Id];
        delete opptyScheds;
        
        Date productionDate = Date.newInstance(2016, 05, 15);
        oppty.Production_Date__c = productionDate;
        oppty.CloseDate = productionDate - 30;
        createOpportunitySchedules(oppty);
    		 
    	OpportunitySchedule__c opptySched = 
        	[select Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c 
        	   from OpportunitySchedule__c 
    		  where Opportunity__c = :oppty.Id
    		    and Sched_Date__c = :Date.newInstance(2016, 04, 01)];
    		    
		opptySched.Oppty_Sched_Qty__c += 1000;
		opptySched.Frozen_Oppty_Sched_Qty__c += 1000;
		update opptySched;
		Test.stopTest();
		
        update opptyProd;
        
        oppty = getOpportunity(oppty.Id);
        Decimal opptyClaimValue = getOpportunityClaimValue(oppty, new Set<Id>{opptyProd.Id});
        
        System.assertEquals(opptyClaimValue, oppty.Claim_Value_USD__c);  
    }
    
    static void opptyClaimValueProductionDateChanged(Date productionDate) {
    	delete opptyProds;
        
        PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :opptyProd.Product2Id and CurrencyIsoCode = :CCY_CODE_DEFAULT limit 1];
        
        Test.startTest();
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyProd.OpportunityId, PricebookEntryId = pbe.Id);
        oli.UnitPrice = UNIT_PRICE;
        oli.Component_Multiplier__c = COMP_MULT;
        insert oli;
		        
        List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProd};
        Map<ID, Opportunity> opptyClaimValues = getOpportunityClaimValues(opptyLineItems);
        Opportunity oppty = opptyClaimValues.get(opptyProd.OpportunityId);
        
        List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :oppty.Id];
        delete opptyScheds;
		
		oppty.Production_Date__c = productionDate;
        oppty.CloseDate = productionDate - 30;
        update oppty;  
		Test.stopTest();
		
        createOpportunitySchedules(oppty);
        
        oppty = getOpportunity(oppty.Id);
        Decimal opptyClaimValue = getOpportunityClaimValue(oppty, new Set<Id>{oli.Id});
        
        System.assertEquals(opptyClaimValue, oppty.Claim_Value_USD__c);	
    }
    
    @isTest
    static void testOpptyClaimValueProductionDateChanged01() {
    	opptyClaimValueProductionDateChanged(Date.newInstance(2016, 02, 15));      
    }

    @isTest
    static void testOpptyClaimValueProductionDateChanged02() {
    	opptyClaimValueProductionDateChanged(Date.newInstance(2016, 07, 15));
    }
   
    @isTest
    static void testOpptyClaimValueProductionDateChanged03() {
    	opptyClaimValueProductionDateChanged(Date.newInstance(2016, 11, 15));
    }
    
    @isTest
    static void testOpptyClaimValueProductionDateChanged04() {
    	opptyClaimValueProductionDateChanged(Date.newInstance(2017, 1, 15));
    }
  
    @isTest
    static void testOpptyProdAddedNoOpptySchedule() {
    	Test.startTest();
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
        delete opptyScheds;
        
        PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :opptyProd.Product2Id and CurrencyIsoCode = :CCY_CODE_DEFAULT limit 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyProd.OpportunityId, PricebookEntryId = pbe.Id);
        oli.UnitPrice = UNIT_PRICE;
        oli.Component_Multiplier__c = COMP_MULT;
        
        try {
            insert oli;
            
            System.assert(false);
        } catch (DmlException e) {
            System.assert(true);
        } finally {
        	Test.stopTest();
        }
    }
    
    @isTest
    static void testOpptyProdAddedCreateOpptyProdSchedule() {
    	Test.startTest();
    	PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :opptyProd.Product2Id and CurrencyIsoCode = :CCY_CODE_DEFAULT limit 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyProd.OpportunityId, PricebookEntryId = pbe.Id);
        oli.UnitPrice = UNIT_PRICE;
        oli.Component_Multiplier__c = COMP_MULT;
        insert oli;
        
        List<OpportunityProductSchedule__c> opptyProdScheds = [select Id from OpportunityProductSchedule__c where Opportunity__c = :oli.OpportunityId and Oppty_Prod_ID_Full__c = :oli.Id];
        Test.stopTest();
        
        System.assert(opptyProdScheds.size() > 0);	
    }
    
    @isTest
    static void testOpptyProdLostAddedNoOpptyProdScheduleCreated() {
    	Test.startTest();
    	PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :opptyProd.Product2Id and CurrencyIsoCode = :CCY_CODE_DEFAULT limit 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyProd.OpportunityId, PricebookEntryId = pbe.Id);
        oli.UnitPrice = UNIT_PRICE;
        oli.Component_Multiplier__c = COMP_MULT;
        oli.Prod_Lost_Cancelled__c = PROD_LOST;
        insert oli;
        
        List<OpportunityProductSchedule__c> opptyProdScheds = [select Id from OpportunityProductSchedule__c where Opportunity__c = :oli.OpportunityId and Oppty_Prod_ID_Full__c = :oli.Id];
        Test.stopTest();
        
        System.assert(opptyProdScheds.size() == 0);	
    }
    
    @isTest
    static void testOpptyProdCancelledAddedNoOpptyProdScheduleCreated() {
    	Test.startTest();
    	PricebookEntry pbe = [select Id from PricebookEntry where Product2Id = :opptyProd.Product2Id and CurrencyIsoCode = :CCY_CODE_DEFAULT limit 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opptyProd.OpportunityId, PricebookEntryId = pbe.Id);
        oli.UnitPrice = UNIT_PRICE;
        oli.Component_Multiplier__c = COMP_MULT;
        oli.Prod_Lost_Cancelled__c = PROD_CANCELLED;
        insert oli;
        
        List<OpportunityProductSchedule__c> opptyProdScheds = [select Id from OpportunityProductSchedule__c where Opportunity__c = :oli.OpportunityId and Oppty_Prod_ID_Full__c = :oli.Id];
        Test.stopTest();
        
        System.assert(opptyProdScheds.size() == 0);	
    }
    
    // TMMA
    @isTest
    static void testMnOpptyProdUpdateBypassTmmaOverride() {
        Test.startTest();
        opptyProdMN.Opportunity.TMMA_Override__c = true;
        update opptyProdMN.Opportunity;
        
        User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
        	opptyProdMN.UnitPrice = UNIT_PRICE + 0.1;
        	opptyProdMN.Component_Multiplier__c = COMP_MULT + 1;
        	update opptyProdMN;
        	
        	opptyProdMN.Opportunity.Bypass_Validation_Sched_Start_Date__c = true;
        	opptyProdMN.Opportunity.CloseDate = EXPECTED_CLOSE_DATE.addDays(2);
        	opptyProdMN.Opportunity.Production_Date__c = PRODUCTION_DATE.addDays(2);
        	Opportunities.resetUpdateEventEntry();
        	update opptyProdMN.Opportunity;
        }
        Test.stopTest();
        
        OpportunityLineItem opptyLineItem = [select UnitPrice, Component_Multiplier__c from OpportunityLineItem where Id = :opptyProdMN.Id];
        
        System.assertEquals(UNIT_PRICE, opptyLineItem.UnitPrice);
        System.assertEquals(COMP_MULT, opptyLineItem.Component_Multiplier__c);
        
        Opportunity oppty2 = 
        	[select CloseDate, Production_Date__c
        	   from Opportunity 
        	  where Id = :opptyProdMN.OpportunityId];
      
        System.assertEquals(EXPECTED_CLOSE_DATE, oppty2.CloseDate);
        System.assertEquals(PRODUCTION_DATE, oppty2.Production_Date__c);
    }
    
    @isTest
    static void testMnOpptySchedUpdateBypassTmmaOverride() {
    	Test.startTest();
        opptyProdMN.Opportunity.TMMA_Override__c = true;
        update opptyProdMN.Opportunity;	
        
        User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
        	opptyProdMN.Opportunity.One_Year_Pieces__c = ONE_YEAR_PIECES + 500;	
        	update opptyProdMN.Opportunity;
        }
        Test.stopTest();
        
        OpportunitySchedule__c opptySched = 
			[select Id, Opportunity__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c
			   from OpportunitySchedule__c
			  where Opportunity__c = :opptyProdMN.OpportunityId
			  limit 1];
			  
		System.assertEquals(ONE_YEAR_PIECES / 4, opptySched.Oppty_Sched_Qty__c);	
    }
    
    @isTest
    static void testMnOpptyProdPriceUpdatedByTmma() {
    	Test.startTest();
    	System.runAs(getSystemAdminUser()) {
	        opptyProdMN.UnitPrice = UNIT_PRICE + 0.1;
	        update opptyProdMN;	
	        
	        Opportunity oppty = [select TMMA_Override__c from Opportunity where Id = :opptyProdMN.OpportunityId];
	        
	        System.assert(oppty.TMMA_Override__c);
    	}
        Test.stopTest();
    }
    
    @isTest
    static void testTmmaOverrideNotSetForSfdcOppty() {
    	Test.startTest();
        opptyProd.UnitPrice = UNIT_PRICE + 0.1;
        update opptyProdMN;	
        
        Opportunity oppty = [select TMMA_Override__c from Opportunity where Id = :opptyProd.OpportunityId];
        
        System.assert(!oppty.TMMA_Override__c);
        Test.stopTest();
    }
    
    @isTest
    static void testMnOpptyProdPriceUpdatedByDataAdminUser() {
    	Test.startTest();	
    	User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
        	opptyProdMN.UnitPrice = UNIT_PRICE + 0.1;
        	update opptyProdMN;	
        
        	Opportunity oppty = [select TMMA_Override__c from Opportunity where Id = :opptyProdMN.OpportunityId];
        
        	System.assert(!oppty.TMMA_Override__c);	
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMnOpptyProdQtyPerSysUpdatedByTmma() {
    	Test.startTest();
    	System.runAs(getSystemAdminUser()) {
	        opptyProdMN.Component_Multiplier__c = COMP_MULT + 1;
	        update opptyProdMN;	
	        
	        Opportunity oppty = [select TMMA_Override__c from Opportunity where Id = :opptyProdMN.OpportunityId];
	        
	        System.assert(oppty.TMMA_Override__c);
    	}
        Test.stopTest();
    }
    
    @isTest
    static void testMnOpptyProdQtyPerSysUpdatedByDataAdminUser() {
    	Test.startTest();	
    	User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
        	opptyProdMN.Component_Multiplier__c = COMP_MULT + 1;
        	update opptyProdMN;	
        
        	Opportunity oppty = [select TMMA_Override__c from Opportunity where Id = :opptyProdMN.OpportunityId];
        
        	System.assert(!oppty.TMMA_Override__c);	
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMnOpptyExpectedCloseDateUpdatedByTmma() {
    	Test.startTest();
    	System.runAs(getSystemAdminUser()) {
	        opptyProdMN.Opportunity.CloseDate = EXPECTED_CLOSE_DATE.addDays(2);
	        update opptyProdMN.Opportunity;	
	        
	        Opportunity oppty = [select TMMA_Override__c from Opportunity where Id = :opptyProdMN.OpportunityId];
	        
	        System.assert(oppty.TMMA_Override__c);
    	}
        Test.stopTest();
    }
    
    @isTest
    static void testMnOpptyExpectedCloseDateUpdatedByDataAdminUser() {
    	Test.startTest();
        User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
        	opptyProdMN.Opportunity.CloseDate = EXPECTED_CLOSE_DATE.addDays(2);
        	update opptyProdMN.Opportunity;	
        
        	Opportunity oppty = [select TMMA_Override__c from Opportunity where Id = :opptyProdMN.OpportunityId];
        
        	System.assert(!oppty.TMMA_Override__c);	
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMnOpptyProdDateUpdatedByTmma() {
    	Test.startTest();
    	System.runAs(getSystemAdminUser()) {
    		opptyProdMN.Opportunity.Bypass_Validation_Sched_Start_Date__c = true;
	        opptyProdMN.Opportunity.Production_Date__c = PRODUCTION_DATE.addDays(2);
	        update opptyProdMN.Opportunity;	
	        
	        Opportunity oppty = [select TMMA_Override__c from Opportunity where Id = :opptyProdMN.OpportunityId];
	        
	        System.assert(oppty.TMMA_Override__c);
    	}
        Test.stopTest();
    }
    
    @isTest
    static void testMnOpptyProdDateUpdatedByDataAdminUser() {
    	Test.startTest();
        User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
        	opptyProdMN.Opportunity.Bypass_Validation_Sched_Start_Date__c = true;
        	opptyProdMN.Opportunity.Production_Date__c = PRODUCTION_DATE.addDays(2);
        	update opptyProdMN.Opportunity;	
        
        	Opportunity oppty = [select TMMA_Override__c from Opportunity where Id = :opptyProdMN.OpportunityId];
        
        	System.assert(!oppty.TMMA_Override__c);	
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMnOpptyTmma() {
    	Test.startTest();
    	opptyProdMN.Opportunity.Locked_Exchange_Rate__c = EXCH_RATE_DEFAULT;
    	opptyProdMN.Opportunity.TMMA_Override__c = true;
        update opptyProdMN.Opportunity;
        Test.stopTest();
        
        update opptyProdMN;
    	
    	Opportunity oppty = getOpportunity(opptyProdMN.OpportunityId);
    	Decimal opptyClaimValue = getOpportunityClaimValue(oppty, getOpptyProdIDs(opptyProdMN.OpportunityId));
        
        System.assertEquals(opptyClaimValue, oppty.Claim_Value_USD__c);
    }
    
    @isTest
    static void testMnOpptyProdTmma() {
    	Test.startTest();
    	opptyProdMN.Opportunity.Locked_Exchange_Rate__c = EXCH_RATE_DEFAULT;
    	opptyProdMN.Opportunity.TMMA_Override__c = true;
        update opptyProdMN.Opportunity;
        Test.stopTest();
        
        update opptyProdMN;
    	
    	List<OpportunityLineItem> opptyLineItems = new List<OpportunityLineItem>{opptyProdMN};
        Map<ID, OpportunityLineItem> opptyProdClaimValues = getOpportunityProductClaimValues(opptyLineItems);
        
        System.assertEquals(((UP_CM * ONE_YEAR_PIECES) / EXCH_RATE_DEFAULT), opptyProdClaimValues.get(opptyProdMN.Id).Claim_Value_USD__c);
    		
    }
    
    static Map<ID, OpportunityLineItem> getOpportunityProductClaimValues(List<OpportunityLineItem> opptyLineItems) {
        Set<ID> opptyLineItemIDs = new Set<ID>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
            opptyLineItemIDs.add(oli.Id);
        }
        
        Map<ID, OpportunityLineItem> result = new Map<ID, OpportunityLineItem>(
            [select Claim_Value_USD__c, Lost_Cancelled_Claim_Value_USD__c, LT_Value_USD__c, Lost_Cancelled_LT_Value_USD__c
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
            [select Claim_Value_USD__c
               from Opportunity
              where Id in :opptyIDs]
        );
        
        return result;
    }
    
    static Set<ID> getOpptyProdIDs(ID opptyID) {
        Map<ID, OpportunityLineItem> opptyLineItems = new Map<ID, OpportunityLineItem>(
            [select Id from OpportunityLineItem where OpportunityId = :opptyProd.OpportunityId]
        );
        
        return (Set<ID>)opptyLineItems.keySet();
    }
    
    static Opportunity getOpportunity(ID opptyID) {
        return [select Claim_Value_USD__c, Production_Date__c, Locked_Exchange_Rate__c, One_Year_Pieces__c, RecordTypeId, Account.CMD_Industry_Segment__c
                  from Opportunity 
                 where Id = :opptyID];    
    }
    
    static Double getOpportunityClaimValue(Opportunity oppty, Set<ID> opptyProdIDs) {
        Double result = 0;
        
        Map<ID, OpportunitySchedule__c> opptyScheds = new Map<ID, OpportunitySchedule__c>(
    		[select Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c, Sched_Date__c 
    		   from OpportunitySchedule__c 
    		  where Opportunity__c = :oppty.Id
    		 order by Sched_Date__c]
    	);
    	
        List<Double> quarterQtys = new List<Double>();
        Date prodDate = oppty.Production_Date__c;
        String prodYrQtr = prodDate.year() + '0' + (((prodDate.month() - 1) / 3) + 1);
        Integer startIndex = -1;
        
        for (Integer i = 0; i < opptyScheds.size(); i++) {
    		OpportunitySchedule__c opptySched = opptyScheds.values()[i];
    		Date schedDate = opptySched.Sched_Date__c;
    		String yrQtr = schedDate.year() + '0' + (((schedDate.month() - 1) / 3) + 1); 	
    		
    		if (yrQtr.equals(prodYrQtr)) {
    			startIndex = i;
    		}
    		
    		quarterQtys.add(opptySched.Frozen_Oppty_Sched_Qty__c);
    	}
    	
    	List<OpportunityLineItem> olis = [select MAG__c, UnitPrice, Component_Multiplier__c, Share__c from OpportunityLineItem where Id in :opptyProdIDs];
    	        
        for (OpportunityLineItem oli : olis) {
            if (OpportunityProductClaimValue.isLifetime(oppty, oli)) {
                result += (oppty.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId() ? ((UP_CM * ONE_YEAR_PIECES) / oppty.Locked_Exchange_Rate__c) : CLAIM_VALUE_LIFETIME);
                continue;
            }
            
            Integer magClaimValueQuarters = Integer.valueOf(OpportunityProductClaimValue.MAG_CLAIM_VALUE_QUARTERS.get(oli.MAG__c));
            Integer endIndex = startIndex + magClaimValueQuarters;
            Double sumQuarterQty = 0;
            
            for (Integer i = startIndex; i < endIndex; i++) {
                if (i < quarterQtys.size()) {
                    sumQuarterQty += quarterQtys.get(i);     
                }
            } 
            
            result += (sumQuarterQty * oli.UnitPrice * oli.Component_Multiplier__c * (oli.Share__c / 100) / oppty.Locked_Exchange_Rate__c);
        }
        
        return result;
    }
    
    static Boolean isAuto() {
        return (opptyProd.Opportunity.Account.CMD_Industry_Segment__c == CBG_AUTOMOTIVE) ? true : false;
    }
    
    static Product2 createShortLivedProduct() {
        return new Product2(Name = 'Test Product', MAG__c = MAG_SHORT_LIVED, IsActive = true);
    }
    
    static User getSystemAdminUser() {
    	return [select Id from User where ProfileId = :CommonUtils.getSystemAdminProfileId() and Id != :CommonUtils.getDataAdminUserId() and IsActive = true limit 1];	
    }
    
}