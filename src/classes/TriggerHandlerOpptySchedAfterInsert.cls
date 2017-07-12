public class TriggerHandlerOpptySchedAfterInsert extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        updateOpportunityProductQuantity(tp);
        createOpportunityProductSchedules(tp);
    } 
    
    private void updateOpportunityProductQuantity(TriggerParameters tp) {
    	List<OpportunityLineItem> opptyProdsUpdated = OpportunityScheduleHelper.updateOpportunityProductQuantity(tp.newList);
        
        for (OpportunityLineItem oli : opptyProdsUpdated) {
            sObjectsToUpdate.put(oli.Id, oli);  
        }	
    }
    
    private void createOpportunityProductSchedules(TriggerParameters tp) {
    	List<OpportunityProductSchedule__c> opptyProdSchedsInserted = OpportunityScheduleHelper.createOpportunityProductSchedules(tp.newList);
        
        for (OpportunityProductSchedule__c ops : opptyProdSchedsInserted) {
            sObjectsToInsert.add(ops);
        }	
    }  
}