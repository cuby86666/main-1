public class TriggerHandlerOpptyProdBeforeInsert extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		OpportunityProductHelper.checkOpportunitySchedule(tp.newList);
		
		OpportunityLineItemTrigger.onBeforeInsert(tp.newList);

		OpportunityProductHelper.setOpportunityProductLastBusinessModifiedInfo(tp.newList);
		OpportunityProductHelper.setOpportunityProductQuantity(tp.newList);
		OpportunityProductHelper.setOpportunityProductLostCancelledInfo(tp.newList);
		OpportunityProductClaimValue.setOpportunityProductClaimValues(tp.newList);	
	}    
}