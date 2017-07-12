/******************************************************************************
@Modified By :     Scarlett Kang
@Modified Date :   26 Sep 2014
@Description :     Updated test methods to fix it due to new mandatory field - Postal Code

@LastModified By :     Manoj
@Modified Date :   10 Mar 2015
@Description :     Modified to improve the code coverage
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    20 Mar 2015
@Description:      Change the field type of SAP_CMD__c.Industry_Segment__c to formula
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Scarlett Kang
@Modified Date:    May 30 2016
@Description:      1606 Release - SIR 292, [IMO]Divide CACC "Industry Segment" to "CBG" and "SUB-CBG", 
                   SAP_CMD__c.Industry_Sub_Segment__c is going to be formula field
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Baji
@Modified Date:    Aug 30, 2016 
@Description:      Modified for SIR 990. To obsolete and then adjust the transportation zone field to change it's data-type
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Baji
@Modified Date:    Mar 20, 2017
@Description:      Modified as part of SFDC 363 to create test methods for SAP_CMD_Request_Trigger.cls
---------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      Apr 26, 2017 
@Description:        SFDC-430 - Replace GSM COntroller Approver Group picklist to new multiselect picklist Controller Approver Group
*****************************************************************************************************/

@IsTest
public class SAP_CMD_Trigger_Test{
    private static final String TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER = 'Z001_SoldTo_ShipTo_BillTo_Payer';
    private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
    private static final String TYPE_SAP_Funloc_Edit_Request = 'SAP_Funloc_Edit_Request';
    
    private static RecordType Z001_SoldTo_ShipTo_BillTo_Payer;
    private static RecordType globalCustomer;
    private static RecordType SAP_Funloc_Edit_Request;
    
    private static CMD_Request__c testRequest;
    private static Funloc__c objFunloc;
    private static List<Customer__c> lstCustomer;
    private static Customer__c objCustomer;
    private static List<SAP_CMD__c> lstSAPCMD;
    private static SAP_CMD__c objSAPCMD;
    private static Consolidated_Account_Code__c objCACC;
    
