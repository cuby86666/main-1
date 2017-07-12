public class SAP_CMD_Trigger{
    public void updateCMDRequestStatus(string CMD_Request_Id, String SAP_CMD_Id){
        List<CMD_Request__c> findRequest = [
            SELECT  Id,
                    Request_Status__c
            FROM    CMD_Request__c
            WHERE   Id = :CMD_Request_Id AND Funloc_SAP_CMD__c = :SAP_CMD_Id
        ];
        
        if(findRequest.size() > 0){
            for(integer i = 0 ; i < findRequest.size(); i++)
                findRequest[i].Request_Status__c = 'Completed';
            
            update findRequest;
        }

    }
    
    public static void removeCMDRequestId(string CMD_Request_Id, String SAP_CMD_Id){
        List<SAP_CMD__c> findSAPCMD = [
            SELECT  Id,
                    CMD_Request_Id__c
            FROM    SAP_CMD__c
            WHERE   Id = :SAP_CMD_Id AND CMD_Request_Id__c = :CMD_Request_Id
        ];
        
        if(findSAPCMD.size() > 0){
            for(Integer i  = 0 ; i < findSAPCMD.size() ; i++)
                findSAPCMD[i].CMD_Request_Id__c = NULL;
            
            update findSAPCMD;
        }
    }
}