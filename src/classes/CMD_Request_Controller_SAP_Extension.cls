/********************************************************************************************************************************************************************
@Modified By :       Scarlett Kang
@Modified Date:      29 Nov 2014
@Description:        More fields copy to SAP CMD
-------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date :     09 March 2015  
@Description :       1. Account groups Z010 (ZI), Z004 (Bill-to) are not required for Tax Classification setting in SAP
                     2. Sales_Area_Region__c should be copied to SAP CMD, mapping field is SAP_CMD__c.Region__c
-------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      20 Mar 2015
@Description:        Change the field type of SAP_CMD__c.Industry_Segment__c to formula and not copy CMD_Request__c.Industry_Segment__c to SAP CMD Object
                     Change mapping field: CMD_Request__c.Sales_Area_Region__c -> SAP_CMD__c.Region__c
-------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      12 Jun 2015
@Description:        Copy Accounting Clerk & Account Assignment Group for Z003, and not copy Industry_Sub_Segment__c for all account groups
---------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      04 Aug 2015
@Description:       1508 Release. Copy Label Code to SAP CMD based on the value of Label Code Required
----------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      12 Feb 2016
@Description:        1603 Release (SIR 499) - Copy ZA/ZS as partner functions to related SAP CMD based on the New CMD Request form.
*******************************************************************************************************************************************************************
----------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      29 Feb 2016
@Description:        1603 Release (SIR 732) - Code optimization for the multiple If block conditions based on the Account Group on the New CMD Request form.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By:        Scarlett Kang
@Modified Date:      23 Mar 2016
@Description:        1604 Release SIR 706
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Shridevi   
@Modified Date:      April 20, 2016 
@Description:        1605 Release (SIR 534) - To copy the value of the field  No_of_days_for_Early_Shipment__c from cmd Request to SAP cmd for Z001,Z002,Z012 Account groups.
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By:        Scarlett Kang
@Modified Date:      29 Sep 2016
@Description:        1610 Release SIR 1265 - Test Class failed
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      14 Mar 2017
@Description:        1704 Release (SFDC 327) - Remove Nexperia sales org. ( MY61, PH62 & CN61) from SAP CMD Request picklist
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      17 Apr 2017
@Description:        1705 Release (SFDC 428) -  To link multiple ZORG SAP CMDs to CMD Request.
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      26 Apr 2017
@Description:        1705 Release (SFDC 467) -  To generate ZORG SAP CMDs based on rule provided.
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      21 Jun 2017
@Description:        1707 Release (SFDC 585) -  To add new fields 'Version ID for internationla addresses' & 'Tax Number 5' for MSO China project
                     1707 Release (SFDC 455) -  To generate ZORG SAP CMDs based on rule provided for new sales org CN60.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      17 Jul 2017 
@Description:        1708 Release (SFDC 684) - SAP CMD - BillCurrency-PY should be on SAP CMD layout
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji/Venkatesh
@Modified Date:      31 Aug 2017 
@Description:        1709 Release (SFDC 729) - To update CMD Request record type into new field: 'CMD Request Type' on SAP CMD as we need to exclude few validations on SAP CMD for MANU/SBE funloc.
                                               - To set Credit control area on SAP CMD to 'NL60' for Non-MANU funloc requests.
                                               - To carry the data for [UNLOADING POINT] for account group Z012 from CMD Request -> SAP CMD.
*******************************************************************************************************************************************************************/
public class CMD_Request_Controller_SAP_Extension {
    
    public CMD_Request__c theRequest;
//    private Customer__c theHubCustomer;
    public SAP_CMD__c theCMD;  //public for the test class
    public string theAccountGroup;  //public for the test class
    public string thePartnerFunction;  //public for the test class
    //private static List<Tax_Classification__c> lstNewTaxClassification;
    //private static List<Tax_Classification__c> lstTaxClassification;
    //private static Tax_Classification__c newTax;
    public List<Tax_Classification__c> lstTaxClassification{get; set;}
    public List<Tax_Classification__c> lstNewTaxClassification{get; set;}
    public List<Sales_Organisation_ZORG__c> lstZORGSalesOrgs;//1604 Release SIR 706 - Added by Scarlett
    public List<SAP_CMD__c> lstNewZORGSAPCMD;//1604 Release SR 706 - Added by Scarlett
    public SAP_CMD__c newZORG;//1604 Release SR 706 - Added by Scarlett
    public SAP_CMD__c ZORGSAPCMD;//1604 Release SR 706 - Added by Scarlett
    public List<Tax_Classification__c> lstZORGTaxClassification;//1604 Release SR 706 - Added by Scarlett
    
    private Static Final string TYPE_New_MANU_CmdReq='SAP_New_MANU_Funloc_request';// obj: CMD Request
    private Static Final string TYPE_Edit_MANU_CmdReq='SAP_MANU_Funloc_Edit_request';// obj: CMD Request
    private Static Final string TYPE_New_SBE_CmdReq='SAP_New_SBE_Funloc_request';
    private Static Final string TYPE_Edit_SBE_CmdReq='SAP_SBE_Funloc_Edit_request';
    private static final String Z001_RECORD_TYPE = 'Z001_SoldTo_ShipTo_BillTo_Payer';
    private static final string Z002_RECORD_TYPE = 'Z002_Ship_To';
    private static final string Z003_RECORD_TYPE = 'Z003_Payer';
    private static final string Z004_RECORD_TYPE = 'Z004_Bill_To';
    private static final string Z005_RECORD_TYPE = 'Z005_SoldTo_BillTo_Payer';
    private static final string Z010_RECORD_TYPE = 'Z010_Intermediate_Consignee';
    private static final string Z011_RECORD_TYPE = 'Z011_Sold_To';
    private static final string Z012_RECORD_TYPE = 'Z012_Sold_to_Ship_To';
    private static final string Z013_RECORD_TYPE = 'Z013_Payer_Bill_To';
    private static final string ZORG_RECORD_TYPE = 'ZORG_Organizational_Customers';
    private static final string ZOTHERS_RECORD_TYPE = 'ZOthers_Non_Commercial_Entities';
    private static final string ZA_ZS_RECORD_TYPE = 'ZA_ZS';
    private static final string RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE = 'RE_RG_WE_AG_ZC_ZD_ZI';//1604 Release SR 706 - Added by Scarlett
    private static final string Partner_Function_Type_ZA = 'ZA - Customer Service Rep';
    private static final string Partner_Function_Type_ZS = 'ZS - Sales Person';
    private static final string Partner_Function_Type_ZC = 'ZC - CSW: SP of end-customer';//1604 Release SR 706 - Added by Scarlett
    private static final string Partner_Function_Type_ZD = 'ZD - CSW: SH of end-customer';//1604 Release SR 706 - Added by Scarlett
    private static final string Partner_Function_Type_SP = 'WE - ShipTo Party';//1604 Release SR 706 - Added by Scarlett
    private static final string Partner_Function_Type_SH = 'AG - SoldTo Party';//1604 Release SR 706 - Added by Scarlett
    private static final String SALES_ORG_NL60 = 'NL60 - RSO Europe';
    private static final String SALES_ORG_US60 = 'US60 - RSO U.S.A.';
    private static final String SALES_ORG_JP60 = 'JP60 - MSO Japan';
    private static final String SALES_ORG_CN60 = 'CN60 - MSO China CN60';
    Public Static Id Z001_RECORD_TYPE_ID;
    Public Static Id Z002_RECORD_TYPE_ID;
    Public Static Id Z003_RECORD_TYPE_ID;
    Public Static Id Z004_RECORD_TYPE_ID;
    Public Static Id Z005_RECORD_TYPE_ID;
    Public Static Id Z010_RECORD_TYPE_ID;
    Public Static Id Z011_RECORD_TYPE_ID;
    Public Static Id Z012_RECORD_TYPE_ID;
    Public Static Id Z013_RECORD_TYPE_ID;
    Public Static Id ZORG_RECORD_TYPE_ID;
    Public Static Id ZOthers_RECORD_TYPE_ID;
    Public Static Id ZA_ZS_RECORD_TYPE_ID;
    public static Id RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID;//1604 Release SR 706 - Added by Scarlett
    public static Id SAP_New_MANU_Funloc_request_ID;
    public static Id SAP_MANU_Funloc_Edit_request_ID;
    public static Id SAP_New_SBE_Funloc_request_ID;
    public static Id SAP_SBE_Funloc_Edit_request_ID;
   
       
    public CMD_Request_Controller_SAP_Extension( ApexPages.StandardController stdController ) {
        theAccountGroup = ApexPages.currentPage().getParameters().get('ag');
        thePartnerFunction = ApexPages.currentPage().getParameters().get('pf');

        this.theRequest = (CMD_Request__c)stdController.getRecord();
        theRequest = [
            SELECT  Id,
                    Consolidated_Account_Code__c,
//                    SAP_Request_Type__c,
                    Accept_Dupl_PO_SP__c, 
//                    Acct_assgmt_group__c,
                    Acct_at_cust__c,
                    Account_Group__c,
                    BillCurrency_PY__c,
                    BP__c,
                    BP_GID__c,
                    BP_Same_as_SP__c,
                    BP_Same_as_PY__c,
                    BP_CustomerID__c,
                    BP_Funloc__c,
                    BP_Funloc_Id__c,
                    BP_Name__c,
                    BP_Street__c,
                    BP_City__c,
                    BP_State__c,
                    BP_Country__c,
                    BP_Postal_Code__c,
                    BP_Telephone__c,
                    BP_Fax__c,
                    BP_Email__c,
                    C_GAD_Indicator_SH__c,
                    Ch_dupl_PO_item_SP__c,
                    Con_Acct_SP_EMS__c,
                    Company_Code__c,
//                    Controlled_Party__c,
                    Controlled_Party__c, //Scarlett
                    Currency__c,
                    Cust_pric_proc__c,
                    Customer_Factory_Calendar__c,
//                    Customer_Statistics_Group__c,
                    Delivery_Group_Ind_SH__c,
                    Delivery_priority__c,
//                    Distribution_Channel__c,
//                    Distribution_Region__c,
                    Exch_rate_type__c,
                    Fixed_Currency_Ind_SP__c,
                    Fix_Price_Ind_SP__c,
                    Global_Account__c,
                    Grp_1_Sls_Channel_SP__c,
                    Grp_2_Cus_Prce_Grp_SP__c,
                    Incoterms_1__c,
                    Incoterms_2__c,
//                    Ind_period_account_statement__c,
                    Industry_Segment__c,
                    Industry_Sub_Segment__c,
                    Lockbox__c,
                    Matl_Det_Grp_SP__c,
                    Max_partial_deliveries__c,
                    Military_Usage__c,
                    Non_I2_related_SP__c,
                    Order_combination__c,
                    Partial_delivery_per_item__c,
                    Payment_Credit_Memo__c,
                    PD_Key_Account__c,
                    Pull_Up_OK_SH__c,
                    PY__c,
                    PY_Same_as_SP__c,
                    PY_GID__c,
                    PY_CustomerID__c,
                    PY_Funloc__c,
                    PY_Funloc_Id__c,
                    PY_Name__c,
                    PY_Street__c,
                    PY_City__c,
                    PY_State__c,
                    PY_Country__c,
                    PY_Postal_Code__c,
                    PY_Telephone__c,
                    PY_Fax__c,
                    PY_Email__c,
//                    Reason_Code_Conversion__c,
//                    Reconciliation_Account__c,
                    Reprice_Basis__c,
                    Rounding_Rule_SH__c,
                    S_O_Sub_Group__c,
                    Sales_Office__c,
                    Sales_Organisation__c,
//                    Selection_Rule_for_Payment_Advice__c,
//                    Sorting_key_for_assignment_no__c,
                    SH__c,
                    SH_Same_as_SP__c,
                    SH_GID__c,
                    SH_CustomerID__c,
                    SH_Funloc__c,
                    SH_Funloc_Id__c,
                    SH_Name__c,
                    SH_Street__c,
                    SH_City__c,
                    SH_State__c,
                    SH_Country__c,
                    SH_Postal_Code__c,
                    SH_Telephone__c,
                    SH_Fax__c,
                    SH_Email__c,
                    SP__c,
                    SP_GID__c,
                    SP_CustomerID__c,
                    SP_Funloc__c,
                    SP_Funloc_Id__c,
                    SP_Name__c,
                    SP_Street__c,
                    SP_City__c,
                    SP_State__c,
                    SP_Country__c,
                    SP_Postal_Code__c,
                    SP_Telephone__c,
                    SP_Fax__c,
                    SP_Email__c,
                    Terms_of_payment__c,
                    Terms_of_Payment_Sales__c,
                    Transportation_Zone__c,
                    Taxes_Number_1__c,
                    VAT_Registration_Number__c,
                    ZI__c,
                    ZI_GID__c,
                    ZI_CustomerID__c,
                    ZI_Funloc__c,
                    ZI_Funloc_Id__c,
                    ZI_Name__c,
                    ZI_Street__c,
                    ZI_City__c,
                    ZI_State__c,
                    ZI_Country__c,
                    ZI_Postal_Code__c,
                    ZI_Telephone__c,
                    ZI_Fax__c,
                    Region__c,
                    Label_Code__c,
                    Label_Required__c,
                    Account_memo__c,
                    Accounting_Clerk__c,
                    Acct_assgmt_group__c,
                    Act_clerk_fax_number__c,
                    Act_clerk_internet_address__c,
                    Act_clerk_tel_no__c,
                    Additional_Shipping_Mark__c,
                    Additional_VAT_Number_1__c,
                    Additional_VAT_Number_2__c,
                    Additional_VAT_Number_3__c,
                    Additional_VAT_Number_4__c,
                    Additional_VAT_Number_5__c,
                    Additional_VAT_Number_6__c,
                    Additional_VAT_Number_7__c,
                    Additional_VAT_Number_8__c,
                    Billing_Block__c,
                    Central_deletion_block__c,
                    Central_Deletion_Flag__c,
                    Central_delivery_block__c,
                    Central_Order_Block__c,
                    Central_posting_block__c,
                    Chinese_Name1__c,
                    Chinese_Name2__c,
                    Chinese_Street__c,
                    City_Chinese__c,
                    Version_ID_for_International_Addresses__c,
                    Tax_Number_5__c,
                    Country_Additional_VAT_Number_1__c,
                    Country_Additional_VAT_Number_2__c,
                    Country_Additional_VAT_Number_3__c,
                    Country_Additional_VAT_Number_4__c,
                    Country_Additional_VAT_Number_5__c,
                    Country_Additional_VAT_Number_6__c,
                    Country_Additional_VAT_Number_7__c,
                    Country_Additional_VAT_Number_8__c,
                    Customer_Statistics_Group__c,
                    Deletion_Block_Company_Code__c,
                    Deletion_Flag_Company_Code__c,
                    Deletion_Flag_Sales_Area__c,
                    Delivery_Block__c,
                    Distribution_Channel__c,
                    Distribution_Region__c,
                    Division__c,
                    Freight_Forwarder__c,
                    FunLoc_Type__c,
                    Global_Customer_ID__c,
                    Ind_period_account_statement__c,
                    Indicator_Record_Payment_History__c,
                    Key_for_Payment_Grouping__c,
                    Language__c,
                    Name_1_Service_Provider__c,
                    Order_Block__c,
                    Our_account_at_customer__c,
                    Payment_Guarantee_Procedure__c,
                    Posting_Block_Company_Code__c,
                    Reason_Code_Conversion__c,
                    Reconciliation_Account__c,
//                    Region__c,
                    Sales_district__c,
//                    Sales_office__c,
                    Screened_for_SDI__c,
                    Selection_Rule_for_Payment_Advice__c,
                    Shipping_Condition__c,
                    Sorting_key_for_assignment_no__c,
//                    Taxes_Number_1__c,
//                    Terms_of_Payment__c,
                    Tolerance_Group__c,
                    Trading_Partner__c,
                    Unloading_Point__c,
                    User_at_customer__c,
                    Central_Billing_Block__c,
                    Main_shipping_mark__c,
                    CPNJ_for_Brazil__c,
                    Brazil_Specific_Clause__c,
                    SP_Name_Line_2__c,
                    SP_Name_Line_3__c,
                    SP_Name_Line_4__c,
                    SP_PO_Box__c,
                    SP_PO_Box_City__c,
                    SP_PO_Box_Postal_Code__c,
                    SH_Name_Line_2__c,
                    SH_Name_Line_3__c,
                    SH_Name_Line_4__c,
                    PY_Name_Line_2__c,
                    PY_Name_Line_3__c,
                    PY_Name_Line_4__c,
                    PY_PO_Box__c,
                    PY_PO_Box_City__c,
                    PY_PO_Box_Postal_Code__c,
                    BP_Name_Line_2__c,
                    BP_Name_Line_3__c,
                    BP_Name_Line_4__c,
                    BP_PO_Box__c,
                    BP_PO_Box_City__c,
                    BP_PO_Box_Postal_Code__c,
                    ZI_Name_Line_2__c,
                    ZI_Name_Line_3__c,
                    ZI_Name_Line_4__c,
                    Sales_Area_Region__c,
                    Customer_Service_ZA__c,
                    Sales_Rep_ZS__c,
                    ZORG_same_as_SH__c,//1604 Release SIR 706 - Added by Scarlett
                    ZORG_City__c,
                    ZORG_Country__c,
                    ZORG_Email__c,
                    ZORG_Name__c,
                    ZORG_Name_Line_2__c,
                    ZORG_Name_Line_3__c,
                    ZORG_Name_Line_4__c,
                    ZORG_State__c,
                    ZORG_Street__c,
                    ZORG_Telephone__c,
                    ZORG_Postal_Code__c,
                    Incoterms_1_ZORG__c,
                    Incoterms_2_ZORG__c,
                    Transportation_Zone_ZORG__c,
                    Non_I2_related_SP_ZORG__c,
                    Order_Combination_ZORG__c,
                    Customer_Pricing_Procedure_ZORG__c,
            /**** SIR 534 - Modified By Shridevi************/
                    No_of_days_for_Early_Shipment__c,
            /*****SIR 534 - Modified By Shridevi -END*******/
                    RecordTypeId,
                    RecordType.name
            FROM    CMD_Request__c
            WHERE   Id = :theRequest.Id
        ];
/*        
        if( theRequest.SP_CustomerID__c != null || theRequest.SP_CustomerID__c != '' ){
            theHubCustomer = [
                SELECT  Id,
                        Legal_Name__c
                FROM    Customer__c
                WHERE   Id = :theRequest.SP_CustomerID__c
                LIMIT 1
            ];
        }
*/    
    }

