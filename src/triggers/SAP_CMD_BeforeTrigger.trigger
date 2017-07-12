/******************************************************************************
@Modified By :     Scarlett Kang
@Modified Date :   31 Mar 2015
@Description :     Upsert SAP CMD Request records after update or insert
********************************************************************************/
trigger SAP_CMD_BeforeTrigger on SAP_CMD__c (before insert, before update) 
{
   list<SAP_CMD__c> lstSapCmd=new List<SAP_CMD__c>();
   for(SAP_CMD__c sapcmd:trigger.new)
   {
       if(sapcmd.CMD_Request_Id__c !=null && sapcmd.CMD_Request_Id__c != '')
       {
           lstSapCmd.add(sapcmd);
       }      
   } 
   if(lstSapCmd.size() >0)
    {
        SAP_CMD_Request_Trigger.syncSAP_CMD_Approval_Fields(lstSapCmd);
    }       
}