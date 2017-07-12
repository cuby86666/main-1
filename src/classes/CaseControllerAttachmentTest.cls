/***********************************************************************************************
@LastModified By :  Scarlett Kang
@Modified For :   Release 2016.01 SIR#566
@Description :    New field with picklist for Case Service_Category__c
************************************************************************************************/
@isTest
private class CaseControllerAttachmentTest {
    static testMethod void test1() {
        CaseControllerAttachment controller = new CaseControllerAttachment();
        Case testCase = controller.theCase;
        testCase.Case_Owner_Name__c = '';
        testCase.Email__c = '';
        testCase.Application__c = '';
        testCase.Subject = '';
        testCase.Description = '';
        /**1601 Release - SIR 522, Modified by Scarlett**/
        testCase.Service_Category__c = '';
        /**1601 Release - SIR 522, Modified by Scarlett- END**/
        controller.theCase = testCase;
        controller.Submit();
    }
    
    static testMethod void test2() {
        ApexPages.currentPage().getParameters().put('success','1');
        CaseControllerAttachment controller = new CaseControllerAttachment();
        Case testCase = controller.theCase;
        testCase.Case_Owner_Name__c = 'Data Admin';
        testCase.Email__c = 'test';
        testCase.Application__c = 'Apttus';
        testCase.Subject = 'test';
        testCase.Description = 'test';
        /**1601 Release - SIR 522, Modified by Scarlett**/
        testCase.Service_Category__c = 'test';
        /**1601 Release - SIR 522, Modified by Scarlett - END**/
        controller.theCase = testCase;
        Attachment testAttachment = controller.theAttachment;
        testAttachment.Body = Blob.valueOf('Unit Test Attachment Body');
        controller.theAttachment = testAttachment;
        controller.Submit();
    }
    
    static testMethod void test3() {
        CaseControllerAttachment controller = new CaseControllerAttachment();
        controller.theCase = new Case();
        controller.theAttachment = new Attachment();
        controller.Submit();
    }
}