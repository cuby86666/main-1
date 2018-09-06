@isTest
private class ModelNDesignRegistrationsProcessJobTest {
	
	private static final String STATUS_QUEUED = MnStages.STATUS_QUEUED;
	private static final String STATUS_PROCESSING = MnStages.STATUS_PROCESSING;
	private static final String STATUS_COMPLETED = MnStages.STATUS_COMPLETED;
	private static final String STATUS_DUPLICATED = MnStages.STATUS_DUPLICATED;
	private static final String STATUS_IGNORED = MnStages.STATUS_IGNORED;
	private static final String STATUS_FAILED = MnStages.STATUS_FAILED;
	
	private static final Date PRODUCTION_DATE = Date.newInstance(2014, 02, 16);
	private static final Date ACTION_DATE = Date.newInstance(2017, 02, 28); 
	private static final Date WIN_DATE = Date.newInstance(2012, 01, 08);
	
	private static final String REJECT_REASON = 'No Commercial Relation';
	
	private static final String STAGE_INITIAL_ENGAGEMENT = Opportunities.STAGE_INITIAL_ENGAGEMENT;
	private static final String STAGE_DISCOVERY = Opportunities.STAGE_DISCOVERY;
	private static final String STAGE_COMMITMENT = Opportunities.STAGE_COMMITMENT;
	private static final String STAGE_LOST = Opportunities.STAGE_LOST;
	private static final String STAGE_CANCELLED = Opportunities.STAGE_CANCELLED; 
	
	private static MnStage__c mnStage;
	private static String opptyExtId;
	private static String opptyProdExtId;
	private static PricebookEntry pricebookEntry12NC;
	private static Opportunity oppty;
	private static OpportunityLineItem opptyProd;
	
	static {
		List<MnStage__c> mnStages = (List<MnStage__c>)new MnStagesSelector().selectAll();
	
		if (mnStages.size() > 0) {
			mnStage = mnStages.get(0);
			opptyExtId = mnStage.Reg_Oppty_Num__c + '-' + mnStage.Reg_Part_OID__c;
			opptyProdExtId = mnStage.Reg_Part_OID__c;
			
			for (PricebookEntry pe : new PricebookEntriesSelector().selectByProdSalesItemWithProduct(new Set<String> {mnStage.Part_12NC__c})) {
					if (pricebookEntry12NC == null &&
						pe.Product2.Sales_Item__c == mnStage.Part_12NC__c &&
						pe.CurrencyIsoCode == mnStage.Currency_Code__c) {
						pricebookEntry12NC = pe;
					}	
			}
			
			oppty = ((List<Opportunity>)new OpportunitiesSelector().selectAll()).get(0);
    		opptyProd = new OpportunityLineItemsSelector().selectByOpptyIdWithOpportunity(new Set<Id> {oppty.Id}).get(0); 
    	}		
	}
    
