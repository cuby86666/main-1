// 2015-03-03 by Rex: First release.
// 
/***************************************************************************************************************************
@Modified By :     Scarlett Kang
@Modified Date:    24 Jun 2015
@Description:      Change the field type of SAP_CMD__c.Industry_Sub_Segment__c to formula   
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Baji
@Modified Date:    Aug 30, 2016 
@Description:      Modified for SIR 990. To obsolete and then adjust the transportation zone field to change it's data-type    
***************************************************************************************************************************/      
@isTest(SeeAllData=true)
private class SAPCustomerUpdateBatchTest {
    static testMethod void updateTest1() {
        SAPCustomerUpdateBatch objBatch = new SAPCustomerUpdateBatch();
        Database.executeBatch(objBatch);
    }
    
    private static final String TYPE_Global_Enterprise = 'Global_Enterprise';//ojb: Customer
    private static final String TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER = 'Z001_SoldTo_ShipTo_BillTo_Payer';// obj: SAP CMD
    private static final String TYPE_Z002_Ship_To = 'Z002_Ship_To';// obj: SAP CMD
    private static final String TYPE_Z010_Intermediate_Consignee = 'Z010_Intermediate_Consignee';// obj: SAP CMD
    private static final String TYPE_New_SFDC_Parent_Account = 'New_SFDC_Parent_Account';// obj: CMD Request
    private static final String TYPE_Parent_Account = 'Parent_Account';//obj: Account
    private static final String TYPE_Child_Account = 'Child_Account';//obj: Account
    private static final String TYPE_Country_and_Region = 'Country_and_Region';//obj: Hub Foundation
    private static final String TYPE_SAP_New_Funloc_Request = 'SAP_New_Funloc_Request';// obj: CMD Request
    private static final String TYPE_SAP_Funloc_Edit_Request = 'SAP_Funloc_Edit_Request';// obj: CMD Request
    
    private static RecordType Global_Enterprise;
    private static RecordType Z001_SoldTo_ShipTo_BillTo_Payer;
    private static RecordType New_SFDC_Parent_Account;
    private static RecordType SAP_New_Funloc_Request;
    private static RecordType SAP_Funloc_Edit_Request;
    private static RecordType Parent_Account;
    private static RecordType Child_Account;
    private static RecordType Country_and_Region;
    private static RecordType Z002_Ship_To;
    private static RecordType Z010_Intermediate_Consignee;
    
