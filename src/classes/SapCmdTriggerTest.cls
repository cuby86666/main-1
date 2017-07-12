/*******************************************************************************************************
@Modified By :          Nisha Agrawal
@Modified Date:      14 Feb 2014
@Description:            Updated test methods to fix it due to new mandatory field - Legal Name in SAP CMD
--------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :          Nisha Agrawal
@Modified Date:      19 Feb 2014
@Description:           Added new test method for Syncing Customer Address from GCM in case of Sold Tos
---------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:    18 Mar 2014
@Description:         Updated test method to  de-link Region field from GCM (DO NOT sync it with GCM)
 --------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:    25 Mar 2014indus
@Description:         Updated test method to de-link Street2 and Street 3  field from GCM (DO NOT sync it with GCM)
----------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:    05 May 2014
@Description:        1- Updated test Method updated to generate funloc for all account gropups from SAP CMD instead of GCM
                                     2- New test method added to update funloc on SAP CMD record update  
----------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:     11 Jun 2014
@Description:        1. Updated test methods to fix it due to removal of CACC related fields
                                       2. Added new test method for CACC feature.
-------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Scarlett Kang
@Modified Date :   26 Sep 2014
@Description :     Updated test methods to fix it due to new mandatory field - Zip
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    20 Mar 2015
@Description:      Change the field type of SAP_CMD__c.Industry_Segment__c to formula
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:    10 Sep 2015
@Description:      Added one line to cover the code for Julie CMD(sales org code: HK91).
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    Sep 30 2015
@Description:      SIR 495 - Stop copying Industry Sub Segment from Customer object to SAP CMD
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    Oct 23 2015
@Description:      1511 Release - SIR 474, Stop copying Address information from Customer to SAP CMD
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    Dec 21 2015
@Description:      1601 Release - SIR 4596, SAP CMD - Name3 field map to funloc DB
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:    May 30 2016
@Description:      1606 Release - SIR 292, [IMO]Divide CACC "Industry Segment" to "CBG" and "SUB-CBG", 
				   SAP_CMD__c.Industry_Sub_Segment__c is going to be formula field
******************************************************************************************************************************/

@istest
private class SapCmdTriggerTest
{
    private static final String TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER = 'Z001_SoldTo_ShipTo_BillTo_Payer';
    private static final String TYPE_Z010_INTERMEDIATE_CONSIGNEE = 'Z010_Intermediate_Consignee';
    private static final String TYPE_Z002_SHIP_TO='Z002_Ship_To';
    private static final String TYPE_Z011_SOLD_TO = 'Z011_Sold_To';
    private static final String TYPE_Z012_SOLD_TO_SHIP_TO = 'Z012_Sold_to_Ship_To';
    private static final String TYPE_Z003_PAYER = 'Z003_Payer';
    private static final String TYPE_Z004_BILL_TO ='Z004_Bill_To';
    private static final String TYPE_Z005_SOLD_TO_BILL_TO_PAYER = 'Z005_SoldTo_BillTo_Payer';
    private static final String TYPE_Z013_PAYER_BILL_TO = 'Z013_Payer_Bill_To';
    private static final String TYPE_ZORG_ORGANIZATIONAL_CUSTOMERS='ZORG_Organizational_Customers';
    private static final String TYPE_ZOTHERS_NON_COMMERCIAL_ENTITIES='ZOthers_Non_Commercial_Entities';
    
    private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
    
    private static RecordType Z001_SoldTo_ShipTo_BillTo_Payer;
    private static RecordType Z010_Intermediate_Consignee;
    private static RecordType Z002_Ship_To;
    private static RecordType Z011_Sold_To;
    private static RecordType Z012_Sold_to_Ship_To;
    private static RecordType Z003_Payer;
    private static RecordType Z004_Bill_To;
    private static RecordType Z005_SoldTo_BillTo_Payer;
    private static RecordType Z013_Payer_Bill_To;  
    private static RecordType ZORG_Organizational_Customers;
    private static RecordType ZOthers_Non_Commercial_Entities;
    
