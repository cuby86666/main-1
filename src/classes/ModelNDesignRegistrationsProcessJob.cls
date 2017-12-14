global class ModelNDesignRegistrationsProcessJob implements Database.Batchable<SObject> {
	
	private static final String STATUS_QUEUED = MnStages.STATUSES.get(MnStages.Status.QUEUED);
	private static final String STATUS_PROCESSING = MnStages.STATUSES.get(MnStages.Status.PROCESSING);
	private static final String STATUS_COMPLETED = MnStages.STATUSES.get(MnStages.Status.COMPLETED);
	private static final String STATUS_INVALID = MnStages.STATUSES.get(MnStages.Status.INVALID);
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		p('start');
		return new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {STATUS_QUEUED});
	}
	
	global void execute(Database.BatchableContext bc, List<MnStage__c> scope) {
		p('execute');
		MnStages mnStages = new MnStages(scope.deepClone(true, true, true));
		
		Map<Id, Boolean> opptyProdsExistedByMnStageId = mnStages.checkOpptyProdsExisted();
		Map<Id, Id> pricebookEntryIdsByMnStageId = mnStages.findPricebookEntries();
		
		List<Opportunity> oppties = new List<Opportunity>();
		List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>(); 
		
		for (MnStage__c ms : scope) {
			String opptyExtId = ms.Reg_Oppty_Num__c + '-' + ms.Reg_Part_OID__c;
		
			Opportunity oppty = new Opportunity();
			oppty.Legacy_Id__c = opptyExtId;
			oppty.CloseDate = ms.Reg_Production_Date__c;
			oppty.CurrencyIsoCode = ms.Currency_Code__c;
			oppty.Name = (ms.Reg_Oppty_Num__c + ' - ' + ms.Part_Name__c + ' - ' + ms.Prog_Name__c).left(120);
			oppty.RecordTypeId = OpportunitiesSelector.getMnRecordTypeId();
			oppty.StageName = 'Initial Engagement'; // todo
			oppty.Assembly__c = ms.Assembly_Name__c;
			oppty.Business_Created_Date__c = ms.Reg_Created_Date__c;
			oppty.Design_Customer_City__c = ms.Addr_Design_Cust_City__c;
			oppty.Design_Customer_Country__c = ms.Addr_Design_Cust_Country__c;
			oppty.Design_Customer_GID__c = ms.Design_Cust_GID__c;
			oppty.Design_Customer_Location__c = ms.Design_Cust_Loc__c;
			oppty.Design_Customer_Name__c = ms.Design_Cust_Name__c;
			oppty.Design_Customer_State__c = ms.Addr_Design_Cust_State__c;
			oppty.Design_Customer_Zip__c = ms.Addr_Design_Cust_Zip__c;
			oppty.Design_Reg_Is_Created_By_B2B__c = ms.Reg_Is_Created_By_B2B__c;
			oppty.Design_Reg_Is_Duplicated__c = ms.Reg_Is_Duplicated__c;
			oppty.Design_Reg_Reject_Reason__c = ms.Reg_Reject_Reason__c;
			oppty.Design_Reg_Status__c = ms.Reg_Status__c;
			oppty.Design_Reg_Win_Date__c = ms.Reg_Win_Date__c;
			oppty.Design_Reg_Win_Status__c = ms.Reg_Win_Status__c;
			oppty.Design_Region__c = ms.Geo_Design_Cust_Region__c;
			oppty.Distributor_Branch_Name__c = ms.Org_Disti_Branch__c;
			oppty.Distributor_Name__c = ms.Disti_Name__c;
			oppty.Distributor_Tracking_Number__c = ms.Reg_Disti_Tracking_Num__c;
			oppty.End_Customer_City__c = ms.Addr_End_Cust_City__c;
			oppty.End_Customer_Country__c = ms.Addr_End_Cust_Country__c;
			oppty.End_Customer_GID__c = ms.End_Cust_GID__c;
			oppty.End_Customer_Location__c = ms.End_Cust_Loc__c;
			oppty.End_Customer_Name__c = ms.End_Cust_Name__c;
			oppty.End_Customer_Region__c = ms.Geo_End_Cust_Region__c;
			oppty.End_Customer_State__c = ms.Addr_End_Cust_State__c;
			oppty.End_Customer_Zip__c = ms.Addr_End_Cust_Zip__c;
			oppty.Expiration_Date__c = ms.Reg_Expiration_Date__c;
			oppty.Industry_Segment__c = (ms.Func_Name__c != null) ? ms.Func_Name__c.substringBefore('-').removeEnd(':') : null; 
			oppty.Last_Business_Modified_Date__c = ms.Reg_Modified_Date__c;
			oppty.Legacy_Design_Registration_Number__c = ms.Reg_Num__c;
			oppty.Legacy_Opportunity_Owner__c = ms.User_Email__c;
			oppty.Lead_Id__c = ms.Reg_Lead_Id__c;
			oppty.Locked_Exchange_Rate__c = ms.Reg_Exchange_Rate__c;
			oppty.Lost_Date__c = (ms.Reg_Status__c == 'Rejected') ? ms.Reg_Action_Date__c : null; 
			oppty.One_Year_Pieces__c = ms.Reg_Project_Units__c;
			oppty.Production_Date__c = ms.Reg_Production_Date__c;
			oppty.Rejected_by__c = ms.User_First_Name__c + ' ' + ms.User_Last_Name__c;
			oppty.Sub_Segment__c = (ms.Func_Name__c != null) ? ms.Func_Name__c.substringAfter('-') : null; 
			
			oppties.add(oppty);
			
			OpportunityLineItem opptyProd = new OpportunityLineItem();
			opptyProd.Legacy_Id__c = ms.Reg_Part_OID__c;
			opptyProd.Opportunity = new Opportunity(Legacy_Id__c = opptyExtId);
			
			// PricebookEntryId can be set only when an oppty prod is created.
			if (!opptyProdsExistedByMnStageId.get(ms.Id)) { 
				opptyProd.PricebookEntryId = pricebookEntryIdsByMnStageId.get(ms.Id);	
			} 
			
			opptyProd.UnitPrice = ms.Reg_Part_ASP__c;
			opptyProd.Competitor__c = ms.Competitor_Name__c;
			opptyProd.Component_Multiplier__c = ms.Reg_Part_Qty_Per_Sys__c;
			opptyProd.Design_Reg_Part_Active_Flag__c = ms.Reg_Part_Is_Active__c;
			opptyProd.Design_Reg_Part_Created_Date__c = ms.Reg_Part_Created_Date__c;
			opptyProd.Design_Reg_Part_Modified_Date__c = ms.Reg_Part_Modified_Date__c;
			opptyProd.Design_Reg_Part_Is_Obsolete__c = ms.Reg_Part_Is_Obsolete__c;
			opptyProd.Distributor_Tracking_Number__c = ms.Reg_Part_Disti_Tracking_Num__c;
			opptyProd.Expert_Certified__c = ms.Reg_Part_Is_Expert_Certified__c;
			opptyProd.Final_Registration_Item__c = ms.Reg_Part_Final_Phase__c;
			opptyProd.Legacy_1_Year_Prod__c = ms.Reg_Part_One_Year_Value__c;
			opptyProd.POS_Quantity__c = ms.Reg_Part_POS_Qty_Shipped__c; 
			opptyProd.POS_Resale_Value_USD__c = (ms.Reg_Exchange_Rate__c != null && ms.Reg_Exchange_Rate__c != 0) ? (ms.Reg_Part_POS_Resale_Value__c / ms.Reg_Exchange_Rate__c.setScale(6)) : 0;
			opptyProd.Probability_to_Win__c = (ms.Design_Confidence__c == null || ms.Design_Confidence__c == 0.25) ? '0% - 50%' : (ms.Design_Confidence__c == 0.5 ? '50% - 80%' : (ms.Design_Confidence__c == 1 ? '80% - 100%' : null));
			opptyProd.Registration_Effort_Description__c = (ms.Reg_Part_Margin_Qualification__c != null) ? ms.Reg_Part_Margin_Qualification__c : ms.Reg_Part_Effort_Desc__c;
			opptyProd.Registration_Effort_Percentage__c = ms.Reg_Part_Effort_Pct__c;
			opptyProd.Registration_Status__c = ms.Reg_Part_Status__c;
			opptyProd.Win_Date__c = ms.Reg_Part_Win_Date__c;
			opptyProd.Win_Status__c = ms.Reg_Part_Win_Status__c;
			
			opptyProds.add(opptyProd);
			
			String message = checkMnStageInvalid(ms); 
			
			if (message != '') {
				ms.Status__c = STATUS_INVALID;
				ms.Message__c = message;
			} else {
				ms.Status__c = STATUS_PROCESSING;	
			}
		}
		
		update scope; 	
		
		List<Database.UpsertResult> opptiesUpsertResults = Database.upsert(oppties, Opportunity.Fields.Legacy_Id__c, false);
		List<Database.UpsertResult> opptyProdsUpsertResults = Database.upsert(opptyProds, OpportunityLineItem.Fields.Legacy_Id__c, false);
		
		List<Id> opptyIdsDeleted = new List<Id>();
		
		for (Integer i = 0; i < scope.size(); i++) {
			MnStage__c mnStage = scope.get(i);
			Database.UpsertResult opptyUpsertResult = opptiesUpsertResults.get(i);
			Database.UpsertResult opptyProdUpsertResult = opptyProdsUpsertResults.get(i);
			
			if (mnStage.Status__c == STATUS_INVALID && opptyUpsertResult.isSuccess()) {
				opptyIdsDeleted.add(opptyUpsertResult.getId());	
			}
			
			if (!opptyUpsertResult.isSuccess()) {
				mnStage.Status__c = STATUS_INVALID; 
				mnStage.Message__c = (mnStage.Message__c == null) ? processErrors(opptyUpsertResult.getErrors()) : mnStage.Message__c;	
			} else {
				mnStage.Status__c = STATUS_COMPLETED; 
			}
		
			if (!opptyProdUpsertResult.isSuccess()) {
				// If oppty prod is not created successfully, oppty should be deleted if already created.
				if (opptyUpsertResult.isSuccess()) {
					opptyIdsDeleted.add(opptyUpsertResult.getId());	
				}
				
				mnStage.Status__c = STATUS_INVALID; 
				mnStage.Message__c = (mnStage.Message__c == null) ? processErrors(opptyProdUpsertResult.getErrors()) : mnStage.Message__c; 	
			} else {
				mnStage.Status__c = STATUS_COMPLETED; 
			}
		}
		
		if (opptyIdsDeleted.size() > 0) {
			List<Database.DeleteResult> opptiesDeleteResults = Database.delete(opptyIdsDeleted, false);
		}
		
		update scope; 
System.debug('///////// mnstages end: ' + new MnStagesSelector().selectAll());		
	}
	
	global void finish(Database.BatchableContext bc) {
		p('finish');	
	}
	
	private String checkMnStageInvalid(MnStage__c mnStage) {
		String result = '';
		
		if (mnStage.Reg_Production_Date__c == null) {
			result += 'Reg_Production_Date__c is blank. ';	
		}
		
		if (mnStage.Reg_Exchange_Rate__c == null || mnStage.Reg_Exchange_Rate__c == 0) {
			result += 'Reg_Exchange_Rate__c is blank or 0. ';
		}
		
		if (mnStage.Reg_Project_Units__c == null || mnStage.Reg_Project_Units__c == 0) {
			result += 'Reg_Project_Units__c is blank or 0. ';
		}
		
		if (mnStage.Reg_Part_Win_Status__c != null && mnStage.Reg_Part_Win_Status__c.contains('Win') && mnStage.Reg_Part_Win_Date__c == null) {
			result += 'Reg_Part_Win_Status__c is "Win", but Reg_Part_Win_Date__c is blank. ';
		} 
		
		return result;
	}
	
	private String processErrors(List<Database.Error> errors) {
		String result = '';
		
		for (Database.Error err : errors) {
			result += err.getStatusCode() + ': ' + err.getMessage() + '. Fields that affected this error: ' + err.getFields() + '. ';
		}	
		
		return result;
	}
	
	private static void p(String msg) {
		CommonUtils.p(ModelNDesignRegistrationsProcessJob.class, '//-c', msg);
   	}
    
}