@isTest
private class OpportunityApprovalTest {
	private static final String TEST_USER_PROFILE = 'Standard User';
	private static final String TEST_USER = 't_user_1';
	private static final String TEST_USER_MAG_STAR = 'uMagSTAR';
	private static final String TEST_USER_BL_STAR = 'uBlSTAR';
	private static final String TEST_USER_GAM_STAR = 'uGamSTAR';
	private static final String TEST_USER_GAM_SAMSUNG = 'uGamSAMS';
	private static final String TEST_USER_GAM_GENERAL = 'uGamGen';//SFDC-954
	private static final String TEST_USER_EVP_STAR = 'uEvpSTAR';
	private static final String TEST_USER_EVP_SAMSUNG = 'uEvpSAMS';
	private static final String TEST_USER_AUTO = 'userAUTO';
	private static final String TEST_USER_MT1 = 'userMT1';
	private static final String TEST_USER_MT2 = 'userMT2';
	private static final String TEST_USER_MAG = 'userMAG';
	private static final String TEST_USER_BL = 'userBL';
	private static final String MAG_SHORT_LIVED;
    private static final String MAG_LIFETIME;
    private static final String BL1 = 'BL01';
    private static final String BL2 = 'BLM1';
    private static final String CCY_CODE_USD = 'USD';
    private static final String CCY_CODE_EUR = 'EUR';
    private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
    private static final Double EXCH_RATE_USD = 2.0;
    private static final Double EXCH_RATE_EUR = 0.9;
    private static final String PARENT_ACCOUNT_STAR = 'STAR';
	private static final String PARENT_ACCOUNT_SAMSUNG = 'Samsung';
    private static final String CBG_AUTOMOTIVE = 'Automotive';
    private static final String CBG_NON_AUTOMOTIVE = 'Non-Automotive';
    private static final String REGION_GC = 'Greater China';
    private static final String REGION_SAP = 'South Asia Pacific';
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final Decimal UNIT_PRICE = 2;
    private static final Double COMP_MULT = 5;
    private static final Integer PROD_COUNT = 4;
    private static final Double THRESHOLD_MAG = 100 * 1000;
    private static final Double THRESHOLD_BL = 15 * 1000 * 1000;
    private static final Double THRESHOLD_VP = 10 * 1000 * 1000;
    
    private static ID userIdMagSTAR;
    private static ID userIdBlSTAR;
    private static ID userIdGamSTAR;
    private static ID userIdGamSamsung;
    private static ID userIdGamGeneral;//SFDC-954
    private static ID userIdEvpSTAR;
    private static ID userIdEvpSamsung;
    private static ID userIdAuto;
    private static ID userIdMT1;
    private static ID userIdMT2;
    private static ID userIdMAG;
    private static ID userIdBL;
    private static ID parentAccountIdSTAR;
    private static ID parentAccountIdSamsung;
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
        
        List<User> users = [select Alias, MT_1__c, MT_2__c from User where Alias in (:TEST_USER, :TEST_USER_MAG, :TEST_USER_BL, :TEST_USER_MAG_STAR, :TEST_USER_BL_STAR, :TEST_USER_GAM_STAR, :TEST_USER_GAM_SAMSUNG, :TEST_USER_GAM_GENERAL, :TEST_USER_EVP_STAR, :TEST_USER_EVP_SAMSUNG, :TEST_USER_AUTO)];
        
        for (User u : users) {
        	if (u.Alias == TEST_USER) {
        		userIdMT1 = u.MT_1__c;
        		userIdMT2 = u.MT_2__c;	
        	} else if (u.Alias == TEST_USER_MAG) {
        		userIdMAG = u.Id;
        	} else if (u.Alias == TEST_USER_BL) {
        		userIdBL = u.Id;
        	} else if (u.Alias == TEST_USER_MAG_STAR) {
        		userIdMagSTAR = u.Id;
        	} else if (u.Alias == TEST_USER_BL_STAR) {
        		userIdBlSTAR = u.Id;
        	} else if (u.Alias == TEST_USER_GAM_STAR) {
        		userIdGamSTAR = u.Id;
        	} else if (u.Alias == TEST_USER_GAM_SAMSUNG) {
        		userIdGamSamsung = u.Id;
        	} else if (u.Alias == TEST_USER_GAM_GENERAL) {
        		userIdGamGeneral = u.Id; //SFDC-954
        	} else if (u.Alias == TEST_USER_EVP_STAR) {
        		userIdEvpSTAR = u.Id;
        	} else if (u.Alias == TEST_USER_EVP_SAMSUNG) {
        		userIdEvpSamsung = u.Id;
        	} else if (u.Alias == TEST_USER_AUTO) {
        		userIdAuto = u.Id;
        	}
        }
        
        List<Account> accounts = [select Name from Account];
        
