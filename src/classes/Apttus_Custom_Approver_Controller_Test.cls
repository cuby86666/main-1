@isTest
private class Apttus_Custom_Approver_Controller_Test 
{
 static testMethod void ApttusCustomApproverTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController != null); 
 }
 
 static testMethod void GetLegalPicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getLegal_Picklist().size() > 0); 
 }
 
 static testMethod void GetApprover1PicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.Approver_1_Role__c = 'GSM Controller';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getApprover1_Picklist().size() > 0); 
 }
  static testMethod void GetApprover2PicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.Approver_2_Role__c = 'GSM Controller';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getApprover2_Picklist().size() > 0); 
 }
  static testMethod void GetApprover3PicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.Approver_3_Role__c = 'GSM Controller';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getApprover3_Picklist().size() > 0); 
 }
  static testMethod void GetApprover4PicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.Approver_4_Role__c = 'GSM Controller';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getApprover4_Picklist().size() > 0); 
 }
  static testMethod void GetApprover5PicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.Approver_5_Role__c = 'GSM Controller';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getApprover5_Picklist().size() > 0); 
 }
  static testMethod void GetApprover6PicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.Approver_6_Role__c = 'GSM Controller';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getApprover6_Picklist().size() > 0); 
 }
  static testMethod void GetApprover7PicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.Approver_7_Role__c = 'GSM Controller';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getApprover7_Picklist().size() > 0); 
 }
  static testMethod void GetApprover8PicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.Approver_8_Role__c = 'GSM Controller';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getApprover8_Picklist().size() > 0); 
 }
  static testMethod void GetApprover9PicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.Approver_9_Role__c = 'GSM Controller';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getApprover9_Picklist().size() > 0); 
 }
  static testMethod void GetMTApproverPicklistTest() {
     Apttus__APTS_Agreement__c testData = new Apttus__APTS_Agreement__c(name='Tester');
     testData.MT_Approver_Role__c = 'Management Team';
     ApexPages.StandardController controller = new ApexPages.StandardController(testData);
     Apttus_Custom_Approver_Controller extController = new Apttus_Custom_Approver_Controller(controller);
     system.assert(extController.getMTApprover_Picklist().size() > 0); 
 }
}