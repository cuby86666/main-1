public class TriggerHandlerOpptyBeforeUpdate extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
        OpportunityHelper.setOpportunityGeneralInfo(tp.oldList, tp.newList);
        OpportunityHelper.setOpportunityStarInfo(tp.newList);
		
		// TMMA
		//J OpportunityProductClaimValue.updateTmmaOverrideIfOpportunityMnUpdatedByTMMA((Map<ID, Opportunity>)tp.oldMap, (Map<ID, Opportunity>)tp.newMap);  
    	//J OpportunityProductClaimValue.bypassOpportunityMnUpdateForTmmaOverride((Map<ID, Opportunity>)tp.oldMap, (Map<ID, Opportunity>)tp.newMap);
		
		OpportunityTrigger.onBeforeUpdate(tp.newList, (Map<ID, Opportunity>)tp.oldMap);
	}    
}