/******************************************************************************
@Created By :       Scarlett Kang
@Created Date:      19 Aug 2015
@Description:       Test data revision for new validation rule
-------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      01 April 2016
@Description:        1604 Release - SIR 706. SAP CMD - allow ZORG funloc to flow from SFDC to SAP
-------------------------------------------------------------------------------
@Modified By :       Shridevi   
@Modified Date:      April 21, 2016 
@Description:        1605 Release (SIR 534) - For testing the copied the value of the field  No_of_days_for_Early_Shipment__c from cmd Request to SAP cmd for Z001,Z002,Z012 Account groups.
-------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Aug 31, 2016 
@Description:        1609 Release SIR 1102 & 990 - commented/uncommented the code to change CMD Request's field data-type.
---------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Mar 14, 2017 
@Description:        To fix test class error : GSM Controller Approver Group is mandatory
---------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Apr 17, 2017 
@Description:        To test SFDC-428 functionality(To link multiple ZORG SAP CMDs to CMD Request) and improve overall code coverage 
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      Apr 26, 2017
@Description:        To test 1705 Release (SFDC 467) -  To generate ZORG SAP CMDs based on rule provided.
---------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      Apr 26, 2017 
@Description:        SFDC-430 - Replace GSM COntroller Approver Group picklist to new multiselect picklist Controller Approver Group
---------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      Jun 01, 2017 
@Description:        SFDC-477 - Make Controller Approver required in case of new funloc request
----------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      21 Jun 2017
@Description:        1707 Release (SFDC 585) -  To test new fields 'Version ID for internationla addresses' & 'Tax Number 5' for MSO China project
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      17 Jul 2017 
@Description:        1708 Release (SFDC 684) - SAP CMD - BillCurrency-PY should be on SAP CMD layout
******************************************************************************/
@isTest
private class CMD_Request_Controller_SAP_Ext_Test {
    
    private static RecordType newSAPrt;
    private static Id newMANUSAPrt;
    private static String newSAPrtId = '012D0000000QlBaIAK';
//    private static String newSAPrtId = '012M00000004ejsIAA';
    
    private static CMD_Request__c testRequest;

    private static Customer__c testCustomer;
    
    private static Consolidated_Account_Code__c testCACC;
    
    private static Tax_Classification__c testTaxClassification;
    private static String funlocId;
    
    private static void fetchRecordTypes(){
        for(RecordType rt : [   
            Select Id, DeveloperName
            From RecordType
            WHERE SobjectType = 'CMD_Request__c' 
            AND DeveloperName LIKE '%SAP%' 
            AND IsActive=true
        ]){
            if( rt.DeveloperName == 'SAP New Funloc Request' ) {
                newSAPrt = rt;
//              newSAPrtId = String.valueOf(rt.Id);            
                newSAPrtId = rt.Id;            
            }
           if( rt.DeveloperName == 'SAP_New_MANU_Funloc_request' ) {
                newMANUSAPrt = rt.id;
             }
    }
  }
    private static List<Sales_Organisation_ZORG__c> lstCustomSalesOrgSetting;
    private static void createSalesOrgCustomSetting(){
    lstCustomSalesOrgSetting = new List<Sales_Organisation_ZORG__c>();
    
    lstCustomSalesOrgSetting.add(new Sales_Organisation_ZORG__c(Name = 'CN64 - Tianji'));
    lstCustomSalesOrgSetting.add(new Sales_Organisation_ZORG__c(Name = 'TH61 - NXP Thailand'));
    lstCustomSalesOrgSetting.add(new Sales_Organisation_ZORG__c(Name = 'TW61 - NXP Kaohsiung'));
    lstCustomSalesOrgSetting.add(new Sales_Organisation_ZORG__c(Name = 'US63 - NXP Austin'));
        
    insert lstCustomSalesOrgSetting;
  }

    private static void prepareTestCustomer(){
        testCustomer = new Customer__c(
            DNB_Verified__c = 'DNB Accepted',
            Legal_Name__c = 'Test Legal Name',
            Account_Name__c = 'Test Account Name',
            Street__c = 'Test Street',
            City__c = 'Test City',
            Country__c = 'Netherlands',
            Zip__c = 'Test',
            Industry_Segment__c = 'AA - Appliances',
            Industry_Sub_Segment__c = 'A1 - Major Home Appliances',
            Role__c = 'Focused'
        );
        insert testCustomer;
    }
    
