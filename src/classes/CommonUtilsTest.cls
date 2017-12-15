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
    	System.assertNotEquals(null, CommonUtils.isAdminOrIntegrationUser());
    	System.assertNotEquals(null, CommonUtils.isIntegrationUser());
    	System.assertNotEquals(null, CommonUtils.isAdmin());
    	System.assertNotEquals(null, CommonUtils.generateGuid());
    }
    
    @isTest
    static void testFxRates() {
    	List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
        fxrs.add(new FX_Rates__c(Name = 'USD', Currency_Code__c = 'USD', CurrencyIsoCode = 'USD', Exchange_Rate__c = 1.0));
        fxrs.add(new FX_Rates__c(Name = 'EUR', Currency_Code__c = 'EUR', CurrencyIsoCode = 'EUR', Exchange_Rate__c = 0.9));
        insert fxrs;
        
    	System.assert(CommonUtils.getFxRatesByCurIsoCode().size() > 0);	
    }
    
    @isTest
    static void testLoggingSetting() {
    	Boolean isLoggingActive = ((List<Logging_Setting__mdt>)new LoggingSettingsSelector().selectWhere('MasterLabel = \'System Debug\'')).get(0).IsActive__c;	
    	
    	System.assertEquals(isLoggingActive, CommonUtils.isLoggingActive);
    }
    
}