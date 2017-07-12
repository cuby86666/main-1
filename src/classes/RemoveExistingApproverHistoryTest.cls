@isTest
public class RemoveExistingApproverHistoryTest{
    static testMethod void theTest(){     
        Test.StartTest();
        Approver_History__c AH = new Approver_History__c
        (
            //Target_Object_ID__c = PISi.ProcessInstance.TargetObjectId,
            //Object_URL_2__c = system.URL.getSalesforceBaseUrl().toExternalForm() + '/' + PISi.ProcessInstance.TargetObjectId,
            //Is_Workitem__c = false,
            //Approval_Status__c = PISi.ProcessInstance.Status,
            //Actor_Username__c = PISi.Actor.Username,
            //Actual_Approver__c = PISi.Actor.Id,
            //Approver_Action_Date__c = PISi.CreatedDate,
            Comments__c = 'NULL',
            Approval_Name__c = 'Test delete',
            Status__c = 'Approved Test',
            Temp_Record__c = false
        );
        insert AH;
        
        RemoveExistingApproverHistory RemoveEAH = new RemoveExistingApproverHistory();
        Database.executeBatch(RemoveEAH);
        Test.StopTest();
        
        Integer i = [SELECT COUNT() FROM Approver_History__c];
        System.assertEquals(i, 1);
    }   
}