    public pageReference New_SAP_CMD() {  
    
    For(recordType rt:[Select Id, Name,DeveloperName From RecordType Where IsActive=true 
                        AND(
                        (SobjectType = 'SAP_CMD__c' AND
                        (DeveloperName =:Z001_RECORD_TYPE OR DeveloperName =:Z002_RECORD_TYPE OR 
                        DeveloperName =:Z003_RECORD_TYPE OR DeveloperName =:Z004_RECORD_TYPE OR
                        DeveloperName =:Z005_RECORD_TYPE OR DeveloperName =:Z010_RECORD_TYPE OR
                        DeveloperName =:Z011_RECORD_TYPE OR DeveloperName =:Z012_RECORD_TYPE OR
                        DeveloperName =:Z013_RECORD_TYPE OR DeveloperName =:ZORG_RECORD_TYPE OR
                        DeveloperName =:ZOTHERS_RECORD_TYPE))
                        OR (SobjectType = 'CMD_Request__c' AND 
                        (DeveloperName =: TYPE_New_MANU_CmdReq OR DeveloperName =: TYPE_Edit_MANU_CmdReq OR
                         DeveloperName =: TYPE_New_SBE_CmdReq OR DeveloperName =: TYPE_Edit_SBE_CmdReq)))])
                    
                    
       {
         if(rt.DeveloperName == Z001_RECORD_TYPE) 
            {
               Z001_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == Z002_RECORD_TYPE)
            {
               Z002_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == Z003_RECORD_TYPE)
            {
               Z003_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == Z004_RECORD_TYPE)
            {
               Z004_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == Z005_RECORD_TYPE)
            {
               Z005_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == Z010_RECORD_TYPE)
            {
               Z010_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == Z011_RECORD_TYPE)
            {
               Z011_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == Z012_RECORD_TYPE)
            {
               Z012_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == Z013_RECORD_TYPE)
            {
               Z013_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == ZORG_RECORD_TYPE)
            {
               ZORG_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == ZOthers_RECORD_TYPE)
            {
               ZOthers_RECORD_TYPE_ID = rt.id;  
            }
         else if(rt.DeveloperName == TYPE_New_MANU_CmdReq)
            {
               SAP_New_MANU_Funloc_request_ID = rt.id;  
            }
         else if(rt.DeveloperName == TYPE_Edit_MANU_CmdReq)
            {
               SAP_MANU_Funloc_Edit_request_ID = rt.id;  
            }
         else if(rt.DeveloperName == TYPE_New_SBE_CmdReq)
            {
               SAP_New_SBE_Funloc_request_ID = rt.id;  
            }
         else if(rt.DeveloperName == TYPE_Edit_SBE_CmdReq)
            {
               SAP_SBE_Funloc_Edit_request_ID = rt.id;  
            }
       }
       
         
        theCMD = new SAP_CMD__c(
//        FunLoc__c = 'a1UD0000000QhEjMAK',
            CMD_Request_Id__c = theRequest.Id ,
            CMD_Request_ID_Text__c = theRequest.Id , // for SIR 698: to copy 'title' based on CMD Request Id
            CMD_Request_Type__c = theRequest.RecordType.name,
            // Distribution_Response__c
            // Distributed_at_least_once__c
//            Transportation_Zone__c = theRequest.Transportation_Zone__c ,
            // Language__c = 
            // Trading_Partner__c = 
//            Tax_Number_1__c = theRequest.Taxes_Number_1__c ,
//            VAT_Registration_Number__c = theRequest.VAT_Registration_Number__c ,
//            Global_Account__c = theRequest.Global_Account__c ,
            // Base_Region__c =
//            PD_Key_Account__c = theRequest.PD_Key_Account__c ,
            // Customer_Category__c = theRequest.Customer_Category__c ,
//            Customer_Factory_Calendar__c = theRequest.Customer_Factory_Calendar__c ,
            // Unloading_Point__c = 
            Military_Usage__c = theRequest.Military_Usage__c ,
            // SDI_Screened__c = 
/*            Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : Controlled_Party__c )  
                ),*/
//            Con_Acct_SP_EMS__c = theRequest.Con_Acct_SP_EMS__c ,
//            Rounding_Rule_SH__c = theRequest.Rounding_Rule_SH__c ,
            // Market_Segm_SH__c = theRequest.Industry_Segment__c
            // Sub_Segment_SH__c = theRequest.Industry_Sub_Segment__c ,
//            Fix_Price_Ind_SP__c = theRequest.Fix_Price_Ind_SP__c ,
//            Delivery_Group_Ind_SH__c = theRequest.Delivery_Group_Ind_SH__c ,
//            Pull_Up_OK_SH__c = theRequest.Pull_Up_OK_SH__c ,
//            Company_Code__c = theRequest.Company_Code__c ,
//            Reconciliation_Account__c = theRequest.Reconciliation_Account__c ,
//            Sorting_key_for_assignment_no__c = theRequest.Sorting_key_for_assignment_no__c ,
//            Terms_of_payment__c = theRequest.Terms_of_payment__c ,
//            Payment_Credit_Memo__c = theRequest.Payment_Credit_Memo__c ,
            // Tolerance_Group__c = 
//            Lockbox__c = theRequest.Lockbox__c ,
            // Indicator_Record_Payment_History__c = 
//            Selection_Rule_for_Payment_Advice__c = theRequest.Selection_Rule_for_Payment_Advice__c ,
            // Key_for_Payment_Grouping__c = 
//            Reason_Code_Conversion__c = theRequest.Reason_Code_Conversion__c ,
            // Acconting_Clerk__c = 
            // Act_clerk_tel_no__c = 
            // Act_clerk_fax_number__c = 
            // Act_clerk_internet_address__c =
            //Our_account_at_customer__c = 
            //Account_memo__c =
            //User_at_customer__c = 
//            Ind_period_account_statement__c = theRequest.Ind_period_account_statement__c ,
            Sales_Organisation__c = theRequest.Sales_Organisation__c 
            // Division__c = 
//            Distribution_Channel__c = theRequest.Distribution_Channel__c ,
//            Distribution_Region__c = theRequest.Distribution_Region__c ,
//            Sales_office__c = theRequest.Sales_Office__c ,
//            Currency__c = theRequest.Currency__c ,
            // Sales_district__c = 
//            S_O_Sub_Group__c = theRequest.S_O_Sub_Group__c ,
//            Exch_rate_type__c = theRequest.Exch_rate_type__c ,
//            Reprice_Basis__c = theRequest.Reprice_Basis__c ,
//            Cust_pric_proc__c = theRequest.Cust_pric_proc__c ,
//            Acct_at_cust__c = theRequest.Acct_at_cust__c ,
//            Fixed_Currency_Ind_SP__c = theRequest.Fixed_Currency_Ind_SP__c ,
//            Accept_Dupl_PO_SP__c = theRequest.Accept_Dupl_PO_SP__c ,
//            Non_I2_related_SP__c = theRequest.Non_I2_related_SP__c ,
//            Customer_Statistics_Group__c = theRequest.Customer_Statistics_Group__c ,
//            C_GAD_Indicator_SH__c = theRequest.C_GAD_Indicator_SH__c ,
//            Ch_dupl_PO_item_SP__c = theRequest.Ch_dupl_PO_item_SP__c ,
//            Delivery_priority__c = theRequest.Delivery_priority__c ,
//            Order_combination__c = theRequest.Order_combination__c ,
//            Max_partial_deliveries__c = theRequest.Max_partial_deliveries__c ,
            // Shipping_conditions__c = 
//            Partial_delivery_per_item__c = theRequest.Partial_delivery_per_item__c ,
//            Incoterms_1__c = theRequest.Incoterms_1__c ,
//            Incoterms_2__c = theRequest.Incoterms_2__c ,
            // Paym_guar_proc__c = 
//            Acct_assgmt_group__c = theRequest.Acct_assgmt_group__c ,
            // Cred_contr_area__c = 
//            Terms_of_Payment_Sales__c = theRequest.Terms_of_Payment_Sales__c ,
//            Grp_1_Sls_Channel_SP__c = theRequest.Grp_1_Sls_Channel_SP__c ,
//            Grp_2_Cus_Prce_Grp_SP__c = theRequest.Grp_2_Cus_Prce_Grp_SP__c ,
//            Matl_Det_Grp_SP__c = theRequest.Matl_Det_Grp_SP__c ,
//            BillCurrency_PY__c = theRequest.BillCurrency_PY__c
        );
        
       /******* set the credit control area to 'None' for MANU New/Edit Funloc Request******/
        if(theRequest.RecordTypeId != SAP_New_MANU_Funloc_request_ID && theRequest.RecordTypeId != SAP_MANU_Funloc_Edit_request_ID) { // added as part of SFDC-729 FeedBacks
                theCMD.Cred_contr_area__c = 'NL60 - RSO Europe';
       }
      

//        if( theAccountGroup == 'Z001' || theRequest.Account_Group__c == 'Z001' ){
        if( theAccountGroup == 'Z001' ){
            theCMD.Consolidated_Account_Code__c = theRequest.Consolidated_Account_Code__c;
            theCMD.Transportation_Zone__c = theRequest.Transportation_Zone__c ;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c ;
            theCMD.VAT_Registration_Number__c = theRequest.VAT_Registration_Number__c ;
            theCMD.Global_Account__c = theRequest.Global_Account__c ;
//STAN            theCMD.PD_Key_Account__c = theRequest.PD_Key_Account__c ;
            theCMD.Customer_Factory_Calendar__c = theRequest.Customer_Factory_Calendar__c ;
//STAN            theCMD.Con_Acct_SP_EMS__c = theRequest.Con_Acct_SP_EMS__c ;
            theCMD.Rounding_Rule_SH__c = theRequest.Rounding_Rule_SH__c ;
            theCMD.Fix_Price_Ind_SP__c = theRequest.Fix_Price_Ind_SP__c ;
            theCMD.Delivery_Group_Ind_SH__c = theRequest.Delivery_Group_Ind_SH__c ;
            theCMD.Pull_Up_OK_SH__c = theRequest.Pull_Up_OK_SH__c ;
            theCMD.Company_Code__c = theRequest.Company_Code__c ;
            theCMD.Terms_of_payment__c = theRequest.Terms_of_payment__c ;
            theCMD.Payment_Credit_Memo__c = theRequest.Payment_Credit_Memo__c ;
            theCMD.Lockbox__c = theRequest.Lockbox__c ;
            theCMD.Sales_office__c = theRequest.Sales_Office__c ;
            theCMD.Currency__c = theRequest.Currency__c ;
            theCMD.S_O_Sub_Group__c = theRequest.S_O_Sub_Group__c ;
            theCMD.Exch_rate_type__c = theRequest.Exch_rate_type__c ;
            theCMD.Reprice_Basis__c = theRequest.Reprice_Basis__c ;
            theCMD.Cust_pric_proc__c = theRequest.Cust_pric_proc__c ;
            theCMD.Acct_at_cust__c = theRequest.Acct_at_cust__c ;
//            theCMD.Fixed_Currency_Ind_SP__c = theRequest.Fixed_Currency_Ind_SP__c ;

            theCMD.Accept_Dupl_PO_SP__c = 
                ( theRequest.Accept_Dupl_PO_SP__c == 'Yes' ? true : 
                     ( theRequest.Accept_Dupl_PO_SP__c == 'No' ? false : theCMD.Accept_Dupl_PO_SP__c )
                );
            theCMD.Non_I2_related_SP__c = 
                ( theRequest.Non_I2_related_SP__c == 'Yes' ? true :
                    ( theRequest.Non_I2_related_SP__c == 'No' ? false : theCMD.Non_I2_related_SP__c )
                );
            theCMD.C_GAD_Indicator_SH__c = 
                ( theRequest.C_GAD_Indicator_SH__c == 'Yes' ? true : 
                    ( theRequest.C_GAD_Indicator_SH__c == 'No' ? false : theCMD.C_GAD_Indicator_SH__c )
                );
            theCMD.Ch_dupl_PO_item_SP__c = 
                ( theRequest.Ch_dupl_PO_item_SP__c == 'Yes' ? true :
                    ( theRequest.Ch_dupl_PO_item_SP__c == 'No' ? false : theCMD.Ch_dupl_PO_item_SP__c )
                );

//            theCMD.Delivery_priority__c = 
//                ( theRequest.Delivery_priority__c == 'Yes' ? true :
//                    ( theRequest.Delivery_priority__c == 'No' ? false : theCMD.Delivery_priority__c )
//                );
            theCMD.Order_combination__c = 
                ( theRequest.Order_combination__c == 'Yes' ? true :
                    ( theRequest.Order_combination__c == 'No' ? false : theCMD.Order_combination__c )
                );

/**
            theCMD.Accept_Dupl_PO_SP__c = theRequest.Accept_Dupl_PO_SP__c ;
            theCMD.Non_I2_related_SP__c = theRequest.Non_I2_related_SP__c ;
            theCMD.C_GAD_Indicator_SH__c = theRequest.C_GAD_Indicator_SH__c ;
            theCMD.Ch_dupl_PO_item_SP__c = theRequest.Ch_dupl_PO_item_SP__c ;
*/
            theCMD.Delivery_priority__c = theRequest.Delivery_priority__c ;
/*            theCMD.Order_combination__c = theRequest.Order_combination__c ;
**/
            theCMD.Max_partial_deliveries__c = theRequest.Max_partial_deliveries__c ;
            theCMD.Partial_delivery_per_item__c = theRequest.Partial_delivery_per_item__c ;
            theCMD.Incoterms_1__c = theRequest.Incoterms_1__c ;
            theCMD.Incoterms_2__c = theRequest.Incoterms_2__c ;
            theCMD.Terms_of_Payment_Sales__c = theRequest.Terms_of_Payment_Sales__c ;
            theCMD.Grp_1_Sls_Channel_SP__c = theRequest.Grp_1_Sls_Channel_SP__c ;
            theCMD.Grp_2_Cus_Prce_Grp_SP__c = theRequest.Grp_2_Cus_Prce_Grp_SP__c ;
            theCMD.Matl_Det_Grp_SP__c = theRequest.Matl_Det_Grp_SP__c ;
            theCMD.BillCurrency_PY__c = theRequest.BillCurrency_PY__c ;
            /***Scarlett - 1508 Release***/      
            theCMD.Label_Required__c = theRequest.Label_Required__c;
            if(theRequest.Label_Required__c != null && theRequest.Label_Required__c == 'Yes')
                theCMD.Label_Code__c = theRequest.Label_Code__c;

            if(theRequest.Label_Required__c != null && theRequest.Label_Required__c == 'No')
                theCMD.Label_Code__c = '';
            /***Scarlett - 1508 Release - End***/   
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            /* 1603 Release */
            theCMD.RecordTypeId = Z001_RECORD_TYPE_ID;
            theCMD.HUB_Customer__c = theRequest.SP_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.SP_Name__c;
            theCMD.Name_2__c = theRequest.SP_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.SP_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.SP_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.SP_Street__c; 
            theCMD.City__c = theRequest.SP_City__c;
            theCMD.State_Province__c = theRequest.SP_State__c;
            theCMD.Country__c = theRequest.SP_Country__c;
            theCMD.Zip__c = theRequest.SP_Postal_Code__c;
            theCMD.Telephone__c = theRequest.SP_Telephone__c;
            theCMD.Fax__c = theRequest.SP_Fax__c;
            theCMD.Email__c = theRequest.SP_Email__c;
            theCMD.PO_Box__c = theRequest.SP_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.SP_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.SP_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.FunLoc__c = theRequest.SP_Funloc_Id__c;
            /*1603 Release*/
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Additional_VAT_Number_1_Plants_Abroad__c = theRequest.Additional_VAT_Number_1__c;
            theCMD.Additional_VAT_Number_2_Plants_Abroad__c = theRequest.Additional_VAT_Number_2__c;
            theCMD.Additional_VAT_Number_3_Plants_Abroad__c = theRequest.Additional_VAT_Number_3__c;
            theCMD.Additional_VAT_Number_4_Plants_Abroad__c = theRequest.Additional_VAT_Number_4__c;
            theCMD.Additional_VAT_Number_5_Plants_Abroad__c = theRequest.Additional_VAT_Number_5__c;
            theCMD.Additional_VAT_Number_6_Plants_Abroad__c = theRequest.Additional_VAT_Number_6__c;
            theCMD.Additional_VAT_Number_7_Plants_Abroad__c = theRequest.Additional_VAT_Number_7__c;
            theCMD.Additional_VAT_Number_8_Plants_Abroad__c = theRequest.Additional_VAT_Number_8__c;
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
            //b  theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
            if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
               else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;
          
         //b   theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
         if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
               else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_Order_Block__c;
            
         //b   theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
            if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
               else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Chinese_City__c = theRequest.City_Chinese__c;
            theCMD.Country_Additional_VAT_Number_1__c = theRequest.Country_Additional_VAT_Number_1__c;
            theCMD.Country_Additional_VAT_Number_2__c = theRequest.Country_Additional_VAT_Number_2__c;
            theCMD.Country_Additional_VAT_Number_3__c = theRequest.Country_Additional_VAT_Number_3__c;
            theCMD.Country_Additional_VAT_Number_4__c = theRequest.Country_Additional_VAT_Number_4__c;
            theCMD.Country_Additional_VAT_Number_5__c = theRequest.Country_Additional_VAT_Number_5__c;
            theCMD.Country_Additional_VAT_Number_6__c = theRequest.Country_Additional_VAT_Number_6__c;
            theCMD.Country_Additional_VAT_Number_7__c = theRequest.Country_Additional_VAT_Number_7__c;
            theCMD.Country_Additional_VAT_Number_8__c = theRequest.Country_Additional_VAT_Number_8__c;
            theCMD.Customer_Statistics_Group__c = theRequest.Customer_Statistics_Group__c;
          //  theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
          if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
          else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
               
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            //theCMD.HUB_Customer__c = theRequest.Global_Customer_ID__c;
            theCMD.Language__c = theRequest.Language__c;
            theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
            theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            //theCMD.SDI_Screened__c = theRequest.Screened_for_SDI__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );
            theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Version_ID_for_International_Addresses__c = theRequest.Version_ID_for_International_Addresses__c;
            theCMD.Tax_Number_5__c = theRequest.Tax_Number_5__c;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c;
            theCMD.Trading_Partner__c = theRequest.Trading_Partner__c;
            theCMD.Distribution_Region__c = theRequest.Distribution_Region__c;
            theCMD.Sales_district__c = theRequest.Sales_district__c;
            theCMD.Shipping_conditions__c = theRequest.Shipping_Condition__c;
            theCMD.Unloading_Point__c = theRequest.Unloading_Point__c;
            theCMD.Acct_assgmt_group__c = theRequest.Acct_assgmt_group__c;
            theCMD.Account_memo__c = theRequest.Account_memo__c;
            theCMD.Acconting_Clerk__c = theRequest.Accounting_Clerk__c;
            theCMD.Act_clerk_fax_number__c = theRequest.Act_clerk_fax_number__c;
            theCMD.Act_clerk_internet_address__c = theRequest.Act_clerk_internet_address__c;
            theCMD.Act_clerk_tel_no__c = theRequest.Act_clerk_tel_no__c;
          //  theCMD.Deletion_Block_Company_Code__c = theRequest.Deletion_Block_Company_Code__c;
          //  theCMD.Deletion_Flag_Company_Code__c = theRequest.Deletion_Flag_Company_Code__c;
             if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'Yes')
               theCMD.Deletion_Block_Company_Code__c = TRUE;
              else if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'No')
                 theCMD.Deletion_Block_Company_Code__c = FALSE;

