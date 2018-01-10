/*********************************************************************************************************************************************
@LastModified By :     Manoj
@Modified Date :   11 Mar 2015
@Description :     Modified to improve the code coverage
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    20 Mar 2015
@Description:      Change the field type of SAP_CMD__c.Industry_Segment__c to formula
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    24 Jun 2015
@Description:      Change the field type of SAP_CMD__c.Industry_Sub_Segment__c to formula
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    25 Jun 2015
@Description:      Run as business user to tirgger process on process builder
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    11 Nov 2015
@Description:      Modified for adding City__c and Street_1__c information to all SAP CMD records
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :      Baji    
@Modified Date:    April 04, 2016 
@Description:      Modified for testing Fetch Title and Output values from the SAP CMD also to test the Dispatch Email method and SAPCMD_EraseTitleOutput  class
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Shridevi   
@Modified Date:    April 14, 2016 
@Description:      Modified for testing Customer_Catagory__C on cmd_Request.
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Shridevi   
@Modified Date:    May 02, 2016 
@Description:      Modified for optimizing the test method CustomerCatagoryTest()
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Baji
@Modified Date:    Aug 30, 2016 
@Description:      Modified for SIR 990. To obsolete and then adjust the transportation zone field to change it's data-type
-----------------------------------------------------------------------------------------------------------
@Modified By :      Baji
@Modified Date:     23 Mar 2017
@Description:       1704 Release (SFDC 285) - to test the code related to CMD Request completion notification for new funloc request to S&P team.
-----------------------------------------------------------------------------------------------------------
@Modified By :      Baji
@Modified Date:     26 Jul 2017
@Description:       1708 Release (SFDC 729) - To test default value feature for few of the fieds on SAP CMD New SBE Funloc Request form.
-----------------------------------------------------------------------------------------------------------
@Modified By :      Baji
@Modified Date:     20 Nov 2017
@Description:       1712 Release (SFDC-1087) - To disable the code related to SP team notification when New funloc request is completed
*********************************************************************************************************************************************/

@isTest
public class CMD_Request_Trigger_Test {
    private RecordType newSfdcParentAccount;
    public string newSfdcParentAccountRTId;
    
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
    private static final String TYPE_New_SBE_CmdReq = 'SAP_New_SBE_Funloc_request';// obj: CMD Request
    private Static Final string TYPE_Edit_SBE_CmdReq='SAP_SBE_Funloc_Edit_request';// obj: CMD Request
    private Static Final string TYPE_New_MANU_CmdReq='SAP_New_MANU_Funloc_request';// obj: CMD Request
    private Static Final string TYPE_Edit_MANU_CmdReq='SAP_MANU_Funloc_Edit_request';// obj: CMD Request
    private static final String Profile_NXP_CMD_Officer = 'NXP CMD Officer';// Profile NXP CMD Officer
    
