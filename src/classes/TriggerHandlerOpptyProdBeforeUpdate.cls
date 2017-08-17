public class TriggerHandlerOpptyProdBeforeUpdate extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		// TMMA
		//J OpportunityProductClaimValue.bypassOpportunityProductMnUpdateForTmmaOverride((Map<ID, OpportunityLineItem>)tp.oldMap, (Map<ID, OpportunityLineItem>)tp.newMap);
		
		//J OpportunityProductClaimValue.setOpportunityProductClaimValues(tp.newList);	
		//J OpportunityProductHelper.setOpportunityProductLastBusinessModifiedInfo(tp.newList);
        //J OpportunityProductHelper.updateOpportunityProductLostCancelledInformation(tp.oldList, tp.newList);
		
		//J OpportunityLineItemTrigger.onBeforeUpdate(tp.newList);
	}    
}