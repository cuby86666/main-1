@isTest
private class OpportunityScheduleMasterControllerTest {
	
	private static final String TEST_USER_PROFILE = 'System Administrator';
	private static final String TEST_USER = 't_user_1';
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    private static final String CBG_NON_AUTOMOTIVE = 'Non-Automotive';
    private static final String CBG_DEFAULT = CBG_NON_AUTOMOTIVE; // @default
    private static final String MAG_SHORT_LIVED;
    private static final String MAG_LIFETIME;
    private static final String MAG_DEFAULT;
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_EUR = 'EUR';
    private static final Double EXCH_RATE_USD = 2.0;
    private static final Double EXCH_RATE_EUR = 0.9;
    private static final Decimal UNIT_PRICE = 2;
    private static final Double COMP_MULT = 5;
    private static final Double UP_CM = UNIT_PRICE * COMP_MULT;
    private static final Double ONE_YEAR_PIECES = 1500;
    private static final Double LOCKED_EXCHANGE_RATE = 1.5;
    private static final Date PRODUCTION_DATE = Date.today();
        
    private static List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
    private static List<OpportunityLineItem> opptyProdsMn = new List<OpportunityLineItem>();
    private static OpportunityLineItem opptyProd;
    private static OpportunityLineItem opptyProdLT;
    private static OpportunityLineItem opptyProdMn;
    
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
                opptyProdsMn.add(oli);
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
        
