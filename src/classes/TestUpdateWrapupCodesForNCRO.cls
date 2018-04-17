@isTest
public class TestUpdateWrapupCodesForNCRO {
	@isTest
    public static void testNCRODataWrapupUpdate(){
    	List<Natterbox_Call_Reporting_Object__c> nboxdata = Test.loadData(Natterbox_Call_Reporting_Object__c.sObjectType, 'nbox_test_data_ncro');    
		List<Task> nboxtaskdata = Test.loadData(Task.sObjectType, 'nbox_test_data_task');            
        System.assert(nboxdata.size()>0);
        System.assert(nboxtaskdata.size()>0);
        System.debug(' data loaded '+nboxdata.size());
        Test.startTest();
        Database.executeBatch(new UpdateWrapupCodesForNCRO());
        Test.stopTest();
        List<Natterbox_Call_Reporting_Object__c> updatednboxdata = [SELECT Id,Wrapup_String_1__c, Wrapup_String_2__c, Bridge_UUID__c from Natterbox_Call_Reporting_Object__c where (Wrapup_String_1__c = null OR Wrapup_String_2__c = null) and Bridge_UUID__c <> null];
		System.assert(updatednboxdata == null || updatednboxdata.size()==0);
    }
}