             if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'Yes')
               theCMD.Deletion_Flag_Company_Code__c = TRUE;
              else if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'No')
                 theCMD.Deletion_Flag_Company_Code__c = FALSE;

            //theCMD.Indicator_Record_Payment_History__c = theRequest.Indicator_Record_Payment_History__c;
            theCMD.Indicator_Record_Payment_History__c = 
                ( theRequest.Indicator_Record_Payment_History__c == 'Yes' ? true :
                    ( theRequest.Indicator_Record_Payment_History__c == 'No' ? false : theCMD.Indicator_Record_Payment_History__c )
                );
            theCMD.Ind_period_account_statement__c = theRequest.Ind_period_account_statement__c;
            theCMD.Key_for_Payment_Grouping__c = theRequest.Key_for_Payment_Grouping__c;
            theCMD.Our_account_at_customer__c = theRequest.Our_account_at_customer__c;
            theCMD.Paym_guar_proc__c = theRequest.Payment_Guarantee_Procedure__c;
          //  theCMD.Posting_block_for_company_code__c = theRequest.Posting_Block_Company_Code__c;
            if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'Yes')
               theCMD.Posting_block_for_company_code__c = TRUE;
             else if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'No')
               theCMD.Posting_block_for_company_code__c = FALSE;

            theCMD.Reason_Code_Conversion__c = theRequest.Reason_Code_Conversion__c;
            theCMD.Reconciliation_Account__c = theRequest.Reconciliation_Account__c;
            theCMD.Selection_Rule_for_Payment_Advice__c = theRequest.Selection_Rule_for_Payment_Advice__c;
            theCMD.Sorting_key_for_assignment_no__c = theRequest.Sorting_key_for_assignment_no__c;
            theCMD.Tolerance_Group__c = theRequest.Tolerance_Group__c;
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )  
                );
            theCMD.User_at_customer__c = theRequest.User_at_customer__c;
            theCMD.Fixed_Currency_Ind_SP__c = 
                ( theRequest.Fixed_Currency_Ind_SP__c == 'Yes' ? true : 
                    ( theRequest.Fixed_Currency_Ind_SP__c == 'No' ? false : theCMD.Fixed_Currency_Ind_SP__c )  
                );
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Central_Order_Block__c = theRequest.Central_Order_Block__c;
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
           
           //----------------------------------added as part of SIR 534----------------------------------------------
         
            if(theRequest.No_of_days_for_Early_Shipment__c!=null)
            {
             theCMD.No_of_days_for_Early_Shipment__c=theRequest.No_of_days_for_Early_Shipment__c;
             
            }
            //--------------------------------------------------------------------------------------------------------
            
        }
        
      
        
        if( theAccountGroup == 'Z002' ){
            theCMD.Consolidated_Account_Code__c = theRequest.Consolidated_Account_Code__c;
            theCMD.Transportation_Zone__c = theRequest.Transportation_Zone__c ;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c ;
            theCMD.Global_Account__c = theRequest.Global_Account__c ;
//STAN          theCMD.PD_Key_Account__c = theRequest.PD_Key_Account__c ;
            theCMD.Customer_Factory_Calendar__c = theRequest.Customer_Factory_Calendar__c ;
//STAN            theCMD.Con_Acct_SP_EMS__c = theRequest.Con_Acct_SP_EMS__c ;
            theCMD.Rounding_Rule_SH__c = theRequest.Rounding_Rule_SH__c ;
            theCMD.Delivery_Group_Ind_SH__c = theRequest.Delivery_Group_Ind_SH__c ;
            theCMD.Pull_Up_OK_SH__c = theRequest.Pull_Up_OK_SH__c ;

            theCMD.C_GAD_Indicator_SH__c = 
                ( theRequest.C_GAD_Indicator_SH__c == 'Yes' ? true : 
                    ( theRequest.C_GAD_Indicator_SH__c == 'No' ? false : theCMD.C_GAD_Indicator_SH__c )
                ) ;
 
//            theCMD.C_GAD_Indicator_SH__c = theRequest.C_GAD_Indicator_SH__c ;

            theCMD.Delivery_priority__c = theRequest.Delivery_priority__c ;
            theCMD.Max_partial_deliveries__c = theRequest.Max_partial_deliveries__c ;
            theCMD.Partial_delivery_per_item__c = theRequest.Partial_delivery_per_item__c ;
            theCMD.Incoterms_1__c = theRequest.Incoterms_1__c ;
            theCMD.Incoterms_2__c = theRequest.Incoterms_2__c ;
//Scarlett            theCMD.Industry_Segment__c = theRequest.Industry_Segment__c;
//            theCMD.Industry_Sub_Segment__c = theRequest.Industry_Sub_Segment__c;
            /***Scarlett - 1508 Release***/      
            theCMD.Label_Required__c = theRequest.Label_Required__c;
            if(theRequest.Label_Required__c != null && theRequest.Label_Required__c == 'Yes')
                theCMD.Label_Code__c = theRequest.Label_Code__c;

            if(theRequest.Label_Required__c != null && theRequest.Label_Required__c == 'No')
                theCMD.Label_Code__c = '';
            /***Scarlett - 1508 Release - End***/   
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            //1603 Release
             //New fields in SAP New Funloc Request - Modified by Scarlett on 2014.11.19
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
         //   theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
         //   theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
             if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
                  else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;

             if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
                 else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;

             if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
                 else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_Order_Block__c;
          //  theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
          //  theCMD.Chinese_City__c = theRequest.City_Chinese__c;
          //  theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
            if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
            else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
               
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Distribution_Region__c = theRequest.Distribution_Region__c;//New mapping field add by Scarlett on 2015.03.09
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            //theCMD.HUB_Customer__c = theRequest.Global_Customer_ID__c;
            theCMD.Language__c = theRequest.Language__c;
          //  theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
          //  theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            theCMD.Sales_district__c = theRequest.Sales_district__c;
            //theCMD.SDI_Screened__c = theRequest.Screened_for_SDI__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );  
            theCMD.Shipping_conditions__c = theRequest.Shipping_Condition__c;
          //  theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c;
            theCMD.Unloading_Point__c = theRequest.Unloading_Point__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )  
                );
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Central_Order_Block__c = theRequest.Central_Order_Block__c;
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            //----------------------------------added as part of SIR 534----------------------------------------------
            if(theRequest.No_of_days_for_Early_Shipment__c!=null)
            {
             theCMD.No_of_days_for_Early_Shipment__c=theRequest.No_of_days_for_Early_Shipment__c;
             
            }
            //--------------------------------------------------------------------------------------------------------
       
        }
//        if( ( theAccountGroup == 'Z002' || theRequest.Account_Group__c == 'Z002') && !(theRequest.SH_Same_as_SP__c) ){
        if( theAccountGroup == 'Z002' && !(theRequest.SH_Same_as_SP__c) ){
            theCMD.RecordTypeId = Z002_RECORD_TYPE_ID;
//          theCMD.HUB_Customer__c = theRequest.SH_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.SH_Name__c;
            theCMD.Name_2__c = theRequest.SH_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.SH_Name_Line_3__c;////new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.SH_Name_Line_4__c;////new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.SH_Street__c;
            theCMD.City__c = theRequest.SH_City__c;
            theCMD.State_Province__c = theRequest.SH_State__c;
            theCMD.Country__c = theRequest.SH_Country__c;
            theCMD.Zip__c = theRequest.SH_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.SH_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.SH_Telephone__c;
            theCMD.Fax__c = theRequest.SH_Fax__c;
            theCMD.Email__c = theRequest.SH_Email__c;
        }
