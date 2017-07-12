/*
Modified by Scarlett on 2014.01.15
Calculate Approver Pending Days For Performance Management
Related Object: Account, Agreement, Rebate, Opportunity, CMD Request, SAP CMD
*/
/* Modified by Balaji G on 2016.05.04*/
global with sharing class CalculatePendingDaysBatch implements Database.Batchable<sObject>{
//global long dateLastRecord;
global Datetime timeNow = System.now();
//global Datetime timeNow = Datetime.now();
//global double time_LastRecord;
//global integer count_data = 0;
String query;
global list<Approver_History__c> tempRecord = [SELECT Id, Approver_Action_Date__c  FROM Approver_History__c WHERE Temp_Record__c = true order by CREATEDDATE desc LIMIT 1];


//Start
    global Database.QueryLocator start(Database.BatchableContext BC) { 
    //only extract approval process of opportunity, account, agreement, rebate 
        return Database.getQueryLocator([SELECT Actor_Username__c, Actual_Approver__c, Status__c, 
            Approval_Status__c, Pending_Days__c, Target_Object_ID__c, Approver_Action_Date__c
            FROM Approver_History__c 
            WHERE (Target_Object_ID__c LIKE '006%' OR Target_Object_ID__c LIKE '001%' 
            OR Target_Object_ID__c LIKE 'a01%' OR Target_Object_ID__c LIKE 'a1A%' OR Target_Object_ID__c LIKE 'a1X%'
            OR Target_Object_ID__c LIKE 'a1S%') 
            AND Temp_Record__c = false
            ORDER BY Target_Object_ID__c, Approver_Action_Date__c ASC]);
        
        //return Database.getQueryLocator(query);
    }
//Execute
    global void execute(Database.BatchableContext BC, list<sObject> scope) {    
        list<Approver_History__c> AH = (list<Approver_History__c>)scope;
        decimal pendingDaysUnRound;
        double startDate, endDate;
        //Calculate pending days for first row data
        if(tempRecord.size() > 0){
            if(AH[0].Status__c != 'Started' && tempRecord[0].Approver_Action_Date__c != null)
            {// is not work item and one approval process has been cut into two pieces
                startDate = tempRecord[0].Approver_Action_Date__c.getTime();
                //System.debug('Started date: ' + startDate);
                endDate = AH[0].Approver_Action_Date__c.getTime();
                try{
                    pendingDaysUnRound = ((endDate - startDate)  / 1000 / 60 / 60 / 24);// Unit: day
                    AH[0].Pending_Days__c = pendingDaysUnRound.setscale(2, roundingMode.UP);
                }catch(System.CalloutException e){
                    System.debug('Pending days calculation ERROR:' + e);
                }
            }
        
              
            for(Integer i = 1 ; i < AH.size() ; i++){  
            System.debug('Object ID: ' + AH[i].Target_Object_ID__c);
            /*
            if(AH[i].Status__c != 'Started'){// Approver status != Started
                if(AH[i].Target_Object_ID__c.equals(AH[(i-1)].Target_Object_ID__c) == true){// not workitem
                    startDate = AH[(i-1)].Approver_Action_Date__c.getTime();
                    endDate = AH[i].Approver_Action_Date__c.getTime();
                }
                else{
                    //if(AH[i].Is_Workitem__c == true && AH[i].Approval_Status__c == 'Pending'){// is workitem
                    if(AH[i].Approval_Status__c == 'Pending'){// is workitem
                        startDate = AH[(i-1)].Approver_Action_Date__c.getTime();
                        endDate = timeNow.getTime();
                    }
                }
                try{
                    pendingDaysUnRound = ((endDate - startDate)  / 1000 / 60 / 60 / 24);// Unit: day
                }catch(System.CalloutException e){
                    System.debug('Pending days calculation ERROR:' + e);
                }
                AH[i].Pending_Days__c = pendingDaysUnRound.setscale(2, roundingMode.UP);
            }
            */
            if(AH[i].Status__c != 'Started'){// actual approver ; not submiter
                // Type 1: Approver's status is Approver, Rejected, Reassigned, Removed(Recalled)
                if(AH[i].Target_Object_ID__c.equals(AH[(i-1)].Target_Object_ID__c) == true){// in the same approval process
                    startDate = AH[(i-1)].Approver_Action_Date__c.getTime();
                    endDate = AH[i].Approver_Action_Date__c.getTime();
                }
                // Type 2: Approver's status is Pending
                if(AH[i].Approval_Status__c == 'Pending' && AH[i].Status__c == 'Pending'){// is work item ; approver is pending
                    startDate = AH[i].Approver_Action_Date__c.getTime();
                    endDate = timeNow.getTime();
                }
                // Type 3: Approver's status is No response
                if(AH[i].Approval_Status__c == 'NoResponse' && AH[i].Status__c == null){
                    startDate = 0.0;
                    endDate = 0.0;
                }
                // Calculate Pending Days
                try{
                    pendingDaysUnRound = ((endDate - startDate)  / 1000 / 60 / 60 / 24);// Unit: day
                }catch(System.CalloutException e){
                    System.debug('Pending days calculation ERROR:' + e);
                } 
                AH[i].Pending_Days__c = pendingDaysUnRound.setscale(2, roundingMode.UP);
            }// end if 
            
            /*
            if(AH[i].Status__c != 'Started'){
                System.debug('**********************************************');
                System.debug('Object ID: ' + AH[i].Target_Object_ID__c);
                System.debug('Start date: ' + startDate);
                System.debug('End date: ' + startDate);
                System.debug('Pending Days: ' + AH[i].Pending_Days__c);
            } 
            */
            //count_data++;
            
        }// end loop
        
        //if(count_data == AH.size()){
            //Approver_History__c temp = new Approver_History__c();
            System.debug('AH size: ' + AH.size());
            tempRecord[0].Approver_Action_Date__c = AH[(AH.size()-1)].Approver_Action_Date__c;
        // }
        update tempRecord;
        update AH;
        }
        else
            System.debug('No Temp Record found ERROR:');
    }
    
//Finish
    global void finish(Database.BatchableContext BC){
    /*
        AsyncApexJob a = [SELECT Id, CreatedBy.Email, Status
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('[Notification] Approver Pending Days Calculation ' + a.Status);
        mail.setPlainTextBody('Calculation completed! You can run the approver performance report now.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    */
    }
}