    private static List<Customer__c> lstCustomer;
    private static Customer__c objCustomer;
    private static List<Hub_Foundation__C> lstHubFoundation;
    private static Hub_Foundation__c objHubFoundation;
    private static List<SAP_CMD__c> lstSAPCMD;
    private static SAP_CMD__c objSAPCMD;
    private static Account objParentAccount;
    private static Account objChildAccount;
    private static Funloc__c objFunloc;
    private static List<Funloc__c> lstFunloc;
    private static Consolidated_Account_Code__c objCACC;

    
    private static void fetchRecordType(){
        for(RecordType rt : [SELECT Id, DeveloperName
                             FROM   RecordType
                             WHERE  IsActive = TRUE 
                             AND ((SobjectType = 'Customer__c' AND DeveloperName =: TYPE_Global_Enterprise)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z002_Ship_To)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z010_Intermediate_Consignee)
                                 OR (SobjectType = 'Account' and DeveloperName =: TYPE_Parent_Account)
                                 OR (SobjectType = 'Account' and DeveloperName =: TYPE_Child_Account)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_New_SFDC_Parent_Account)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_SAP_New_Funloc_Request)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_SAP_Funloc_Edit_Request)
                                 OR (SobjectType = 'Hub_Foundation__c' and DeveloperName =: TYPE_Country_and_Region ))
                              ])
        {
            if(rt.DeveloperName == TYPE_Global_Enterprise)
                Global_Enterprise = rt;
            if(rt.DeveloperName == TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                Z001_SoldTo_ShipTo_BillTo_Payer = rt;
            if(rt.DeveloperName == TYPE_Z002_Ship_To) 
                Z002_Ship_To = rt;
            if(rt.DeveloperName == TYPE_Z010_Intermediate_Consignee)
                Z010_Intermediate_Consignee = rt;
            if(rt.DeveloperName == TYPE_New_SFDC_Parent_Account)
                New_SFDC_Parent_Account = rt;
            if(rt.DeveloperName == TYPE_Parent_Account)
                Parent_Account = rt;            
            if(rt.DeveloperName == TYPE_Child_Account)
                Child_Account = rt;
            if(rt.DeveloperName == TYPE_SAP_New_Funloc_Request)
                SAP_New_Funloc_Request = rt;    
            if(rt.DeveloperName == TYPE_SAP_Funloc_Edit_Request)
                SAP_Funloc_Edit_Request = rt; 
            if(rt.DeveloperName == TYPE_Country_and_Region)
                Country_and_Region = rt; 
        }
    }
    
    private static void createCustomer()
    {
        lstCustomer = new List<Customer__c>();
        for(integer i=0; i < 10; i++)
        {
            objCustomer = new Customer__c(RecordTypeId = Global_Enterprise.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
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
    
    private static void createHubFundation(){
        objHubFoundation= new Hub_Foundation__c(
            RecordTypeId = Country_and_Region.Id,
            Alpha_2_Code__c =  'AE',
            Region__c = 'EU - EMEA',
            Country__c = 'Czech Republic',
            Alpha_3_Code__c = 'ARE'
        );

        insert objHubFoundation;
    }
    
    private static void createParentAccount(){
        objParentAccount = new Account(
            RecordTypeId = Parent_Account.Id,
            Customer_Category__c = 'Key',
            Name ='Unit Test Parent Account', 
            Status_of_D_B_Cleansing__c = 'D&B Data Accepted' , 
            D_B_Account_Name__c = 'DB Name' , 
            D_B_Street__c = 'DB Street' , 
            D_B_State_Province__c = 'DB State' , 
            D_B_City__c = 'DB City' , 
            D_B_Country__c = 'DB Country' , 
            D_B_ZIP_Postal_Code__c = 'DB Zip' , 
            D_B_SIC_Code__c = 'DB Sic' , 
            D_B_SIC_Code_Description__c = 'DB Sic Desc' 
        );
        insert objParentAccount;    
    }
    
    private static void createChildAccount(){
        objChildAccount = new Account(
            RecordTypeId = Child_Account.Id,
            Name ='Unit Test Child Account', 
            Status_of_D_B_Cleansing__c = 'D&B Data Accepted' , 
            D_B_Account_Name__c = 'DB Name' , 
            D_B_Street__c = 'DB Street' , 
            D_B_State_Province__c = 'DB State' , 
            D_B_City__c = 'DB City' , 
            D_B_Country__c = 'DB Country' , 
            D_B_ZIP_Postal_Code__c = 'DB Zip' , 
            D_B_SIC_Code__c = 'DB Sic' , 
            D_B_SIC_Code_Description__c = 'DB Sic Desc' 
        );
        insert objChildAccount;
    }
    
    private static void createFunloc(){
        lstFunloc = new List<Funloc__c>();
        
        for(integer i = 0 ; i < 10 ; i++){
            Funloc__c objFonloc = new Funloc__c(
                Name__c = 'Test Convert' + i,
                Call_Name__c = 'Test Convert',
                Street_Name__c = 'Test Convert',
                Place_Name__c = 'Test Convert',
                Country_Name__c = 'Test Convert'
            );
            lstFunloc.add(objFonloc);
        }
        insert lstFunloc;
    }
    
    private static void createSAPCMD(){
        lstSAPCMD = new List<SAP_CMD__c>();
        //SAP CMD with Z001
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[0].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[0].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c = lstCustomer[0].id,
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test',  Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett          Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
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
            BillCurrency_PY__c = 'USD', Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.'
        );
        lstSAPCMD.add(objSAPCMD);
        
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[0].Id,
            Status__c = 'Approved',
            Funloc__c = lstFunloc[0].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c = lstCustomer[0].id,
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'US60 - RSO U.S.A.',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test',  Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett          Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
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
            BillCurrency_PY__c = 'USD', Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.'
        );
        lstSAPCMD.add(objSAPCMD);
        
        //SAP CMD with ZI/Z010
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z010_Intermediate_Consignee.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[1].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[1].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c = lstCustomer[0].id,
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test',  Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett          Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
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

}