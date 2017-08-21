@isTest
private class fflibTest {
	// Test class for fflib_* classes
	
	class TestDomain extends ApplicationDomain {
		public TestDomain() {
			super();
		}	
	}
	
	@isTest
    static void test() {
    	TestDomain td = new TestDomain();
    	
    	new fflib_Application.UnitOfWorkFactory(new List<SObjectType>{Opportunity.SObjectType}).newInstance(new List<SObjectType>{Opportunity.SObjectType});
    	
    	fflib_QualifiedMethodAndArgValues qmav = new fflib_QualifiedMethodAndArgValues(new fflib_QualifiedMethod(null, null, null), new fflib_MethodArgValues(new List<String>{'test'}), null);
    	qmav.getQualifiedMethod();
    	qmav.getMethodArgValues();
    	qmav.getMockInstance();
    	qmav.toString();
    	
    	OpportunityLineItemsSelector sel = new OpportunityLineItemsSelector();
    	sel.assertIsAccessible();
    	sel.sObjectType();
    	sel.newQueryFactory(false);
    	fflib_QueryFactory qf = new OpportunitiesSelector().newQueryFactory();
    	sel.addQueryFactorySubselect(qf);
    	sel.addQueryFactorySubselect(qf, false);
    	
    	String[] toAddresses = new String[] {'abc@company.com'};
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('support@package.dev');
		mail.setSenderDisplayName('My Package Support');
		mail.setSubject('Package uninstall successful');
		mail.setPlainTextBody('Thanks for uninstalling the package.');
    	new fflib_SObjectUnitOfWork(new List<SObjectType>{Opportunity.SObjectType}).registerEmail(mail);
    	
    	new OpportunitiesSelector().newQueryFactory().getOffset();
    	
    	fflib_SObjectDomain domain = new Opportunities(new List<Opportunity>{new Opportunity()});
    	domain.sObjectType();
    	
    	fflib_SObjectDescribe.getDescribe(new Opportunity());
    	fflib_SObjectDescribe.GlobalDescribeMap gdm = new fflib_SObjectDescribe.GlobalDescribeMap(new Map<String,Schema.SObjectType>{'Opportunity' => Opportunity.SObjectType});
    	gdm.values();
    } 
     
}