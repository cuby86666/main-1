@isTest
private class SAP_CMD_Request_Trigger_Test {
    
    private static RecordType SAPrt;
    private static string SAPrtId = '012D0000000QlBaIAK';
    private static RecordType Z001rt;
    private static string Z001rtId;
    private static Funloc__c objFunloc;
    private static List<Customer__c> lstCustomer;
    private static Customer__c objCustomer;
    
    Private Static list<CMD_Request__c> lstCmdRequest;
    Private Static list<SAP_CMD__c> lstSapCmd;
    Private Static list<SAP_CMD_Request__c> lstSapCmdRequest;
    private static CMD_Request__c testRequest;
    private static SAP_CMD__c testSAPCMD;
    private static SAP_CMD_Request__c testSAPCMDRequest;

    @isTest(SeeAllData=true)     
    private static void fetchRecordTypes()
    {
        for(RecordType rt : 
            [   
                Select Id, DeveloperName
                From RecordType
                WHERE SobjectType = 'CMD_Request__c' 
                AND DeveloperName LIKE '%SAP%' 
                AND IsActive=true
                Limit 1
            ]
        )
        {
            SAPrt = rt;
            SAPrtId = String.valueOf(rt.Id);            
        }    
        for(RecordType rt : 
            [   
                Select Id, DeveloperName
                From RecordType
                WHERE SobjectType = 'SAP_CMD__c' 
                AND IsActive=true
            ]
        )
        {
            if( rt.DeveloperName == 'Z001_SoldTo_ShipTo_BillTo_Payer' ){
                Z001rt = rt;
                Z001rtId = String.valueOf(rt.Id);
            }               
        }    
    }
    
    private static void createFunloc(){
        objFunloc = new Funloc__c(
            Name__c = 'Test Convert',
            Call_Name__c = 'Test Convert',
            Street_Name__c = 'Test Convert',
            Place_Name__c = 'Test Convert',
            Country_Name__c = 'Test Convert'
        );

        insert objFunloc;
    }
    
    

    static  void thePositiveTest(){
        lstCmdRequest=new list<CMD_Request__c>();
        lstSapCmd=new list<SAP_CMD__c>();
      	lstSapCmdRequest= new list<SAP_CMD_Request__c>();
        
        fetchRecordTypes();
	            
        testRequest = new CMD_Request__c(
            RecordTypeId = SAPrtId,
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',            
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group'
        );
        
        lstCmdRequest.add(testRequest);
        insert lstCmdRequest;
        
        testSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001rtId,
            CMD_Request_ID__c = lstCmdRequest[0].Id,
            FunLoc__c = objFunloc.Id,
            HUB_Customer__c = lstCustomer[0].Id,
            Legal_Name__c = 'Test Legal Name'
        );
        lstSapCmd.add(testSAPCMD);
        insert lstSapCmd;
        
        SAP_CMD_Request_Trigger.upsertSAP_CMD_Request( lstSapCmd );
        
        LIST<SAP_CMD_Request__c> listSAPCMDRequests = [SELECT Id ,
                                                     		Approval_Status__c ,
                                                     		Pending_Approver__c ,
                                                      		Pending_Approval_Since__c
                                                      	FROM  SAP_CMD_Request__c
                                                      	WHERE CMD_Request__c = :lstCmdRequest[0].Id
                                                      	AND	SAP_CMD__c = :lstSapCmd[0].Id
                                                     ];
       
        if( listSAPCMDRequests.size() > 0 )
            testSAPCMDRequest = listSAPCMDRequests[0];

        System.assert( testSAPCMDRequest.id != null );

        for(SAP_CMD__c sap:lstSapCmd)
        {
            sap.Status__c = 'Draft';
            sap.Pending_Approver__c = 'Export Control';
        }        
        update lstSapCmd;
        
        SAP_CMD_Request_Trigger.syncSAP_CMD_Approval_Fields(lstSapCmd);
		        
        System.assertEquals( testSAPCMD.Status__c , testSAPCMDRequest.Approval_Status__c );
//        System.assertEquals( testSAPCMD.Pending_Approver__c , testSAPCMDRequest.Pending_Approver__c );
        System.assertEquals( testSAPCMD.Pending_Approval_Since__c , testSAPCMDRequest.Pending_Approval_Since__c );
    }  
}