public class OpportunityLineItemsSelector extends ApplicationSelector {

	public Schema.SObjectType getSObjectType() {
		return OpportunityLineItem.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			OpportunityLineItem.Id,
			OpportunityLineItem.OpportunityId,
			OpportunityLineItem.Program__c
		};
	}
	
	public List<OpportunityLineItem> selectById(Set<Id> ids) {
		p('selectById');
		return (List<OpportunityLineItem>)selectSObjectsById(ids);
	}
	
	public List<OpportunityProductValueSummary> selectLifetimeValueByOpptyIdGroupByMag(Set<Id> opptyIds) {
		p('selectLifetimeValueByOpptyIdGroupByMag');
		List<OpportunityProductValueSummary> result = new List<OpportunityProductValueSummary>();
		
		List<AggregateResult> opptyProdMagLtValues = 
			[select PricebookEntry.Product2.MAG__c mag, sum(LT_Value_USD__c) totalMagLtValue
           	   from OpportunityLineItem 
          	  where OpportunityId in :opptyIds 
          	    and Prod_Lost_Cancelled__c = null
         	 group by PricebookEntry.Product2.MAG__c];
         	 
		for (AggregateResult ar : opptyProdMagLtValues) {
			result.add(new OpportunityProductValueSummary(ar));	
		}         	 	
		
		return result;
	}
	
	public List<OpportunityProductValueSummary> selectLifetimeValueByOpptyIdGroupByBl(Set<Id> opptyIds) {
		p('selectLifetimeValueByOpptyIdGroupByBl');
		List<OpportunityProductValueSummary> result = new List<OpportunityProductValueSummary>();
		
		List<AggregateResult> opptyProdBlLtValues = 
			[select PricebookEntry.Product2.BL__c bl, sum(LT_Value_USD__c) totalBlLtValue
           	   from OpportunityLineItem 
          	  where OpportunityId in :opptyIds 
          	    and Prod_Lost_Cancelled__c = null
         	 group by PricebookEntry.Product2.BL__c];
         	 
		for (AggregateResult ar : opptyProdBlLtValues) {
			result.add(new OpportunityProductValueSummary(ar));	
		}         	 	
		
		return result;
	}
	
	public class OpportunityProductValueSummary {
		private AggregateResult result;
		
		private OpportunityProductValueSummary(AggregateResult result) {
			this.result = result;	
		}
		
		public String mag { 
			get { return (String)result.get('mag'); } 
		}
		
		public Double totalMagLtValue { 
			get { return (Double)result.get('totalMagLtValue'); } 
		}
		
		public String bl { 
			get { return (String)result.get('bl'); } 
		}
		
		public Double totalBlLtValue { 
			get { return (Double)result.get('totalBlLtValue'); } 
		}
	}
	
	private static void p(String msg) {
		System.debug('//-s OpportunityLineItemsSelector - ' + msg);
	}
    
}