    private static void fetchRecordTypes(){
        for(Recordtype rt : [SELECT Id, DeveloperName
                              FROM RecordType
                              WHERE IsActive = true AND  
                              (
                              (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                               OR (SobjectType = 'Customer__c' AND DeveloperName =: TYPE_GLOBALENTERPRISE)
                               OR (SobjectType = 'CMD_Request__c' AND DeveloperName =: TYPE_SAP_Funloc_Edit_Request)
                              )
                              ])
        {
            if(rt.DeveloperName == TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                Z001_SoldTo_ShipTo_BillTo_Payer = rt;
            if(rt.DeveloperName == TYPE_GLOBALENTERPRISE)
                globalCustomer = rt;
            if(rt.DeveloperName == TYPE_SAP_Funloc_Edit_Request)
                SAP_Funloc_Edit_Request = rt;              
        }//END for
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
    
    private static void createCustomer()
    {
        lstCustomer = new List<Customer__c>();
        for(integer i=0; i < 10; i++)
        {
            objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                          Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                          Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                          House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                          Zip__c = 'ut_zip' + i , City__c = 'ut_city' + i, Country__c = 'USA' ,  
                                          Industry_Segment__c = 'CC - Computing' ,
                                          Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                          Fulfillment_Channel__c = 'Disti',  Street_2__c = 'ut_street_2' + i ,
                                          Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,Industry_Sub_Segment__c = 'F1 - Desktop',
                                          SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                          Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                          Fax__c = '+1234567890', Telephone__c = '+1234567890');
            lstCustomer.add(objCustomer);                        
         }                                         
         insert lstCustomer;
    }
    
    private static void createCACC(){
        objCACC = new Consolidated_Account_Code__c(
            Name ='ZZZ', Code_Description__c = 'Test Code' , 
            End_Customer_GID__c = objCustomer.Id, 
            Customer_Category__c = 'Focus', 
            PD_Key_Account__c = 'Test', 
            Base_Region__c = 'AM-Americas'
        );
        insert objCACC;
    }
    
    private static void createSAPCMD(){
        lstSAPCMD = new List<SAP_CMD__c>();
        //SAP CMD with Z001
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[0].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = objFunloc.Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c = lstCustomer[0].id,
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//1606 Release SIR 292            Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
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
            Street_1__c = 'Test'
        );
        lstSAPCMD.add(objSAPCMD);
        insert lstSAPCMD;
    }
    
    static testmethod void theTest(){              
        //prepare data
        fetchRecordTypes();
        createFunloc();
        createCustomer();
        createCACC();
        createSAPCMD();
        
        SAP_CMD__c testSAPCMD = [SELECT Id, Funloc__c, CMD_Request_Id__c, Status__c, Pending_Approver__c, Pending_Approval_Since__c FROM SAP_CMD__c Limit 1];
        system.assert(testSAPCMD.Funloc__c != null);
        
        //Create CMD Request
        Funloc__c testFunloc = [SELECT Id, FunLoc_Number_Text__c FROM Funloc__c limit 1];
        List<CMD_Request__c> lstCMDRequest = new List<CMD_Request__c>();
        CMD_Request__c request = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = testFunloc.FunLoc_Number_Text__c,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Approved',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan' //added by Nisha Agrawal on Apr 26 for SFDC-430 
        );
        insert request;
        lstCMDRequest.add(request);
         
        CMD_Request_Trigger.fetchSAPCMDids( lstCMDRequest );        
        system.assertEquals(request.Funloc_SAP_CMD__c, testSAPCMD.Id);
           
        //update SAP CMD 
        testSAPCMD.CMD_Request_Id__c = string.valueof(request.Id);
        testSAPCMD.Status__c = 'Approved';
        update testSAPCMD;
 
        testSAPCMD.Status__c = 'Approved and Distributed';
        update testSAPCMD;
        
        request.Request_Status__c = 'Completed';
        update request;
        SAP_CMD_Trigger sapCmd = new SAP_CMD_Trigger();
        sapCmd.updateCMDRequestStatus(string.valueof(request.Id),string.valueof(testSAPCMD.Id));
        SAP_CMD_Trigger.removeCMDRequestId(string.valueof(request.Id),string.valueof(testSAPCMD.Id));
    }    
    static testmethod void Update_SAPCMD_GeneralData_Test(){
   
        list<CMD_Request__c> lstCmdRequest=new list<CMD_Request__c>();
       
        
        fetchRecordTypes();
        createFunloc();
        createCustomer();
        createCACC();
        createSAPCMD();     
        testRequest = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
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
        Test.startTest();
        insert lstCmdRequest;
        
     List<SAP_CMD__c> listSap = new List<SAP_CMD__c>();
        //SAP CMD with Z001
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[0].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = objFunloc.Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c = lstCustomer[0].id,
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
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
            Street_1__c = 'Test'
        );
            listSap.add(objSAPCMD);
            insert listSap;
            
       list<SAP_CMD__c> lstSAPCMDtobeUpdated = new list<SAP_CMD__c>();

      for(SAP_CMD__c sap:lstSAPCMD)
          {
            sap.Name_2__c='Test Name 2';
            sap.Name_4__c='Test Name 4';
            sap.Legal_Name__c='Test Legal Name';
            sap.Name_3__c='Test Name 3';
            sap.Street_2__c='Test Street 2';
            sap.Street_1__c='Test Street 1';
            sap.State_Province__c='Test State Province';
            sap.Country__c='Test Country';
            sap.City__c='Test City';
            sap.Zip__c='Test Zip';
            sap.PO_Box__c='Test POB';
            sap.PO_Box_City__c='Test POBC';
            sap.PO_Box_Postal_Code__c='Test POBPC';
            sap.Telephone__c='Test Telephone';
            sap.Email__c='testemail@test.com';
            lstSAPCMDtobeUpdated.add(sap);
        }        
        update lstSAPCMDtobeUpdated;
        
        list<sap_cmd__c> lstsc = [select id,Name_2__c,Name_4__c,Street_1__c,Street_2__c,Zip__c,Email__c from sap_cmd__c where Funloc__c =: objFunloc.id];
        system.assertEquals('Test Name 2', lstsc[0].Name_2__c );
        system.assertEquals('Test Name 4', lstsc[0].Name_4__c );
        system.assertEquals('Test Street 1', lstsc[0].Street_1__c );
        system.assertEquals('Test Street 2', lstsc[0].Street_2__c );
        system.assertEquals('Test Zip', lstsc[0].Zip__c );
        system.assertEquals('testemail@test.com', lstsc[0].Email__c );
     Test.stopTest();
   }
}