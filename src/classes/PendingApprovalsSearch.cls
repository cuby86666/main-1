/*  Modified by Michael Fang on 2013-12-6
    Fetch all approval process history, incl. Approved (within a month) and all Pending
    Add Opportunity, Agreement Lookup fields
*/
public with sharing class PendingApprovalsSearch {
    public PendingApprovalsSearch() { 
        //
        map<String, String> sObjectPrefixes = new map<String, String>();
        for(Schema.SObjectType sObj : Schema.getGlobalDescribe().values())
            sObjectPrefixes.put(sObj.getDescribe().getKeyPrefix(), sObj.getDescribe().getLabel());
        //
        list<ProcessInstance> PISWi = [SELECT  Id, TargetObjectId, Status, 
            (SELECT Id, ActorId, OriginalActorId, StepStatus,  Comments FROM StepsAndWorkitems), // History
            (SELECT Id, ActorId, OriginalActorId, StepStatus,  Comments FROM Steps),
            (SELECT Id, ActorId, OriginalActorId, CreatedDate FROM Workitems)                        
            FROM ProcessInstance WHERE (Status = 'Pending' Or (Status = 'Approved' And LastModifiedDate = THIS_MONTH))
            ORDER BY TargetObjectId];
        // Remove Existing Pending Approval Data
        list<Approval_History__c> listPA = [Select Id From Approval_History__c];
        delete listPA; listPA = new list<Approval_History__c>();
        
        for( ProcessInstance PI : PISWi) {      
            for( ProcessInstanceWorkitem Wi : PI.Workitems) {
                Approval_History__c PA = new Approval_History__c
                (
                    Request_Date__c = Wi.CreatedDate,
                    Object_URL__c = system.URL.getSalesforceBaseUrl().toExternalForm() + '/' + PI.TargetObjectId,
                    Type__c = PI.Status
                );
                // Actual Approver
                if(String.valueOf(Wi.ActorId).left(3) == '005') 
                    PA.Approver__c = Wi.ActorId; 
                else PA.if_Not_User__c = Wi.ActorId; // if pending against a group or queue
                // Assigned Approver
                if(String.valueOf(Wi.OriginalActorId).left(3) == '005') 
                    PA.AssignTo_Approver__c = Wi.ActorId; 
                else PA.if_Not_User__c += ' | ' + Wi.ActorId;
                
                String ObjId = String.valueOf(PI.TargetObjectId);
                
                if(sObjectPrefixes.containsKey(ObjId.left(3))) 
                    PA.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
        
                if(PA.Object_Type__c == 'Opportunity') PA.Opportunity__c = PI.TargetObjectId; //Opportuniy 
                else if(PA.Object_Type__c == 'Agreement') PA.Agreement__c = PI.TargetObjectId; //Agreement 
//                else if(PA.Object_Type__c == 'Rebate') PA.Rebate__c = PI.TargetObjectId; //Rebate 
                else if(String.valueOf(PI.TargetObjectId).left(3) == 'a1A') PA.Rebate__c = PI.TargetObjectId; //Rebate 
                listPA.add(PA);
            }
        } insert listPA;
    }
}