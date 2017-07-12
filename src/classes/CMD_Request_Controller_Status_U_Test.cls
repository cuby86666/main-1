/********************************************************************************************************************************************************************
@Created By :       Scarlett Kang
@Created Date:      Oct 02 2015
@Description:       Test for new created Apex
*******************************************************************************************************************************************************************/
@isTest
public class CMD_Request_Controller_Status_U_Test {
    private static String TYPE_New_SFDC_Parent_Account = 'New_SFDC_Parent_Account';
    private static String TYPE_SAP_New_Funloc_Request = 'SAP_New_Funloc_Request';
    
    private static RecordType New_SFDC_Parent_Account;
    private static RecordType SAP_New_Funloc_Request;
    
    private static CMD_Request__c theRequest;
    private static Account theAccount;
        
    private static void fetchRecordType(){
        for(RecordType rt : [SELECT Id, DeveloperName
                             FROM   RecordType
                             WHERE  IsActive = TRUE 
                             AND (SobjectType = 'CMD_Request__c' 
                                  AND (DeveloperName =: TYPE_New_SFDC_Parent_Account OR DeveloperName =: TYPE_SAP_New_Funloc_Request)
                                 )
                              ])
        {
            if(rt.DeveloperName == TYPE_New_SFDC_Parent_Account)
                New_SFDC_Parent_Account = rt;
            if(rt.DeveloperName == TYPE_SAP_New_Funloc_Request)
                SAP_New_Funloc_Request = rt;
        }
    }
    
    
    static testmethod void createAccountRequest(){
        theRequest = new CMD_Request__c(
            RecordType = New_SFDC_Parent_Account,
            Request_Status__c = 'Approved'
        );
        
        insert theRequest;
        
        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(theRequest);
        CMD_Request_Controller_Ext_Status_Update theControllerExt 
            = new CMD_Request_Controller_Ext_Status_Update( theStandardController );
        theControllerExt.updateCRMCMDRequestStatus();    
    }
    
    static testmethod void createFunlocRequest(){
        theRequest = new CMD_Request__c(
            RecordType = SAP_New_Funloc_Request,
            Request_Status__c = 'Approved'
        );
        
        insert theRequest;
        
        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(theRequest);
        CMD_Request_Controller_Ext_Status_Update theControllerExt 
            = new CMD_Request_Controller_Ext_Status_Update( theStandardController );
        theControllerExt.updateFunlocRequestStatus();    
    }
}