/********************************************************************************************
@Created By :    Scarlett Kang
@Created Date:   19 Apr 2015
@Description:    Batch update Opportunity, called by Approver_Matrix_Extension_Controller
********************************************************************************************/
/**********************
@ Updated By: Scarlett Kang
@ Update Date: 1506 Release
@ Description: Changed to Batch 
******************************************
@ Updated By: Jewelslyn
@ Update Date: 1605 Release
@ Description: added new approver fields and removed old approver fields as part DW approval revision
*******************************************
@ Updated By: Balaji G
@ Update Date: 1610 Release
@ Description: SIR1174 Commented usage of fields Level2_PM11__c and Level2_PM12__c to delete them
*******************************************/

global with sharing class UpdateOpportunityBatch implements Database.Batchable<sObject>{
 
global String ApproverId;

//Start
    global Database.QueryLocator start(Database.BatchableContext BC) { 
         
        //return Database.getQueryLocator(query);
        
        return Database.getQueryLocator(
            [SELECT Id 
             FROM   Opportunity 
             WHERE
                    (Level1_RVP__c =: ApproverId 
                    OR Level1_Reg_Controller__c =: ApproverId
                    OR Level2_PM1__c =: ApproverId
                    OR Level2_PM2__c =: ApproverId
                    OR Level2_PM3__c =: ApproverId
                    OR Level2_PM4__c =: ApproverId
                    OR Level2_PM5__c =: ApproverId
                    OR Level2_PM6__c =: ApproverId
                    OR Level2_PM7__c =: ApproverId
                    OR Level2_PM8__c =: ApproverId
                    OR Level2_PM9__c =: ApproverId
                    OR Level2_PM10__c =: ApproverId
//                    OR Level2_PM11__c =: ApproverId
//                    OR Level2_PM12__c =: ApproverId
                    OR BL_Approver_1__c=:ApproverId
                    OR BL_Approver_2__c=:ApproverId
                    OR BL_Approver_3__c=:ApproverId
                    OR BL_Approver_4__c=:ApproverId
                    OR BL_Approver_5__c=:ApproverId
                    OR MAG_Approver_1__c=:ApproverId
                    OR MAG_Approver_2__c=:ApproverId
                    OR MAG_Approver_3__c=:ApproverId
                    OR MAG_Approver_4__c=:ApproverId
                    OR MAG_Approver_5__c=:ApproverId
                    OR MAG_Approver_6__c=:ApproverId
                    OR MAG_Approver_7__c=:ApproverId
                    OR MAG_Approver_8__c=:ApproverId
                    OR MAG_Approver_9__c=:ApproverId
                    OR MAG_Approver_10__c=:ApproverId 
                    OR Sales_Director_Approver__c=:ApproverId 
                    OR Regional_VP_Approver__c=:ApproverId 
                   )
                    AND (Design_Win_Approval_Process__c = 'Open' 
                    OR Design_Win_Approval_Process__c = 'Pending')
                    AND RecordTypeId = '012D0000000Qp1V'
                    AND StageName = 'Decision']
        );
    }
    
//Execute
    global void execute(Database.BatchableContext BC, list<sObject> scope) {    
        list<Opportunity> affectedOppty = (list<Opportunity>)scope;
        
        if(affectedOppty.size() > 0)
            update affectedOppty;
    }

//Finish
    global void finish(Database.BatchableContext BC){
    }
    
}