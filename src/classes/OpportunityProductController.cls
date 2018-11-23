public with sharing class OpportunityProductController {
	
	private static final Map<String, String> FIELDS = new Map<String, String> {
		OpportunityLineItem.UnitPrice.getDescribe().getName() => 'price',
		OpportunityLineItem.Price_Erosion_Rate__c.getDescribe().getName() => 'priceErosionRate',
		OpportunityLineItem.Component_Multiplier__c.getDescribe().getName() => 'qtyPerSys',
		OpportunityLineItem.Share__c.getDescribe().getName() => 'share',
		OpportunityLineItem.Probability_to_Win__c.getDescribe().getName() => 'probToWin',
		OpportunityLineItem.Help_Needed__c.getDescribe().getName() => 'helpNeeded' 	
	}; 
	
	public class OpportunityProductWrapper {
		@AuraEnabled public String id { get; set; }
		@AuraEnabled public String opptyName { get; set; }
		@AuraEnabled public String opptyUrl { get; set; }
		@AuraEnabled public String ccyCode { get; set; }
		@AuraEnabled public String prodName { get; set; }
		@AuraEnabled public String opptyProdUrl { get; set; }
		@AuraEnabled public Decimal price { get; set; }
		@AuraEnabled public Decimal priceErosionRate { get; set; }
		@AuraEnabled public Decimal qtyPerSys { get; set; }
		@AuraEnabled public Decimal share { get; set; }
		@AuraEnabled public String probToWin { get; set; }
		@AuraEnabled public String helpNeeded { get; set; }
	}
	
	public class Error {
		@AuraEnabled public Map<String, ErrorDetail> rows { get; set; }
	}
	
	public class ErrorDetail {
		@AuraEnabled public String title { get; set; }
		@AuraEnabled public List<String> messages { get; set; }
		@AuraEnabled public List<String> fieldNames { get; set; }
	}
	
	@AuraEnabled
    public static List<OpportunityProductWrapper> getOpportunityProducts(Id progId) {
    	p('getOpportunityProducts');
    	List<OpportunityProductWrapper> result = new List<OpportunityProductWrapper>();
    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByProgramIdAndOwnerIdWithAccountAndOwnerAndProducts(new Set<Id> {progId}, new Set<Id> {UserInfo.getUserId()});
    	
    	for (Opportunity o : oppties) {
    		for (OpportunityLineItem oli : o.OpportunityLineItems) {
    			OpportunityProductWrapper opw = new OpportunityProductWrapper();
    			opw.id = oli.Id;
    			opw.opptyName = o.Name;
    			opw.opptyUrl = '/' + o.Id;
    			opw.ccyCode = o.CurrencyIsoCode;
    			opw.prodName = oli.Product_Name__c;
    			opw.opptyProdUrl = '/' + oli.Id;
    			opw.price = oli.UnitPrice;
    			opw.priceErosionRate = oli.Price_Erosion_Rate__c / 100;
    			opw.qtyPerSys = oli.Component_Multiplier__c;
    			opw.share = oli.Share__c / 100;
    			opw.probToWin = oli.Probability_to_Win__c;
    			opw.helpNeeded = oli.Help_Needed__c;
    			result.add(opw);		
    		}
    	}
    	
    	return result;	
    }
    
    @AuraEnabled
    public static void updateOpportunityProducts(String changedValues) {
    	List<OpportunityLineItem> opptyProdsUpdated = new List<OpportunityLineItem>();

    	for (OpportunityProductWrapper opw : (List<OpportunityProductWrapper>)JSON.deserialize(changedValues, List<OpportunityProductWrapper>.class)) {
    		OpportunityLineItem oli = new OpportunityLineItem();
    		oli.Id = opw.id;
    		if (opw.price != null) oli.UnitPrice = opw.price;
    		if (opw.priceErosionRate != null) oli.Price_Erosion_Rate__c = opw.priceErosionRate * 100;
    		if (opw.qtyPerSys != null) oli.Component_Multiplier__c = opw.qtyPerSys;
    		if (opw.share != null) oli.Share__c = opw.share * 100;
    		//if (opw.probToWin != null) oli.Probability_to_Win__c = opw.probToWin;
    		if (opw.helpNeeded != null) oli.Help_Needed__c = opw.helpNeeded;
    		opptyProdsUpdated.add(oli);  	
    	}
    	
    	List<Database.SaveResult> opptyProdsUpdateResults = Database.update(opptyProdsUpdated, false);
    	
    	Map<String, ErrorDetail> errDetailsById = new Map<String, ErrorDetail>();
    	    	
    	for (Integer i = 0; i < opptyProdsUpdateResults.size(); i++) {
    		Database.SaveResult sr = opptyProdsUpdateResults.get(i);
    		
    		if (!sr.isSuccess()) {
    			ErrorDetail errDetail = new ErrorDetail();
    			List<String> messages = new List<String>(); 
    			List<String> fieldNames = new List<String>();
    			
    			for (Database.Error e : sr.getErrors()) {
    				messages.add(e.getMessage());
    				
    				for (String f : e.getFields()) {
    					fieldNames.add(FIELDS.get(f));		
    				}
    			}
    			
    			errDetail.title = sr.getErrors().size() + ' error(s) found.';
    			errDetail.messages = messages;
    			errDetail.fieldNames = fieldNames;   
    			errDetailsById.put(opptyProdsUpdated.get(i).Id, errDetail);
    		}
    	}
    	
    	if (errDetailsById.size() > 0) {
    		Error err = new Error();
    		err.rows = errDetailsById;
    		
    		throw new AuraHandledException(JSON.serialize(err));	
    	}
    }
    
    private static void p(String msg) {
		CommonUtils.p(OpportunityScheduleMasterController.class, '//-c', msg);
	}

}