    @testSetup
    static void setup() {
		MnStage__c mnStage = new MnStage__c();
		mnStage.Reg_OID__c = '874047';
		mnStage.Reg_Action_Date__c = ACTION_DATE;
		mnStage.Reg_Created_Date__c = Date.newInstance(2017, 02, 03);
		mnStage.Reg_Lead_Id__c = null;
		mnStage.Reg_Disti_Tracking_Num__c = '205069';
		mnStage.Reg_Status__c = 'Rejected';
		mnStage.Reg_Exchange_Rate__c = 0.92506938;
		mnStage.Reg_Is_Duplicated__c = false;
		mnStage.Reg_Modified_Date__c = Date.newInstance(2017, 10, 02);
		mnStage.Reg_Oppty_Num__c = '811152';
		mnStage.Reg_Production_Date__c = PRODUCTION_DATE;
		mnStage.Reg_Project_Units__c = 2000000;
		mnStage.Reg_Expiration_Date__c = Date.newInstance(2019, 09, 25);
		mnStage.Reg_Num__c = '1-CDSPKP';
		mnStage.Reg_Reject_Reason__c = REJECT_REASON;
		mnStage.Reg_Win_Date__c = Date.newInstance(2012, 01, 08);
		mnStage.Reg_Win_Status__c = 'DesignWin';
		mnStage.Reg_Is_Created_By_B2B__c = false;
		mnStage.Assembly_OID__c = '733710';
		mnStage.Assembly_Name__c = 'ASSV Lowend~Q1-ASSV Lowend';
		mnStage.Currency_OID__c = '15';
		mnStage.Currency_Code__c = 'EUR';
		mnStage.End_Cust_OID__c = '810397';
		mnStage.End_Cust_GID__c = '100378609';
		mnStage.End_Cust_Name__c = 'ALFMEIER PRAEZISION AG';
		mnStage.End_Cust_Loc__c = 'TREUCHTLINGEN';
		mnStage.Geo_End_Cust_OID__c = '1';
		mnStage.Geo_End_Cust_Region__c = 'EMEA';
		mnStage.Addr_End_Cust_OID__c = '1339139';
		mnStage.Addr_End_Cust_City__c = 'TREUCHTLINGEN';
		mnStage.Addr_End_Cust_State__c = null;
		mnStage.Addr_End_Cust_Zip__c = '91757';
		mnStage.Addr_End_Cust_Country__c = 'GERMANY';
		mnStage.Design_Cust_OID__c = '2';
		mnStage.Design_Cust_GID__c = '100378609';
		mnStage.Design_Cust_Name__c = 'ALFMEIER';
		mnStage.Design_Cust_Loc__c = 'TREUCHTLINGEN';
		mnStage.Geo_Design_Cust_OID__c = '1';
		mnStage.Geo_Design_Cust_Region__c = 'EMEA';
		mnStage.Addr_Design_Cust_OID__c = '1658923';
		mnStage.Addr_Design_Cust_City__c = 'TREUCHTLINGEN';
		mnStage.Addr_Design_Cust_State__c = null;
		mnStage.Addr_Design_Cust_Zip__c = null;
		mnStage.Addr_Design_Cust_Country__c = 'GERMANY';
		mnStage.Disti_OID__c = '1';
		mnStage.Disti_Name__c = 'ARROW EMEA';
		mnStage.Func_OID__c = '48';
		mnStage.Func_Name__c = 'Automotive:-Other';
		mnStage.Org_Disti_OID__c = '154';
		mnStage.Org_Disti_Branch__c = 'ARROW-NÜRNBERG [316654]';
		mnStage.User_OID__c = '617390';
		mnStage.User_Email__c = 'bernhard.kraemer@nxp.com';
		mnStage.User_First_Name__c = 'Bernhard';
		mnStage.User_Last_Name__c = 'Kraemer';
		mnStage.Prog_OID__c = '659292';
		mnStage.Prog_Name__c = 'ASSV Lowend~Q1-ASSV Lowend';
		mnStage.Reg_Part_OID__c = '1037233';
		mnStage.Reg_Part_ASP__c = 0.33;
		mnStage.Reg_Part_Margin_Qualification__c = null;
		mnStage.Reg_Part_Effort_Desc__c = 'Creation (FSL)';
		mnStage.Reg_Part_Effort_Pct__c = null;
		mnStage.Reg_Part_Disti_Tracking_Num__c = '205069';
		mnStage.Reg_Part_Is_Active__c = true;
		mnStage.Reg_Part_Status__c = 'Rejected';
		mnStage.Reg_Part_Is_Obsolete__c = false;
		mnStage.Reg_Part_POS_Qty_Shipped__c = 225000;
		mnStage.Reg_Part_POS_Resale_Value__c = 2356123.512539;
		mnStage.Reg_Part_Qty_Per_Sys__c = 1;
		mnStage.Reg_Part_Win_Status__c = 'Pending';
		mnStage.Reg_Part_One_Year_Value__c = 660000;
		mnStage.Reg_Part_Win_Date__c = WIN_DATE;
		mnStage.Reg_Part_Created_Date__c = Date.newInstance(2017, 02, 03);
		mnStage.Reg_Part_Modified_Date__c = Date.newInstance(2017, 09, 25);
		mnStage.Reg_Part_Final_Phase__c = 'No';
		mnStage.Reg_Part_Is_Expert_Certified__c = false;
		mnStage.Competitor_OID__c = '1';
		mnStage.Competitor_Name__c = 'OTHER';
		mnStage.Design_Confidence_OID__c = '2';
		mnStage.Design_Confidence__c = 0.5;
		mnStage.Part_OID__c = '128352';
		mnStage.Part_Name__c = 'S9S08SG4E2CTGR';
		mnStage.Part_12NC__c = '935313895518';
		mnStage.Part_Is_Root__c = false;
		mnStage.Part_Root__c = 'MC9S08SG';
		mnStage.Prod_Family_OID__c = '273';
		mnStage.Prod_Family__c = 'RGP';
		
		insert mnStage;
		
		List<MnStage__c> mnStages = (List<MnStage__c>)new MnStagesSelector().selectAll();
		System.assertEquals(STATUS_QUEUED, mnStages.get(0).Status__c);
		
		List<Product2> prods = new List<Product2>(); 
		
		Product2 prod = new Product2();
		prod.Name = 'Test Prod 1';
		prod.IsActive = true;
		prod.Sales_Item__c = mnStage.Part_12NC__c;
		prods.add(prod);
		
		prod = new Product2();
		prod.Name = 'Test Prod 2';
		prod.IsActive = true;
		prod.Basic_Type__c = mnStage.Part_Root__c;
		prods.add(prod);
		
		insert prods;
	
		processData();
	}
    
