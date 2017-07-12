public class TriggerHandlerOpptySchedAfterUpdate extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
        updateOpportunityProductQuantity(tp);	
		updateOpportunityProductSchedules(tp);
	}
	
	private void updateOpportunityProductQuantity(TriggerParameters tp) {
		List<OpportunityLineItem> opptyProdsUpdated = OpportunityScheduleHelper.updateOpportunityProductQuantity(tp.newList);
		
		for (OpportunityLineItem oli : opptyProdsUpdated) {
			sObjectsToUpdate.put(oli.Id, oli);	
		}	
	}
	
	private void updateOpportunityProductSchedules(TriggerParameters tp) {
		List<OpportunityProductSchedule__c> opptyProdSchedsUpdated = 
            OpportunityScheduleHelper.updateOpportunityProductSchedules(tp.oldList, tp.newList);

        for(OpportunityProductSchedule__c ops : opptyProdSchedsUpdated){
            sObjectsToUpdate.put(ops.Id, ops);
        }	
	}     
}