/********************************************************************************************************
Modified by Scarlett on 2014/01/15
Collect all processinstanceWorkitems and insert to Approver_History
---------------------------------------------------------------------------------------------------------
@Last Modified:  Scarlett Kang
@Last Modified:  Jan 15, 2016
@Description:  1601 Hot-fix - SIR 665 Approver History Schedule Job is failed caused by Large SOQL Queries
********************************************************************************************************/
global with sharing class CollectProcessInstanceWorkItem implements Database.batchable<sObject>{
/*
public String query = 'SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, \" + 
            ProcessInstance.TargetObject.Name, \" +
            Actor.Username, Actor.Id, CreatedDate \" +
            FROM ProcessInstanceWorkitem \" +
            WHERE ProcessInstance.CreatedDate >= 2013-01-01T00:00:00Z +'";
            */
/***Modified by Scarlett on Jan 15, 2016***/
//public String query = 'SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, Actor.Username, Actor.Id, CreatedDate FROM ProcessInstanceWorkitem WHERE ProcessInstance.CreatedDate >= 2014-01-01T00:00:00Z';            
public String query = 'SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, Actor.Username, Actor.Id, CreatedDate FROM ProcessInstanceWorkitem WHERE ProcessInstance.CreatedDate >= LAST_N_MONTHS: 12';
/***Modified by Scarlett on Jan 15, 2016 - END***/
    
//Start
global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);    
}
//Execute
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        //Get Object Prefix
        map<String, String> sObjectPrefixes = new map<String, String>();
        for(Schema.SObjectType sObj : Schema.getGlobalDescribe().values())
            sObjectPrefixes.put(sObj.getDescribe().getKeyPrefix(), sObj.getDescribe().getLabel());
        
        List<Group> allCMDGroups = [
            SELECT Id, Name, Type FROM Group
			WHERE Name LIKE '%CMD%'];
        
        map<Id, String> mapCMDgroup = new map<Id, String>();
        for(Group theGroup : allCMDGroups){
            mapCMDgroup.put(theGroup.Id, theGroup.Name);
        }
            
        
        List<GroupMember> allGroupMembers= [
            SELECT GroupId, Id, UserOrGroupId FROM GroupMember
        ];
        
        list<Approver_History__c> listAH = new list<Approver_History__c>();
        
         //Insert Latest ProcessInstanceWorkitems to Approver_History      
         for(ProcessInstanceWorkitem Wi : (list<ProcessInstanceWorkitem>)scope) { 
                Approver_History__c AH = new Approver_History__c
                (
                Target_Object_ID__c = Wi.ProcessInstance.TargetObjectId,
                //Object_URL_2__c = system.URL.getSalesforceBaseUrl().toExternalForm() + '/' + Wi.ProcessInstance.TargetObjectId,
                //Is_Workitem__c = true,
                Approval_Status__c = Wi.ProcessInstance.Status,
                Approver_Action_Date__c = Wi.CreatedDate,
                Approval_Name__c = Wi.ProcessInstance.TargetObject.Name,
                Temp_Record__c = false
                );
               
                if(Wi.ProcessInstance.Status == 'Pending')
                     AH.Status__c = 'Pending';
             
                if(String.valueOf(Wi.Actor.Id).left(3) == '005'){
                    AH.Actual_Approver__c = Wi.Actor.Id;
                    AH.Actor_Username__c = Wi.Actor.Username;
                }
             	//Get Approver Group
                if(String.valueOf(Wi.Actor.Id).left(3) == '00G'){
                    //String groupId = String.valueOf(Wi.Actor.Id);
                    AH.Approver_Group__c = mapCMDgroup.get(String.valueOf(Wi.Actor.Id));
                    AH.Actor_Username__c = Wi.Actor.Username;
                }
                
                String ObjId = String.valueOf(Wi.ProcessInstance.TargetObjectId);
                //If it's a Account
                if(String.valueOf(Wi.ProcessInstance.TargetObjectId).left(3) == '001') {
                    AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                    AH.Account__c = Wi.ProcessInstance.TargetObjectId;
                    AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
                }
                //If it's a Agreement
                if(String.valueOf(Wi.ProcessInstance.TargetObjectId).left(3) == 'a01') {
                    AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                    AH.Agreement__c = Wi.ProcessInstance.TargetObjectId;
                    AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
                }
                //If it's a Opportunity
                if(String.valueOf(Wi.ProcessInstance.TargetObjectId).left(3) == '006') {
                    AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                    AH.Opportunity__c = Wi.ProcessInstance.TargetObjectId;
                    AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
                }
                //If it's Rebate
                if(String.valueOf(Wi.ProcessInstance.TargetObjectId).left(3) == 'a1A'){
                    AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                    AH.Rebate__c = Wi.ProcessInstance.TargetObjectId;
                    AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
                }       
                // CMD Request
                if(String.valueOf(Wi.ProcessInstance.TargetObjectId).left(3) == 'a1S'){
                    AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                    AH.CMD_Request__c = Wi.ProcessInstance.TargetObjectId;
                    AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
                }
             	/*
                // SAP CMD
                if(String.valueOf(Wi.ProcessInstance.TargetObjectId).left(3) == 'a1X'){
                    AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                    AH.SAP_CMD__c = Wi.ProcessInstance.TargetObjectId;
                    AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
                }    
				*/
                
                listAH.add(AH);
             //}//end if
         }//end for 
         insert listAH;
    }
//Finish
    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
           CollectProcessInstanceSteps steps = new CollectProcessInstanceSteps();
           Database.executeBatch(steps, 400);
       }
    }
}