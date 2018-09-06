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
    private static Opportunity oppty;
    private static Opportunity opptyMn;
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
		
		if (opptyProd != null) {
			oppty = new OpportunitiesSelector().selectById(new Set<Id> {opptyProd.OpportunityId}).get(0);	
		}        
        
        if (opptyProdMn != null) {
        	opptyMn = new OpportunitiesSelector().selectById(new Set<Id> {opptyProdMn.OpportunityId}).get(0);	
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
        	createOpportunitySchedules(o.Id, o.Production_Date__c, 1000);	
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
    
    static void createOpportunitySchedules(Id opptyId, Date prodDate, Double totalQty) {
    	List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
    	List<Date> schedDates = OpportunityService.generateOpportunityScheduleDates(prodDate, 4);
    	Double qty = totalQty / 4;
    	
    	for (Date schedDate : schedDates) {
    		OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = opptyId, Sched_Date__c = schedDate, Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
    		opptyScheds.add(opptySched); 	
    	}
    	
    	insert opptyScheds;
    }
    
    static User createUser(String alias, String lastName, ID profileID, Boolean signedARIA) {
    	User user = newUser(alias, lastName, null, profileID, signedARIA); 
    	insert user;
        
        return user;	
    }
    
    static User createUser(String alias, String lastName, String username, ID profileID, Boolean signedARIA) {
    	User user = newUser(alias, lastName, username, profileID, signedARIA); 
    	insert user;
        
        return user;	
    }
    
    static User newUser(String alias, String lastName, String username, ID profileID, Boolean signedARIA) {
    	String email = CommonUtils.generateGUID() + '@nxp.com.test123';
    	
    	User user = new User(EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
		user.Alias = alias;
		user.LastName = lastName;
		user.ProfileId = profileID;
		user.Email = email;
		user.UserName = (username != null) ? username : email;
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
    
    @isTest
    static void testMnOpptyOwnerId() {
    	final String END_CUST_GID = '12345';
    	final String DISTI_NAME = 'CHINA ELEC';
    	final String END_CUST_REGION = 'AMERICAS';
    	final String LEGACY_ID = DISTI_NAME + '-' + END_CUST_REGION;   
    	final String APPROVER_EMAIL = CommonUtils.generateGUID() + '@nxp.com.test123';  
    	
    	Test.startTest();
    	Profile p = [select Id from Profile where Name = :TEST_USER_PROFILE];
    	
    	// Use account owner as oppty owner
    	User acctOwner = createUser('tuser123', 'tuser123', p.Id, false);
    	acctOwner.IsActive = true;
    	update acctOwner;
    	
    	Account a1 = new Account();
    	a1.Name = 'Test Account 1';
    	a1.OwnerId = acctOwner.Id;
    	a1.NXP_GID__c = END_CUST_GID;
    	insert a1;
    	
    	Opportunity oppty = new OpportunitiesSelector().selectById(new Set<Id> {opptyProdMn.OpportunityId}).get(0);
    	oppty.OwnerId = CommonUtils.getDataAdminUserId();
    	oppty.End_Customer_GID__c = END_CUST_GID;
    	update oppty;    	
    	
    	oppty = new OpportunitiesSelector().selectByIdWithAccountAndOwner(new Set<Id> {oppty.Id}).get(0);
    	
    	OpportunityService.updateMnOpportunityAccountsAndOwners(new List<Opportunity> {oppty}, null);
    	
    	update oppty;
    	
    	oppty = new OpportunitiesSelector().selectById(new Set<Id> {oppty.Id}).get(0);
    	
    	System.assertEquals(acctOwner.Id, oppty.OwnerId);
  	
    	// Use approver as oppty owner
    	User drApprover = createUser('tuser456', 'tuser456', APPROVER_EMAIL, p.Id, false);
    	
    	Account a2 = new Account();
    	a2.name = 'Test Account 2';
    	a2.Legacy_Id__c = LEGACY_ID;
    	insert a2;
    	
    	oppty.OwnerId = CommonUtils.getDataAdminUserId();
    	oppty.Legacy_Opportunity_Owner__c = APPROVER_EMAIL; 
    	oppty.End_Customer_GID__c = null;
    	oppty.Distributor_Name__c = DISTI_NAME;
    	oppty.End_Customer_Region__c = END_CUST_REGION;
    	update oppty;
    	
    	oppty = new OpportunitiesSelector().selectByIdWithAccountAndOwner(new Set<Id> {oppty.Id}).get(0);
    	
    	OpportunityService.updateMnOpportunityAccountsAndOwners(new List<Opportunity> {oppty}, null);
    	
    	update oppty;
    	
    	oppty = new OpportunitiesSelector().selectById(new Set<Id> {oppty.Id}).get(0);
        
    	System.assertEquals(drApprover.Id, oppty.OwnerId);
    	Test.stopTest();
    	
    	// If oppty owner is not Data Admin, no change.
    	oppty.OwnerId = drApprover.Id;
    	oppty.End_Customer_GID__c = END_CUST_GID;
    	oppty.Distributor_Name__c = null;
    	oppty.End_Customer_Region__c = null;
    	update oppty;    	
    	
    	oppty = new OpportunitiesSelector().selectByIdWithAccountAndOwner(new Set<Id> {oppty.Id}).get(0);
    	
    	OpportunityService.updateMnOpportunityAccountsAndOwners(new List<Opportunity> {oppty}, null);
    	
    	update oppty;
    	
    	oppty = new OpportunitiesSelector().selectById(new Set<Id> {oppty.Id}).get(0);
    	
    	System.assertEquals(drApprover.Id, oppty.OwnerId);
    }
    
    @isTest
    static void testShiftOpportunitySchedules() {
    	List<OpportunitySchedule__c> opptyScheds = new OpportunitySchedulesSelector().selectByOpptyId(new Set<Id> {oppty.Id});
    	Date prodDate = Date.today(); 
    	
    	OpportunityService.shiftOpportunitySchedules(opptyScheds, prodDate);
    	
    	System.assertEquals(prodDate, opptyScheds.get(0).Sched_Date__c);
    }
  
    @isTest
    static void testGenerateOpportunityScheduleDates() {
    	Date prodDate = Date.newInstance(2018, 05, 18);
    	List<Date> schedDates = OpportunityService.generateOpportunityScheduleDates(prodDate, 5);
    	
    	System.assertEquals(prodDate, schedDates.get(0)); 	
    	System.assertEquals(Date.newInstance(2018, 07, 01), schedDates.get(1));
    	System.assertEquals(Date.newInstance(2018, 10, 01), schedDates.get(2));
    	System.assertEquals(Date.newInstance(2019, 01, 01), schedDates.get(3));
    	System.assertEquals(Date.newInstance(2019, 04, 01), schedDates.get(4));
    }
    
}