public class TriggerDispatcherOpportunity extends TriggerDispatcherBase {
    private static Boolean isBeforeInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;
	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false;
	
	public override void beforeInsert(TriggerParameters tp) {
		if (!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			execute(new TriggerHandlerOpptyBeforeInsert(), tp, TriggerParameters.TriggerEvent.beforeInsert);
			isBeforeInsertProcessing = false;
		} else {
			//execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert);
		}
	} 

	public override void beforeUpdate(TriggerParameters tp) {
		if (!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new TriggerHandlerOpptyBeforeUpdate(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
			isBeforeUpdateProcessing = false;
		} else {
			//execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate);
		}
	} 
	
	public override void afterInsert(TriggerParameters tp) {
		if (!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			execute(new TriggerHandlerOpptyAfterInsert(), tp, TriggerParameters.TriggerEvent.afterInsert);
			isAfterInsertProcessing = false;
		} else {
			//execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
		}
	}
	
    public override void afterUpdate(TriggerParameters tp) {
		if (!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			execute(new TriggerHandlerOpptyAfterUpdate(), tp, TriggerParameters.TriggerEvent.afterUpdate);
			isAfterUpdateProcessing = false;
		} else {
			//execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
		}
	}   
}