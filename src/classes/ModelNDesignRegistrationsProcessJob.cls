global class ModelNDesignRegistrationsProcessJob implements Database.Batchable<SObject> {
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		p('start');
		return new MnStagesSelector().selectByStatusQueryLocator(new Set<String> {MnStages.STATUSES.get(MnStages.Status.QUEUED)});
	}
	
	global void execute(Database.BatchableContext bc, List<MnStage__c> scope) {
		p('execute');
		List<Opportunity> oppties = new List<Opportunity>();
		List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>(); 
		
		Map<Id, Boolean> opptyProdExistedByMnStageId = checkOpptyProdExisted(scope);
		
		for (MnStage__c ms : scope) {
			String opptyExtId = ms.Reg_Oppty_Num__c + '-' + ms.Reg_Part_OID__c;
		
			Opportunity oppty = new Opportunity();
			oppty.Legacy_Id__c = opptyExtId;
			oppty.CloseDate = ms.Reg_Production_Date__c;
			oppty.CurrencyIsoCode = ms.Currency_Code__c;
			oppty.Name = (ms.Reg_Oppty_Num__c + ' - ' + ms.Part_Name__c + ' - ' + ms.Prog_Name__c).left(120);
			oppty.RecordTypeId = OpportunitiesSelector.getMnRecordTypeId();
			oppty.StageName = 'Initial Engagement'; // todo
			oppty.Lead_Id__c = ms.Reg_Lead_Id__c;
			oppty.Locked_Exchange_Rate__c = ms.Reg_Exchange_Rate__c;
			oppty.One_Year_Pieces__c = ms.Reg_Project_Units__c;
			oppty.Production_Date__c = ms.Reg_Production_Date__c;
			
			oppties.add(oppty);
			
			OpportunityLineItem opptyProd = new OpportunityLineItem();
			opptyProd.Legacy_Id__c = ms.Reg_Part_OID__c;
			opptyProd.Opportunity = new Opportunity(Legacy_Id__c = opptyExtId);
			
			if (!opptyProdExistedByMnStageId.get(ms.Id)) { // PricebookEntryId can be set only when an oppty prod is created.
				opptyProd.PricebookEntryId = '01u20000008gOhfAAE';	
			} 
			
			opptyProd.UnitPrice = ms.Reg_Part_ASP__c;
			opptyProd.Component_Multiplier__c = ms.Reg_Part_Qty_Per_Sys__c; 
			
			opptyProds.add(opptyProd);
		}	
		
		Database.UpsertResult[] opptiesUpsertResults = Database.upsert(oppties, Opportunity.Fields.Legacy_Id__c, true);
		Database.UpsertResult[] opptyProdsUpsertResults = Database.upsert(opptyProds, OpportunityLineItem.Fields.Legacy_Id__c, true);
		
		for (MnStage__c ms : scope) {
			ms.Status__c = 'Completed';
		}
		
		update scope; 
	}
	
	global void finish(Database.BatchableContext bc) {
		p('finish');	
	}
	
	private static Map<Id, Boolean> checkOpptyProdExisted(List<MnStage__c> mnStages) {
		Map<Id, Boolean> result = new Map<Id, Boolean>(); // MnStage__c.Id -> Oppty Prod Existed
		Set<String> legacyIds = new Set<String>();
		
		for (MnStage__c ms : mnStages) {
			result.put(ms.Id, false);
			legacyIds.add(ms.Reg_Part_OID__c);
		}
		
		List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByLegacyId(legacyIds);
		
		for (MnStage__c ms : mnStages) {
			for (OpportunityLineItem oli : opptyProds) {
				if (ms.Reg_Part_OID__c == oli.Legacy_Id__c) {
					result.put(ms.Id, true);
					break;
				} 	
			}	
		}
		
		return result;
	}
	
	private static void p(String msg) {
		CommonUtils.p(ModelNDesignRegistrationsProcessJob.class, '//-c', msg);
   	}
    
}