//        if( ( theAccountGroup == 'Z002' || theRequest.Account_Group__c == 'Z002' ) && theRequest.SH_Same_as_SP__c ){
        if( theAccountGroup == 'Z002' && theRequest.SH_Same_as_SP__c ){
            theCMD.RecordTypeId = Z002_RECORD_TYPE_ID;
            theCMD.HUB_Customer__c = theRequest.SP_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.SP_Name__c;
            theCMD.Name_2__c = theRequest.SP_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.SP_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.SP_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.SP_Street__c;
            theCMD.City__c = theRequest.SP_City__c;
            theCMD.State_Province__c = theRequest.SP_State__c;
            theCMD.Country__c = theRequest.SP_Country__c;
            theCMD.Zip__c = theRequest.SP_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.SP_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.SP_Telephone__c;
            theCMD.Fax__c = theRequest.SP_Fax__c;
            theCMD.Email__c = theRequest.SP_Email__c;
            theCMD.PO_Box__c = theRequest.SP_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.SP_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.SP_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
        }
        
      

        if( theAccountGroup == 'Z003' ){
            theCMD.Global_Account__c = theRequest.Global_Account__c ;
            theCMD.Company_Code__c = theRequest.Company_Code__c ;
            theCMD.Terms_of_payment__c = theRequest.Terms_of_payment__c ;
            theCMD.Payment_Credit_Memo__c = theRequest.Payment_Credit_Memo__c ;
            theCMD.Lockbox__c = theRequest.Lockbox__c ;
            theCMD.Terms_of_Payment_Sales__c = theRequest.Terms_of_Payment_Sales__c ;
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            //1603 Release
         //New fields in SAP New Funloc Request - Modified by Scarlett on 2014.11.19
            theCMD.Act_clerk_internet_address__c = theRequest.Act_clerk_internet_address__c;
            theCMD.Act_clerk_tel_no__c = theRequest.Act_clerk_tel_no__c;
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
          //  theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
          //  theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
            if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
                  else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;

             if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
                 else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;

             if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
                 else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_Order_Block__c;
          //  theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
            theCMD.Chinese_City__c = theRequest.City_Chinese__c;
            theCMD.Customer_Statistics_Group__c = theRequest.Customer_Statistics_Group__c;
          //  theCMD.Deletion_Block_Company_Code__c = theRequest.Deletion_Block_Company_Code__c;
         //   theCMD.Deletion_Flag_Company_Code__c = theRequest.Deletion_Flag_Company_Code__c;
          //  theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
           if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'Yes')
               theCMD.Deletion_Block_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'No')
               theCMD.Deletion_Block_Company_Code__c = FALSE;

         if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'Yes')
               theCMD.Deletion_Flag_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'No')
               theCMD.Deletion_Flag_Company_Code__c = FALSE;

          if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
            else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
               
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            //theCMD.HUB_Customer__c = theRequest.Global_Customer_ID__c;
            //theCMD.Indicator_Record_Payment_History__c = theRequest.Indicator_Record_Payment_History__c;
            theCMD.Indicator_Record_Payment_History__c = 
                ( theRequest.Indicator_Record_Payment_History__c == 'Yes' ? true :
                    ( theRequest.Indicator_Record_Payment_History__c == 'No' ? false : theCMD.Indicator_Record_Payment_History__c )
                );            
            theCMD.Ind_period_account_statement__c = theRequest.Ind_period_account_statement__c;
            theCMD.Key_for_Payment_Grouping__c = theRequest.Key_for_Payment_Grouping__c;
            theCMD.Language__c = theRequest.Language__c;
            theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
            theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            theCMD.Our_account_at_customer__c = theRequest.Our_account_at_customer__c;
            theCMD.Paym_guar_proc__c = theRequest.Payment_Guarantee_Procedure__c;
          //  theCMD.Posting_block_for_company_code__c = theRequest.Posting_Block_Company_Code__c;
              if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'Yes')
               theCMD.Posting_block_for_company_code__c = TRUE;
                 else if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'No')
               theCMD.Posting_block_for_company_code__c = FALSE;

            theCMD.Reason_Code_Conversion__c = theRequest.Reason_Code_Conversion__c;
            theCMD.Reconciliation_Account__c = theRequest.Reconciliation_Account__c;
            //theCMD.SDI_Screened__c = theRequest.Screened_for_SDI__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );            
            theCMD.Selection_Rule_for_Payment_Advice__c = theRequest.Selection_Rule_for_Payment_Advice__c;
            theCMD.Sorting_key_for_assignment_no__c = theRequest.Sorting_key_for_assignment_no__c;
            theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Version_ID_for_International_Addresses__c = theRequest.Version_ID_for_International_Addresses__c;
            theCMD.Tax_Number_5__c = theRequest.Tax_Number_5__c;
            theCMD.Tolerance_Group__c = theRequest.Tolerance_Group__c;
            theCMD.User_at_customer__c = theRequest.User_at_customer__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )  
                );
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Central_Order_Block__c = theRequest.Central_Order_Block__c;
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Acconting_Clerk__c = theRequest.Accounting_Clerk__c;
            theCMD.Acct_assgmt_group__c = theRequest.Acct_assgmt_group__c;
            theCMD.BillCurrency_PY__c = theRequest.BillCurrency_PY__c ; // added as part of SFDC-684
            
        }
//        if( ( theAccountGroup == 'Z003' || theRequest.Account_Group__c == 'Z003' ) && !(theRequest.PY_Same_as_SP__c) ){
        if( theAccountGroup == 'Z003' && !(theRequest.PY_Same_as_SP__c) ){
            theCMD.RecordTypeId = Z003_RECORD_TYPE_ID;
//            theCMD.HUB_Customer__c = theRequest.PY_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.PY_Name__c;
            theCMD.Name_2__c = theRequest.PY_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.PY_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.PY_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.PY_Street__c;
            theCMD.City__c = theRequest.PY_City__c;
            theCMD.State_Province__c = theRequest.PY_State__c;
            theCMD.Country__c = theRequest.PY_Country__c;
            theCMD.Zip__c = theRequest.PY_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.PY_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.PY_Telephone__c;
            theCMD.Fax__c = theRequest.PY_Fax__c;
            theCMD.Email__c = theRequest.PY_Email__c;
            theCMD.PO_Box__c = theRequest.PY_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.PY_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.PY_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
        }
//        if( ( theAccountGroup == 'Z003' || theRequest.Account_Group__c == 'Z003' ) && theRequest.PY_Same_as_SP__c ){
        if( theAccountGroup == 'Z003' && theRequest.PY_Same_as_SP__c ){
            theCMD.RecordTypeId = Z003_RECORD_TYPE_ID;
            theCMD.HUB_Customer__c = theRequest.SP_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.SP_Name__c;
            theCMD.Name_2__c = theRequest.SP_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.SP_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.SP_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.SP_Street__c;
            theCMD.City__c = theRequest.SP_City__c;
            theCMD.State_Province__c = theRequest.SP_State__c;
            theCMD.Country__c = theRequest.SP_Country__c;
            theCMD.Zip__c = theRequest.SP_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.SP_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.SP_Telephone__c;
            theCMD.Fax__c = theRequest.SP_Fax__c;
            theCMD.Email__c = theRequest.SP_Email__c;
            theCMD.PO_Box__c = theRequest.SP_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.SP_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.SP_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
        }
        
      

        if( theAccountGroup == 'Z004' ) {
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c ;
            theCMD.Global_Account__c = theRequest.Global_Account__c ;
            //1603 Release
            //New fields in SAP New Funloc Request - Modified by Scarlett on 2014.11.19
            theCMD.Acct_assgmt_group__c = theRequest.Acct_assgmt_group__c;
            theCMD.Account_memo__c = theRequest.Account_memo__c;
            theCMD.Acconting_Clerk__c = theRequest.Accounting_Clerk__c;
            theCMD.Act_clerk_fax_number__c = theRequest.Act_clerk_fax_number__c;
            theCMD.Act_clerk_internet_address__c = theRequest.Act_clerk_internet_address__c;
            theCMD.Act_clerk_tel_no__c = theRequest.Act_clerk_tel_no__c;
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
          //  theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
          //  theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
          if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
                  else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;

             if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
                 else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;

             if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
                 else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_Order_Block__c;
          //  theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
          //  theCMD.Chinese_City__c = theRequest.City_Chinese__c;
            theCMD.Customer_Statistics_Group__c = theRequest.Customer_Statistics_Group__c;
          //  theCMD.Deletion_Block_Company_Code__c = theRequest.Deletion_Block_Company_Code__c;
          //  theCMD.Deletion_Flag_Company_Code__c = theRequest.Deletion_Flag_Company_Code__c;
          //  theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
             if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'Yes')
               theCMD.Deletion_Block_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'No')
               theCMD.Deletion_Block_Company_Code__c = FALSE;

             if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'Yes')
               theCMD.Deletion_Flag_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'No')
               theCMD.Deletion_Flag_Company_Code__c = FALSE;

            if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
            else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
               
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            //theCMD.HUB_Customer__c = theRequest.Global_Customer_ID__c;
            //theCMD.Indicator_Record_Payment_History__c = theRequest.Indicator_Record_Payment_History__c;
            theCMD.Indicator_Record_Payment_History__c = 
                ( theRequest.Indicator_Record_Payment_History__c == 'Yes' ? true :
                    ( theRequest.Indicator_Record_Payment_History__c == 'No' ? false : theCMD.Indicator_Record_Payment_History__c )
                );              
            theCMD.Ind_period_account_statement__c = theRequest.Ind_period_account_statement__c;
            theCMD.Key_for_Payment_Grouping__c = theRequest.Key_for_Payment_Grouping__c;
            theCMD.Language__c = theRequest.Language__c;
          //  theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
         //   theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            theCMD.Our_account_at_customer__c = theRequest.Our_account_at_customer__c;
            theCMD.Paym_guar_proc__c = theRequest.Payment_Guarantee_Procedure__c;
         //   theCMD.Posting_block_for_company_code__c = theRequest.Posting_Block_Company_Code__c;
            if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'Yes')
               theCMD.Posting_block_for_company_code__c = TRUE;
             else if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'No')
               theCMD.Posting_block_for_company_code__c = FALSE;

            theCMD.Reason_Code_Conversion__c = theRequest.Reason_Code_Conversion__c;
            theCMD.Reconciliation_Account__c = theRequest.Reconciliation_Account__c;
            //theCMD.SDI_Screened__c = theRequest.Screened_for_SDI__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );         
            theCMD.Selection_Rule_for_Payment_Advice__c = theRequest.Selection_Rule_for_Payment_Advice__c;
            theCMD.Sorting_key_for_assignment_no__c = theRequest.Sorting_key_for_assignment_no__c;
          //  theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Tolerance_Group__c = theRequest.Tolerance_Group__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )  
                );
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Central_Order_Block__c = theRequest.Central_Order_Block__c;
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
        }
//        if( ( theAccountGroup == 'Z004' || theRequest.Account_Group__c == 'Z004' ) && !(theRequest.BP_Same_as_SP__c) && !(theRequest.BP_Same_as_PY__c) ){
        if( theAccountGroup == 'Z004' && !(theRequest.BP_Same_as_SP__c) && !(theRequest.BP_Same_as_PY__c) ){
            theCMD.RecordTypeId = Z004_RECORD_TYPE_ID;
//            theCMD.HUB_Customer__c = theRequest.BP_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.BP_Name__c;
            theCMD.Name_2__c = theRequest.BP_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.BP_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.BP_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.BP_Street__c;
            theCMD.City__c = theRequest.BP_City__c;
            theCMD.State_Province__c = theRequest.BP_State__c;
            theCMD.Country__c = theRequest.BP_Country__c;
            theCMD.Zip__c = theRequest.BP_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.BP_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.BP_Telephone__c;
            theCMD.Fax__c = theRequest.BP_Fax__c;
            theCMD.Email__c = theRequest.BP_Email__c;
            theCMD.PO_Box__c = theRequest.BP_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.BP_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.BP_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
        }
//        if( ( theAccountGroup == 'Z004' || theRequest.Account_Group__c == 'Z004' ) && theRequest.BP_Same_as_SP__c ){
        if( theAccountGroup == 'Z004' && theRequest.BP_Same_as_SP__c ){
            theCMD.RecordTypeId = Z004_RECORD_TYPE_ID;
            theCMD.HUB_Customer__c = theRequest.SP_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.SP_Name__c;
            theCMD.Name_2__c = theRequest.SP_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.SP_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.SP_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.SP_Street__c;
            theCMD.City__c = theRequest.SP_City__c;
            theCMD.State_Province__c = theRequest.SP_State__c;
            theCMD.Country__c = theRequest.SP_Country__c;
            theCMD.Zip__c = theRequest.SP_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.SP_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.SP_Telephone__c;
            theCMD.Fax__c = theRequest.SP_Fax__c;
            theCMD.Email__c = theRequest.SP_Email__c;
            theCMD.PO_Box__c = theRequest.SP_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.SP_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.SP_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
        }