    public static void prepareConsolidatedAccountCode(){
        testCACC = new Consolidated_Account_Code__c(
            Name = 'ABC',
            Base_Region__c = 'Test',
            Customer_Category__c = 'Test',
            Delivery_Priority__c = 'Test',
            Code_Description__c = 'ABC',
            PD_Key_Account__c = 'test'
        );
        insert testCACC;
    }
    
    private static void insertFunloc(){
        Funloc__c objFunloc = new Funloc__c(
            Name__c = 'Test Convert',
            Call_Name__c = 'Test Convert',
            Street_Name__c = 'Test Convert',
            Place_Name__c = 'Test Convert',
            Country_Name__c = 'Test Convert'
        );
        insert objFunLoc;  
        List<FunLoc__c> fl = [select id from FunLoc__c where Name__c='Test Convert'];
        if(fl.size() >0){
            funlocId = fl.get(0).id;
        }
    }
    
    //@isTest(SeeAllData=true) 
    //static void theZ001Test(){
    static testmethod void theZ001Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z001',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
            //SP_GID__c = testCustomer.Name,
            SP_GID__c = string.valueof(lstCustomer[0].Name),
//Scarlett
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'Test',
            Sales_Rep_ZS__c = 'Test',
            Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;
        
        testTaxClassification = new Tax_Classification__c(
            CMD_Request__c = testRequest.Id,
            Country__c = 'AT - Austria', 
            Tax_Category__c = 'MWST', 
            Tax_Classification__c = '1'
        );
        insert testTaxClassification;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z001';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU'; 
//        theControllerExt.theCMD.HUB_Customer__c = testCustomer.Id;
        theControllerExt.New_SAP_CMD(); 
      //  System.debug('theControllerExt::'+theControllerExt);
       //  System.debug('theControllerExt.theRequest----'+ theControllerExt.theRequest);  
       //   System.debug('theControllerExt.thecmd----'+ theControllerExt.thecmd); 
        //  System.debug('theControllerExt.thecmd.No_of_days_for_Early_Shipment__c----'+theControllerExt.thecmd.No_of_days_for_Early_Shipment__c); 
        /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       Test.stopTest();
    }  
    
    static testmethod void theZ001Test2(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z001',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='No',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Screened_for_SDI__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Controller_Approver_Group__c = 'AP - South Asia-Pacific' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;
        
        testTaxClassification = new Tax_Classification__c(
            CMD_Request__c = testRequest.Id,
            Country__c = 'ES - Spain', 
            Tax_Category__c = 'MWST', 
            Tax_Classification__c = '1'
        );
        insert testTaxClassification;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z001';
        theControllerExt.New_SAP_CMD(); 
     
        /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ002Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z002',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/          // Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//Scarlett
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            SH_Name__c = 'Test Name',
            SH_Street__c = 'Test Street',
            SH_City__c = 'Test City',
            SH_Country__c = 'Test Country',
            SH_Postal_Code__c = '12345',
            SH_Region__c = 'EU - Europe',
            SH_Telephone__c = '+1234567890',
            SH_Fax__c = '+1234567890',
            SH_Email__c = 'test@test.com',
            SH_Funloc__c = '100000',
            SH_Funloc_Id__c = funLocId,
            Company_Code__c = 'Test',
            Label_required__c = 'Yes',
            Label_Code__c = '12345',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Controller_Approver_Group__c = 'EU - EMEA' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z002';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();      
          /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
        Test.stopTest();
    }  
    
    static testmethod void theZ001MANUReq(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z001',
            RecordTypeId = newMANUSAPrt,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
            //SP_GID__c = testCustomer.Name,
            SP_GID__c = string.valueof(lstCustomer[0].Name),
//Scarlett
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Postal_Code__c = '12345',
            Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            No_of_days_for_Early_Shipment__c=50,
            Order_combination__c='Yes',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            BillCurrency_PY__c = 'Test',
            Sales_Rep_ZS__c = 'Test',
            Controller_Approver_Group__c = 'AP - South Asia-Pacific', //Line added by Nisha Agrawal for SFDC-477
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5'
        );
        insert testRequest;
        
        testTaxClassification = new Tax_Classification__c(
            CMD_Request__c = testRequest.Id,
            Country__c = 'AT - Austria', 
            Tax_Category__c = 'MWST', 
            Tax_Classification__c = '1'
        );
        insert testTaxClassification;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z001';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU'; 
