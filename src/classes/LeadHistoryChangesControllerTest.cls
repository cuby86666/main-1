@IsTest
private class LeadHistoryChangesControllerTest {
	@IsTest
    static void queryLeadHistoryRecords() {
        // Given
        Account acc = new Account(Name='test Account');
        insert acc;

        Contact contact1 = new Contact(FirstName='Test',LastName='1',AccountId= acc.id,Email='testsfdc1111@nxp.com');
        insert contact1;
        
        Lead lead1 = new Lead(Company = 'NXP', LastName = 'Test', Status = 'Open',
                              Email='testsfdc1111@nxp.com', Distributor_Contact__c= contact1.Id);
        insert lead1;
  		
        // When
        LeadHistoryChangesController.LeadHistoryWrapper lhw = LeadHistoryChangesController.queryLeadHistoryRecords(1,10,lead1.Id);

		// Then
		System.assertNotEquals(null, lhw);
    }
}