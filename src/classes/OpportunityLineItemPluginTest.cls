@isTest
private class OpportunityLineItemPluginTest {

	@testSetup
	static void setup() {
		//OpportunityTestFactory.setup();	
        SfdcTestFactory.createSfdcOpportunitiesAndLineItems(1, 5);
	}
    
    static testMethod void testPluginInvoke() {
        OpportunityLineItemPlugin plugin = new OpportunityLineItemPlugin();
        Map<String,String> parms = new Map<String,String>();
        Test.startTest();
        Opportunity oppty = [Select Id, Name from Opportunity limit 1];
        parms.put('Id', oppty.Id);
        Process.PluginRequest request = new Process.PluginRequest(parms);
        Process.PluginResult result = plugin.invoke(request);
        Test.stopTest();
    }
    
    static testMethod void testPluginDescribe() {
        Test.startTest();
        OpportunityLineItemPlugin plugin = new OpportunityLineItemPlugin();
        Process.PluginDescribeResult result = plugin.describe();
        Test.stopTest();
    }
    
    static testMethod void testPluginInvokeException() {
  		Set<String> lostCancelled = new Set<String> {'Lost','Cancelled'};
        OpportunityLineItemPlugin plugin = new OpportunityLineItemPlugin();
        Map<String,String> parms = new Map<String,String>();
        parms.put('Id', '0065E000009K7fNQAS');
        Process.PluginRequest request = new Process.PluginRequest(parms);
        Process.PluginResult result = plugin.invoke(request);
        Boolean productStatus = (Boolean)result.outputParameters.get('ProductStatus');
        System.assert(productStatus == false);
    }
}