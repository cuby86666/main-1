public class TriggerHandlerOpptyProdBeforeInsert extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		//J OpportunityProductHelper.checkOpportunitySchedule(tp.newList);
		
		//J OpportunityLineItemTrigger.onBeforeInsert(tp.newList);

		//J OpportunityProductHelper.setOpportunityProductLastBusinessModifiedInfo(tp.newList);
		//J OpportunityProductHelper.setOpportunityProductQuantity(tp.newList);
		//J OpportunityProductHelper.setOpportunityProductLostCancelledInfo(tp.newList);
		//J OpportunityProductClaimValue.setOpportunityProductClaimValues(tp.newList);	
	}    
}