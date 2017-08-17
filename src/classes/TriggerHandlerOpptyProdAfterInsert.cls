public class TriggerHandlerOpptyProdAfterInsert extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		//J OpportunityLineItemTrigger.onAfterInsert_Update_Delete(tp.newList);
		
		//J createOpportunityProductSchedules(tp);
	} 
	/*J
	private void createOpportunityProductSchedules(TriggerParameters tp) {
		List<OpportunityProductSchedule__c> opptyProdSchedsInserted = OpportunityProductHelper.createOpportunityProductSchedules(tp.newList);
		
		for (OpportunityProductSchedule__c ops : opptyProdSchedsInserted) {
			sObjectsToInsert.add(ops);	
		}	
	}  
	*/ 
}