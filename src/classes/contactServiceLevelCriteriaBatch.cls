/*
created by: Shridevi Badiger
Created Date:24-May-2017
Description:As part of SIR SFDC-207-To calculate the case priority.
*/

global with sharing class contactServiceLevelCriteriaBatch implements Database.Batchable<sObject>{

global Datetime date1 = System.today().adddays(-7);
global Datetime  date2= (System.today().adddays(1));
//global RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
//global RecordType techRecordType=[Select Id,name from recordtype where name='Tech Support' LIMIT 1];
//global 
//Start
    global Database.QueryLocator start(Database.BatchableContext BC) 
    { 
       return Database.getQueryLocator([SELECT id,Contact_service_Level__c,Criteria_Field_Value__c from Contact_Service_Level_Criteria__c where (CreatedDate>:date1 and createdDate<:date2 ) or (lastModifieddate>:date1 and lastModifieddate<:date2)  ]);
    }
//Execute
    global void execute(Database.BatchableContext BC, list<sObject> ListCSLC) 
    {    
        
         list<contact> listContact=new list<contact>();
         list<string> listEmail=new list<string>();
         list<Contact_Service_Level_Criteria__c> listCSLC1=new list<Contact_Service_Level_Criteria__c>();
         for(Sobject CSLCRec:listCSLC)
            {
                listCSLC1.add((Contact_Service_Level_Criteria__c)CSLCRec);
               // listEmail.add((string)CSLCRec.Criteria_Field_Value__c);
            }
         for(Contact_Service_Level_Criteria__c CSLCRec:listCSLC1)
            {
               
               listEmail.add('%'+((string)CSLCRec.Criteria_Field_Value__c)+'%');
            } 
            System.debug(listEmail);
         if(listEmail!=null && listEmail.size()!=null)
            {
                listContact=[select id,contact_service_level__c,email from contact where email like:listEmail];
                System.debug(listContact);
                if(listContact.size()!=0 && listContact!=null)
                update listContact;
            }
        system.debug(listContact);
    }
    
//Finish
    global void finish(Database.BatchableContext BC)
    {}
}