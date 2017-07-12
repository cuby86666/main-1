/*******************************************************************************************************
@Modified By :       Nisha Agrawal
@Modified Date:      14 Feb 2014
@Description:        Updated test methods to fix it due to new mandatory field - Legal Name in SAP CMD
--------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      14 Feb 2014
@Description:        Updated test methods to fix it due to new mandatory field - Region in SAP CMD
--------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      11 Jun 2014
@Description:        Updated test methods to fix it due to remove CACC related fields
-------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date :     26 Sep 2014
@Description :       Updated test methods to fix it due to new mandatory field - Zip, Con. Acct- SP / EMS
-------------------------------------------------------------------------------
@Modified By :       Stan Hsu
@Modified Date :     Dec 11 2014
@Description :       Removed all reference to Industry Segment and Sub Segment
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Baji
@Modified Date:    Aug 30, 2016 
@Description:      Modified for SIR 990. To obsolete and then adjust the transportation zone field to change it's data-type
*****************************************************************************************************************/

@istest
private class UnlockSapCmdRecordsBatchTest
{
    private static final String TYPE_Z002_SHIP_TO='Z002_Ship_To';
    private static final String TYPE_Z011_SOLD_TO = 'Z011_Sold_To';
    private static final String TYPE_Z012_SOLD_TO_SHIP_TO = 'Z012_Sold_to_Ship_To';
    private static final String TYPE_Z003_PAYER = 'Z003_Payer';
    private static final String TYPE_Z004_BILL_TO ='Z004_Bill_To';
    private static final String TYPE_Z005_SOLD_TO_BILL_TO_PAYER = 'Z005_SoldTo_BillTo_Payer';
    private static final String TYPE_Z013_PAYER_BILL_TO = 'Z013_Payer_Bill_To';
            
    private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
    
    private static RecordType Z002_Ship_To;
    private static RecordType Z011_Sold_To;
    private static RecordType Z012_Sold_to_Ship_To;
    private static RecordType Z003_Payer;
    private static RecordType Z004_Bill_To;
    private static RecordType Z005_SoldTo_BillTo_Payer;
    private static RecordType Z013_Payer_Bill_To;  
    
    private static RecordType globalCustomer;
    
        
    private static final integer RECORD_COUNT = 25;
    
