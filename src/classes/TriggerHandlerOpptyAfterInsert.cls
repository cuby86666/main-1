public class TriggerHandlerOpptyAfterInsert extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		//J createOpportunitySchedulesMN(tp);	
	} 
	/*J
	private void createOpportunitySchedulesMN(TriggerParameters tp) {
		List<SObject> opptysMN = new List<SObject>();
		
		for (SObject o : tp.newList) {
			if (((Opportunity)o).RecordTypeId == OpportunityHelper.getMnRecordTypeID()) {
				opptysMN.add(o);	
			}
		}
		
		if (opptysMN.size() > 0) {
			List<OpportunitySchedule__c> opptySchedsInserted = OpportunityHelper.createOpportunitySchedulesMN(opptysMN);
		
			for (OpportunitySchedule__c os : opptySchedsInserted) {
				sObjectsToInsert.add(os);	
			}	
		}	
	} 
	*/
}