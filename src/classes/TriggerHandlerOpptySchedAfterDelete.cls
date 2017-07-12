public class TriggerHandlerOpptySchedAfterDelete extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        updateOpportunityProductQuantity(tp); 
        OpportunityScheduleHelper.deleteOpportunityProductSchedules(tp.oldList);
    } 
    
    private void updateOpportunityProductQuantity(TriggerParameters tp) {
    	List<OpportunityLineItem> opptyProdsUpdated = OpportunityScheduleHelper.updateOpportunityProductQuantity(tp.oldList);
        
        for (OpportunityLineItem oli : opptyProdsUpdated) {
            sObjectsToUpdate.put(oli.Id, oli);  
        }	
    } 
}