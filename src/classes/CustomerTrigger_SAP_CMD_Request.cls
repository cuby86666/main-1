public with sharing class CustomerTrigger_SAP_CMD_Request {

    private static List<CMD_Request__c> allSAPCMDRequests; 
    private static List<CMD_Request__c> theRequestsToBeUpdated = new List<CMD_Request__c>(); 
    
    public static void syncGidBackToRequests( List<Customer__c> listCustomers ) {
        allSAPCMDRequests = [
            SELECT  Id,
                    SP_GID__c,
                    SH_GID__c,
                    PY_GID__c,
                    BP_GID__c,
                    ZI_GID__c
            FROM    CMD_Request__c
            WHERE   RecordType.Name LIKE '%SAP%'
        ];
        for( Customer__c theCustomer : listCustomers ) {
            for( CMD_Request__c theRequest : allSAPCMDRequests ) {
                if( theCustomer.CMD_Request_Id__c == theRequest.Id ) {
                    if( theCustomer.CMD_Request_Partner_Function__c == 'SP' ){
                        theRequest.SP_GID__c = theCustomer.Name;
                    }
                    /*if( theCustomer.CMD_Request_Partner_Function__c == 'SH' ){
                        theRequest.SH_GID__c = theCustomer.Name;
                    }
                    if( theCustomer.CMD_Request_Partner_Function__c == 'PY' ){
                        theRequest.PY_GID__c = theCustomer.Name;
                    }
                    if( theCustomer.CMD_Request_Partner_Function__c == 'BP' ){
                        theRequest.BP_GID__c = theCustomer.Name;
                    }
                    if( theCustomer.CMD_Request_Partner_Function__c == 'ZI' ){
                        theRequest.ZI_GID__c = theCustomer.Name;
                    } */
                    theRequestsToBeUpdated.add( theRequest );
                }
            }
        }
        update theRequestsToBeUpdated;
    }
}