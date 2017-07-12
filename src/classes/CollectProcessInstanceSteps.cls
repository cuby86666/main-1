/********************************************************************************************************
Modified by Scarlett on 2014/01/15
Collect all processinstanceStpes and insert to Approver_History 
For Calculate Approver Pending Days
---------------------------------------------------------------------------------------------------------
@Last Modified:  Scarlett Kang
@Last Modified:  Jan 15, 2016
@Description:  1601 Hot-fix - SIR 665 Approver History Schedule Job is failed caused by Large SOQL Queries
********************************************************************************************************/
global with sharing class CollectProcessInstanceSteps implements Database.batchable<sObject>{ 
/***Modified by Scarlett on Jan 15, 2016***/
//global String query = 'SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, Actor.Username, Actor.Id, CreatedDate, StepStatus, Comments FROM ProcessInstanceStep WHERE ProcessInstance.CreatedDate >= 2014-01-01T00:00:00Z';
global String query = 'SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, Actor.Username, Actor.Id, CreatedDate, StepStatus, Comments FROM ProcessInstanceStep WHERE ProcessInstance.CreatedDate >= LAST_N_MONTHS: 12';
/***Modified by Scarlett on Jan 15, 2016 - END***/
//Start
global Database.QueryLocator start(Database.BatchableContext BC) { 
    /*
        return Database.getQueryLocator([SELECT ProcessInstance.Status, ProcessInstance.TargetObjectId, 
            ProcessInstance.TargetObject.Name,
            Actor.Username, Actor.Id, CreatedDate, StepStatus, Comments 
            FROM ProcessInstanceStep 
            WHERE ProcessInstance.CreatedDate >= 2013-01-01T00:00:00Z]);
            */
        return Database.getQueryLocator(query);    
    }
//Finish
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        //Get Object Prefix
        map<String, String> sObjectPrefixes = new map<String, String>();
        for(Schema.SObjectType sObj : Schema.getGlobalDescribe().values())
            sObjectPrefixes.put(sObj.getDescribe().getKeyPrefix(), sObj.getDescribe().getLabel());
             
        //list<Approver_History__c> listAH = [Select Id From Approver_History__c];
        //delete listAH; 
        list<Approver_History__c> listAH = new list<Approver_History__c>();
        
        //Group
        List<Group> allCMDGroups = [
            SELECT Id, Name, Type FROM Group
			WHERE Name LIKE '%CMD%'];       
        map<Id, String> mapCMDgroup = new map<Id, String>();
        for(Group theGroup : allCMDGroups){
            mapCMDgroup.put(theGroup.Id, theGroup.Name);
        }
        
        //Group Member
        List<GroupMember> allGroupMembers= [
            SELECT GroupId, Id, UserOrGroupId FROM GroupMember
        ];     
        map<Id, Id> mapGroupMember = new map<Id, Id>();
        for(GroupMember thegmember : allGroupMembers){
            mapGroupMember.put(thegmember.UserOrGroupId, thegmember.GroupId);
        }
   
        for(ProcessInstanceStep PISi : (list<ProcessInstanceStep>)scope){
            Approver_History__c AH = new Approver_History__c
            (
            Target_Object_ID__c = PISi.ProcessInstance.TargetObjectId,
            //Object_URL_2__c = system.URL.getSalesforceBaseUrl().toExternalForm() + '/' + PISi.ProcessInstance.TargetObjectId,
            //Is_Workitem__c = false,
            Approval_Status__c = PISi.ProcessInstance.Status,
            //Actor_Username__c = PISi.Actor.Username,
            //Actual_Approver__c = PISi.Actor.Id,
            Approver_Action_Date__c = PISi.CreatedDate,
            Comments__c = PISi.Comments,
            Approval_Name__c = PISi.ProcessInstance.TargetObject.Name,
            Status__c = PISi.StepStatus,
            Temp_Record__c = false
            );
            
            if(String.valueOf(PISi.Actor.Id).left(3) == '005'){
                AH.Actual_Approver__c = PISi.Actor.Id;
                AH.Actor_Username__c = PISi.Actor.Username;
                AH.Approver_Group__c = mapCMDgroup.get(String.valueOf( mapGroupMember.get(String.valueOf(PISi.Actor.Id)) ));
            }
                
            String ObjId = String.valueOf(PISi.ProcessInstance.TargetObjectId);
            //If Account
            if(String.valueOf(PISi.ProcessInstance.TargetObjectId).left(3) == '001') {
                AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                AH.Account__c = PISi.ProcessInstance.TargetObjectId;
                AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
            }
            //If Agreement
            if(String.valueOf(PISi.ProcessInstance.TargetObjectId).left(3) == 'a01') {
                AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                AH.Agreement__c = PISi.ProcessInstance.TargetObjectId;
                AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
            }
            //If Opportunity
            if(String.valueOf(PISi.ProcessInstance.TargetObjectId).left(3) == '006') {
                AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                AH.Opportunity__c = PISi.ProcessInstance.TargetObjectId;
                AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
            }
            //If Rebate
            if(String.valueOf(PISi.ProcessInstance.TargetObjectId).left(3) == 'a1A'){
                AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                AH.Rebate__c = PISi.ProcessInstance.TargetObjectId;
                AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
            }
            // CMD Request
            if(String.valueOf(PISi.ProcessInstance.TargetObjectId).left(3) == 'a1S'){
                AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                AH.CMD_Request__c = PISi.ProcessInstance.TargetObjectId;
                AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
            }    
            /*
            // SAP CMD
  			if(String.valueOf(PISi.ProcessInstance.TargetObjectId).left(3) == 'a1X'){
                AH.Object_Type__c = sObjectPrefixes.get(ObjId.left(3));
                AH.SAP_CMD__c = PISi.ProcessInstance.TargetObjectId;
                AH.Approval_Type__c = sObjectPrefixes.get(ObjId.left(3));
            }
			*/
            listAH.add(AH);
        }
        insert listAH;
    }
//Execute
    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
            CalculatePendingDaysBatch cls = new CalculatePendingDaysBatch();
            Database.executeBatch(cls, 400);
        }
    }

}