    @isTest
    static void testSetup() {
    	List<Opportunity> oppties = (List<Opportunity>)new OpportunitiesSelector().selectAll();
    	System.assertEquals(1, oppties.size());
    	
    	Opportunity oppty = oppties.get(0);
    	
        List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByOpptyIdWithOpportunity(new Set<Id> {oppty.Id});
        System.assertEquals(1, opptyProds.size());
        
        System.assertEquals(STATUS_COMPLETED, mnStage.Status__c);
    }
    
    @isTest
    static void testBatch() {
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	
    	insert mnStageClone;
    	
    	Test.startTest();
    	runBatch();
    	Test.stopTest();
    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Oppty_Num__c + '-' + mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(1, oppties.size());
    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(1, opptyProds.size());
    }
    
    @isTest
    static void testUpdateStatus() {
    	String jobId = '7070E00000MlbZUQAZ';
    	String message = 'some error';
    	
    	mnStage.Status__c = STATUS_PROCESSING;	
    	mnStage.Batch_Job_ID__c = jobId;
    	
    	update mnStage;
    	
    	new ModelNDesignRegistrationsProcessJob().updateStatus(jobId, message);
    	
    	MnStage__c ms = new MnStagesSelector().selectById(new Set<Id> {mnStage.Id}).get(0);
    	System.assertEquals(STATUS_FAILED, ms.Status__c);
    	System.assertEquals(message, ms.Message__c);
    }
    
    @isTest
    static void testNotify() {
    	try {
    		new ModelNDesignRegistrationsProcessJob().execute(null, null);		
    	} catch (Exception e) {
    		// ignored
    	}
    	
    	ModelNDesignRegistrationsProcessJob.notify(new List<String> {'testuser@nxp.com.test'}, 'test');
    }
    
    @isTest
    static void testScheduler() {
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	
    	insert mnStageClone;
    	
    	Datetime dt = Datetime.now().addDays(1);
        String CRON_EXP = '0 0 0 ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
    	
    	String schedJobId = System.schedule('TestModelNDesignRegistrationsProcessJob', CRON_EXP, new ModelNDesignRegistrationsProcessJob());
    	CronTrigger ct = [select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where Id = :schedJobId];
    	System.assertEquals(CRON_EXP, ct.CronExpression);
    	System.assertEquals(0, ct.TimesTriggered);
    	System.assertEquals(dt.format('yyyy-MM-dd 00:00:00'), String.valueOf(ct.NextFireTime));
    }
    
    @isTest
    static void testUpdate() {
    	final String LEAD_ID = '12345';
    	final Integer QTY_PER_SYS = 5; 
    	
    	// Update existing oppty and oppty prod
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Lead_Id__c = LEAD_ID;
    	mnStageClone.Reg_Part_Qty_Per_Sys__c = QTY_PER_SYS;
    	
    	insert mnStageClone;
    	
    	// There should be 2 records in the staging table.
    	List<MnStage__c> mnStages = (List<MnStage__c>)new MnStagesSelector().selectAll();
    	System.assertEquals(2, mnStages.size());
    	
    	// There should be only 1 record with Status = 'Queued'.
    	mnStages = new MnStagesSelector().selectByStatus(new Set<String> {STATUS_QUEUED});
    	System.assertEquals(1, mnStages.size());
    	
    	Test.startTest();
    	processData();
    	Test.stopTest();
    	    	
    	List<Opportunity> oppties = (List<Opportunity>)new OpportunitiesSelector().selectAll();
    	System.assertEquals(1, oppties.size());
    	
    	Opportunity oppty = oppties.get(0);
    	System.assertEquals(LEAD_ID, oppty.Lead_Id__c);
    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByOpptyIdWithOpportunity(new Set<Id> {oppty.Id});
        System.assertEquals(1, opptyProds.size());	
        
        OpportunityLineItem opptyProd = opptyProds.get(0);
        System.assertEquals(QTY_PER_SYS, opptyProd.Component_Multiplier__c);
    }
    
