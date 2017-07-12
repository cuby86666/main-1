/****************************************************************************************************
Last modifiedby   :Shridevi Badiger
Last Modified date:23-Nov-2016
Description       : SIR 1371-Not able to save funlocs in CMDRequests.

****************************************************************************************************/

@isTest
private class SAPCMDMassUpdateControllerTest
{
    //TO Do:Update Stan for the line commented
    //private static final String CMD_REQUEST_SAP_MASS_UPDATE_RECORD_TYPE_ID = '012D0000000QmBTIA0';
    //private static final String CMD_REQUEST_SAP_MASS_UPDATE_RECORD_TYPE_ID = '012M00000004gGJIAY';     
    private static final String SAP_MASS_UPDATE_REQUEST = 'SAP_Mass_Update_Request';
    private static RecordType sapMassUpdateRequest;
    private static RecordType Z001rt;
    private static string Z001rtId;
    private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
    private static final String TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER = 'Z001_SoldTo_ShipTo_BillTo_Payer';
    private static RecordType globalCustomer;
    public static  Customer__c testCustomer;
    public static  Funloc__c testFunloc;
    public static  List<Funloc__c> listFunlocs=new List<Funloc__c>();
    public static  SAP_CMD__c testSAPCMD;
    public static Consolidated_Account_Code__c testCACC;
    public static list<CMD_Request_SAP_Mass_Update_Detail__c>  listtestMassUpdate;
    private static void fetchRecordTypes()
    {
        //get CMD Request record type
        RecordType rt=[Select Id, DeveloperName
                       From RecordType Where IsActive=true and
                       (SobjectType = 'CMD_Request__c' and 
                        DeveloperName =: SAP_MASS_UPDATE_REQUEST
                       )
                       limit 1];
        
        if(rt.DeveloperName == SAP_MASS_UPDATE_REQUEST)
        {
            sapMassUpdateRequest = rt;
        }  
    }
    
