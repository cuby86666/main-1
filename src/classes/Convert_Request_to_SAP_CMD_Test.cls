/***************************************************************************************************************************
@Modified By :       Scarlett Kang
@Modified Date:    20 Mar 2015
@Description:      Change the field type of SAP_CMD__c.Industry_Segment__c to formula
---------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    02 Oct 2015
@Description:      1510 Release - SIR 404. SAP CMD - ZA & ZS change - from manual to auto (for edit funloc request), 
                    enhance code coverage
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    May 30 2016
@Description:      1606 Release - SIR 292, [IMO]Divide CACC "Industry Segment" to "CBG" and "SUB-CBG", 
           SAP_CMD__c.Industry_Sub_Segment__c is going to be formula field
-------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Aug 31, 2016 
@Description:        1609 Release SIR 1102 & 990 & 1138 - commented/uncommented the code to change CMD Request's field data-type.
---------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      Apr 26, 2017 
@Description:        SFDC-430 - Replace GSM COntroller Approver Group picklist to new multiselect picklist Controller Approver Group
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      27 Jun 2017
@Description:        1707 Release (SFDC 585) -  To test new fields 'Version ID for internationla addresses' & 'Tax Number 5' for MSO China project
                     Improved code coverage from 93% - 98%
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      17 Jul 2017 
@Description:        1708 Release (SFDC 684) - SAP CMD - BillCurrency-PY should be on SAP CMD layout
***************************************************************************************************************************/
@isTest
public class Convert_Request_to_SAP_CMD_Test {
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
    private static final String TYPE_ZA_ZS = 'ZA_ZS';// obj: Partner Function
    
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
    private static RecordType ZA_ZS;
      
