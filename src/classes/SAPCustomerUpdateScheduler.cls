global class SAPCustomerUpdateScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
		SAPCustomerUpdateBatch objBatch = new SAPCustomerUpdateBatch();
		Database.executeBatch(objBatch);
    }
}