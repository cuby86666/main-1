public class OpportunityLineItemsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return OpportunityLineItem.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			OpportunityLineItem.Id,
			OpportunityLineItem.OpportunityId,
			OpportunityLineItem.Product2Id,
			OpportunityLineItem.Quantity,
			OpportunityLineItem.UnitPrice,
			OpportunityLineItem.Component_Multiplier__c,
			OpportunityLineItem.Price_Erosion_Rate__c,
			OpportunityLineItem.Prod_Lost__c,
			OpportunityLineItem.Prod_Lost_Cancelled__c,
			OpportunityLineItem.Prod_Lost_Cancelled_Date__c, 
			OpportunityLineItem.Prod_Lost_Cancelled_Reason__c,
			OpportunityLineItem.Prod_Lost_Reason__c, 
			OpportunityLineItem.Program__c,
			OpportunityLineItem.Share__c
		};
	}
	
	public List<OpportunityLineItem> selectByOpptyIdWithOpportunity(Set<Id> opptyIds) {
		p('selectByOpptyIdWithOpportunity(opptyIds)');
		return selectByOpptyIdWithOpportunity(opptyIds, null);
	}
	
	public List<OpportunityLineItem> selectByOpptyIdWithOpportunity(Set<Id> opptyIds, Set<String> lostCancelled) {
		p('selectByOpptyIdWithOpportunity(opptyIds, lostCancelled)');
		fflib_QueryFactory opptyLineItemsQueryFactory = newQueryFactory();
		
		new OpportunitiesSelector().configureQueryFactoryFields(opptyLineItemsQueryFactory, OpportunityLineItem.OpportunityId.getDescribe().getRelationshipName());	
		
		String condition = 'OpportunityId in :opptyIds';
		 
		if (lostCancelled != null) {
			condition += ' and Prod_Lost_Cancelled__c not in :lostCancelled';
		}
		
		return (List<OpportunityLineItem>)Database.query(opptyLineItemsQueryFactory.setCondition(condition).toSOQL());
	}
	
	public Map<Id, List<OpportunityProductValueSummary>> selectLifetimeValueByOpptyIdGroupByOpptyIdAndMag(Set<Id> opptyIds) {
		p('selectLifetimeValueByOpptyIdGroupByOpptyIdAndMag');
		List<OpportunityProductValueSummary> opptyProdValSummaries = new List<OpportunityProductValueSummary>();
		
		List<AggregateResult> opptyProdMagLtValues = 
			[select OpportunityId opptyId, PricebookEntry.Product2.MAG__c mag, sum(LT_Value_USD__c) totalMagLtValue
           	   from OpportunityLineItem 
          	  where OpportunityId in :opptyIds 
          	    and Prod_Lost_Cancelled__c = null
         	 group by OpportunityId, PricebookEntry.Product2.MAG__c
         	 order by OpportunityId, PricebookEntry.Product2.MAG__c];
         	 
		for (AggregateResult ar : opptyProdMagLtValues) {
			opptyProdValSummaries.add(new OpportunityProductValueSummary(ar));	
		}         	 	
		
		return convertToMap(opptyProdValSummaries);
	}
	
	public Map<Id, List<OpportunityProductValueSummary>> selectLifetimeValueByOpptyIdGroupByOpptyIdAndBl(Set<Id> opptyIds) {
		p('selectLifetimeValueByOpptyIdGroupByOpptyIdAndBl');
		List<OpportunityProductValueSummary> opptyProdValSummaries = new List<OpportunityProductValueSummary>();
		
		List<AggregateResult> opptyProdBlLtValues = 
			[select OpportunityId opptyId, PricebookEntry.Product2.BL__c bl, sum(LT_Value_USD__c) totalBlLtValue
           	   from OpportunityLineItem 
          	  where OpportunityId in :opptyIds 
          	    and Prod_Lost_Cancelled__c = null
         	 group by OpportunityId, PricebookEntry.Product2.BL__c
         	 order by OpportunityId, PricebookEntry.Product2.BL__c];
         	 
		for (AggregateResult ar : opptyProdBlLtValues) {
			opptyProdValSummaries.add(new OpportunityProductValueSummary(ar));	
		}         	 	
		
		return convertToMap(opptyProdValSummaries);
	}
	
	public class OpportunityProductValueSummary {
		private AggregateResult result;
		
		private OpportunityProductValueSummary(AggregateResult result) {
			this.result = result;	
		}
		
		public Id opptyId { 
			get { return (Id)result.get('opptyId'); } 
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
	
	private Map<Id, List<OpportunityProductValueSummary>> convertToMap(List<OpportunityProductValueSummary> opptyProdValSummaries) {
		Map<Id, List<OpportunityProductValueSummary>> result = new Map<Id, List<OpportunityProductValueSummary>>();
		
		Id key = null;
		List<OpportunityProductValueSummary> value = new List<OpportunityProductValueSummary>();  
		
		for (OpportunityProductValueSummary opvs : opptyProdValSummaries) {
			if (key == null) {
				key = opvs.opptyId;
			}
			
			if (key == opvs.opptyId) {
				value.add(opvs);	
			} else {
				key = opvs.opptyId;
				value = new List<OpportunityProductValueSummary>(); 
				value.add(opvs);
			}
			
			result.put(key, value);
		}	
		
		return result;
	} 
	
}