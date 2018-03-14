@isTest
private class OpportunityServiceTest {
	
	private static final String TEST_USER_PROFILE = 'Standard User';
	private static final String TEST_USER = 't_user_1';
	private static final String MAG_SHORT_LIVED;
    private static final String MAG_LIFETIME;
    private static final String MAG_DEFAULT;
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
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    private static final Double ONE_YEAR_PIECES = 1500;
    private static final Double LOCKED_EXCHANGE_RATE = 1.5;
        
    private static List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
    private static List<OpportunityLineItem> opptyProdsMn = new List<OpportunityLineItem>();
    private static OpportunityLineItem opptyProd;
    private static OpportunityLineItem opptyProdMn;
    
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
        
        List<OpportunityLineItem> olis = new OpportunityLineItemsSelector().selectAllWithOpportunity();  
        
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
                break;
            } 
        }
        
        for (OpportunityLineItem oli : opptyProdsMN) {
            if (oli.MAG__c == MAG_DEFAULT) {
                opptyProdMn = oli;
                break;
            }
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
        Account parentGeneral = createAccount('Parent Account - General', AccountsSelector.getParentRecordTypeID(), null, null);
        Account a = createAccount('Test Account', AccountsSelector.getChildRecordTypeID(), parentGeneral.Id, CBG_AUTOMOTIVE);
         
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
        insert o;
        
        if (recordTypeID == OpportunitiesSelector.getSfdcRecordTypeId()) {
        	// For direct oppty, oppty scheds are manually created.
        	createOpportunitySchedules(o.Id, 1000);	
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
    
    @isTest
    static void testDeriveMnOpportunityStages() {
    	opptyProdMn.Registration_Status__c = 'Approved';
    	opptyProdMn.Win_Status__c = 'Pending';
    	update opptyProdMn;
    	
    	Opportunity opptyMn = new OpportunitiesSelector().selectById(new Set<Id> {opptyProdMn.OpportunityId}).get(0);
    	opptyMn.Design_Reg_Status__c = 'Requested';
    	opptyMn.Expiration_Date__c = (System.today() - 1);
    	update opptyMn;    	
    	
    	Map<Id, String> opptyStagesById = OpportunityService.deriveMnOpportunityStages(new Set<Id> {opptyMn.Id});
    	    	
    	System.assertEquals(Opportunities.STAGE_LOST, opptyStagesById.get(opptyMn.Id));
    }
    
    @isTest
    static void testUpdateMnOpportunityStages() {
    	opptyProdMn.Registration_Status__c = 'Requested';
    	opptyProdMn.Win_Status__c = 'Pending';
    	update opptyProdMn; 
    	
    	Opportunity opptyMn = new OpportunitiesSelector().selectById(new Set<Id> {opptyProdMn.OpportunityId}).get(0);
    	opptyMn.Design_Reg_Status__c = 'Approved';
    	opptyMn.Expiration_Date__c = (System.today() + 1);	
    	update opptyMn;
    	
    	opptyMn = new OpportunitiesSelector().selectById(new Set<Id> {opptyProdMn.OpportunityId}).get(0);
    	
    	System.assertEquals(Opportunities.STAGE_INITIAL_ENGAGEMENT, opptyMn.StageName);
    	
    	Test.startTest();
    	opptyMn.Expiration_Date__c = (System.today() - 1);  
    	update opptyMn;
    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectById(new Set<Id> {opptyProdMn.OpportunityId}); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	OpportunityService.updateMnOpportunityStages(oppties, uow);
    	uow.commitWork();
    	
    	opptyMn = new OpportunitiesSelector().selectById(new Set<Id> {opptyProdMn.OpportunityId}).get(0);
    	Test.stopTest();
    	
    	System.assertEquals(Opportunities.STAGE_LOST, opptyMn.StageName);
    }
    
}