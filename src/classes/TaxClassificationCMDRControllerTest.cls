/**************************************************************************************
@Modified By :       Jewelslyn
@Modified Date:      6 Nov 2015
@Description:        Added test method for sales org code HK91 (Julie CMD)
-------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      01 June 2016
@Description:        1606 Release SIR 915 - [COM] Revise Funloc CMD approval flow 
                     and add new Tax Classification for new Sales Orgs/CSC Site
****************************************************************************************
@Modified By :       Baji
@Modified Date:      24 Mar 2017
@Description:        *1704 Release (SFDC 327) - Remove Nexperia sales org. ( MY61, PH62, CN61 & HK91) from SAP CMD Request picklist
                     *To fix test class error : GSM Controller Approver Group is madatory 
---------------------------------------------------------------------------------
@Modified By :       Nisha Agrawal
@Modified Date:      Apr 26, 2017 
@Description:        SFDC-430 - Replace GSM COntroller Approver Group picklist to new multiselect picklist Controller Approver Group
-------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      27 Jun 2017
@Description:        1707 Release (SFDC 455) - Generate Tax Classifications for Sales Org. CN60
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
@Modified By :       Baji
@Modified Date:      01 Aug 2017 
@Description:        1708 Release (SFDC 729) - Generate Tax Classifications for MANU/SBE sales orgs.
****************************************************************************************/


@isTest
public class TaxClassificationCMDRControllerTest {
    private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
    private static final String TYPE_SAP_New_Funloc_Request = 'SAP_New_Funloc_Request';
    private static final String TYPE_SAP_New_MANU_Funloc_Request = 'SAP_New_MANU_Funloc_request';
    
    
    private static RecordType SAP_New_Funloc_Request;
    private static RecordType SAP_New_MANU_Funloc_Request;
    private static RecordType globalCustomer;
    
    private static Consolidated_Account_Code__c testCACC;
    private static Customer__c objCustomer;
    
    private static void fetchRecordTypes()
    {
        //get SAP CMD record type
        for(RecordType rt : [SELECT Id, DeveloperName
                             FROM   RecordType
                             WHERE  IsActive = TRUE AND  
                              ((SobjectType = 'CMD_Request__c' AND DeveloperName =: TYPE_SAP_New_Funloc_Request)
                              OR (SobjectType = 'CMD_Request__c' AND DeveloperName =: TYPE_SAP_New_MANU_Funloc_Request)
                              OR (SobjectType = 'Customer__c' AND DeveloperName =: TYPE_GLOBALENTERPRISE))
                              ])
        {
            if(rt.DeveloperName == TYPE_SAP_New_Funloc_Request)
                SAP_New_Funloc_Request = rt;
            if(rt.DeveloperName == TYPE_SAP_New_MANU_Funloc_Request)
                SAP_New_MANU_Funloc_Request = rt;
            if(rt.DeveloperName == TYPE_GLOBALENTERPRISE)
                globalCustomer = rt;
        }
    }   
    
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
    
