public class TriggerHandlerOpptyBeforeUpdate extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
        //J OpportunityHelper.setOpportunityGeneralInfo(tp.oldList, tp.newList);
        //J OpportunityHelper.setOpportunityStarInfo(tp.newList);
		
		// TMMA
		//J OpportunityProductClaimValue.updateTmmaOverrideIfOpportunityMnUpdatedByTMMA((Map<ID, Opportunity>)tp.oldMap, (Map<ID, Opportunity>)tp.newMap);  
    	//J OpportunityProductClaimValue.bypassOpportunityMnUpdateForTmmaOverride((Map<ID, Opportunity>)tp.oldMap, (Map<ID, Opportunity>)tp.newMap);
		
		//J OpportunityTrigger.onBeforeUpdate(tp.newList, (Map<ID, Opportunity>)tp.oldMap);
	}    
}