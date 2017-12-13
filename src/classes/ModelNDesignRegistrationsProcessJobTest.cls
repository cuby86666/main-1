@isTest
private class ModelNDesignRegistrationsProcessJobTest {
	
	private static final String STATUS_QUEUED = MnStages.STATUSES.get(MnStages.Status.QUEUED);
	private static final String STATUS_COMPLETED = MnStages.STATUSES.get(MnStages.Status.COMPLETED);
	
	private static MnStage__c mnStage;
	private static String opptyExtId;
	private static String opptyProdExtId;
	private static PricebookEntry pricebookEntry12NC;
	private static PricebookEntry pricebookEntryRoot;
	private static Opportunity oppty;
	private static OpportunityLineItem opptyProd;
	
	static {
		List<MnStage__c> mnStages = (List<MnStage__c>)new MnStagesSelector().selectAll();
	
		if (mnStages.size() > 0) {
			mnStage = mnStages.get(0);
			opptyExtId = mnStage.Reg_Oppty_Num__c + '-' + mnStage.Reg_Part_OID__c;
			opptyProdExtId = mnStage.Reg_Part_OID__c;
			
			for (PricebookEntry pe : new PricebookEntriesSelector().selectByProdBasicTypeOrSalesItemWithProduct(new Set<String> {mnStage.Part_Root__c}, new Set<String> {mnStage.Part_12NC__c})) {
					if (pricebookEntryRoot == null &&
					    pe.Product2.Basic_Type__c == mnStage.Part_Root__c &&
						pe.CurrencyIsoCode == mnStage.Currency_Code__c) {
						pricebookEntryRoot = pe;
					} else if (pricebookEntry12NC == null &&
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
		mnStage.Reg_Action_Date__c = Date.newInstance(2017, 02, 28);
		mnStage.Reg_Created_Date__c = Date.newInstance(2017, 02, 03);
		mnStage.Reg_Lead_Id__c = null;
		mnStage.Reg_Disti_Tracking_Num__c = '205069';
		mnStage.Reg_Status__c = 'Rejected';
		mnStage.Reg_Exchange_Rate__c = 0.92506938;
		mnStage.Reg_Is_Duplicated__c = false;
		mnStage.Reg_Modified_Date__c = Date.newInstance(2017, 10, 02);
		mnStage.Reg_Oppty_Num__c = '811152';
		mnStage.Reg_Production_Date__c = Date.newInstance(2014, 02, 16);
		mnStage.Reg_Project_Units__c = 2000000;
		mnStage.Reg_Expiration_Date__c = Date.newInstance(2019, 09, 25);
		mnStage.Reg_Num__c = '1-CDSPKP';
		mnStage.Reg_Reject_Reason__c = 'No Commercial Relation';
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
		mnStage.Reg_Part_Win_Status__c = 'ProdWin';
		mnStage.Reg_Part_One_Year_Value__c = 660000;
		mnStage.Reg_Part_Win_Date__c = Date.newInstance(2012, 01, 08);
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
	
		runBatch();
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
    static void testUpdate() {
    	final String LEAD_ID = '12345';
    	final Integer QTY_PER_SYS = 5; 
    	
    	// Update existing oppty and oppty prod
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Opportunity__c = null;
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
    	runBatch();
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
    	mnStageClone.Opportunity__c = null;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	
    	insert mnStageClone;	
    	
    	// There should be 2 records in the staging table.
    	List<MnStage__c> mnStages = (List<MnStage__c>)new MnStagesSelector().selectAll();
    	System.assertEquals(2, mnStages.size());
    	
    	// There should be only 1 record with Status = 'Queued'.
    	mnStages = new MnStagesSelector().selectByStatus(new Set<String> {STATUS_QUEUED});
    	System.assertEquals(1, mnStages.size());
    	
    	Test.startTest();
    	runBatch();
    	Test.stopTest();
    	
    	List<Opportunity> oppties = (List<Opportunity>)new OpportunitiesSelector().selectAll();
    	System.assertEquals(2, oppties.size());
    	
    	List<OpportunityLineItem> opptyProds = (List<OpportunityLineItem>)new OpportunityLineItemsSelector().selectAll();
    	System.assertEquals(2, opptyProds.size());
    }
    
    @isTest
    static void testPricebookEntry() {
    	// Not root part
    	OpportunityLineItem opptyProd = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {opptyProdExtId}).get(0);
    	System.assertEquals(pricebookEntry12NC.Id, opptyProd.PricebookEntryId);
    	
    	// Root part
    	MnStage__c mnStageClone = mnStage.clone(false, true, false, false);
    	mnStageClone.Status__c = STATUS_QUEUED;
    	mnStageClone.Opportunity__c = null;
    	mnStageClone.Part_Is_Root__c = true;
    	mnStageClone.Reg_Oppty_Num__c = '819834';
    	mnStageClone.Reg_Part_OID__c = '1048946';
    	
    	insert mnStageClone;
    	
    	Test.startTest();
    	runBatch();
    	Test.stopTest();
    	
    	opptyProd = new OpportunityLineItemsSelector().selectByLegacyId(new Set<String> {mnStageClone.Reg_Part_OID__c}).get(0);
    	System.assertEquals(pricebookEntryRoot.Id, opptyProd.PricebookEntryId);
    }
    
    @isTest
    static void testDerivedFields() {
    	System.assertEquals('Automotive', oppty.Industry_Segment__c);
    	System.assertEquals(mnStage.Reg_Oppty_Num__c + '-' + mnStage.Reg_Part_OID__c, oppty.Legacy_Id__c);
    	System.assertEquals(Date.newInstance(2017, 02, 28), oppty.Lost_Date__c);
    	System.assertEquals(mnStage.Reg_Oppty_Num__c + ' - ' + mnStage.Part_Name__c + ' - ' + mnStage.Prog_Name__c, oppty.Name);
    	System.assertEquals(mnStage.User_First_Name__c + ' ' + mnStage.User_Last_Name__c, oppty.Rejected_by__c);
    	System.assertEquals('Other', oppty.Sub_Segment__c);	
    	System.assertEquals(mnStage.Reg_Part_POS_Resale_Value__c / mnStage.Reg_Exchange_Rate__c.setScale(6), opptyProd.POS_Resale_Value_USD__c);
    	System.assertEquals('50% - 80%', opptyProd.Probability_to_Win__c);	
    	System.assertEquals('Creation (FSL)', opptyProd.Registration_Effort_Description__c);
    }
    
    private static void runBatch() {
    	ModelNDesignRegistrationsProcessJob drProcessJob = new ModelNDesignRegistrationsProcessJob();
    	Database.executeBatch(drProcessJob); 	
    } 
    
}