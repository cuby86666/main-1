/********************************************************************************************************************************************************************
@Created By :       Scarlett Kang
@Created Date:      05 Oct 2015
@Description:       1510 Release - SIR 356. CMD Request - Create a button to changed status to Complete for CMD officer
*******************************************************************************************************************************************************************/
public without sharing class CMD_Request_Controller_Ext_Status_Update {
    private CMD_Request__c theRequest;
    
    public CMD_Request_Controller_Ext_Status_Update(ApexPages.StandardController stdController ){
        this.theRequest = (CMD_Request__c)stdController.getRecord();
        theRequest = [
            SELECT  Id, 
            Request_Status__c 
            FROM    CMD_Request__c 
            WHERE   Id = :theRequest.Id AND 
            (RecordType.Name = 'SAP New Funloc Request' 
             OR RecordType.Name = 'SAP Funloc Edit Request' 
             OR RecordType.Name = 'SAP Mass Update Request'
             OR RecordType.Name = 'New SFDC Parent Account' 
             OR RecordType.Name = 'New SFDC Child Account' 
             OR RecordType.Name = 'Edit SFDC Parent Account' 
             OR RecordType.Name = 'Edit SFDC Child Account'
             OR RecordType.Name = 'SAP New MANU Funloc request' 
             OR RecordType.Name = 'SAP MANU Funloc Edit request' 
             OR RecordType.Name = 'SAP New SBE Funloc request' 
             OR RecordType.Name = 'SAP SBE Funloc Edit request'
            )
        ];
        
    }

    public pageReference updateFunlocRequestStatus(){
        theRequest.Request_Status__c = 'Completed';
        
        update theRequest;
        
        system.debug('********Request Status: ' + theRequest.Request_Status__c);
        
        PageReference requestUpdate_page = new PageReference('/' + theRequest.Id);
        requestUpdate_page.setRedirect(true);
        return requestUpdate_page;
    }
    
    public pageReference updateCRMCMDRequestStatus(){
        theRequest.Request_Status__c = 'Completed';
        
        update theRequest;
        
        system.debug('********Request Status: ' + theRequest.Request_Status__c);
        
        PageReference requestUpdate_page = new PageReference('/' + theRequest.Id);
        requestUpdate_page.setRedirect(true);
        return requestUpdate_page;
    }
}