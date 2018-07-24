/************************************************************************************************************
 *  Modified By: Baji
 *  Modified Date: May 10, 2018 
 *  Description: Removed seealldata=true and created test methods to test pending approvers fucntionality on opportunity/Agreement/Rebate
 ************************************************************************************************************/
  
@isTest
private class PendingApprovalsSearchTest {
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
   // private static final Date PRODUCTION_DATE = Date.newInstance(2018, 05, 31);
    private static final Date PRODUCTION_DATE = system.today() + 1;
    private static final String PROD_LOST = 'Lost';
    private static final String PROD_CANCELLED = 'Cancelled';
        
    private static List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
    private static List<OpportunityLineItem> opptyProdsMN = new List<OpportunityLineItem>();
    private static OpportunityLineItem opptyProd;
    private static OpportunityLineItem opptyProdLT;
    private static OpportunityLineItem opptyProdMN;
   
    private static final String TYPE_OEM_EMS = 'OEM_EMS'; // Object: Rebate
    private static final String TYPE_OEM_EMS_Rebate_Product = 'OEM_EMS_Rebate_Product'; // Object: Rebate Product
    
    private static RecordType OEM_EMS;
    private static RecordType OEM_EMS_Rebate_Product;
    
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
                    PricebookEntry.Product2.MAG__c
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
        amcs.add(new Approvers_Matrix__c(Type__c = 'Segment VP', criteria_1__c = 'Automotive', Approver__c = u.Id, Threshold_1__c = 10000000));
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
            o = new Opportunity(Name = 'Test Oppty1', AccountId = a.Id, StageName = 'Initial Engagement'); //Todo: Not set AccountId for code coverage   
        } else {
            o = new Opportunity(Name = 'Test Oppty2', AccountId = a.Id, StageName = 'Initial Engagement');
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
        
        System.debug('after insert oppty' + o.id);
        
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
    static void testOpptySubmitForApproval() {
    
     
     opptyProd.Opportunity.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE;
     update opptyProd.Opportunity.Account;
     
        opptyProd.Opportunity.stagename = 'Decision';
        opptyProd.Opportunity.X90_Day_Maturity_Exception__c = true;
        opptyProd.Opportunity.Written_Confirmation_from_Customer__c = true;
        opptyProd.Opportunity.Compliance_Risk__c = 'Not Applicable';
        opptyProd.Opportunity.Industry_Segment__c = 'Automotive';
        opptyProd.Opportunity.Sub_Segment__c= 'ADAS';
    
        
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            Attachment attach=new Attachment();
            attach.ParentId=opptyProd.Opportunity.id;
            attach.Name='Unit Test Attachment';
            attach.body=bodyBlob;            
            insert attach;
            
       
        update opptyProd.Opportunity;
        
      Test.startTest();
      Opportunity oppty = getOpportunity(opptyProd.OpportunityId);
      oppty.Owner.MT_2__c = null;
      oppty.Account.CMD_Industry_Segment__c = CBG_AUTOMOTIVE; 
      update oppty.Owner;
      update oppty.Account;
    
      Test.stopTest();
    
      oppty = getOpportunity(opptyProd.OpportunityId);
      fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
      OpportunityApproval.setVpApprover1ID(oppty, uow);
      uow.commitWork();
      oppty = getOpportunity(opptyProd.OpportunityId);
  
      Opportunity opp = [select stagename,Product_Status__c,Opportunity_Min_Value_10K__c,Production_Date_after_Close_Date__c, Opportunity_90_Day_Maturity__c,
      DW_Evidence_Check_Box__c,Compliance_Assessment_Evidence_Check_Box__c,Production_Date__c, Regional_VP_Approver__c,
      VP_Approver_2__c,   Sales_Director_Approver__c,Active_Account__c, Claim_Value_USD__c,Locked_Exchange_Rate__c, One_Year_Pieces__c, RecordTypeId, Account.CMD_Industry_Segment__c,Industry_Segment__c
      from Opportunity where id=:opptyProd.Opportunity.id];
        
        system.debug('Testcheck1'+ opp.stagename);
        system.debug('Testcheck2'+ opp.Product_Status__c);
        system.debug('Testcheck3'+ opp.Opportunity_Min_Value_10K__c);
        system.debug('Testcheck4'+ opp.Production_Date_after_Close_Date__c);
        system.debug('Testcheck5'+ opp.Opportunity_90_Day_Maturity__c);
        system.debug('Testcheck6'+ opp.DW_Evidence_Check_Box__c);
        system.debug('Testcheck7'+ opp.Compliance_Assessment_Evidence_Check_Box__c);
        system.debug('Testcheck8'+ opp.Production_Date__c);
        system.debug('Testcheck9'+ opp.Regional_VP_Approver__c);
        system.debug('Testcheck10'+ opp.VP_Approver_2__c);
        system.debug('Testcheck11'+ opp.Sales_Director_Approver__c);
        system.debug('Testcheck12'+ opp.Active_Account__c);
        system.debug('Testcheck13'+ opp.Claim_Value_USD__c);
        system.debug('Testcheck14'+ opp.Locked_Exchange_Rate__c);
        system.debug('Testcheck15'+ opp.Industry_Segment__c);
        system.debug('Testcheck16'+ opp.Account.CMD_Industry_Segment__c);
        
       
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(opptyProd.Opportunity.id);
        Approval.ProcessResult result = Approval.process(app); 

        PendingApprovalsSearch PAS = new PendingApprovalsSearch();
    }
  
 
    
    static testMethod void testeRebateSubmitForApproval() 
    {
        //prepare test data
        
        fetchRecordType();
        
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            List<User> lstApprovers = TestUtil.createTestUsers(objProfile.Id, 18);
            insert lstApprovers;
            
            for(User objUser : lstApprovers)
            {
                system.assert(objUser.Id != null);
            }   
            
            User objApttusChecker = lstApprovers[0];            
            User objLegal = lstApprovers[1];
            User objCorpCotrol = lstApprovers[2];
            User objGlobalSalesOPS = lstApprovers[3];
            User objRegionalController = lstApprovers[4];
            User objRegionalChannelController = lstApprovers[5];
            User objGlobalChannelController = lstApprovers[6];
            User objRegionalDistiManager = lstApprovers[7];
            User objRegionalSalesManager  = lstApprovers[8];
            User objGSMController = lstApprovers[9];
            
            system.assert(objApttusChecker.Id != null);                        
            system.assert(objLegal.Id != null);
            system.assert(objCorpCotrol.Id != null);
            system.assert(objGlobalSalesOPS.Id != null);
            system.assert(objRegionalController.Id != null);
            system.assert(objRegionalChannelController.Id != null);            
            system.assert(objGlobalChannelController.Id != null);
            system.assert(objRegionalDistiManager.Id != null);
            system.assert(objRegionalSalesManager.Id != null);
            system.assert(objGSMController.Id != null);
               
            integer numOfProducts = 8;
            integer i;
            
            //insert products
            List<Product2> lstProducts = new List<Product2>();
            Product2 objProduct;
            
            for(i =0; i < numOfProducts ;  i++)
            {
                objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut' + i, isActive = true);
                lstProducts.add(objProduct);
            }
            insert lstProducts;
            
            //assert products       
            for(Product2 p : lstProducts)
            {
                system.assert(p.Id != null);
            }
                 
            //insert approver matrix
            List<Rebate_Approver_Matrix__c> lstRebateApprovers = new List<Rebate_Approver_Matrix__c>();
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Apttus Aggrement Checker' , Approver__c = objApttusChecker.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Legal' , Approver__c = objLegal.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Corporate Control' , Approver__c = objCorpCotrol.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Sales & OPS Manager' , Approver__c = objGlobalSalesOPS.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Controller' , Approver__c = objRegionalController.Id));           
            //Modified by Nisha Agrawal on May 14, 2018 for approval flow change
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA', Program_Type__c = 'OEM / EMS' , Role__c = 'Regional Channel Controller' , Approver__c = objRegionalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Channel Controller' , Approver__c = objGlobalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Disti Manager' , Approver__c = objRegionalDistiManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Sales Manager' , Approver__c = objRegionalSalesManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'GSM Controller' , Approver__c = objGSMController.Id));
                
            //insert MAG Approvers              
            for(i =0; i < numOfProducts ;  i++)
            {
                lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'BL Marketing Manager', MAG__c = 'ut' + i , Approver__c = lstApprovers[i + 10].Id));
            }
            insert lstRebateApprovers;
            
            for(Rebate_Approver_Matrix__c objApprover : lstRebateApprovers)
            {
                system.assert(objApprover.Id != null);
            }
            
            //insert FX_Rates       
            //fetch the Rebate Currency
            List<FX_Rates__c> lstRates = [Select Id , Name From FX_Rates__c Where Name = 'USD' Limit 1];
            FX_Rates__c rebateCurrency;
            
            if(lstRates.size() > 0)
            {
                rebateCurrency = lstRates[0];           
            }
            else
            {
                rebateCurrency = new FX_Rates__c(Name = 'USD' , Currency_Code__c = 'USD');
                insert rebateCurrency;
                
                system.assert(rebateCurrency.Id != null);
            }
           
            //insert Consolidated Account code
            Consolidated_Account_Code__c objCACC = new Consolidated_Account_Code__c();
            objCACC.Code_Description__c='123';
            insert objCACC;
            system.assert(objCACC.Id != null);
            
            //insert eRebate
           
            //New Recordtype created
            eRebate__c objRebate = new eRebate__c(
                Rebate_Program_Name__c = 'ut_program' , 
                Sales_Channel__c = 'OEM',  
                End_Customer__c ='ut_endcustomer', 
                Rebate_End_Date__c = date.today().addDays(30) , 
                Rebate_Effective_Date__c = date.today() , 
                Sales_Region__c = 'EMEA' , 
                Rebate_Currency__c = rebateCurrency.Id,  
                CurrencyIsoCode = 'USD', 
                Red_Flag__c = 'YES', 
                Material_Limitations_to_do_Business__c = true, 
                Consolidated_Account_Code_Description__c = objCACC.Id, 
                //Scarlett Capped_Payout_USD__c = 50000000, 
                Capped_Payout_USD__c = 100000000,
                Industry_Segment__c = 'Test', 
                Programe_Type__c = 'OEM / EMS',
                RecordType = OEM_EMS,
                Apttus_Agreement__c = true,
                Apttus_Agreement_Number__c = '4444'
            );
          
            insert objRebate;
            system.assert(objRebate.Id != null);
                        
            //start the Test        
            Test.startTest();
            
            //insert Rebate Products
            List<eRebate_Product__c> lstRebateLines = new List<eRebate_Product__c>();
            
          
            /****
            New fields created and remodify formula for calculating Total Estimated Rebate Amount
            Estimated Rebate Amount = (Booking Cost- Actual Cost) * Quantity
            ****/
            for(i=0; i < numOfProducts ;  i++)
            {
                lstRebateLines.add(
                    new eRebate_Product__c( 
                        eRebate__c = objRebate.Id , 
                        Price_Gap__c = (i * 10.0) , 
                        //Scarlett Quantity__c = 5, 
                        Quantity__c = 500000,
                        Product__c = lstProducts[i].Id,
                        Booking_Cost__c = 7.25,
                        Actual_Cost__c = 0.25,
                        RecordType = OEM_EMS_Rebate_Product
                    )
                );
            }
         
        
            insert lstRebateLines;
            
         objRebate = [Select Id , Apttus_Rebate_Checker__c, Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c, Total_Est_Rebate_Amount_USD__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
            
            system.debug('********Total Rebate Amount: ' + objRebate.Total_Est_Rebate_Amount_USD__c);
            
       
            //update the Rebate Product
            for(eRebate_Product__c rebateProduct : lstRebateLines)
            {
                rebateProduct.Line_Description__c = 'test';
//                rebateProduct.Quantity__c = 2000;
                rebateProduct.Price_Gap__c = 800;
            }

            update lstRebateLines;
            
            objRebate.Stage__c='Decision';
            update objRebate;
           
           eRebate__c eRebate = [select id,Stage__c, Apttus_Agreement__c from eRebate__c where id=:objRebate.id];
           system.debug('retestcheck1' + eRebate.stage__c);
           system.debug('retestcheck2' + eRebate.Apttus_Agreement__c);
           Test.stopTest();
           
        Approval.ProcessSubmitRequest appRebate = new Approval.ProcessSubmitRequest();
        appRebate.setObjectId(objRebate.id);
        Approval.ProcessResult result = Approval.process(appRebate); 

        PendingApprovalsSearch PAS2 = new PendingApprovalsSearch();
    }
  }
  
     
    private static void fetchRecordType(){
        for(RecordType rt: [SELECT  Id, DeveloperName 
                            FROM    RecordType 
                            WHERE IsActive = TRUE AND (
                            SobjectType = 'eRebate__c' or SobjectType = 'Rebate_Product__c')
                            ])
        {
            if(rt.DeveloperName == TYPE_OEM_EMS)                
                OEM_EMS = rt;
            if(rt.DeveloperName == TYPE_OEM_EMS_Rebate_Product)
                OEM_EMS_Rebate_Product = rt;
        }
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
        return [select Claim_Value_USD__c,Regional_VP_Approver__c, Account.Parentid,Account.Parent.name,Owner.id,Owner.name,Owner.MT_2__c,Production_Date__c, Locked_Exchange_Rate__c, One_Year_Pieces__c, RecordTypeId, Account.CMD_Industry_Segment__c
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
        return [select Id,MT_2__c from User where ProfileId = :CommonUtils.getSystemAdminProfileId() and Id != :CommonUtils.getDataAdminUserId() and IsActive = true limit 1];  
    }
    
}