    @isTest
    static void testInsert() {
    	// Insert new oppty and oppty prod
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	
    	insert mnStageClone;	
    	
    	// There should be 2 records in the staging table.
    	List<MnStage__c> mnStages = (List<MnStage__c>)new MnStagesSelector().selectAll();
    	System.assertEquals(2, mnStages.size());
    	
    	// There should be only 1 record with Status = 'Queued'.
    	mnStages = new MnStagesSelector().selectByStatus(new Set<String> {STATUS_QUEUED});
    	System.assertEquals(1, mnStages.size());
    	
    	processData();
    	    	
    	List<Opportunity> oppties = (List<Opportunity>)new OpportunitiesSelector().selectAll();
    	System.assertEquals(2, oppties.size());
    	
    	List<OpportunityLineItem> opptyProds = (List<OpportunityLineItem>)new OpportunityLineItemsSelector().selectAll();
    	System.assertEquals(2, opptyProds.size());
    }
    
    @isTest
    static void testIgnore() {
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	mnStageClone.Prod_Family__c = 'R02';
    	insert mnStageClone;
    	
    	processData();
    	
    	MnStage__c ms = new MnStagesSelector().selectById(new Set<Id> {mnStageClone.Id}).get(0);    	
    	System.assertEquals(STATUS_IGNORED, ms.Status__c);
    	System.assertEquals(null, ms.Opportunity__c);
    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Oppty_Num__c + '-' + mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, oppties.size());	
    	
    	mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819835';
    	mnStageClone.Reg_Part_OID__c = '1048947';
    	mnStageClone.Reg_Status__c = 'Preparing';
    	insert mnStageClone;
    	
    	processData();
    	
    	ms = new MnStagesSelector().selectById(new Set<Id> {mnStageClone.Id}).get(0);    	
    	System.assertEquals(STATUS_IGNORED, ms.Status__c);
    	System.assertEquals(null, ms.Opportunity__c);
    	
