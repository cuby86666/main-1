public class TriggerHandlerOpptyBeforeInsert extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		OpportunityHelper.setOpportunityGeneralInfo(null, tp.newList);
		OpportunityHelper.setOpportunityStarInfo(tp.newList);
		
		OpportunityTrigger.onBeforeInsert(tp.newList);
	}    
}