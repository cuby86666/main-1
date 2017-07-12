public class TriggerHandlerOpptyProdAfterInsert extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		OpportunityLineItemTrigger.onAfterInsert_Update_Delete(tp.newList);
		
		createOpportunityProductSchedules(tp);
	} 
	
	private void createOpportunityProductSchedules(TriggerParameters tp) {
		List<OpportunityProductSchedule__c> opptyProdSchedsInserted = OpportunityProductHelper.createOpportunityProductSchedules(tp.newList);
		
		for (OpportunityProductSchedule__c ops : opptyProdSchedsInserted) {
			sObjectsToInsert.add(ops);	
		}	
	}   
}