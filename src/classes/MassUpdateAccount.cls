/*
Modified by Scarlett
Invoke Account Trigger ReportUpdate to mass update account fields
*/
global with sharing class MassUpdateAccount implements Database.Batchable<sObject>{
global String query = 'SELECT Id, Name FROM Account';
//Start
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        //return  Database.getQueryLocator([SELECT Id, Name FROM Account]);
        return  Database.getQueryLocator(query);
    }
//Execute
    global void execute(Database.BatchableContext BC, list<sObject> scope) {    
        update scope;
    }
//Finish
    global void finish(Database.BatchableContext BC){
    }    
}