//        if( ( theAccountGroup == 'Z004' || theRequest.Account_Group__c == 'Z004' ) && theRequest.BP_Same_as_PY__c ){
        if( theAccountGroup == 'Z004' && theRequest.BP_Same_as_PY__c ){
            theCMD.RecordTypeId = Z004_RECORD_TYPE_ID;
//            theCMD.HUB_Customer__c = theRequest.PY_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.PY_Name__c;
            theCMD.Name_2__c = theRequest.PY_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.PY_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.PY_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.PY_Street__c;
            theCMD.City__c = theRequest.PY_City__c;
            theCMD.State_Province__c = theRequest.PY_State__c;
            theCMD.Country__c = theRequest.PY_Country__c;
            theCMD.Zip__c = theRequest.PY_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.PY_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.PY_Telephone__c;
            theCMD.Fax__c = theRequest.PY_Fax__c;
            theCMD.Email__c = theRequest.PY_Email__c;
            theCMD.PO_Box__c = theRequest.PY_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.PY_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.PY_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
        }
        
  
        
        if( theAccountGroup == 'Z005' ) {
            theCMD.Consolidated_Account_Code__c = theRequest.Consolidated_Account_Code__c;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c ;
            theCMD.VAT_Registration_Number__c = theRequest.VAT_Registration_Number__c ;
            theCMD.Global_Account__c = theRequest.Global_Account__c ;
//STAN            theCMD.PD_Key_Account__c = theRequest.PD_Key_Account__c ;
//STAN            theCMD.Con_Acct_SP_EMS__c = theRequest.Con_Acct_SP_EMS__c ;
            theCMD.Fix_Price_Ind_SP__c = theRequest.Fix_Price_Ind_SP__c ;
            theCMD.Company_Code__c = theRequest.Company_Code__c ;
            theCMD.Terms_of_payment__c = theRequest.Terms_of_payment__c ;
            theCMD.Payment_Credit_Memo__c = theRequest.Payment_Credit_Memo__c ;
            theCMD.Lockbox__c = theRequest.Lockbox__c ;
            theCMD.Sales_office__c = theRequest.Sales_Office__c ;
            theCMD.Currency__c = theRequest.Currency__c ;
            theCMD.S_O_Sub_Group__c = theRequest.S_O_Sub_Group__c ;
            theCMD.Exch_rate_type__c = theRequest.Exch_rate_type__c ;
            theCMD.Reprice_Basis__c = theRequest.Reprice_Basis__c ;
            theCMD.Cust_pric_proc__c = theRequest.Cust_pric_proc__c ;
            theCMD.Acct_at_cust__c = theRequest.Acct_at_cust__c ;
//            theCMD.Fixed_Currency_Ind_SP__c = theRequest.Fixed_Currency_Ind_SP__c ;
//            theCMD.Non_I2_related_SP__c = theRequest.Non_I2_related_SP__c ;

            theCMD.Accept_Dupl_PO_SP__c = 
                ( theRequest.Accept_Dupl_PO_SP__c == 'Yes' ? true : 
                     ( theRequest.Accept_Dupl_PO_SP__c == 'No' ? false : theCMD.Accept_Dupl_PO_SP__c )
                );
            theCMD.Ch_dupl_PO_item_SP__c = 
                ( theRequest.Ch_dupl_PO_item_SP__c == 'Yes' ? true :
                    ( theRequest.Ch_dupl_PO_item_SP__c == 'No' ? false : theCMD.Ch_dupl_PO_item_SP__c )
                );

//            theCMD.Delivery_priority__c = 
//                ( theRequest.Delivery_priority__c == 'Yes' ? true :
//                    ( theRequest.Delivery_priority__c == 'No' ? false : theCMD.Delivery_priority__c )
//                );

            theCMD.Order_combination__c = 
                ( theRequest.Order_combination__c == 'Yes' ? true :
                    ( theRequest.Order_combination__c == 'No' ? false : theCMD.Order_combination__c )
                );

/*********************            
            theCMD.Accept_Dupl_PO_SP__c = theRequest.Accept_Dupl_PO_SP__c ;
            theCMD.Ch_dupl_PO_item_SP__c = theRequest.Ch_dupl_PO_item_SP__c ;
*/
            theCMD.Delivery_priority__c = theRequest.Delivery_priority__c ;
/*            theCMD.Order_combination__c = theRequest.Order_combination__c ;
************************/
            theCMD.Terms_of_Payment_Sales__c = theRequest.Terms_of_Payment_Sales__c ;
            theCMD.Grp_1_Sls_Channel_SP__c = theRequest.Grp_1_Sls_Channel_SP__c ;
            theCMD.Grp_2_Cus_Prce_Grp_SP__c = theRequest.Grp_2_Cus_Prce_Grp_SP__c ;
            theCMD.Matl_Det_Grp_SP__c = theRequest.Matl_Det_Grp_SP__c ;
            theCMD.BillCurrency_PY__c = theRequest.BillCurrency_PY__c ;
//Scarlett            theCMD.Industry_Segment__c = theRequest.Industry_Segment__c;
//            theCMD.Industry_Sub_Segment__c = theRequest.Industry_Sub_Segment__c;
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            //1603 Release
            theCMD.RecordTypeId = Z005_RECORD_TYPE_ID;
            theCMD.HUB_Customer__c = theRequest.SP_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.SP_Name__c;
            theCMD.Name_2__c = theRequest.SP_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.SP_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.SP_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.SP_Street__c;
            theCMD.City__c = theRequest.SP_City__c;
            theCMD.State_Province__c = theRequest.SP_State__c;
            theCMD.Country__c = theRequest.SP_Country__c;
            theCMD.Zip__c = theRequest.SP_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.SP_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.SP_Telephone__c;
            theCMD.Fax__c = theRequest.SP_Fax__c;
            theCMD.Email__c = theRequest.SP_Email__c;
            theCMD.PO_Box__c = theRequest.SP_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.SP_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.SP_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
            //1603 Release
            //New fields in SAP New Funloc Request - Modified by Scarlett on 2014.11.19
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Additional_VAT_Number_1_Plants_Abroad__c = theRequest.Additional_VAT_Number_1__c;
            theCMD.Additional_VAT_Number_2_Plants_Abroad__c = theRequest.Additional_VAT_Number_2__c;
            theCMD.Additional_VAT_Number_3_Plants_Abroad__c = theRequest.Additional_VAT_Number_3__c;
            theCMD.Additional_VAT_Number_4_Plants_Abroad__c = theRequest.Additional_VAT_Number_4__c;
            theCMD.Additional_VAT_Number_5_Plants_Abroad__c = theRequest.Additional_VAT_Number_5__c;
            theCMD.Additional_VAT_Number_6_Plants_Abroad__c = theRequest.Additional_VAT_Number_6__c;
            theCMD.Additional_VAT_Number_7_Plants_Abroad__c = theRequest.Additional_VAT_Number_7__c;
            theCMD.Additional_VAT_Number_8_Plants_Abroad__c = theRequest.Additional_VAT_Number_8__c;
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
          //  theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
          //  theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
            if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
                  else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;

             if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
                 else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;

             if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
                 else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_Order_Block__c;
         //   theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
            theCMD.Chinese_City__c = theRequest.City_Chinese__c;
            theCMD.Country_Additional_VAT_Number_1__c = theRequest.Country_Additional_VAT_Number_1__c;
            theCMD.Country_Additional_VAT_Number_2__c = theRequest.Country_Additional_VAT_Number_2__c;
            theCMD.Country_Additional_VAT_Number_3__c = theRequest.Country_Additional_VAT_Number_3__c;
            theCMD.Country_Additional_VAT_Number_4__c = theRequest.Country_Additional_VAT_Number_4__c;
            theCMD.Country_Additional_VAT_Number_5__c = theRequest.Country_Additional_VAT_Number_5__c;
            theCMD.Country_Additional_VAT_Number_6__c = theRequest.Country_Additional_VAT_Number_6__c;
            theCMD.Country_Additional_VAT_Number_7__c = theRequest.Country_Additional_VAT_Number_7__c;
            theCMD.Country_Additional_VAT_Number_8__c = theRequest.Country_Additional_VAT_Number_8__c;
            theCMD.Customer_Statistics_Group__c = theRequest.Customer_Statistics_Group__c;
          //  theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
            if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
            else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            //theCMD.HUB_Customer__c = theRequest.Global_Customer_ID__c;
            theCMD.Language__c = theRequest.Language__c;
            theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
            theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            //theCMD.SDI_Screened__c = theRequest.Screened_for_SDI__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );               
            theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Version_ID_for_International_Addresses__c = theRequest.Version_ID_for_International_Addresses__c;
            theCMD.Tax_Number_5__c = theRequest.Tax_Number_5__c;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c;
            theCMD.Trading_Partner__c = theRequest.Trading_Partner__c;
            theCMD.Acct_assgmt_group__c = theRequest.Acct_assgmt_group__c;
            theCMD.Account_memo__c = theRequest.Account_memo__c;
            theCMD.Acconting_Clerk__c = theRequest.Accounting_Clerk__c;
            theCMD.Act_clerk_fax_number__c = theRequest.Act_clerk_fax_number__c;
            theCMD.Act_clerk_internet_address__c = theRequest.Act_clerk_internet_address__c;
            theCMD.Act_clerk_tel_no__c = theRequest.Act_clerk_tel_no__c;
          //  theCMD.Deletion_Block_Company_Code__c = theRequest.Deletion_Block_Company_Code__c;
          //  theCMD.Deletion_Flag_Company_Code__c = theRequest.Deletion_Flag_Company_Code__c;
          
           if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'Yes')
               theCMD.Deletion_Block_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'No')
               theCMD.Deletion_Block_Company_Code__c = FALSE;

             if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'Yes')
               theCMD.Deletion_Flag_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'No')
               theCMD.Deletion_Flag_Company_Code__c = FALSE;

            //theCMD.Indicator_Record_Payment_History__c = theRequest.Indicator_Record_Payment_History__c;
            theCMD.Indicator_Record_Payment_History__c = 
                ( theRequest.Indicator_Record_Payment_History__c == 'Yes' ? true :
                    ( theRequest.Indicator_Record_Payment_History__c == 'No' ? false : theCMD.Indicator_Record_Payment_History__c )
                );                
            theCMD.Ind_period_account_statement__c = theRequest.Ind_period_account_statement__c;
            theCMD.Key_for_Payment_Grouping__c = theRequest.Key_for_Payment_Grouping__c;
            theCMD.Our_account_at_customer__c = theRequest.Our_account_at_customer__c;
            theCMD.Paym_guar_proc__c = theRequest.Payment_Guarantee_Procedure__c;
           // theCMD.Posting_block_for_company_code__c = theRequest.Posting_Block_Company_Code__c;
              if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'Yes')
               theCMD.Posting_block_for_company_code__c = TRUE;
                 else if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'No')
               theCMD.Posting_block_for_company_code__c = FALSE;
               
            theCMD.Reason_Code_Conversion__c = theRequest.Reason_Code_Conversion__c;
            theCMD.Reconciliation_Account__c = theRequest.Reconciliation_Account__c;
            theCMD.Selection_Rule_for_Payment_Advice__c = theRequest.Selection_Rule_for_Payment_Advice__c;
            theCMD.Sorting_key_for_assignment_no__c = theRequest.Sorting_key_for_assignment_no__c;
            theCMD.Tolerance_Group__c = theRequest.Tolerance_Group__c;
            theCMD.User_at_customer__c = theRequest.User_at_customer__c;   
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )  
                );
            theCMD.Fixed_Currency_Ind_SP__c = 
                ( theRequest.Fixed_Currency_Ind_SP__c == 'Yes' ? true : 
                    ( theRequest.Fixed_Currency_Ind_SP__c == 'No' ? false : theCMD.Fixed_Currency_Ind_SP__c )  
                );
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Central_Order_Block__c = theRequest.Central_Order_Block__c;
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
           
        }

        
    
