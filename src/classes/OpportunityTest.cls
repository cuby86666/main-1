/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
private class OpportunityTest {
    private static final String TYPE_PARENT_ACC = 'Parent_Account'; 
    private static final String TYPE_CHILD_ACC = 'Child_Account';
    private static final String TEST_USER_PROFILE = 'Standard User';
    private static final String TEST_USER_EMAIL = 'testuser@testorg.com.test';
    private static final String TEST_SYSTEM_ADMIN_EMAIL = 'testsystemadmin@testorg.com.test';
    private static final String TEST_INTEGRATION_USER_EMAIL = 'testintegrationuser@testorg.com.test';
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
    private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);
    private static final String STAGE_NAME = 'Initial Engagement';
    private static final String STAGE_LOST = 'Lost';
    private static final String STAGE_CANCELLED = 'Cancelled';
    private static final String STAGE_COMMITMENT = 'Commitment';
    private static String DW_APPROVAL_STATUS_OPEN = 'Open';
    private static String DW_APPROVAL_STATUS_APPROVED = 'Approved';
    private static String DW_APPROVAL_STATUS_LOST = 'Lost';
    private static String PROBABILITY_TO_WIN = '80% - 100%';
    private static final Decimal UNIT_PRICE = 2;
    private static final Double COMP_MULT = 5;
    private static final Double ONE_YEAR_PROD = 1500;
    private static final Double SHARE = 100;
    
    private static List<Opportunity> opptyList;
    private static Opportunity opptySfdc;
    private static Opportunity opptyMn;
    private static OpportunityLineItem opptyProdSfdc;
    private static OpportunityLineItem opptyProdMn;
    
    public static ID PARENT_RECORD_TYPE_ID;
    public static ID CHILD_RECORD_TYPE_ID;
    
    static{
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
        system.debug('=== After Insert Parent Account... ===');
        
        parentAcc = [SELECT Id FROM Account WHERE RecordTypeId =: PARENT_RECORD_TYPE_ID LIMIT 1];
        system.debug('*** Parent Account Id:' + parentAcc.Id + ' ***');
        
        // Insert Child Account
        Account childAcc = new Account(Name = 'Test Account', Region__c = 'EMEA', RecordTypeId = CHILD_RECORD_TYPE_ID, ParentId = parentAcc.Id);
        childAcc.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        insert childAcc;
        
        Account childAcc1 = new Account(Name = 'Test Account 1', Region__c = 'Japan', RecordTypeId = CHILD_RECORD_TYPE_ID, ParentId = parentAcc.Id);
        childAcc1.CMD_Industry_Segment__c = CBG_DEFAULT; // CMD_Industry_Segment__c: One of the criteria to determine claim values
        insert childAcc1;
        
        // Insert Countact
        Contact contact = new Contact(FirstName='test1', LastName='strLastName', Title = 'strTitle', Phone = '8123978919', email = 'test1@test.com', AccountID = childAcc.Id, CanAllowPortalSelfReg = false);
        insert contact;
        
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
        createSfdcOpportunities(STAGE_NAME, u, fxRates, childAcc, prods);
        createSfdcOpportunities(STAGE_LOST, u, fxRates, childAcc, prods);
        createMnOpportunities(STAGE_NAME, u, fxRates, childAcc, prods);
        Test.stopTest();
    }
    
    static void createSfdcOpportunities(String opptyStageName, User u, Map<String, FX_Rates__c> fxRates, Account a, List<Product2> prods){   
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
    
    static void createMnOpportunities(String opptyStageName, User u, Map<String, FX_Rates__c> fxRates, Account a, List<Product2> prods) {
        // Insert MN Opportunity        
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
        
        insert oppty;
        
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

    @isTest
    static void testOpportunityLostCancelledInfoDwApprovalStatus(){
        List<Opportunity> opptys;
        Map<ID, Opportunity> opptyLostCancelledInfo;
        
        opptySfdc = [
            SELECT Id,
                    StageName,
                    Lost_Date__c,
                    Lost_Description__c,
                    Lost_Reason__c,
                    Design_Win_Approval_Process__c
            FROM Opportunity
            WHERE RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND StageName =: STAGE_NAME
        ];
        
        system.assertEquals(NULL, opptySfdc.Lost_Date__c);

        // Update Opprtunity to Lost
        opptySfdc.StageName = STAGE_LOST;
        opptySfdc.Lost_Description__c = '[Lost]Test Lost Description';
        opptySfdc.Lost_Reason__c = '[Lost]Test Lost Reason';
        update opptySfdc;

        opptys = new List<Opportunity>{opptySfdc};
        opptyLostCancelledInfo = getOpptyLostCancelledInfo(opptys);
        system.assertEquals(date.today(), opptyLostCancelledInfo.get(opptySfdc.Id).Lost_Date__c);
        system.assertEquals('[Lost]Test Lost Description', opptyLostCancelledInfo.get(opptySfdc.Id).Lost_Description__c);
        system.assertEquals('[Lost]Test Lost Reason', opptyLostCancelledInfo.get(opptySfdc.Id).Lost_Reason__c);
        
        // Update Opportunity from Lost to Open
        opptySfdc.StageName = STAGE_NAME;
        update opptySfdc;
    
        opptys = new List<Opportunity>{opptySfdc};
        opptyLostCancelledInfo = getOpptyLostCancelledInfo(opptys);
        system.assertEquals(null, opptyLostCancelledInfo.get(opptySfdc.Id).Lost_Date__c);
        system.assertEquals(null, opptyLostCancelledInfo.get(opptySfdc.Id).Lost_Description__c);
        system.assertEquals(null, opptyLostCancelledInfo.get(opptySfdc.Id).Lost_Reason__c);
        
        // Update Opportunity from Open to Cancelled
        opptySfdc.StageName = STAGE_CANCELLED;
        opptySfdc.Lost_Description__c = '[Cancelled]Test Cancelled Description';
        opptySfdc.Lost_Reason__c = '[Cancelled]Test Cancelled Reason';
        update opptySfdc;        
    
        opptys = new List<Opportunity>{opptySfdc};
        opptyLostCancelledInfo = getOpptyLostCancelledInfo(opptys);
        system.assertEquals(date.today(), opptyLostCancelledInfo.get(opptySfdc.Id).Lost_Date__c);
    }

    @isTest
    static void testDesignWinApprovalStatus(){          
        List<Opportunity> opptys;
        Map<ID, Opportunity> opptyDwApprovalStatuses;
            
        opptySfdc = [
            SELECT  Id,
                    StageName,
                    Design_Win_Approval_Process__c
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND StageName =: STAGE_NAME
        ];
        
        system.assertEquals(DW_APPROVAL_STATUS_OPEN, opptySfdc.Design_Win_Approval_Process__c);
 
        // Update Opportunity Stage to Lost
        opptySfdc.StageName = STAGE_LOST;
        update opptySfdc;

        opptys = new List<Opportunity>{opptySfdc};
        opptyDwApprovalStatuses = getOpptyDwApprovalStatus(opptys);
        system.assertEquals(DW_APPROVAL_STATUS_LOST, opptyDwApprovalStatuses.get(opptySfdc.Id).Design_Win_Approval_Process__c);
        
        // Update Opportunity Stage from Lost to Initial Engagement
        opptySfdc.StageName = STAGE_NAME;
        update opptySfdc;
        
        opptys = new List<Opportunity>{opptySfdc};
        opptyDwApprovalStatuses = getOpptyDwApprovalStatus(opptys);
        system.assertEquals(DW_APPROVAL_STATUS_OPEN, opptyDwApprovalStatuses.get(opptySfdc.Id).Design_Win_Approval_Process__c);
        
        //create new Opportunity with Lost Stage
        
    }

    @isTest
    static void testOpptyHelpNeededHistory(){
        List<Opportunity> opptys;
        List<Opportunity> opptyUpdateList = new List<Opportunity>();
        Map<Id, Opportunity> opptyHelpNeededHistory;
        
        opptySfdc = [
            SELECT  Id,
                    Help_Needed__c,
                    Help_Needed_History__c,
                    RecordTypeId
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND StageName = : STAGE_NAME
        ];
        
        opptyMn = [
            SELECT  Id,
                    Help_Needed__c,
                    Help_Needed_History__c,
                    RecordTypeId
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getMnRecordTypeId()
        ];

        system.assertEquals(NULL, opptySfdc.Help_Needed_History__c);
        system.assertEquals(NULL, opptyMn.Help_Needed_History__c);
    
        opptySfdc.Help_Needed__c = '[SFDC Oppty]Test Help Needed v1';
        opptyUpdateList.add(opptySfdc);        
        opptyMn.Help_Needed__c = '[MN Oppty]Test Help Needed v1';
        opptyUpdateList.add(opptyMn);
        update opptyUpdateList;
        
        opptyUpdateList = new List<Opportunity>();
        opptySfdc.Help_Needed__c = '[SFDC Oppty]Test Help Needed v2';
        opptyUpdateList.add(opptySfdc);        
        opptyMn.Help_Needed__c = '[MN Oppty]Test Help Needed v2';
        opptyUpdateList.add(opptyMn);   
        update opptyUpdateList;

        opptys = new List<Opportunity>{opptySfdc, opptyMn};
        opptyHelpNeededHistory = getHelpNeededHistory(opptys);
        system.assertEquals('[SFDC Oppty]Test Help Needed v1', opptyHelpNeededHistory.get(opptySfdc.Id).Help_Needed_History__c);
        system.assertEquals('[MN Oppty]Test Help Needed v1', opptyHelpNeededHistory.get(opptyMn.Id).Help_Needed_History__c);
    }
    
    @isTest
    static void testParentAccountIdTextAndAccountRegionText(){
        List<Opportunity> opptysUpdate;
        Map<ID, Opportunity> opptyParentAccountAndAccountRegion = new Map<ID, Opportunity>();
        
        opptySfdc = [
            SELECT  Id,
                    Account.ParentId,
                    Parent_Account_ID_Text__c,
                    Account.Region__c,
                    Account_Region_TEXT__c
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND StageName = : STAGE_NAME
        ];
        
        opptyMn = [
            SELECT  Id,
                    Account.ParentId,
                    Parent_Account_ID_Text__c,
                    Account.Region__c,
                    Account_Region_TEXT__c
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getMnRecordTypeId()
        ];
        
        system.assertEquals(string.valueof(opptySfdc.Account.ParentId).substring(0, 15), opptySfdc.Parent_Account_ID_Text__c);
        system.assertEquals(string.valueof(opptyMn.Account.ParentId).substring(0, 15), opptyMn.Parent_Account_ID_Text__c);
        system.assertEquals(string.valueof(opptySfdc.Account.Region__c), opptySfdc.Account_Region_TEXT__c);
        system.assertEquals(string.valueof(opptyMn.Account.Region__c), opptyMn.Account_Region_TEXT__c);
        
        // Update Account of Opportunity
        
        Account accJapan = [SELECT Id, ParentId, Region__c FROM Account WHERE Region__c = 'Japan' LIMIT 1];
        opptySfdc.AccountId = accJapan.Id;
        opptyMn.AccountId = accJapan.Id;
        opptysUpdate = new List<Opportunity>{opptySfdc, opptyMn};
        update opptysUpdate;
        
        opptyParentAccountAndAccountRegion = getOpptyParentAccountAndAccountRegion(opptysUpdate);
        
        system.assertEquals(String.valueOf(accJapan.ParentId).substring(0, 15), opptyParentAccountAndAccountRegion.get(opptySfdc.Id).Parent_Account_ID_Text__c);
        system.assertEquals(String.valueOf(accJapan.ParentId).substring(0, 15), opptyParentAccountAndAccountRegion.get(opptyMn.Id).Parent_Account_ID_Text__c);
        system.assertEquals(accJapan.Region__c, opptyParentAccountAndAccountRegion.get(opptySfdc.Id).Account_Region_TEXT__c);
        system.assertEquals(accJapan.Region__c, opptyParentAccountAndAccountRegion.get(opptyMn.Id).Account_Region_TEXT__c);
    }
  
    @isTest
    static void testOpportunityStarInfo(){
        List<Opportunity> opptys;
        Map<ID, Opportunity> opptyStarInfo;
        
        opptySfdc = [
            SELECT  Id,
                    AccountId,
                    ASSE_Qual_plan_requested_by__c,
                    Qual_Plan_requested__c,
                    Customer_DRI__c,
                    Star_contact_window_identified__c,
                    APN_Rate__c,
                    APN_assigned__c,
                    BL_DRI_New__c,
                    Internal_Concept_realized__c,
                    Percentage_to_DW_Completion__c,
                    Paper_slides_prepped_and_discussion_with__c,
                    Discussion_with_Star_occurred_follow__c,
                    Samples_available__c,
                    Project_Known__c,
                    Sampled_to_Dev_Build__c,
                    Sampled_to_Proto_Build__c,
                    Show_up_on_MPS_IO_File_12_16_weeks_be__c,
                    Qual_Complete__c,
                    EVT_Done__c,
                    DVT_Done__c
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND StageName = : STAGE_NAME
        ];
        
        system.assertEquals(false, opptySfdc.Qual_Plan_requested__c);
        system.assertEquals(false, opptySfdc.Star_contact_window_identified__c);
        system.assertEquals(false, opptySfdc.APN_assigned__c);
        system.assertEquals(false, opptySfdc.Internal_Concept_realized__c);
        system.assertEquals(null, opptySfdc.Percentage_to_DW_Completion__c);
        
        Contact testContact = [SELECT Id FROM Contact WHERE Account.RecordTypeId = :CHILD_RECORD_TYPE_ID AND AccountId = :opptySfdc.AccountId LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :TEST_USER_PROFILE LIMIT 1];
 
        opptySfdc.ASSE_Qual_plan_requested_by__c = testContact.Id;
        opptySfdc.Customer_DRI__c = testContact.Id;
        opptySfdc.APN_Rate__c = 100;
        opptySfdc.BL_DRI_New__c = 'Test';
        opptySfdc.Internal_Concept_realized__c = true;
        opptySfdc.Star_contact_window_identified__c = true;
        opptySfdc.Paper_slides_prepped_and_discussion_with__c = true;
        opptySfdc.Discussion_with_Star_occurred_follow__c = true;
        opptySfdc.Samples_available__c = true;
        opptySfdc.Project_Known__c = true;
        opptySfdc.APN_assigned__c = true;
        opptySfdc.Sampled_to_Dev_Build__c = true;
        opptySfdc.Qual_Plan_requested__c = true;
        opptySfdc.Sampled_to_Proto_Build__c = true;
        opptySfdc.Show_up_on_MPS_IO_File_12_16_weeks_be__c = true;
        opptySfdc.Qual_Complete__c = true;
        opptySfdc.EVT_Done__c = true;
        opptySfdc.DVT_Done__c = true;        
        update opptySfdc;
        
        opptys = new List<Opportunity>{opptySfdc};
        opptyStarInfo = getStarInformation(opptys);
        
        system.assertEquals(true, opptyStarInfo.get(opptySfdc.Id).Qual_Plan_requested__c);
        system.assertEquals(true, opptyStarInfo.get(opptySfdc.Id).Star_contact_window_identified__c);
        system.assertEquals(true, opptyStarInfo.get(opptySfdc.Id).APN_assigned__c);
        system.assertEquals(true, opptyStarInfo.get(opptySfdc.Id).Internal_Concept_realized__c);
    }

    @isTest
    static void testProbabilityToWin(){
        List<Opportunity> opptys;
        Map<ID, Opportunity> opptyProbablityToWin;
        
        opptySfdc = [
            SELECT  Id, Probability_to_Win__c, Design_Win_Approval_Process__c
            FROM    Opportunity
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND StageName = : STAGE_NAME
            LIMIT 1
        ];
        
        opptySfdc.Design_Win_Approval_Process__c = DW_APPROVAL_STATUS_APPROVED;
        update opptySfdc;
        
        opptys = new List<Opportunity>{opptySfdc};
        opptyProbablityToWin = getProbabilityToWin(opptys);
        
        system.assertEquals(PROBABILITY_TO_WIN, opptyProbablityToWin.get(opptySfdc.Id).Probability_to_Win__c);
    }
    
    @isTest
    static void testLastBusinessModifiedDateAndLastBusinessModifiedDate(){
        Map<ID, Opportunity> opptyLastModifiedInfo = new Map<ID, Opportunity>();
        List<Opportunity> opptysNew;
        
        Account childAccount = [SELECT Id FROM Account WHERE Account.RecordTypeId = :CHILD_RECORD_TYPE_ID LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :TEST_USER_PROFILE LIMIT 1];
        User admin = [SELECT Id FROM User WHERE ProfileId = :CommonUtils.getSystemAdminProfileID() AND isActive = true LIMIT 1];
        User igUser = [SELECT Id FROM User WHERE ProfileId = :CommonUtils.getIntegrationUserProfileID() AND isActive = true LIMIT 1];
        
        opptySfdc = [
            SELECT  Id, Last_Business_Modified_By_Id__c, Last_Business_Modified_Date__c
            FROM    Opportunity
            LIMIT 1
        ];
        
        system.assertNotEquals(null, opptySfdc.Last_Business_Modified_By_Id__c);
        system.assertNotEquals(null, opptySfdc.Last_Business_Modified_Date__c);   
        
        Opportunity opptyNew1 = new Opportunity(
            Name = 'Test Oppty',
            RecordTypeId = OpportunitiesSelector.getSfdcRecordTypeId(),
            AccountId = childAccount.Id,
            StageName = STAGE_NAME,
            CurrencyIsoCode = CCY_CODE_DEFAULT,
            Production_Date__c = date.today() + 60,
            CloseDate = date.today() + 30
        );
        
        system.runAs(testUser) {
            insert opptyNew1;
        }

        opptysNew = new List<Opportunity>{opptyNew1};
        opptyLastModifiedInfo = getOpptyLastModifiedInfo(opptysNew);
        
        system.assertEquals(testUser.Id, opptyLastModifiedInfo.get(opptyNew1.Id).Last_Business_Modified_By_Id__c);
        system.assertNotEquals(null, opptyLastModifiedInfo.get(opptyNew1.Id).Last_Business_Modified_Date__c);       
        
        system.runAs(admin) {
            update opptyNew1;
        }
        
        opptysNew = new List<Opportunity>{opptyNew1};
        opptyLastModifiedInfo = getOpptyLastModifiedInfo(opptysNew);
        
        system.assertEquals(testUser.Id, opptyLastModifiedInfo.get(opptyNew1.Id).Last_Business_Modified_By_Id__c);
        
        Opportunity opptyNew2 = new Opportunity(
            Name = 'Test Oppty',
            RecordTypeId = OpportunitiesSelector.getSfdcRecordTypeId(),
            AccountId = childAccount.Id,
            StageName = STAGE_NAME,
            CurrencyIsoCode = CCY_CODE_DEFAULT,
            Production_Date__c = date.today() + 60,
            CloseDate = date.today() + 30
        );
        
        system.runAs(admin) {
            insert opptyNew2;
        }
        
        opptysNew = new List<Opportunity>{opptyNew2};
        opptyLastModifiedInfo = getOpptyLastModifiedInfo(opptysNew);
        
        system.assertEquals(admin.Id, opptyLastModifiedInfo.get(opptyNew2.Id).Last_Business_Modified_By_Id__c);
        
        opptyNew2.OwnerId = testUser.Id;
        
        system.runAs(admin) {
            update opptyNew2;
        }

        system.runAs(testUser) {
            update opptyNew2;
        }
        
        opptysNew = new List<Opportunity>{opptyNew2};
        opptyLastModifiedInfo = getOpptyLastModifiedInfo(opptysNew);
        
        system.assertEquals(testUser.Id, opptyLastModifiedInfo.get(opptyNew2.Id).Last_Business_Modified_By_Id__c);
        
        system.runAs(igUser) {
            update opptyNew2;
        }
        
        opptysNew = new List<Opportunity>{opptyNew2};
        opptyLastModifiedInfo = getOpptyLastModifiedInfo(opptysNew);
        
        system.assertEquals(testUser.Id, opptyLastModifiedInfo.get(opptyNew2.Id).Last_Business_Modified_By_Id__c);
    }
    
    @isTest
    static void testCurrencyAndLockedExchangeRate() {
        Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
        Map<ID, Opportunity> opptyFxRates = new Map<ID, Opportunity>();
        List<Opportunity> opptys;
        FX_Rates__c fxRateUpdate;
        List<FX_Rates__c> fxRatesUpdate = new List<FX_Rates__c>();
        Double exchangeRateBeforeLost;
        
        opptySfdc = [
            SELECT  Id, StageName, CurrencyIsoCode, Currency__c, Locked_Exchange_Rate__c, Design_Win_Approval_Process__c
            FROM    Opportunity
            WHERE   Design_Win_Approval_Process__c = :DW_APPROVAL_STATUS_OPEN 
                    AND CurrencyIsoCode != NULL
                    AND RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId()
            LIMIT 1
        ];
        
        opptyMn = [
            SELECT  Id, StageName, CurrencyIsoCode, Currency__c, Locked_Exchange_Rate__c, Design_Win_Approval_Process__c
            FROM    Opportunity
            WHERE   Design_Win_Approval_Process__c = :DW_APPROVAL_STATUS_OPEN 
                    AND CurrencyIsoCode != NULL
                    AND RecordTypeId = :OpportunitiesSelector.getMnRecordTypeId()
            LIMIT 1
        ];
        
        fxRates = getFxRates();
        
        system.assertEquals(fxRates.get(opptySfdc.CurrencyIsoCode).Id, opptySfdc.Currency__c);
        system.assertEquals(fxRates.get(opptySfdc.CurrencyIsoCode).Exchange_Rate__c, opptySfdc.Locked_Exchange_Rate__c);
        system.assertEquals(fxRates.get(opptyMn.CurrencyIsoCode).Id, opptyMn.Currency__c);
        
        fxRateUpdate = new FX_Rates__c(
            Id = fxRates.get(opptySfdc.CurrencyIsoCode).Id,
            Exchange_Rate__c = fxRates.get(opptySfdc.CurrencyIsoCode).Exchange_Rate__c + 0.01
        );
        //fxRatesUpdate.add(fxRateUpdate);
        update fxRateUpdate;
        
        opptys = new List<Opportunity>{opptySfdc, opptyMn};
        update opptys;
        
        opptyFxRates = getOpptyCurrenyLockedExchangeRate(opptys);
        fxRates = getFxRates();
        
        system.assertEquals(fxRates.get(opptySfdc.CurrencyIsoCode).Exchange_Rate__c, opptyFxRates.get(opptySfdc.Id).Locked_Exchange_Rate__c);

        // Update SFDC Oppty to Lost
        exchangeRateBeforeLost = opptyFxRates.get(opptySfdc.Id).Locked_Exchange_Rate__c;
        
        fxRateUpdate = new FX_Rates__c(
            Id = fxRates.get(opptySfdc.CurrencyIsoCode).Id,
            Exchange_Rate__c = EXCH_RATE_USD
        );      
        update fxRateUpdate;
        
        opptySfdc.StageName = STAGE_LOST;
        update opptySfdc;
        
        fxRates = getFxRates();
        
        system.assertNOTEquals(fxRates.get(opptySfdc.CurrencyIsoCode).Exchange_Rate__c, opptyFxRates.get(opptySfdc.Id).Locked_Exchange_Rate__c);
    }
    /* Removed for One Funnel 2.0 project
    @isTest
    static void testMNOpptyDesignWinApprovalStatus(){
        Map<ID, Opportunity> opptyDWApprovalStatus = new Map<ID, Opportunity>();
        List<Opportunity> opptys;
        
        opptyMn = [
            SELECT  Id, StageName, Design_Win_Approval_Process__c 
            FROM    Opportunity 
            WHERE   RecordTypeId = :OpportunitiesSelector.getMnRecordTypeId() AND StageName = :STAGE_NAME
            LIMIT 1
        ];
        
        system.assertEquals(DW_APPROVAL_STATUS_OPEN, opptyMn.Design_Win_Approval_Process__c);
        
        opptyMn.StageName = STAGE_COMMITMENT;
        update opptyMn;
        
        opptys = new List<Opportunity>{opptyMn};
        opptyDWApprovalStatus = getOpptyDesignWinApprovalStatus(opptys);
        
        system.assertEquals(DW_APPROVAL_STATUS_APPROVED, opptyDWApprovalStatus.get(opptyMn.Id).Design_Win_Approval_Process__c);
        
        opptyMn.StageName = STAGE_LOST;
        update opptyMn;

        opptys = new List<Opportunity>{opptyMn};
        opptyDWApprovalStatus = getOpptyDesignWinApprovalStatus(opptys);
        
        system.assertEquals(DW_APPROVAL_STATUS_LOST, opptyDWApprovalStatus.get(opptyMn.Id).Design_Win_Approval_Process__c);     
    }
    */
    @isTest
    static void testOpptyProdLostCancelledInfo(){
        Map<Id, OpportunityLineItem> opptyProdLostCancelledInfo = new Map<Id, OpportunityLineItem>();
        List<Opportunity> opptysUpdate;
        
        Test.startTest();
        opptySfdc = [
            SELECT  Id, StageName, Design_Win_Approval_Process__c, Lost_Date__c, Lost_Description__c, Lost_Reason__c
            FROM    Opportunity 
            WHERE   RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId() AND StageName = :STAGE_NAME
            LIMIT 1
        ];    
        
        opptyProdSfdc = [
            SELECT  Id, Prod_Lost__c, Prod_Lost_Cancelled__c, Prod_Lost_Cancelled_Date__c, Prod_Lost_Reason__c, Prod_Lost_Cancelled_Reason__c
            FROM    OpportunityLineItem
            WHERE   OpportunityId = :opptySfdc.Id 
            LIMIT 1
        ];  
        
        opptyMn = [
            SELECT  Id, StageName, Design_Win_Approval_Process__c, Lost_Date__c, Expiration_Date__c, Lost_Description__c, Lost_Reason__c
            FROM    Opportunity 
            WHERE   RecordTypeId = :OpportunitiesSelector.getMnRecordTypeId() AND StageName = :STAGE_NAME
            LIMIT 1
        ];
        
        opptyProdMn = [
            SELECT  Id, Prod_Lost__c, Prod_Lost_Cancelled__c, Prod_Lost_Cancelled_Date__c, Prod_Lost_Reason__c, Prod_Lost_Cancelled_Reason__c
            FROM    OpportunityLineItem
            WHERE   OpportunityId = :opptyMn.Id
        ];
        
        system.assertEquals(false, opptyProdSfdc.Prod_Lost__c);
        system.assertEquals(false, opptyProdMn.Prod_Lost__c);
        
        opptysUpdate = new List<Opportunity>();
        
        opptyMn.StageName = STAGE_LOST;
        opptyMn.Lost_Reason__c = 'Lost';
        opptyMn.Lost_Description__c = 'Lost Description';
        opptysUpdate.add(opptyMn);
        
        opptySfdc.StageName = STAGE_LOST;
        opptySfdc.Lost_Reason__c = 'Lost';
        opptySfdc.Lost_Description__c = 'Lost Description';
        opptySfdc.Competitors__c = 'Test Competitor';
        opptysUpdate.add(opptySfdc);
        update opptysUpdate;
        Test.stopTest();
        
        opptyProdLostCancelledInfo = getOpptyProdLostCancelledInfo(opptysUpdate);
        
        system.assertEquals(true, opptyProdLostCancelledInfo.get(opptyProdMn.Id).Prod_Lost__c);
        system.assertEquals('Lost', opptyProdLostCancelledInfo.get(opptyProdMn.Id).Prod_Lost_Cancelled_Reason__c);
                
        system.assertEquals(true, opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost__c);
        system.assertEquals('Lost', opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost_Cancelled_Reason__c);
        system.assertEquals('Lost Description', opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost_Reason__c);
        system.assertEquals('Test Competitor', opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Competitor__c);
        
        // Update oppty from Lost to Initial Engagement
        opptysUpdate = new List<Opportunity>();
        
        opptySfdc.StageName = STAGE_NAME;
        opptysUpdate.add(opptySfdc);
        
        opptyMn.StageName = STAGE_NAME;
        opptyMn.Lost_Date__c = null;
        opptyMn.Lost_Reason__c = null;
        opptysUpdate.add(opptyMn);
        
        update opptysUpdate;
        
        opptyProdLostCancelledInfo = getOpptyProdLostCancelledInfo(opptysUpdate); 
        
        system.assertEquals(false, opptyProdLostCancelledInfo.get(opptyProdMn.Id).Prod_Lost__c);
        system.assertEquals(null, opptyProdLostCancelledInfo.get(opptyProdMn.Id).Prod_Lost_Cancelled_Reason__c);
        system.assertEquals(null, opptyProdLostCancelledInfo.get(opptyProdMn.Id).Prod_Lost_Reason__c); 
        
        system.assertEquals(true, opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost__c);
        system.assertEquals('Lost', opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost_Cancelled_Reason__c);
        system.assertEquals('Lost Description', opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Prod_Lost_Reason__c);
        system.assertEquals('Test Competitor', opptyProdLostCancelledInfo.get(opptyProdSfdc.Id).Competitor__c);             
    }
       
    static Map<Id, Opportunity> getOpptyLostCancelledInfo(List<Opportunity> opptys){
        set<ID> opptyIDs = new Set<ID>();
        
        for(Opportunity oppty : opptys){
            opptyIDs.add(oppty.Id);
        }
        
        MAP<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id, StageName, Lost_Date__c, Lost_Description__c, Lost_Reason__c
             FROM Opportunity
             WHERE Id in :opptyIDs]
        );
        
        return result;
    }
    
    static Map<Id, Opportunity> getOpptyDwApprovalStatus(List<Opportunity> opptys){
        Set<ID> opptyIDs = new Set<ID>();
        
        for(Opportunity oppty : opptys){
            opptyIDs.add(oppty.Id);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id, Design_Win_Approval_Process__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    }
    
    static Map<Id, Opportunity> getHelpNeededHistory(List<Opportunity> opptys){
        Set<ID> opptyIDs = new Set<ID>();
        
        for(Opportunity oppty : opptys){
            opptyIDs.add(oppty.Id);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id, Help_Needed__c, Help_Needed_History__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    }
  
    static Map<Id, Opportunity> getStarInformation(List<Opportunity> opptys){
        Set<ID> opptyIDs = new Set<ID>();
        
        for(Opportunity oppty : opptys){
            opptyIDs.add(oppty.Id);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id,
                    Qual_Plan_requested__c,
                    Star_contact_window_identified__c,
                    APN_assigned__c,
                    Internal_Concept_realized__c,
                    Percentage_to_DW_Completion__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    }
    
    static Map<Id, Opportunity> getProbabilityToWin(List<Opportunity> opptys){
        Set<ID> opptyIDs = new Set<ID>();
        
        for(Opportunity oppty : opptys){
            opptyIDs.add(oppty.Id);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id,
                    Probability_to_Win__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    }    
    
    static Map<ID, Opportunity> getOpptyLastModifiedInfo(List<Opportunity> opptysNew){
        Set<ID> opptyIDs = new Set<ID>();
        
        for (Opportunity opptyNew : opptysNew) {
            opptyIDs.add(opptyNew.Id);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id,
                    Last_Business_Modified_By_Id__c,
                    Last_Business_Modified_Date__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    }
    
    static Map<ID, Opportunity> getOpptyCurrenyLockedExchangeRate(List<Opportunity> opptysNew){
        Set<ID> opptyIDs = new Set<ID>();
        
        for (Opportunity opptyNew : opptysNew) {
            opptyIDs.add(opptyNew.Id);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id,
                    StageName,
                    CurrencyIsoCode, 
                    Currency__c, 
                    Locked_Exchange_Rate__c, 
                    Design_Win_Approval_Process__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    }
    
    static Map<String, FX_Rates__c> getFxRates(){
        Map<String, FX_Rates__c> result = new  Map<String, FX_Rates__c>();
         
        List<FX_Rates__c> fxRates = [
            SELECT Id, 
                    Name, 
                    CurrencyIsoCode, 
                    Exchange_Rate__c 
             FROM   FX_Rates__c
        ];
        
        for (FX_Rates__c fxr : fxRates) {
            result.put(fxr.Name, fxr);
        }
        
        return result;
    }
    
    static Map<ID, Opportunity> getOpptyDesignWinApprovalStatus(List<Opportunity> opptysNew){
        Set<ID> opptyIDs = new Set<ID>();
        
        for (Opportunity opptyNew : opptysNew) {
            opptyIDs.add(opptyNew.Id);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id,
                    StageName,
                    Design_Win_Approval_Process__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    }
    
    static Map<ID, OpportunityLineItem> getOpptyProdLostCancelledInfo(List<Opportunity> opptys) {
        Set<ID> opptyIDs = new Set<ID>();
        
        for (Opportunity oppty : opptys) {
            opptyIDs.add(oppty.Id);
        }
        
        Map<Id, OpportunityLineItem> result = new Map<Id, OpportunityLineItem>(
            [SELECT Id, 
                    Prod_Lost__c, 
                    Prod_Lost_Cancelled__c, 
                    Prod_Lost_Cancelled_Date__c, 
                    Prod_Lost_Reason__c, 
                    Prod_Lost_Cancelled_Reason__c,
                    Competitor__c
             FROM   OpportunityLineItem
             WHERE  OpportunityId in :opptyIDs]
        );      
        
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
    
    private static Map<ID, Opportunity> getOpptyParentAccountAndAccountRegion(List<Opportunity> opptys){
        Set<ID> opptyIDs = new Set<ID>();
        
        for (Opportunity oppty : opptys) {
            opptyIDs.add(oppty.Id);
        }
        
        Map<ID, Opportunity> result = new Map<ID, Opportunity>(
            [SELECT Id, AccountId, Account.ParentId, Parent_Account_ID_Text__c, Account_Region_TEXT__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    }
}