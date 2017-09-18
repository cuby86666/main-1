/*****************************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      16 Oct 2013
@Description:       Test Class for Controller class TaxClassificationController
--------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      14 Feb 2014
@Description:        Updated test methods to fix it due to new mandatory field - Legal Name in  SAP CMD
--------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:     11 Jun 2014
@Description:        Updated test methods to fix it due to remove CACC related fields
--------------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      26 Sep 2014
@Description:        Updated test methods to fix it due to new mandatory field - Zip
--------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      27 Aug 2015
@Description:        Added test method for sales org code HK91 (Julie CMD)
-------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      31 May 2016
@Description:        1606 Release SIR 915 -     [COM] Revise Funloc CMD approval flow 
                     and add new Tax Classification for new Sales Orgs/CSC Site
-------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :     Baji
@Modified Date:    Aug 30, 2016 
@Description:      Modified for SIR 990. To obsolete and then adjust the transportation zone field to change it's data-type
---------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      24 Mar 2017
@Description:        1704 Release (SFDC 327) - Remove Nexperia sales org. ( MY61, PH62, CN61 & HK91) from SAP CMD Request picklist
-------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      27 June 2017
@Description:        1707 Release (SFDC 455) - Generate Tax Classifications for Sales Org. CN60
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      01 Aug 2017 
@Description:        1708 Release (SFDC 729) - Generate Tax Classifications for MANU/SBE sales orgs.
******************************************************************************************************************/

@isTest
private class TaxClassificationControllerTest
{
    private static final String TYPE_Z010_INTERMEDIATE_CONSIGNEE = 'Z010_Intermediate_Consignee';
    private static final String TYPE_Z005_SOLD_TO_BILL_TO_PAYER = 'Z005_SoldTo_BillTo_Payer';
    private static final String TYPE_Z013_PAYER_BILL_TO = 'Z013_Payer_Bill_To';
    
    private static RecordType Z010_Intermediate_Consignee;
    private static RecordType Z005_SoldTo_BillTo_Payer;
    private static RecordType Z013_Payer_Bill_To;  
    
    private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
    private static RecordType globalCustomer;
    
