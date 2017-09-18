/* Violate Salesforce.com best practice, there's no DML in the loop
 * 
@Modified By :       Scarlett Kang
@Modified Date:    20 Mar 2015
@Description:      Change the field type of SAP_CMD__c.Industry_Segment__c to formula and not convert Industry_Segment__c to SAP CMD Object
                   Change mapping field: CMD_Request__c.Sales_Area_Region__c -> SAP_CMD__c.Region__c
---------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    22 Jul 2015
@Description:      1507 Hot-Fix. Stop copying Industry_Sub_Segment__c to SAP CMD
---------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    04 Aug 2015
@Description:      1508 Release. Copy Label Code to SAP CMD based on the value of Label Code Required
---------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    02 Oct 2015
@Description:      1510 Release - SIR 404. SAP CMD - ZA & ZS change - from manual to auto (for edit funloc request)
---------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      29 Feb 2016
@Description:        1603 Release (SIR 499) - Copy ZA/ZS as partner functions to related SAP CMD based on the New CMD Request form.
                     1603 Release (SIR 732) - To Improve existing CMD Codes(Hardcoding id's, to reduce redundant code etc.) 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Shridevi   
@Modified Date:      April 20, 2016 
@Description:        1605 Release (SIR 534) - To Copy the value of the field  No_of_days_for_Early_Shipment__c from cmd Request to SAP cmd for Ship-To flag.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      August 16, 2016 
@Description:        1609 Release (SIR 1138, 1102, 990) - To set Sap_Cmd__C.Matl_Det_Grp_SP__c to 'BLANK' when CMD_Request__c.Matl_Det_Grp_SP__c='set to BLANK'
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      21 Jun 2017
@Description:        1707 Release (SFDC 585) -  To add new fields 'Version ID for internationla addresses' & 'Tax Number 5' for MSO China project
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      17 Jul 2017 
@Description:        1708 Release (SFDC 684) - SAP CMD - BillCurrency-PY should be on SAP CMD layout
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      08 Sep 2017 
@Description:        1709 Release (SFDC 729) - Extended batch:convert CMD Request to SAP CMD functionality to MANU/SBE Edit funloc.
***************************************************************************************************************************************************************/