//        theControllerExt.theCMD.HUB_Customer__c = testCustomer.Id;
        theControllerExt.New_SAP_CMD(); 
      //  System.debug('theControllerExt::'+theControllerExt);
       //  System.debug('theControllerExt.theRequest----'+ theControllerExt.theRequest);  
       //   System.debug('theControllerExt.thecmd----'+ theControllerExt.thecmd); 
        //  System.debug('theControllerExt.thecmd.No_of_days_for_Early_Shipment__c----'+theControllerExt.thecmd.No_of_days_for_Early_Shipment__c); 
        /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       
       Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ002SPTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z002',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//Scarlett
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = funLocId,
            SH_Same_as_SP__c = true,
            Company_Code__c = 'Test',
            Label_required__c = 'Yes',
            Label_Code__c = '12345',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Screened_for_SDI__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Controller_Approver_Group__c = 'EU - EMEA' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z002';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ003Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z003',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
            //PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Test Country',
            PY_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            PY_Telephone__c = '+1234567890',
            PY_Fax__c = '+1234567890',
            PY_Email__c = 'test@test.com',
            PY_Funloc__c = '100000',
            //PY_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            PY_Funloc_Id__c = funLocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            BillCurrency_PY__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'M',
            Tax_Number_5__c = 'Test Tax Number 5',
            Controller_Approver_Group__c = 'GC - Greater China; CO - Correction Region' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z003';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }  
    @isTest
    static void theZ003MANUTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z003',
            RecordTypeId = newMANUSAPrt,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
            //PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Test Country',
            PY_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            PY_Telephone__c = '+1234567890',
            PY_Fax__c = '+1234567890',
            PY_Email__c = 'test@test.com',
            PY_Funloc__c = '100000',
            //PY_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            PY_Funloc_Id__c = funLocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            BillCurrency_PY__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'M',
            Tax_Number_5__c = 'Test Tax Number 5',
            Controller_Approver_Group__c = 'GC - Greater China; CO - Correction Region' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z003';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }  


    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ003SPTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z003',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            //SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SP_Funloc_ID__c=funLocId,
            PY_Same_as_SP__c = true,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
             Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Screened_for_SDI__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Controller_Approver_Group__c ='KR - Korea' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z003';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ004Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z004',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            BP_GID__c = testCustomer.Name,
            BP_CustomerID__c = testCustomer.Id,
            BP_GID__c = '100000000',
            //BP_CustomerID__c = 'a1ND0000001vB7GMAU',
            BP_Name__c = 'Test Name',
            BP_Street__c = 'Test Street',
            BP_City__c = 'Test City',
            BP_Country__c = 'Test Country',
            BP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            BP_Telephone__c = '+1234567890',
            BP_Fax__c = '+1234567890',
            BP_Email__c = 'test@test.com',
            BP_Funloc__c = '100000',
            //BP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            BP_Funloc_ID__c=funlocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Controller_Approver_Group__c ='KR - Korea' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z004';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();   
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ004SPTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z004',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            //SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SP_Funloc_Id__c = funLocId,
            BP_Same_as_SP__c = true,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
             Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Screened_for_SDI__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Controller_Approver_Group__c ='NA - Americas' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z004';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();      
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ004PYTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z004',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,            
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
//            PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Test Country',
            PY_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            PY_Telephone__c = '+1234567890',
            PY_Fax__c = '+1234567890',
            PY_Email__c = 'test@test.com',
            PY_Funloc__c = '100000',
            //PY_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            PY_Funloc_Id__c = funLocId,
            BP_Same_as_PY__c = true,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Controller_Approver_Group__c ='NA - Americas' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z004';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    //static void theZ005Test(){
    static testmethod void theZ005test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z005',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            //SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SP_Funloc_ID__c=funlocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            BillCurrency_PY__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5',
            Controller_Approver_Group__c ='JP - Japan' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z005';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';  
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  
     static testmethod void theZ005MANUtest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z005',
            RecordTypeId = newMANUSAPrt,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            //SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SP_Funloc_ID__c=funlocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            BillCurrency_PY__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'C',
            Tax_Number_5__c = 'Test Tax Number 5',
            Controller_Approver_Group__c ='JP - Japan' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z005';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';  
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  
    static testmethod void theZ005test2(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z005',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            
            SP_Funloc_ID__c=funlocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Order_combination__c='No',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Screened_for_SDI__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Controller_Approver_Group__c ='JP - Japan' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z005';

        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ010Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z010',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            ZI_GID__c = testCustomer.Name,
            ZI_CustomerID__c = testCustomer.Id,
            ZI_GID__c = '100000000',
//            ZI_CustomerID__c = 'a1ND0000001vB7GMAU',
            ZI_Name__c = 'Test Name',
            ZI_Street__c = 'Test Street',
            ZI_City__c = 'Test City',
            ZI_Country__c = 'Test Country',
            ZI_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            ZI_Telephone__c = '+1234567890',
            ZI_Fax__c = '+1234567890',
//            ZI_Email__c = 'test@test.com',
            ZI_Funloc__c = '100000',
//            ZI_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z010';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();      
        Test.stopTest();
    }  
    @isTest
    static void theZ010Test1(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z010',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            ZI_GID__c = testCustomer.Name,
            ZI_CustomerID__c = testCustomer.Id,
            ZI_GID__c = '100000000',
//            ZI_CustomerID__c = 'a1ND0000001vB7GMAU',
            ZI_Name__c = 'Test Name',
            ZI_Street__c = 'Test Street',
            ZI_City__c = 'Test City',
            ZI_Country__c = 'Test Country',
            ZI_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            ZI_Telephone__c = '+1234567890',
            ZI_Fax__c = '+1234567890',
//            ZI_Email__c = 'test@test.com',
            ZI_Funloc__c = '100000',
//            ZI_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Order_combination__c='No',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Screened_for_SDI__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No'

        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z010';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();      
        Test.stopTest();
    }  


    //@isTest(SeeAllData=true) 
    //static void theZ011Test(){
    
    static testmethod void theZ011Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z011',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Controller_Approver_Group__c ='JP - Japan' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z011';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';   
        theControllerExt.New_SAP_CMD();   
        Test.stopTest();
    }  
    
    static testmethod void theZ011Test1(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);
        
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z011',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Screened_for_SDI__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Controller_Approver_Group__c ='JP - Japan' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z011';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';   
        theControllerExt.New_SAP_CMD();   
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    //static void theZ012Test(){
    static testmethod void theZ012Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        Test.startTest();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);        
        
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z012',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            //SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SP_Funloc_ID__c = funLocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Controller_Approver_Group__c ='CO - Correction Region' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z012';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';  
        theControllerExt.New_SAP_CMD();      
          /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       
        Test.stopTest();
    }  
    
    static testmethod void theZ012Test1(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        Test.startTest();
        insertFunloc();
        List<Customer__c> lstCustomer = [SELECT Id, Name FROM Customer__c];
        system.assert(lstCustomer.size() > 0);        
        
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z012',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
//            SP_CustomerID__c = testCustomer.Id,
//            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_GID__c = string.valueof(lstCustomer[0].Name),
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            //SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SP_Funloc_ID__c = funLocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Order_combination__c='No',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Screened_for_SDI__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Controller_Approver_Group__c = 'CO - Correction Region' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z012';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';  
        theControllerExt.New_SAP_CMD();      
          /*********************************************** modified for SIR534**********************************************************************/
        system.assertEquals(theControllerExt.thecmd.No_of_days_for_Early_Shipment__c,theControllerExt.theRequest.No_of_days_for_Early_Shipment__c);
        /*********************************************** modified for SIR534**********************************************************************/
       
        Test.stopTest();
    }  

    //@isTest(SeeAllData=true) 
    @isTest
    static void theZ013Test(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z013',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
//            PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Test Country',
            PY_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            PY_Telephone__c = '+1234567890',
            PY_Fax__c = '+1234567890',
            PY_Email__c = 'test@test.com',
            PY_Funloc__c = '100000',
            //PY_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            PY_Funloc_Id__c = funlocId,
            PY_Same_as_SP__c = false,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            BillCurrency_PY__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'M',
            Tax_Number_5__c = 'Test Tax Number 5',
            Controller_Approver_Group__c = 'Channel - Channel' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;
        System.debug('STAN:testRequest.Account_Group__c=' + testRequest.Account_Group__c);
        System.debug('STAN:theRequest.PY_Same_as_SP__c=' + testRequest.PY_Same_as_SP__c);

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z013';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }
    
     @isTest
    static void theZ013MANUTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z013',
            RecordTypeId = newMANUSAPrt,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO', 
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            PY_GID__c = testCustomer.Name,
            PY_CustomerID__c = testCustomer.Id,
            PY_GID__c = '100000000',
//            PY_CustomerID__c = 'a1ND0000001vB7GMAU',
            PY_Name__c = 'Test Name',
            PY_Street__c = 'Test Street',
            PY_City__c = 'Test City',
            PY_Country__c = 'Test Country',
            PY_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            PY_Telephone__c = '+1234567890',
            PY_Fax__c = '+1234567890',
            PY_Email__c = 'test@test.com',
            PY_Funloc__c = '100000',
            //PY_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            PY_Funloc_Id__c = funlocId,
            PY_Same_as_SP__c = false,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            BillCurrency_PY__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Screened_for_SDI__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'M',
            Tax_Number_5__c = 'Test Tax Number 5',
            Controller_Approver_Group__c = 'Channel - Channel' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;
      ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z013';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }

   // @isTest(SeeAllData=true) 
   @isTest
    static void theZ013SPTest(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            Account_Group__c = 'Z013',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
/*STAN needs to enhance*/           //Consolidated_Account_Code__c = 'a1rD0000007BKFfIAO',
/*Modified by Scarlett*/            Consolidated_Account_Code__c = testCACC.Id,
//            SP_GID__c = testCustomer.Name,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            //SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SP_Funloc_Id__c = funlocId,
            PY_Same_as_SP__c = true,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Screened_for_SDI__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Controller_Approver_Group__c = 'Channel - Channel' //Line added by Nisha Agrawal for SFDC-477
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'Z013';
//        theControllerExt.theCMD.HUB_Customer__c = 'a1ND0000001vB7GMAU';    
        theControllerExt.New_SAP_CMD();  
        Test.stopTest();
    }  
    
    /***1604 Release - SIR 706, Added by Scarlett - START***/
    //ZORG not same as Ship-to
    //@isTest(seeAllData = TRUE)
    @isTest
    static void theZORGtest1(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            ZORG_Same_as_SH__c = FALSE,
            Account_Group__c = 'ZORG',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'US60 - RSO U.S.A.',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            //SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SP_Funloc_Id__c = funlocId,
            SH_Same_as_SP__c = true,
            Company_Code__c = 'Test',
            Label_required__c = 'Yes',
            Label_Code__c = '12345',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            
            //GSM_Controller_Approver_Group__c = 'GC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'GC - Greater China', //added by Nisha Agrawal on Apr 26 for SFDC-430
            Additional_Shipping_Mark__c = 'Test',
            Additional_VAT_Number_1__c = '12345',
            Additional_VAT_Number_2__c = '12345',
            Additional_VAT_Number_3__c = '12345',
            Additional_VAT_Number_4__c = '12345',
            Additional_VAT_Number_5__c = '12345',
            Additional_VAT_Number_6__c = '12345',
            Additional_VAT_Number_7__c = '12345',
            Additional_VAT_Number_8__c = '12345',
            
            Billing_Block__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            Central_Billing_Block__c = 'Test',
            //Central_deletion_block__c = true,
            //Central_Deletion_Flag__c = 'Yes',
            Central_delivery_block__c = 'Test',
            Central_order_block__c = 'Test',
            //Central_posting_block__c = 'Yes',
            ZORG_City__c = 'Test',
            City_Chinese__c = 'Test',
            Controlled_Party__c = 'Test',
            ZORG_Country__c = 'Test',
            Country_Additional_VAT_Number_1__c = '12345',
            Country_Additional_VAT_Number_2__c = '12345',
            Country_Additional_VAT_Number_3__c = '12345',
            Country_Additional_VAT_Number_4__c = '12345',
            Country_Additional_VAT_Number_5__c = '12345',
            Country_Additional_VAT_Number_6__c = '12345',
            Country_Additional_VAT_Number_7__c = '12345',
            Country_Additional_VAT_Number_8__c = '12345',
            CPNJ_for_Brazil__c = '12345',
            Customer_Statistics_Group__c = '12345',
            //Deletion_Block_Company_Code__c = 'Yes',
            //Deletion_Flag_Company_Code__c = 'Yes',
            //Deletion_Flag_Sales_Area__c = 'Yes',
            Delivery_Block__c = '12345',
            Delivery_Group_Ind_SH__c = '12345',
            Delivery_priority__c = '12345',
            Distribution_Channel__c = '12345',
            Distribution_Region__c = '12345',
            Division__c = '12345',
            ZORG_Email__c = 'test@test.com',
            Exch_rate_type__c = '12345',
            Freight_Forwarder__c = '12345',
            FunLoc_Type__c = '12345',
            Grp_2_Cus_Prce_Grp_SP__c = 'Test',
            Incoterms_1_ZORG__c = 'Test',
            Incoterms_2_ZORG__c = 'Test',
            Language__c = 'Test',
            ZORG_Name__c  = 'Test',
            Main_shipping_mark__c  = 'Test',
            Matl_Det_Grp_SP__c = 'Test',
            Max_partial_deliveries__c = '01',
            Military_Usage__c = 'Test',
            Chinese_Name1__c = 'Test',
            ZORG_Name_Line_2__c = 'Test',
            Chinese_Name2__c = 'Test',
            ZORG_Name_Line_3__c = 'Test',
            ZORG_Name_Line_4__c = 'Test',
            Non_I2_related_SP_ZORG__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination_ZORG__c = 'Test',
            Partial_delivery_per_item__c = 'Test',
            Payment_Guarantee_Procedure__c = 'Test',
            //Posting_Block_Company_Code__c = 'Yes',
            Sales_Area_Region__c = 'Test',
            Screened_for_SDI__c = 'Test',
            Shipping_Condition__c = 'Test',
            ZORG_State__c = 'Test',
            Chinese_Street__c = 'Test',
            ZORG_Street__c = 'Test',
            Taxes_Number_1__c = 'Test',
            ZORG_Telephone__c = 'Test',
            Trading_Partner__c = 'Test',
          //  Transportation_Zone_ZORG__c = 'Test',
            Unloading_Point__c = 'Test',
            VAT_Registration_Number__c = 'Test',
            ZORG_Postal_Code__c = 'Test',
            Central_deletion_block__c= 'Yes',
            Central_deletion_Flag__c = 'Yes',
            Central_posting_block__c = 'Yes',
            Deletion_Flag_Sales_Area__c = 'Yes',
            Deletion_Block_Company_Code__c = 'Yes',
            Deletion_Flag_Company_Code__c = 'Yes',
            Indicator_Record_Payment_History__c = 'Yes',
            Posting_Block_Company_Code__c = 'Yes',
            Version_ID_for_International_Addresses__c = 'C'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'ZORG'; 
        theControllerExt.New_SAP_CMD();   
        Test.stopTest();
    }
    
    //ZORG same as Ship-to, SH same as SP
    //@isTest(seeAllData = TRUE)
    @isTest
    static void theZORGtest2(){
        fetchRecordTypes();
        prepareTestCustomer();
        createSalesOrgCustomSetting();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            ZORG_Same_as_SH__c = TRUE,
            SH_Same_as_SP__c = true,
            Account_Group__c = 'ZORG',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'US60 - RSO U.S.A.',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Company_Code__c = 'Test',
            Label_required__c = 'Yes',
            Label_Code__c = '12345',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            //GSM_Controller_Approver_Group__c = 'GC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'GC - Greater China', //added by Nisha Agrawal on Apr 26 for SFDC-430
            Additional_Shipping_Mark__c = 'Test',
            Additional_VAT_Number_1__c = '12345',
            Additional_VAT_Number_2__c = '12345',
            Additional_VAT_Number_3__c = '12345',
            Additional_VAT_Number_4__c = '12345',
            Additional_VAT_Number_5__c = '12345',
            Additional_VAT_Number_6__c = '12345',
            Additional_VAT_Number_7__c = '12345',
            Additional_VAT_Number_8__c = '12345',
            
            Billing_Block__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            Central_Billing_Block__c = 'Test',
            //Central_deletion_block__c = 'Yes',
            //Central_Deletion_Flag__c = 'Yes',
            Central_delivery_block__c = 'Test',
            Central_order_block__c = 'Test',
            //Central_posting_block__c = 'Yes',
            ZORG_City__c = 'Test',
            City_Chinese__c = 'Test',
            Controlled_Party__c = 'Yes',
            ZORG_Country__c = 'Test',
            Country_Additional_VAT_Number_1__c = '12345',
            Country_Additional_VAT_Number_2__c = '12345',
            Country_Additional_VAT_Number_3__c = '12345',
            Country_Additional_VAT_Number_4__c = '12345',
            Country_Additional_VAT_Number_5__c = '12345',
            Country_Additional_VAT_Number_6__c = '12345',
            Country_Additional_VAT_Number_7__c = '12345',
            Country_Additional_VAT_Number_8__c = '12345',
            CPNJ_for_Brazil__c = '12345',
            Customer_Statistics_Group__c = '12345',
            //Deletion_Block_Company_Code__c = 'Yes',
            //Deletion_Flag_Company_Code__c = 'Yes',
           //Deletion_Flag_Sales_Area__c = 'Yes',
            Delivery_Block__c = '12345',
            Delivery_Group_Ind_SH__c = '12345',
            Delivery_priority__c = '12345',
            Distribution_Channel__c = '12345',
            Distribution_Region__c = '12345',
            Division__c = '12345',
            ZORG_Email__c = 'test@test.com',
            Exch_rate_type__c = '12345',
            Freight_Forwarder__c = '12345',
            FunLoc_Type__c = '12345',
            Grp_2_Cus_Prce_Grp_SP__c = 'Test',
            Incoterms_1_ZORG__c = 'Test',
            Incoterms_2_ZORG__c = 'Test',
            Language__c = 'Test',
            ZORG_Name__c  = 'Test',
            Main_shipping_mark__c  = 'Test',
            Matl_Det_Grp_SP__c = 'Test',
            Max_partial_deliveries__c = '01',
            Military_Usage__c = 'Test',
            Chinese_Name1__c = 'Test',
            ZORG_Name_Line_2__c = 'Test',
            Chinese_Name2__c = 'Test',
            ZORG_Name_Line_3__c = 'Test',
            ZORG_Name_Line_4__c = 'Test',
            Non_I2_related_SP_ZORG__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination_ZORG__c = 'Test',
            Partial_delivery_per_item__c = 'Test',
            Payment_Guarantee_Procedure__c = 'Test',
            //Posting_Block_Company_Code__c = 'Yes',
            Sales_Area_Region__c = 'Test',
            Screened_for_SDI__c = 'Yes',
            Shipping_Condition__c = 'Test',
            ZORG_State__c = 'Test',
            Chinese_Street__c = 'Test',
            ZORG_Street__c = 'Test',
            Taxes_Number_1__c = 'Test',
            ZORG_Telephone__c = 'Test',
            Trading_Partner__c = 'Test',
            Transportation_Zone_ZORG__c = 'Test',
            Unloading_Point__c = 'Test',
            VAT_Registration_Number__c = 'Test',
            ZORG_Postal_Code__c = 'Test',
            Central_deletion_block__c= 'No',
            Central_deletion_Flag__c = 'No',
            Central_posting_block__c = 'No',
            Deletion_Flag_Sales_Area__c = 'No',
            Deletion_Block_Company_Code__c = 'No',
            Deletion_Flag_Company_Code__c = 'No',
            Indicator_Record_Payment_History__c = 'No',
            Posting_Block_Company_Code__c = 'No',
            Version_ID_for_International_Addresses__c = 'M'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'ZORG'; 
        theControllerExt.New_SAP_CMD(); 
        Test.stopTest();
    }
    //ZORG same as Ship-to, SH not same as SP
    //@isTest(seeAllData = TRUE)
    @isTest
    static void theZORGtest3(){
        fetchRecordTypes();
        prepareTestCustomer();
        prepareConsolidatedAccountCode();
        insertFunloc();
        Test.startTest();
        testRequest = new CMD_Request__c(
            ZORG_Same_as_SH__c = TRUE,
            SH_Same_as_SP__c = FALSE,
            Account_Group__c = 'ZORG',
            RecordTypeId = newSAPrtId,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'US60 - RSO U.S.A.',
            Consolidated_Account_Code__c = testCACC.Id,
            SP_CustomerID__c = testCustomer.Id,
            SP_GID__c = '100000000',
            //SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Test Country',
            SP_Postal_Code__c = '12345',
            Region__c = 'EU - Europe',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            //SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SP_Funloc_Id__c = funlocId,
            SH_CustomerID__c = testCustomer.Id,
            SH_GID__c = '100000000',
            //SH_CustomerID__c = 'a1ND0000001vB7GMAU',
            SH_Name__c = 'Test Name',
            SH_Street__c = 'Test Street',
            SH_City__c = 'Test City',
            SH_Country__c = 'Test Country',
            SH_Postal_Code__c = '12345',
            SH_Telephone__c = '+1234567890',
            SH_Fax__c = '+1234567890',
            SH_Email__c = 'test@test.com',
            SH_Funloc__c = '100000',
            //SH_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            SH_Funloc_Id__c = funLocId,
            Company_Code__c = 'Test',
            Label_required__c = 'No',
            Label_Code__c = '12345',
            Industry_Segment__c = 'Test',
            Industry_Sub_Segment__c = 'Test',
            Customer_Factory_Calendar__c = 'Test',
            Customer_Service_ZA__c = 'Test',
            Incoterms_1__c = 'Test',
            Incoterms_2__c = 'Test',
            Lockbox__c = 'Test',
            Payment_Credit_Memo__c= 'Test',
            Pull_Up_OK_SH__c = 'Test',
            Rounding_Rule_SH__c = 'Test',
            Terms_of_Payment__c = 'Test',
            Terms_of_Payment_Sales__c = 'Test',
            Con_Acct_SP_EMS__c = 'Test',
            Cust_pric_proc__c = 'Test',
            Grp_1_Sls_Channel_SP__c = 'Test',
            Currency__c = 'Test Currency',
            PD_Key_Account__c = 'Test PD Key Account',
            Reprice_Basis__c = 'Test Reprice Basis',
            Sales_Office__c = 'Test Sales_Office__c',
            S_O_Sub_Group__c = 'Test S O Sub Group',
            Reconciliation_Account__c = 'Test',
            //GSM_Controller_Approver_Group__c = 'GC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'GC - Greater China', //added by Nisha Agrawal on Apr 26 for SFDC-430
            Additional_Shipping_Mark__c = 'Test',
            Additional_VAT_Number_1__c = '12345',
            Additional_VAT_Number_2__c = '12345',
            Additional_VAT_Number_3__c = '12345',
            Additional_VAT_Number_4__c = '12345',
            Additional_VAT_Number_5__c = '12345',
            Additional_VAT_Number_6__c = '12345',
            Additional_VAT_Number_7__c = '12345',
            Additional_VAT_Number_8__c = '12345',
            Billing_Block__c = 'Test',
            Brazil_Specific_Clause__c = 'Test',
            Central_Billing_Block__c = 'Test',
            Central_deletion_block__c = 'Yes',
            Central_Deletion_Flag__c = 'Yes',
            Central_delivery_block__c = 'Test',
            Central_order_block__c = 'Test',
            Central_posting_block__c = 'Yes',
            ZORG_City__c = 'Test',
            City_Chinese__c = 'Test',
            Controlled_Party__c = 'No',
            ZORG_Country__c = 'Test',
            Country_Additional_VAT_Number_1__c = '12345',
            Country_Additional_VAT_Number_2__c = '12345',
            Country_Additional_VAT_Number_3__c = '12345',
            Country_Additional_VAT_Number_4__c = '12345',
            Country_Additional_VAT_Number_5__c = '12345',
            Country_Additional_VAT_Number_6__c = '12345',
            Country_Additional_VAT_Number_7__c = '12345',
            Country_Additional_VAT_Number_8__c = '12345',
            CPNJ_for_Brazil__c = '12345',
            Customer_Statistics_Group__c = '12345',
            //Deletion_Block_Company_Code__c = 'Yes',
            //Deletion_Flag_Company_Code__c = 'Yes',
            //Deletion_Flag_Sales_Area__c = 'Yes',
            Delivery_Block__c = '12345',
            Delivery_Group_Ind_SH__c = '12345',
            Delivery_priority__c = '12345',
            Distribution_Channel__c = '12345',
            Distribution_Region__c = '12345',
            Division__c = '12345',
            ZORG_Email__c = 'test@test.com',
            Exch_rate_type__c = '12345',
            Freight_Forwarder__c = '12345',
            FunLoc_Type__c = '12345',
            Grp_2_Cus_Prce_Grp_SP__c = 'Test',
            Incoterms_1_ZORG__c = 'Test',
            Incoterms_2_ZORG__c = 'Test',
            Language__c = 'Test',
            ZORG_Name__c  = 'Test',
            Main_shipping_mark__c  = 'Test',
            Matl_Det_Grp_SP__c = 'Test',
            Max_partial_deliveries__c = '01',
            Military_Usage__c = 'Test',
            Chinese_Name1__c = 'Test',
            ZORG_Name_Line_2__c = 'Test',
            Chinese_Name2__c = 'Test',
            ZORG_Name_Line_3__c = 'Test',
            ZORG_Name_Line_4__c = 'Test',
            Non_I2_related_SP_ZORG__c = 'Test',
            Order_Block__c = 'Test',
            Order_Combination_ZORG__c = 'Test',
            Partial_delivery_per_item__c = 'Test',
            Payment_Guarantee_Procedure__c = 'Test',
            //Posting_Block_Company_Code__c = 'Yes',
            Sales_Area_Region__c = 'Test',
            Screened_for_SDI__c = 'No',
            Shipping_Condition__c = 'Test',
            ZORG_State__c = 'Test',
            Chinese_Street__c = 'Test',
            ZORG_Street__c = 'Test',
            Taxes_Number_1__c = 'Test',
            ZORG_Telephone__c = 'Test',
            Trading_Partner__c = 'Test',
          //  Transportation_Zone_ZORG__c = 'Test',
            Unloading_Point__c = 'Test',
            VAT_Registration_Number__c = 'Test',
            ZORG_Postal_Code__c = 'Test',
            Version_ID_for_International_Addresses__c = 'C'
        );
        insert testRequest;

        ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(testRequest);
        CMD_Request_Controller_SAP_Extension theControllerExt 
            = new CMD_Request_Controller_SAP_Extension( theStandardController );
        theControllerExt.theAccountGroup = 'ZORG'; 
        theControllerExt.New_SAP_CMD();
        Test.stopTest();
    }
    /***1604 Release - SIR 706, Added by Scarlett - END***/
}