    private static List<Customer__c> lstCustomer;
    private static Customer__c objCustomer;
    //private static List<Hub_Foundation__C> lstHubFoundation;
    private static Hub_Foundation__c objHubFoundation;
    private static List<SAP_CMD__c> lstSAPCMD;
    private static SAP_CMD__c objSAPCMD;
    private static Account objParentAccount;
    private static Account objChildAccount;
    private static Funloc__c objFunloc;
    private static List<Funloc__c> lstFunloc;
    private static Consolidated_Account_Code__c objCACC;
    private static List<Partner_Function__c> lstPartnerFunction;
    
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
                                 OR (SobjectType = 'Partner_Function__c' and DeveloperName =: TYPE_ZA_ZS))
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
            if(rt.DeveloperName == TYPE_ZA_ZS)
                ZA_ZS = rt; 
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
            Country__c = 'USA',
            Alpha_3_Code__c = 'ARE'
        );

        insert objHubFoundation;
    }
    
    /*
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
    */
    
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
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
             Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett on May 30 2016           Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
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
            Street_1__c = 'Test',Version_ID_for_International_Addresses__c = 'C',Tax_Number_5__c = 'Test Tax Number 5'
        );
        lstSAPCMD.add(objSAPCMD);
        
        //SAP CMD with Z001
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[1].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[1].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c = lstCustomer[0].id,
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
             Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett on May 30 2016           Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
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
        
        //SAP CMD with ZI/Z010
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z010_Intermediate_Consignee.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[2].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[2].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c = lstCustomer[0].id,
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
             Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett on May 30 2016           Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
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
            Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.', City__c = 'Test', Country__c = 'Test', 
            Street_1__c = 'Test'
        );
        lstSAPCMD.add(objSAPCMD);
        
        //SAP CMD with ZI/Z010
        objSAPCMD = new SAP_CMD__c(
            RecordTypeId = Z010_Intermediate_Consignee.Id,
            Legal_Name__c = 'Test SAP CMD - Test Test',
            HUB_Customer__c = lstCustomer[3].Id,
            Status__c = 'Approved and Distributed',
            Funloc__c = lstFunloc[3].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Language__c='M - Traditional Chinese', FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c = lstCustomer[0].id,
            Company_Code__c = 'NL60 - RSO Europe' , Sales_Organisation__c = 'NL60 - RSO Europe',
            Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', Grp_1_Sls_Channel_SP__c='DIS - Distributor',
            Acct_assgmt_group__c='01 - Local 3rd Party', Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Acconting_Clerk__c = 'Test',
            Customer_Factory_Calendar__c = '01 - Customer calendar Germany standard', Cust_pric_proc__c = 'Test', 
            Transportation_Zone__c = 'AE1',
            Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE', Rounding_Rule_SH__c = 'C - Round to Closest',
//Scarlett          Industry_Segment__c = 'AA - Appliances', 
//Scarlett on May 30 2016           Industry_Sub_Segment__c = 'A1 - Major Home Appliances', 
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
            Main_shipping_mark__c = 'NXP MOTOROLA(CHINA)', Additional_shipping_mark__c = 'C/NO.', City__c = 'Test', Country__c = 'Test', 
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
    
    private static void createPartnerFunction(){   
        lstPartnerFunction = new List<Partner_Function__c>();
        //ZA
        Partner_Function__c objPartnerFunctionZA = new Partner_Function__c(
            RecordTypeId = ZA_ZS.Id,
            FunLoc__c = lstFunloc[0].Id,
            Partner_Function_Type__c = 'ZA - Customer Service Rep',
            Person_Name__c = 'Test Person Name -ZA',
            SAP_Customer__c = lstSAPCMD[0].Id
        );
        lstPartnerFunction.add(objPartnerFunctionZA);
        
        //ZS
        Partner_Function__c objPartnerFunctionZS = new Partner_Function__c(
            RecordTypeId = ZA_ZS.Id,
            FunLoc__c = lstFunloc[0].Id,
            Partner_Function_Type__c = 'ZS - Sales Person',
            Person_Name__c = 'Test Person Name - ZS',
            SAP_Customer__c = lstSAPCMD[0].Id
        ); 
        lstPartnerFunction.add(objPartnerFunctionZS);
        
        insert lstPartnerFunction;
    }
    
    //create SAP New Funloc Request
    static testmethod void myUnitTest1(){

        //prepare data
        fetchRecordType();
        createCustomer();
        //createParentAccount();
        createCACC();
        createHubFundation();
        createFunloc();
        createSAPCMD();
        createPartnerFunction();
        
        List<Customer__c> tempLstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(tempLstCustomer.size() > 0);
        List<Hub_Foundation__c> tempLstHubFoundation = [SELECT Id FROM Hub_Foundation__c];
        system.assert(tempLstHubFoundation.size() > 0);
        List<Partner_Function__c> tempPartnerFunction = [SELECT Id FROM Partner_Function__c];
        system.assert(tempPartnerFunction.size() > 0);
        
        Funloc__c tempLstFunloc1 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[0].Id];
        
        test.startTest();
        Datetime dt1 = DateTime.newInstance(2014,01,01,00,00,00);
        Datetime dt2 = DateTime.newInstance(2014,01,31,00,00,00);
        Datetime dt3 = DateTime.newInstance(2014,01,10,00,00,00);
        
        //CMD Request with duplicate SAP CMD
        CMD_Request__c theRequest = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc1.FunLoc_Number_Text__c,
            //Funloc_SAP_CMD__c = lstSAPCMD[0].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Approval_Submission_Date__c = dt2,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Version_ID_for_International_Addresses__c = 'C'
        );
        insert theRequest;       
        
        theRequest.Request_Status__c = 'Approved';
        theRequest.Approval_Submission_Date__c = dt3;
        update theRequest; 
          
        System.assert(theRequest.Funloc__c != null);
        //system.assert(theRequest.Funloc_SAP_CMD__c != null);
        system.assert(theRequest.Approval_Submission_Date__c != null);
     
        CMD_Request__c theRequest1 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc1.FunLoc_Number_Text__c,
            //Funloc_SAP_CMD__c = lstSAPCMD[0].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,           
            Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_Line_2__c = 'Test',
            Name_Line_3__c = 'Test',
            Name_Line_4__c = 'Test',
            City__c = 'Test',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '115',
            PO_Box__c = '115',
            PO_Box_City__c = 'Test',
            PO_Box_Postal_Code__c = '115',
            Telephone__c = '123456789',
            Fax__c = '123456789',
            Email__c = 'test@test.com',
            VAT_Registration_Number__c = '123455555',
            Taxes_Number_1__c = '1234555555',
           Transportation_Zone__c = '123',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = 'test',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = 'Test',
            Tolerance_Group__c = 'Test',
            Screened_for_SDI__c = 'Yes',
            Controlled_Party__c = 'Yes',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt1,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            //Global_Customer_ID__c = '1234567890',
            Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Additional_VAT_Number_1__c = '123456',
            Additional_VAT_Number_2__c = '123456',  
            Additional_VAT_Number_3__c = '123456',
            Additional_VAT_Number_4__c = '123456',
            Additional_VAT_Number_5__c = '123456',
            Additional_VAT_Number_6__c = '123456',
            Additional_VAT_Number_7__c = '123456',
            Additional_VAT_Number_8__c = '123456',
            Country_Additional_VAT_Number_1__c = 'USA',
            Country_Additional_VAT_Number_2__c = 'USA',
            Country_Additional_VAT_Number_3__c = 'USA',
            Country_Additional_VAT_Number_4__c = 'USA',
            Country_Additional_VAT_Number_5__c = 'USA',
            Country_Additional_VAT_Number_6__c = 'USA',
            Country_Additional_VAT_Number_7__c = 'USA',
            Country_Additional_VAT_Number_8__c = 'USA', 
            Trading_Partner__c = 'Test',
            Global_Account__c = 'Test',
            Military_Usage__c = 'Yes',
            Fix_Price_Ind_SP__c = 'Test',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Acct_at_cust__c = 'Test',
            Currency__c = 'USD',
            Cust_pric_proc__c = 'Test',
            Customer_Statistics_Group__c = 'Test',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = 'Test',
            Region__c = 'Test',
            Reprice_Basis__c = 'Test',
            S_O_Sub_Group__c = 'Test',
            Sales_office__c = 'Test',
            Delivery_priority__c = 'Test',
            Max_partial_deliveries__c = 'Test',
            BillCurrency_PY__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Grp_2_Cus_Prce_Grp_SP__c = 'Test',
            Matl_Det_Grp_SP__c = 'Test',
            Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            CPNJ_for_Brazil__c = 'Test',
            Freight_Forwarder__c = 'Test',
            Main_shipping_mark__c = 'Test',
            Billing_Block__c = 'Test',
            Central_Billing_Block__c = 'Test',
            Central_delivery_block__c = 'Test',
            FunLoc_Type__c = 'Test',
            Central_order_block__c = 'Test',
            Delivery_Block__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination__c = 'Yes',
            Distribution_Region__c = 'Test',
            Sales_district__c = 'Test',
            Partial_delivery_per_item__c = 'Test',
            Reconciliation_Account__c = 'Test',
            Fixed_Currency_Ind_SP__c = 'Yes',
            Non_I2_related_SP__c = 'Yes',
            Sales_Area_Region__c = 'Yes',
            Accept_Dupl_PO_SP__c  = 'Yes',
            Ch_dupl_PO_item_SP__c = 'Yes',
            Customer_Factory_Calendar__c = 'Test',
            Unloading_Point__c = 'test',
            Delivery_Group_Ind_SH__c = 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            C_GAD_Indicator_SH__c = 'Yes',
            Shipping_Condition__c  = 'Test',
            Incoterms_1__c = 'test',
            Incoterms_2__c = 'test',
            Label_Required__c = 'No',
            Company_Code__c = 'test',
            Sorting_key_for_assignment_no__c = 'Test',
            Indicator_Record_Payment_History__c = 'yes',
            Lockbox__c  = 'test',
            Payment_Credit_Memo__c = 'Test',
            Reason_Code_Conversion__c = 'Test',
            Selection_Rule_for_Payment_Advice__c = 'Test',
            Terms_of_Payment__c = 'Test',
            
            Account_memo__c = 'test',
            Accounting_Clerk__c = 'Test',
            Act_clerk_fax_number__c = '+886281709999',
            Act_clerk_internet_address__c = 'Test',
            Act_clerk_tel_no__c = '+886281709999',
            User_at_customer__c = 'Test',
            Acct_assgmt_group__c = 'Test',
            Payment_Guarantee_Procedure__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Our_account_at_customer__c = 'Test',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Customer_Service_ZA__c = 'Test ZA',
            Sales_Rep_ZS__c = 'Test ZS',
            Version_ID_for_International_Addresses__c = 'M',
            Tax_Number_5__c = 'Test Tax 5'
        );
        insert theRequest1;       
        
        theRequest1.Request_Status__c = 'Approved';
        update theRequest1;
        
        system.assert(theRequest1.FLAG_Sold_to__c == true);  
        system.assert(theRequest1.FLAG_Ship_to__c == true);   
        //system.assert(theRequest1.FLAG_Payer__c == true); 
        system.assert(theRequest1.FLAG_Bill_to__c == true); 
        system.assert(theRequest1.Global_Customer_ID__c != null);
        
        ////Request 2 with negative value
        Funloc__c tempLstFunloc2 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[1].Id];
        
        CMD_Request__c theRequest2 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc2.FunLoc_Number_Text__c,
            Funloc_SAP_CMD__c = lstSAPCMD[1].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,        
            Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_Line_2__c = 'Test',
            Name_Line_3__c = 'Test',
            Name_Line_4__c = 'Test',
            City__c = 'Test',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '115',
            PO_Box__c = '115',
            PO_Box_City__c = 'Test',
            PO_Box_Postal_Code__c = '115',
            Telephone__c = '123456789',
            Fax__c = '123456789',
            Email__c = 'test@test.com',
            VAT_Registration_Number__c = '123455555',
            Taxes_Number_1__c = '1234555555',
            Transportation_Zone__c = '123',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = 'test',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = 'Test',
            Tolerance_Group__c = 'Test',
            Screened_for_SDI__c = 'No',
            Controlled_Party__c = 'No',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt2,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            Name_1_Service_Provider__c ='Test',
            Customer_Type__c = 'Service Provider',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Additional_VAT_Number_1__c = '123456',
            Additional_VAT_Number_2__c = '123456',  
            Additional_VAT_Number_3__c = '123456',
            Additional_VAT_Number_4__c = '123456',
            Additional_VAT_Number_5__c = '123456',
            Additional_VAT_Number_6__c = '123456',
            Additional_VAT_Number_7__c = '123456',
            Additional_VAT_Number_8__c = '123456',
            Country_Additional_VAT_Number_1__c = 'USA',
            Country_Additional_VAT_Number_2__c = 'USA',
            Country_Additional_VAT_Number_3__c = 'USA',
            Country_Additional_VAT_Number_4__c = 'USA',
            Country_Additional_VAT_Number_5__c = 'USA',
            Country_Additional_VAT_Number_6__c = 'USA',
            Country_Additional_VAT_Number_7__c = 'USA',
            Country_Additional_VAT_Number_8__c = 'USA',
            Trading_Partner__c = 'Test',
            Global_Account__c = 'Test',
            Military_Usage__c = 'Yes',
            Fix_Price_Ind_SP__c = 'Test',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Acct_at_cust__c = 'Test',
            Currency__c = 'USD',
            Cust_pric_proc__c = 'Test',
            Customer_Statistics_Group__c = 'Test',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = 'Test',
            Region__c = 'Test',
            Reprice_Basis__c = 'Test',
            S_O_Sub_Group__c = 'Test',
            Sales_office__c = 'Test',
            Delivery_priority__c = 'Test',
            Max_partial_deliveries__c = 'Test',
            BillCurrency_PY__c = 'Set to BLANK',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Grp_2_Cus_Prce_Grp_SP__c = 'Set to BLANK',
            Matl_Det_Grp_SP__c = 'Set to Blank',
            Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            CPNJ_for_Brazil__c = 'Test',
            Freight_Forwarder__c = 'Test',
            Main_shipping_mark__c = 'Test',
            Billing_Block__c = 'Test',
            Central_Billing_Block__c = 'Test',
            Central_delivery_block__c = 'Test',
            FunLoc_Type__c = 'Test',
            Central_order_block__c = 'Test',
            Delivery_Block__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination__c = 'No',
            Distribution_Region__c = 'Test',
            Sales_district__c = 'Test',
            Partial_delivery_per_item__c = 'Set to BLANK',
            Reconciliation_Account__c = 'Test',
            Fixed_Currency_Ind_SP__c = 'No',
            Non_I2_related_SP__c = 'No',
            Sales_Area_Region__c = 'Yes',
            Accept_Dupl_PO_SP__c = 'No',
            Ch_dupl_PO_item_SP__c = 'No',
            Delivery_Group_Ind_SH__c = 'Set to BLANK',
            C_GAD_Indicator_SH__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Posting_Block_Company_Code__c = 'Yes',
            Key_for_Payment_Grouping__c = 'Test',
            Customer_Service_ZA__c = 'Test ZA',
            Sales_Rep_ZS__c = 'Test ZS',
            Label_Required__c = 'Yes',
            Label_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'C'
        );
        insert theRequest2;       
        
        theRequest2.Request_Status__c = 'Approved';
        update theRequest2;   
        
        system.assert(theRequest2.Funloc__c != null);
        system.assert(theRequest2.Funloc_SAP_CMD__c != null);
        system.assert(theRequest2.FLAG_Sold_to__c == true);  
        system.assert(theRequest2.FLAG_Ship_to__c == true);   
        //system.assert(theRequest2.FLAG_Payer__c == true); 
        system.assert(theRequest2.FLAG_Bill_to__c == true); 
        
        //CMD Request with ZI
        Funloc__c tempLstFunloc3 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[2].Id];
        
        CMD_Request__c theRequest3 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc3.FunLoc_Number_Text__c,
            Funloc_SAP_CMD__c = lstSAPCMD[2].Id,
            Global_Customer_ID__c = lstCustomer[0].Id,  
            Consolidated_Account_Code__c = objCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_Line_2__c = 'Test',
            Name_Line_3__c = 'Test',
            Name_Line_4__c = 'Test',
            City__c = 'Test',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '115',
            PO_Box__c = '115',
            PO_Box_City__c = 'Test',
            PO_Box_Postal_Code__c = '115',
            Telephone__c = '123456789',
            Fax__c = '123456789',
            Email__c = 'test@test.com',
            VAT_Registration_Number__c = '123455555',
            Taxes_Number_1__c = '1234555555',
            Transportation_Zone__c = '1234',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = 'test',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = 'Test',
            Tolerance_Group__c = 'Test',
            Screened_for_SDI__c = 'Yes',
            Controlled_Party__c = 'Yes',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt2,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            //Global_Customer_ID__c = '1234567890',
            //Name_1_Service_Provider__c ='Test',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Additional_VAT_Number_1__c = '123456',
            Additional_VAT_Number_2__c = '123456',  
            Additional_VAT_Number_3__c = '123456',
            Additional_VAT_Number_4__c = '123456',
            Additional_VAT_Number_5__c = '123456',
            Additional_VAT_Number_6__c = '123456',
            Additional_VAT_Number_7__c = '123456',
            Additional_VAT_Number_8__c = '123456',
            Country_Additional_VAT_Number_1__c = 'USA',
            Country_Additional_VAT_Number_2__c = 'USA',
            Country_Additional_VAT_Number_3__c = 'USA',
            Country_Additional_VAT_Number_4__c = 'USA',
            Country_Additional_VAT_Number_5__c = 'USA',
            Country_Additional_VAT_Number_6__c = 'USA',
            Country_Additional_VAT_Number_7__c = 'USA',
            Country_Additional_VAT_Number_8__c = 'USA',
            Trading_Partner__c = 'Test',
            Global_Account__c = 'Test',
            Military_Usage__c = 'Yes',
            Fix_Price_Ind_SP__c = 'Test',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Acct_at_cust__c = 'Test',
            Currency__c = 'USD',
            Cust_pric_proc__c = 'Test',
            Customer_Statistics_Group__c = 'Test',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = 'Test',
            Region__c = 'Test',
            Reprice_Basis__c = 'Test',
            S_O_Sub_Group__c = 'Test',
            Sales_office__c = 'Test',
            Delivery_priority__c = 'Test',
            Max_partial_deliveries__c = 'Test',
            BillCurrency_PY__c = 'Set to BLANK',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Grp_2_Cus_Prce_Grp_SP__c = 'Set to BLANK',
            Matl_Det_Grp_SP__c = 'Test',
            Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            CPNJ_for_Brazil__c = 'Test',
            Freight_Forwarder__c = 'Test',
            Main_shipping_mark__c = 'Test',
            Billing_Block__c = 'Test',
            Central_Billing_Block__c = 'Test',
            Central_delivery_block__c = 'Test',
            FunLoc_Type__c = 'Test',
            Central_order_block__c = 'Test',
            Delivery_Block__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination__c = 'No',
            Distribution_Region__c = 'Test',
            Sales_district__c = 'Test',
            Partial_delivery_per_item__c = 'Set to BLANK',
            Reconciliation_Account__c = 'Test',
            Fixed_Currency_Ind_SP__c = 'No',
            Non_I2_related_SP__c = 'No',
            Sales_Area_Region__c = 'Yes',
            Accept_Dupl_PO_SP__c = 'No',
            Ch_dupl_PO_item_SP__c = 'No',
            Delivery_Group_Ind_SH__c = 'Set to BLANK',
            C_GAD_Indicator_SH__c = 'No',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Indicator_Record_Payment_History__c = 'No',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Label_Required__c = 'No',
            Posting_Block_Company_Code__c = 'Yes',
            Key_for_Payment_Grouping__c = 'Test',
            Version_ID_for_International_Addresses__c = 'M',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert theRequest3;       
        
        theRequest3.Request_Status__c = 'Approved';
        update theRequest3;   
        
        system.assert(theRequest3.Funloc__c != null);
        system.assert(theRequest3.Funloc_SAP_CMD__c != null);
        system.assert(theRequest3.FLAG_ZI__c = true);
        
        //CMD Request with ZI - negative value
        Funloc__c tempLstFunloc4 = [SELECT Id, Funloc_Number_Text__c FROM Funloc__c WHERE Id =: lstFunloc[3].Id];
        
        CMD_Request__c theRequest4 = new CMD_Request__c(
            RecordTypeId = SAP_Funloc_Edit_Request.Id,
            Funloc__c = tempLstFunloc4.FunLoc_Number_Text__c,
            Funloc_SAP_CMD__c = lstSAPCMD[3].Id,
            Consolidated_Account_Code__c = objCACC.Id,
            Global_Customer_ID__c = lstCustomer[0].Id,   
            Ready_to_Submit__c = true,
            Request_Status__c = 'draft',
            Reason_for_request__c = 'Test',
            Sales_Organisation__c = 'NL60 - RSO Europe',
            GCP_Q_Approver_Group__c = 'AMEC Disti',
            //GSM_Controller_Approver_Group__c = 'JAPAN',  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'JP - Japan', //added by Nisha Agrawal on Apr 26 for SFDC-430 
            Role__c = 'OEM' ,
            Name_Legal_Name__c = 'Test Convert 1',
            Name_Line_2__c = 'Test',
            Name_Line_3__c = 'Test',
            Name_Line_4__c = 'Test',
            City__c = 'Test',
            Country__c = 'USA',
            State_Province__c = 'Indiana',
            Postal_Code__c = '115',
            PO_Box__c = '115',
            PO_Box_City__c = 'Test',
            PO_Box_Postal_Code__c = '115',
            Telephone__c = '123456789',
            Fax__c = '123456789',
            Email__c = 'test@test.com',
            VAT_Registration_Number__c = '123455555',
            Taxes_Number_1__c = '1234555555',
            Transportation_Zone__c = '123',
            Language__c = 'M - Traditional Chinese',
            Chinese_Name1__c = 'test',
            Street__c = 'Test',
            Street_4__c = 'test',
            Ind_period_account_statement__c = 'Test',
            Tolerance_Group__c = 'Test',
            Screened_for_SDI__c = 'No',
            Controlled_Party__c = 'No',
            FLAG_Bill_to__c = True,
            FLAG_Sold_to__c = True,
            FLAG_Ship_to__c = True,
            Street_House_Number__c = 'Test 1',
            Approval_Submission_Date__c = dt2,
            Effective_Date__c = null,
            Update_SAP_CMD_Failed__c = false,
            //Global_Customer_ID__c = '1234567890',
            //Name_1_Service_Provider__c ='Test',
            City_Chinese__c = 'Test',
            Chinese_Name2__c = 'Test',
            Chinese_Street__c = 'Test',
            Additional_VAT_Number_1__c = '123456',
            Additional_VAT_Number_2__c = '123456',  
            Additional_VAT_Number_3__c = '123456',
            Additional_VAT_Number_4__c = '123456',
            Additional_VAT_Number_5__c = '123456',
            Additional_VAT_Number_6__c = '123456',
            Additional_VAT_Number_7__c = '123456',
            Additional_VAT_Number_8__c = '123456',
            Country_Additional_VAT_Number_1__c = 'USA',
            Country_Additional_VAT_Number_2__c = 'USA',
            Country_Additional_VAT_Number_3__c = 'USA',
            Country_Additional_VAT_Number_4__c = 'USA',
            Country_Additional_VAT_Number_5__c = 'USA',
            Country_Additional_VAT_Number_6__c = 'USA',
            Country_Additional_VAT_Number_7__c = 'USA',
            Country_Additional_VAT_Number_8__c = 'USA',
            Trading_Partner__c = 'Test',
            Global_Account__c = 'Test',
            Military_Usage__c = 'Yes',
            Fix_Price_Ind_SP__c = 'Test',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Acct_at_cust__c = 'Test',
            Currency__c = 'USD',
            Cust_pric_proc__c = 'Test',
            Customer_Statistics_Group__c = 'Test',
            Distribution_Channel__c = 'Test',
            Division__c = 'Test',
            Exch_rate_type__c = 'Test',
            Region__c = 'Test',
            Reprice_Basis__c = 'Test',
            S_O_Sub_Group__c = 'Test',
            Sales_office__c = 'Test',
            Delivery_priority__c = 'Test',
            Max_partial_deliveries__c = 'Test',
            BillCurrency_PY__c = 'Set to BLANK',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Grp_2_Cus_Prce_Grp_SP__c = 'Set to BLANK',
            Matl_Det_Grp_SP__c = 'Test',
            Additional_shipping_mark__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            CPNJ_for_Brazil__c = 'Test',
            Freight_Forwarder__c = 'Test',
            Main_shipping_mark__c = 'Test',
            Billing_Block__c = 'Test',
            Central_Billing_Block__c = 'Test',
            Central_delivery_block__c = 'Test',
            FunLoc_Type__c = 'Test',
            Central_order_block__c = 'Test',
            Delivery_Block__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination__c = 'No',
            Distribution_Region__c = 'Test',
            Sales_district__c = 'Test',
            Partial_delivery_per_item__c = 'Set to BLANK',
            Reconciliation_Account__c = 'Test',
            Fixed_Currency_Ind_SP__c = 'No',
            Non_I2_related_SP__c = 'No',
            Sales_Area_Region__c = 'Yes',
            Accept_Dupl_PO_SP__c = 'No',
            Ch_dupl_PO_item_SP__c = 'No',
            Delivery_Group_Ind_SH__c = 'Set to BLANK',
            C_GAD_Indicator_SH__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            
            Posting_Block_Company_Code__c = 'Yes',
            Key_for_Payment_Grouping__c = 'Test',
            Version_ID_for_International_Addresses__c = 'M'
        );
        insert theRequest4;       
        
        theRequest4.Request_Status__c = 'Approved';
        update theRequest4;   
        
        system.assert(theRequest4.Funloc__c != null);
        system.assert(theRequest4.Funloc_SAP_CMD__c != null);
        system.assert(theRequest4.FLAG_ZI__c = true);
        
        Convert_Request_to_SAP_CMD convertRequests = new Convert_Request_to_SAP_CMD();

        test.stopTest();
    }
}