    private static void fetchRecordTypes()
    {
        //get SAP CMD record type
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              ((SobjectType = 'SAP_CMD__c' and (DeveloperName =: TYPE_Z002_SHIP_TO 
                                                                or DeveloperName =: TYPE_Z011_SOLD_TO
                                                                or DeveloperName =: TYPE_Z012_SOLD_TO_SHIP_TO
                                                                or DeveloperName =: TYPE_Z003_PAYER
                                                                or DeveloperName =: TYPE_Z004_BILL_TO
                                                                or DeveloperName =: TYPE_Z005_SOLD_TO_BILL_TO_PAYER
                                                                or DeveloperName =: TYPE_Z013_PAYER_BILL_TO
                                                               ))
                                  OR (SobjectType = 'Customer__c' and DeveloperName =: TYPE_GLOBALENTERPRISE)
                              )])
        {
            if(rt.DeveloperName == TYPE_Z002_SHIP_TO)
            {
                Z002_Ship_To = rt;
            }
            else if(rt.DeveloperName == TYPE_Z011_SOLD_TO)
            {
                Z011_Sold_To = rt; 
            }
            else if(rt.DeveloperName == TYPE_Z012_SOLD_TO_SHIP_TO)
            {
                Z012_Sold_to_Ship_To = rt;
            }
            else if(rt.DeveloperName == TYPE_Z013_PAYER_BILL_TO)
            {
                Z013_Payer_Bill_To = rt;
            }
            else if(rt.DeveloperName == TYPE_Z003_PAYER)
            {
               Z003_Payer  = rt;
            }
            else if(rt.DeveloperName == TYPE_Z004_BILL_TO)
            {
               Z004_Bill_To  = rt;
            }
            else if(rt.DeveloperName == TYPE_Z005_SOLD_TO_BILL_TO_PAYER)
            {
               Z005_SoldTo_BillTo_Payer  = rt;
            }
            
            
            if(rt.DeveloperName == TYPE_GLOBALENTERPRISE)
            {
                globalCustomer = rt;
            }          
        }
            
    }
    private static List<Customer__c> createCustomers()
    {
          List<Customer__c> lstCustomers = new List<Customer__c>();
          Customer__c objCustomer;
          for(integer i=0; i < RECORD_COUNT; i++)
          {
                           
              objCustomer = new Customer__c(RecordTypeId = globalCustomer.Id, Account_Name__c = 'ut_Global_Enterprise ' + i ,
                                            Legal_Name__c = 'ut_Global_Enterprise ' + i , DUNS__c = 'ut_123'+ i , 
                                            Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                            House_Number__c = 'ut'+ i , Street__c = 'ut_street_1' + i ,
                                            City__c = 'ut_city' + i , Country__c = 'ANDORRA', 
                                            Zip__c = 'ut_zip' + i , 
//                                            Industry_Segment__c = 'Computing' ,
                                            Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                            Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2' + i ,
                                            Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,
//                                            Industry_Sub_Segment__c = 'F1 - Desktop',
                                            SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                            Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                            Fax__c = '+1234567890', Telephone__c = '+1234567890', Industry_Segment__c = 'test');
             lstCustomers.add(objCustomer);                                            
         }
         return lstCustomers;
    }
    
    private static List<Consolidated_Account_Code__c> createCACC()
    {
          //List<customer__c> lstCustomers = createCustomers();
          //insert lstCustomers;
          
          List<Consolidated_Account_Code__c> lstCACC = new List<Consolidated_Account_Code__c>();
          Consolidated_Account_Code__c objCACC;
          
          for(integer i=0; i < RECORD_COUNT; i++)
          {
                           
              objCACC = new Consolidated_Account_Code__c(Name ='ZZZ', Code_Description__c = 'Test Code'  + i, 
                                                         //End_Customer_GID__c = lstCustomers[i].Id, 
                                                         Customer_Category__c = 'Focus' + i, 
                                                         PD_Key_Account__c = 'Test' + i, 
/* added by Stan */                                      Industry_Segment__c = 'Computing' + i,
                                                         Base_Region__c = 'AM-Americas' + i);
             lstCACC.add(objCACC);                                            
         }
         return lstCACC;
    }
   
    /**********************************************************************************************
        Case - New SAP CMD with status Approved and Distributed,Approved and Failed Distribution  
    ***********************************************************************************************/    
    static testMethod void UnlockSapCmdRecordsBatchTest1() 
    {
        //prepare test data
        fetchRecordTypes();
        List<customer__c> lstCustomers = createCustomers();
        insert lstCustomers;
        List<SAP_CMD__c> lstSapCmds = new List<SAP_CMD__c>();
        List<Consolidated_Account_Code__c> lstCACC = createCACC();
        insert lstCACC;
        integer i = 0;
        while(i < 10)
        {    
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z002_Ship_To.id,HUB_Customer__c = lstCustomers[++i].id,Status__c = 'Approved and Distributed', Legal_Name__c = 'test legal name' , City__c = 'ut_city', Street_1__c = 'ut_street', Country__c = 'ut_country', 
//                                            Industry_Segment__c = 'AA - Appliances', 
//                                            Industry_Sub_Segment__c = 'A1 - Major Home Appliances',  
                                            Language__c='E - English', FunLoc_Type__c='internal', End_Customer_NXP_Global_ID__c = lstCustomers[++i].id,Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',
                                            Currency__c='USD - US Dollar',Incoterms_2__c = 'TEST'+i,Sales_Organisation__c='NL60 - RSO Europe',Transportation_Zone__c='AR1',
                                            Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',Payment_Credit_Memo__c='014 - Prepaid', 
                                            S_O_Sub_Group__c='AT - Austria', Reprice_Basis__c='C - Conf. Delivery Date', Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',Delivery_priority__c='10 - Priority 1', Company_Code__c = 'NL60 - RSO Europe',  Customer_Statistics_Group__c ='1' , Global_Account__c = 'ABAUT - ABA AB AUTOMOTIVE',
                                             Sorting_key_for_assignment_no__c = '000 - Allocation number', Lockbox__c = 'EUR', Reason_Code_Conversion__c = '001 - Version 001', Selection_Rule_for_Payment_Advice__c = '001 - Document no / Reference', Acconting_Clerk__c = '01 - Zoe Wen', Ind_period_account_statement__c ='1 - No account statement needed',
                                            Sales_office__c = 'APDI - APDI', Exch_rate_type__c ='4DEC - NXP Act. Rate' , Terms_of_Payment_Sales__c = '014 - Prepaid', Region__c = 'AP - Asia Pacific', Rounding_Rule_SH__c = 'C - Round to Closest', Label_Required__c = 'No', Zip__c = '123456', Consolidated_Account_Code__c = lstCACC[++i].Id));
        }
             
        Test.startTest();
        insert lstSapCmds;
        for(SAP_CMD__c objSapCmds:lstSapCmds)
        {
            system.assert(objSapCmds.id!=null);
        }
        List<SAP_CMD__c> lstSapCmd = [SELECT Id, Name, HUB_Customer__r.Account_Name__c, Status__c 
                                            From  SAP_CMD__c 
                                            Where (Status__c ='Approved and Distributed' OR Status__c = 'Approved and Failed Distribution') 
                                                    and (LastModifiedDate>=: DateTime.Now().addMinutes(-10))];
        system.assertNotEquals(lstSapCmd.size(),0);                                                                                                          
        UnlockSapCmdRecordsBatch updateBatch = new UnlockSapCmdRecordsBatch();
        Database.executeBatch(updateBatch,25);
        Test.stopTest();   
    }
}