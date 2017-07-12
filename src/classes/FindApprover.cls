/******************************************************************************
@Created By :    Scarlett Kang   
@Created Date:   June 9, 2014
@Description:    Help system admin to find approver and mark   
********************************************************************************/

global with sharing class FindApprover implements Database.Batchable<sObject> {
    public String query = 'SELECT Id, Name, Approver__c, Opportunity_Approver__c, Rebate_Approver__c, Apttus_Approver__c, SAP_CMD_Approver__c  FROM User ' + 
        				  'WHERE IsActive = TRUE AND ' +
        				  '(Profile.Name != \'Customer Portal Manager Standard\' AND ' + 
        				  'Profile.Name != \'NXP Community Profile\' AND ' + 
        				  'Profile.Name != \'Customer Community Login User\' AND ' + 
        				  'Profile.Name != \'Partner Community User\' AND ' + 
        				  'Profile.Name != \'NXP Customer Community Login User\' AND ' + 
        				  'Profile.Name != \'Overage High Volume Customer Portal User\' AND ' + 
        				  'Profile.Name != \'Community Profile\' AND ' + 
        				  'Profile.Name != \'NXP - Overage High Volume Customer Portal User\' AND ' + 
        				  'Profile.Name != \'NXP - Customer Portal Debugging Profile\' AND ' + 
        				  'Profile.Name != \'Gold Partner User\' AND ' + 
        				  'Profile.Name != \'NXP Partner User\' AND ' + 
        				  'Profile.Name != \'Partner Community User\' AND Profile.Name != \'NXP Partner User - EMEA\') ';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, list<sObject> scope) { 
        List<User> users = (list<User>)scope;
        
        //Apporver Matrix used by opportunity
        List<Approvers_Matrix__c> approverM = [
            SELECT Type__c, Approver__c FROM Approvers_Matrix__c
        ];     

        //Apttus Approver Table
        List<Apttus_Approver_Table__c> approverT = [
            SELECT Id, User__c, Role__c FROM Apttus_Approver_Table__c
        ];
        //Rebate Approver Matrix
        List<Rebate_Approver_Matrix__c> approverR = [
            SELECT Id, Approver__c, Role__c FROM Rebate_Approver_Matrix__c
        ];

        Map<Id, Group> groupMap = new Map<Id, Group>([
            SELECT Id, Name
            FROM Group
            WHERE TYPE = 'Queue' AND Name LIKE '%SAP CMD%' 
        ]);
        
        List<GroupMember> groupMembers = [
            SELECT GroupId, Id, UserOrGroupId FROM GroupMember
            WHERE GroupId In : groupMap.KeySet()
        ];
        
        Set<Id> userOrGroupIds = new Set<Id>();
        for(GroupMember member : groupMembers){
            userOrGroupIds.add(member.UserOrGroupId);
        }
        
        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Name
            From User
            WHERE Id In :UserOrGroupIds
        ]);
        
        //Added by Scarlett on Sep 1, 2015
        //CRM CMD user group
        Map<Id, Group> groupCRMCMDMap = new Map<Id, Group>([
            SELECT Id, Name
            FROM Group
            WHERE TYPE = 'Queue' AND Name LIKE '%CRM CMD%' 
        ]);

		 List<GroupMember> groupCRMCMDMembers = [
            SELECT GroupId, Id, UserOrGroupId FROM GroupMember
            WHERE GroupId In : groupCRMCMDMap.KeySet()
        ];
        
        Set<Id> userOrGroupCRMCMDIds = new Set<Id>();
        for(GroupMember member : groupCRMCMDMembers){
            userOrGroupCRMCMDIds.add(member.UserOrGroupId);
        }
        
        Map<Id, User> userCRMCMDMap = new Map<Id, User>([
            SELECT Id, Name
            From User
            WHERE Id In :userOrGroupCRMCMDIds
        ]);
        //End --- Added by Scarlett on Sep 1, 2015
        
        for(Integer i = 0 ; i < users.size() ; i++){
            users[i].Approver__c = false;
            users[i].Opportunity_Approver__c = false;
            users[i].Rebate_Approver__c = false;
            users[i].Apttus_Approver__c = false;
            users[i].SAP_CMD_Approver__c = false;
            users[i].CRM_CMD_Approver__c = false;
        }
       
        for(Integer i = 0 ; i < users.size() ; i++){                   
            //Apporver Matrix
            for(Approvers_Matrix__c m : approverM){
                if(users[i].Id == String.valueOf(m.Approver__c)){
                    users[i].Approver__c = true;
                    users[i].Opportunity_Approver__c = true;
                }
            }

            //Apttus Approver Table
            for(Apttus_Approver_Table__c t : approverT){
                if(users[i].Id == String.valueOf(t.User__c)){
                    users[i].Approver__c = true;
                    users[i].Apttus_Approver__c = true;
                }
            }

            //Rebate Approver Matrix
            for(Rebate_Approver_Matrix__c r : approverR){
                if(users[i].Id == String.valueOf(r.Approver__c)){
                    users[i].Approver__c = true;
                    users[i].Rebate_Approver__c = true;
                }
            }
            
            //SAP CMD Queues    
            if(userMap.containsKey(users[i].Id)){
                users[i].Approver__c = true;
                users[i].SAP_CMD_Approver__c =true;
            }

            /***Modified by Scarlett on Sep 1***/
            /***Retrive CRM CMD Approvers from queues***/
            //CRM CMD Queues
            if(userCRMCMDMap.containsKey(users[i].Id)){
                users[i].Approver__c = true;
                users[i].CRM_CMD_Approver__c =true;
            }
            
        }
        update users;

    }
    global void finish(Database.BatchableContext BC) {
    }
}