//        if( theAccountGroup == 'Z010' || theRequest.Account_Group__c == 'Z010' ){
        if( theAccountGroup == 'Z010' ){
            theCMD.RecordTypeId = Z010_RECORD_TYPE_ID;
//            theCMD.HUB_Customer__c = theRequest.ZI_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.ZI_Name__c;
            theCMD.Name_2__c = theRequest.ZI_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.ZI_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.ZI_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.ZI_Street__c;
            theCMD.City__c = theRequest.ZI_City__c;
            theCMD.State_Province__c = theRequest.ZI_State__c;
            theCMD.Country__c = theRequest.ZI_Country__c;
            theCMD.Zip__c = theRequest.ZI_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.ZI_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.ZI_Telephone__c;
            theCMD.Fax__c = theRequest.ZI_Fax__c;
//            theCMD.Email__c = theRequest.ZI_Email__c;
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            //1603 release
            //New fields in SAP New Funloc Request - Modified by Scarlett on 2014.11.19
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
          //  theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
          //  theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
            if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
                  else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;

             if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
                 else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;

             if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
                 else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_Order_Block__c;
         //   theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
          //  theCMD.Chinese_City__c = theRequest.City_Chinese__c;
         //   theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
           if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
             else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            //theCMD.HUB_Customer__c = theRequest.Global_Customer_ID__c;
            theCMD.Language__c = theRequest.Language__c;
          //  theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
          //  theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            //theCMD.SDI_Screened__c = theRequest.Screened_for_SDI__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );   
          //  theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )  
                );
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Central_Order_Block__c = theRequest.Central_Order_Block__c;
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
        }
        
  
        if( theAccountGroup == 'Z011' ) {
            theCMD.Consolidated_Account_Code__c = theRequest.Consolidated_Account_Code__c;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c ;
            theCMD.VAT_Registration_Number__c = theRequest.VAT_Registration_Number__c ;
            theCMD.Global_Account__c = theRequest.Global_Account__c ;
//STAN            theCMD.PD_Key_Account__c = theRequest.PD_Key_Account__c ;
//STAN            theCMD.Con_Acct_SP_EMS__c = theRequest.Con_Acct_SP_EMS__c ;
            theCMD.Fix_Price_Ind_SP__c = theRequest.Fix_Price_Ind_SP__c ;
            theCMD.Sales_office__c = theRequest.Sales_Office__c ;
            theCMD.Currency__c = theRequest.Currency__c ;
            theCMD.S_O_Sub_Group__c = theRequest.S_O_Sub_Group__c ;
            theCMD.Exch_rate_type__c = theRequest.Exch_rate_type__c ;
            theCMD.Reprice_Basis__c = theRequest.Reprice_Basis__c ;
            theCMD.Cust_pric_proc__c = theRequest.Cust_pric_proc__c ;
            theCMD.Acct_at_cust__c = theRequest.Acct_at_cust__c ;
//            theCMD.Fixed_Currency_Ind_SP__c = theRequest.Fixed_Currency_Ind_SP__c ;

            theCMD.Accept_Dupl_PO_SP__c = 
                ( theRequest.Accept_Dupl_PO_SP__c == 'Yes' ? true : 
                     ( theRequest.Accept_Dupl_PO_SP__c == 'No' ? false : theCMD.Accept_Dupl_PO_SP__c )
                );
            theCMD.Non_I2_related_SP__c = 
                ( theRequest.Non_I2_related_SP__c == 'Yes' ? true :
                    ( theRequest.Non_I2_related_SP__c == 'No' ? false : theCMD.Non_I2_related_SP__c )
                );
            theCMD.Ch_dupl_PO_item_SP__c = 
                ( theRequest.Ch_dupl_PO_item_SP__c == 'Yes' ? true :
                    ( theRequest.Ch_dupl_PO_item_SP__c == 'No' ? false : theCMD.Ch_dupl_PO_item_SP__c )
                );

//            theCMD.Delivery_priority__c = 
//                ( theRequest.Delivery_priority__c == 'Yes' ? true :
//                    ( theRequest.Delivery_priority__c == 'No' ? false : theCMD.Delivery_priority__c )
//                );
            theCMD.Order_combination__c = 
                ( theRequest.Order_combination__c == 'Yes' ? true :
                    ( theRequest.Order_combination__c == 'No' ? false : theCMD.Order_combination__c )
                );

/****************
            theCMD.Accept_Dupl_PO_SP__c = theRequest.Accept_Dupl_PO_SP__c ;
            theCMD.Non_I2_related_SP__c = theRequest.Non_I2_related_SP__c ;
            theCMD.Ch_dupl_PO_item_SP__c = theRequest.Ch_dupl_PO_item_SP__c ;
*/
            theCMD.Delivery_priority__c = theRequest.Delivery_priority__c ;
/*            theCMD.Order_combination__c = theRequest.Order_combination__c ;
*********************/
            theCMD.Grp_1_Sls_Channel_SP__c = theRequest.Grp_1_Sls_Channel_SP__c ;
            theCMD.Grp_2_Cus_Prce_Grp_SP__c = theRequest.Grp_2_Cus_Prce_Grp_SP__c ;
            theCMD.Matl_Det_Grp_SP__c = theRequest.Matl_Det_Grp_SP__c ;
          //  theCMD.BillCurrency_PY__c = theRequest.BillCurrency_PY__c ; // commented as part of SFDC-684
//Scarlett            theCMD.Industry_Segment__c = theRequest.Industry_Segment__c;
//            theCMD.Industry_Sub_Segment__c = theRequest.Industry_Sub_Segment__c;
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            //1603 Release
            theCMD.RecordTypeId = Z011_RECORD_TYPE_ID;
            theCMD.HUB_Customer__c = theRequest.SP_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.SP_Name__c;
            theCMD.Name_2__c = theRequest.SP_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.SP_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.SP_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.SP_Street__c;
            theCMD.City__c = theRequest.SP_City__c;
            theCMD.State_Province__c = theRequest.SP_State__c;
            theCMD.Country__c = theRequest.SP_Country__c;
            theCMD.Zip__c = theRequest.SP_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.SP_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.SP_Telephone__c;
            theCMD.Fax__c = theRequest.SP_Fax__c;
            theCMD.Email__c = theRequest.SP_Email__c;
            theCMD.PO_Box__c = theRequest.SP_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.SP_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.SP_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
            //1603 Release
            //New fields in SAP New Funloc Request - Modified by Scarlett on 2014.11.19
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Additional_VAT_Number_1_Plants_Abroad__c = theRequest.Additional_VAT_Number_1__c;
            theCMD.Additional_VAT_Number_2_Plants_Abroad__c = theRequest.Additional_VAT_Number_2__c;
            theCMD.Additional_VAT_Number_3_Plants_Abroad__c = theRequest.Additional_VAT_Number_3__c;
            theCMD.Additional_VAT_Number_4_Plants_Abroad__c = theRequest.Additional_VAT_Number_4__c;
            theCMD.Additional_VAT_Number_5_Plants_Abroad__c = theRequest.Additional_VAT_Number_5__c;
            theCMD.Additional_VAT_Number_6_Plants_Abroad__c = theRequest.Additional_VAT_Number_6__c;
            theCMD.Additional_VAT_Number_7_Plants_Abroad__c = theRequest.Additional_VAT_Number_7__c;
            theCMD.Additional_VAT_Number_8_Plants_Abroad__c = theRequest.Additional_VAT_Number_8__c;
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
          //  theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
          //  theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
            if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
                  else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;

             if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
                 else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;

             if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
                 else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_Order_Block__c;
          //  theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
          //  theCMD.Chinese_City__c = theRequest.City_Chinese__c;
            theCMD.Country_Additional_VAT_Number_1__c = theRequest.Country_Additional_VAT_Number_1__c;
            theCMD.Country_Additional_VAT_Number_2__c = theRequest.Country_Additional_VAT_Number_2__c;
            theCMD.Country_Additional_VAT_Number_3__c = theRequest.Country_Additional_VAT_Number_3__c;
            theCMD.Country_Additional_VAT_Number_4__c = theRequest.Country_Additional_VAT_Number_4__c;
            theCMD.Country_Additional_VAT_Number_5__c = theRequest.Country_Additional_VAT_Number_5__c;
            theCMD.Country_Additional_VAT_Number_6__c = theRequest.Country_Additional_VAT_Number_6__c;
            theCMD.Country_Additional_VAT_Number_7__c = theRequest.Country_Additional_VAT_Number_7__c;
            theCMD.Country_Additional_VAT_Number_8__c = theRequest.Country_Additional_VAT_Number_8__c;
            theCMD.Customer_Statistics_Group__c = theRequest.Customer_Statistics_Group__c;
          //  theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
            if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
             else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            //theCMD.HUB_Customer__c = theRequest.Global_Customer_ID__c;
            theCMD.Language__c = theRequest.Language__c;
         //   theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
         //   theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            //theCMD.SDI_Screened__c = theRequest.Screened_for_SDI__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );            
          //  theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c;
            theCMD.Trading_Partner__c = theRequest.Trading_Partner__c;  
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )  
                );
            theCMD.Fixed_Currency_Ind_SP__c = 
                ( theRequest.Fixed_Currency_Ind_SP__c == 'Yes' ? true : 
                    ( theRequest.Fixed_Currency_Ind_SP__c == 'No' ? false : theCMD.Fixed_Currency_Ind_SP__c )  
                );
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Central_Order_Block__c = theRequest.Central_Order_Block__c;
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
        }

        
 
        if( theAccountGroup == 'Z012' ) {
            theCMD.Consolidated_Account_Code__c = theRequest.Consolidated_Account_Code__c;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c ;
            theCMD.VAT_Registration_Number__c = theRequest.VAT_Registration_Number__c ;
            theCMD.Global_Account__c = theRequest.Global_Account__c ;
//STAN            theCMD.PD_Key_Account__c = theRequest.PD_Key_Account__c ;
            theCMD.Customer_Factory_Calendar__c = theRequest.Customer_Factory_Calendar__c ;
//STAN            theCMD.Con_Acct_SP_EMS__c = theRequest.Con_Acct_SP_EMS__c ;
            theCMD.Rounding_Rule_SH__c = theRequest.Rounding_Rule_SH__c ;
            theCMD.Fix_Price_Ind_SP__c = theRequest.Fix_Price_Ind_SP__c ;
            theCMD.Delivery_Group_Ind_SH__c = theRequest.Delivery_Group_Ind_SH__c ;
            theCMD.Pull_Up_OK_SH__c = theRequest.Pull_Up_OK_SH__c ;
            theCMD.Sales_office__c = theRequest.Sales_Office__c ;
            theCMD.Currency__c = theRequest.Currency__c ;
            theCMD.S_O_Sub_Group__c = theRequest.S_O_Sub_Group__c ;
            theCMD.Exch_rate_type__c = theRequest.Exch_rate_type__c ;
            theCMD.Reprice_Basis__c = theRequest.Reprice_Basis__c ;
            theCMD.Cust_pric_proc__c = theRequest.Cust_pric_proc__c ;
            theCMD.Acct_at_cust__c = theRequest.Acct_at_cust__c ;

            theCMD.Fixed_Currency_Ind_SP__c = 
                ( theRequest.Fixed_Currency_Ind_SP__c == 'Yes' ? true :
                    ( theRequest.Fixed_Currency_Ind_SP__c == 'No' ? false : theCMD.Fixed_Currency_Ind_SP__c )
                );
            theCMD.Accept_Dupl_PO_SP__c = 
                ( theRequest.Accept_Dupl_PO_SP__c == 'Yes' ? true : 
                     ( theRequest.Accept_Dupl_PO_SP__c == 'No' ? false : theCMD.Accept_Dupl_PO_SP__c )
                );
            theCMD.Non_I2_related_SP__c = 
                ( theRequest.Non_I2_related_SP__c == 'Yes' ? true :
                    ( theRequest.Non_I2_related_SP__c == 'No' ? false : theCMD.Non_I2_related_SP__c )
                );
            theCMD.C_GAD_Indicator_SH__c = 
                ( theRequest.C_GAD_Indicator_SH__c == 'Yes' ? true : 
                    ( theRequest.C_GAD_Indicator_SH__c == 'No' ? false : theCMD.C_GAD_Indicator_SH__c )
                ) ;
            theCMD.Ch_dupl_PO_item_SP__c = 
                ( theRequest.Ch_dupl_PO_item_SP__c == 'Yes' ? true :
                    ( theRequest.Ch_dupl_PO_item_SP__c == 'No' ? false : theCMD.Ch_dupl_PO_item_SP__c )
                );

/*            theCMD.Delivery_priority__c = 
                ( theRequest.Delivery_priority__c == 'Yes' ? true :
                    ( theRequest.Delivery_priority__c == 'No' ? false : theCMD.Delivery_priority__c )
                );
*/
            theCMD.Order_combination__c = 
                ( theRequest.Order_combination__c == 'Yes' ? true :
                    ( theRequest.Order_combination__c == 'No' ? false : theCMD.Order_combination__c )
                );

/*****************            
            theCMD.Fixed_Currency_Ind_SP__c = theRequest.Fixed_Currency_Ind_SP__c ;
            theCMD.Accept_Dupl_PO_SP__c = theRequest.Accept_Dupl_PO_SP__c ;
            theCMD.Non_I2_related_SP__c = theRequest.Non_I2_related_SP__c ;
            theCMD.C_GAD_Indicator_SH__c = theRequest.C_GAD_Indicator_SH__c ;
            theCMD.Ch_dupl_PO_item_SP__c = theRequest.Ch_dupl_PO_item_SP__c ;
*/
            theCMD.Delivery_priority__c = theRequest.Delivery_priority__c ;
/*            theCMD.Order_combination__c = theRequest.Order_combination__c ;
********************/
            theCMD.Max_partial_deliveries__c = theRequest.Max_partial_deliveries__c ;
            theCMD.Partial_delivery_per_item__c = theRequest.Partial_delivery_per_item__c ;
            theCMD.Incoterms_1__c = theRequest.Incoterms_1__c ;
            theCMD.Incoterms_2__c = theRequest.Incoterms_2__c ;
            theCMD.Grp_1_Sls_Channel_SP__c = theRequest.Grp_1_Sls_Channel_SP__c ;
            theCMD.Grp_2_Cus_Prce_Grp_SP__c = theRequest.Grp_2_Cus_Prce_Grp_SP__c ;
            theCMD.Matl_Det_Grp_SP__c = theRequest.Matl_Det_Grp_SP__c ;
         //   theCMD.BillCurrency_PY__c = theRequest.BillCurrency_PY__c ; //commented as part of SFDC-684
//Scarlett            theCMD.Industry_Segment__c = theRequest.Industry_Segment__c;
//            theCMD.Industry_Sub_Segment__c = theRequest.Industry_Sub_Segment__c;
            /***Scarlett - 1508 Release***/      
            theCMD.Label_Required__c = theRequest.Label_Required__c;
            if(theRequest.Label_Required__c != null && theRequest.Label_Required__c == 'Yes')
                theCMD.Label_Code__c = theRequest.Label_Code__c;

            if(theRequest.Label_Required__c != null && theRequest.Label_Required__c == 'No')
                theCMD.Label_Code__c = '';
            /***Scarlett - 1508 Release - End***/   
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            //1603 Release
            theCMD.RecordTypeId = Z012_RECORD_TYPE_ID;
            theCMD.HUB_Customer__c = theRequest.SP_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.SP_Name__c;
            theCMD.Name_2__c = theRequest.SP_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.SP_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.SP_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Street_1__c = theRequest.SP_Street__c;
            theCMD.City__c = theRequest.SP_City__c;
            theCMD.State_Province__c = theRequest.SP_State__c;
            theCMD.Country__c = theRequest.SP_Country__c;
            theCMD.Zip__c = theRequest.SP_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.SP_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.SP_Telephone__c;
            theCMD.Fax__c = theRequest.SP_Fax__c;
            theCMD.Email__c = theRequest.SP_Email__c;
            theCMD.PO_Box__c = theRequest.SP_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.SP_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.SP_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
            //1603 Release
            //New fields in SAP New Funloc Request - Modified by Scarlett on 2014.11.19
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Additional_VAT_Number_1_Plants_Abroad__c = theRequest.Additional_VAT_Number_1__c;
            theCMD.Additional_VAT_Number_2_Plants_Abroad__c = theRequest.Additional_VAT_Number_2__c;
            theCMD.Additional_VAT_Number_3_Plants_Abroad__c = theRequest.Additional_VAT_Number_3__c;
            theCMD.Additional_VAT_Number_4_Plants_Abroad__c = theRequest.Additional_VAT_Number_4__c;
            theCMD.Additional_VAT_Number_5_Plants_Abroad__c = theRequest.Additional_VAT_Number_5__c;
            theCMD.Additional_VAT_Number_6_Plants_Abroad__c = theRequest.Additional_VAT_Number_6__c;
            theCMD.Additional_VAT_Number_7_Plants_Abroad__c = theRequest.Additional_VAT_Number_7__c;
            theCMD.Additional_VAT_Number_8_Plants_Abroad__c = theRequest.Additional_VAT_Number_8__c;
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
         //   theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
         //   theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
            if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
                  else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;

             if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
                 else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;

             if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
                 else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_Order_Block__c;
         //   theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
          //  theCMD.Chinese_City__c = theRequest.City_Chinese__c;
            theCMD.Country_Additional_VAT_Number_1__c = theRequest.Country_Additional_VAT_Number_1__c;
            theCMD.Country_Additional_VAT_Number_2__c = theRequest.Country_Additional_VAT_Number_2__c;
            theCMD.Country_Additional_VAT_Number_3__c = theRequest.Country_Additional_VAT_Number_3__c;
            theCMD.Country_Additional_VAT_Number_4__c = theRequest.Country_Additional_VAT_Number_4__c;
            theCMD.Country_Additional_VAT_Number_5__c = theRequest.Country_Additional_VAT_Number_5__c;
            theCMD.Country_Additional_VAT_Number_6__c = theRequest.Country_Additional_VAT_Number_6__c;
            theCMD.Country_Additional_VAT_Number_7__c = theRequest.Country_Additional_VAT_Number_7__c;
            theCMD.Country_Additional_VAT_Number_8__c = theRequest.Country_Additional_VAT_Number_8__c;
            theCMD.Customer_Statistics_Group__c = theRequest.Customer_Statistics_Group__c;
           // theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
            if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
             else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            //theCMD.HUB_Customer__c = theRequest.Global_Customer_ID__c;
            theCMD.Language__c = theRequest.Language__c;
         //   theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
        // theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            //theCMD.SDI_Screened__c = theRequest.Screened_for_SDI__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );   
         //   theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c;
            theCMD.Trading_Partner__c = theRequest.Trading_Partner__c;
            theCMD.Distribution_Region__c = theRequest.Distribution_Region__c;
            theCMD.Sales_district__c = theRequest.Sales_district__c;
            theCMD.Shipping_conditions__c = theRequest.Shipping_Condition__c;
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )  
                );            
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Transportation_Zone__c = theRequest.Transportation_Zone__c;
            theCMD.Central_Order_Block__c = theRequest.Central_Order_Block__c;
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Unloading_Point__c = theRequest.Unloading_Point__c;
            //----------------------------------added as part of SIR 534----------------------------------------------
            if(theRequest.No_of_days_for_Early_Shipment__c!=null)
            {
         
             theCMD.No_of_days_for_Early_Shipment__c=theRequest.No_of_days_for_Early_Shipment__c;
            
            }
            //--------------------------------------------------------------------------------------------------------
       
        }

        
  

        if( theAccountGroup == 'Z013' ) {
            theCMD.Global_Account__c = theRequest.Global_Account__c ;
//STAN            theCMD.PD_Key_Account__c = theRequest.PD_Key_Account__c ;
            theCMD.Company_Code__c = theRequest.Company_Code__c ;
            theCMD.Terms_of_payment__c = theRequest.Terms_of_payment__c ;
            theCMD.Payment_Credit_Memo__c = theRequest.Payment_Credit_Memo__c ;
            theCMD.Lockbox__c = theRequest.Lockbox__c ;
            theCMD.Terms_of_Payment_Sales__c = theRequest.Terms_of_Payment_Sales__c ;
            //1603 Release
            //New fields in SAP New Funloc Request - Modified by Scarlett on 2014.11.19
            theCMD.Acct_assgmt_group__c = theRequest.Acct_assgmt_group__c;
            theCMD.Account_memo__c = theRequest.Account_memo__c;
            theCMD.Acconting_Clerk__c = theRequest.Accounting_Clerk__c;
            theCMD.Act_clerk_fax_number__c = theRequest.Act_clerk_fax_number__c;
            theCMD.Act_clerk_internet_address__c = theRequest.Act_clerk_internet_address__c;
            theCMD.Act_clerk_tel_no__c = theRequest.Act_clerk_tel_no__c;
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
        //    theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
         //   theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
            if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
                  else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;

             if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
                 else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;

             if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
                 else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_Order_Block__c;
          //  theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
            theCMD.Chinese_City__c = theRequest.City_Chinese__c;
            theCMD.Customer_Statistics_Group__c = theRequest.Customer_Statistics_Group__c;
         //   theCMD.Deletion_Block_Company_Code__c = theRequest.Deletion_Block_Company_Code__c;
         //   theCMD.Deletion_Flag_Company_Code__c = theRequest.Deletion_Flag_Company_Code__c;
          //  theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
              if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'Yes')
               theCMD.Deletion_Block_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'No')
               theCMD.Deletion_Block_Company_Code__c = FALSE;

             if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'Yes')
               theCMD.Deletion_Flag_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'No')
               theCMD.Deletion_Flag_Company_Code__c = FALSE;

            if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
             else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
               
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            //theCMD.HUB_Customer__c = theRequest.Global_Customer_ID__c;
            //theCMD.Indicator_Record_Payment_History__c = theRequest.Indicator_Record_Payment_History__c;
            theCMD.Indicator_Record_Payment_History__c = 
                ( theRequest.Indicator_Record_Payment_History__c == 'Yes' ? true :
                    ( theRequest.Indicator_Record_Payment_History__c == 'No' ? false : theCMD.Indicator_Record_Payment_History__c )
                );     
            theCMD.Ind_period_account_statement__c = theRequest.Ind_period_account_statement__c;
            theCMD.Key_for_Payment_Grouping__c = theRequest.Key_for_Payment_Grouping__c;
            theCMD.Language__c = theRequest.Language__c;
            theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
            theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            theCMD.Our_account_at_customer__c = theRequest.Our_account_at_customer__c;
            theCMD.Paym_guar_proc__c = theRequest.Payment_Guarantee_Procedure__c;
          //  theCMD.Posting_block_for_company_code__c = theRequest.Posting_Block_Company_Code__c;
              if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'Yes')
               theCMD.Posting_block_for_company_code__c = TRUE;
                 else if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'No')
               theCMD.Posting_block_for_company_code__c = FALSE;
            theCMD.Reason_Code_Conversion__c = theRequest.Reason_Code_Conversion__c;
            theCMD.Reconciliation_Account__c = theRequest.Reconciliation_Account__c;
            //theCMD.SDI_Screened__c = theRequest.Screened_for_SDI__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );               
            theCMD.Selection_Rule_for_Payment_Advice__c = theRequest.Selection_Rule_for_Payment_Advice__c;
            theCMD.Sorting_key_for_assignment_no__c = theRequest.Sorting_key_for_assignment_no__c;
            theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Version_ID_for_International_Addresses__c = theRequest.Version_ID_for_International_Addresses__c;
            theCMD.Tax_Number_5__c = theRequest.Tax_Number_5__c;
            theCMD.Tolerance_Group__c = theRequest.Tolerance_Group__c;
            theCMD.User_at_customer__c = theRequest.User_at_customer__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true : 
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )  
                ); 
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Central_Order_Block__c = theRequest.Central_Order_Block__c;
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
            theCMD.BillCurrency_PY__c = theRequest.BillCurrency_PY__c ; // added as part of SFDC-684
           
        }