    private static RecordType Global_Enterprise;
    private static RecordType Z001_SoldTo_ShipTo_BillTo_Payer;
    private static RecordType New_SFDC_Parent_Account;
    private static RecordType SAP_New_Funloc_Request;
    private static RecordType SAP_Funloc_Edit_Request;
    private static RecordType SAP_New_SBE_Funloc_request;
    private static RecordType SAP_SBE_Funloc_Edit_request;
    private static RecordType SAP_New_MANU_Funloc_request;
    private static RecordType SAP_MANU_Funloc_Edit_request;
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
    private static User businessUser;
    private static CMD_Request_Completion_Output__c objCustomOutSet;
    private static List<CMD_Request_Completion_Mails__c> lstCustomEmailSetting;
    
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
                                 OR (SobjectType = 'Hub_Foundation__c' and DeveloperName =: TYPE_Country_and_Region )
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_New_SBE_CmdReq )
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_Edit_SBE_CmdReq )
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_New_MANU_CmdReq )
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_Edit_MANU_CmdReq ))
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
            if(rt.DeveloperName == TYPE_New_SBE_CmdReq)
                SAP_New_SBE_Funloc_request = rt; 
            if(rt.DeveloperName == TYPE_Edit_SBE_CmdReq)
                SAP_SBE_Funloc_Edit_request = rt; 
            if(rt.DeveloperName == TYPE_New_MANU_CmdReq)
                SAP_New_MANU_Funloc_request = rt; 
            if(rt.DeveloperName == TYPE_Edit_MANU_CmdReq)
                SAP_MANU_Funloc_Edit_request = rt; 
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
                                          Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i, 
                                          /****Scarlett - 2015.07 Release
                                          Industry_Sub_Segment__c = 'F1 - Desktop',
                                          ****/
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
    
    private static void createCustomEmailSetting(){
    lstCustomEmailSetting = new List<CMD_Request_Completion_Mails__c>();
    
    lstCustomEmailSetting.add(new CMD_Request_Completion_Mails__c(Name = 'Logistics 1',Email_Ids__c = 'testmail.@testorg.com'));
    lstCustomEmailSetting.add(new CMD_Request_Completion_Mails__c(Name = 'CMD Team',Email_Ids__c = 'testuser.@testorg.com'));
  //  lstCustomEmailSetting.add(new CMD_Request_Completion_Mails__c(Name = 'S&P Team',Email_Ids__c = 'testemail.@testorg.com'));    
    
    insert lstCustomEmailSetting;
  }
    
    private static void createCustomOutputSetting(){
    
    objCustomOutSet= new CMD_Request_Completion_Output__c(
        Name = 'FCA Hong Kong',
        Output__c = 'Z_F8/F8 PI GAD output setting is completed to HK25'
    );
    insert objCustomOutSet;
   
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
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
/****Scarlett 2015.07 Release
            Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
****/
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
            Street_1__c = 'Test',
            SAP_CMD_Title__c = 'Test Fetch Title',
            Output_Message__c = 'FCA Hong Kong'
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
/****Scarlett - 2015.07 Release         
            Industry_Sub_Segment__c = 'A1 - Major Home Appliances',
****/
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
            Street_1__c = 'Test',
            SAP_CMD_Title__c = 'Test Fetch Title'
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
/****Scarlett 2015.07 Release
            Industry_Sub_Segment__c = 'A1 - Major Home Appliances',
****/ 
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
            Street_1__c = 'Test',
            SAP_CMD_Title__c = 'Test Fetch Title'
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
    
    private static void createAccountRequestUser(){
        Profile businessUserProfile = [
            SELECT Id FROM Profile WHERE Name LIKE '%NXP Sales%' LIMIT 1
        ];
        
        businessUser = new User(
            ProfileId = businessUserProfile.Id,
            Alias = 'buzUser', Email='CMD_Request_Trigger_Test.businessUser@test.com', 
            EmailEncodingKey='UTF-8', LastName='businessUser', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='CMD_Request_Trigger_Test.businessUser@test.com'
        );
        insert businessUser;
    }
    
    //create SAP New Funloc Request
    static testmethod void myUnitTest1(){
        
        
        //prepare data
        fetchRecordType();
        createCustomer();
        createParentAccount();
        createChildAccount();
        createCACC();
        createHubFundation();
        createFunloc();
        createSAPCMD();
        createAccountRequestUser();
        createCustomEmailSetting();
        createCustomOutputSetting();
     
        
        system.assertEquals(objParentAccount.Customer_Category__c, 'Key');
        
        List<Customer__c> tempLstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(tempLstCustomer.size() > 0);
        
        List<Funloc__c> tempLstFunloc = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[0].Id];
        
        Account parentAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Parent Account'];
        
        test.startTest();
        CMD_Request__c theRequest1 = new CMD_Request__c(
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Requester_Email__c = 'test@test.com' ,
            Street__c = 'TEST STREET' ,
            City__c = 'TEST CITY' ,
            Country__c = 'Czech Republic' ,//same with Hub_Foundation__c.Country__c, fetchRegion
            Role__c = 'OEM' ,
            //Parent_Account_in_CRM__c = objParentAccount.Id,//fetchParentCustomerCategory
            Parent_Account_in_CRM__c = parentAccount.Id,
            Sales_Organisation__c = 'NL60 - RSO Europe',// same with SAP_CMD__c.Sales_Organisation__c
            Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SH_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            PY_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            BP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            ZI_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            //GID__c = String.valueOf(lstCustomer[0].Name),//fetchCustomersIDs
            GID__c = '100000130',
            SP_GID__c = '100000130',
            SH_GID__c = '100000130',
            PY_GID__c = '100000130',
            BP_GID__c = '100000130',
            ZI_GID__c = '100000130',
            Consolidated_Account_Code__c = objCACC.Id//fetchCACCs
            //Request_Status__c = 'Approved'
        );
        //lstRequest.add(theRequest1);
        
        insert theRequest1;
        
        theRequest1.Request_Status__c = 'Approved';
        update theRequest1;
        
       // SAP_CMD__C sapCmdRequest = [Select Id,RecordTypeId,SAP_CMD_Title__c,Output_Message__c,Funloc__c  From SAP_CMD__C ];
        
        theRequest1.Request_Status__c = 'Completed';
        update theRequest1;
        CMD_Request__c theRequest2 = new CMD_Request__c(
            Parent_Account_in_CRM__c = objChildAccount.Id,
            Country__c = null,//fetchRegion
            Funloc__c = '00001',//fetchSAPCMDids
            SP_Funloc__c = '00001',
            SH_Funloc__c = '00001',
            PY_Funloc__c = '00001',
            BP_Funloc__c = '00001',
            ZI_Funloc__c = '00001'
        );
        insert theRequest2;
        
        CMD_Request__c theRequest3 = new CMD_Request__c(
            Country__c = null//fetchRegion
        );
        insert theRequest3;
        
        List<Funloc__c> tempLstFunloc2 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[1].Id];
        
        //Request with ZI
        CMD_Request__c theRequest4 = new CMD_Request__c(
            Street__c = 'TEST STREET' ,
            City__c = 'TEST CITY' ,
            Country__c = 'Czech Republic' ,//same with Hub_Foundation__c.Country__c, fetchRegion
            Role__c = 'OEM' ,
            //Parent_Account_in_CRM__c = objParentAccount.Id,//fetchParentCustomerCategory
            Parent_Account_in_CRM__c = parentAccount.Id,
            Sales_Organisation__c = 'NL60 - RSO Europe',// same with SAP_CMD__c.Sales_Organisation__c
            Funloc__c = tempLstFunloc2[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SH_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            PY_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            BP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            ZI_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            //GID__c = String.valueOf(lstCustomer[0].Name),//fetchCustomersIDs
            GID__c = '100000130',
            SP_GID__c = '100000130',
            SH_GID__c = '100000130',
            PY_GID__c = '100000130',
            BP_GID__c = '100000130',
            ZI_GID__c = '100000130',
            Consolidated_Account_Code__c = objCACC.Id,//fetchCACCs
            Request_Status__c = 'Approved'
        );
        //lstRequest.add(theRequest1);
        insert theRequest4;
        
        //Request with ZI
        CMD_Request__c theRequest5 = new CMD_Request__c(
            RecordTypeId = SAP_New_SBE_Funloc_Request.Id,
            Street__c = 'TEST STREET' ,
            City__c = 'TEST CITY' ,
            Country__c = 'Czech Republic' ,//same with Hub_Foundation__c.Country__c, fetchRegion
            Role__c = 'OEM' ,
            //Parent_Account_in_CRM__c = objParentAccount.Id,//fetchParentCustomerCategory
            Parent_Account_in_CRM__c = parentAccount.Id,
            Sales_Organisation__c = 'NL60 - RSO Europe',// same with SAP_CMD__c.Sales_Organisation__c
            Funloc__c = tempLstFunloc2[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            Consolidated_Account_Code__c = objCACC.Id,//fetchCACCs
            Request_Status__c = 'Approved'
        );
        //lstRequest.add(theRequest1);
        insert theRequest5;
        
         CMD_Request__c theRequest6 = new CMD_Request__c(
            RecordTypeId = SAP_New_SBE_Funloc_Request.Id,
            Street__c = 'TEST STREET' ,
            City__c = 'TEST CITY' ,
            Country__c = 'Czech Republic' ,//same with Hub_Foundation__c.Country__c, fetchRegion
            Role__c = 'OEM' ,
            //Parent_Account_in_CRM__c = objParentAccount.Id,//fetchParentCustomerCategory
            Parent_Account_in_CRM__c = parentAccount.Id,
            Sales_Organisation__c = 'US60 - RSO U.S.A.',// same with SAP_CMD__c.Sales_Organisation__c
            Funloc__c = tempLstFunloc2[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            Consolidated_Account_Code__c = objCACC.Id,//fetchCACCs
            Request_Status__c = 'Approved'
        );
        //lstRequest.add(theRequest1);
        insert theRequest6;
        
        test.stopTest();
    }
    
    //Run as CMD Officer
    static testMethod void myUnitTest2(){
        
        //prepare data
        fetchRecordType();
        createCustomer();
        createParentAccount();
        createChildAccount();
        createCACC();
        createHubFundation();
        createFunloc();
        createSAPCMD();
        List<Account> listAccount=new List<Account>();
        CMD_Request__c testCmdRequest=new CMD_Request__c();
        list<CMD_Request__c> listCmdRequest=new list<CMD_Request__c>();
        system.assertEquals(objParentAccount.Customer_Category__c, 'Key');
        
        List<Customer__c> tempLstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(tempLstCustomer.size() > 0);
        
        List<Funloc__c> tempLstFunloc = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[0].Id];
        
        Account parentAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Parent Account'];
        
        test.startTest();
        CMD_Request__c theRequest1 = new CMD_Request__c(
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Requester_Email__c = 'test@test.com' ,
            Street__c = 'TEST STREET' ,
            City__c = 'TEST CITY' ,
            Country__c = 'Czech Republic' ,//same with Hub_Foundation__c.Country__c, fetchRegion
            Role__c = 'OEM' ,
            //Parent_Account_in_CRM__c = objParentAccount.Id,//fetchParentCustomerCategory
            Parent_Account_in_CRM__c = parentAccount.Id,
            Sales_Organisation__c = 'NL60 - RSO Europe',// same with SAP_CMD__c.Sales_Organisation__c
            Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SH_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            PY_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            BP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            ZI_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            //GID__c = String.valueOf(lstCustomer[0].Name),//fetchCustomersIDs
            GID__c = '100000130',
            SP_GID__c = '100000130',
            SH_GID__c = '100000130',
            PY_GID__c = '100000130',
            BP_GID__c = '100000130',
            ZI_GID__c = '100000130',
            Consolidated_Account_Code__c = objCACC.Id,//fetchCACCs
            Request_Status__c = 'Approved',
            CMD_Officer_Approved_Rejected_Date__c = datetime.Now()
        );
        //lstRequest.add(theRequest1);
        insert theRequest1; 

        //run as CMD officer
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'NXP CMD Officer'];
        if(objProfile != null){
            //Create CMD Officer
            User officer = new User(
                Alias = 'newUser', Email='newuser.cmd@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='newuser.cmd@testorg.com'
            );
            
            //system.runAs(officer){
            /****Scarlett - 2015.07 Release - CMD Officer won't modify any request****/
            
        
            
                update theRequest1;
            //}
        }
        
       
        
        test.stopTest();
    }
    
  
    
    static testMethod void emailDispatchTest(){
        
        //prepare data
        fetchRecordType();
        createCustomer();
        createParentAccount();
        createChildAccount();
        createCACC();
        createHubFundation();
        createFunloc();
        createSAPCMD();
        createCustomEmailSetting();
        createCustomOutputSetting();
              
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: Profile_NXP_CMD_Officer ];
        List<SAP_CMD__c> tempLstSapCmd = [SELECT Id, Output_Message__c,SAP_CMD_Title__c,FunLoc__c,Customer_FunLoc_Number__c, Sales_Organisation__c  FROM SAP_CMD__c WHERE Id =: lstSAPCMD[0].Id];
        
        List<Funloc__c> tempLstFunloc = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[0].Id];
        
        Account parentAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Parent Account'];
        test.startTest();
        if(objProfile != null){
            //Create CMD Officer
        
            User officer = new User(
                Alias = 'newUser', Email='newuser.cmd@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='newuser.cmd@testorg.com'
            );
        List<Customer__c> tempLstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(tempLstCustomer.size() > 0);
        
        
        
        //test.startTest();
        system.runAs(officer)
        {
        CMD_Request__c theRequest1 = new CMD_Request__c(
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Requester_Email__c = 'test@test.com' ,
            Street__c = 'TEST STREET' ,
            City__c = 'TEST CITY' ,
            Country__c = 'Czech Republic' ,//same with Hub_Foundation__c.Country__c, fetchRegion
            Role__c = 'OEM' ,
            Recipient_List__c = 'Logistics 1',
            Parent_Account_in_CRM__c = parentAccount.Id,
            Sales_Organisation__c = 'NL60 - RSO Europe',// same with SAP_CMD__c.Sales_Organisation__c
            Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SH_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            PY_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            BP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            ZI_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            GID__c = '100000130',
            SP_GID__c = '100000130',
            SH_GID__c = '100000130',
            PY_GID__c = '100000130',
            BP_GID__c = '100000130',
            ZI_GID__c = '100000130',
            Consolidated_Account_Code__c = objCACC.Id,//fetchCACCs
            Request_Status__c = 'Approved'
        );
     
        insert theRequest1; 

        map <Id,CMD_Request__c> oldCMDReqMaptest= new map<Id, CMD_Request__c>();
      
        
        tempLstSapCmd[0].Status__c = 'Approved and Distributed';
        tempLstSapCmd[0].CMD_Request_ID_Text__c= theRequest1.Id;
        update tempLstSapCmd[0];
        
        oldCMDReqMaptest.put(theRequest1.Id,theRequest1);
        theRequest1.Request_Status__c = 'Completed';
        update theRequest1; 
        theRequest1=[Select Title__c, Output__c From CMD_Request__c where Request_Status__c='Completed'];      
        system.assert(theRequest1.Title__c!= null);
        system.assert(theRequest1.Output__c!=null);
        }
        }
        SAPCMD_EraseTitleOutput erase = new SAPCMD_EraseTitleOutput();
        System.schedule('Test', '0 0 12 ? * FRI *', erase);
        erase.start( (Database.BatchableContext) null );
        erase.execute( (Database.BatchableContext) null, tempLstSapCmd );
        erase.finish( (Database.BatchableContext) null );
        erase.execute((SchedulableContext)null);
        SAPCMD_EraseTitleOutput.run();
        SAP_CMD__c SapCmdRec = [SELECT Id, Output_Message__c,SAP_CMD_Title__c,FunLoc__c,Customer_FunLoc_Number__c, Sales_Organisation__c  FROM SAP_CMD__c WHERE Id =: tempLstSapCmd[0].id];
        system.assert(SapCmdRec.SAP_CMD_Title__c==null);
        system.assert(SapCmdRec.Output_Message__c==null); 
       
        test.stopTest();
    
    }
    
    
     static testMethod void emailDispatchTest1(){
        
        //prepare data
        fetchRecordType();
        createCustomer();
        createParentAccount();
        createChildAccount();
        createCACC();
        createHubFundation();
        createFunloc();
        createSAPCMD();
        createCustomEmailSetting();
        createCustomOutputSetting();
              
        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: Profile_NXP_CMD_Officer ];
        List<SAP_CMD__c> tempLstSapCmd = [SELECT Id, Output_Message__c,SAP_CMD_Title__c,FunLoc__c,Customer_FunLoc_Number__c, Sales_Organisation__c  FROM SAP_CMD__c WHERE Id =: lstSAPCMD[0].Id];
        
        List<Funloc__c> tempLstFunloc = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[0].Id];
        
        Account parentAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Parent Account'];
        test.startTest();
        if(objProfile != null){
            //Create CMD Officer
        
            User officer = new User(
                Alias = 'newUser', Email='newuser.cmd@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='newuser.cmd@testorg.com'
            );
        List<Customer__c> tempLstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(tempLstCustomer.size() > 0);
        
        
        
        //test.startTest();
        system.runAs(officer)
        {
        CMD_Request__c theRequest1 = new CMD_Request__c(
            RecordTypeId = SAP_SBE_Funloc_Edit_request.Id,
            Requester_Email__c = 'test@test.com' ,
            Street__c = 'TEST STREET' ,
            City__c = 'TEST CITY' ,
            Country__c = 'Czech Republic' ,//same with Hub_Foundation__c.Country__c, fetchRegion
            Role__c = 'OEM' ,
            Recipient_List__c = 'Logistics 1',
            Parent_Account_in_CRM__c = parentAccount.Id,
            Sales_Organisation__c = 'NL60 - RSO Europe',// same with SAP_CMD__c.Sales_Organisation__c
            Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,//fetchSAPCMDids
            SH_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            PY_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            BP_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            ZI_Funloc__c = tempLstFunloc[0].FunLoc_Number_Text__c,
            GID__c = '100000130',
            SP_GID__c = '100000130',
            SH_GID__c = '100000130',
            PY_GID__c = '100000130',
            BP_GID__c = '100000130',
            ZI_GID__c = '100000130',
            Consolidated_Account_Code__c = objCACC.Id,//fetchCACCs
            Request_Status__c = 'Approved'
        );
     
        insert theRequest1; 

        map <Id,CMD_Request__c> oldCMDReqMaptest= new map<Id, CMD_Request__c>();
      
        
        tempLstSapCmd[0].Status__c = 'Approved and Distributed';
        tempLstSapCmd[0].CMD_Request_ID_Text__c= theRequest1.Id;
        update tempLstSapCmd[0];
        
        oldCMDReqMaptest.put(theRequest1.Id,theRequest1);
        theRequest1.Request_Status__c = 'Completed';
        update theRequest1; 
        theRequest1=[Select Title__c, Output__c From CMD_Request__c where Request_Status__c='Completed'];      
        system.assert(theRequest1.Title__c!= null);
        system.assert(theRequest1.Output__c!=null);
        }
        }
        SAPCMD_EraseTitleOutput erase = new SAPCMD_EraseTitleOutput();
        System.schedule('Test', '0 0 12 ? * FRI *', erase);
        erase.start( (Database.BatchableContext) null );
        erase.execute( (Database.BatchableContext) null, tempLstSapCmd );
        erase.finish( (Database.BatchableContext) null );
        erase.execute((SchedulableContext)null);
        SAPCMD_EraseTitleOutput.run();
        SAP_CMD__c SapCmdRec = [SELECT Id, Output_Message__c,SAP_CMD_Title__c,FunLoc__c,Customer_FunLoc_Number__c, Sales_Organisation__c  FROM SAP_CMD__c WHERE Id =: tempLstSapCmd[0].id];
        system.assert(SapCmdRec.SAP_CMD_Title__c==null);
        system.assert(SapCmdRec.Output_Message__c==null); 
       
        test.stopTest();
    
    }
  //Test method for SIR 19: Effective allignment for Customer Catagtory field in both parent account and CMD Request
 public static Account testAccount;
 public static List<Account> listAccount=new List<Account>();
 public static CMD_Request__c testCmdRequest=new CMD_Request__c();
 public static  list<CMD_Request__c> listCmdRequest=new list<CMD_Request__c>();
 /* public static account createTestAccount(string name,id testRecordType)
{   
    testAccount=new account();
    testAccount.name=name;
    testAccount.region__c = 'EMEA';   
    testAccount.type = 'OEM';    
    testAccount.industry_Segment__c = 'Industrial'; 
    testAccount.sub_Segment__c = 'Smart Metering';   
    testAccount.numberOfEmployees = 1500;  
    testAccount.annualRevenue = 100000; 
    testAccount.recordTypeId = testRecordType; 
        
    return testAccount;
}
*/
public static CMD_Request__c createCMDRequest(id testParentAccount)
{
testCmdRequest=new CMD_Request__c();
testCmdRequest.recordTypeId=New_SFDC_Parent_Account.id;
testCmdRequest.Parent_Account_in_CRM__c=testParentAccount;
testCmdRequest.Country__c='Czech Republic';
//testCmdRequest.Customer_Category__c='Partner';
return testCmdRequest;
}
  
  
  
  public static testMethod void customerCatagoryTest()
  {  
     integer count=0;
     fetchRecordType(); 
     createHubFundation();                         
     for(count=0;count<2;count++)
     {   
         createParentAccount();       
         listAccount.add(objParentAccount);
         listCmdRequest.add(createCMDRequest(listAccount[count].id));
     } 
                               
     listAccount[1].Customer_Category__c='Mega';
     upsert listAccount;
     insert listCmdRequest;
     listCmdRequest=[select id,Customer_Category__c from CMD_Request__c where id in: listCmdRequest];
     test.startTest();
     count=0;
     system.assertEquals(listCmdRequest[0].Customer_Category__c,listAccount[0].Customer_Category__c);
     system.assertEquals(listCmdRequest[1].Customer_Category__c,listAccount[1].Customer_Category__c);
     listCmdRequest[0].Parent_Account_in_CRM__c=listAccount[1].id;
     listCmdRequest[1].Parent_Account_in_CRM__c=listAccount[0].id;
     update listCmdRequest;
     listCmdRequest=[select id,Customer_Category__c from CMD_Request__c where id in:listCmdRequest];
    // system.assertEquals(listCmdRequest[0].Customer_Category__c,listAccount[1].Customer_Category__c);
   //  system.assertEquals(listCmdRequest[1].Customer_Category__c,listAccount[0].Customer_Category__c);
     listCmdRequest[1].Parent_Account_in_CRM__c=null;
     listCmdRequest[1].country__c=null;
     update listCmdRequest;
   
     test.stopTest();
  }  
}


