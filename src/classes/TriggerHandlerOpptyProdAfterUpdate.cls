public class TriggerHandlerOpptyProdAfterUpdate extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
    	// TMMA
    	OpportunityProductClaimValue.updateTmmaOverrideIfOpportunityProductMnUpdatedByTMMA((Map<ID, OpportunityLineItem>)tp.oldMap, (Map<ID, OpportunityLineItem>)tp.newMap);
    	
        OpportunityLineItemTrigger.onAfterInsert_Update_Delete(tp.newList);
        
        deleteOpportunityProductSchedues(tp);
        createOpportunityProductSchedules(tp);
        updateOpportunityProductSchedules(tp);
    }
    
    private void updateOpportunityProductSchedules(TriggerParameters tp) {
    	List<OpportunityProductSchedule__c> opptyProdSchedsUpdatedPrice = OpportunityProductHelper.updateOpportunityProducySchedules(tp.oldList, tp.newList);
        
        for (OpportunityProductSchedule__c opptyProdSched : opptyProdSchedsUpdatedPrice) {
            sObjectsToUpdate.put(opptyProdSched.Id, opptyProdSched);    
        }	
    } 
    
    private void deleteOpportunityProductSchedues(TriggerParameters tp) {
    	List<OpportunityProductSchedule__c> opptyProdSchedsDeleted = OpportunityProductHelper.deleteLostCancelledOpportunityProductSchedules(tp.oldList, tp.newList);
    
    	for (OpportunityProductSchedule__c opptyProdSched : opptyProdSchedsDeleted) {
            sObjectsToDelete.add(opptyProdSched);    
        }	
    }
    
    private void createOpportunityProductSchedules(TriggerParameters tp) {
    	List<OpportunityProductSchedule__c> opptyProdSchedsInserted = OpportunityProductHelper.createReOpenOpportunityProductSchedules(tp.oldList, tp.newList);
    	
    	for (OpportunityProductSchedule__c opptyProdSched : opptyProdSchedsInserted) {
            sObjectsToInsert.add(opptyProdSched);  
        }	
    }
}