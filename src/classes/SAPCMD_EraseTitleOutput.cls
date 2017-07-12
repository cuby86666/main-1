/**********************************************************************************************
@Modified By :    Baji    
@Modified Date :  April 04, 2016  
@Description :    To Erase the Title and Output Message field values from the SAP CMD records for which the Emails sent when the
                  corresponding CMD Request record status is changed to Completed for the First time.
************************************************************************************************/
global class SAPCMD_EraseTitleOutput implements Database.Batchable<SObject>, schedulable {
   
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       
     List<CMD_Request__c> lstCmdCompleted =new List<CMD_Request__c>();
     lstCmdCompleted = [select Id,Title__c,Output__c, Name from CMD_Request__c where Request_Status__c ='Completed' and LastModifiedDate <:Date.today()] ;
        
     If(Test.isRunningTest())
     {
      lstCmdCompleted = [select Id,Title__c,Output__c, Name from CMD_Request__c where Request_Status__c ='Completed' ] ;
     }
       
     List<String> stgCmdText = new List<String> ();
     
     if(lstCmdCompleted!= null && lstCmdCompleted.size()>0 )
     {    
        for(CMD_Request__c cmd:lstCmdCompleted)
        {
            stgCmdText.add(cmd.Id);
        }
     }       
        return Database.getQueryLocator([Select Id, SAP_CMD_Title__c, Output_Message__c, Name from SAP_CMD__c where ( Status__c ='Approved and Distributed' and CMD_Request_ID_Text__c In : stgCmdText ) ]);
    
    }
   
    global void execute(Database.BatchableContext bc, List<SAP_CMD__c> scope) 
    {
        for(SAP_CMD__c sapCmd : scope)
        {
           If(sapCmd.SAP_CMD_Title__c !=null || sapCmd.Output_Message__c !=null)
           {
            sapCmd.SAP_CMD_Title__c= '';

            sapCmd.Output_Message__c= '';
           }
        }

       update scope;
    }
    
    global void finish(Database.BatchableContext bc){    

   }
  
    global void execute(SchedulableContext sc) {
        run();
    }

    public static void run() {
        ID BatchId = Database.executeBatch(new SAPCMD_EraseTitleOutput(), 2000);
    }

  /* Public static void SchedulerMethod() {
    //string con_exp= '0 0 0 ? * SUN *';
    string con_exp= '0 15 17 ? * FRI*';
    System.schedule('SAPCMD_EraseTitleOutput', con_exp, new SAPCMD_EraseTitleOutput());
  }
*/

}