    static testMethod void CMDRequestSALES_ORG_NL60(){
        //create data
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        //create CDM Request - SAP New Funloc Request
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'NL60 - RSO Europe',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',
            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
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
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
        );
        insert objCMDRequest;
        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();
    }
    
    static testMethod void CMDRequestSALES_ORG_US60(){
        //create data
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        //create CDM Request - SAP New Funloc Request
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'US60 - RSO U.S.A.',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',
            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
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
            S_O_Sub_Group__c = 'Test S O Sub Group' ,
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430 
        );
        insert objCMDRequest;
        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();
    }
    
    static testMethod void CMDRequestSALES_ORG_CN62(){
        //create data
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        //create CDM Request - SAP New Funloc Request
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN62 - MSO China',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',
            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
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
            S_O_Sub_Group__c = 'Test S O Sub Group' ,
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
        );
        insert objCMDRequest;
        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();
    }
    
    static testMethod void CMDRequestSALES_ORG_CN60(){
        //create data
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        //create CDM Request - SAP New Funloc Request
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN60 - MSO China CN60',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',
            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
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
            S_O_Sub_Group__c = 'Test S O Sub Group' ,
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
        );
        insert objCMDRequest;
        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();
    }
    
    
   //Test method is added to include the sales org HK-91 for Julie CMD 
  /*  static testMethod void CMDRequestSALES_ORG_HK_91()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'HK91 - WeEn Semiconductor',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            GSM_Controller_Approver_Group__c = 'AMEC'
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    } */
    static testMethod void CMDRequestSALES_ORG_JP_60()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'JP60 - MSO Japan',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }
    static testMethod void CMDRequestSALES_ORG_US_63()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'US63 - NXP San Jose',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            //GSM_Controller_Approver_Group__c = 'AMEC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'NA - Americas' //added by Nisha Agrawal on Apr 26 for SFDC-430
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }
  /*  static testMethod void CMDRequestSALES_ORG_CN_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN61 - MSO China',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group');
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    } */
    
    static testMethod void CMDRequestSALES_ORG_CN_64()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN64 - Tianjin',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            //GSM_Controller_Approver_Group__c = 'EMEA'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'EU - EMEA' //added by Nisha Agrawal on Apr 26 for SFDC-430
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }
  /*  static testMethod void CMDRequestSALES_ORG_MY_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'MY61 - NXP Seremban',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group');
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }
    
    static testMethod void CMDRequestSALES_ORG_PH_62()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'PH62 - NXP Cabuyao',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group');
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }*/
    static testMethod void CMDRequestSALES_ORG_TH_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'TH61 - NXP Thailand',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            //GSM_Controller_Approver_Group__c = 'SAP'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'AP - South Asia-Pacific' //added by Nisha Agrawal on Apr 26 for SFDC-430
        );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }   
    static testMethod void CMDRequestSALES_ORG_TW_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'TW61 - NXP Kaohsiung',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            //GSM_Controller_Approver_Group__c = 'GC'  //commented by Nisha Agrawal on Apr 26 for SFDC-430
            Controller_Approver_Group__c = 'GC - Greater China' //added by Nisha Agrawal on Apr 26 for SFDC-430
            );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
         PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_AT_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'AT61 - SOrg. GRK',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
    static testMethod void CMDRequestSALES_ORG_BE_61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'BE61 - NXP Semicon. Leuven',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_CN68()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'CN68 - NXP(China)Management',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_DE42()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'DE42 - NXP Hamburg Other',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_DE63()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'DE63 - NXP Semi. Germany',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_EM61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'EM61 - NXP GEM',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_FR61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'FR61 - NXP Caen',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_IN61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'IN61 - NXP India',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_MX61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'MX61 - SOrg. Mexico',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_NL40()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'NL40 - NXP Nijmegen Site Su',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_NL61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'NL61 - Nijmegen',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_NL68()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'NL68 - NXP Software',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
     static testMethod void CMDRequestSALES_ORG_RO61()
    {
        fetchRecordTypes();
        prepareConsolidatedAccountCode();
        createCustomer();
        
        CMD_Request__c objCMDRequest = new CMD_Request__c(
            Sales_Organisation__c = 'RO61 - SOrg. Romania',
            Reason_for_request__c = 'Test',
            Account_Group__c = 'Z001',
            RecordTypeId = SAP_New_MANU_Funloc_Request.Id,
            Consolidated_Account_Code__c = testCACC.Id,
            Ready_to_Submit__c = true,
            Request_Status__c = 'Ready to Submit',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            SP_GID__c = '100000000',            
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
            S_O_Sub_Group__c = 'Test S O Sub Group'
           );
            
        insert objCMDRequest;        
        system.assert(objCMDRequest.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.TaxClassification;
        pgRef.getParameters().put('Id',objCMDRequest.Id);
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController stdController = new Apexpages.StandardSetController(new List<Tax_Classification__c>());
        TaxClassificationCMDRequestController controller = new TaxClassificationCMDRequestController(stdController);
        
        System.assert(controller.lstTaxClassifications != null);
        System.assert(controller.lstTaxClassifications.size() > 0);
        
        //invoke saveTaxClassificationCMDRequest method
        pgRef = controller.saveTaxClassification();
        System.assert(pgRef != null);
        System.assertEquals(pgRef.getUrl(), '/' + controller.objCMDRequest.Id);
        
        //stop the test
        Test.stopTest();   
    
    }  
}