    //to fetch record types 
    private static void fetchRecordTypes()
    {
        //get SAP CMD record type
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              ((SobjectType = 'SAP_CMD__c' and (DeveloperName =: TYPE_Z010_INTERMEDIATE_CONSIGNEE
                                                                or DeveloperName =: TYPE_Z005_SOLD_TO_BILL_TO_PAYER
                                                                or DeveloperName =: TYPE_Z013_PAYER_BILL_TO
                                                                ))or(SobjectType = 'Customer__c' and (DeveloperName =: TYPE_GLOBALENTERPRISE))
                              )])
        {   
            if(rt.DeveloperName == TYPE_Z010_INTERMEDIATE_CONSIGNEE)
            {
                Z010_Intermediate_Consignee = rt;
            }
            else if(rt.DeveloperName == TYPE_Z013_PAYER_BILL_TO)
            {
                Z013_Payer_Bill_To = rt;
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
    
    //method to return a customer
    private static Customer__c createCustomer()
    {
         Customer__c objCustomer;
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
         return objCustomer;
    }
    
    //Case - Sales Organisation ->NL60 - RSO Europe
    static testMethod void TaxClassificationControllerTest1()
    {
        //prepare test data
        fetchRecordTypes();
        
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z005_SoldTo_BillTo_Payer.id,HUB_Customer__c = objCustomer.id,Status__c='Draft',
                                                Legal_Name__c = 'test legal name' ,  Language__c='E - English', FunLoc_Type__c='internal', End_Customer_NXP_Global_ID__c = objCustomer.Id, 
                                                Grp_1_Sls_Channel_SP__c = 'DIS - Distributor',Acct_assgmt_group__c='01 - Local 3rd Party',
                                                Currency__c='USD - US Dollar', Sales_Organisation__c='NL60 - RSO Europe',Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1');
        insert objSapCmd;
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();
    }
    
    //Case - Sales Organisation ->US60 - RSO U.S.A.
    static testMethod void TaxClassificationControllerTest2()
    {
        //prepare test data
        fetchRecordTypes();
        
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId = Z010_Intermediate_Consignee.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft',
                                                Legal_Name__c = 'test legal name' ,   City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English',FunLoc_Type__c='Internal',                                               
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'US60 - RSO U.S.A.', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '123456');
        insert objSapCmd;
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();
     }
     
     //Case - Sales Organisation -> MSO China CN60
    static testMethod void TaxClassificationControllerTestCN60()
    {
        //prepare test data
        fetchRecordTypes();
        
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId = Z010_Intermediate_Consignee.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft',
                                                Legal_Name__c = 'test legal name' ,   City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English',FunLoc_Type__c='Internal',                                               
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'CN60 - MSO China CN60', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '123456');
        insert objSapCmd;
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();
     }
    
    //Case - Sales Organisation ->CN62 - MSO China
    static testMethod void TaxClassificationControllerTest3()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'CN62 - MSO China', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '123456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }       
    
    //Case - Sales Organisation ->  HK91 - WeEn Semiconductor
   /* static testMethod void TaxClassificationControllerTest4()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'HK91 - WeEn Semiconductor', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }  */
    
    //Case - Sales Organisation ->  JP60 - MSO Japan
    static testMethod void TaxClassificationControllerTest5()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'JP60 - MSO Japan',Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }     
        //Case - Sales Organisation ->  US63 - NXP San Jose
    static testMethod void TaxClassificationControllerTest6()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'US63 - NXP San Jose', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    } 
            //Case - Sales Organisation ->  US63 - NXP San Jose
    static testMethod void TaxClassificationControllerTest7()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'US63 - NXP San Jose', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    } 
            //Case - Sales Organisation ->  CN61 - MSO China
  /*  static testMethod void TaxClassificationControllerTest8()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'CN61 - MSO China', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    } */
            //Case - Sales Organisation ->  CN64 - Tianjin
    static testMethod void TaxClassificationControllerTest9()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'CN64 - Tianjin', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }    
    //Case - Sales Organisation ->  MY61 - NXP Seremban            
   /* static testMethod void TaxClassificationControllerTest10()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'MY61 - NXP Seremban',Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }     
        //Case - Sales Organisation ->  PH62 - NXP Cabuyao            
    static testMethod void TaxClassificationControllerTest11()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'PH62 - NXP Cabuyao', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }  */    
            //Case - Sales Organisation ->  TH61 - NXP Thailand            
    static testMethod void TaxClassificationControllerTest12()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'TH61 - NXP Thailand', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
                //Case - Sales Organisation ->  TW61 - NXP Kaohsiung            
    static testMethod void TaxClassificationControllerTest13()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'TW61 - NXP Kaohsiung',Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }  
    static testMethod void TaxClassificationSalesOrgAT61()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'AT61 - SOrg. GRK', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgBE61()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'BE61 - NXP Semicon. Leuven', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgCN68()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c =  'CN68 - NXP(China)Management', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgDE42()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'DE42 - NXP Hamburg Other', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesORGEM61()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'EM61 - NXP GEM', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgFR61()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c =  'FR61 - NXP Caen', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgIN61()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'IN61 - NXP India', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgMX61()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'MX61 - SOrg. Mexico', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgNL40()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'NL40 - NXP Nijmegen Site Su', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgNL61()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'NL61 - Nijmegen', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgNL68()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'NL68 - NXP Software', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgRO61()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'RO61 - SOrg. Romania', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }      
    static testMethod void TaxClassificationSalesOrgDE63()
    {
        //prepare test data
        fetchRecordTypes();
        //inserting customer list 
        customer__c objCustomer = createCustomer();
        insert objCustomer;
        system.assert(objCustomer.Id != null);
        
        SAP_CMD__c objSapCmd = new SAP_CMD__c(RecordTypeId=Z013_Payer_Bill_To.Id, HUB_Customer__c = objCustomer.Id, Status__c='Draft', 
                                                Legal_Name__c = 'test legal name4' ,  City__c= 'ut_city', Street_1__c = 'ut_Street1', Country__c = 'ANDORRA',    
                                                Language__c='E - English', FunLoc_Type__c='Internal',
                                                End_Customer_NXP_Global_ID__c = objCustomer.Id, Grp_1_Sls_Channel_SP__c='DIS - Distributor',
                                                Acct_assgmt_group__c='01 - Local 3rd Party',Currency__c='USD - US Dollar',Sales_Organisation__c = 'DE63 - NXP Semi. Germany', Transportation_Zone__c='AR1',
                                                Customer_Factory_Calendar__c='1A - Customer Calendar ARROW NL',Fix_Price_Ind_SP__c='Y - Yes',
                                                Reconciliation_Account__c='1200000 - Trade AR with domestic parties',Terms_of_payment__c='014 - Prepaid',
                                                Payment_Credit_Memo__c='014 - Prepaid',S_O_Sub_Group__c='AT - Austria',Reprice_Basis__c='C - Conf. Delivery Date',
                                                 Distribution_Region__c='A1 - HK00',Cust_pric_proc__c='1 - OEM/EMS Pricing',Incoterms_1__c='CIP - Carriage & Insurance Paid To',
                                                 Delivery_priority__c='10 - Priority 1', Zip__c = '188456');
        insert objSapCmd;        
        system.assert(objSapCmd.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objSapCmd.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationController controller = new TaxClassificationController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassification method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objSapCmd.Id);
        
        //stop the test
        Test.stopTest();   
    }               
}