        for (Account a : accounts) {
        	if (a.Name == PARENT_ACCOUNT_STAR) {
        		parentAccountIdSTAR = a.Id;	
        	} else if (a.Name == PARENT_ACCOUNT_SAMSUNG) {
        		parentAccountIdSamsung = a.Id;	
        	}
        }
        
        List<OpportunityLineItem> opptyLineItems = [select Id, OpportunityId, PricebookEntry.Product2.MAG__c from OpportunityLineItem]; 
        
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
    	
    	// insert test users
    	List<User> users = new List<User>();
    	users.add(newUser(TEST_USER_MAG_STAR, TEST_USER_MAG_STAR, p.Id, true));
    	users.add(newUser(TEST_USER_BL_STAR, TEST_USER_BL_STAR, p.Id, true));
    	users.add(newUser(TEST_USER_GAM_STAR, TEST_USER_GAM_STAR, p.Id, true));
    	users.add(newUser(TEST_USER_GAM_SAMSUNG, TEST_USER_GAM_SAMSUNG, p.Id, false));
    	users.add(newUser(TEST_USER_EVP_STAR, TEST_USER_EVP_STAR, p.Id, true));
    	users.add(newUser(TEST_USER_EVP_SAMSUNG, TEST_USER_EVP_SAMSUNG, p.Id, false));
    	users.add(newUser(TEST_USER_AUTO, TEST_USER_AUTO, p.Id, false));
    	users.add(newUser(TEST_USER_MT1, TEST_USER_MT1, p.Id, false));
    	users.add(newUser(TEST_USER_MT2, TEST_USER_MT2, p.Id, false));
    	users.add(newUser(TEST_USER_MAG, TEST_USER_MAG, p.Id, false));
    	users.add(newUser(TEST_USER_BL, TEST_USER_BL, p.Id, false));
    	users.add(newUser(TEST_USER_GAM_GENERAL, TEST_USER_GAM_GENERAL, p.Id, false));//SFDC-954
    	insert users;
    	
    	User userMagSTAR = users.get(0);
    	User userBlSTAR = users.get(1);
    	User userGamSTAR = users.get(2);
    	User userGamSamsung = users.get(3);
    	User userEvpSTAR = users.get(4);
    	User userEvpSamsung = users.get(5);
    	User userAuto = users.get(6);
    	User userMT1 = users.get(7);
    	User userMT2 = users.get(8);
    	User userMAG = users.get(9);
    	User userBL = users.get(10);
    	User userGamGeneral = users.get(11);//SFDC-954
    	
    	User u = createUser(TEST_USER, TEST_USER, p.Id, false);
        u.MT_1__c = userMT1.Id;
        u.MT_2__c = userMT2.Id;
        update u;
        
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
         
        // insert approvers
        List<Approvers_Matrix__c> ams = new List<Approvers_Matrix__c>();
        ams.add(newApproverMatrix('MAG Approver', MAG_SHORT_LIVED, null, THRESHOLD_MAG, userMAG.Id, null));
        ams.add(newApproverMatrix('MAG Approver', MAG_LIFETIME, null, THRESHOLD_MAG, userMAG.Id, null));
        ams.add(newApproverMatrix('BL Approver', BL1, null, THRESHOLD_BL, userBL.Id, null));
        ams.add(newApproverMatrix('BL Approver', BL2, null, THRESHOLD_BL, userBL.Id, null));
        ams.add(newApproverMatrix('MAG Approver', MAG_SHORT_LIVED, 'STAR', THRESHOLD_MAG, userMagSTAR.Id, null));
        ams.add(newApproverMatrix('MAG Approver', MAG_LIFETIME, 'STAR', THRESHOLD_MAG, userMagSTAR.Id, null));
        ams.add(newApproverMatrix('BL Approver', BL1, 'STAR', THRESHOLD_BL, userBlSTAR.Id, null));
        ams.add(newApproverMatrix('BL Approver', BL2, 'STAR', THRESHOLD_BL, userBlSTAR.Id, null));
        ams.add(newApproverMatrix('GAM', 'STAR', null, 0, userGamSTAR.Id, null));
        ams.add(newApproverMatrix('GAM', 'Samsung', null, 0, userGamSamsung.Id, null));
        ams.add(newApproverMatrix('EVP', 'STAR', null, THRESHOLD_VP, userEvpSTAR.Id, null));
        ams.add(newApproverMatrix('EVP', 'Samsung', null, THRESHOLD_VP, userEvpSamsung.Id, null));
        ams.add(newApproverMatrix('Segment VP', 'Automotive', null, THRESHOLD_VP, userAuto.Id, null));
        ams.add(newApproverMatrix('GSM Sales Director', null, null, 0, u.Id, null));
        ams.add(newApproverMatrix('GSM VP 1', null, null, THRESHOLD_VP, u.Id, null));
        ams.add(newApproverMatrix('GSM VP 2', 'Automotive', 'Greater China', THRESHOLD_VP, u.Id, null));
        ams.add(newApproverMatrix('GSM VP 2', 'Automotive', 'South Asia Pacific', THRESHOLD_VP, u.Id, null));
        ams.add(newApproverMatrix('GAM', 'General Account', null, 0, userGamGeneral.Id, parentGeneral.Id));
        insert ams; 
         
         
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
    
