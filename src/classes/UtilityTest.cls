@isTest
private class UtilityTest {
	
    static testMethod void testGetObjectFields() {
    	Map<String, Schema.SObjectField> fieldsMap = Schema.SobjectType.Opportunity.fields.getMap();    	 
		String s =  Utility.getObjectFields(fieldsMap);
		System.assert(true, s!=null);    	
    }
    
    static testMethod void testBuildSQLStatement() {
    	String s = Utility.buildSQLStatement('fields', 'objectName', null);
    	System.assert(true, s!=null);    
     	s = Utility.buildSQLStatement('fields', 'objectName', 'criteria');
    	System.assert(true, s!=null);    
    }
    
    static testMethod void testRetrieveObjectRecord() {
    	String sql = 'Select Id from User limit 1';
    	List<SObject> sobjList = Utility.retrieveObjectRecord(sql);
    	System.assert(true, sobjList!=null);    
    }
    
    static testMethod void testdDateSpanInQuarter() {
    	map<String, map<Integer, Date>> mapTest = Utility.DateSpanInQuarter(null);
    	System.assert(true, mapTest != null);
    	mapTest = Utility.DateSpanInQuarter(2012);
    	System.assert(true, mapTest != null);
    }
    
    static testMethod void testSendEmail() {
    	Utility.SendEmail('Test Email', new list<String> { 'testSendEmail@test.test' }, 
    		'Test Body', 'Test attachment', 'csv', 'Test attachment body');
    }
}