        for (OpportunityLineItem oli : opptyProdsMn) {
            if (oli.MAG__c == MAG_DEFAULT) {
                opptyProdMn = oli;
                break;
            }
        }
    }
    
    @testSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        User u = createUser(TEST_USER, TEST_USER, p.Id, false);
        
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
        a.Customer_Category__c = 'Tier 4 - TMMA';
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
        
        OpportunityProgram__c prog = new OpportunityProgram__c();
    	prog.Name = 'Test program';
    	
    	insert prog;
        
        System.runAs(u) {
        	Test.startTest();
	        createOpportunityProducts(OpportunitiesSelector.getSfdcRecordTypeId(), prog.Id, fxRates, a, prods);
	        Test.stopTest();
	        
	        createOpportunityProducts(OpportunitiesSelector.getMnRecordTypeId(), prog.Id, fxRates, a, prods);	
        }
    }
    
    static User createUser(String alias, String lastName, ID profileID, Boolean signedARIA) {
    	User user = newUser(alias, lastName, profileID, signedARIA); 
    	insert user;
        
        return user;	
    }
    
    static User newUser(String alias, String lastName, ID profileID, Boolean signedARIA) {
    	String email = CommonUtils.generateGUID() + '@nxp.com.test123';
    	
    	User user = new User(EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
		user.Alias = alias;
		user.LastName = lastName;
		user.ProfileId = profileID;
		user.Email = email;
		user.UserName = email;
		user.Signed_ARIA__c = signedARIA;
		        
        return user;	
    }
    
    static void createOpportunityProducts(Id recordTypeId, Id progId, Map<String, FX_Rates__c> fxRates, Account a, List<Product2> prods) {
        // Insert an opportunity
        Opportunity o;
        String ccyCode; 
        
        if (recordTypeId == OpportunitiesSelector.getMnRecordTypeId()) {
        	o = new Opportunity(Name = 'Test Oppty', AccountId = a.Id, StageName = 'Initial Engagement');
        	ccyCode = CCY_CODE_EUR; 	
        } else {
        	o = new Opportunity(Name = 'Test Oppty', AccountId = a.Id, StageName = 'Initial Engagement');
        	ccyCode = CCY_CODE_USD;
        }
        
        Date prodDate = (recordTypeId == OpportunitiesSelector.getMnRecordTypeId()) ? PRODUCTION_DATE.addMonths(3) : PRODUCTION_DATE;  
        
        o.RecordTypeId = recordTypeId;
        o.Program__c = progId;
        o.Production_Date__c = prodDate;
        o.CloseDate = prodDate.addMonths(-2);
        o.Locked_Exchange_Rate__c = LOCKED_EXCHANGE_RATE; // Enabled for MN type, hidden for SFDC type. Admin can edit it no matter what type it is.
        o.One_Year_Pieces__c = ONE_YEAR_PIECES;
        o.Currency__c = fxRates.get(ccyCode).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o.CurrencyIsoCode = ccyCode; // CurrencyIsoCode and Currency__c are correlated.
        insert o;
        
        if (recordTypeId == OpportunitiesSelector.getSfdcRecordTypeId()) {
        	// For direct oppty, oppty scheds are manually created.
        	createOpportunitySchedules(o.Id, prodDate, 2000);	
        } 
        
        System.debug('//J ========== after insert oppty');
        
        List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id in :prods and CurrencyIsoCode = :ccyCode];
        
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
    
    static void createOpportunitySchedules(Id opptyId, Date prodDate, Double totalQty) {
    	List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
    	List<Date> schedDates = OpportunityService.generateOpportunityScheduleDates(prodDate, 4);
    	Double qty = totalQty / 4;
    	Integer i = 1;
    	
    	for (Date schedDate : schedDates) {
    		OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = opptyId, Sched_Date__c = schedDate, Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty, Comment__c = 'Comment ' + i++);
    		opptyScheds.add(opptySched); 	
    	}
    	
    	insert opptyScheds;
    }
    
    @isTest
    static void testUpdateOpptiesScheds() {
    	Map<Id, Opportunity> oppties = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(new Set<Id> {opptyProd.OpportunityId, opptyProdMn.OpportunityId})); 
    	
    	Opportunity opptyMaster = oppties.get(opptyProd.OpportunityId);
    	
    	Date closeDate = opptyMaster.CloseDate;
    	Date prodDate = opptyMaster.Production_Date__c;
    	    	    	
    	Opportunity oppty = oppties.get(opptyProdMn.OpportunityId);
    	
    	User user = [select Id from User where Alias = :TEST_USER];
    	
    	System.runAs(user) {
    		OpportunityScheduleMasterController.updateOpptiesScheds(opptyMaster);	
    	}
    	
    	oppties = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(new Set<Id> {opptyMaster.Id, oppty.Id}));
    	
    	opptyMaster = oppties.get(opptyMaster.Id);
    	oppty = oppties.get(oppty.Id);
    	
    	System.assertEquals(closeDate, opptyMaster.CloseDate);
    	System.assertEquals(closeDate, oppty.CloseDate);
    	System.assertEquals(prodDate, opptyMaster.Production_Date__c);
    	System.assertEquals(prodDate, oppty.Production_Date__c);
    	System.assertEquals(true, oppty.TMMA_Override__c); 
    	System.assertEquals(false, oppty.Bypass_Validation_Sched_Start_Date__c); 
    	
    	Map<Id, List<OpportunitySchedule__c>> opptySchedsByOpptyId = new OpportunitySchedulesSelector().selectByOpptyIdGroupByOpptyId(oppties.keySet());
    	
    	List<OpportunitySchedule__c> opptyMasterScheds = opptySchedsByOpptyId.get(opptyMaster.Id);
    	List<OpportunitySchedule__c> opptyScheds = opptySchedsByOpptyId.get(oppty.Id);
    	    	
    	System.assertEquals(opptyMasterScheds.size(), opptyScheds.size());
    	
    	for (Integer i = 0; i < opptyMasterScheds.size(); i++) {
    		OpportunitySchedule__c opptyMasterSched = opptyMasterScheds.get(i);
    		OpportunitySchedule__c opptySched = opptyScheds.get(i);
   		
    		System.assertEquals(opptyMasterSched.Sched_Date__c, opptySched.Sched_Date__c);
    		System.assertEquals(opptyMasterSched.Oppty_Sched_Qty__c, opptySched.Oppty_Sched_Qty__c);
    		System.assertEquals(opptyMasterSched.Frozen_Oppty_Sched_Qty__c, opptySched.Frozen_Oppty_Sched_Qty__c);
    		System.assertEquals(opptyMasterSched.Comment__c, opptySched.Comment__c);
    		System.assertEquals(oppty.CurrencyIsoCode, opptySched.CurrencyIsoCode);
    	}
    	
    	Map<Id, List<OpportunityProductSchedule__c>> opptyProdSchedsByOpptyId = new OpportunityProductSchedulesSelector().selectByOpptyIdGroupByOpptyId(oppties.keySet());
    	
    	List<OpportunityProductSchedule__c> opptyProdMasterScheds = opptyProdSchedsByOpptyId.get(opptyMaster.Id);
    	List<OpportunityProductSchedule__c> opptyProdScheds = opptyProdSchedsByOpptyId.get(oppty.Id);
   	
    	System.assertEquals(opptyProdMasterScheds.size(), opptyProdScheds.size());
    	
    	for (Integer i = 0; i < opptyProdMasterScheds.size(); i++) {
    		OpportunityProductSchedule__c opptyProdMasterSched = opptyProdMasterScheds.get(i);
    		OpportunityProductSchedule__c opptyProdSched = opptyProdScheds.get(i);
   		
    		System.assertEquals(opptyProdMasterSched.Sched_Date__c, opptyProdSched.Sched_Date__c);
    		System.assertEquals(opptyProdMasterSched.Oppty_Sched_Qty__c, opptyProdSched.Oppty_Sched_Qty__c);
    		System.assertEquals(opptyProdMasterSched.Frozen_Oppty_Sched_Qty__c, opptyProdSched.Frozen_Oppty_Sched_Qty__c);
    		System.assertEquals(oppty.CurrencyIsoCode, opptyProdSched.CurrencyIsoCode);
    	}
    }
    
    static Opportunity getOpportunity(Id opptyId) {
        return new OpportunitiesSelector().selectById(new Set<Id> {opptyId}).get(0);    
    }
	
}