//        if( ( theAccountGroup == 'Z013' || theRequest.Account_Group__c == 'Z013' ) && !(theRequest.PY_Same_as_SP__c) ){
        if( theAccountGroup == 'Z013' && !(theRequest.PY_Same_as_SP__c) ){
            theCMD.RecordTypeId = Z013_RECORD_TYPE_ID;
//            theCMD.HUB_Customer__c = theRequest.PY_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.PY_Name__c;
            theCMD.Name_2__c = theRequest.PY_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.PY_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.PY_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06            
            theCMD.Street_1__c = theRequest.PY_Street__c;
            theCMD.City__c = theRequest.PY_City__c;
            theCMD.State_Province__c = theRequest.PY_State__c;
            theCMD.Country__c = theRequest.PY_Country__c;
            theCMD.Zip__c = theRequest.PY_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.PY_Funloc_Id__c;
            theCMD.Telephone__c = theRequest.PY_Telephone__c;
            theCMD.Fax__c = theRequest.PY_Fax__c;
            theCMD.Email__c = theRequest.PY_Email__c;
            theCMD.PO_Box__c = theRequest.PY_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.PY_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.PY_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Region__c = theRequest.Sales_Area_Region__c;//New mapping field add by Scarlett on 2015.03.09
        }
//        if( ( theAccountGroup == 'Z013' || theRequest.Account_Group__c == 'Z013' ) && theRequest.PY_Same_as_SP__c ){
        if( theAccountGroup == 'Z013' && theRequest.PY_Same_as_SP__c ){
            theCMD.RecordTypeId = Z013_RECORD_TYPE_ID;
            theCMD.HUB_Customer__c = theRequest.SP_CustomerId__c;
            theCMD.Legal_Name__c = theRequest.SP_Name__c;
            theCMD.Name_2__c = theRequest.SP_Name_Line_2__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_3__c = theRequest.SP_Name_Line_3__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.Name_4__c = theRequest.SP_Name_Line_4__c;//new mapping field added by Scarlett on 2015.02.06            
            theCMD.Street_1__c = theRequest.SP_Street__c;
            theCMD.City__c = theRequest.SP_City__c;
            theCMD.State_Province__c = theRequest.SP_State__c;
            theCMD.Country__c = theRequest.SP_Country__c;
            theCMD.Zip__c = theRequest.SP_Postal_Code__c;
            theCMD.FunLoc__c = theRequest.SP_Funloc_Id__c;
            theCMD.PO_Box__c = theRequest.SP_PO_Box__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_City__c = theRequest.SP_PO_Box_City__c;//new mapping field added by Scarlett on 2015.02.06
            theCMD.PO_Box_Postal_Code__c = theRequest.SP_PO_Box_Postal_Code__c;//new mapping field added by Scarlett on 2015.02.06            
        }
        
        /***1604 SIR 706 - Modified by Scarlett - START***/
        if(theAccountGroup == 'ZORG'){
            theCMD.RecordTypeId = ZORG_RECORD_TYPE_ID;
            
            //Copy Address Information from ZORG section (ZORG not same as SH)
            if(!(theRequest.ZORG_same_as_SH__c)){
                theCMD.City__c = theRequest.ZORG_City__c;
                theCMD.Country__c = theRequest.ZORG_Country__c;
                theCMD.Email__c = theRequest.ZORG_Email__c;
                theCMD.Legal_Name__c = theRequest.ZORG_Name__c;
                theCMD.Name_2__c = theRequest.ZORG_Name_Line_2__c;
                theCMD.Name_3__c = theRequest.ZORG_Name_Line_3__c;
                theCMD.Name_4__c = theRequest.ZORG_Name_Line_4__c;
                theCMD.State_Province__c = theRequest.ZORG_State__c;
                theCMD.Street_1__c = theRequest.ZORG_Street__c;
                theCMD.Telephone__c = theRequest.ZORG_Telephone__c;
                theCMD.Zip__c = theRequest.ZORG_Postal_Code__c;
            }
            
            //Copy Address Information from SH section: (ZORG same as SH & SH not same as SP)
            if(theRequest.ZORG_same_as_SH__c && !(theRequest.SH_Same_as_SP__c)){
                theCMD.City__c = theRequest.SH_City__c;
                theCMD.Country__c = theRequest.SH_Country__c;
                theCMD.Email__c = theRequest.SH_Email__c;
                theCMD.Legal_Name__c = theRequest.SH_Name__c;
                theCMD.Name_2__c = theRequest.SH_Name_Line_2__c;
                theCMD.Name_3__c = theRequest.SH_Name_Line_3__c;
                theCMD.Name_4__c = theRequest.SH_Name_Line_4__c;
                theCMD.State_Province__c = theRequest.SH_State__c;
                theCMD.Street_1__c = theRequest.SH_Street__c;
                theCMD.Telephone__c = theRequest.SH_Telephone__c;
                theCMD.Zip__c = theRequest.SH_Postal_Code__c;
            }
            
            //Copy Address Information from SP section: (ZORG same as SH & SH same as SP)
            if(theRequest.ZORG_same_as_SH__c && theRequest.SH_Same_as_SP__c){
                theCMD.City__c = theRequest.SP_City__c;
                theCMD.Country__c = theRequest.SP_Country__c;
                theCMD.Email__c = theRequest.SP_Email__c;
                theCMD.Legal_Name__c = theRequest.SP_Name__c;
                theCMD.Name_2__c = theRequest.SP_Name_Line_2__c;
                theCMD.Name_3__c = theRequest.SP_Name_Line_3__c;
                theCMD.Name_4__c = theRequest.SP_Name_Line_4__c;
                theCMD.State_Province__c = theRequest.SP_State__c;
                theCMD.Street_1__c = theRequest.SP_Street__c;
                theCMD.Telephone__c = theRequest.SP_Telephone__c;
                theCMD.Zip__c = theRequest.SP_Postal_Code__c;
            }
            
            //Copy general information
            theCMD.Additional_shipping_mark__c = theRequest.Additional_Shipping_Mark__c;
            theCMD.Additional_VAT_Number_1_Plants_Abroad__c = theRequest.Additional_VAT_Number_1__c;
            theCMD.Additional_VAT_Number_2_Plants_Abroad__c = theRequest.Additional_VAT_Number_2__c;
            theCMD.Additional_VAT_Number_3_Plants_Abroad__c = theRequest.Additional_VAT_Number_3__c;
            theCMD.Additional_VAT_Number_4_Plants_Abroad__c = theRequest.Additional_VAT_Number_4__c;
            theCMD.Additional_VAT_Number_5_Plants_Abroad__c = theRequest.Additional_VAT_Number_5__c;
            theCMD.Additional_VAT_Number_6_Plants_Abroad__c = theRequest.Additional_VAT_Number_6__c;
            theCMD.Additional_VAT_Number_7_Plants_Abroad__c = theRequest.Additional_VAT_Number_7__c;
            theCMD.Additional_VAT_Number_8_Plants_Abroad__c = theRequest.Additional_VAT_Number_8__c;
       //     theCMD.BillCurrency_PY__c = theRequest.BillCurrency_PY__c; //SFDC-684
            theCMD.Billing_Block_Sales_area__c = theRequest.Billing_Block__c;
            theCMD.Brazil_Specific_Clause__c = theRequest.Brazil_Specific_Clause__c;
            theCMD.Central_billing_block_for_customer__c = theRequest.Central_Billing_Block__c;
          //  theCMD.Central_deletion_block__c = theRequest.Central_deletion_block__c;
         //   theCMD.Central_Deletion_Flag__c = theRequest.Central_Deletion_Flag__c;
            if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'Yes')
               theCMD.Central_deletion_block__c = TRUE;
                  else if(theRequest.Central_deletion_block__c != null && theRequest.Central_deletion_block__c != '' && theRequest.Central_deletion_block__c == 'No')
               theCMD.Central_deletion_block__c = FALSE;

             if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'Yes')
               theCMD.Central_deletion_Flag__c = TRUE;
                 else if(theRequest.Central_deletion_Flag__c != null && theRequest.Central_deletion_Flag__c != '' && theRequest.Central_deletion_Flag__c == 'No')
               theCMD.Central_deletion_Flag__c = FALSE;

             if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'Yes')
               theCMD.Central_posting_block__c = TRUE;
                 else if(theRequest.Central_posting_block__c != null && theRequest.Central_posting_block__c != '' && theRequest.Central_posting_block__c == 'No')
               theCMD.Central_posting_block__c = FALSE;
               
            theCMD.Central_delivery_block__c = theRequest.Central_delivery_block__c;
            theCMD.Central_order_block__c = theRequest.Central_order_block__c;
         //   theCMD.Central_posting_block__c = theRequest.Central_posting_block__c;
          //  theCMD.Chinese_City__c = theRequest.City_Chinese__c;
            theCMD.Consolidated_Account_Code__c = theRequest.Consolidated_Account_Code__c;
            theCMD.Controlled_Party__c = 
                ( theRequest.Controlled_Party__c == 'Yes' ? true :
                    ( theRequest.Controlled_Party__c == 'No' ? false : theCMD.Controlled_Party__c )
                );    
            theCMD.Country_Additional_VAT_Number_1__c = theRequest.Country_Additional_VAT_Number_1__c;
            theCMD.Country_Additional_VAT_Number_2__c = theRequest.Country_Additional_VAT_Number_2__c;
            theCMD.Country_Additional_VAT_Number_3__c = theRequest.Country_Additional_VAT_Number_3__c;
            theCMD.Country_Additional_VAT_Number_4__c = theRequest.Country_Additional_VAT_Number_4__c;
            theCMD.Country_Additional_VAT_Number_5__c = theRequest.Country_Additional_VAT_Number_5__c;
            theCMD.Country_Additional_VAT_Number_6__c = theRequest.Country_Additional_VAT_Number_6__c;
            theCMD.Country_Additional_VAT_Number_7__c = theRequest.Country_Additional_VAT_Number_7__c;
            theCMD.Country_Additional_VAT_Number_8__c = theRequest.Country_Additional_VAT_Number_8__c;
            theCMD.CPNJ_for_Brazil__c = theRequest.CPNJ_for_Brazil__c;
            theCMD.Currency__c = theRequest.Currency__c;
            theCMD.Customer_Factory_Calendar__c = theRequest.Customer_Factory_Calendar__c;
            theCMD.Cust_pric_proc__c = theRequest.Customer_Pricing_Procedure_ZORG__c;
            theCMD.Customer_Statistics_Group__c = theRequest.Customer_Statistics_Group__c;
          //  theCMD.Deletion_Block_Company_Code__c = theRequest.Deletion_Block_Company_Code__c;
          //  theCMD.Deletion_Flag_Company_Code__c = theRequest.Deletion_Flag_Company_Code__c;
          //  theCMD.Deletion_Flag_Sales_Area__c = theRequest.Deletion_Flag_Sales_Area__c;
             if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'Yes')
               theCMD.Deletion_Block_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Block_Company_Code__c != null && theRequest.Deletion_Block_Company_Code__c != '' && theRequest.Deletion_Block_Company_Code__c == 'No')
               theCMD.Deletion_Block_Company_Code__c = FALSE;

             if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'Yes')
               theCMD.Deletion_Flag_Company_Code__c = TRUE;
             else if(theRequest.Deletion_Flag_Company_Code__c != null && theRequest.Deletion_Flag_Company_Code__c != '' && theRequest.Deletion_Flag_Company_Code__c == 'No')
               theCMD.Deletion_Flag_Company_Code__c = FALSE;

            if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'Yes')
               theCMD.Deletion_Flag_Sales_Area__c = TRUE;
             else if(theRequest.Deletion_Flag_Sales_Area__c != null && theRequest.Deletion_Flag_Sales_Area__c != '' && theRequest.Deletion_Flag_Sales_Area__c == 'No')
               theCMD.Deletion_Flag_Sales_Area__c = FALSE;
               
            theCMD.Delivery_Block_Sales_area__c = theRequest.Delivery_Block__c;
            theCMD.Delivery_Group_Ind_SH__c = theRequest.Delivery_Group_Ind_SH__c;
            theCMD.Delivery_priority__c = theRequest.Delivery_priority__c;
            theCMD.Distribution_Channel__c = theRequest.Distribution_Channel__c;
            theCMD.Distribution_Region__c = theRequest.Distribution_Region__c;
            theCMD.Division__c = theRequest.Division__c;
            theCMD.Exch_rate_type__c = theRequest.Exch_rate_type__c;
            theCMD.Freight_Forwarder__c = theRequest.Freight_Forwarder__c;
            theCMD.FunLoc_Type__c = theRequest.FunLoc_Type__c;
            theCMD.Global_Account__c = theRequest.Global_Account__c;
            theCMD.Grp_1_Sls_Channel_SP__c = theRequest.Grp_1_Sls_Channel_SP__c;
            theCMD.Grp_2_Cus_Prce_Grp_SP__c = theRequest.Grp_2_Cus_Prce_Grp_SP__c;
            theCMD.Incoterms_1__c = theRequest.Incoterms_1_ZORG__c;
            theCMD.Incoterms_2__c = theRequest.Incoterms_2_ZORG__c;
            theCMD.Label_Code__c = theRequest.Label_Code__c;
            theCMD.Label_Required__c = theRequest.Label_Required__c;
            theCMD.Language__c = theRequest.Language__c;
            theCMD.Main_shipping_mark__c = theRequest.Main_shipping_mark__c;
            theCMD.Matl_Det_Grp_SP__c = theRequest.Matl_Det_Grp_SP__c;
            theCMD.Max_partial_deliveries__c = theRequest.Max_partial_deliveries__c;
            theCMD.Military_Usage__c = theRequest.Military_Usage__c;
          //  theCMD.Chinese_Name1__c = theRequest.Chinese_Name1__c;
            theCMD.Name_1_Service_Provider__c = theRequest.Name_1_Service_Provider__c;
          //  theCMD.Chinese_Name2__c = theRequest.Chinese_Name2__c;
            theCMD.Non_I2_related_SP__c = 
                ( theRequest.Non_I2_related_SP_ZORG__c == 'Yes' ? true :
                    ( theRequest.Non_I2_related_SP_ZORG__c == 'No' ? false : theCMD.Non_I2_related_SP__c )
                );    
            theCMD.Order_Block_Sales_area__c = theRequest.Order_Block__c;
            theCMD.Order_combination__c = 
                ( theRequest.Order_Combination_ZORG__c == 'Yes' ? true :
                    ( theRequest.Order_Combination_ZORG__c == 'No' ? false : theCMD.Order_combination__c )
                );   
            theCMD.Partial_delivery_per_item__c = theRequest.Partial_delivery_per_item__c;
         //   theCMD.Posting_block_for_company_code__c = theRequest.Posting_Block_Company_Code__c;
             if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'Yes')
               theCMD.Posting_block_for_company_code__c = TRUE;
                 else if(theRequest.Posting_Block_Company_Code__c != null && theRequest.Posting_Block_Company_Code__c != '' && theRequest.Posting_Block_Company_Code__c == 'No')
               theCMD.Posting_block_for_company_code__c = FALSE;
            theCMD.Region__c = theRequest.Sales_Area_Region__c;
            theCMD.Sales_Organisation__c = theRequest.Sales_Organisation__c;
            theCMD.SDI_Screened__c = 
                ( theRequest.Screened_for_SDI__c == 'Yes' ? true :
                    ( theRequest.Screened_for_SDI__c == 'No' ? false : theCMD.SDI_Screened__c )
                );   
            theCMD.Shipping_conditions__c = theRequest.Shipping_Condition__c;
          //  theCMD.Chinese_Street__c = theRequest.Chinese_Street__c;
            theCMD.Tax_Number_1__c = theRequest.Taxes_Number_1__c;
            theCMD.Trading_Partner__c = theRequest.Trading_Partner__c;
            theCMD.Transportation_Zone__c = theRequest.Transportation_Zone_ZORG__c;
            theCMD.Unloading_Point__c = theRequest.Unloading_Point__c;
            theCMD.VAT_Registration_Number__c = theRequest.VAT_Registration_Number__c;
        }
        /***1604 SIR 706 - Modified by Scarlett - END***/
   
        
