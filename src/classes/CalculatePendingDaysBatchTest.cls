@isTest //(SeeAllData=true)
public class CalculatePendingDaysBatchTest{
    static testMethod void theTest() {
        Approver_History__c tempRecord = new Approver_History__c (Temp_Record__c = true,Approver_Action_Date__c = datetime.newInstance(2014, 1, 01));
        insert tempRecord;
        
        Approver_History__c AH1 = new Approver_History__c
        (
        Actor_Username__c = 'test0@test',
        Status__c = null,
        Approval_Status__c = 'Approved',
        Target_Object_ID__c = '001D0000016UgJyIAK',
        Approver_Action_Date__c = datetime.newInstance(2014, 1, 17),
        Temp_Record__c = false
        );
        insert AH1;
        Approver_History__c AH2 = new Approver_History__c
        (
        Actor_Username__c = 'test1@test',
        Status__c = 'Approved',
        Approval_Status__c = 'Approved',
        Target_Object_ID__c = '001D0000016UgJyIAK',
        Approver_Action_Date__c = System.now(),
        Temp_Record__c = false
        );
        insert AH2;
        
        Approver_History__c AH3 = new Approver_History__c
        (
        Actor_Username__c = 'test0@test',
        Status__c = null,
        Approval_Status__c = 'Approved',
        Target_Object_ID__c = '001D0000016VxmbIAC',
        Approver_Action_Date__c = datetime.newInstance(2014, 1, 17),
        Temp_Record__c = false
        );
        insert AH3;
        Approver_History__c AH4 = new Approver_History__c
        (
        Actor_Username__c = 'test1@test',
        Status__c = 'Pending',
        Approval_Status__c = 'Approved',
        Target_Object_ID__c = '001D0000016VxmbIAC',
        Approver_Action_Date__c = datetime.newInstance(2014, 1, 20),
        Temp_Record__c = false
        );
        insert AH4;
        
        Approver_History__c AH5 = new Approver_History__c
        (
        Actor_Username__c = 'test0@test',
        Status__c = 'Started',
        Approval_Status__c = 'Pending',
        Target_Object_ID__c = '001D00000176mBwIAI',
        Approver_Action_Date__c = datetime.newInstance(2014, 1, 17),
        Temp_Record__c = false
        );
        insert AH5;
        Approver_History__c AH6 = new Approver_History__c
        (
        Actor_Username__c = 'test0@test',
        Status__c = 'Pending',
        Approval_Status__c = 'Pending',
        Target_Object_ID__c = '001D00000176mBwIAI',
        Approver_Action_Date__c = datetime.newInstance(2014, 1, 20),
        Temp_Record__c = false
        );
        insert AH6;
        Approver_History__c AH7 = new Approver_History__c
        (
        Actor_Username__c = 'test0@test',
        Status__c = null,
        Approval_Status__c = 'NoResponse',
        Target_Object_ID__c = '001D00000176mBwIAI',
        Approver_Action_Date__c = datetime.newInstance(2014, 1, 20),
        Temp_Record__c = false
        );
        insert AH7;
        
        Test.StartTest();
        CalculatePendingDaysBatch testA = new CalculatePendingDaysBatch();
        Database.executeBatch(testA);
        //Database.executeBatch(new CalculatePendingDaysBatch());
        Test.StopTest();
    }
}