    static Approvers_Matrix__c newApproverMatrix(String type, String criteria1, String criteria2, Double threshold1, ID approverID, ID accountID) {//SFDC-954, Add Account ID
    	Approvers_Matrix__c approverMatrix = new Approvers_Matrix__c();
    	approverMatrix.RecordTypeId = new ApproverMatrixesSelector().getRecordTypeId(ApproverMatrixesSelector.RecordType.DIRECT_OPPTY);
    	approverMatrix.Type__c = type;
    	approverMatrix.Criteria_1__c = criteria1;
    	approverMatrix.Criteria_2__c = criteria2;
    	approverMatrix.Threshold_1__c = threshold1;
    	approverMatrix.Approver__c = approverID;
    	approverMatrix.Account__c = accountID;
    	    	
    	return approverMatrix;
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
    static void testOpptyLifetimeValue() {
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	OpportunitySchedulesSelector.OpportunityScheduleValueSummary schedValue = new OpportunitySchedulesSelector().selectSchedValueByOpptyIdGroupByOpptyId(new Set<Id>{opptyProd.OpportunityId}).get(0);
    	
    	System.assertEquals((schedValue.totalFrozenSchedQty * COMP_MULT * UNIT_PRICE * PROD_COUNT) / EXCH_RATE_USD, oppty.LT_Value_USD__c);
    } 
    
    @isTest
    static void testSalesDirectorApproverIdGeneral() {
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT2, OpportunityApproval.getSalesDirectorApproverID(oppty));  
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setSalesDirectorApproverID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT2, oppty.Sales_Director_Approver__c);
    	