//        System.debug('DEV_DEBUG: Auto_Generate_FunLoc__c '+theCMD.Auto_Generate_FunLoc__c );
        System.debug('DEV_DEBUG: FunLoc__c ' + theCMD.FunLoc__c );
        System.debug('DEV_DEBUG: theAccountGroup '+ theAccountGroup );
        System.debug('DEV_DEBUG: theRequest.Account_Group__c ' + theRequest.Account_Group__c );
        System.debug('DEV_DEBUG: theRequest.SP_CustomerId__c ' + theRequest.SP_CustomerId__c );

        insert theCMD;
        
        /***1604 SIR 706 - Modified by Scarlett - START***/
        //ZORG SAP CMD Auto Creation
        if(theAccountGroup == 'ZORG'){
            //Sales Org List from Custom Setting
            lstZORGSalesOrgs = [
                SELECT  Name 
                FROM    Sales_Organisation_ZORG__c
            ];
            
            lstNewZORGSAPCMD = new List<SAP_CMD__c>();
            
            ZORGSAPCMD = [
                SELECT  Id, 
                        Sales_Organisation__c,
                        FunLoc__c
                FROM    SAP_CMD__c 
                WHERE   CMD_Request_Id__c =: theRequest.Id AND 
                        Sales_Organisation__c =: theRequest.Sales_Organisation__c AND 
                        RecordTypeId =: ZORG_RECORD_TYPE_ID LIMIT 1
            ];
            
            //Create ZORG SAP CMDs with different Sales Orgs
            if(lstZORGSalesOrgs.size() > 0){
                newZORG = new SAP_CMD__c();
                for(integer i = 0; i < lstZORGSalesOrgs.size(); i++){
                    newZORG = theCMD.Clone(FALSE, FALSE, FALSE, FALSE);
                    newZORG.Sales_Organisation__c = lstZORGSalesOrgs[i].Name;
                    newZORG.FunLoc__c = ZORGSAPCMD.FunLoc__c;
                    lstNewZORGSAPCMD.add(newZORG);
                   }
             //SFDC-467/455 - generate ZORG SAP CMD with slaes org NL60 when New funloc Request's sales org is US60 or JP60 or CN60
              //  if((theRequest.Sales_Organisation__c !=null && theRequest.Sales_Organisation__c.trim() == SALES_ORG_US60) || (theRequest.Sales_Organisation__c !=null && theRequest.Sales_Organisation__c.trim() == SALES_ORG_JP60) || (theRequest.Sales_Organisation__c !=null && theRequest.Sales_Organisation__c.trim() == SALES_ORG_CN60)){
                  if(theRequest.Sales_Organisation__c == 'US60 - RSO U.S.A.' || theRequest.Sales_Organisation__c == 'JP60 - MSO Japan'  || theRequest.Sales_Organisation__c == 'CN60 - MSO China CN60' ){
                    newZORG = new SAP_CMD__c();
                    newZORG = theCMD.Clone(FALSE, FALSE, FALSE, FALSE);
                    newZORG.Sales_Organisation__c = 'NL60 - RSO Europe';
                    newZORG.FunLoc__c = ZORGSAPCMD.FunLoc__c;
                    lstNewZORGSAPCMD.add(newZORG);
                  }
                
                insert lstNewZORGSAPCMD;
                
           //SFDC-428 - To create SAP CMD Request (to link multiple ZORG SAP CMDS with CMD Request)
           SAP_CMD_Request__c newZORGSapCmdReq;
           List<SAP_CMD_Request__c> lstNewZORGSapCmdRequest = new List<SAP_CMD_Request__c>();
             for(SAP_CMD__c sapCmd : lstNewZORGSAPCMD){
                    newZORGSapCmdReq = new SAP_CMD_Request__c();
                    newZORGSapCmdReq.CMD_Request__c  = sapCmd.CMD_Request_Id__c;
                    newZORGSapCmdReq.SAP_CMD__c = sapCmd.id;
                    lstNewZORGSapCmdRequest.add(newZORGSapCmdReq);
                }
             
            insert lstNewZORGSapCmdRequest;

            //Create Tax Classification for ZORG SAP CMDs
                //lstNewZORGSAPCMD = [SELECT Id, FunLoc__c FROM SAP_CMD__c WHERE CMD_Request_Id__c =: theRequest.Id AND RecordTypeId =:ZORG_RECORD_TYPE_ID];
                lstZORGTaxClassification = new List<Tax_Classification__c>();
                for(integer i = 0; i < lstNewZORGSAPCMD.size(); i++){
                  /*  if(lstNewZORGSAPCMD[i].Sales_Organisation__c == 'CN61 - MSO China'){
                        lstZORGTaxClassification.add(new Tax_Classification__c(SAP_CMD_Tax_Classification__c = lstNewZORGSAPCMD[i].Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                        lstZORGTaxClassification.add(new Tax_Classification__c(SAP_CMD_Tax_Classification__c = lstNewZORGSAPCMD[i].Id, Country__c = 'HK - Hong Kong', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    }*/
                    if(lstNewZORGSAPCMD[i].Sales_Organisation__c == 'CN64 - Tianjin'){
                        lstZORGTaxClassification.add(new Tax_Classification__c(SAP_CMD_Tax_Classification__c = lstNewZORGSAPCMD[i].Id, Country__c = 'CN - China', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    }
                /*    if(lstNewZORGSAPCMD[i].Sales_Organisation__c == 'MY61 - NXP Seremban'){
                        lstZORGTaxClassification.add(new Tax_Classification__c(SAP_CMD_Tax_Classification__c = lstNewZORGSAPCMD[i].Id, Country__c = 'MY - Malaysia', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    }
                    if(lstNewZORGSAPCMD[i].Sales_Organisation__c == 'PH62 - NXP Cabuyao'){
                        lstZORGTaxClassification.add(new Tax_Classification__c(SAP_CMD_Tax_Classification__c = lstNewZORGSAPCMD[i].Id, Country__c = 'PH - Philippines', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    } */
                    if(lstNewZORGSAPCMD[i].Sales_Organisation__c == 'TH61 - NXP Thailand'){
                        lstZORGTaxClassification.add(new Tax_Classification__c(SAP_CMD_Tax_Classification__c = lstNewZORGSAPCMD[i].Id, Country__c = 'TH - Thailand', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    }
                    if(lstNewZORGSAPCMD[i].Sales_Organisation__c == 'TW61 - NXP Kaohsiung'){
                        lstZORGTaxClassification.add(new Tax_Classification__c(SAP_CMD_Tax_Classification__c = lstNewZORGSAPCMD[i].Id, Country__c = 'TW - Taiwan', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                    }
                    if(lstNewZORGSAPCMD[i].Sales_Organisation__c == 'US63 - NXP Austin'){
                    lstZORGTaxClassification.add(new Tax_Classification__c(SAP_CMD_Tax_Classification__c = lstNewZORGSAPCMD[i].Id, Country__c = 'IN - India', Tax_Category__c = 'MWST', Tax_Classification__c = '1'));
                        lstZORGTaxClassification.add(new Tax_Classification__c(SAP_CMD_Tax_Classification__c = lstNewZORGSAPCMD[i].Id, Country__c = 'US - USA', Tax_Category__c = 'UTXJ', Tax_Classification__c = '1'));
                    }
                }
                insert lstZORGTaxClassification;
            }
        }
        /***1604 SIR 706 - Modified by Scarlett - END***/
        
        
        
        //Copy Tax Classification for SAP CMD (Account group Z010 & Z004 are not required)
        lstTaxClassification = new List<Tax_Classification__c>();
        lstTaxClassification = [
            SELECT  Id,
                    CMD_Request__c,
                    Country__c,
                    Tax_Classification__c,
                    Tax_Category__c
            FROM    Tax_Classification__c
            WHERE   CMD_Request__c = :theRequest.Id AND CMD_Request__c != NULL AND CMD_Request__c != '' //1610 - SIR 1273 - Modified by Scarlett
        ];
        
        lstNewTaxClassification = new List<Tax_Classification__c>();
                                                                 
        if(lstTaxClassification.size() > 0 && theAccountGroup != 'Z004' && theAccountGroup != 'Z010'){           
            for(Tax_Classification__c temp : lstTaxClassification){
                Tax_Classification__c newTax = new Tax_Classification__c(
                    SAP_CMD_Tax_Classification__c = theCMD.Id,
                    Country__c = temp.Country__c,
                    Tax_Classification__c = temp.Tax_Classification__c,
                    Tax_Category__c = temp.Tax_Category__c
                );
                try{
                    lstNewTaxClassification.add(newTax);
                    newTax = null;
                }catch (Exception e){
                    system.debug('Error Message: ' + e + '*********');
                }               
            }
            insert lstNewTaxClassification;
        }//if
        
     /** Added below code as part of 1603 release -SIR 499 => To copy ZA/ZS values from CMD New request form to SAP CMD as partner functions automatically. **/
     
        List<Partner_Function__c> lstNewPartnerFunction = new List<Partner_Function__c>();
        
         ZA_ZS_RECORD_TYPE_ID = [Select Id, Name,DeveloperName From RecordType Where IsActive=true AND 
                                (SobjectType = 'Partner_Function__c' AND DeveloperName =:ZA_ZS_RECORD_TYPE) limit 1].id;
                       
        if((theAccountGroup == 'Z001' || theAccountGroup == 'Z002'|| theAccountGroup == 'Z012'))
        {
             if(theRequest.Customer_Service_ZA__c != '' && theRequest.Customer_Service_ZA__c != null)
             {                 
              Partner_Function__c newPartnerFunction = new  Partner_Function__c();
              newPartnerFunction.RecordTypeId = ZA_ZS_RECORD_TYPE_ID;
              newPartnerFunction.SAP_Customer__c = theCMD.Id;
              newPartnerFunction.Partner_Function_Type__c = Partner_Function_Type_ZA;
              newPartnerFunction.Person_Name__c = theRequest.Customer_Service_ZA__c;              
             // insert new Partner Function for ZA;
              lstNewPartnerFunction.add(newPartnerFunction);
             }
            
            if(theRequest.Sales_Rep_ZS__c != '' && theRequest.Sales_Rep_ZS__c != null)
             {                 
              Partner_Function__c newPartnerFunction = new  Partner_Function__c();
              newPartnerFunction.RecordTypeId = ZA_ZS_RECORD_TYPE_ID;
              newPartnerFunction.SAP_Customer__c = theCMD.Id;
              newPartnerFunction.Partner_Function_Type__c = Partner_Function_Type_ZS;
              newPartnerFunction.Person_Name__c = theRequest.Sales_Rep_ZS__c;              
             // insert new Partner Function for ZS;
              lstNewPartnerFunction.add(newPartnerFunction);
             }
            insert lstNewPartnerFunction;
        }  /* SIR 499 - code ended */  
        
        /***1604 Release SIR 706 - Modified by Scarlett - START***/
        RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID = [Select Id, Name,DeveloperName From RecordType Where IsActive=true AND 
                                (SobjectType = 'Partner_Function__c' AND DeveloperName =: RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE) limit 1].id;
        
        if(theAccountGroup == 'ZORG'){
            //Add Partner Function Records
            lstNewPartnerFunction.add(
               new Partner_Function__c(
               RecordTypeId = RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID, 
               SAP_Customer__c = theCMD.Id, 
               Partner_Function_Type__c = Partner_Function_Type_SP, 
               FunLoc__c = ZORGSAPCMD.FunLoc__c)
            );
            lstNewPartnerFunction.add(
               new Partner_Function__c(
               RecordTypeId = RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID, 
               SAP_Customer__c = theCMD.Id, 
               Partner_Function_Type__c = Partner_Function_Type_SH, 
               FunLoc__c = ZORGSAPCMD.FunLoc__c)
            );
            for(integer i = 0; i < lstNewZORGSAPCMD.size(); i++){
              lstNewPartnerFunction.add(
                  new Partner_Function__c(
                  RecordTypeId = RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID, 
                  SAP_Customer__c = lstNewZORGSAPCMD[i].Id, 
                  Partner_Function_Type__c = Partner_Function_Type_SP, 
                  FunLoc__c = lstNewZORGSAPCMD[i].Funloc__c)
              );
              lstNewPartnerFunction.add(
                  new Partner_Function__c(
                  RecordTypeId = RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID, 
                  SAP_Customer__c = lstNewZORGSAPCMD[i].Id, 
                  Partner_Function_Type__c = Partner_Function_Type_SH, 
                  FunLoc__c = lstNewZORGSAPCMD[i].Funloc__c)
              );
            }
            /*
            //Add Partner Function records (ZC/ZD) for ZORG SAP CMDs
            lstNewPartnerFunction.add(
               new Partner_Function__c(
               RecordTypeId = RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID, 
               SAP_Customer__c = theCMD.Id, 
               Partner_Function_Type__c = Partner_Function_Type_ZC, 
               FunLoc__c = ZORGSAPCMD.FunLoc__c)
            );
            lstNewPartnerFunction.add(
               new Partner_Function__c(
               RecordTypeId = RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID, 
               SAP_Customer__c = theCMD.Id, 
               Partner_Function_Type__c = Partner_Function_Type_ZD, 
               FunLoc__c = ZORGSAPCMD.FunLoc__c)
            );
            for(integer i = 0; i < lstNewZORGSAPCMD.size(); i++){
              lstNewPartnerFunction.add(
                  new Partner_Function__c(
                  RecordTypeId = RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID, 
                  SAP_Customer__c = lstNewZORGSAPCMD[i].Id, 
                  Partner_Function_Type__c = Partner_Function_Type_ZC, 
                  FunLoc__c = lstNewZORGSAPCMD[i].Funloc__c)
              );
              lstNewPartnerFunction.add(
                  new Partner_Function__c(
                  RecordTypeId = RE_RG_WE_AG_ZC_ZD_ZI_RECORD_TYPE_ID, 
                  SAP_Customer__c = lstNewZORGSAPCMD[i].Id, 
                  Partner_Function_Type__c = Partner_Function_Type_ZD, 
                  FunLoc__c = lstNewZORGSAPCMD[i].Funloc__c)
              );
            }
            */
            insert lstNewPartnerFunction;   
        }

        /***1604 Release SIR 706 - Modified by Scarlett - END***/
     
        PageReference SAP_CMD_Page = new PageReference('/' + theCMD.Id);
        SAP_CMD_Page.setRedirect(true);
        return SAP_CMD_Page;
    }
}