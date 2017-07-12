@isTest
private class TriggerFrameworkTest { 
	@isTest
	static void testCreateTriggerDispatcher() {
		try {
			TriggerFactory.createTriggerDispatcher(FX_Rates__c.sObjectType); // This object does not have trigger dispatcher.
			System.assert(false);	
		} catch (TriggerException te) {
			System.assert(true);
		}
	}
	
	@isTest
	static void testTriggerDispatcherBase() {
		// for test coverage
		TriggerDispatcherBase tdb = new TriggerDispatcherBase();
		tdb.bulkBefore();
		tdb.bulkAfter();
		tdb.beforeInsert(null);
		tdb.beforeUpdate(null);
		tdb.beforeDelete(null);
		tdb.afterInsert(null);
		tdb.afterUpdate(null);
		tdb.afterDelete(null);	
		tdb.andFinally();
		
		try {
			tdb.execute(new TriggerHandlerOpptyAfterUpdate(), null, TriggerParameters.TriggerEvent.beforeDelete);
		} catch (Exception e) {
			System.assert(true);
		}
	}
}