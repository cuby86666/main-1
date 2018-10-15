public class MnStages extends ApplicationDomain {
		
	public enum Status {HOLDING, QUEUED, PROCESSING, COMPLETED, INVALID, DUPLICATED, IGNORED, FAILED, ABORTED}
		
	public static final Map<Status, String> STATUSES = new Map<Status, String> {
		Status.HOLDING => 'Holding',
		Status.QUEUED => 'Queued',
		Status.PROCESSING => 'Processing',
		Status.COMPLETED => 'Completed',
		Status.INVALID => 'Invalid',
		Status.DUPLICATED => 'Duplicated',
		Status.IGNORED => 'Ignored',
		Status.FAILED => 'Failed',
		Status.ABORTED => 'Aborted'
	};
	
	public static final String STATUS_HOLDING = STATUSES.get(Status.HOLDING);
	public static final String STATUS_QUEUED = STATUSES.get(Status.QUEUED);
	public static final String STATUS_PROCESSING = STATUSES.get(Status.PROCESSING);
	public static final String STATUS_COMPLETED = STATUSES.get(Status.COMPLETED);
	public static final String STATUS_INVALID = STATUSES.get(Status.INVALID);
	public static final String STATUS_DUPLICATED = STATUSES.get(Status.DUPLICATED);
	public static final String STATUS_IGNORED = STATUSES.get(Status.IGNORED);
	public static final String STATUS_FAILED = STATUSES.get(Status.FAILED);
	public static final String STATUS_ABORTED = STATUSES.get(Status.ABORTED);
	
	public enum RegPartStatus {PENDING, REQUESTED, APPROVED, REJECTED}
	
	public static final Map<RegPartStatus, String> REG_PART_STATUSES = new Map<RegPartStatus, String> {
		RegPartStatus.PENDING => 'Pending',
		RegPartStatus.REQUESTED => 'Requested',
		RegPartStatus.APPROVED => 'Approved',
		RegPartStatus.REJECTED => 'Rejected'	
	};
	
	public static final String REG_PART_STATUS_PENDING = REG_PART_STATUSES.get(RegPartStatus.PENDING);
	public static final String REG_PART_STATUS_REQUESTED = REG_PART_STATUSES.get(RegPartStatus.REQUESTED);
	public static final String REG_PART_STATUS_APPROVED = REG_PART_STATUSES.get(RegPartStatus.APPROVED);
	public static final String REG_PART_STATUS_REJECTED = REG_PART_STATUSES.get(RegPartStatus.REJECTED);
	
	public enum RegPartWinStatus {PENDING, DESIGN_WIN, PROD_WIN, WIN}
	
	public static final Map<RegPartWinStatus, String> REG_PART_WIN_STATUSES = new Map<RegPartWinStatus, String> {
		RegPartWinStatus.PENDING => 'Pending',
		RegPartWinStatus.DESIGN_WIN => 'DesignWin',
		RegPartWinStatus.PROD_WIN => 'ProdWin',
		RegPartWinStatus.WIN => 'Win'	
	};
	
	public static final String REG_PART_WIN_STATUS_PENDING = REG_PART_WIN_STATUSES.get(RegPartWinStatus.PENDING);
	public static final String REG_PART_WIN_STATUS_DESIGN_WIN = REG_PART_WIN_STATUSES.get(RegPartWinStatus.DESIGN_WIN);
	public static final String REG_PART_WIN_STATUS_PROD_WIN = REG_PART_WIN_STATUSES.get(RegPartWinStatus.PROD_WIN);
	public static final String REG_PART_WIN_STATUS_WIN = REG_PART_WIN_STATUSES.get(RegPartWinStatus.WIN);
	
	public enum RegStatus {PENDING, REQUESTED, APPROVED, REJECTED}
	
	public static final Map<RegStatus, String> REG_STATUSES = new Map<RegStatus, String> {
		RegStatus.PENDING => 'Pending',
		RegStatus.REQUESTED => 'Requested',
		RegStatus.APPROVED => 'Approved',
		RegStatus.REJECTED => 'Rejected'	
	};
	
	public static final String REG_STATUS_PENDING = REG_STATUSES.get(RegStatus.PENDING);
	public static final String REG_STATUS_REQUESTED = REG_STATUSES.get(RegStatus.REQUESTED);
	public static final String REG_STATUS_APPROVED = REG_STATUSES.get(RegStatus.APPROVED);
	public static final String REG_STATUS_REJECTED = REG_STATUSES.get(RegStatus.REJECTED);
	
	private List<MnStage__c> mnStages;
	
	private MnStages() {}   
	
	private MnStages(List<MnStage__c> mnStages) {
		super(mnStages);	
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new MnStages(sObjectList);
		}
	}
	
	public static MnStages newInstance(List<MnStage__c> mnStages) {
		MnStages newInstance = new MnStages();
		newInstance.mnStages = mnStages;
		newInstance.ignore();
		newInstance.deduplicate();
		newInstance.invalidate();
		
		return newInstance; 	
	} 
	
	public override void onBeforeInsert() {
		p('onBeforeInsert');
		for (MnStage__c ms : (List<MnStage__c>)this.records) {
			if (!ModelNDesignRegistrationsProcessJob.isSerialMode() && CommonUtils.isIntegrationUser()) {
				ms.Status__c = STATUS_HOLDING;	
			} else {
				ms.Status__c = STATUS_QUEUED;	
			}
		}
	}
	
	public void processData() {
		p('processData');
		if (this.mnStages.size() == 0) return;
		
		Map<Id, Boolean> opptyProdsExistedByMnStageId = checkOpptyProdsExisted();
		Map<Id, Id> pricebookEntryIdsByMnStageId = findPricebookEntries();
		
		List<Opportunity> oppties = new List<Opportunity>();
		List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>(); 
		
		for (MnStage__c ms : this.mnStages) {
			ms.Message__c = '';
			ms.Opportunity__c = null;
			
			String opptyExtId = ms.Reg_Oppty_Num__c + '-' + ms.Reg_Part_OID__c;
		
			Opportunity oppty = new Opportunity();
			oppty.Legacy_Id__c = opptyExtId;
			oppty.CurrencyIsoCode = ms.Currency_Code__c;
			oppty.Name = (ms.Reg_Oppty_Num__c + ' - ' + ms.Part_Name__c + ' - ' + ms.Prog_Name__c).left(120);
			oppty.RecordTypeId = OpportunitiesSelector.getMnRecordTypeId();
			oppty.StageName = OpportunityService.deriveMnOpportunityStage(ms.Reg_Part_Status__c, ms.Reg_Part_Win_Status__c, ms.Reg_Status__c, ms.Reg_Expiration_Date__c);
			oppty.Assembly__c = ms.Assembly_Name__c;
			oppty.Business_Created_Date__c = ms.Reg_Created_Date__c;
			oppty.Bypass_Validation_Sched_Start_Date__c = true;
			oppty.Design_Customer_City__c = ms.Addr_Design_Cust_City__c;
			oppty.Design_Customer_Country__c = ms.Addr_Design_Cust_Country__c;
			oppty.Design_Customer_GID__c = ms.Design_Cust_GID__c;
			oppty.Design_Customer_Location__c = ms.Design_Cust_Loc__c;
			oppty.Design_Customer_Name__c = ms.Design_Cust_Name__c;
			oppty.Design_Customer_State__c = ms.Addr_Design_Cust_State__c;
			oppty.Design_Customer_Zip__c = ms.Addr_Design_Cust_Zip__c;
			oppty.Design_Reg_Is_Created_By_B2B__c = ms.Reg_Is_Created_By_B2B__c;
			oppty.Design_Reg_Is_Duplicated__c = ms.Reg_Is_Duplicated__c;
			oppty.Design_Reg_Production_Date__c = ms.Reg_Production_Date__c;
			oppty.Design_Reg_Reject_Reason__c = ms.Reg_Reject_Reason__c;
			oppty.Design_Reg_Status__c = ms.Reg_Status__c;
			oppty.Design_Reg_Win_Date__c = ms.Reg_Win_Date__c;
			oppty.Design_Reg_Win_Status__c = ms.Reg_Win_Status__c;
			oppty.Design_Region__c = ms.Geo_Design_Cust_Region__c;
			oppty.Design_Win_Approval_Process__c = null;
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
			oppty.One_Year_Pieces__c = ms.Reg_Project_Units__c;
			oppty.Project__c = ms.Prog_Name__c;
			oppty.Rejected_by__c = (ms.User_First_Name__c != null ? ms.User_First_Name__c : '') + ' ' + (ms.User_Last_Name__c != null ? ms.User_Last_Name__c : '');
			oppty.Sub_Segment__c = (ms.Func_Name__c != null) ? ms.Func_Name__c.substringAfter('-') : null;
			
			OpportunityService.setMnOpportunityCloseDateAndProdDate(oppty, ms.Reg_Production_Date__c, ms.Reg_Part_Win_Date__c);
			OpportunityService.setMnOpportunityLostCancelledInfo(oppty, ms.Reg_Action_Date__c); 
			
			oppties.add(oppty);
			
			OpportunityLineItem opptyProd = new OpportunityLineItem();
			opptyProd.Legacy_Id__c = ms.Reg_Part_OID__c;
			opptyProd.Opportunity = new Opportunity(Legacy_Id__c = opptyExtId);
			
			// PricebookEntryId can be set only when an oppty prod is created.
			if (!opptyProdsExistedByMnStageId.get(ms.Id)) { 
				opptyProd.PricebookEntryId = pricebookEntryIdsByMnStageId.get(ms.Id);
				
				if (opptyProd.PricebookEntryId == null) {
					ms.Status__c = STATUS_INVALID;
					ms.Message__c = 'Product or Price Book Entry is not found. ';
				}	
			} 
			
			opptyProd.UnitPrice = ms.Reg_Part_ASP__c;
			opptyProd.Competitor__c = ms.Competitor_Name__c;
			opptyProd.Component_Multiplier__c = ms.Reg_Part_Qty_Per_Sys__c;
			opptyProd.Design_Reg_Part_Active_Flag__c = ms.Reg_Part_Is_Active__c;
			opptyProd.Design_Reg_Part_Approved_Date__c = ms.Reg_Part_Approved_Date__c;
			opptyProd.Design_Reg_Part_Created_Date__c = ms.Reg_Part_Created_Date__c;
			opptyProd.Design_Reg_Part_Modified_Date__c = ms.Reg_Part_Modified_Date__c;
			opptyProd.Design_Reg_Part_Is_Obsolete__c = ms.Reg_Part_Is_Obsolete__c;
			opptyProd.Distributor_Tracking_Number__c = ms.Reg_Part_Disti_Tracking_Num__c;
			opptyProd.Expert_Certified__c = ms.Reg_Part_Is_Expert_Certified__c;
			opptyProd.Final_Registration_Item__c = ms.Reg_Part_Final_Phase__c;
			opptyProd.Legacy_1_Year_Prod__c = ms.Reg_Part_One_Year_Value__c;
			opptyProd.POS_Quantity__c = ms.Reg_Part_POS_Qty_Shipped__c;
			opptyProd.POS_Resale_Value_USD__c = (ms.Reg_Part_POS_Resale_Value__c != null && ms.Reg_Exchange_Rate__c != null && ms.Reg_Exchange_Rate__c != 0) ? (ms.Reg_Part_POS_Resale_Value__c / ms.Reg_Exchange_Rate__c.setScale(6)) : 0;
			opptyProd.Probability_to_Win__c = (ms.Design_Confidence__c == null || ms.Design_Confidence__c == 0.25) ? '0% - 50%' : (ms.Design_Confidence__c == 0.5 ? '50% - 80%' : (ms.Design_Confidence__c == 1 ? '80% - 100%' : null));
			opptyProd.Registration_Effort_Description__c = (ms.Reg_Part_Margin_Qualification__c != null) ? ms.Reg_Part_Margin_Qualification__c : ms.Reg_Part_Effort_Desc__c;
			opptyProd.Registration_Effort_Percentage__c = ms.Reg_Part_Effort_Pct__c;
			opptyProd.Registration_Status__c = ms.Reg_Part_Status__c;
			opptyProd.Win_Date__c = ms.Reg_Part_Win_Date__c;
			opptyProd.Win_Status__c = ms.Reg_Part_Win_Status__c;
			
			opptyProds.add(opptyProd);
		}
		
		update this.mnStages; 	
		
		List<Database.UpsertResult> opptiesUpsertResults = Database.upsert(oppties, Opportunity.Fields.Legacy_Id__c, false);
		List<Database.UpsertResult> opptyProdsUpsertResults = Database.upsert(opptyProds, OpportunityLineItem.Fields.Legacy_Id__c, false);
		
		Set<Id> opptyIdsDeleted = new Set<Id>();
		
		for (Integer i = 0; i < this.mnStages.size(); i++) {
			MnStage__c mnStage = this.mnStages.get(i);
			Database.UpsertResult opptyUpsertResult = opptiesUpsertResults.get(i);
			Database.UpsertResult opptyProdUpsertResult = opptyProdsUpsertResults.get(i);
			
			if (mnStage.Status__c == STATUS_INVALID && opptyUpsertResult.isSuccess()) {
				opptyIdsDeleted.add(opptyUpsertResult.getId());	
			}
			
			if (!opptyUpsertResult.isSuccess()) {
				mnStage.Status__c = STATUS_INVALID; 
				mnStage.Message__c = (mnStage.Message__c == '') ? processErrors(opptyUpsertResult.getErrors()) : mnStage.Message__c;	
			}
		
			if (!opptyProdUpsertResult.isSuccess()) {
				mnStage.Status__c = STATUS_INVALID; 
				mnStage.Message__c = (mnStage.Message__c == '') ? processErrors(opptyProdUpsertResult.getErrors()) : mnStage.Message__c;
				
				// If oppty prod is not created successfully, oppty should be deleted if already created.
				if (opptyUpsertResult.isSuccess()) {
					opptyIdsDeleted.add(opptyUpsertResult.getId());	
				}
			}
			
			if (mnStage.Status__c != STATUS_INVALID && opptyUpsertResult.isSuccess() && opptyProdUpsertResult.isSuccess()) {
				mnStage.Status__c = STATUS_COMPLETED;
				mnStage.Opportunity__c = opptyUpsertResult.getId();	
			}
		}
		
		if (opptyIdsDeleted.size() > 0) {
			List<Database.DeleteResult> opptiesDeleteResults = Database.delete(new List<Id>(opptyIdsDeleted), false);
		}
		
		update this.mnStages; 
	}
	
	private void ignore() {
		p('ignore');
		Map<Id, MnStage__c> mnStagesById = new Map<Id, MnStage__c>(this.mnStages); 
		
		List<Model_N_Stage_Setting__mdt> mnStageSettings = (List<Model_N_Stage_Setting__mdt>)new ModelNStageSettingsSelector().selectAll();
		
		for (MnStage__c ms : this.mnStages) {
			for (Model_N_Stage_Setting__mdt mnss : mnStageSettings) {
				if (mnss.Name__c.endsWithIgnoreCase('__c') && ms.get(mnss.Name__c) == mnss.Value__c) {
					ms.Status__c = STATUS_IGNORED;
					ms.Message__c = mnss.Name__c + ': ' + mnss.Value__c + ' is ignored.';
					ms.Opportunity__c = null;
					mnStagesById.remove(ms.Id);	
					break;	
				}
			}
		}
		
		update this.mnStages;
		
		this.mnStages = mnStagesById.values(); 
	}
	
	private void deduplicate() {
		p('deduplicate');
		Map<String, MnStage__c> mnStagesDeduped = new Map<String, MnStage__c>();
		
		for (MnStage__c ms : this.mnStages) {
			String opptyExtId = ms.Reg_Oppty_Num__c + '-' + ms.Reg_Part_OID__c;	
			mnStagesDeduped.put(opptyExtId, ms);
		}
		
		for (MnStage__c ms : this.mnStages) {
			String opptyExtId = ms.Reg_Oppty_Num__c + '-' + ms.Reg_Part_OID__c;
			
			if (mnStagesDeduped.containsKey(opptyExtId) && mnStagesDeduped.get(opptyExtId) !== ms) {
				ms.Status__c = STATUS_DUPLICATED;
				ms.Message__c = 'Duplicated with record Id: ' + mnStagesDeduped.get(opptyExtId).Id;
				ms.Opportunity__c = null;	 
			}
				
		}
		
		update this.mnStages;
		
		this.mnStages = mnStagesDeduped.values();		
	}
	
	private void invalidate() {
		p('invalidate');
		Map<Id, MnStage__c> mnStagesById = new Map<Id, MnStage__c>(this.mnStages); 
		
		for (MnStage__c ms : this.mnStages) {
			ms.Message__c = '';
			
			String message = checkMnStageInvalid(ms);
			
			if (message != '') {
				ms.Status__c = STATUS_INVALID;
				ms.Message__c = message;
				ms.Opportunity__c = null;
				mnStagesById.remove(ms.Id);	
			}
		}
		
		update this.mnStages;
		
		this.mnStages = mnStagesById.values();	
	}
	
	private Map<Id, Boolean> checkOpptyProdsExisted() {
		p('checkOpptyProdsExisted');
		Map<Id, Boolean> result = new Map<Id, Boolean>(); // MnStage__c.Id => Oppty Prod Existed
		Set<String> legacyIds = new Set<String>();
		
		for (MnStage__c ms : this.mnStages) {
			result.put(ms.Id, false);
			legacyIds.add(ms.Reg_Part_OID__c);
		}
		
		List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(legacyIds);
		
		for (MnStage__c ms : this.mnStages) {
			for (OpportunityLineItem oli : opptyProds) {
				if (ms.Reg_Part_OID__c == oli.Legacy_Id__c) {
					result.put(ms.Id, true);
					break;
				} 	
			}	
		}
		
		return result;
	}
	
	private Map<Id, Id> findPricebookEntries() {
		p('findPricebookEntries');
		Map<Id, Id> result = new Map<Id, Id>(); // MnStage__c.Id => PricebookEntry.Id
		
		Set<String> prodSalesItems = new Set<String>();
		
		for (MnStage__c ms : this.mnStages) {
			prodSalesItems.add(ms.Part_12NC__c);	
		}
		
		List<PricebookEntry> pricebookEntries = new PricebookEntriesSelector().selectByProdSalesItemWithProduct(prodSalesItems); 
		
		for (MnStage__c ms : this.mnStages) {
			for (PricebookEntry pe : pricebookEntries) {
				if (ms.Part_12NC__c == pe.Product2.Sales_Item__c && 
				   	ms.Currency_Code__c == pe.CurrencyIsoCode) {
					result.put(ms.Id, pe.Id);
					break;    	
				}	
			}	
		} 	
		
		return result;
	}
	
	private String checkMnStageInvalid(MnStage__c mnStage) {
		p('checkMnStageInvalid');
		String result = mnStage.Message__c;
		
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
		
		if (mnStage.Disti_Name__c == null || mnStage.Disti_Name__c == '') {
			result += 'Disti_Name__c is blank. ';	
		} 
		
		return result;
	}
	
	private String processErrors(List<Database.Error> errors) {
		p('processErrors');
		String result = '';
		
		for (Database.Error err : errors) {
			result += err.getStatusCode() + ': ' + err.getMessage() + '. Fields that affected this error: ' + err.getFields() + '. ';
		}	
		
		return result;
	}

}