public with sharing class Convert_Request_to_SAP_CMD{
    
    Datetime timeNow = datetime.now();//.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
    //public SAP_CMD__c SAP;
    public List<CMD_Request__c> theRequests;
    public List<Partner_Function__c> lstNewPartnerFunction{get; set;} 
    private static final string Partner_Function_Type_ZA= 'ZA - Customer Service Rep';
    private static final string Partner_Function_Type_ZS= 'ZS - Sales Person';
    private static final string ZA_ZS_RECORD_TYPE = 'ZA_ZS';
    Public Static Id ZA_ZS_RECORD_TYPE_ID;

  public Convert_Request_to_SAP_CMD(){
        theRequests = [
            SELECT  Id, 
                    Request_Status__c,
                    Effective_Date__c,
                    Funloc__c,
                    Funloc_SAP_CMD__c,
                    Sales_Organisation__c,
                    FLAG_Sold_to__c,
                    FLAG_Ship_to__c,
                    FLAG_Bill_to__c,
                    FLAG_Payer__c,
                    FLAG_ZI__c,
                    Name_Legal_Name__c,
                    Name_Line_2__c,
                    Name_Line_3__c,
                    Name_Line_4__c,
                    City__c,
                    Country__c,
                    Street_4__c,
                    State_Province__c,
                    Postal_Code__c,
                    PO_Box__c,
                    PO_Box_City__c,
                    PO_Box_Postal_Code__c,
                    EMail__c,
                    Fax__c,
                    Telephone__c,
                    Transportation_Zone__c,
                    Taxes_Number_1__c,
                    VAT_Registration_Number__c,
//                    Base_Region__c,
                    Global_Account__c,
                    PD_Key_Account__c,
                    Customer_Factory_Calendar__c,
                    Controlled_Party__c,
                    Military_Usage__c,
                    Screened_for_SDI__c,
                    Consolidated_Account_Code__c,
                    Delivery_Group_Ind_SH__c,
                    Fix_Price_Ind_SP__c,
                    Industry_Segment__c,
                    Industry_Sub_Segment__c,
                    Pull_Up_OK_SH__c,
                    Rounding_Rule_SH__c,
                    Company_Code__c,
                    Lockbox__c,
                    Payment_Credit_Memo__c,
                    Terms_of_Payment__c,
                    Accept_Dupl_PO_SP__c,
                    Acct_at_cust__c,
                    C_GAD_Indicator_SH__c,
                    Ch_dupl_PO_item_SP__c,
                    Currency__c,
                    Cust_pric_proc__c,
                    Fixed_Currency_Ind_SP__c,
                    Non_I2_related_SP__c,
                    Sales_Area_Region__c,
                    Reprice_Basis__c,
                    S_O_Sub_Group__c,
                    Sales_Office__c,
                    Delivery_priority__c,
                    Max_partial_deliveries__c,
                    Order_Combination__c,
                    Partial_delivery_per_item__c,
                    Shipping_Condition__c,
                    Incoterms_1__c,
                    Incoterms_2__c,
                    Payment_Guarantee_Procedure__c,
                    Terms_of_Payment_Sales__c,
                    BillCurrency_PY__c,
                    Grp_1_Sls_Channel_SP__c,
                    Grp_2_Cus_Prce_Grp_SP__c,
                    Matl_Det_Grp_SP__c,
                    Additional_Shipping_Mark__c,
                    Brazil_Specific_Clause__c,
                    CPNJ_for_Brazil__c,
                    Main_shipping_mark__c,
                    Billing_Block__c,
                    Delivery_Block__c,
                    Order_Block__c,
                    Name_1_Service_Provider__c,
                    Street_House_Number__c,
                    Language__c,
                    City_Chinese__c,
                    Chinese_Name1__c,
                    Chinese_Name2__c,
                    Chinese_Street__c,
                    Version_ID_for_International_Addresses__c,
                    Tax_Number_5__c,
                    Additional_VAT_Number_1__c,
                    Additional_VAT_Number_2__c,
                    Additional_VAT_Number_3__c,
                    Additional_VAT_Number_4__c,
                    Additional_VAT_Number_5__c,
                    Additional_VAT_Number_6__c,
                    Additional_VAT_Number_7__c,
                    Additional_VAT_Number_8__c,
                    Country_Additional_VAT_Number_1__c,
                    Country_Additional_VAT_Number_2__c,
                    Country_Additional_VAT_Number_3__c,
                    Country_Additional_VAT_Number_4__c,
                    Country_Additional_VAT_Number_5__c,
                    Country_Additional_VAT_Number_6__c,
                    Country_Additional_VAT_Number_7__c,
                    Country_Additional_VAT_Number_8__c,
                    Trading_Partner__c,
                    Customer_Category__c,
                    Unloading_Point__c,
                    Reconciliation_Account__c,
                    Sorting_key_for_assignment_no__c,
                    Indicator_Record_Payment_History__c,
                    Key_for_Payment_Grouping__c,
                    Reason_Code_Conversion__c,
                    Selection_Rule_for_Payment_Advice__c,
                    Tolerance_Group__c,
                    Account_memo__c,
                    Accounting_Clerk__c,
                    Act_clerk_fax_number__c,
                    Act_clerk_internet_address__c,
                    Act_clerk_tel_no__c,
                    Ind_period_account_statement__c,
                    Our_account_at_customer__c,
                    User_at_customer__c,
                    Customer_Statistics_Group__c,
                    Distribution_Channel__c,
                    Distribution_Region__c,
                    Division__c,
                    Exch_rate_type__c,
                    Sales_district__c,
                    Acct_assgmt_group__c,
//                    Credit_Control_Area__c,
                    Freight_Forwarder__c,
                    Central_Billing_Block__c,
                    Central_delivery_block__c,
                    Central_order_block__c,
                    Central_posting_block__c,
                    Posting_Block_Company_Code__c,
                    Central_deletion_block__c,
                    Central_Deletion_Flag__c,
                    Deletion_Block_Company_Code__c,
                    Deletion_Flag_Company_Code__c,
                    Deletion_Flag_Sales_Area__c,
                    FunLoc_Type__c,
                    Update_SAP_CMD_Failed__c,
                    Approval_Submission_Date__c,
                    Global_Customer_ID__c,
                    GID__c,
                    Label_Code__c,
                    Label_Required__c,
            /***1510 Release - Modified by Scarlett***/
                    Customer_Service_ZA__c,
                    Sales_Rep_ZS__c,
            /***1510 Release - Modified by Scarlett - END***/
            /**** SIR 534 - Modified By Shridevi************/
                    No_of_days_for_Early_Shipment__c
            /*****SIR 534 - Modified By Shridevi -END*******/
            FROM    CMD_Request__c
            WHERE   (Request_Status__c = 'Approved'  
                     AND (RecordType.Name = 'SAP Funloc Edit Request' OR RecordType.Name = 'SAP MANU Funloc Edit request' OR RecordType.Name = 'SAP SBE Funloc Edit request')
                     AND Update_SAP_CMD_Failed__c = False) AND (Effective_Date__c <=: timeNow OR Effective_Date__c = null)
            ORDER BY Approval_Submission_Date__c ASC LIMIT 10000
        ];
        
        List<SAP_CMD__c> theCMDs = new List<SAP_CMD__c>();

        Map<Id, CMD_Request__c> mapRequestAll = new Map<Id, CMD_Request__c>();
        For(CMD_Request__c request : theRequests){
            if(mapRequestAll.containsKey(request.Funloc_SAP_CMD__c) == false){
                mapRequestAll.put(request.Funloc_SAP_CMD__c, request);
            }
            else if(mapRequestAll.containsKey(request.Funloc_SAP_CMD__c) == True){
                CMD_Request__c existingRequest = new CMD_Request__c();
                existingRequest = mapRequestAll.get(request.Funloc_SAP_CMD__c);
               if(Date.valueOf(existingRequest.Approval_Submission_Date__c) > Date.valueOf(request.Approval_Submission_Date__c)){
                  mapRequestAll.remove(existingRequest.Funloc_SAP_CMD__c);
                    mapRequestAll.put(request.Funloc_SAP_CMD__c, request);
                    
                }
             }
        }
        
        List<CMD_Request__c> testRequest = new List<CMD_Request__c>();
        testRequest = mapRequestAll.values();
       
        List<SAP_CMD__c> SAPCMDCanBeUpdated = [
            SELECT  Id, Status__c, Customer_FunLoc_Number__c, Cred_contr_area__c 
            FROM    SAP_CMD__c 
            WHERE   (Status__c = 'Ready for Approval' 
            //OR      Status__c = 'Approved and Failed Distribution' 
            OR      Status__c = 'Approved and Distributed')
            AND     CMD_Request_Id__c = null
        ];
        
        Map<String, String> mapSAPCMD = new Map<String,String>();
        
        for(SAP_CMD__c SAP : SAPCMDCanBeUpdated)
            mapSAPCMD.put(SAP.Id, SAP.Status__c);  
        system.debug('checkmap' + mapSAPCMD);
         
        /***1510 Release - Modified by Scarlett***/
        List<Partner_Function__c> lstPartnerFunction = [
            SELECT  Id, 
                    SAP_Customer__c,
                    Partner_Function_Type__c,
                    Person_Name__c
            FROM    Partner_Function__c
            WHERE   RecordType.DeveloperName =: ZA_ZS_RECORD_TYPE
        ];
        
        ZA_ZS_RECORD_TYPE_ID = [Select Id, Name,DeveloperName From RecordType Where IsActive=true AND 
                                (SobjectType = 'Partner_Function__c' AND DeveloperName =:ZA_ZS_RECORD_TYPE) limit 1].id;

        
        //SAP CMD Id -> Partner Function Type -> Partner Function Id
        Map<String, Map<String, String>> mapSAPCMDtoPartnerFunction = new Map<String, Map<String,String>>();

        for(Partner_Function__c objPartnerFunction : lstPartnerFunction){
            if(mapSAPCMDtoPartnerFunction.containsKey(objPartnerFunction.SAP_Customer__c)){
                mapSAPCMDtoPartnerFunction.get(objPartnerFunction.SAP_Customer__c).put(objPartnerFunction.Partner_Function_Type__c, objPartnerFunction.Id);
            }
            else{
                mapSAPCMDtoPartnerFunction.put(objPartnerFunction.SAP_Customer__c, new Map<String, String> {objPartnerFunction.Partner_Function_Type__c => objPartnerFunction.Id});
            }
        }
        
        //Partner Function Update List
        List<Partner_Function__c> lstPartnerFunctionUpdate = new List<Partner_Function__c>();
        /***1510 Release - Modified by Scarlett - END***/
        
        //for(CMD_Request__c request : theRequests){
        for(CMD_Request__c request : mapRequestAll.values()){
        
            if(mapSAPCMD.containsKey(request.Funloc_SAP_CMD__c) == True){
            System.debug('in loop no_of_days_for_early_shipment:::'+request.No_of_days_for_Early_Shipment__c);
                SAP_CMD__c SAP = new SAP_CMD__c(Id = request.Funloc_SAP_CMD__c);
                SAP.CMD_Request_Id__c = request.Id;
                SAP.CMD_Request_ID_Text__c = request.id;
                SAP.Status__c = 'Approved';
                if(request.Global_Customer_ID__c != null && request.Global_Customer_ID__c != '')
                    SAP.HUB_Customer__c = request.Global_Customer_ID__c;

     
  /****************************************************** If Conditions common for all Flags(SP,SH,BP,PY,ZI)******************************************/   
    If(request.FLAG_Sold_to__c == True||request.FLAG_Ship_to__c == True||request.FLAG_Bill_to__c == True||request.FLAG_Payer__c == True||request.FLAG_ZI__c == True){         
                        
                    if(request.Name_Legal_Name__c != null && request.Name_Legal_Name__c != '' ) 
                        SAP.Legal_Name__c = request.Name_Legal_Name__c;            
                    if(request.Name_Line_2__c != null && request.Name_Line_2__c != '' ) 
                        SAP.Name_2__c = request.Name_Line_2__c;
                    if(request.Name_Line_3__c != null && request.Name_Line_3__c != '' ) 
                        SAP.Name_3__c = request.Name_Line_3__c;
                    if(request.Name_Line_4__c != null && request.Name_Line_4__c != '' ) 
                        SAP.Name_4__c = request.Name_Line_4__c;                    
                    if(request.Name_1_Service_Provider__c != null && request.Name_1_Service_Provider__c != '' ) 
                        SAP.Name_1_Service_Provider__c = request.Name_1_Service_Provider__c;
                    if(request.City__c != null && request.City__c != '' )   
                        SAP.City__c = request.City__c;
                    if(request.Country__c != null && request.Country__c != '' ) 
                        SAP.Country__c = request.Country__c;
                    if(request.Street_4__c != null && request.Street_4__c != '' )   
                        SAP.Street_2__c = request.Street_4__c;
                    if(request.State_Province__c != null && request.State_Province__c != '' )   
                        SAP.State_Province__c = request.State_Province__c;
                    if(request.Street_House_Number__c!= null && request.Street_House_Number__c!= '' )   
                        SAP.Street_1__c = request.Street_House_Number__c;
                    if(request.Postal_Code__c != null && request.Postal_Code__c != '' ) 
                        SAP.Zip__c = request.Postal_Code__c;
                    if(request.PO_Box__c != null && request.PO_Box__c != '' )   
                        SAP.PO_Box__c = request.PO_Box__c;
                    if(request.PO_Box_City__c != null && request.PO_Box_City__c != '' ) 
                        SAP.PO_Box_City__c = request.PO_Box_City__c;
                    if(request.PO_Box_Postal_Code__c != null && request.PO_Box_Postal_Code__c != '' )   
                        SAP.PO_Box_Postal_Code__c = request.PO_Box_Postal_Code__c;
                    if(request.EMail__c != null && request.EMail__c != '' ) 
                        SAP.Email__c = request.EMail__c;
                    if(request.Fax__c != null && request.Fax__c != '' ) 
                        SAP.Fax__c = request.Fax__c;
                    if(request.Telephone__c != null && request.Telephone__c != '' ) 
                        SAP.Telephone__c = request.Telephone__c;
                    if(request.Language__c != null && request.Language__c != '' )   
                        SAP.Language__c = request.Language__c;
                  /*  if(request.City_Chinese__c != null && request.City_Chinese__c != '' )   
                        SAP.Chinese_City__c = request.City_Chinese__c;
                    if(request.Chinese_Name1__c != null && request.Chinese_Name1__c != '' ) 
                        SAP.Chinese_Name1__c = request.Chinese_Name1__c;
                    if(request.Chinese_Name2__c != null && request.Chinese_Name2__c != '' ) 
                        SAP.Chinese_Name2__c = request.Chinese_Name2__c;
                    if(request.Chinese_Street__c != null && request.Chinese_Street__c != '' )   
                        SAP.Chinese_Street__c = request.Chinese_Street__c;*/

                    if(request.Controlled_Party__c != null && request.Controlled_Party__c != ''){
                                            if(request.Controlled_Party__c == 'Yes')
                                                SAP.Controlled_Party__c = true;
                                            if(request.Controlled_Party__c == 'No')
                                                SAP.Controlled_Party__c = false;               
                                        }
                    if(request.Military_Usage__c != null && request.Military_Usage__c != '') 
                                            SAP.Military_Usage__c = request.Military_Usage__c;
                     
                    if(request.Screened_for_SDI__c != null && request.Screened_for_SDI__c != ''){
                                            if(request.Screened_for_SDI__c == 'Yes')
                                                SAP.SDI_Screened__c = true;
                                            if(request.Screened_for_SDI__c == 'No')
                                                SAP.SDI_Screened__c = false;
                                        }                    


                if(request.Distribution_Channel__c != null && request.Distribution_Channel__c != '') 
                            SAP.Distribution_Channel__c = request.Distribution_Channel__c;
    
                if(request.Division__c != null && request.Division__c != '') 
                                        SAP.Division__c = request.Division__c;
                
                if(request.Sales_Organisation__c != null && request.Sales_Organisation__c != '') 
                                        SAP.Sales_Organisation__c = request.Sales_Organisation__c;
                
                if(request.Additional_Shipping_Mark__c != null && request.Additional_Shipping_Mark__c != '' )   
                                        SAP.Additional_shipping_mark__c = request.Additional_Shipping_Mark__c;
                
                if(request.Brazil_Specific_Clause__c != null && request.Brazil_Specific_Clause__c != '') 
                                        SAP.Brazil_Specific_Clause__c = request.Brazil_Specific_Clause__c;
     
                if(request.CPNJ_for_Brazil__c != null && request.CPNJ_for_Brazil__c != '') 
                                        SAP.CPNJ_for_Brazil__c = request.CPNJ_for_Brazil__c;
                
                if(request.Freight_Forwarder__c != null && request.Freight_Forwarder__c != '' ) 
                                        SAP.Freight_Forwarder__c = request.Freight_Forwarder__c;
                
                if(request.Main_shipping_mark__c != null && request.Main_shipping_mark__c != '' )   
                                        SAP.Main_shipping_mark__c = request.Main_shipping_mark__c;
                
                if(request.Billing_Block__c != null && request.Billing_Block__c != '' ) 
                                        SAP.Billing_Block_Sales_area__c = request.Billing_Block__c;
                
                if(request.Central_Billing_Block__c != null && request.Central_Billing_Block__c != '') 
                                        SAP.Central_billing_block_for_customer__c = request.Central_Billing_Block__c;
                
                if(request.Central_delivery_block__c != null && request.Central_delivery_block__c != '' )   
                                        SAP.Central_delivery_block__c = request.Central_delivery_block__c;
                
                if(request.Central_order_block__c != null && request.Central_order_block__c != '') 
                                        SAP.Central_order_block__c = request.Central_order_block__c;
                                      //  SAP.Central_posting_block__c = request.Central_posting_block__c;
                     if(request.Central_posting_block__c != null && request.Central_posting_block__c != '' && request.Central_posting_block__c == 'Yes')
                               SAP.Central_posting_block__c = TRUE;
                     else if(request.Central_posting_block__c != null && request.Central_posting_block__c != '' && request.Central_posting_block__c == 'No')
                               SAP.Central_posting_block__c = FALSE;

                
                if(request.Delivery_Block__c != null && request.Delivery_Block__c != '') 
                                        SAP.Delivery_Block_Sales_area__c = request.Delivery_Block__c;
                
                if(request.Order_Block__c != null && request.Order_Block__c != '') 
                                        SAP.Order_Block_Sales_area__c = request.Order_Block__c;
                                      /*  SAP.Central_deletion_block__c = request.Central_deletion_block__c;
                                        SAP.Central_Deletion_Flag__c = request.Central_Deletion_Flag__c;
                                        SAP.Deletion_Flag_Sales_Area__c = request.Deletion_Flag_Sales_Area__c; */
                       if(request.Central_deletion_block__c != null && request.Central_deletion_block__c != '' && request.Central_deletion_block__c == 'Yes')
                           SAP.Central_deletion_block__c = TRUE;
                         else if(request.Central_deletion_block__c != null && request.Central_deletion_block__c != '' && request.Central_deletion_block__c == 'No')
                           SAP.Central_deletion_block__c  = FALSE;

                       if(request.Central_deletion_Flag__c != null && request.Central_deletion_Flag__c != '' && request.Central_deletion_Flag__c == 'Yes')
                           SAP.Central_deletion_Flag__c = TRUE;
                         else if(request.Central_deletion_Flag__c != null && request.Central_deletion_Flag__c != '' && request.Central_deletion_Flag__c == 'No')
                           SAP.Central_deletion_Flag__c = FALSE;
               
                         if(request.Deletion_Flag_Sales_Area__c != null && request.Deletion_Flag_Sales_Area__c != '' && request.Deletion_Flag_Sales_Area__c == 'Yes')
                               SAP.Deletion_Flag_Sales_Area__c  = TRUE;
                          else if(request.Deletion_Flag_Sales_Area__c != null && request.Deletion_Flag_Sales_Area__c != '' && request.Deletion_Flag_Sales_Area__c == 'No')
                               SAP.Deletion_Flag_Sales_Area__c = FALSE;

                                        
                
                if(request.FunLoc_Type__c != null && request.FunLoc_Type__c != '') 
                                        SAP.FunLoc_Type__c = request.FunLoc_Type__c;
    }                    
/****************************************************** If Conditions common for all Flags Ends(SP,SH,BP,PY,ZI)******************************************/ 


/*********************** Start - Fields specific to Sold-To Type *************************************/
                If(request.FLAG_Sold_to__c == True)
                {

                    if(request.Additional_VAT_Number_1__c != null && request.Additional_VAT_Number_1__c != '' ) 
                        SAP.Additional_VAT_Number_1_Plants_Abroad__c = request.Additional_VAT_Number_1__c;
                    if(request.Additional_VAT_Number_2__c != null && request.Additional_VAT_Number_2__c != '' ) 
                        SAP.Additional_VAT_Number_2_Plants_Abroad__c = request.Additional_VAT_Number_2__c;
                    if(request.Additional_VAT_Number_3__c != null && request.Additional_VAT_Number_3__c != '' ) 
                        SAP.Additional_VAT_Number_3_Plants_Abroad__c = request.Additional_VAT_Number_3__c;
                    if(request.Additional_VAT_Number_4__c != null && request.Additional_VAT_Number_4__c != '' ) 
                        SAP.Additional_VAT_Number_4_Plants_Abroad__c = request.Additional_VAT_Number_4__c;
                    if(request.Additional_VAT_Number_5__c != null && request.Additional_VAT_Number_5__c != '' ) 
                        SAP.Additional_VAT_Number_5_Plants_Abroad__c = request.Additional_VAT_Number_5__c;
                    if(request.Additional_VAT_Number_6__c != null && request.Additional_VAT_Number_6__c != '' ) 
                        SAP.Additional_VAT_Number_6_Plants_Abroad__c = request.Additional_VAT_Number_6__c;
                    if(request.Additional_VAT_Number_7__c != null && request.Additional_VAT_Number_7__c != '' ) 
                        SAP.Additional_VAT_Number_7_Plants_Abroad__c = request.Additional_VAT_Number_7__c;
                    if(request.Additional_VAT_Number_8__c != null && request.Additional_VAT_Number_8__c != '' ) 
                        SAP.Additional_VAT_Number_8_Plants_Abroad__c = request.Additional_VAT_Number_8__c;
                    if(request.Country_Additional_VAT_Number_1__c != null && request.Country_Additional_VAT_Number_1__c != '' ) 
                        SAP.Country_Additional_VAT_Number_1__c = request.Country_Additional_VAT_Number_1__c;
                    if(request.Country_Additional_VAT_Number_2__c != null && request.Country_Additional_VAT_Number_2__c != '' ) 
                        SAP.Country_Additional_VAT_Number_2__c = request.Country_Additional_VAT_Number_2__c;
                    if(request.Country_Additional_VAT_Number_3__c != null && request.Country_Additional_VAT_Number_3__c != '' ) 
                        SAP.Country_Additional_VAT_Number_3__c = request.Country_Additional_VAT_Number_3__c;
                    if(request.Country_Additional_VAT_Number_4__c != null && request.Country_Additional_VAT_Number_4__c != '' ) 
                        SAP.Country_Additional_VAT_Number_4__c = request.Country_Additional_VAT_Number_4__c;
                    if(request.Country_Additional_VAT_Number_5__c != null && request.Country_Additional_VAT_Number_5__c != '' ) 
                        SAP.Country_Additional_VAT_Number_5__c = request.Country_Additional_VAT_Number_5__c;
                    if(request.Country_Additional_VAT_Number_6__c != null && request.Country_Additional_VAT_Number_6__c != '' ) 
                        SAP.Country_Additional_VAT_Number_6__c = request.Country_Additional_VAT_Number_6__c;
                    if(request.Country_Additional_VAT_Number_7__c != null && request.Country_Additional_VAT_Number_7__c != '' ) 
                        SAP.Country_Additional_VAT_Number_7__c = request.Country_Additional_VAT_Number_7__c;
                    if(request.Country_Additional_VAT_Number_8__c != null && request.Country_Additional_VAT_Number_8__c != '' ) 
                        SAP.Country_Additional_VAT_Number_8__c = request.Country_Additional_VAT_Number_8__c;



            if(request.Trading_Partner__c != null && request.Trading_Partner__c != '' ) 
                                    SAP.Trading_Partner__c = request.Trading_Partner__c;
            
            if(request.Fix_Price_Ind_SP__c != null && request.Fix_Price_Ind_SP__c != '' )   
                                    SAP.Fix_Price_Ind_SP__c = request.Fix_Price_Ind_SP__c;
            
            if(request.Accept_Dupl_PO_SP__c != null && request.Accept_Dupl_PO_SP__c != ''){
                                    if(request.Accept_Dupl_PO_SP__c == 'Yes')
                                        SAP.Accept_Dupl_PO_SP__c = true;
                                    if(request.Accept_Dupl_PO_SP__c == 'No')
                                        SAP.Accept_Dupl_PO_SP__c = false;
                                }  
            
            if(request.Acct_at_cust__c != null && request.Acct_at_cust__c != '' )   
                                    SAP.Acct_at_cust__c = request.Acct_at_cust__c; 
            
            if(request.Ch_dupl_PO_item_SP__c != null && request.Ch_dupl_PO_item_SP__c != ''){
                                    if(request.Ch_dupl_PO_item_SP__c == 'Yes')
                                        SAP.Ch_dupl_PO_item_SP__c = true;
                                    if(request.Ch_dupl_PO_item_SP__c == 'No')
                                        SAP.Ch_dupl_PO_item_SP__c = false;
                                }   
            if(request.Currency__c != null && request.Currency__c != '' )   
                                    SAP.Currency__c = request.Currency__c;
            if(request.Cust_pric_proc__c != null && request.Cust_pric_proc__c != '' )   
                                    SAP.Cust_pric_proc__c = request.Cust_pric_proc__c;
            if(request.Exch_rate_type__c != null && request.Exch_rate_type__c != '' )   
                                    SAP.Exch_rate_type__c = request.Exch_rate_type__c; 
            
            if(request.Fixed_Currency_Ind_SP__c != null && request.Fixed_Currency_Ind_SP__c != ''){
                                    if(request.Fixed_Currency_Ind_SP__c == 'Yes')
                                        SAP.Fixed_Currency_Ind_SP__c = true;
                                    if(request.Fixed_Currency_Ind_SP__c == 'No')
                                        SAP.Fixed_Currency_Ind_SP__c = false;
                                } 
            if(request.Non_I2_related_SP__c != null && request.Non_I2_related_SP__c != ''){
                                    if(request.Non_I2_related_SP__c == 'Yes')
                                        SAP.Non_I2_related_SP__c = true;
                                    if(request.Non_I2_related_SP__c == 'No')
                                        SAP.Non_I2_related_SP__c = false;
                                } 
            if(request.Sales_Area_Region__c != null && request.Sales_Area_Region__c != '' ) 
                                    SAP.Region__c = request.Sales_Area_Region__c;
            if(request.Reprice_Basis__c != null && request.Reprice_Basis__c != '' ) 
                                    SAP.Reprice_Basis__c = request.Reprice_Basis__c;
            if(request.S_O_Sub_Group__c != null && request.S_O_Sub_Group__c != '' ) 
                                    SAP.S_O_Sub_Group__c = request.S_O_Sub_Group__c;
            if(request.Sales_Office__c != null && request.Sales_Office__c != '' )   
                                    SAP.Sales_office__c = request.Sales_Office__c;
            
            if(request.Order_Combination__c != null && request.Order_Combination__c != ''){
                                    if(request.Order_Combination__c == 'Yes')
                                        SAP.Order_Combination__c = true;
                                    if(request.Order_Combination__c == 'No')
                                        SAP.Order_Combination__c = false;
                                } 
           // commenetd as part of SFDC-684 
          /*  if(request.BillCurrency_PY__c != null && request.BillCurrency_PY__c != '' && request.BillCurrency_PY__c != 'Set to BLANK') 
                                    SAP.BillCurrency_PY__c = request.BillCurrency_PY__c;
                                else if(request.BillCurrency_PY__c == 'Set to BLANK')
                                    SAP.BillCurrency_PY__c = null; */
            
            if(request.Grp_1_Sls_Channel_SP__c != null && request.Grp_1_Sls_Channel_SP__c != '' )   
                                    SAP.Grp_1_Sls_Channel_SP__c = request.Grp_1_Sls_Channel_SP__c;
            if(request.Grp_2_Cus_Prce_Grp_SP__c != null && request.Grp_2_Cus_Prce_Grp_SP__c != '' && request.Grp_2_Cus_Prce_Grp_SP__c != 'Set to BLANK') 
                                    SAP.Grp_2_Cus_Prce_Grp_SP__c = request.Grp_2_Cus_Prce_Grp_SP__c;
                                else if(request.Grp_2_Cus_Prce_Grp_SP__c == 'Set to BLANK')
                                    SAP.Grp_2_Cus_Prce_Grp_SP__c = NULL;
            if(request.Matl_Det_Grp_SP__c != null && request.Matl_Det_Grp_SP__c != '' && request.Matl_Det_Grp_SP__c != 'Set to BLANK') 
                                    SAP.Matl_Det_Grp_SP__c = request.Matl_Det_Grp_SP__c;
                                else if(request.Matl_Det_Grp_SP__c != null && request.Matl_Det_Grp_SP__c != '' && request.Matl_Det_Grp_SP__c == 'Set to BLANK') // added for SIR 1138
                                    SAP.Matl_Det_Grp_SP__c = NULL;
            }
            /********************* End - Fields specific to Sold-To Type **************************/ 
            
           /********************** Start - Fields specific to Ship-To Type ***************************/
            
            if(request.FLAG_Ship_to__c == True){
            system.debug('check1' + request.FLAG_Ship_to__c);
            if(request.Transportation_Zone__c != null && request.Transportation_Zone__c != '' ) 
                                    SAP.Transportation_Zone__c = request.Transportation_Zone__c;
             
            if(request.Customer_Factory_Calendar__c != null && request.Customer_Factory_Calendar__c != '' ) 
                                    SAP.Customer_Factory_Calendar__c = request.Customer_Factory_Calendar__c;
            
            if(request.Unloading_Point__c != null && request.Unloading_Point__c != '' ) 
                                    SAP.Unloading_Point__c = request.Unloading_Point__c;
            
            if(request.Delivery_Group_Ind_SH__c != null && request.Delivery_Group_Ind_SH__c != '' && request.Delivery_Group_Ind_SH__c != 'Set to BLANK') 
                                    SAP.Delivery_Group_Ind_SH__c = request.Delivery_Group_Ind_SH__c;
             else if(request.Delivery_Group_Ind_SH__c == 'Set to BLANK')
                                    SAP.Delivery_Group_Ind_SH__c = null;
            
            if(request.Pull_Up_OK_SH__c != null && request.Pull_Up_OK_SH__c != '' ) 
                                    SAP.Pull_Up_OK_SH__c = request.Pull_Up_OK_SH__c;
                                if(request.Rounding_Rule_SH__c != null && request.Rounding_Rule_SH__c != '' )   
                                    SAP.Rounding_Rule_SH__c = request.Rounding_Rule_SH__c;
            
            if(request.C_GAD_Indicator_SH__c != null && request.C_GAD_Indicator_SH__c != ''){
                                    if(request.C_GAD_Indicator_SH__c == 'Yes')
                                        SAP.C_GAD_Indicator_SH__c = true;
                                    if(request.C_GAD_Indicator_SH__c == 'No')
                                        SAP.C_GAD_Indicator_SH__c = false;
                                }    
            if(request.Distribution_Region__c != null && request.Distribution_Region__c != '' ) 
                                    SAP.Distribution_Region__c = request.Distribution_Region__c;
             
            if(request.Sales_district__c != null && request.Sales_district__c != '' )   
                                    SAP.Sales_district__c = request.Sales_district__c;
            
            if(request.Max_partial_deliveries__c != null && request.Max_partial_deliveries__c != '' )   
                                    SAP.Max_partial_deliveries__c = request.Max_partial_deliveries__c;
            
            if(request.Partial_delivery_per_item__c != null && request.Partial_delivery_per_item__c != '' && request.Partial_delivery_per_item__c != 'Set to BLANK') 
                                    SAP.Partial_delivery_per_item__c = request.Partial_delivery_per_item__c;
                                else if(request.Partial_delivery_per_item__c == 'Set to BLANK')
                                    SAP.Partial_delivery_per_item__c = null;
            
            if(request.Shipping_Condition__c != null && request.Shipping_Condition__c != '' )   
                                    SAP.Shipping_conditions__c = request.Shipping_Condition__c;
            
            if(request.Incoterms_1__c != null && request.Incoterms_1__c != '' ) 
                                    SAP.Incoterms_1__c = request.Incoterms_1__c;
            
            if(request.Incoterms_2__c != null && request.Incoterms_2__c != '' ) 
                                    SAP.Incoterms_2__c = request.Incoterms_2__c;
            
            if(request.Label_Required__c != null && request.Label_Required__c != '')
                                    SAP.Label_Required__c = request.Label_Required__c;
            
            if(request.Label_Required__c == 'Yes' && request.Label_Code__c != null && request.Label_Code__c != '')
                                    SAP.Label_Code__c = request.Label_Code__c;
            
            if(request.Label_Required__c == 'No')
                                    SAP.Label_Code__c = '';
             //--------------------------- modified for SIR 534 ----------------------------------------------------                     
            if(request.No_of_days_for_Early_Shipment__c!=null)
                         {           
                                 SAP.No_of_days_for_Early_Shipment__c=request.No_of_days_for_Early_Shipment__c;
                                 
                         }                 
             //-----------------------------------------------------------------------------------------------------                       
             lstNewPartnerFunction = new List<Partner_Function__c>();
                                if(request.Customer_Service_ZA__c != '' && request.Customer_Service_ZA__c != null){
                                     
                                    if(mapSAPCMDtoPartnerFunction.containsKey(request.Funloc_SAP_CMD__c) 
                                       && mapSAPCMDtoPartnerFunction.get(request.Funloc_SAP_CMD__c).containsKey('ZA - Customer Service Rep')){
                                           system.debug('checkZA' + request.Customer_Service_ZA__c);
                                           Partner_Function__c objPartnerFunctionUpdate = new Partner_Function__c(
                                               Id = mapSAPCMDtoPartnerFunction.get(request.Funloc_SAP_CMD__c).get('ZA - Customer Service Rep'),
                                               Person_Name__c = request.Customer_Service_ZA__c
                                           );
                                           lstPartnerFunctionUpdate.add(objPartnerFunctionUpdate);
                                       }
                                    else
                                    {
                                      system.debug('checkZAnew' + request.Customer_Service_ZA__c); 
                                      Partner_Function__c newPartnerFunction = new  Partner_Function__c();
                                      newPartnerFunction.RecordTypeId = ZA_ZS_RECORD_TYPE_ID;
                                      newPartnerFunction.SAP_Customer__c = request.Funloc_SAP_CMD__c;
                                      newPartnerFunction.Partner_Function_Type__c = Partner_Function_Type_ZA;
                                      newPartnerFunction.Person_Name__c = request.Customer_Service_ZA__c;              
                                      // insert newPartnerFunction;
                                      lstNewPartnerFunction.add(newPartnerFunction);
                                    }
                                }
                                
                                //Update ZS
                                if(request.Sales_Rep_ZS__c != '' && request.Sales_Rep_ZS__c != null){
                                      
                                    if(mapSAPCMDtoPartnerFunction.containsKey(request.Funloc_SAP_CMD__c)
                                       && mapSAPCMDtoPartnerFunction.get(request.Funloc_SAP_CMD__c).containsKey('ZS - Sales Person')){
                                            system.debug('checkZS' + request.Sales_Rep_ZS__c);
                                           Partner_Function__c objPartnerFunctionUpdate = new Partner_Function__c(
                                               Id = mapSAPCMDtoPartnerFunction.get(request.Funloc_SAP_CMD__c).get('ZS - Sales Person'),
                                               Person_Name__c = request.Sales_Rep_ZS__c
                                           );
                                           lstPartnerFunctionUpdate.add(objPartnerFunctionUpdate);
                                       }
                                    else
                                    {
                                       system.debug('checkZSnew' + request.Sales_Rep_ZS__c);
                                      Partner_Function__c newPartnerFunction = new  Partner_Function__c();
                                      newPartnerFunction.RecordTypeId = ZA_ZS_RECORD_TYPE_ID;
                                      newPartnerFunction.SAP_Customer__c = request.Funloc_SAP_CMD__c;
                                      newPartnerFunction.Partner_Function_Type__c = Partner_Function_Type_ZS;
                                      newPartnerFunction.Person_Name__c = request.Sales_Rep_ZS__c;              
                                      // insert newPartnerFunction;
                                      lstNewPartnerFunction.add(newPartnerFunction);
                                    }
                                 }
                                 
                                   system.debug('listvaluesinsideif' + lstNewPartnerFunction);
            }
/**************************End - Fields specific to Ship-To Type****************************/

/**********************Start - Fields specific to Payer-To Type*************************************************/

            if(request.FLAG_Payer__c == True){
            if(request.Company_Code__c != null && request.Company_Code__c != '' )   
                                    SAP.Company_Code__c = request.Company_Code__c;
            
            if(request.Reconciliation_Account__c != null && request.Reconciliation_Account__c != '' )   
                                    SAP.Reconciliation_Account__c = request.Reconciliation_Account__c;
            
            if(request.Sorting_key_for_assignment_no__c != null && request.Sorting_key_for_assignment_no__c != '' ) 
                                    SAP.Sorting_key_for_assignment_no__c = request.Sorting_key_for_assignment_no__c;
            
            if(request.Indicator_Record_Payment_History__c != null && request.Indicator_Record_Payment_History__c != ''){
                                    if(request.Indicator_Record_Payment_History__c == 'Yes')
                                        SAP.Indicator_Record_Payment_History__c = true;
                                    if(request.Indicator_Record_Payment_History__c == 'No')
                                        SAP.Indicator_Record_Payment_History__c = False;
                                }   
            
            if(request.Key_for_Payment_Grouping__c != null && request.Key_for_Payment_Grouping__c != '' )   
                                    SAP.Key_for_Payment_Grouping__c = request.Key_for_Payment_Grouping__c;
            
            if(request.Lockbox__c != null && request.Lockbox__c != '' ) 
                                    SAP.Lockbox__c = request.Lockbox__c;
            
            if(request.Payment_Credit_Memo__c != null && request.Payment_Credit_Memo__c != '' ) 
                                    SAP.Payment_Credit_Memo__c = request.Payment_Credit_Memo__c;
            
            if(request.Reason_Code_Conversion__c != null && request.Reason_Code_Conversion__c != '' )   
                                    SAP.Reason_Code_Conversion__c = request.Reason_Code_Conversion__c;
            
            if(request.Selection_Rule_for_Payment_Advice__c != null && request.Selection_Rule_for_Payment_Advice__c != '' ) 
                                    SAP.Selection_Rule_for_Payment_Advice__c = request.Selection_Rule_for_Payment_Advice__c;
            
            if(request.Terms_of_Payment__c != null && request.Terms_of_Payment__c != '' )   
                                    SAP.Terms_of_payment__c = request.Terms_of_Payment__c;
            
            if(request.Tolerance_Group__c != null && request.Tolerance_Group__c != '' ) 
                                    SAP.Tolerance_Group__c = request.Tolerance_Group__c;
            
            if(request.Account_memo__c != null && request.Account_memo__c != '' )   
                                    SAP.Account_memo__c = request.Account_memo__c;
            
            if(request.Accounting_Clerk__c != null && request.Accounting_Clerk__c != '' )   
                                    SAP.Acconting_Clerk__c = request.Accounting_Clerk__c;
            
            if(request.Act_clerk_fax_number__c != null && request.Act_clerk_fax_number__c != '' )   
                                    SAP.Act_clerk_fax_number__c = request.Act_clerk_fax_number__c;
            
            if(request.Act_clerk_internet_address__c != null && request.Act_clerk_internet_address__c != '' )   
                                    SAP.Act_clerk_internet_address__c = request.Act_clerk_internet_address__c;
            
            if(request.Act_clerk_tel_no__c != null && request.Act_clerk_tel_no__c != '' )   
                                    SAP.Act_clerk_tel_no__c = request.Act_clerk_tel_no__c;
                                
            if(request.Ind_period_account_statement__c != null && request.Ind_period_account_statement__c != '' )   
                                    SAP.Ind_period_account_statement__c = request.Ind_period_account_statement__c;
                                
            if(request.Our_account_at_customer__c != null && request.Our_account_at_customer__c != '' ) 
                                    SAP.Our_account_at_customer__c = request.Our_account_at_customer__c;
                                
            if(request.User_at_customer__c != null && request.User_at_customer__c != '' )   
                                    SAP.User_at_customer__c = request.User_at_customer__c;
            
            if(request.Acct_assgmt_group__c != null && request.Acct_assgmt_group__c != '' ) 
                                    SAP.Acct_assgmt_group__c = request.Acct_assgmt_group__c;
            
            if(request.Payment_Guarantee_Procedure__c != null && request.Payment_Guarantee_Procedure__c != '' ) 
                                    SAP.Paym_guar_proc__c = request.Payment_Guarantee_Procedure__c;
            
            if(request.Terms_of_Payment_Sales__c != null && request.Terms_of_Payment_Sales__c != '' )   
                                    SAP.Terms_of_Payment_Sales__c = request.Terms_of_Payment_Sales__c;
            
          /*  SAP.Posting_block_for_company_code__c = request.Posting_Block_Company_Code__c;
            
            SAP.Deletion_Block_Company_Code__c = request.Deletion_Block_Company_Code__c;
            
            SAP.Deletion_Flag_Company_Code__c = request.Deletion_Flag_Company_Code__c;*/
             if(request.Posting_Block_Company_Code__c != null && request.Posting_Block_Company_Code__c != '' && request.Posting_Block_Company_Code__c == 'Yes')
                   SAP.Posting_block_for_company_code__c = TRUE;
                else if(request.Posting_Block_Company_Code__c != null && request.Posting_Block_Company_Code__c != '' && request.Posting_Block_Company_Code__c == 'No')
                   SAP.Posting_block_for_company_code__c = FALSE;

             if(request.Deletion_Block_Company_Code__c != null && request.Deletion_Block_Company_Code__c != '' && request.Deletion_Block_Company_Code__c == 'Yes')
                   SAP.Deletion_Block_Company_Code__c = TRUE;
                else if(request.Deletion_Block_Company_Code__c != null && request.Deletion_Block_Company_Code__c != '' && request.Deletion_Block_Company_Code__c == 'No')
                   SAP.Deletion_Block_Company_Code__c = FALSE;
               
              if(request.Deletion_Flag_Company_Code__c != null && request.Deletion_Flag_Company_Code__c != '' && request.Deletion_Flag_Company_Code__c == 'Yes')
                   SAP.Deletion_Flag_Company_Code__c = TRUE;
                else if(request.Deletion_Flag_Company_Code__c != null && request.Deletion_Flag_Company_Code__c != '' && request.Deletion_Flag_Company_Code__c == 'No')
                   SAP.Deletion_Flag_Company_Code__c = FALSE;
                    if(request.City_Chinese__c != null && request.City_Chinese__c != '' )   
                        SAP.Chinese_City__c = request.City_Chinese__c;
                    if(request.Chinese_Name1__c != null && request.Chinese_Name1__c != '' ) 
                        SAP.Chinese_Name1__c = request.Chinese_Name1__c;
                    if(request.Chinese_Name2__c != null && request.Chinese_Name2__c != '' ) 
                        SAP.Chinese_Name2__c = request.Chinese_Name2__c;
                    if(request.Chinese_Street__c != null && request.Chinese_Street__c != '' )   
                        SAP.Chinese_Street__c = request.Chinese_Street__c;
                    if(request.Version_ID_for_International_Addresses__c != null && request.Version_ID_for_International_Addresses__c != '' ) 
                                    SAP.Version_ID_for_International_Addresses__c = request.Version_ID_for_International_Addresses__c;
            
                    if(request.Tax_Number_5__c != null && request.Tax_Number_5__c != '' )   
                                    SAP.Tax_Number_5__c = request.Tax_Number_5__c;
                    // Added as aprt of SFDC-684                
                    if(request.BillCurrency_PY__c != null && request.BillCurrency_PY__c != '' && request.BillCurrency_PY__c != 'Set to BLANK') 
                                    SAP.BillCurrency_PY__c = request.BillCurrency_PY__c;
                                else if(request.BillCurrency_PY__c == 'Set to BLANK')
                                    SAP.BillCurrency_PY__c = null;
            
       }
/*******************End - Fields specific to Payer-To Type***************************/

/**********************  Start - Fields common to Sold-To and Ship-To Type *********************************/

            If(request.FLAG_Sold_to__c == True||request.FLAG_Ship_to__c == True){
            if(request.Taxes_Number_1__c != null && request.Taxes_Number_1__c != '' )   
                                    SAP.Tax_Number_1__c = request.Taxes_Number_1__c;
            
            if(request.VAT_Registration_Number__c!= null && request.VAT_Registration_Number__c!= '' ) 
                                    SAP.VAT_Registration_Number__c = request.VAT_Registration_Number__c;
            
            if(String.valueof(request.Consolidated_Account_Code__c) != null && String.valueof(request.Consolidated_Account_Code__c) != '')
                                    SAP.Consolidated_Account_Code__c = String.valueof(request.Consolidated_Account_Code__c);
            
            if(request.Delivery_priority__c != null && request.Delivery_priority__c != '' ) 
                                    SAP.Delivery_priority__c = request.Delivery_priority__c;
            }
/**************** End - Fields common to Sold-To and Ship-To Type************************************/

/********************  Start - Fields common to Sold-To and Payer-To Type ***************************/
            If(request.FLAG_Sold_to__c == True||request.FLAG_Payer__c == True){
            if(request.Customer_Statistics_Group__c != null && request.Customer_Statistics_Group__c != '' ) 
                                    SAP.Customer_Statistics_Group__c = request.Customer_Statistics_Group__c;
            }

/******************* End - Fields common to Sold-To and Payer-To Type ******************************************/


/********************  Start - Fields common to Sold-To ,Ship-to, Bill-to and PAYER *********************************/
            If(request.FLAG_Sold_to__c == True||request.FLAG_Ship_to__c == True||request.FLAG_Bill_to__c == True||request.FLAG_Payer__c == True){
            if(request.Global_Account__c != null && request.Global_Account__c != '' )   
                                    SAP.Global_Account__c = request.Global_Account__c;
            
            }
/********************** End - Fields common to Sold-To ,Ship-to, Bill-to and PAYER ***********************************/

        theCMDs.add(SAP);
    }
 }
                  
       Map<String, Id> mapApprovedRequest = new Map<String, Id>();
       if(theRequests.size()!=null){      //null exception
        for(CMD_Request__c request : theRequests)
            mapApprovedRequest.put(request.Funloc_SAP_CMD__c, request.Id);
        
        List<CMD_Request__c> allFailedRequests = new List<CMD_Request__c>();
        try{
            List<Database.SaveResult> updateResults;
            
            updateResults = Database.update(theCMDs, false);
            for(Integer i = 0 ; i < updateResults.size() ; i++){
                if(updateResults.get(i).isSuccess()){
                    updateResults.get(i).getId();
                }
                else if(!updateResults.get(i).isSuccess()){
                    Database.Error error = updateResults.get(i).getErrors().get(0);
                    theCMDs.get(i);//failed record from the list
                    
                    
                    CMD_Request__c failedRequest = new CMD_Request__c
                    (
                        Id = mapApprovedRequest.get(theCMDs.get(i).Id), 
                        Update_SAP_CMD_Failed__c = True,
                        Update_SAP_CMD_Error_Message__c = String.valueof(error.getMessage())
                    );
                    //failedRequest.Update_SAP_CMD_Failed__c = True;
                    allFailedRequests.add(failedRequest);
                }
            }
           
            update allFailedRequests;
        } catch(DmlException e){
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        } 
        catch(ListException e){
            System.debug('Error Message: ' + e);
        }
      }  // null exception end  
      
        /***1510 Release - Modified by Scarlett on Oct 05 2015***/
        //Update Related Partner Function records
        update lstPartnerFunctionUpdate;
        //for SIR 499
        system.debug('listvalues' + lstNewPartnerFunction);
        if(lstNewPartnerFunction!=null){
        insert lstNewPartnerFunction; 
        }   
        /***1510 Release - Modified by Scarlett on Oct 05 2015 - END***/
    }
}