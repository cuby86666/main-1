public class TriggerHandlerOpptyProdAfterDelete extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        //J OpportunityLineItemTrigger.onAfterInsert_Update_Delete(tp.oldList);
        
        //J deleteOpportunityProductScheds(tp); 
    } 
    /*J
    private void deleteOpportunityProductScheds(TriggerParameters tp) {
    	List<OpportunityProductSchedule__c> opptyProdSchedsDeleted = OpportunityProductHelper.deleteOpportunityProductScheds(tp.oldList);
        
        for (OpportunityProductSchedule__c opptyProdSched : opptyProdSchedsDeleted) {
            sObjectsToDelete.add(opptyProdSched);   
        }	
    }  
    */ 
}