/*
@isTest
private class CMD_Request_Trigger_Test 
{
/*    private static User testUser = new User(  FirstName = 'Test' ,
                                                LastName = 'User' ,
                                                Username = 'test@test.com' ,
                                                Email = 'test@test.com'
                                            );
*/
/*
    private RecordType newSfdcParentAccount;
    public string newSfdcParentAccountRTId;
    
    private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
    private static final String TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER = 'Z001_SoldTo_ShipTo_BillTo_Payer';
    private static final String TYPE_New_SFDC_Parent_Account = 'New_SFDC_Parent_Account';
    private static final String TYPE_Child_Account = 'Child_Account';
    private static final String TYPE_SAP_New_Funloc_Request = 'SAP_New_Funloc_Request';
    private static final String TYPE_SAP_Funloc_Edit_Request = 'SAP_Funloc_Edit_Request';
    private static final String TYPE_Z002_Ship_To = 'Z002_Ship_To';
    private static final String TYPE_Country_and_Region = 'Country_and_Region';
    
    private static RecordType globalCustomer;
    private static RecordType Z001_SoldTo_ShipTo_BillTo_Payer;
    private static RecordType New_SFDC_Parent_Account;
    private static RecordType Child_Account;
    private static RecordType SAP_New_Funloc_Request;
    private static RecordType SAP_Funloc_Edit_Request;
    private static RecordType Z002_Ship_To;
    private static RecordType Country_and_Region;
    
    private static Customer__c objCustomer;
    private static List<Hub_Foundation__C> lstHubFoundation;
    private static SAP_CMD__c objSAPCMD;
    private static Account objChildAccount;
    private static User objUserCMDOfficer;
    private static Hub_Foundation__c objHubFoundation;
    
    private void fetchNewSfdcParentAccountRecordType()
    {
        for(RecordType rt : 
            [   
                Select Id, DeveloperName
                From RecordType
                WHERE SobjectType = 'CMD_Request__c' 
                AND DeveloperName = 'New_SFDC_Parent_Account' 
                AND IsActive=true
                Limit 1
            ]
           )
        {
            newSfdcParentAccount = rt;
            newSfdcParentAccountRTId = String.valueOf(rt.Id);            
        }    
    }
    
    //Modified By Scarlett
    private static void fetchRecordType(){
        for(RecordType rt : [SELECT Id, DeveloperName
                             FROM   RecordType
                             WHERE  IsActive = TRUE 
                             AND ((SobjectType = 'Customer__c' AND DeveloperName =: TYPE_GLOBALENTERPRISE)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z002_Ship_To)
                                 OR (SobjectType = 'Account' and DeveloperName =: TYPE_Child_Account)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_SAP_New_Funloc_Request)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_SAP_Funloc_Edit_Request)
                                 OR (SobjectType = 'Hub_Foundation__c' and DeveloperName =: TYPE_Country_and_Region ))
                              ])
        {
            if(rt.DeveloperName == TYPE_GLOBALENTERPRISE)
                globalCustomer = rt;
            if(rt.DeveloperName == TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                Z001_SoldTo_ShipTo_BillTo_Payer = rt;
            if(rt.DeveloperName == TYPE_Z002_Ship_To)
                Z002_Ship_To = rt;
            if(rt.DeveloperName == TYPE_New_SFDC_Parent_Account)
                New_SFDC_Parent_Account = rt;
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

    //Modified By Scarlett
    private static void createCustomer()
    {
         objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ',
                                        Legal_Name__c = 'ut_Global_Enterprise ', DUNS__c = 'ut_123', 
                                        Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                        House_Number__c = 'ut', Street__c = 'ut_street_1',
                                        City__c = 'ut_city', Country__c = 'ANDORRA', 
                                        Zip__c = 'ut_zip', Industry_Segment__c = 'Computing' ,
                                        Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                        Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2',
                                        Street_3__c = 'ut_street_3' ,State__c = 'test',Industry_Sub_Segment__c = 'F1 - Desktop',
                                        SIC_Code__c = 't1', NAICS_Code__c = 'ut', 
                                        Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                        Fax__c = '+1234567890', Telephone__c = '+1234567890');                                            
         insert objCustomer;
    }
    
    //Modified By Scarlett
    private static void createHubFundation(){
        objHubFoundation= new Hub_Foundation__c(
            RecordTypeId = Country_and_Region.Id,
            Alpha_2_Code__c =  'AE',
            Region__c = 'EU - EMEA',
            Country__c = 'Taiwan',
            Alpha_3_Code__c = 'ARE'
        );

        insert objHubFoundation;
    }
    
    //Modified By Scarlett
    private static void createAccount(){
        objChildAccount = new Account(
            Name ='Unit Test Account', 
            RecordTypeId = Child_Account.Id , 
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
    
    //Modified By Scarlett
    private static void createSAPCMD(){
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id, 
            HUB_Customer__c = objCustomer.Id, 
            Status__c = 'Draft', 
            Legal_Name__c = 'test record' ,  
            Name_2__c = 'additional name', 
            Name_3__c = 'test name 3', 
            Name_4__c = 'test name 4',  
            Language__c = 'M - Traditional Chinese',
            FunLoc_Type__c = 'internal',
            End_Customer_NXP_Global_ID__c = objCustomer.Id,
            Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',
            Acct_assgmt_group__c = '01 - Local 3rd Party',
            Currency__c = 'USD - US Dollar',
            Incoterms_2__c = 'TEST'
        );
        insert objSAPCMD;
    }
    
    @isTest(SeeAllData=true) 
    static void myUnitTest() 
    {
        //prepare data
        fetchRecordType();
        createHubFundation();
        createAccount();
//      insert testUser;

//      fetchNewSfdcParentAccountRecordType();
     Recordtype rt1 = [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              SobjectType = 'SAP_CMD__c' and Name ='Z001 - Sold To / Ship To / Bill To / Payer'];
                              
     Recordtype rt2 = [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              SobjectType = 'SAP_CMD__c' and Name ='Z010 - Intermediate Consignee']; 
                              
      List<Customer__c> lstCustomers = new List<Customer__c>();
        Customer__c objCustomer1;
        for(integer i=0; i < 5; i++){                   
             objCustomer1 = new Customer__c(
                 RecordTypeId = globalCustomer.Id, 
                 Account_Name__c = 'ut_Global_Enterprise ' + i ,
                 Legal_Name__c = 'ut_Global_Enterprise ' + i , 
                 DUNS__c = 'ut_123'+ i , 
                 Status__c = 'Active' ,  
                 DNB_Verified__c = 'D&B Accepted' ,
                 House_Number__c = 'ut'+ i , 
                 Street__c = 'ut_street_1' + i ,
                 Zip__c = 'ut_zip' + i , 
                 City__c = 'ut_city' + i, 
                 Country__c = 'USA' ,  
                 Industry_Segment__c = 'CC - Computing' ,
                 Type__c = 'Customer' , 
                 Role__c = 'OEM',
                 GSM_Classification__c = 'Global',
                 Fulfillment_Channel__c = 'Disti',  
                 Street_2__c = 'ut_street_2' + i ,
                 Street_3__c = 'ut_street_3' + i ,
                 State__c = 'test' + i,
                 Industry_Sub_Segment__c = 'F1 - Desktop',
                 SIC_Code__c = 't' + i, 
                 NAICS_Code__c = 'ut_' + i, 
                 Website__c = 'http://www.test.com', 
                 EMail__c  = 'test.test@test.com',
                 Fax__c = '+1234567890', 
                 Telephone__c = '+1234567890'
             );
             lstCustomers.add(objCustomer1);   
               }
             insert lstCustomers; 
       
        
        
        Funloc__c newFonloc = new Funloc__c(
            Name__c = 'Test Convert',
            Call_Name__c = 'Test Convert',
            Street_Name__c = 'Test Convert',
            Place_Name__c = 'Test Convert',
            Country_Name__c = 'Test Convert'
        );
        insert newFonloc;
        
        Funloc__c newFonloc2 = new Funloc__c(
            Name__c = 'Test Convert',
            Call_Name__c = 'Test Convert',
            Street_Name__c = 'Test Convert',
            Place_Name__c = 'Test Convert',
            Country_Name__c = 'Test Convert'
        );
        insert newFonloc2;
        
        List<Funloc__c> lstFunloc = new List<Funloc__c>();
        for(integer i = 0 ; i < 10 ; i++){
            Funloc__c tempFunloc = new Funloc__c(
                Name__c = 'Test Convert'+ i,
                Call_Name__c = 'Test Convert',
                Street_Name__c = 'Test Convert',
                Place_Name__c = 'Test Convert',
                Country_Name__c = 'Test Convert'
            );
            lstFunloc.add(tempFunloc);
        }
        insert lstFunloc;
    
        Consolidated_Account_Code__c con1 = new Consolidated_Account_Code__c(
            Name ='ZZZ', Code_Description__c = 'Test Code' , 
            End_Customer_GID__c = lstCustomers[0].Id, 
            Customer_Category__c = 'Focus', 
            PD_Key_Account__c = 'Test', 
            Base_Region__c = 'AM-Americas'
        );
        insert con1;
     
       
     Funloc__c objfunloc = [SELECT Id, FunLoc_Number_Text__c FROM Funloc__c limit 1];
                              
     SAP_CMD__c NewCMD = new SAP_CMD__c();
        NewCMD.RecordTypeid = rt1.id; //RecordType: Z001 - Sold To / Ship To / Bill To / Payer
        NewCMD.Status__c = 'Approved and Distributed';
        NewCMD.HUB_Customer__c = lstCustomers[0].Id;
        NewCMD.Legal_Name__c = 'Test SAP CMD - Test Test';
        NewCMD.Transportation_Zone__c = 'AE1 - United Arab Emir. 1';
        NewCMD.Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE';
        NewCMD.Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard';
        NewCMD.Rounding_Rule_SH__c = 'C - Round to Closest';
//Scarlett        NewCMD.Industry_Segment__c = 'AA - Appliances';
        NewCMD.Industry_Sub_Segment__c = 'A1 - Major Home Appliances';
        NewCMD.Company_Code__c = 'NL60 - RSO Europe';
        NewCMD.Ind_period_account_statement__c = '1 - No account statement needed'; 
        NewCMD.Sales_Organisation__c = 'NL60 - RSO Europe';
        NewCMD.Region__c = 'AM - Americas';
        NewCMD.Label_Required__c = 'Yes';
        NewCMD.FunLoc_Type__c = 'Pure';
        NewCMD.Consolidated_Account_Code__c = con1.Id;
        NewCMD.Name_2__c = '(China) Co., Ltd.';
        NewCMD.Street_1__c = 'Test';
        NewCMD.City__c = 'TEDA, TIANJIN';
        NewCMD.Country__c = 'China';
        NewCMD.Zip__c = '300457';
        NewCMD.Global_Account__c = 'MOTOROLA - MOT MOTOROLA INC.';
        NewCMD.Customer_Factory_Calendar__c = 'Z5 - Generic 5 Day Working Week Calendar';
        NewCMD.Unloading_Point__c = 'CUSTOMER UNLOADING POINT';
        NewCMD.Military_Usage__c = 'No - ID for mainly non-military use';
        NewCMD.Fix_Price_Ind_SP__c = 'N - No';
        NewCMD.Delivery_Group_Ind_SH__c = '01 - Sh per single line';
        NewCMD.Pull_Up_OK_SH__c = 'N - No';
        NewCMD.Reconciliation_Account__c = '1200100 - Trade AR with foreign parties';
        NewCMD.Sorting_key_for_assignment_no__c = '000 - Allocation number';
        NewCMD.Terms_of_payment__c = '114 - 75 days after invoice date';
        NewCMD.Payment_Credit_Memo__c = '114 - 75 days after invoice date';
        NewCMD.Indicator_Record_Payment_History__c = TRUE;
        NewCMD.Key_for_Payment_Grouping__c = '02 - Currency';
        NewCMD.Lockbox__c = 'USD';
        NewCMD.Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference';
        NewCMD.Reason_Code_Conversion__c = '001 - Version 001';
        NewCMD.Acconting_Clerk__c = '17 - Jo Chen';
        NewCMD.User_at_customer__c = 'Motorola Mobili';
        NewCMD.Act_clerk_internet_address__c = 'AMB3425@motorola.com';
        NewCMD.Ind_period_account_statement__c = 'M - Mailing account statements';
        NewCMD.Sales_Organisation__c = 'NL60 - RSO Europe';
        NewCMD.Distribution_Channel__c = '00';
        NewCMD.Sales_office__c = 'SG60 - MSO SINGAPORE';
        NewCMD.Sales_district__c = 'AC - AP Greater China';
        NewCMD.Exch_rate_type__c = '4DEC - NXP Act. Rate';
        NewCMD.Cust_pric_proc__c = '1 - OEM/EMS Pricing';
        NewCMD.Region__c = 'AP - Asia Pacific';
        NewCMD.Division__c = '00';
        NewCMD.Distribution_Region__c = 'P1 - HK00';
        NewCMD.Currency__c = 'USD - US Dollar';
        NewCMD.S_O_Sub_Group__c = 'SG - Singapore';  
        NewCMD.Reprice_Basis__c = 'C - Conf. Delivery Date';
        NewCMD.Acct_at_cust__c = '1106401';
        NewCMD.Customer_Statistics_Group__c = '1';
        NewCMD.Delivery_priority__c = '30 - Priority 3';
        NewCMD.Max_partial_deliveries__c = '9';
        NewCMD.Order_combination__c = TRUE;
        NewCMD.Shipping_conditions__c = '01 - Ship via Std Route';
        NewCMD.Incoterms_1__c = 'FCA - Free carrier';     
        NewCMD.Paym_guar_proc__c = 'Z001 - No guarantee required';
        NewCMD.Cred_contr_area__c = 'NL60 - RSO Europe';
        NewCMD.Incoterms_2__c = 'HONG KONG';
        NewCMD.Acct_assgmt_group__c = '02 - Export 3rd Party';
        NewCMD.Terms_of_Payment_Sales__c = '114 - 75 days after invoice date';
        NewCMD.Grp_1_Sls_Channel_SP__c = 'OEM - Original Equip Mfr';
        NewCMD.Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility';
        NewCMD.BillCurrency_PY__c = 'USD';
        NewCMD.Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)';
        NewCMD.Additional_shipping_mark__c = 'C/NO.';
        NewCMD.Label_Required__c = 'No';
        NewCMD.FunLoc_Type__c = 'Pure';
        //NewCMD.FunLoc__c = funloc.Id;
        //NewCMD.FunLoc__c = 'a1UD0000000QZBa';
       
        NewCMD.CMD_Request_Id__c = null;
        NewCMD.Zip__c= '123456';
        NewCMD.Funloc__c = objFunloc.Id;
        
        insert NewCMD;                   
        
        
       SAP_CMD__c NewCMD1 = new SAP_CMD__c();
        NewCMD1.RecordTypeid = rt2.id; //RecordType: Z010 - Intermediate Consignee
        NewCMD1.Status__c = 'Approved and Distributed';
        NewCMD1.HUB_Customer__c = lstCustomers[0].Id;
        NewCMD1.Legal_Name__c = 'Test SAP CMD - Test Test';
        NewCMD1.Transportation_Zone__c = 'AE1 - United Arab Emir. 1';
        NewCMD1.Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE';
        NewCMD1.Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard';
        NewCMD1.Rounding_Rule_SH__c = 'C - Round to Closest';
//Scarlett        NewCMD1.Industry_Segment__c = 'AA - Appliances';
        NewCMD1.Industry_Sub_Segment__c = 'A1 - Major Home Appliances';
        NewCMD1.Company_Code__c = 'NL60 - RSO Europe';
        NewCMD1.Ind_period_account_statement__c = '1 - No account statement needed'; 
        NewCMD1.Sales_Organisation__c = 'NL60 - RSO Europe';
        NewCMD1.Region__c = 'AM - Americas';
        NewCMD1.Label_Required__c = 'Yes';
        NewCMD1.FunLoc_Type__c = 'Pure';
        NewCMD1.Consolidated_Account_Code__c = con1.Id;
        NewCMD1.Name_2__c = '(China) Co., Ltd.';
        NewCMD1.Street_1__c = 'Test';
        NewCMD1.City__c = 'TEDA, TIANJIN';
        NewCMD1.Country__c = 'China';
        NewCMD1.Zip__c = '300457';
        NewCMD1.Global_Account__c = 'MOTOROLA - MOT MOTOROLA INC.';
        NewCMD1.Customer_Factory_Calendar__c = 'Z5 - Generic 5 Day Working Week Calendar';
        NewCMD1.Unloading_Point__c = 'CUSTOMER UNLOADING POINT';
        NewCMD1.Military_Usage__c = 'No - ID for mainly non-military use';
        NewCMD1.Fix_Price_Ind_SP__c = 'N - No';
        NewCMD1.Delivery_Group_Ind_SH__c = '01 - Sh per single line';
        NewCMD1.Pull_Up_OK_SH__c = 'N - No';
        NewCMD1.Reconciliation_Account__c = '1200100 - Trade AR with foreign parties';
        NewCMD1.Sorting_key_for_assignment_no__c = '000 - Allocation number';
        NewCMD1.Terms_of_payment__c = '114 - 75 days after invoice date';
        NewCMD1.Payment_Credit_Memo__c = '114 - 75 days after invoice date';
        NewCMD1.Indicator_Record_Payment_History__c = TRUE;
        NewCMD1.Key_for_Payment_Grouping__c = '02 - Currency';
        NewCMD1.Lockbox__c = 'USD';
        NewCMD1.Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference';
        NewCMD1.Reason_Code_Conversion__c = '001 - Version 001';
        NewCMD1.Acconting_Clerk__c = '17 - Jo Chen';
        NewCMD1.User_at_customer__c = 'Motorola Mobili';
        NewCMD1.Act_clerk_internet_address__c = 'AMB3425@motorola.com';
        NewCMD1.Ind_period_account_statement__c = 'M - Mailing account statements';
        NewCMD1.Sales_Organisation__c = 'NL60 - RSO Europe';
        NewCMD1.Distribution_Channel__c = '00';
        NewCMD1.Sales_office__c = 'SG60 - MSO SINGAPORE';
        NewCMD1.Sales_district__c = 'AC - AP Greater China';
        NewCMD1.Exch_rate_type__c = '4DEC - NXP Act. Rate';
        NewCMD1.Cust_pric_proc__c = '1 - OEM/EMS Pricing';
        NewCMD1.Region__c = 'AP - Asia Pacific';
        NewCMD1.Division__c = '00';
        NewCMD1.Distribution_Region__c = 'P1 - HK00';
        NewCMD1.Currency__c = 'USD - US Dollar';
        NewCMD1.S_O_Sub_Group__c = 'SG - Singapore';  
        NewCMD1.Reprice_Basis__c = 'C - Conf. Delivery Date';
        NewCMD1.Acct_at_cust__c = '1106401';
        NewCMD1.Customer_Statistics_Group__c = '1';
        NewCMD1.Delivery_priority__c = '30 - Priority 3';
        NewCMD1.Max_partial_deliveries__c = '9';
        NewCMD1.Order_combination__c = TRUE;
        NewCMD1.Shipping_conditions__c = '01 - Ship via Std Route';
        NewCMD1.Incoterms_1__c = 'FCA - Free carrier';     
        NewCMD1.Paym_guar_proc__c = 'Z001 - No guarantee required';
        NewCMD1.Cred_contr_area__c = 'NL60 - RSO Europe';
        NewCMD1.Incoterms_2__c = 'HONG KONG';
        NewCMD1.Acct_assgmt_group__c = '02 - Export 3rd Party';
        NewCMD1.Terms_of_Payment_Sales__c = '114 - 75 days after invoice date';
        NewCMD1.Grp_1_Sls_Channel_SP__c = 'OEM - Original Equip Mfr';
        NewCMD1.Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility';
        NewCMD1.BillCurrency_PY__c = 'USD';
        NewCMD1.Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)';
        NewCMD1.Additional_shipping_mark__c = 'C/NO.';
        NewCMD1.Label_Required__c = 'No';
        NewCMD1.FunLoc_Type__c = 'Pure';
        //NewCMD1.FunLoc__c = funloc.Id;
        //NewCMD1.FunLoc__c = 'a1UD0000000QZBa';
        NewCMD1.FunLoc__c = newFonloc.Id;
        NewCMD1.CMD_Request_Id__c = null;
        NewCMD1.Zip__c= '123456';
        
        insert NewCMD1;                       
                              
        SAP_CMD__c NewCMDZ002 = new SAP_CMD__c();
        NewCMDZ002.RecordTypeid = Z002_Ship_To.Id;
        NewCMDZ002.Status__c = 'Approved and Distributed';
        NewCMDZ002.HUB_Customer__c = lstCustomers[0].Id;
        NewCMDZ002.Legal_Name__c = 'Test SAP CMD - Test Test';
        NewCMDZ002.Transportation_Zone__c = 'AE1 - United Arab Emir. 1';
        NewCMDZ002.Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE';
        NewCMDZ002.Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard';
        NewCMDZ002.Rounding_Rule_SH__c = 'C - Round to Closest';
//Scarlett        NewCMDZ002.Industry_Segment__c = 'AA - Appliances';
        NewCMDZ002.Industry_Sub_Segment__c = 'A1 - Major Home Appliances';
        NewCMDZ002.Company_Code__c = 'NL60 - RSO Europe';
        NewCMDZ002.Ind_period_account_statement__c = '1 - No account statement needed'; 
        NewCMDZ002.Sales_Organisation__c = 'NL60 - RSO Europe';
        NewCMDZ002.Region__c = 'AM - Americas';
        NewCMDZ002.Label_Required__c = 'Yes';
        NewCMDZ002.FunLoc_Type__c = 'Pure';
        NewCMDZ002.Consolidated_Account_Code__c = con1.Id;
        NewCMDZ002.Name_2__c = '(China) Co., Ltd.';
        NewCMDZ002.Street_1__c = 'Test';
        NewCMDZ002.City__c = 'TEDA, TIANJIN';
        NewCMDZ002.Country__c = 'China';
        NewCMDZ002.Zip__c = '300457';
        NewCMDZ002.Global_Account__c = 'MOTOROLA - MOT MOTOROLA INC.';
        NewCMDZ002.Customer_Factory_Calendar__c = 'Z5 - Generic 5 Day Working Week Calendar';
        NewCMDZ002.Unloading_Point__c = 'CUSTOMER UNLOADING POINT';
        NewCMDZ002.Military_Usage__c = 'No - ID for mainly non-military use';
        NewCMDZ002.Fix_Price_Ind_SP__c = 'N - No';
        NewCMDZ002.Delivery_Group_Ind_SH__c = '01 - Sh per single line';
        NewCMDZ002.Pull_Up_OK_SH__c = 'N - No';
        NewCMDZ002.Reconciliation_Account__c = '1200100 - Trade AR with foreign parties';
        NewCMDZ002.Sorting_key_for_assignment_no__c = '000 - Allocation number';
        NewCMDZ002.Terms_of_payment__c = '114 - 75 days after invoice date';
        NewCMDZ002.Payment_Credit_Memo__c = '114 - 75 days after invoice date';
        NewCMDZ002.Indicator_Record_Payment_History__c = TRUE;
        NewCMDZ002.Key_for_Payment_Grouping__c = '02 - Currency';
        NewCMDZ002.Lockbox__c = 'USD';
        NewCMDZ002.Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference';
        NewCMDZ002.Reason_Code_Conversion__c = '001 - Version 001';
        NewCMDZ002.Acconting_Clerk__c = '17 - Jo Chen';
        NewCMDZ002.User_at_customer__c = 'Motorola Mobili';
        NewCMDZ002.Act_clerk_internet_address__c = 'AMB3425@motorola.com';
        NewCMDZ002.Ind_period_account_statement__c = 'M - Mailing account statements';
        NewCMDZ002.Sales_Organisation__c = 'NL60 - RSO Europe';
        NewCMDZ002.Distribution_Channel__c = '00';
        NewCMDZ002.Sales_office__c = 'SG60 - MSO SINGAPORE';
        NewCMDZ002.Sales_district__c = 'AC - AP Greater China';
        NewCMDZ002.Exch_rate_type__c = '4DEC - NXP Act. Rate';
        NewCMDZ002.Cust_pric_proc__c = '1 - OEM/EMS Pricing';
        NewCMDZ002.Region__c = 'AP - Asia Pacific';
        NewCMDZ002.Division__c = '00';
        NewCMDZ002.Distribution_Region__c = 'P1 - HK00';
        NewCMDZ002.Currency__c = 'USD - US Dollar';
        NewCMDZ002.S_O_Sub_Group__c = 'SG - Singapore';  
        NewCMDZ002.Reprice_Basis__c = 'C - Conf. Delivery Date';
        NewCMDZ002.Acct_at_cust__c = '1106401';
        NewCMDZ002.Customer_Statistics_Group__c = '1';
        NewCMDZ002.Delivery_priority__c = '30 - Priority 3';
        NewCMDZ002.Max_partial_deliveries__c = '9';
        NewCMDZ002.Order_combination__c = TRUE;
        NewCMDZ002.Shipping_conditions__c = '01 - Ship via Std Route';
        NewCMDZ002.Incoterms_1__c = 'FCA - Free carrier';     
        NewCMDZ002.Paym_guar_proc__c = 'Z001 - No guarantee required';
        NewCMDZ002.Cred_contr_area__c = 'NL60 - RSO Europe';
        NewCMDZ002.Incoterms_2__c = 'HONG KONG';
        NewCMDZ002.Acct_assgmt_group__c = '02 - Export 3rd Party';
        NewCMDZ002.Terms_of_Payment_Sales__c = '114 - 75 days after invoice date';
        NewCMDZ002.Grp_1_Sls_Channel_SP__c = 'OEM - Original Equip Mfr';
        NewCMDZ002.Grp_2_Cus_Prce_Grp_SP__c = '042 - Motorola Mobility';
        NewCMDZ002.BillCurrency_PY__c = 'USD';
        NewCMDZ002.Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)';
        NewCMDZ002.Additional_shipping_mark__c = 'C/NO.';
        NewCMDZ002.Label_Required__c = 'No';
        NewCMDZ002.FunLoc_Type__c = 'Pure';
        //NewCMD1.FunLoc__c = funloc.Id;
        //NewCMD1.FunLoc__c = 'a1UD0000000QZBa';
        NewCMDZ002.FunLoc__c = lstFunloc[0].Id;
        NewCMDZ002.CMD_Request_Id__c = null;
        NewCMDZ002.Zip__c= '123456';
        
        insert NewCMDZ002;  

        SAP_CMD__c theSAP = [
            SELECT  Id, 
                    Customer_FunLoc_Number__c ,
                    Funloc__c
            FROM SAP_CMD__c
            WHERE RecordType.Name = 'Z001 - Sold To / Ship To / Bill To / Payer' LIMIT 1
        ];
        
        SAP_CMD__c theSAPZ010 = [
            SELECT  Id,
                    Customer_FunLoc_Number__c
            FROM    SAP_CMD__c
            WHERE   RecordType.Name = 'Z010 - Intermediate Consignee' LIMIT 1
        ];
        
        Consolidated_Account_Code__c con = [SELECT Id FROM Consolidated_Account_Code__c LIMIT 1]; 
        

        Account a = [Select Id,name from account limit 1];
        
        
        CMD_Request__c testRequest = new CMD_Request__c(    Requester_Name__c = 'TEST REQUESTER' ,
                                                            Requester_Email__c = 'test@test.com' ,
                                                            Street__c = 'TEST STREET' ,
                                                            City__c = 'TEST CITY' ,
                                                            Country__c = 'Taiwan' ,
                                                            Customer_Category__c = 'Focused' ,
                                                            Role__c = 'OEM' ,
                                                            Parent_Account_in_CRM__c = a.id,
                                                            Funloc__c = theSAP.Customer_FunLoc_Number__c,
                                                            GID__c = '000000001',
                                                            ZI_GID__c = '000000001',
                                                            Consolidated_Account_Code__c = con.Id
                                                       );
        insert testRequest;
//        System.assertNotEquals( testRequest.Customer_Category__c, null );

        CMD_Request__c testRequest2 = new CMD_Request__c(    Requester_Name__c = 'TEST REQUESTER' ,
                                                             Requester_Email__c = 'test@test.com' ,
                                                             Street__c = 'TEST STREET' ,
                                                             City__c = 'TEST CITY' ,
                                                             Country__c = 'Taiwan' ,
                                                             Customer_Category__c = 'Focused' ,
                                                             Role__c = 'OEM' ,
                                                             Parent_Account_in_CRM__c = a.id,
                                                             Funloc__c = theSAP.Customer_FunLoc_Number__c,
                                                             GID__c = '000000001',
                                                             ZI_GID__c = '000000001',
                                                             Consolidated_Account_Code__c = con.Id,
                                                             Request_Status__c = 'Approved'
                                                       );
        insert testRequest2;
        
        //Modified by Scarlett
        //Request with Child Account
        CMD_Request__c testRequest3 = new CMD_Request__c(    Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Customer_Category__c = 'Focused' ,
                                                        Role__c = 'OEM' ,
                                                        //Parent_Account_in_CRM__c = '0012000000XkZFJAA3',
                                                        Parent_Account_in_CRM__c = objChildAccount.Id,
                                                        Funloc__c = theSAP.Customer_FunLoc_Number__c,
                                                        GID__c = '000000001',
                                                        ZI_GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id
                                                       );
        insert testRequest3;

        //Request with SP Funloc
        CMD_Request__c testRequest4 = new CMD_Request__c(    Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Customer_Category__c = 'Focused' ,
                                                        Role__c = 'OEM' ,
                                                        //Parent_Account_in_CRM__c = '0012000000XkZFJAA3',
                                                        //SP_Funloc__c = theSAP.Customer_FunLoc_Number__c,
                                                        SP_Funloc__c = objFunloc.FunLoc_Number_Text__c,
                                                        GID__c = '000000001',
                                                        SP_GID__c = '000000001',
                                                        ZI_GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id
                                                       );
        insert testRequest4;
        
        testRequest4.SP_Funloc__c =  newFonloc.FunLoc_Number_Text__c;
        update testRequest4;
        
        //Request with SH Funloc
         CMD_Request__c testRequest5 = new CMD_Request__c(    Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Customer_Category__c = 'Focused' ,
                                                        Role__c = 'OEM' ,
                                                        //Parent_Account_in_CRM__c = '0012000000XkZFJAA3',
                                                        //SH_Funloc__c = theSAP.Customer_FunLoc_Number__c,
                                                        SH_Funloc__c = objFunloc.FunLoc_Number_Text__c,
                                                        GID__c = '000000001',
                                                        SH_GID__c = '000000001',
                                                        ZI_GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id
                                                       );
        insert testRequest5;     
        
        //Request with PY Funloc
        CMD_Request__c testRequest6 = new CMD_Request__c(    Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Customer_Category__c = 'Focused' ,
                                                        Role__c = 'OEM' ,
                                                        //Parent_Account_in_CRM__c = '0012000000XkZFJAA3',
                                                        //PY_Funloc__c = theSAP.Customer_FunLoc_Number__c,
                                                        PY_Funloc__c = objFunloc.FunLoc_Number_Text__c,
                                                        GID__c = '000000001',
                                                        PY_GID__c = '000000001',
                                                        ZI_GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id
                                                       );
        insert testRequest6;     
        
        //Request with BP Funloc
        CMD_Request__c testRequest7 = new CMD_Request__c(    Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Customer_Category__c = 'Focused' ,
                                                        Role__c = 'OEM' ,
                                                        //Parent_Account_in_CRM__c = '0012000000XkZFJAA3',
                                                        //PY_Funloc__c = theSAP.Customer_FunLoc_Number__c,
                                                        BP_Funloc__c = objFunloc.FunLoc_Number_Text__c,
                                                        GID__c = '000000001',
                                                        BP_GID__c = '000000001',
                                                        ZI_GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id
                                                       );
        insert testRequest7;     

        //Request with ZI
        CMD_Request__c testRequest8 = new CMD_Request__c(    Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Customer_Category__c = 'Focused' ,
                                                        Role__c = 'OEM' ,
                                                        //Parent_Account_in_CRM__c = '0012000000XkZFJAA3',
                                                        Funloc__c = theSAPZ010.Customer_FunLoc_Number__c,
                                                        ZI_Funloc__c = objFunloc.FunLoc_Number_Text__c,
                                                        GID__c = '000000001',
                                                        ZI_GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id
                                                       );
        insert testRequest8;   
        
        //Request with Edit Funloc
        CMD_Request__c testRequest9 = new CMD_Request__c(    Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Customer_Category__c = 'Focused' ,
                                                        Role__c = 'OEM' ,
                                                        //Parent_Account_in_CRM__c = '0012000000XkZFJAA3',
                                                        //Funloc__c = objFunloc.FunLoc_Number_Text__c,
                                                        Funloc__c = objFunloc.FunLoc_Number_Text__c,
                                                        GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id,
                                                        Sales_Organisation__c = 'NL60 - RSO Europe'
                                                       );
        insert testRequest9; 
        testRequest9.Funloc__c = '123456';
        update testRequest9;

        //Request with New Funloc
        CMD_Request__c testRequest10 = new CMD_Request__c(   RecordTypeId = SAP_New_Funloc_Request.Id,
                                                        Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Customer_Category__c = 'Focused' ,
                                                        Role__c = 'OEM' ,
                                                        //Parent_Account_in_CRM__c = '0012000000XkZFJAA3',
                                                        //Funloc__c = objFunloc.FunLoc_Number_Text__c,
                                                        Funloc__c = newFonloc2.FunLoc_Number_Text__c,
                                                        GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id
                                                       );
        insert testRequest10;         

        //Edit request with ZOO2 Account group
        CMD_Request__c testRequestZ002 = new CMD_Request__c(   RecordTypeId = SAP_Funloc_Edit_Request.Id,
                                                        Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Funloc__c = lstFunloc[0].FunLoc_Number_Text__c,
                                                        GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id,
                                                        Sales_Organisation__c = 'NL60 - RSO Europe'
                                                       );
        insert testRequestZ002;  
        system.assert(testRequestZ002.Funloc__c == lstFunloc[0].FunLoc_Number_Text__c);
        
        //Edit request with ZI Account group 
        CMD_Request__c testRequestZI = new CMD_Request__c(   RecordTypeId = SAP_Funloc_Edit_Request.Id,
                                                        Requester_Name__c = 'TEST REQUESTER' ,
                                                        Requester_Email__c = 'test@test.com' ,
                                                        Street__c = 'TEST STREET' ,
                                                        City__c = 'TEST CITY' ,
                                                        Country__c = 'Taiwan' ,
                                                        Funloc__c = newFonloc.FunLoc_Number_Text__c,
                                                        GID__c = '000000001',
                                                        Consolidated_Account_Code__c = con.Id,
                                                        Sales_Organisation__c = 'NL60 - RSO Europe'
                                                       );
        insert testRequestZI;  
        
        List<CMD_Request__c> allRequests = [
            SELECT  Id ,
                    Country__c ,
                    Region__c ,
                    Parent_Account_in_CRM__c ,
                    Approver_AMEC__c ,
                    Approver_EMEA__c ,
                    Approver_GC__c ,
                    Approver_Japan__c ,
                    Approver_Korea__c ,
                    Approver_Korea_2__c ,
                    Approver_SAP__c ,
                    Approver_SAP_2__c ,
                    Approver_SAP_3__c ,
                    SP_GID__c ,
                    SH_GID__c ,
                    PY_GID__c ,
                    BP_GID__c ,
                    ZI_GID__c ,
                    SP_CustomerID__c ,
                    SH_CustomerID__c ,
                    PY_CustomerID__c ,
                    BP_CustomerID__c ,
                    ZI_CustomerID__c,
                    Customer_Category__c
            FROM CMD_Request__c
            LIMIT 100
        ];
        
        CMD_Request_Trigger.fetchRegion( allRequests );
        CMD_Request_Trigger.fetchApprovers( allRequests ); 
        CMD_Request_Trigger.fetchCustomersIDs( allRequests );    
        CMD_Request_Trigger.fetchSAPCMDids( allRequests );
        CMD_Request_Trigger.fetchCACCs( allRequests ); 
        CMD_Request_Trigger.eraseRequestFields( allRequests ); 
        CMD_Request_Trigger.fetchCMDOfficer( allRequests ); 
    }
}
*/