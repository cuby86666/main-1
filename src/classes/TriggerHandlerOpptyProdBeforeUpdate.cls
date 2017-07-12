public class TriggerHandlerOpptyProdBeforeUpdate extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		// TMMA
		OpportunityProductClaimValue.bypassOpportunityProductMnUpdateForTmmaOverride((Map<ID, OpportunityLineItem>)tp.oldMap, (Map<ID, OpportunityLineItem>)tp.newMap);
		
		OpportunityProductClaimValue.setOpportunityProductClaimValues(tp.newList);	
		OpportunityProductHelper.setOpportunityProductLastBusinessModifiedInfo(tp.newList);
        OpportunityProductHelper.updateOpportunityProductLostCancelledInformation(tp.oldList, tp.newList);
		
		OpportunityLineItemTrigger.onBeforeUpdate(tp.newList);
	}    
}