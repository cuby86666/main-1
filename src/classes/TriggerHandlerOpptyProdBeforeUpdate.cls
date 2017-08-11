public class TriggerHandlerOpptyProdBeforeUpdate extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		// TMMA
		//J OpportunityProductClaimValue.bypassOpportunityProductMnUpdateForTmmaOverride((Map<ID, OpportunityLineItem>)tp.oldMap, (Map<ID, OpportunityLineItem>)tp.newMap);
		
		//J OpportunityProductClaimValue.setOpportunityProductClaimValues(tp.newList);	
		OpportunityProductHelper.setOpportunityProductLastBusinessModifiedInfo(tp.newList);
        OpportunityProductHelper.updateOpportunityProductLostCancelledInformation(tp.oldList, tp.newList);
		
		OpportunityLineItemTrigger.onBeforeUpdate(tp.newList);
	}    
}