    	oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Oppty_Num__c + '-' + mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, oppties.size());	
    }
    
    @isTest
    static void testDeduplicate() {
    	final String LEAD_ID = '12345';
    	
    	MnStage__c mnStageClone1 = mnStage.clone(false, true, false, false);
    	mnStageClone1.Status__c = STATUS_QUEUED;
    	mnStageClone1.Message__c = '';
    	mnStageClone1.Reg_Oppty_Num__c = '819834';
    	mnStageClone1.Reg_Part_OID__c = '1048946';
    	insert mnStageClone1;
    	
    	MnStage__c mnStageClone2 = mnStage.clone(false, true, false, false);
    	mnStageClone2.Status__c = STATUS_QUEUED;
    	mnStageClone2.Message__c = '';	
    	mnStageClone2.Reg_Oppty_Num__c = '819834';
    	mnStageClone2.Reg_Part_OID__c = '1048946';
    	mnStageClone2.Reg_Lead_Id__c = LEAD_ID;
    	insert mnStageClone2;
    	
    	processData();
    	
    	MnStage__c ms = new MnStagesSelector().selectById(new Set<Id> {mnStageClone1.Id}).get(0);    	
    	System.assertEquals(STATUS_DUPLICATED, ms.Status__c);
    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone2.Reg_Oppty_Num__c + '-' + mnStageClone2.Reg_Part_OID__c});
    	System.assertEquals(1, oppties.size());
    	System.assertEquals(LEAD_ID, oppties.get(0).Lead_Id__c);
    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {mnStageClone2.Reg_Part_OID__c});
    	System.assertEquals(1, opptyProds.size());
    }
    
    @isTest
    static void testPricebookEntry() {
    	OpportunityLineItem opptyProd = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {opptyProdExtId}).get(0);
    	System.assertEquals(pricebookEntry12NC.Id, opptyProd.PricebookEntryId);
    }
    
    @isTest
    static void testDerivedFields() {
    	System.assertEquals('Automotive', oppty.Industry_Segment__c);
    	System.assertEquals(mnStage.Reg_Oppty_Num__c + '-' + mnStage.Reg_Part_OID__c, oppty.Legacy_Id__c);
    	System.assertEquals(ACTION_DATE, oppty.Lost_Date__c);
    	System.assertEquals(mnStage.Reg_Oppty_Num__c + ' - ' + mnStage.Part_Name__c + ' - ' + mnStage.Prog_Name__c, oppty.Name);
    	System.assertEquals(mnStage.User_First_Name__c + ' ' + mnStage.User_Last_Name__c, oppty.Rejected_by__c);
    	System.assertEquals('Other', oppty.Sub_Segment__c);	
    	System.assertEquals(mnStage.Reg_Part_POS_Resale_Value__c / mnStage.Reg_Exchange_Rate__c.setScale(6), opptyProd.POS_Resale_Value_USD__c);
    	System.assertEquals('50% - 80%', opptyProd.Probability_to_Win__c);	
    	System.assertEquals('Creation (FSL)', opptyProd.Registration_Effort_Description__c);
    }
    
    @isTest
    static void testInvalidMnStageRegProductionDate() {
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	mnStageClone.Reg_Production_Date__c = null;	
    	
    	insert mnStageClone;
    	
    	processData();
    	    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Oppty_Num__c + '-' + mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, oppties.size());
    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, opptyProds.size());
    }
    
    @isTest
    static void testInvalidMnStageRegExchangeRate() {
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	mnStageClone.Reg_Exchange_Rate__c = 0;
    	    	
    	insert mnStageClone;
    	
    	processData();
    	    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Oppty_Num__c + '-' + mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, oppties.size());
    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, opptyProds.size());
    }
    
    @isTest
    static void testInvalidMnStageRegProjectUnits() {
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	mnStageClone.Reg_Project_Units__c = null;
    	    	
    	insert mnStageClone;
    	
    	processData();
    	    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Oppty_Num__c + '-' + mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, oppties.size());
    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, opptyProds.size());
    }
    
    @isTest
    static void testInvalidMnStageRegPartWin() {
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	mnStageClone.Reg_Part_Win_Status__c = 'ProdWin';
    	mnStageClone.Reg_Part_Win_Date__c = null;
    	    	
    	insert mnStageClone;
    	
    	processData();
    	    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Oppty_Num__c + '-' + mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, oppties.size());
    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, opptyProds.size());
    }
    
    @isTest
    static void testInvalidMnStageDistiName() {
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	mnStageClone.Disti_Name__c = null;
    	
    	insert mnStageClone;
    	
    	processData();
    	    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Oppty_Num__c + '-' + mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, oppties.size());
    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, opptyProds.size());
    }
    
    @isTest
    static void testInvalidBookPart() {
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	mnStageClone.Part_12NC__c = '000000000000';	
    	
    	insert mnStageClone;
    	
    	processData();
    	    	
    	List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, opptyProds.size());
    	
    	// If oppty prod is not created successfully, oppty should be deleted if already created. 
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Oppty_Num__c + '-' + mnStageClone.Reg_Part_OID__c});
    	System.assertEquals(0, oppties.size());
    }
    
    /**
     * Reg_Part_Status__c: Pending, Requested, Approved, Rejected
     * Reg_Part_Win_Status__c: Pending, DesignWin, ProdWin, Win 
     * Reg_Status__c: Pending, Requested, Approved, Rejected
     */
    @isTest
    static void testOpptyCloseDateAndProdDate1() {
    	// TMMA Override = false
    	// Commitment 
    	// Reg Production Date < Reg Part Win Date 
    	oppty.TMMA_Override__c = false;
    	
    	update oppty;
    	
    	final Date REG_PROD_DATE = Date.today() + 30;
    	final Date REG_PART_WIN_DATE = Date.today() + 60;
    	
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Pending'; 
    	mnStage.Reg_Part_Win_Status__c = 'DesignWin';
    	mnStage.Reg_Status__c = 'Pending';
    	mnStage.Reg_Production_Date__c = REG_PROD_DATE;
    	mnStage.Reg_Part_Win_Date__c = REG_PART_WIN_DATE;
    	
    	update mnStage;
    	
    	processData();
    	
    	Opportunity oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	
    	System.assertEquals(REG_PART_WIN_DATE, oppty.CloseDate);
    	System.assertEquals(REG_PART_WIN_DATE.addMonths(6), oppty.Production_Date__c);
    }
    
    @isTest
    static void testOpptyCloseDateAndProdDate2() {
    	// TMMA Override = false 
    	// Commitment 
    	// Reg Production Date >= Reg Part Win Date
    	oppty.TMMA_Override__c = false;
    	
    	update oppty;
    	
    	final Date REG_PROD_DATE = Date.today() + 60;
    	final Date REG_PART_WIN_DATE = Date.today() + 30;
    	
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Approved'; 
    	mnStage.Reg_Part_Win_Status__c = 'ProdWin';
    	mnStage.Reg_Status__c = 'Rejected';
    	mnStage.Reg_Production_Date__c = REG_PROD_DATE;
    	mnStage.Reg_Part_Win_Date__c = REG_PART_WIN_DATE;
    	
    	update mnStage;
    	
    	processData();
    	
    	Opportunity oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	
    	System.assertEquals(REG_PART_WIN_DATE, oppty.CloseDate);
    	System.assertEquals(REG_PROD_DATE, oppty.Production_Date__c);
    }
    
    @isTest
    static void testOpptyCloseDateAndProdDate3() {
    	// TMMA Override = false 
    	// Not Commitment 
    	oppty.TMMA_Override__c = false;
    	
    	update oppty;
    	
    	final Date REG_PROD_DATE = Date.today() + 30;
    	
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Rejected'; 
    	mnStage.Reg_Part_Win_Status__c = 'Pending';
    	mnStage.Reg_Status__c = 'Approved';
    	mnStage.Reg_Production_Date__c = REG_PROD_DATE;
    	    	
    	update mnStage;
    	
    	processData();
    	
    	Opportunity oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	
    	System.assertEquals(REG_PROD_DATE, oppty.CloseDate);
    	System.assertEquals(REG_PROD_DATE, oppty.Production_Date__c);
    }
    
    @isTest
    static void testOpptyCloseDateAndProdDate4() {
    	// TMMA Override = true
    	// Commitment 
    	// User Production Date < Reg Part Win Date 
    	final Date USER_CLOSE_DATE = Date.today() + 10;
    	final Date USER_PROD_DATE = Date.today() + 30;
    	
    	oppty.Bypass_Validation_Sched_Start_Date__c = true;
    	oppty.TMMA_Override__c = true;
    	oppty.CloseDate = USER_CLOSE_DATE; 
    	oppty.Production_Date__c = USER_PROD_DATE;
    	
    	update oppty;
    	
    	oppty = new OpportunitiesSelector().selectById(new Set<Id> {oppty.Id}).get(0);
    	
    	List<OpportunitySchedule__c> opptyScheds = new OpportunitySchedulesSelector().selectByOpptyId(new Set<Id> {oppty.Id});
    	OpportunityService.shiftOpportunitySchedules(opptyScheds, oppty.Production_Date__c);
    	
    	update opptyScheds; 
    	
    	final Date REG_PROD_DATE = Date.today() + 90;
    	final Date REG_PART_WIN_DATE = Date.today() + 60;
    	
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Pending'; 
    	mnStage.Reg_Part_Win_Status__c = 'DesignWin';
    	mnStage.Reg_Status__c = 'Pending';
    	mnStage.Reg_Production_Date__c = REG_PROD_DATE;
    	mnStage.Reg_Part_Win_Date__c = REG_PART_WIN_DATE;
    	
    	update mnStage;
    	
    	processData();
    	
    	oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 

    	System.assertEquals(REG_PART_WIN_DATE, oppty.CloseDate);
    	System.assertEquals(REG_PART_WIN_DATE.addMonths(6), oppty.Production_Date__c);
    }

 	@isTest
    static void testOpptyCloseDateAndProdDate5() {
    	// TMMA Override = true  
    	// Commitment 
    	// User Production Date >= Reg Part Win Date
    	final Date USER_CLOSE_DATE = Date.today() + 10;
    	final Date USER_PROD_DATE = Date.today() + 60;
    	
    	oppty.Bypass_Validation_Sched_Start_Date__c = true;
    	oppty.TMMA_Override__c = true;
    	oppty.CloseDate = USER_CLOSE_DATE;
    	oppty.Production_Date__c = USER_PROD_DATE;
    	
    	update oppty;
    	
    	oppty = new OpportunitiesSelector().selectById(new Set<Id> {oppty.Id}).get(0);
    	
    	List<OpportunitySchedule__c> opptyScheds = new OpportunitySchedulesSelector().selectByOpptyId(new Set<Id> {oppty.Id});
    	OpportunityService.shiftOpportunitySchedules(opptyScheds, oppty.Production_Date__c);
    	
    	update opptyScheds;
    	
    	final Date REG_PROD_DATE = Date.today() + 90;
    	final Date REG_PART_WIN_DATE = Date.today() + 30;
    	
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Approved'; 
    	mnStage.Reg_Part_Win_Status__c = 'ProdWin';
    	mnStage.Reg_Status__c = 'Rejected';
    	mnStage.Reg_Production_Date__c = REG_PROD_DATE;
    	mnStage.Reg_Part_Win_Date__c = REG_PART_WIN_DATE;
    	
    	update mnStage;
    	
    	processData();
    	
    	oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	
    	System.assertEquals(REG_PART_WIN_DATE, oppty.CloseDate);
    	System.assertEquals(USER_PROD_DATE, oppty.Production_Date__c);
    }
    
    @isTest
    static void testOpptyCloseDateAndProdDate6() {
    	// TMMA Override = true 
    	// Not Commitment 
    	final Date USER_CLOSE_DATE = Date.today() + 30;
    	final Date USER_PROD_DATE = Date.today() + 60;
    	
    	oppty.Bypass_Validation_Sched_Start_Date__c = true;
    	oppty.TMMA_Override__c = true;
    	oppty.CloseDate = USER_CLOSE_DATE;
    	oppty.Production_Date__c = USER_PROD_DATE;  
    	
    	update oppty;
    	
    	oppty = new OpportunitiesSelector().selectById(new Set<Id> {oppty.Id}).get(0);
    	
    	List<OpportunitySchedule__c> opptyScheds = new OpportunitySchedulesSelector().selectByOpptyId(new Set<Id> {oppty.Id});
    	OpportunityService.shiftOpportunitySchedules(opptyScheds, oppty.Production_Date__c);
    	
    	update opptyScheds;
    	
    	final Date REG_PROD_DATE = Date.today() + 90;
    	
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Rejected'; 
    	mnStage.Reg_Part_Win_Status__c = 'Pending';
    	mnStage.Reg_Status__c = 'Approved';
    	mnStage.Reg_Production_Date__c = REG_PROD_DATE;
    	    	
    	update mnStage;
  
    	processData();
    	
    	oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	
    	System.assertEquals(USER_CLOSE_DATE, oppty.CloseDate);
    	System.assertEquals(USER_PROD_DATE, oppty.Production_Date__c);
    }

    @isTest
    static void testOpptyStageInitialEngagement() {
    	// Initial Engagement
    	// Reg_Part_Status__c: Pending, Requested
    	// Reg_Part_Win_Status__c: Pending
    	// Reg_Status__c: Pending, Requested, Approved
    	// isExpired: false
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Pending'; 
    	mnStage.Reg_Part_Win_Status__c = 'Pending';
    	mnStage.Reg_Status__c = 'Requested';
    	mnStage.Reg_Expiration_Date__c = null;
    	
    	update mnStage;
    	
    	Test.startTest();
    	processData();
    	Test.stopTest(); 
    	
    	Opportunity oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	System.assertEquals(STAGE_INITIAL_ENGAGEMENT, oppty.StageName);
    }
    
    @isTest
    static void testOpptyStageDiscovery() {
    	// Discovery
    	// Reg_Part_Status__c: Approved
    	// Reg_Part_Win_Status__c: Pending
    	// Reg_Status__c: Pending, Requested, Approved
    	// isExpired: false
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Approved'; 
    	mnStage.Reg_Part_Win_Status__c = 'Pending';
    	mnStage.Reg_Status__c = 'Pending';
    	mnStage.Reg_Expiration_Date__c = System.today();
    	
    	update mnStage;
    	
    	Test.startTest();
    	processData();
    	Test.stopTest(); 
    	
    	Opportunity oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	System.assertEquals(STAGE_DISCOVERY, oppty.StageName);
    	System.assertEquals(null, oppty.Lost_Date__c);
    	System.assertEquals(null, oppty.Lost_Reason__c);	
    }
    
    @isTest
    static void testOpptyStageCommitment1() {
    	// Commitment #1
    	// Reg_Part_Status__c: Pending, Requested
    	// Reg_Part_Win_Status__c: DesignWin, ProdWin, Win
    	// Reg_Status__c: Pending, Requested, Approved
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Requested'; 
    	mnStage.Reg_Part_Win_Status__c = 'DesignWin';
    	mnStage.Reg_Status__c = 'Pending';
    	    	    	
    	update mnStage;
    	
    	Test.startTest();
    	processData();
    	Test.stopTest(); 
    	
    	Opportunity oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	System.assertEquals(STAGE_COMMITMENT, oppty.StageName);
    }
    
    @isTest
    static void testOpptyStageCommitment2() {
    	// Commitment #2
    	// Reg_Part_Status__c: Approved, Rejected
    	// Reg_Part_Win_Status__c: DesignWin, ProdWin, Win
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Approved'; 
    	mnStage.Reg_Part_Win_Status__c = 'DesignWin';
    	    	    	
    	update mnStage;
    	
    	Test.startTest();
    	processData();
    	Test.stopTest(); 
    	
    	Opportunity oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	System.assertEquals(STAGE_COMMITMENT, oppty.StageName);
    }
    
    @isTest
    static void testOpptyStageLost() {
    	// Lost
    	// Reg_Part_Status__c: Pending, Requested, Approved
    	// Reg_Part_Win_Status__c: Pending
    	// Reg_Status__c: Pending, Requested, Approved
    	// isExpired: true
    	final Date EXP_DATE = (System.today() - 1); 
    		
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Requested'; 
    	mnStage.Reg_Part_Win_Status__c = 'Pending';
    	mnStage.Reg_Status__c = 'Approved';
    	mnStage.Reg_Expiration_Date__c = EXP_DATE;
    	
    	update mnStage;
    	
    	processData(); 
    	
    	Opportunity oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	System.assertEquals(STAGE_LOST, oppty.StageName);
    	System.assertEquals(EXP_DATE, oppty.Lost_Date__c);
    	System.assertEquals(Opportunities.MN_LOST_REASON, oppty.Lost_Reason__c);
    }
    
    @isTest
    static void testOpptyStageCancelled() {
    	// Cancelled
    	// #1
    	// Reg_Part_Status__c: Pending, Requested
    	// Reg_Status__c: Rejected
    	// #2
    	// Reg_Part_Status__c: Approved
    	// Reg_Part_Win_Status__c: Pending
    	// Reg_Status__c: Rejected
    	// #3
    	// Reg_Part_Status__c: Rejected
    	// Reg_Part_Win_Status__c: Pending
    	mnStage.Status__c = STATUS_QUEUED;
    	mnStage.Reg_Part_Status__c = 'Rejected'; 
    	mnStage.Reg_Part_Win_Status__c = 'Pending';
    	mnStage.Reg_Status__c = 'Pending';
    	    	
    	update mnStage;
    	
    	processData(); 
    	
    	Opportunity oppty = new OpportunitiesSelector().selectByLegacyId(new Set<String> {opptyExtId}).get(0); 
    	System.assertEquals(STAGE_CANCELLED, oppty.StageName);
    	System.assertEquals(ACTION_DATE, oppty.Lost_Date__c);
    	System.assertEquals(REJECT_REASON, oppty.Lost_Reason__c);
    }
    
    @isTest
    static void testSelectByStatusQueryLocator() {
    	System.assertNotEquals(null, new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {STATUS_QUEUED}));
    }
    
    private static void processData() {
    	User u = [select Id from User where Id = :CommonUtils.getDataAdminUserId()];
        
        System.runAs(u) {
			Opportunities.resetUpdateEventEntry();       	
        	MnStages.newInstance(new MnStagesSelector().selectByStatus(new Set<String> {STATUS_QUEUED})).processData();	
        }
    }
    
    private static Id runBatch() {
    	return Database.executeBatch(new ModelNDesignRegistrationsProcessJob());
    } 
    
}