    static testmethod void thePositiveTest() 
    {
        fetchRecordTypes();
        createData();
        
        list<SAP_CMD__c> listSAPCMD=new list<SAP_CMD__c>();
        for(funloc__c funloc:listFunlocs)
        {
        listSAPCMD.add(createSAPCMD(funloc.id));
        system.debug('Funloc::'+funloc);
        }
        insert listSAPCMD;
        
        //createSAPCMD();
        listtestMassUpdate=new list<CMD_Request_SAP_Mass_Update_Detail__c>();//=new CMD_Request_SAP_Mass_Update_Detail__c(CMD_Request__c.ID=testRequest.id,ZA_New__c='HU225 - LASZLO BARANYAI');
        system.debug('Entered method');
       
        CMD_Request__c testRequest = new CMD_Request__c( RecordTypeId = sapMassUpdateRequest.id,Mass_Update_Type__c='ZA');
        insert testRequest;
        //testMassUpdate=
        listtestMassUpdate.add(new CMD_Request_SAP_Mass_Update_Detail__c(Funloc__c=String.valueOf(listFunlocs[0].FunLoc_Number__c),CMD_Request__c=testRequest.id,ZA_New__c='HU225 - LASZLO BARANYAI'));
        //listtestMassUpdate.add(new CMD_Request_SAP_Mass_Update_Detail__c(Funloc__c='100001',CMD_Request__c=testRequest.id,ZA_New__c='HU225 - LASZLO BARANYAI'));
        listtestMassUpdate.add(new CMD_Request_SAP_Mass_Update_Detail__c(Funloc__c=String.valueOf(listFunlocs[1].FunLoc_Number__c),CMD_Request__c=testRequest.id,ZA_New__c='HU225 - LASZLO BARANYAI'));
        
        insert listtestMassUpdate;
        ApexPages.StandardController stdController = new ApexPages.StandardController(testRequest);
        SAPCMDMassUpdateController theController = new SAPCMDMassUpdateController(stdController);
        system.debug('theController ::'+theController);
        system.assert(theController != null);
        theController.addRow();
        theController.add5Rows();
        theController.rowToBeReplicated = '1';
        theController.columnToBeReplicated = 'ZA';
        theController.replicateColumn();
        theController.columnToBeReplicated = 'Address';
        theController.replicateColumn();
        theController.rowToBeRemoved = '1';
        theController.removeRow();
        theController.getZSOptions();
        theController.getZAOptions();
        //theController.getPDKeyOptions();
        theController.getCountryOptions();
        theController.listFunlocWrapper[0].funloc =String.valueOf(listFunlocs[0].FunLoc_Number__c);// '100000';
        theController.listFunlocWrapper[1].funloc = String.valueOf(listFunlocs[1].FunLoc_Number__c);
        // theController.listFunlocWrapper[2].funloc=String.valueOf(listFunlocs[2].FunLoc_Number__c);
        theController.save();
        theController.listFunlocWrapper[0].funloc = String.valueOf(listFunlocs[0].FunLoc_Number__c);
        theController.listFunlocWrapper[1].funloc = String.valueOf(listFunlocs[1].FunLoc_Number__c);
        theController.listFunlocWrapper[2].funloc=String.valueOf(listFunlocs[2].FunLoc_Number__c);
        theController.save();
        listtestMassUpdate=new list<CMD_Request_SAP_Mass_Update_Detail__c>([select id,Funloc__c from CMD_Request_SAP_Mass_Update_Detail__c where CMD_Request__c=:testRequest.id]);
        system.assert(listtestMassUpdate.size()!=0);
        system.debug('listtestMassUpdate.size:'+listtestMassUpdate.size());
        system.debug('theController.listFunlocWrapper:'+theController.listFunlocWrapper);
    }
    
   
    public static void createData()
    {
            for(Recordtype rt : [SELECT Id, DeveloperName
                              FROM RecordType
                              WHERE IsActive = true AND  
                              (
                              (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                               OR (SobjectType = 'Customer__c' AND DeveloperName =: TYPE_GLOBALENTERPRISE)
                              )
                              ])
            {
            if(rt.DeveloperName == TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
              {
                Z001rt = rt;
                Z001rtId = String.valueOf(rt.Id);
              }
            if(rt.DeveloperName == TYPE_GLOBALENTERPRISE)
                globalCustomer = rt;
                     
            }//END for
           testCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' ,
                                          Legal_Name__c = 'ut_Global_Enterprise ' , DUNS__c = 'ut_123' , 
                                          Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                          House_Number__c = 'ut' , Street__c = 'ut_street_1' ,
                                          Zip__c = 'ut_zip'  , City__c = 'ut_city', Country__c = 'USA' ,  
                                          Industry_Segment__c = 'CC - Computing' ,
                                          Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                          Fulfillment_Channel__c = 'Disti',  Street_2__c = 'ut_street_2'  ,
                                          Street_3__c = 'ut_street_3'  ,State__c = 'test' ,Industry_Sub_Segment__c = 'F1 - Desktop',
                                          SIC_Code__c = 't', NAICS_Code__c = 'ut_', 
                                          Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                          Fax__c = '+1234567890', Telephone__c = '+1234567890');
        
        insert testCustomer;
       // funloc__c testFunloc1=new funloc__c(Name__c='test',  Call_Name__c='test',Street_Name__c='test',Place_Name__c='test',Country_Name__c='test');
        //insert testFunloc;
        listFunlocs.add(new funloc__c(Name__c='test1',  Call_Name__c='test',Street_Name__c='test',Place_Name__c='test',Country_Name__c='test'));
        listFunlocs.add(new funloc__c(Name__c='test2',  Call_Name__c='test',Street_Name__c='test',Place_Name__c='test',Country_Name__c='test'));
        listFunlocs.add(new funloc__c(Name__c='test3',  Call_Name__c='test',Street_Name__c='test',Place_Name__c='test',Country_Name__c='test'));
        insert listFunlocs;
        listFunlocs=[select id,funloc_number__c from funloc__c where id in :listFunlocs];
        //testFunloc=[select id,funloc_number__c from funloc__c where id=:testFunloc.id];
        testCACC = new Consolidated_Account_Code__c(
            Name ='ZZZ', Code_Description__c = 'Test Code' , 
            End_Customer_GID__c = testCustomer.Id, 
            Customer_Category__c = 'Focus', 
            PD_Key_Account__c = 'Test', 
            Base_Region__c = 'AM-Americas'
        );
        insert testCACC;
       
            
    //SAPCMD__c testSAPCMD=new SAPCMD__c();
    
    
    }
    public static SAP_CMD__c createSAPCMD(id funlocid)
    {
     testSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001rtId,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = testCustomer.Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = funlocid,
            Company_Code__c = 'NL60 - RSO Europe',
            Consolidated_Account_Code__c = testCACC.Id,
            Sales_Organisation__c = 'NL60 - RSO Europe',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', 
            Cust_pric_proc__c = 'Test', 
            Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', 
            Rounding_Rule_SH__c = 'C - Round to Closest',
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c = testCustomer.id,
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Ind_period_account_statement__c = '1 - No account statement needed',
            Region__c = 'AM - Americas', Label_Required__c = 'Yes', Zip__c = '300457', Unloading_Point__c = 'CUSTOMER UNLOADING POINT', 
            Military_Usage__c = 'No - ID for mainly non-military use', Fix_Price_Ind_SP__c = 'N - No', Delivery_Group_Ind_SH__c = '01 - Sh per single line',
            Pull_Up_OK_SH__c = 'N - No', Reconciliation_Account__c = '1200100 - Trade AR with foreign parties', Sorting_key_for_assignment_no__c = '000 - Allocation number',
            Terms_of_payment__c = '114 - 75 days after invoice date', Delivery_priority__c = '30 - Priority 3', Payment_Credit_Memo__c = '114 - 75 days after invoice date',
            Distribution_Region__c = 'Test', Act_clerk_internet_address__c = 'AMB3425@motorola.com', Indicator_Record_Payment_History__c = TRUE,
            Key_for_Payment_Grouping__c = '02 - Currency', Lockbox__c = 'USD', Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference',
            Reason_Code_Conversion__c = '001 - Version 001', User_at_customer__c = 'Motorola Mobili', 
            Distribution_Channel__c = '00', Sales_office__c = 'SG60 - MSO SINGAPORE', Sales_district__c = 'AC - AP Greater China', Exch_rate_type__c = '4DEC - NXP Act. Rate',
            Division__c = '00', S_O_Sub_Group__c = 'SG - Singapore',
            Reprice_Basis__c = 'C - Conf. Delivery Date', Acct_at_cust__c = '1106401', Customer_Statistics_Group__c = '1', 
            Max_partial_deliveries__c = '9', Order_combination__c = TRUE, Shipping_conditions__c = '01 - Ship via Std Route', Incoterms_1__c = 'FCA - Free carrier',     
            Paym_guar_proc__c = 'Z001 - No guarantee required', Cred_contr_area__c = 'NL60 - RSO Europe', 
            Terms_of_Payment_Sales__c = '114 - 75 days after invoice date', Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility',
            BillCurrency_PY__c = 'USD', Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.', City__c = 'Test', Country__c = 'Test',
            Street_1__c = 'Test',Acct_assgmt_group__c='test'
            );
         return testSAPCMD;
    
    }
  /***************************************************************************
      Test Method for CSV Parsing Method  
    ****************************************************************************/ 
    static testmethod void csvUploadTest() 
    {
        //Prepare the test data
        
        fetchRecordTypes();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c( RecordTypeId = sapMassUpdateRequest.Id,
                                                        Mass_Update_Type__c='ZA');
        insert objCMDRequest;
        
        //Assert the inserted CMD Request Id
        system.assert(objCMDRequest.Id != null);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(objCMDRequest);
        SAPCMDMassUpdateController theController = new SAPCMDMassUpdateController(stdController);
        
        //Assert the SAPCMDMassUpdateController not null
        system.assert(theController != null);
        
        String strMassUpdateType=[Select Mass_Update_Type__c 
                                  From CMD_Request__c limit 1].Mass_Update_Type__c;
        
        //If Condition:Check the CSV Parsing when Mass Update Type is ZA
        if(strMassUpdateType.equalsIgnoreCase('ZA'))
        {
           /********************************************************
            Positive case:When delimitor is colon and no of headers 
            is either two or five->Parse the data and upload the data
            ********************************************************/
            
            //Data with Delimiter - colon   and number of columns -2
            string csvContent = 'Customer FunLoc Number,Person Name\n427863,HU165 - ESZTER LESKO';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            
            //Start the test
            Test.StartTest();
            
            PageReference currentPage=theController.uploadCSV();
            //Assert if the list contains the parsed data
            System.assert(theController.listFunlocWrapper != null);
            System.assert(theController.listFunlocWrapper.size() > 0);
            
            //Data with Delimiter - semi colon  and number of columns -2            
            csvContent = 'Customer FunLoc Number;Person Name\n427863;HU165 - ESZTER LESKO';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();            
            //Assert if the list contains the parsed data
            System.assert(theController.listFunlocWrapper != null);
            System.assert(theController.listFunlocWrapper.size() > 0);

            //Data with Delimiter - colon   and number of columns -5
            csvContent = 'Customer FunLoc Number,SAP CMD,Legal Name,Person Name old,Person Name\n449471,SAP#00016519,Flextronics International KFT,HU225 - LASZLO BARANYAI,TW006 - OPEN';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            //Assert if the list contains the parsed data
            System.assert(theController.listFunlocWrapper != null);
            System.assert(theController.listFunlocWrapper.size() > 0); 

            //Data with Delimiter - semi colon  and number of columns -5
            csvContent = 'Customer FunLoc Number;SAP CMD;Legal Name;Person Name old;Person Name\n449471;SAP#00016519;Flextronics International KFT;HU225 - LASZLO BARANYAI;TW006 - OPEN';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            //Assert if the list contains the parsed data
            System.assert(theController.listFunlocWrapper != null);
            System.assert(theController.listFunlocWrapper.size() > 0); 
            
            /********************************************************
            Negative Case:When delimitor is colon or semicolon and no of headers 
            is neither two nor five and order of column is not as per expected
            ->Do not Parse the data and capture error in apex message
            ********************************************************/
            
            //Data with Delimiter - semi colon  and number of columns -6            
            csvContent = 'Customer FunLoc Number;SAP CMD;Legal Name;Person Name old;Person Name;Person Name\n449471;SAP#00016519;Flextronics International KFT;HU225 - LASZLO BARANYAI;TW006 - OPEN;TW006 - OPEN';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            List<ApexPages.Message> lstMsgs = ApexPages.getMessages();
            lstMsgs = ApexPages.getMessages();
            //Assert if the list contains captured error messages
            System.assert(lstMsgs.size() > 0);
            
            //Data with Delimiter - colon   and number of columns -6           
            csvContent = 'Customer FunLoc Number,SAP CMD,Legal Name,Person Name old,Person Name,Name\n449471,SAP#00016519,Flextronics International KFT,HU225 - LASZLO BARANYAI,TW006 - OPEN,TW006 - OPEN';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            lstMsgs.clear();
            lstMsgs = ApexPages.getMessages();
            System.assert(lstMsgs.size()>0);
            
            //Data with Delimiter - semi colon  and number of columns -2 with wrong header name            
            csvContent = 'Customer FunLoc Number;Person Namee\n427863;HU165 - ESZTER LESKO';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            lstMsgs.clear();
            lstMsgs = ApexPages.getMessages();
            //Assert if the list contains captured error messages
            System.assert(lstMsgs.size() > 0);
            
            //Data with Delimiter - colon   and number of columns -2 with wrong header name            
            csvContent = 'Customer FunLoc Number,Person Namee\n427863,HU165 - ESZTER LESKO';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            lstMsgs.clear();
            lstMsgs = ApexPages.getMessages();
            //Assert if the list contains captured error messages
            System.assert(lstMsgs.size() > 0);
            
            //Data with Delimiter - colon   and number of columns -5 with wrong header name            
            csvContent = 'Customer FunLoc Number,SAP CMDDD,Legal Name,Person Name old,Person Name\n449471,SAP#00016519,Flextronics International KFT,HU225 - LASZLO BARANYAI,TW006 - OPEN';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            lstMsgs.clear();
            lstMsgs = ApexPages.getMessages();
            //Assert if the list contains captured error messages
            System.assert(lstMsgs.size() > 0); 
            
            //Data with Delimiter - semi colon  and number of columns -5 with wrong header name         
            csvContent = 'Customer FunLoc Number;SAP CMD;Legal Name;Person Name old;Person Nameee\n449471;SAP#00016519;Flextronics International KFT;HU225 - LASZLO BARANYAI;TW006 - OPEN';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            lstMsgs.clear();
            lstMsgs = ApexPages.getMessages();
            //Assert if the list contains captured error messages
            System.assert(lstMsgs.size() > 0);           
            
        }        
        
        objCMDRequest = new CMD_Request__c( RecordTypeId = sapMassUpdateRequest.Id,Mass_Update_Type__c='Address');
        insert objCMDRequest;
        
        //Assert the inserted CMD Request Id
        system.assert(objCMDRequest.Id != null);
        
        stdController = new ApexPages.StandardController(objCMDRequest);
        theController = new SAPCMDMassUpdateController(stdController);
        
        //Assert the SAPCMDMassUpdateController not null
        system.assert(theController != null);
        strMassUpdateType=[Select Mass_Update_Type__c 
                           From CMD_Request__c where Mass_Update_Type__c='Address' limit 1].Mass_Update_Type__c;
        
        //If Condition:Check the CSV Parsing when Mass Update Type is Address
        if(strMassUpdateType.equalsIgnoreCase('Address'))
        {   
            /********************************************************
            Positive case:When delimitor is colon or semi colon and 
            no of headers is 12->Parse the data and upload the data
            ********************************************************/
            
            //Data with Delimiter is colon and number of columns is 12
            string csvContent = 'Customer FunLoc Number,SAP CMD,Legal Name,Name 2,Name 3,Name 4,Street,Street 4,City,State,Country,Zip\n427863,test,"test,test",test,test,test,test,test,test,test,test,test';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
             System.debug(' SAPCMDMassUpdateController.contentFile:: '+ SAPCMDMassUpdateController.contentFile );
            PageReference currentPage=theController.uploadCSV();
            System.debug('currentPage::'+currentPage);
            System.debug('theController.listFunlocWrapper::'+theController.listFunlocWrapper);
            //Assert if the list contains the parsed data
            System.assert(theController.listFunlocWrapper != null);
           // System.assert(theController.listFunlocWrapper.size() > 0);
            
            //Data with Delimiter is semi colon and number of columns is 12
            csvContent = 'Customer FunLoc Number;SAP CMD;Legal Name;Name 2;Name 3;Name 4;Street;Street 4;City;State;Country;Zip\n427863;test1;"tttt;st";test;test;test;test;test;test;test;test;test';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            //Assert if the list contains the parsed data
            System.assert(theController.listFunlocWrapper != null);
            //System.assert(theController.listFunlocWrapper.size() > 0);
            
            /********************************************************
            Negative Case:When delimitor is colon or semicolon and no of headers 
            is not 12 and order of column is not as per expected
            ->Do not Parse the data and capture error in apex message
            ********************************************************/
            
            //Data with Delimiter is semi colon and number of columns is >12 and carriage return is \r
            csvContent = 'Customer FunLoc Number;SAP CMD;Legal Name;Name 2;Name 3;Name 4;Street;Street 4;City;State;Country;Zip;Zip\r427863;test1;test1;test;test;test;test;test;test;test;test;test;test';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            List<ApexPages.Message> lstMsgs = ApexPages.getMessages();
            //Assert if the list contains captured error messages
            System.assert(lstMsgs.size() > 0);
            
            //Data with Delimiter is colon and number of columns is <12
            csvContent = 'Customer FunLoc Number,SAP CMD,Legal Name,Name 2,Name 3,Name 4,Street,Street 4,City\n427863,test,test,test,test,test,test,test,test,test,test,test';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            lstMsgs.clear();
            lstMsgs = ApexPages.getMessages();
            //Assert if the list contains captured error messages
            System.assert(lstMsgs.size() > 0);
            
            //Data with Delimiter is semi colon and number of columns is 12 and wrong header name
            csvContent = 'Customer FunLoc Number;SAP CMD;Legal Name;Name 2;Name 3;Name 4;Street;Street 4;City;State;Country;Zipp\r427863;test1;test1;test;test;test;test;test;test;test;test;test';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            lstMsgs.clear();
            lstMsgs = ApexPages.getMessages();
            //Assert if the list contains captured error messages
            System.assert(lstMsgs.size() > 0);
            
            //Data with Delimiter is colon and number of columns is 12 and wrong header name
            csvContent = 'Customer FunLoc Number,SAP CMD,Legal Name,Name 2,Name 3,Name 4,Street,Street 4,City,State,Country,Zipp\n427863,test,test,test,test,test,test,test,test,test,test,test';
            SAPCMDMassUpdateController.contentFile =  blob.valueOf(csvContent);
            currentPage=theController.uploadCSV();
            lstMsgs.clear();
            lstMsgs = ApexPages.getMessages();
            //Assert if the list contains captured error messages
            System.assert(lstMsgs.size() > 0);
            
            //Start the test
            Test.stopTest();
        }
    }

   
}