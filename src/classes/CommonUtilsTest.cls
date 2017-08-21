@isTest
private class CommonUtilsTest {
	@isTest
    static void testGetSObjectTypeName() {
    	Account a = new Account();
    	
    	System.assertEquals('Account', CommonUtils.getSObjectTypeName(a));
    }
    
    @isTest
    static void testGetChildRelationshipName() {
    	System.assertEquals('OpportunityLineItems', CommonUtils.getChildRelationshipName(Opportunity.SObjectType, OpportunityLineItem.SObjectType));	
    }
	
    @isTest
    static void testRoundDouble() {
    	Double a = 0.87542734;
    	Double b = 0.87542754;
    	Double c = 0.87542784;
    	
    	System.assertEquals(0.875427, CommonUtils.roundDouble(a, 6));
    	System.assertEquals(0.875428, CommonUtils.roundDouble(b, 6));	
    	System.assertEquals(0.875428, CommonUtils.roundDouble(c, 6));
    }
    
    @isTest
    static void testIdGetters() {
    	System.assertNotEquals(null, CommonUtils.getIntegrationUserProfileId());
    	System.assertNotEquals(null, CommonUtils.getSystemAdminProfileId());
    	System.assertNotEquals(null, CommonUtils.getDataAdminUserId());
    }
    
}