@isTest
private class OpportunitiesTest {
	
	private static final String TEST_USER_PROFILE = 'Standard User';
	private static final String TEST_USER = 't_user_1';
	private static final String MAG_SHORT_LIVED;
    private static final String MAG_LIFETIME;
    private static final String BL1 = 'BL01';
    private static final String BL2 = 'BLM1';
	private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_EUR = 'EUR';
    private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
    private static final Double EXCH_RATE_USD = 2.0;
    private static final Double EXCH_RATE_EUR = 0.9;
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final Decimal UNIT_PRICE = 2;
    private static final Double COMP_MULT = 5;
    private static final Integer PROD_COUNT = 4;
    private static final String PARENT_ACCOUNT_STAR = 'STAR';
	private static final String PARENT_ACCOUNT_SAMSUNG = 'Samsung';
	private static final String CBG_AUTOMOTIVE = 'Automotive';
    
    private static List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
    private static OpportunityLineItem opptyProd;
    
    static {
    	Opportunity_Claim_Value_MAG_Setting__mdt claimValueMagSetting = 
            [select MAG__c 
               from Opportunity_Claim_Value_MAG_Setting__mdt 
              where Claim_Value_Quarters__c != 'Lifetime'
                and IsActive__c = true
              limit 1];
        
        MAG_SHORT_LIVED = claimValueMagSetting.MAG__c;
               
        claimValueMagSetting = 
            [select MAG__c 
               from Opportunity_Claim_Value_MAG_Setting__mdt 
              where Claim_Value_Quarters__c = 'Lifetime'
                and IsActive__c = true
              limit 1];
        
        MAG_LIFETIME = claimValueMagSetting.MAG__c;
        
        List<OpportunityLineItem> opptyLineItems = [select Id, OpportunityId, Program__c, PricebookEntry.Product2.MAG__c from OpportunityLineItem]; 
        
        for (OpportunityLineItem oli : opptyLineItems) {
        	opptyProds.add(oli);    
        }
        
        if (opptyProds.size() > 0) {
        	opptyProd = opptyProds.get(0);
        }
    }
    	
	@testSetup
    static void setup() {
    	Profile p = [select Id from Profile where Name = :TEST_USER_PROFILE];
    	
    	// insert a test user
    	User u = createUser(TEST_USER, TEST_USER, p.Id, false);
                
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
        
        // Insert accounts
        createAccount(PARENT_ACCOUNT_STAR, AccountsSelector.getParentRecordTypeID(), null, null);
        createAccount(PARENT_ACCOUNT_SAMSUNG, AccountsSelector.getParentRecordTypeID(), null, null);
        Account parentGeneral = createAccount('Parent Account - General', AccountsSelector.getParentRecordTypeID(), null, null);
        Account a = createAccount('Test Account', AccountsSelector.getChildRecordTypeID(), parentGeneral.Id, CBG_AUTOMOTIVE);
         
        // Insert an opportunity
        Opportunity o = new Opportunity(Name = 'Test Oppty', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o.Production_Date__c = PRODUCTION_DATE;
        o.CloseDate = PRODUCTION_DATE - 60;
        o.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        o.Bypass_Validation_Sched_Start_Date__c = true;
        insert o;
        
        System.debug('//J ========== after insert oppty');  
        
        createOpportunitySchedules(o.Id, 1000);
        
        // Insert products
        List<Product2> prods = new List<Product2>();
        
        for (Integer i = 0; i < PROD_COUNT; i++) {
            Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
                prods.add(new Product2(Name = 'Test Product' + i, MAG__c = MAG_SHORT_LIVED, BL__c = BL1, IsActive = true));
            } else {
                prods.add(new Product2(Name = 'Test Product' + i, MAG__c = MAG_LIFETIME, BL__c = BL2, IsActive = true));
            }            
        }
        
        insert prods;
        
        List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id in :prods and CurrencyIsoCode = :CCY_CODE_DEFAULT];
        
