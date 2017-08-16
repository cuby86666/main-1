public class TriggerHandlerOpptyAfterUpdate extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
        //J updateOpportunitySchedules(tp);
        //J updateOpportunityProductLostCancelledInfo(tp);
    } 
	/*J
	private void updateOpportunitySchedules(TriggerParameters tp) {
		Map<ID, Opportunity> opptysOldMN = new Map<ID, Opportunity>();
		Map<ID, Opportunity> opptysNewMN = new Map<ID, Opportunity>();
		Map<ID, Opportunity> opptysOldSFDC = new Map<ID, Opportunity>();
		Map<ID, Opportunity> opptysNewSFDC = new Map<ID, Opportunity>();
		
		for (SObject o : tp.oldList) {
			if (isMnOpptySchedsUpdatable((Opportunity)o)) {
				opptysOldMN.put(o.Id, (Opportunity)o);	
			} else {
				opptysOldSFDC.put(o.Id, (Opportunity)o);
			}
		}
		
		for (SObject o : tp.newList) {
			if (isMnOpptySchedsUpdatable((Opportunity)o)) {
				opptysNewMN.put(o.Id, (Opportunity)o);	
			} else {
				opptysNewSFDC.put(o.Id, (Opportunity)o);
			}
		}
		
		if (opptysOldMN.size() > 0 && opptysNewMN.size() > 0) {
			List<OpportunitySchedule__c> opptySchedsUpdated = OpportunityHelper.updateOpportunitySchedulesMN(opptysOldMN, opptysNewMN);
		
			for (OpportunitySchedule__c os : opptySchedsUpdated) {
				sObjectsToUpdate.put(os.Id, os);	
			}	
		}
		
		if (opptysOldSFDC.size() > 0 && opptysNewSFDC.size() > 0) {
			List<OpportunitySchedule__c> opptySchedsUpdated = OpportunityHelper.updateOpportunitySchedulesSFDC(opptysOldSFDC, opptysNewSFDC);
		
			for (OpportunitySchedule__c os : opptySchedsUpdated) {
				sObjectsToUpdate.put(os.Id, os);	
			}	
		}
	}
	
	private Boolean isMnOpptySchedsUpdatable(Opportunity oppty) {
		return OpportunityHelper.isRecordTypeMN(oppty) && !OpportunityHelper.isTmmaOverride(oppty) && CommonUtils.isIntegrationUser();
	}
	*/
	/*J
	private void updateOpportunityProductLostCancelledInfo(TriggerParameters tp){
		List<OpportunityLineItem> opptyProds = OpportunityHelper.updateOpportunityProductLostCancelledInfo(tp.oldList, tp.newList);
		
		for (OpportunityLineItem opptyProd : opptyProds) {
			sObjectsToUpdate.put(opptyProd.Id, opptyProd);
		}
	}
	*/
}