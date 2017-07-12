/*
Modified by Scarlett on 2014/01/15
Remove Existing Approver History
*/
global with sharing class RemoveExistingApproverHistory implements Database.batchable<sObject>{ 
//global String query;
//Start
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator([SELECT Id FROM Approver_History__c]);
        //return Database.getQueryLocator(query);
    }
//Execute
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        delete Scope;
    }
//Finish
    global void finish(Database.BatchableContext BC){
        Approver_History__c tempRecord = new Approver_History__c (Temp_Record__c = true);
        insert tempRecord;
        
        CollectProcessInstanceWorkItem  insertWorkitem = new CollectProcessInstanceWorkItem();
        Database.executeBatch(insertWorkitem);
    }
}