        // Insert opportunity products
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        
        for (PricebookEntry pbe : pbes) {
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pbe.Id);
            oli.UnitPrice = UNIT_PRICE;
            oli.Component_Multiplier__c = COMP_MULT;
            olis.add(oli);
        }
        
        insert olis;
        
        System.debug('//J ========== after insert oppty prods');
    } 
    
    static void createOpportunitySchedules(ID opptyID, Double totalQty) {
    	List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
    	Double qty = totalQty / 4;
    	
    	OpportunitySchedule__c opptySched;
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 01, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 04, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 07, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);	
    	
    	insert opptyScheds;
    }

	@isTest
    static void testOpptyProdProgramSyncedWithOppty() {
        Test.startTest();
        OpportunityProgram__c opptyProg = new OpportunityProgram__c(Name = 'Test Program');
        insert opptyProg; 
        
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        oppty.Program__c = opptyProg.Id;
        update oppty;
        Test.stopTest();
        
        opptyProd = [select Program__c from OpportunityLineItem where Id = :opptyProd.Id];
        
        System.assertEquals(opptyProg.Id, opptyProd.Program__c);
    }
    
    @isTest
    static void testOpptyProgramEditable() {
    	User user = [select Id from User where Alias = :TEST_USER];
    	
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
	    oppty.Design_Win_Approval_Process__c = 'Approved';
	    update oppty;
	    
	    System.runAs(user) {
	    	OpportunityProgram__c opptyProg = new OpportunityProgram__c(Name = 'Test Program 1');
	    	insert opptyProg;
	        
	        oppty.Program__c = opptyProg.Id;
	        resetOpptyFirstRun();
	        update oppty;
	        
	        opptyProd = [select Program__c from OpportunityLineItem where Id = :opptyProd.Id];
	        
	        System.assertEquals(opptyProg.Id, opptyProd.Program__c);
	        
	        try {
	        	opptyProg = new OpportunityProgram__c(Name = 'Test Program 2');
	        	insert opptyProg;
	        	
	        	// Only Program can be edited all the time.
	        	oppty.Program__c = opptyProg.Id;
	        	oppty.Name = 'Name 1';
	        	resetOpptyFirstRun();
	        	update oppty;	
	        	
	        	System.assert(false);
	        } catch (Exception e) {
	        	System.assert(true);
	        }
	        
	        try {
	        	// Only War Room Completed can be edited all the time.
	        	oppty.War_Room_Completed__c = 'Yes';
	        	oppty.Name = 'Name 2';
	        	resetOpptyFirstRun();
	        	update oppty;	
	        	
	        	System.assert(false);
	        } catch (Exception e) {
	        	System.assert(true);
	        }
	    }
	    
	    oppty.StageName = 'Commitment';
	    oppty.RecordTypeId = OpportunitiesSelector.getMnRecordTypeId();
	    update oppty;
	    
	    System.runAs(user) {
	    	OpportunityProgram__c opptyProg = new OpportunityProgram__c(Name = 'Test Program 3');
	        insert opptyProg;
	        
	        oppty.Program__c = opptyProg.Id;
	        resetOpptyFirstRun();
	        update oppty;
	        
	        opptyProd = [select Program__c from OpportunityLineItem where Id = :opptyProd.Id];
	        
	        System.assertEquals(opptyProg.Id, opptyProd.Program__c);
	        
	        try {
	        	opptyProg = new OpportunityProgram__c(Name = 'Test Program 4');
	        	insert opptyProg;
	        	
	        	// Only Program can be edited all the time.
	        	oppty.Program__c = opptyProg.Id;
	        	oppty.Name = 'Name 3';
	        	resetOpptyFirstRun();
	        	update oppty;
	        	
	        	System.assert(false);
	        } catch (Exception e) {
	        	System.assert(true);
	        }	
	        
	        try {
	        	// Only War Room Completed can be edited all the time.
	        	oppty.War_Room_Completed__c = 'No';
	        	oppty.Name = 'Name 4';
	        	resetOpptyFirstRun();
	        	update oppty;	
	        	
	        	System.assert(false);
	        } catch (Exception e) {
	        	System.assert(true);
	        }
	    }
	    Test.stopTest();
    }
    
    @isTest
    static void testOpptyDiscoveryDate() {
		Test.startTest();
		// Case 1: update oppty to discovery stage
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
	    oppty.StageName = Opportunities.STAGES.get(Opportunities.Stage.DISCOVERY);
	    update oppty;
	    
	    oppty = getOpportunity(opptyProd.OpportunityId);
	    system.assertEquals(date.today(), oppty.Discovery_Date__c);
	    
	    //Case 2: insert oppty with Discovery stage
	    Opportunity opptyDiscovery = new Opportunity(
	    	Name = 'Test Disc Oppty',
	    	Production_Date__c = PRODUCTION_DATE,
        	CloseDate = PRODUCTION_DATE - 60,
	    	StageName = Opportunities.STAGES.get(Opportunities.Stage.DISCOVERY)
	    );
	    insert opptyDiscovery; 
        
        oppty = getOpportunity(opptyDiscovery.Id);
	    system.assertEquals(date.today(), oppty.Discovery_Date__c);
	    
	    Test.stopTest();
    }
    
    @isTest
    static void testOpptyClaimValueHistoryTracking() {
    	Test.startTest();
    	
        //Case 1: Locked Exchange Rate != null && Claim Value != null
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	system.assertNotEquals(null, oppty.Claim_Value__c);
    	system.assertNotEquals(null, oppty.Locked_Exchange_Rate__c);
    	system.assertEquals(oppty.Claim_Value__c/oppty.Locked_Exchange_Rate__c, oppty.Claim_Value_USD_SYS__c);
    	
    	//Case 2: Locked Exchange Rate == null && Claim Value == null
    	Fx_Rates__c fxRate= [SELECT Id, Exchange_Rate__c, CurrencyIsoCode FROM Fx_Rates__c WHERE CurrencyIsoCode = :CCY_CODE_USD];
	    fxRate.Exchange_Rate__c = 0;
	    update fxRate;
    	
    	Opportunity opptyWoProduct = new Opportunity(
	    	Name = 'Test Oppty w/o product',
	    	Production_Date__c = PRODUCTION_DATE,
        	CloseDate = PRODUCTION_DATE - 60,
	    	StageName = Opportunities.STAGES.get(Opportunities.Stage.DISCOVERY),
	    	CurrencyIsoCode = CCY_CODE_USD
	    );
	    insert opptyWoProduct; 
	    	    
	    oppty = getOpportunity(opptyWoProduct.Id);
	    
	    system.assertEquals(0, oppty.Locked_Exchange_Rate__c);
	 	system.assertEquals(null, oppty.Claim_Value_USD_SYS__c);
        
        delete fxRate;
        update oppty;
        oppty = getOpportunity(opptyWoProduct.Id);
	    
	    system.assertEquals(0, oppty.Locked_Exchange_Rate__c);
    	
    	Test.stopTest();
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
    
    static Account createAccount(String name, ID recordTypeID, ID parentID, String cbg) {
    	Account account = new Account(Region__c = 'EMEA');
    	account.Name = name;
    	account.RecordTypeId = recordTypeID;
    	account.ParentId = parentID;
    	account.CMD_Industry_Segment__c = cbg;
    	insert account;
    	
    	return account;
    }
    
    static Opportunity getOpportunity(ID opptyID) {
        return [select LT_Value_USD__c, Sales_Director_Approver__c, Regional_VP_Approver__c, VP_Approver_2__c, 
        			   MAG_Approver_1__c, MAG_Approver_2__c, BL_Approver_1__c, BL_Approver_2__c, Program__c,    
        			   Account.ParentId, Owner.MT_2__c, StageName, Discovery_Date__c, Claim_Value__c, Locked_Exchange_Rate__c,
        			   Claim_Value_USD_SYS__c, CurrencyIsoCode
        		  from Opportunity 
        		 where Id = :opptyID];    
    }
    
    static void resetOpptyFirstRun() {
    	Opportunities.isFirstRunBeforeUpdate = true;
	    Opportunities.isFirstRunAfterUpdate = true;
    }

}