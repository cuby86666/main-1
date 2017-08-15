public class TriggerHandlerOpptySchedAfterDelete extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        //J updateOpportunityProductQuantity(tp); 
        //J OpportunityScheduleHelper.deleteOpportunityProductSchedules(tp.oldList);
    } 
    /*J
    private void updateOpportunityProductQuantity(TriggerParameters tp) {
    	List<OpportunityLineItem> opptyProdsUpdated = OpportunityScheduleHelper.updateOpportunityProductQuantity(tp.oldList);
        
        for (OpportunityLineItem oli : opptyProdsUpdated) {
            sObjectsToUpdate.put(oli.Id, oli);  
        }	
    } 
    */
}