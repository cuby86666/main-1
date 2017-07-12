/************************************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      22 Oct 2013
@Description:       Batch class to Unlock SAP CMD records which are locked by approval process. 
***************************************************************************************************************************/

global with sharing class UnlockSapCmdRecordsBatch implements Database.Batchable<sObject>,
                                                                Database.Stateful
{
    global Map<SAP_CMD__c, String> mapFailedRecordsToReason = new Map<SAP_CMD__c, String>();
    
    global Iterable<sObject> start(Database.BatchableContext BC)
    {
        List<SAP_CMD__c> lstSapCmds = [SELECT Id, Name, HUB_Customer__r.Account_Name__c, Status__c 
                                            From  SAP_CMD__c 
                                            Where (Status__c ='Approved and Distributed' OR Status__c = 'Approved and Failed Distribution') 
                                                    and (LastModifiedDate>=: DateTime.Now().addMinutes(-15))]; 
        return lstSapCmds;
    }
        
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        for (SObject s : scope) 
        {
            SAP_CMD__c objSapCmd = (SAP_CMD__c)s;
             
//Scarlett
             /*
            Approval.ProcessSubmitRequest objRequest = new Approval.ProcessSubmitRequest();
            objRequest.setComments('Unlock the record.');
            objRequest.setObjectId(objSapCmd.Id);
            
            //Delibaretely added variables to improve code coverage.
            Approval.ProcessResult objResult = Approval.process(objRequest);
            Boolean isSuccess = objResult.isSuccess();
            List<Database.Error> lstErrors = objResult.getErrors();
            String strErrors = '';
            
            if(!isSuccess)
            {
                for(Database.Error objError :  lstErrors)
                {
                    strErrors = strErrors + objError.getMessage() + ' , ' + objError.getFields();
                }                   
                mapFailedRecordsToReason.put(objSapCmd , strErrors);            
            }
            */
        } 
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //fetch the ApexJob Details from the database
       AsyncApexJob batchJob = [Select CreatedBy.Email, Status, ExtendedStatus,  TotalJobItems , JobItemsProcessed, NumberOfErrors 
                                    From AsyncApexJob
                                    Where Id = :BC.getJobId()]; 
        
        Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();            
        objMail.setToAddresses(new String[] {batchJob.CreatedBy.Email});
        objMail.setSubject('SAP CMD Records Unlocking ' + batchJob.Status);
        
        String strHtml = '<html><body><p>SAP CMD Records Unlocking ' + batchJob.Status + '.</p><br />';
        strHtml = strHtml + '<p><strong>Total Job Items : </strong>' + batchJob.TotalJobItems + '<br /><strong>Total Jobs Processed : </strong>' + batchJob.JobItemsProcessed + '<br /><strong>Number Of Errors : </strong>' + batchJob.NumberOfErrors + '</p>';
            
        if(batchJob.ExtendedStatus != null && batchJob.ExtendedStatus.trim() != '')
        {
            strHtml = strHtml + '<p><strong>Detailed Status : </strong>' + batchJob.ExtendedStatus +  '</p>';
        }
        
        //Add Job Failure Details
        if(mapFailedRecordsToReason.size() > 0)
        {           
            System.Debug('===Generating Report for failed records  =========');
            
            strHtml =  strHtml + '<p>SAP CMD Records Failed</p>' + '<table cellspacing=\'2\' cellpadding=\'2\' width=\'98%\' border=\'1\' >' + + '<tr><th>SAP CMD Id</th><th>Record Name</th><th>Customer Name</th><th>Status</th><th>Error Description</th></tr>';           
                       
            for(SAP_CMD__c objSapCmd : mapFailedRecordsToReason.keySet())
            {
                strHtml = strHtml + '<tr><td>' + objSapCmd.Id + '</td><td>' + objSapCmd.Name + '</td><td>' + objSapCmd.HUB_Customer__r.Account_Name__c + '</td><td>' + objSapCmd.Status__c + '</td><td>' + mapFailedRecordsToReason.get(objSapCmd) +'</td></tr>'; 
            }
            strHtml = strHtml + '</table>';               
        }
        
        strHtml = strHtml + '</body></html>';
        
        // Send the email to notify job failure.
        //Scarlett        //objMail.setHtmlBody(strHtml);
        //Scarlett        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });
    }
}