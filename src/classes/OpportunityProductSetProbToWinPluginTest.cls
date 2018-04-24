@isTest
public class OpportunityProductSetProbToWinPluginTest {
	private static final String TEST_USER_PROFILE = 'Standard User';
	private static final String TEST_USER = 't_user_1';
	private static final String TEST_USER_MAG_STAR = 'uMagSTAR';
	private static final String TEST_USER_BL_STAR = 'uBlSTAR';
	private static final String TEST_USER_GAM_STAR = 'uGamSTAR';
	private static final String TEST_USER_GAM_SAMSUNG = 'uGamSAMS';
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
        
        List<User> users = [select Alias, MT_1__c, MT_2__c from User where Alias in (:TEST_USER, :TEST_USER_MAG, :TEST_USER_BL, :TEST_USER_MAG_STAR, :TEST_USER_BL_STAR, :TEST_USER_GAM_STAR, :TEST_USER_GAM_SAMSUNG, :TEST_USER_EVP_STAR, :TEST_USER_EVP_SAMSUNG, :TEST_USER_AUTO)];
        
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
    static void setup()
    {
    	Profile p = [select Id from Profile where Name = :TEST_USER_PROFILE];
    	
    	// insert test users
    	List<User> users = new List<User>();
    	users.add(newUser(TEST_USER_MAG_STAR, TEST_USER_MAG_STAR, p.Id));
    	users.add(newUser(TEST_USER_BL_STAR, TEST_USER_BL_STAR, p.Id));
    	users.add(newUser(TEST_USER_GAM_STAR, TEST_USER_GAM_STAR, p.Id));
    	users.add(newUser(TEST_USER_GAM_SAMSUNG, TEST_USER_GAM_SAMSUNG, p.Id));
    	users.add(newUser(TEST_USER_EVP_STAR, TEST_USER_EVP_STAR, p.Id));
    	users.add(newUser(TEST_USER_EVP_SAMSUNG, TEST_USER_EVP_SAMSUNG, p.Id));
    	users.add(newUser(TEST_USER_AUTO, TEST_USER_AUTO, p.Id));
    	users.add(newUser(TEST_USER_MT1, TEST_USER_MT1, p.Id));
    	users.add(newUser(TEST_USER_MT2, TEST_USER_MT2, p.Id));
    	users.add(newUser(TEST_USER_MAG, TEST_USER_MAG, p.Id));
    	users.add(newUser(TEST_USER_BL, TEST_USER_BL, p.Id));
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
    	
    	User u = createUser(TEST_USER, TEST_USER, p.Id);
        u.MT_1__c = userMT1.Id;
        u.MT_2__c = userMT2.Id;
        update u;
        
        // insert approvers
        List<Approvers_Matrix__c> ams = new List<Approvers_Matrix__c>();
        ams.add(newApproverMatrix('MAG Approver', MAG_SHORT_LIVED, null, THRESHOLD_MAG, userMAG.Id));
        ams.add(newApproverMatrix('MAG Approver', MAG_LIFETIME, null, THRESHOLD_MAG, userMAG.Id));
        ams.add(newApproverMatrix('BL Approver', BL1, null, THRESHOLD_BL, userBL.Id));
        ams.add(newApproverMatrix('BL Approver', BL2, null, THRESHOLD_BL, userBL.Id));
        ams.add(newApproverMatrix('MAG Approver', MAG_SHORT_LIVED, 'STAR', THRESHOLD_MAG, userMagSTAR.Id));
        ams.add(newApproverMatrix('MAG Approver', MAG_LIFETIME, 'STAR', THRESHOLD_MAG, userMagSTAR.Id));
        ams.add(newApproverMatrix('BL Approver', BL1, 'STAR', THRESHOLD_BL, userBlSTAR.Id));
        ams.add(newApproverMatrix('BL Approver', BL2, 'STAR', THRESHOLD_BL, userBlSTAR.Id));
        ams.add(newApproverMatrix('GAM', 'STAR', null, 0, userGamSTAR.Id));
        ams.add(newApproverMatrix('GAM', 'Samsung', null, 0, userGamSamsung.Id));
        ams.add(newApproverMatrix('EVP', 'STAR', null, THRESHOLD_VP, userEvpSTAR.Id));
        ams.add(newApproverMatrix('EVP', 'Samsung', null, THRESHOLD_VP, userEvpSamsung.Id));
        ams.add(newApproverMatrix('Segment VP', 'Automotive', null, THRESHOLD_VP, userAuto.Id));
        ams.add(newApproverMatrix('GSM Sales Director', null, null, 0, u.Id));
        ams.add(newApproverMatrix('GSM VP 1', null, null, THRESHOLD_VP, u.Id));
        ams.add(newApproverMatrix('GSM VP 2', 'Automotive', 'Greater China', THRESHOLD_VP, u.Id));
        ams.add(newApproverMatrix('GSM VP 2', 'Automotive', 'South Asia Pacific', THRESHOLD_VP, u.Id));
        insert ams;
        
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
    
    static User createUser(String alias, String lastName, ID profileID) {
    	User user = newUser(alias, lastName, profileID); 
    	insert user;
        
        return user;	
    }
    
    static User newUser(String alias, String lastName, ID profileID) {
    	String email = CommonUtils.generateGUID() + '@nxp.com.test123';
    	
    	User user = new User(EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
		user.Alias = alias;
		user.LastName = lastName;
		user.ProfileId = profileID;
		user.Email = email;
		user.UserName = email;
        user.Signed_ARIA__c = true;
        
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
    
    static Approvers_Matrix__c newApproverMatrix(String type, String criteria1, String criteria2, Double threshold1, ID approverID) {
    	Approvers_Matrix__c approverMatrix = new Approvers_Matrix__c();
    	approverMatrix.RecordTypeId = new ApproverMatrixesSelector().getRecordTypeId(ApproverMatrixesSelector.RecordType.DIRECT_OPPTY);
    	approverMatrix.Type__c = type;
    	approverMatrix.Criteria_1__c = criteria1;
    	approverMatrix.Criteria_2__c = criteria2;
    	approverMatrix.Threshold_1__c = threshold1;
    	approverMatrix.Approver__c = approverID;
    	    	
    	return approverMatrix;
    }
    
    static Opportunity getOpportunity(ID opptyID) {
        return [select LT_Value_USD__c, Sales_Director_Approver__c, Regional_VP_Approver__c, VP_Approver_2__c, 
        			   MAG_Approver_1__c, MAG_Approver_2__c, BL_Approver_1__c, BL_Approver_2__c,  
        			   Account.ParentId, Owner.MT_2__c 
        		  from Opportunity 
        		 where Id = :opptyID];    
    } 
    
    @isTest
    static void testPluginInvoke()
    {
        OpportunityProductSetProbToWinPlugin plugin = new OpportunityProductSetProbToWinPlugin();
        Map<String,String> parms = new Map<String,String>();
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        Test.startTest();
        parms.put('Id', oppty.Id);
        Process.PluginRequest request = new Process.PluginRequest(parms);
        Process.PluginResult result = plugin.invoke(request);
        Test.stopTest();
    }
    
    @isTest
    static void testPluginDescribe()
    {
        Test.startTest();
        OpportunityProductSetProbToWinPlugin plugin = new OpportunityProductSetProbToWinPlugin();
        Process.PluginDescribeResult result = plugin.describe();
        Test.stopTest();
    }
    
    @isTest
    static void testPluginInvokeException()
    {
        OpportunityProductSetProbToWinPlugin plugin = new OpportunityProductSetProbToWinPlugin();
        Map<String,String> parms = new Map<String,String>();
        delete [Select Id from Approvers_Matrix__c Where Type__c = 'GSM Sales Director'];
        Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
        Test.startTest();
        parms.put('Id', oppty.Id);
        Process.PluginRequest request = new Process.PluginRequest(parms);
        Process.PluginResult result = plugin.invoke(request);
        Test.stopTest();
    }
}