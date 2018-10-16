@isTest
private class SAPCMDMassUpdateTest{

/*    
    
    private static final String CMD_REQUEST_SAP_MASS_UPDATE_RECORD_TYPE_ID = '012D0000000QmBTIA0';
//    private static final String CMD_REQUEST_SAP_MASS_UPDATE_RECORD_TYPE_ID = '012M00000004gGJIAY';

    static testmethod void thePositiveTest() {
		CMD_Request__c testRequest = new CMD_Request__c( RecordTypeId = CMD_REQUEST_SAP_MASS_UPDATE_RECORD_TYPE_ID );
        insert testRequest;
        ApexPages.StandardController stdController = new ApexPages.StandardController(testRequest);
   		SAPCMDMassUpdateController theController = new SAPCMDMassUpdateController(stdController);
        system.assert(theController != null);
        theController.addRow();
        theController.add5Rows();
        theController.rowToBeReplicated = '1';
        theController.columnToBeReplicated = 'ZA';
        theController.replicateColumn();
        theController.columnToBeReplicated = 'Address';
        theController.replicateColumn();
        theController.rowToBeRemoved = '1';
        theController.removeRow();
        theController.listFunlocWrapper[0].funloc = '100000';
        theController.listFunlocWrapper[1].funloc = '100001';
        theController.save();
        
//        PageReference pageRef = Page.SAPCMDMassUpdate;
//		Test.setCurrentPage(pageRef);
//		SAPCMDMassUpdateController theController = new SAPCMDMassUpdateController();
    }
*/
}