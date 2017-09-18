/**********************************************************************************************
@Modified By :    Baji    
@Modified Date :  January 27, 2016 
@Description :    To fetch the Email To Addresses who are the recipeints based on the group name selected by CMD officer 
                  when CMD request status is changed to completed (for first time)
************************************************************************************************/
/**********************************************************************************************
@Modified By :    Baji    
@Modified Date :  April 04, 2016 
@Description :    SIR 698:To fetch the Title and Output message from the SAP CMD recods for the correspondind CMD Request based on 
                  the Output list selected by CMD officer when CMD request status is changed to completed (for first time)
-----------------------------------------------------------------------------------------------------------
@Modified By :      Baji
@Modified Date:     24 Jul 2017
@Description:       1708 Release (SFDC 729) - To set default value for few of the fieds on SAP CMD New SBE Funloc Request form.
************************************************************************************************/

trigger CMD_Request_BeforeTrigger on CMD_Request__c (before insert, before update,after update) 
{
    
    if(Trigger.isBefore && Trigger.isInsert){
        CMD_Request_Trigger.setDefaultValueForNewMANUandSBEFunloc( Trigger.New );
    }
    
    
    if( (Trigger.isBefore) && (Trigger.isInsert || Trigger.isUpdate) ) {
        CMD_Request_Trigger.fetchRegion( Trigger.New );
        CMD_Request_Trigger.fetchApprovers( Trigger.New );
        CMD_Request_Trigger.fetchCustomersIDs( Trigger.New );
        CMD_Request_Trigger.fetchSAPCMDids( Trigger.New );
        CMD_Request_Trigger.fetchParentCustomerCategory( Trigger.New );
        CMD_Request_Trigger.fetchCACCs( Trigger.New );
        //CMD_Request_Trigger.fetchCustomerType( Trigger.New );
        CMD_Request_Trigger.fetchCMDOfficer( Trigger.New );
    }
    /********for SIR 698**********/
    If(Trigger.isBefore && Trigger.isUpdate)
    {       
        CMD_Request_Trigger.fetchSapCmdTitle( Trigger.New ,Trigger.oldmap); // SIR 698
    }
   
 
}