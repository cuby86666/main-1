public class TriggerHandlerOpptySchedBeforeUpdate extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		OpportunityScheduleHelper.updateOpportunitySchedules(tp.oldList, tp.newList);
	}
}