    private static RecordType globalCustomer;
        
    private static final integer RECORD_COUNT = 10;
    
    private static void fetchRecordTypes()
    {
        //get SAP CMD record type
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              ((SobjectType = 'SAP_CMD__c' and (DeveloperName =: TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER 
                                                                or DeveloperName =: TYPE_Z010_INTERMEDIATE_CONSIGNEE
                                                                or DeveloperName =: TYPE_Z002_SHIP_TO 
                                                                or DeveloperName =: TYPE_Z011_SOLD_TO
                                                                or DeveloperName =: TYPE_Z012_SOLD_TO_SHIP_TO
                                                                or DeveloperName =: TYPE_Z003_PAYER
                                                                or DeveloperName =: TYPE_Z004_BILL_TO
                                                                or DeveloperName =: TYPE_Z005_SOLD_TO_BILL_TO_PAYER
                                                                or DeveloperName =: TYPE_Z013_PAYER_BILL_TO
                                                                or DeveloperName =: TYPE_ZORG_ORGANIZATIONAL_CUSTOMERS
                                                                or DeveloperName =: TYPE_ZOTHERS_NON_COMMERCIAL_ENTITIES
                                                               ))
                                  OR (SobjectType = 'Customer__c' and DeveloperName =: TYPE_GLOBALENTERPRISE)
                              )])
        {
            if(rt.DeveloperName == TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
            {
                Z001_SoldTo_ShipTo_BillTo_Payer = rt;
            }
            else if(rt.DeveloperName == TYPE_Z010_INTERMEDIATE_CONSIGNEE)
            {
                Z010_Intermediate_Consignee = rt;
            }
            else if(rt.DeveloperName == TYPE_Z002_SHIP_TO)
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
            else if(rt.DeveloperName == TYPE_ZORG_ORGANIZATIONAL_CUSTOMERS)
            {
                ZORG_Organizational_Customers = rt;
            }
            else if(rt.DeveloperName == TYPE_ZOTHERS_NON_COMMERCIAL_ENTITIES)
            {
                ZOthers_Non_Commercial_Entities = rt;
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
                                                                                        Zip__c = 'ut_zip' + i , City__c = 'ut_city' + i, Country__c = 'USA' ,  
                                                                                        //Scarlett Industry_Segment__c = 'CC - Computing' ,
                                                                                        Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                                                                        Fulfillment_Channel__c = 'Disti',  Street_2__c = 'ut_street_2' + i ,
                                                                                        Street_3__c = 'ut_street_3' + i ,State__c = 'test' + i,
                                                                                        //Scarlett on May 30 2016 Industry_Sub_Segment__c = 'F1 - Desktop',
                                                                                        SIC_Code__c = 't' + i, NAICS_Code__c = 'ut_' + i, 
                                                                                        Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
                                                                                        Fax__c = '+1234567890', Telephone__c = '+1234567890');
             lstCustomers.add(objCustomer);                                            
         }
         return lstCustomers;
    }
      
    /***************************************************************************
        Case - New SAP CMD - > New FunLoc created  
    ****************************************************************************/    
    static testMethod void SapCmdTriggerTest1() 
    {
        //prepare test data
        fetchRecordTypes();
        List<customer__c> lstCustomers = createCustomers();
        insert lstCustomers;
     
        
        //start the test
        Test.startTest();
         
        List<SAP_CMD__c> lstSapCmds = new List<SAP_CMD__c>();
        integer i = 0;
        while(i < 4)
        {   
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z001_SoldTo_ShipTo_BillTo_Payer.id, HUB_Customer__c = lstCustomers[++i].Id, Status__c='Draft', Legal_Name__c = 'test record' ,  Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',  Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[i].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c='TEST'));
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z005_SoldTo_BillTo_Payer.id,HUB_Customer__c = lstCustomers[++i].Id , Status__c='Draft', Legal_Name__c = 'test record' ,  Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[i].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST'));
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z011_Sold_To.id,HUB_Customer__c = lstCustomers[++i].id,Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',  Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[i].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST'));
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z012_Sold_to_Ship_To.id,HUB_Customer__c = lstCustomers[++i].id,Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',  Language__c='E - English',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[i].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c = 'TEST'));
            
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z002_Ship_To.Id,Sales_Organisation__c = 'HK91 - WeEn Semiconductor',  Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', City__c = 'test city', Country__c = 'test country', Street_1__c = 'test street',  State_Province__c = 'test state', Zip__c = '12345', Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[i].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c='TEST')); 
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z003_Payer.Id, Sales_Organisation__c = 'NL60 - RSO Europe', Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', City__c = 'test city',  Country__c = 'test country',  Street_1__c = 'test street', Zip__c = '12345',   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[i].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST'));
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z004_Bill_To.Id,   Status__c='Draft', Legal_Name__c = 'test record' , Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',  City__c = 'test city', Country__c = 'test country', Zip__c = '12345',  Street_1__c = 'test street',  PO_Box__c = 'test po', PO_Box_City__c = 'po box city',  PO_Box_Postal_Code__c = '56789',    Language__c='E - English',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[i].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST'));
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z010_Intermediate_Consignee.Id, Status__c='Draft', Legal_Name__c = 'test record' , Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', City__c = 'test city', Country__c = 'test country', Zip__c = '12345',  Street_1__c = 'test street', PO_Box__c = 'test po', PO_Box_City__c = 'po box city',  PO_Box_Postal_Code__c = '56789',   Language__c='E - English',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[i].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c='TEST'));
            lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', City__c = 'test city', Country__c = 'test country', Zip__c = '12345',  Street_1__c = 'test street',  PO_Box__c = 'test po', PO_Box_City__c = 'po box city',  PO_Box_Postal_Code__c = '56789',  Language__c='E - English',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[i].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c ='USD - US Dollar',Incoterms_2__c='TEST'));
        }      
        
        insert lstSapCmds;                                                                 
         
        //prepare a set of all customer ids matching SAP CMD hub customer
        //assert SAP CMD records and funloc number field
        
        //prepare a set of all funloc ids          
        Set<Id> sapCmdIds = new Set<Id>();
        
        for(SAP_CMD__c obj : lstSapCmds)
        {
            system.assert(obj.Id != null);
            sapCmdIds.add(obj.Id);           
        }
        
        /***1601 - SIR 459, Modified by Scarlett***/
        lstSapCmds = [Select Id,  Legal_Name__c,  Name_2__c, Name_3__c, Street_1__c,   Name_4__c  , City__c ,   Zip__c ,   
                                                                                                Country__c ,   State_Province__c ,  PO_Box_Postal_Code__c ,   PO_Box_City__c , PO_Box__c, FunLoc__c ,
                                                                                                Customer_FunLoc_Number__c
                                                                                From SAP_CMD__c 
                                                                                Where Id in : sapCmdIds];
        /***1601 - SIR 459, Modified by Scarlett***/
        
        Set<Id> funlocIds = new Set<Id>();
        for(SAP_CMD__c obj : lstSapCmds)
        {
            funlocIds.add(obj.FunLoc__c);
            system.assert(obj.Customer_FunLoc_Number__c != null);
        } 
        
        Map<Id,Funloc__c> mapIdToFunloc = new Map<Id,Funloc__c>([Select Id , Name__c, SubName__c ,  Call_Name__c, Country_Name__c,
                                                                                                                                              Place_Name__c,  District_Name__c , PostCode__c , Street_Name__c,
                                                                                                                                               Subdivision_Name__c , PO_Box_Post_Code__c , PO_Box_Place_Name__c, Number__c                                                                                                                                            
                                                                                                                                              from Funloc__c
                                                                                                                                              Where Id IN :funlocIds ] );       
        
        FunLoc__c objFunloc;
        
        //fetch funloc records and assert results
        for(SAP_CMD__c objSapCmd : lstSapCmds)
        {
            if (objSapCmd.FunLoc__c!=null)
            {                 
                objFunloc = mapIdToFunloc.get(objSapCmd.FunLoc__c);
                system.assert(objFunloc!=null);
                
                system.assertEquals(objFunloc.Name__c, objSapCmd.Legal_Name__c);
                system.assertEquals(objFunloc.SubName__c, objSapCmd.Name_2__c);
                system.assertEquals(objFunloc.Call_Name__c, objSapCmd.Legal_Name__c);
                system.assertEquals(objFunloc.Street_Name__c, objSapCmd.Street_1__c);
                system.assertEquals(objFunloc.District_Name__c, objSapCmd.Name_4__c);
                
                system.assertEquals(objFunloc.Place_Name__c, objSapCmd.City__c);
                system.assertEquals(objFunloc.PostCode__c, objSapCmd.Zip__c);
                system.assertEquals(objFunloc.Country_Name__c, objSapCmd.Country__c);
                system.assertEquals(objFunloc.Subdivision_Name__c, objSapCmd.State_Province__c);
                system.assertEquals(objFunloc.PO_Box_Post_Code__c, objSapCmd.PO_Box_Postal_Code__c);
                system.assertEquals(objFunloc.PO_Box_Place_Name__c, objSapCmd.PO_Box_City__c);
                system.assertEquals(objFunloc.Number__c, objSapCmd.PO_Box__c);
            }
        }        
        //stop the test 
        Test.stopTest();   
    }
    
     /************************************************************************************************
        Case - New SAP CMD - > Account Group Z001, Z005, Z011, Z012 -  Sync data from GCM
    *************************************************************************************************/    
    static testMethod void SapCmdTriggerTest2() 
    {
        //prepare test data
        fetchRecordTypes();
        List<customer__c> lstCustomers = createCustomers();
        insert lstCustomers;
        
        map<Id, Customer__c> mapIdToCustomers = new map<Id, Customer__c>();
        for(Customer__c obj : lstCustomers)
        {
            system.assert(obj.Id != null);
            mapIdToCustomers.put(obj.Id, obj);  
        }
        
        //start the test
        Test.startTest();
         
        List<SAP_CMD__c> lstSapCmds = new List<SAP_CMD__c>();
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id, HUB_Customer__c = lstCustomers[0].Id, Status__c='Draft', Legal_Name__c = 'test record' ,   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[0].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Zip__c = '123456'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z005_SoldTo_BillTo_Payer.id,HUB_Customer__c = lstCustomers[1].Id , Status__c='Draft', Legal_Name__c = 'test record' ,    Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[1].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST', Zip__c = '123456'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z011_Sold_To.id,HUB_Customer__c = lstCustomers[2].id,Status__c='Draft', Legal_Name__c = 'test record',   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[2].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST', Zip__c = '123456'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z012_Sold_to_Ship_To.id,HUB_Customer__c = lstCustomers[3].id,Status__c='Draft', Legal_Name__c = 'test record',   Language__c='E - English',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[3].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c = 'TEST', Zip__c = '123456'));
        
        insert lstSapCmds;                                                                 
         
        Set<Id> sapCmdIds = new Set<Id>();               
        
        for(SAP_CMD__c obj : lstSapCmds)
        {
            system.assert(obj.Id != null);
            sapCmdIds.add(obj.Id);
        }

        
        //fetch SAP CMD Requests record and assert the results
        for(SAP_CMD__c obj : [Select Id , Legal_Name__c, Street_1__c,  City__c, State_Province__c, Country__c, Region__c,  Zip__c, Telephone__c, 
                                                        Fax__c, Email__c , 
                                                        //Scarlett Industry_Segment__c, 
                                                        //Scarlett on May 30 2016 Industry_Sub_Segment__c , 
                                                       HUB_Customer__c 
                                                       From SAP_CMD__c 
                                                       Where Id in : sapcmdIds])
        {
             Customer__c objCustomer = mapIdToCustomers.get(obj.HUB_Customer__c );
             
             /***1511 Release - SIR 474, Modified by Scarlett***/
             /*
             if(objCustomer != null)
             {           
                system.assert(objCustomer.Legal_Name__c != obj.Legal_Name__c);
                system.assertEquals(objCustomer.Street__c  , obj.Street_1__c);
                system.assertEquals(objCustomer.City__c , obj.City__c);
                system.assertEquals(objCustomer.State__c , obj.State_Province__c);
                system.assertEquals(objCustomer.Country__c , obj.Country__c);
                system.assertEquals(objCustomer.ZIP__c , obj.Zip__c);
                system.assertNotEquals(objCustomer.Telephone__c , obj.Telephone__c);
                system.assertNotEquals(objCustomer.Fax__c , obj.Fax__c);
                system.assertNotEquals(objCustomer.EMail__c , obj.Email__c);
                //Scarlett system.assertEquals(objCustomer.Industry_Segment__c , obj.Industry_Segment__c);
                /***Modified by Scarlett on Sep 30 2015***/
                //system.assertEquals(objCustomer.Industry_Sub_Segment__c , obj.Industry_Sub_Segment__c);
                /***Modified by Scarlett on Sep 30 2015 - END***/
             //}
             /***1511 Release - SIR 474, Modified by Scarlett - END***/
        }
          
        //stop the test 
        Test.stopTest();   
    }   
    
    
    /********************************************************
        Case - Update SAP CMD - > Sync data to Funloc
    *********************************************************/    
    static testMethod void SapCmdTriggerTest3() 
    {
        //prepare test data
        fetchRecordTypes();
        List<customer__c> lstCustomers = createCustomers();
        insert lstCustomers;
        
        List<SAP_CMD__c> lstSapCmds = new List<SAP_CMD__c>();
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z001_SoldTo_ShipTo_BillTo_Payer.id, HUB_Customer__c = lstCustomers[0].Id, Status__c='Draft', Legal_Name__c = 'test record' ,  Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[0].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Zip__c = '123456'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z005_SoldTo_BillTo_Payer.id,HUB_Customer__c = lstCustomers[1].Id , Status__c='Draft', Legal_Name__c = 'test record' ,  Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[1].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST', Zip__c = '123456'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z011_Sold_To.id,HUB_Customer__c = lstCustomers[2].id,Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[2].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST', Zip__c = '123456'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z012_Sold_to_Ship_To.id,HUB_Customer__c = lstCustomers[3].id,Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',   Language__c='E - English',FunLoc_Type__c='internal',End_Customer_NXP_Global_ID__c=lstCustomers[3].id,Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c = 'TEST', Zip__c = '123456'));
        
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z002_Ship_To.Id,  Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', City__c = 'test city', Country__c = 'test country', Street_1__c = 'test street',  State_Province__c = 'test state',    Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',  Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Zip__c = '123456')); 
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z003_Payer.Id,  Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', City__c = 'test city',  Country__c = 'test country',  Street_1__c = 'test street', Zip__c = '12345',   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',  Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z004_Bill_To.Id,   Status__c='Draft', Legal_Name__c = 'test record' , Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',  City__c = 'test city', Country__c = 'test country', Street_1__c = 'test street',  PO_Box__c = 'test po', PO_Box_City__c = 'po box city',  PO_Box_Postal_Code__c = '56789',     Language__c='E - English',FunLoc_Type__c='internal', Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST', Zip__c = '123456'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z010_Intermediate_Consignee.Id, Status__c='Draft', Legal_Name__c = 'test record' , Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', City__c = 'test city', Country__c = 'test country', Street_1__c = 'test street', PO_Box__c = 'test po', PO_Box_City__c = 'po box city',  PO_Box_Postal_Code__c = '56789',    Language__c='E - English',FunLoc_Type__c='internal',  Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Zip__c = '123456' ));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4', City__c = 'test city', Country__c = 'test country', Street_1__c = 'test street',  PO_Box__c = 'test po', PO_Box_City__c = 'po box city',  PO_Box_Postal_Code__c = '56789',   Language__c='E - English',FunLoc_Type__c='internal',  Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c ='USD - US Dollar',Incoterms_2__c='TEST', Zip__c = '123456'));
        
        insert lstSapCmds;
        
        for(SAP_CMD__c obj : lstSapCmds)
        {
            system.assert(obj.Id != null);
        }
        
        //start the test
        Test.startTest();
                                                                              
         //update SAP CMD records
         
        Set<Id> funlocIds = new Set<Id>();
        for(SAP_CMD__c obj : lstSapCmds)
        {
            funlocIds.add(obj.FunLoc__c);
            
            obj.Legal_Name__c = 'Legal name updated';
            obj.Name_2__c = 'name 2 updated';
            obj.Street_1__c =  'Street 1 updated';
            obj.Name_4__c = 'name 4 updated';
            obj.City__c = 'City updated';
            obj.Zip__c = '45459';
            obj.Country__c = 'country updated';
            obj.State_Province__c = 'state updated'; 
            obj.PO_Box_Postal_Code__c = 'PO updated';
            obj.PO_Box_City__c = 'PO City updated';
            obj.PO_Box__c = '60561';    
        } 
         
        update lstSapCmds;
        
        //fetch funloc records and assert results
        Map<Id,Funloc__c> mapIdToFunloc = new Map<Id,Funloc__c>([Select Id , Name__c, SubName__c ,  Call_Name__c, Country_Name__c,
                                                                                                                                              Place_Name__c,  District_Name__c , PostCode__c , Street_Name__c,
                                                                                                                                               Subdivision_Name__c , PO_Box_Post_Code__c , PO_Box_Place_Name__c, Number__c                                                                                                                                            
                                                                                                                                              from Funloc__c
                                                                                                                                              Where Id IN :funlocIds ] );       
        
        FunLoc__c objFunloc;
        for(SAP_CMD__c objSapCmd : lstSapCmds)
        {
            if (objSapCmd.FunLoc__c!=null)
            {                 
                objFunloc = mapIdToFunloc.get(objSapCmd.FunLoc__c);
                system.assert(objFunloc!=null);
                
                system.assertEquals(objFunloc.Name__c, objSapCmd.Legal_Name__c);
                system.assertEquals(objFunloc.SubName__c, objSapCmd.Name_2__c);
                system.assertEquals(objFunloc.Call_Name__c, objSapCmd.Legal_Name__c);
                system.assertEquals(objFunloc.Street_Name__c, objSapCmd.Street_1__c);
                system.assertEquals(objFunloc.District_Name__c, objSapCmd.Name_4__c);
                
                system.assertEquals(objFunloc.Place_Name__c, objSapCmd.City__c);
                system.assertEquals(objFunloc.PostCode__c, objSapCmd.Zip__c);
                system.assertEquals(objFunloc.Country_Name__c, objSapCmd.Country__c);
                system.assertEquals(objFunloc.Subdivision_Name__c, objSapCmd.State_Province__c);
                system.assertEquals(objFunloc.PO_Box_Post_Code__c, objSapCmd.PO_Box_Postal_Code__c);
                system.assertEquals(objFunloc.PO_Box_Place_Name__c, objSapCmd.PO_Box_City__c);
                system.assertEquals(objFunloc.Number__c, objSapCmd.PO_Box__c);
            }
        }  
     
        //stop the test 
        Test.stopTest();   
    }
    
    /************************************************************************************************
        Case - New SAP CMD 
        - > Blank CACC and Blank End Customer GID  and No suggestion by CACC Master
        -> CACC filled up and End Customer GID  filled up and No suggestion by CACC Master
        -> CACC filled up and Blank End Customer GID  and suggested by CACC Master        
    *************************************************************************************************/    
  
    static testMethod void SapCmdTriggerTest4() 
    {
        //prepare test data
        fetchRecordTypes();
        List<customer__c> lstCustomers = createCustomers();
        insert lstCustomers;
        
        map<Id, Customer__c> mapIdToCustomers = new map<Id, Customer__c>();
        for(Customer__c obj : lstCustomers)
        {
            system.assert(obj.Id != null);
            mapIdToCustomers.put(obj.Id, obj);  
        }
        
        //insert records in Consolidated Account Code object
        Consolidated_Account_Code__c objCode = new Consolidated_Account_Code__c(Name ='ZZZ', Code_Description__c = 'Test Code' , End_Customer_GID__c = lstCustomers[0].Id, Customer_Category__c = 'Focus', PD_Key_Account__c = 'Test', Base_Region__c = 'AM-Americas');
        insert objCode;
        system.assert(objCode.Id != null);
        
        //start the test
        Test.startTest();
         
        List<SAP_CMD__c> lstSapCmds = new List<SAP_CMD__c>();
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId = Z001_SoldTo_ShipTo_BillTo_Payer.Id, HUB_Customer__c = lstCustomers[0].Id, Status__c='Draft', Legal_Name__c = 'test record' ,   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal', Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c='TEST', Zip__c = '123456'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z005_SoldTo_BillTo_Payer.id,HUB_Customer__c = lstCustomers[1].Id , Status__c='Draft', Legal_Name__c = 'test record' ,  Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',  Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST', Consolidated_Account_Code__c = objCode.Id, End_Customer_NXP_Global_ID__c = lstCustomers[1].Id, Zip__c = '123456'));
        lstSapCmds.add(new SAP_CMD__c(RecordTypeId=Z011_Sold_To.id,HUB_Customer__c = lstCustomers[2].id,Status__c='Draft', Legal_Name__c = 'test record', Name_2__c = 'additional name', Name_3__c = 'test name 3', Name_4__c = 'test name 4',   Language__c='M - Traditional Chinese',FunLoc_Type__c='internal',  Grp_1_Sls_Channel_SP__c='DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Incoterms_2__c= 'TEST', Consolidated_Account_Code__c = objCode.Id, Zip__c = '123456'));
        
        insert lstSapCmds;                                                                 
         
        Set<Id> sapCmdIds = new Set<Id>();               
        
        for(SAP_CMD__c obj : lstSapCmds)
        {
            system.assert(obj.Id != null);
            sapCmdIds.add(obj.Id);
        }

        
        //fetch SAP CMD Requests record and assert the results
        for(SAP_CMD__c obj : [Select Id , RecordTypeId,  HUB_Customer__c , Consolidated_Account_Code__c , End_Customer_NXP_Global_ID__c 
                                                       From SAP_CMD__c 
                                                       Where Id in : sapcmdIds])
        {
             //Customer__c objCustomer = mapIdToCustomers.get(obj.HUB_Customer__c );
             
             if(obj.RecordTypeId == Z001_SoldTo_ShipTo_BillTo_Payer.Id )
             {
                system.assert(obj.Consolidated_Account_Code__c  == null);
                system.assert(obj.End_Customer_NXP_Global_ID__c == null);
             }
             else  if(obj.RecordTypeId == Z005_SoldTo_BillTo_Payer.Id )
             {
                system.assert(obj.Consolidated_Account_Code__c  != null);
                system.assert(obj.End_Customer_NXP_Global_ID__c != null);
                system.assert(obj.End_Customer_NXP_Global_ID__c != lstCustomers[0].Id);
                system.assert(obj.End_Customer_NXP_Global_ID__c == lstCustomers[1].Id);
             }
             else  if(obj.RecordTypeId == Z011_Sold_To.Id )
             {
                system.assert(obj.Consolidated_Account_Code__c  != null);
                system.assert(obj.End_Customer_NXP_Global_ID__c != null);
                system.assert(obj.End_Customer_NXP_Global_ID__c == lstCustomers[0].Id);
             }
        }
          
        //stop the test 
        Test.stopTest();   
    }    
        
}