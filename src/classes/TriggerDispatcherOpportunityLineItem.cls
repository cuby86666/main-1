public class TriggerDispatcherOpportunityLineItem extends TriggerDispatcherBase {
	private static Boolean isBeforeInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;
	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false;
	private static Boolean isAfterDeleteProcessing = false;
		
	public override void beforeInsert(TriggerParameters tp) {
		if (!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			execute(new TriggerHandlerOpptyProdBeforeInsert(), tp, TriggerParameters.TriggerEvent.beforeInsert);
			isBeforeInsertProcessing = false;
		} else {
			//execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert);
		}
	}
	
	public override void beforeUpdate(TriggerParameters tp) {
		if (!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new TriggerHandlerOpptyProdBeforeUpdate(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
			isBeforeUpdateProcessing = false;
		} else {
			//execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate);
		}
	} 
	
	public override void afterInsert(TriggerParameters tp) {
		if(!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			execute(new TriggerHandlerOpptyProdAfterInsert(), tp, TriggerParameters.TriggerEvent.afterInsert);
			isAfterInsertProcessing = false;
		} else {
			//execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
		}
	}
	
	public override void afterUpdate(TriggerParameters tp) {
		if(!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			execute(new TriggerHandlerOpptyProdAfterUpdate(), tp, TriggerParameters.TriggerEvent.afterUpdate);
			isAfterUpdateProcessing = false;
		} else {
			//execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
		}
	}
	
	public override void afterDelete(TriggerParameters tp) {
		if(!isAfterDeleteProcessing) {
			isAfterDeleteProcessing = true;
			execute(new TriggerHandlerOpptyProdAfterDelete(), tp, TriggerParameters.TriggerEvent.afterDelete);
			isAfterDeleteProcessing = false;
		} else {
			//execute(null, tp, TriggerParameters.TriggerEvent.afterDelete);
		}
	} 	
}