    	testOpptyShare(new List<ID>{userIdMT2});
    }
    
    @isTest
    static void testSalesDirectorApproverIdSTAR() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR;
    	update oppty.Account; 
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdGamSTAR, OpportunityApproval.getSalesDirectorApproverID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setSalesDirectorApproverID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdGamSTAR, oppty.Sales_Director_Approver__c); 
    	
    	testOpptyShare(new List<ID>{userIdGamSTAR});
    }
    
    @isTest
    static void testSalesDirectorApproverIdSamsung() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung;
    	update oppty.Account; 
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdGamSamsung, OpportunityApproval.getSalesDirectorApproverID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setSalesDirectorApproverID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdGamSamsung, oppty.Sales_Director_Approver__c); 
    	
    	testOpptyShare(new List<ID>{userIdGamSamsung});
    }
    
    @isTest
    static void testVpApprover1IdGeneralWithoutMt2Auto() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, oppty.Regional_VP_Approver__c);
    	
    	testOpptyShare(new List<ID>{userIdAuto}); 
    }
    
    @isTest
    static void testVpApprover1IdGeneralWithoutMt2NonAuto() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, oppty.Regional_VP_Approver__c);
    	
    	testOpptyShare(new List<ID>{userIdMT1}); 
    }
    
    @isTest
    static void testVpApprover1IdGeneralWithMt2LtThresholdAuto() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.Regional_VP_Approver__c); 
    }
    
    @isTest
    static void testVpApprover1IdGeneralWithMt2GtThresholdAuto() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_VP * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, oppty.Regional_VP_Approver__c);
    	
    	testOpptyShare(new List<ID>{userIdAuto}); 
    }
    
    @isTest
    static void testVpApprover1IdGeneralWithMt2LtThresholdNonAuto() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.Regional_VP_Approver__c); 
    }
    
    @isTest
    static void testVpApprover1IdGeneralWithMt2GtThresholdNonAuto() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_VP * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, oppty.Regional_VP_Approver__c);
    	
    	testOpptyShare(new List<ID>{userIdMT1}); 
    }
    
    @isTest
    static void testVpApprover1IdLtThresholdSTAR() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR;
    	update oppty.Account; 
    	    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.Regional_VP_Approver__c); 
    }
    
    @isTest
    static void testVpApprover1IdGtThresholdSTAR() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR;
    	update oppty.Account; 
    	    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_VP * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdEvpSTAR, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdEvpSTAR, oppty.Regional_VP_Approver__c);
    	
    	testOpptyShare(new List<ID>{userIdEvpSTAR}); 
    }
    
    @isTest
    static void testVpApprover1IdLtThresholdSamsung() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung;
    	update oppty.Account; 
    	    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.Regional_VP_Approver__c); 
    }
    
    @isTest
    static void testVpApprover1IdGtThresholdSamsung() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung;
    	update oppty.Account; 
    	    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_VP * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdEvpSamsung, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdEvpSamsung, oppty.Regional_VP_Approver__c);
    	
    	testOpptyShare(new List<ID>{userIdEvpSamsung});  
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithoutMt2AutoGC() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, oppty.VP_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdMT1});
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithoutMt2AutoSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_SAP; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, oppty.VP_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdMT1});
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithoutMt2NonAutoGC() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithoutMt2NonAutoSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_SAP; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithoutMt2AutoNonGcSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = 'EMEA'; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithoutMt2NonAutoNonGcSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE;
    	oppty.Account.Region__c = 'EMEA'; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2LtThresholdAutoGC() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2GtThresholdAutoGC() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_VP * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, oppty.VP_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdMT1});
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2LtThresholdAutoSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_SAP; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2GtThresholdAutoSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_SAP; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_VP * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, oppty.VP_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdMT1});
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2LtThresholdNonAutoGC() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2GtThresholdNonAutoGC() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_VP * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2LtThresholdNonAutoSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_SAP; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2GtThresholdNonAutoSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_SAP; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_VP * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2LtThresholdNonAutoNonGcSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE;
    	oppty.Account.Region__c = 'EMEA'; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApprover2IdGeneralWithMt2GtThresholdNonAutoNonGcSAP() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_NON_AUTOMOTIVE;
    	oppty.Account.Region__c = 'EMEA'; 
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_VP * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    }
    
    @isTest
    static void testVpApproverIdGeneralWithoutMt2Deduplication() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Owner.MT_1__c = userIdAuto;
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, OpportunityApproval.getVpApprover1ID(oppty));
    	System.assertEquals(userIdAuto, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, oppty.Regional_VP_Approver__c);
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdAuto}); 
    }
    
    @isTest
    static void testVpApproverIdGeneralWithoutMt2NoDuplication() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Owner;
    	update oppty.Account;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, OpportunityApproval.getVpApprover1ID(oppty));
    	System.assertEquals(userIdMT1, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, oppty.Regional_VP_Approver__c);
    	System.assertEquals(userIdMT1, oppty.VP_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdAuto, userIdMT1});
    }
    
    @isTest
    static void testMagApproverIdGeneralLtThreshold() {
    	Test.startTest();
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> magApproverIDs = OpportunityApproval.getMagApproverIdsWithMag(oppty);
    	
    	System.assertEquals(null, magApproverIDs.get(MAG_SHORT_LIVED));
    	System.assertEquals(null, magApproverIDs.get(MAG_LIFETIME));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setMagApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    }
    
    @isTest
    static void testMagApproverIdGeneralGtThreshold() {
    	Test.startTest();
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_MAG * 2);
    	Test.stopTest();
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> magApproverIDs = OpportunityApproval.getMagApproverIdsWithMag(oppty);
    	
    	System.assertEquals(userIdMAG, magApproverIDs.get(MAG_SHORT_LIVED));
    	System.assertEquals(userIdMAG, magApproverIDs.get(MAG_LIFETIME));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setMagApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMAG, oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdMAG});
    }
    
    @isTest
    static void testMagApproverIdGeneralGtThresholdNoApproverFound() {
    	String mag1 = 'RAB'; // not in approver matrix 
    	String mag2 = 'RDC'; // not in approver matrix
    	
    	Test.startTest();
    	for (Integer i = 0; i < opptyProds.size(); i++) {
    		OpportunityLineItem oli = opptyProds.get(i);
    		Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
            	oli.PricebookEntry.Product2.MAG__c = mag1;	
            } else {
            	oli.PricebookEntry.Product2.MAG__c = mag2;	
            }
    	
    		update oli.PricebookEntry.Product2; 	
    	}
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_MAG * 2);
    	Test.stopTest();
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> magApproverIDs = OpportunityApproval.getMagApproverIdsWithMag(oppty);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), magApproverIDs.get(mag1));
    	System.assertEquals(CommonUtils.getDataAdminUserID(), magApproverIDs.get(mag2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	    	
    	OpportunityApproval.setMagApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{CommonUtils.getDataAdminUserID()});
    }
    
    @isTest
    static void testMagApproverIdLtThresholdSTAR() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> magApproverIDs = OpportunityApproval.getMagApproverIdsWithMag(oppty);
    	
    	System.assertEquals(null, magApproverIDs.get(MAG_SHORT_LIVED));
    	System.assertEquals(null, magApproverIDs.get(MAG_LIFETIME));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setMagApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    }
    
    @isTest
    static void testMagApproverIdGtThresholdSTAR() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_MAG * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> magApproverIDs = OpportunityApproval.getMagApproverIdsWithMag(oppty);
    	
    	System.assertEquals(userIdMagSTAR, magApproverIDs.get(MAG_SHORT_LIVED));
    	System.assertEquals(userIdMagSTAR, magApproverIDs.get(MAG_LIFETIME));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setMagApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMagSTAR, oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdMagSTAR});
    }
    
    @isTest
    static void testMagApproverIdGtThresholdNoApproverFoundSTAR() {
    	String mag1 = 'RAB'; // not in approver matrix 
    	String mag2 = 'RDC'; // not in approver matrix
    	
    	Test.startTest();
    	for (Integer i = 0; i < opptyProds.size(); i++) {
    		OpportunityLineItem oli = opptyProds.get(i);
    		Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
            	oli.PricebookEntry.Product2.MAG__c = mag1;	
            } else {
            	oli.PricebookEntry.Product2.MAG__c = mag2;	
            }
    	
    		update oli.PricebookEntry.Product2; 	
    	}
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_MAG * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> magApproverIDs = OpportunityApproval.getMagApproverIdsWithMag(oppty);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), magApproverIDs.get(mag1));
    	System.assertEquals(CommonUtils.getDataAdminUserID(), magApproverIDs.get(mag2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	    	
    	OpportunityApproval.setMagApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{CommonUtils.getDataAdminUserID()});
    }
    
    @isTest
    static void testMagApproverIdLtThresholdSamsung() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> magApproverIDs = OpportunityApproval.getMagApproverIdsWithMag(oppty);
    	
    	System.assertEquals(null, magApproverIDs.get(MAG_SHORT_LIVED));
    	System.assertEquals(null, magApproverIDs.get(MAG_LIFETIME));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setMagApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    }
    
    @isTest
    static void testMagApproverIdGtThresholdSamsung() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_MAG * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> magApproverIDs = OpportunityApproval.getMagApproverIdsWithMag(oppty);
    	
    	System.assertEquals(userIdMAG, magApproverIDs.get(MAG_SHORT_LIVED));
    	System.assertEquals(userIdMAG, magApproverIDs.get(MAG_LIFETIME));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setMagApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMAG, oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdMAG});
    }
    
    @isTest
    static void testMagApproverIdGtThresholdNoApproverFoundSamsung() {
    	String mag1 = 'RAB'; // not in approver matrix 
    	String mag2 = 'RDC'; // not in approver matrix
    	
    	Test.startTest();
    	for (Integer i = 0; i < opptyProds.size(); i++) {
    		OpportunityLineItem oli = opptyProds.get(i);
    		Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
            	oli.PricebookEntry.Product2.MAG__c = mag1;	
            } else {
            	oli.PricebookEntry.Product2.MAG__c = mag2;	
            }
    	
    		update oli.PricebookEntry.Product2; 	
    	}
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_MAG * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> magApproverIDs = OpportunityApproval.getMagApproverIdsWithMag(oppty);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), magApproverIDs.get(mag1));
    	System.assertEquals(CommonUtils.getDataAdminUserID(), magApproverIDs.get(mag2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	    	
    	OpportunityApproval.setMagApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{CommonUtils.getDataAdminUserID()});
    }
    
    @isTest
    static void testBlApproverIdGeneralLtThreshold() {
    	Test.startTest();
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> blApproverIDs = OpportunityApproval.getBlApproverIdsWithBl(oppty);
    	
    	System.assertEquals(null, blApproverIDs.get(BL1));
    	System.assertEquals(null, blApproverIDs.get(BL2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setBlApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    }
    
    @isTest
    static void testBlApproverIdGeneralGtThreshold() {
    	Test.startTest();
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_BL * 2);
    	Test.stopTest();
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> blApproverIDs = OpportunityApproval.getBlApproverIdsWithBl(oppty);
    	
    	System.assertEquals(userIdBL, blApproverIDs.get(BL1));
    	System.assertEquals(userIdBL, blApproverIDs.get(BL2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setBlApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdBL, oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdBL});
    }
    
    @isTest
    static void testBlApproverIdGeneralGtThresholdNoApproverFound() {
    	String aBL1 = 'BL21'; // not in approver matrix 
    	String aBL2 = 'BL80'; // not in approver matrix
    	
    	Test.startTest();
    	for (Integer i = 0; i < opptyProds.size(); i++) {
    		OpportunityLineItem oli = opptyProds.get(i);
    		Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
            	oli.PricebookEntry.Product2.BL__c = aBL1;	
            } else {
            	oli.PricebookEntry.Product2.BL__c = aBL2;	
            }
    	
    		update oli.PricebookEntry.Product2; 	
    	}
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_BL * 2);
    	Test.stopTest();
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> blApproverIDs = OpportunityApproval.getBlApproverIdsWithBl(oppty);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), blApproverIDs.get(aBL1));
    	System.assertEquals(CommonUtils.getDataAdminUserID(), blApproverIDs.get(aBL2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	    	
    	OpportunityApproval.setBlApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{CommonUtils.getDataAdminUserID()});
    }
    
    @isTest
    static void testBlApproverIdLtThresholdSTAR() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> blApproverIDs = OpportunityApproval.getBlApproverIdsWithBl(oppty);
    	
    	System.assertEquals(null, blApproverIDs.get(BL1));
    	System.assertEquals(null, blApproverIDs.get(BL2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setBlApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    }
    
    @isTest
    static void testBlApproverIdGtThresholdSTAR() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_BL * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> blApproverIDs = OpportunityApproval.getBlApproverIdsWithBl(oppty);
    	
    	System.assertEquals(userIdBlSTAR, blApproverIDs.get(BL1));
    	System.assertEquals(userIdBlSTAR, blApproverIDs.get(BL2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setBlApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdBlSTAR, oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdBlSTAR});
    }
    
    @isTest
    static void testBlApproverIdGtThresholdNoApproverFoundSTAR() {
    	String aBL1 = 'BL21'; // not in approver matrix 
    	String aBL2 = 'BL80'; // not in approver matrix
    	
    	Test.startTest();
    	for (Integer i = 0; i < opptyProds.size(); i++) {
    		OpportunityLineItem oli = opptyProds.get(i);
    		Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
            	oli.PricebookEntry.Product2.BL__c = aBL1;	
            } else {
            	oli.PricebookEntry.Product2.BL__c = aBL2;	
            }
    	
    		update oli.PricebookEntry.Product2; 	
    	}
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_BL * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> blApproverIDs = OpportunityApproval.getBlApproverIdsWithBl(oppty);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), blApproverIDs.get(aBL1));
    	System.assertEquals(CommonUtils.getDataAdminUserID(), blApproverIDs.get(aBL2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	    	
    	OpportunityApproval.setBlApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{CommonUtils.getDataAdminUserID()});
    }
    
    @isTest
    static void testBlApproverIdLtThresholdSamsung() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, 100);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> blApproverIDs = OpportunityApproval.getBlApproverIdsWithBl(oppty);
    	
    	System.assertEquals(null, blApproverIDs.get(BL1));
    	System.assertEquals(null, blApproverIDs.get(BL2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setBlApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(null, oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    }
    
    @isTest
    static void testBlApproverIdGtThresholdSamsung() {
    	Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_BL * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> blApproverIDs = OpportunityApproval.getBlApproverIdsWithBl(oppty);
    	
    	System.assertEquals(userIdBL, blApproverIDs.get(BL1));
    	System.assertEquals(userIdBL, blApproverIDs.get(BL2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setBlApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdBL, oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdBL});
    }
    
    @isTest
    static void testBlApproverIdGtThresholdNoApproverFoundSamsung() {
    	String aBL1 = 'BL21'; // not in approver matrix 
    	String aBL2 = 'BL80'; // not in approver matrix
    	
    	Test.startTest();
    	for (Integer i = 0; i < opptyProds.size(); i++) {
    		OpportunityLineItem oli = opptyProds.get(i);
    		Integer rem = Math.mod(i, 2);
            
            if (rem == 0) {
            	oli.PricebookEntry.Product2.BL__c = aBL1;	
            } else {
            	oli.PricebookEntry.Product2.BL__c = aBL2;	
            }
    	
    		update oli.PricebookEntry.Product2; 	
    	}
    	
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung;
    	update oppty.Account;
    	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_BL * 2);
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	Map<String, ID> blApproverIDs = OpportunityApproval.getBlApproverIdsWithBl(oppty);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), blApproverIDs.get(aBL1));
    	System.assertEquals(CommonUtils.getDataAdminUserID(), blApproverIDs.get(aBL2));
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	    	
    	OpportunityApproval.setBlApproverIDs(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(CommonUtils.getDataAdminUserID(), oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{CommonUtils.getDataAdminUserID()});
    }
    
    @isTest
    static void testAllApproversGeneral() {
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Account;
 
		Test.startTest();   	
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_BL * 2);
    	
    	Map<String, String> approvers = new Map<String, String>();
    	
    	for (OpportunityService.DesignWinApprover dwa : OpportunityService.getDesignWinApprovers(new Set<Id>{opptyProd.OpportunityId}).get(opptyProd.OpportunityId)) {
    		approvers.put(dwa.label, dwa.name);	
    	}
    	
    	System.assertEquals(TEST_USER_MT2, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.SALES_DIRECTOR_APPROVER)));
    	System.assertEquals(TEST_USER_AUTO, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.REGIONAL_VP_APPROVER)));
    	System.assertEquals(TEST_USER_MT1, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.VP_APPROVER_2)));
    	System.assertEquals(TEST_USER_MAG, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.MAG_APPROVER_1)));
    	System.assertEquals(null, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.MAG_APPROVER_2)));
    	System.assertEquals(TEST_USER_BL, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.BL_APPROVER_1)));
    	System.assertEquals(null, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.BL_APPROVER_2)));
    	    	
    	OpportunityService.updateDesignWinApprovers(new Set<Id>{opptyProd.OpportunityId});
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT2, oppty.Sales_Director_Approver__c);
    	System.assertEquals(userIdAuto, oppty.Regional_VP_Approver__c);
    	System.assertEquals(userIdMT1, oppty.VP_Approver_2__c);
    	System.assertEquals(userIdMAG, oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    	System.assertEquals(userIdBL, oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdMT2, userIdAuto, userIdMT1, userIdMAG, userIdBL});
    	Test.stopTest();
    }
    
    @isTest
    static void testAllApproversSTAR() {
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSTAR; 
    	update oppty.Account;
    	
    	Test.startTest();
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_BL * 2);
    	    	
    	Map<String, String> approvers = new Map<String, String>();
    	
    	for (OpportunityService.DesignWinApprover dwa : OpportunityService.getDesignWinApprovers(new Set<Id>{opptyProd.OpportunityId}).get(opptyProd.OpportunityId)) {
    		approvers.put(dwa.label, dwa.name);	
    	}
    	
    	System.assertEquals(TEST_USER_GAM_STAR, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.SALES_DIRECTOR_APPROVER)));
    	System.assertEquals(TEST_USER_EVP_STAR, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.REGIONAL_VP_APPROVER)));
    	System.assertEquals(null, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.VP_APPROVER_2)));
    	System.assertEquals(TEST_USER_MAG_STAR, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.MAG_APPROVER_1)));
    	System.assertEquals(null, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.MAG_APPROVER_2)));
    	System.assertEquals(TEST_USER_BL_STAR, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.BL_APPROVER_1)));
    	System.assertEquals(null, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.BL_APPROVER_2)));
    	    	
    	OpportunityService.updateDesignWinApprovers(new Set<Id>{opptyProd.OpportunityId});
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdGamSTAR, oppty.Sales_Director_Approver__c);
    	System.assertEquals(userIdEvpSTAR, oppty.Regional_VP_Approver__c);
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    	System.assertEquals(userIdMagSTAR, oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    	System.assertEquals(userIdBlSTAR, oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdGamSTAR, userIdEvpSTAR, userIdMagSTAR, userIdBlSTAR});
    	Test.stopTest();
    }
    
    @isTest
    static void testAllApproversSamsung() {
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Account.ParentId = parentAccountIdSamsung; 
    	update oppty.Account;
    	
    	Test.startTest();
    	List<OpportunitySchedule__c> opptyScheds = [select Id from OpportunitySchedule__c where Opportunity__c = :opptyProd.OpportunityId];
    	delete opptyScheds;
    	
    	createOpportunitySchedules(opptyProd.OpportunityId, THRESHOLD_BL * 2);
    	    	
    	Map<String, String> approvers = new Map<String, String>();
    	
    	for (OpportunityService.DesignWinApprover dwa : OpportunityService.getDesignWinApprovers(new Set<Id>{opptyProd.OpportunityId}).get(opptyProd.OpportunityId)) {
    		approvers.put(dwa.label, dwa.name);	
    	}
    	
    	System.assertEquals(TEST_USER_GAM_SAMSUNG, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.SALES_DIRECTOR_APPROVER)));
    	System.assertEquals(TEST_USER_EVP_SAMSUNG, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.REGIONAL_VP_APPROVER)));
    	System.assertEquals(null, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.VP_APPROVER_2)));
    	System.assertEquals(TEST_USER_MAG, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.MAG_APPROVER_1)));
    	System.assertEquals(null, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.MAG_APPROVER_2)));
    	System.assertEquals(TEST_USER_BL, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.BL_APPROVER_1)));
    	System.assertEquals(null, approvers.get(OpportunityApproval.APPROVER_LABELS.get(OpportunityApproval.ApproverLabel.BL_APPROVER_2)));
    	    	
    	OpportunityService.updateDesignWinApprovers(new Set<Id>{opptyProd.OpportunityId});
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdGamSamsung, oppty.Sales_Director_Approver__c);
    	System.assertEquals(userIdEvpSamsung, oppty.Regional_VP_Approver__c);
    	System.assertEquals(null, oppty.VP_Approver_2__c);
    	System.assertEquals(userIdMAG, oppty.MAG_Approver_1__c);
    	System.assertEquals(null, oppty.MAG_Approver_2__c);
    	System.assertEquals(userIdBL, oppty.BL_Approver_1__c);
    	System.assertEquals(null, oppty.BL_Approver_2__c);
    	
    	testOpptyShare(new List<ID>{userIdGamSamsung, userIdEvpSamsung, userIdMAG, userIdBL});
    	Test.stopTest();
    }

    @isTest
    static void testGkamApproverIdGeneral() {
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setGlobalKeyAccountManagerApproverId(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	system.assertNotEquals(null, userIdGamGeneral);
    	system.assertEquals(userIdGamGeneral, oppty.Global_Key_Account_Manager__c);
    	
    	testOpptyShare(new List<ID>{userIdGamGeneral});
    }
    
    @isTest
    static void testGkamApproverIdGeneralGkamSameWithOwner() {
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	
		Test.startTest();
    	Approvers_Matrix__c amGamGeneral = [SELECT Id, Approver__c, Account__c FROM Approvers_Matrix__c WHERE Account__c = :oppty.Account.ParentId];
    	amGamGeneral.Approver__c = oppty.OwnerId;
    	update amGamGeneral;
    	Test.stopTest();
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setGlobalKeyAccountManagerApproverId(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	system.assertEquals(null, oppty.Global_Key_Account_Manager__c);
    }
    
    @isTest
    static void testGkamApproverIdGeneralSameWithSalesDirector() {
    	Test.startTest();
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        
        Approvers_Matrix__c amGamGeneral = [SELECT Id, Approver__c, Account__c FROM Approvers_Matrix__c WHERE Account__c = :oppty.Account.ParentId];   	
    	amGamGeneral.Approver__c = userIdMT2;
    	update amGamGeneral;
        Test.stopTest();
    	
    	System.assertEquals(userIdMT2, OpportunityApproval.getSalesDirectorApproverID(oppty));  
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setSalesDirectorApproverID(oppty, uow);
    	OpportunityApproval.setGlobalKeyAccountManagerApproverId(oppty, uow);
        
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT2, oppty.Sales_Director_Approver__c);
        System.assertEquals(null, oppty.Global_Key_Account_Manager__c);
    	
    	testOpptyShare(new List<ID>{userIdMT2});        
    }
    
    @isTest
    static void testGkamApproverIdGeneralSameWithVpApprover1() {
        Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE; 
    	update oppty.Owner;
    	update oppty.Account;
        Approvers_Matrix__c amGamGeneral = [SELECT Id, Approver__c, Account__c FROM Approvers_Matrix__c WHERE Account__c = :oppty.Account.ParentId];   	
    	amGamGeneral.Approver__c = userIdAuto;
    	update amGamGeneral;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, OpportunityApproval.getVpApprover1ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover1ID(oppty, uow);
        OpportunityApproval.setGlobalKeyAccountManagerApproverId(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdAuto, oppty.Regional_VP_Approver__c);
    	System.assertEquals(null, oppty.Global_Key_Account_Manager__c);
        
    	testOpptyShare(new List<ID>{userIdAuto}); 
    }
    
	@isTest
    static void testGkamApproverIdGeneralSameWithVpApprover2() {
        Test.startTest();
    	Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    	oppty.Owner.MT_2__c = null;
    	oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
    	oppty.Account.Region__c = REGION_GC; 
    	update oppty.Owner;
    	update oppty.Account;
        
        Approvers_Matrix__c amGamGeneral = [SELECT Id, Approver__c, Account__c FROM Approvers_Matrix__c WHERE Account__c = :oppty.Account.ParentId];   	
    	amGamGeneral.Approver__c = userIdMT1;
    	update amGamGeneral;
    	Test.stopTest();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, OpportunityApproval.getVpApprover2ID(oppty)); 
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setVpApprover2ID(oppty, uow);
        OpportunityApproval.setGlobalKeyAccountManagerApproverId(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	System.assertEquals(userIdMT1, oppty.VP_Approver_2__c);
        System.assertEquals(null, oppty.Global_Key_Account_Manager__c);
    	
    	testOpptyShare(new List<ID>{userIdMT1});
    }
    
    @isTest
    static void testGkamApproverIdGeneralWithoutApproverMatrix() {
        Test.startTest();
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        
        Approvers_Matrix__c amGamGeneral = [SELECT Id, Approver__c, Account__c FROM Approvers_Matrix__c WHERE Account__c = :oppty.Account.ParentId];   	
    	delete amGamGeneral;
    	Test.stopTest();
    	
    	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    	
    	OpportunityApproval.setGlobalKeyAccountManagerApproverId(oppty, uow);
    	
    	uow.commitWork();
    	
    	oppty = getOpportunity(opptyProd.OpportunityId);
    	
    	system.assertEquals(null, oppty.Global_Key_Account_Manager__c);
    }
    
    static Opportunity getOpportunity(Id opptyId) {
    	return new OpportunitiesSelector().selectByIdWithAccountAndOwner(new Set<Id> {opptyId}).get(0);    
    } 
    
    static void testOpptyShare(List<ID> userIDs) {
    	List<User> users = [select Id from User where Id in :userIDs];
    	
    	for (User u : users) {
    		System.runAs(u) {
    			Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
    			System.assert(true);	
    		}	
    	}
    }
}