/******************************************************************************************
@Modified By :    Scarlett Kang
@Modified Date :   26 Sep 2014
@Description :     Updated test methods to fix it due to new mandatory field - Postal Code
*******************************************************************************************/

@isTest
private class CustomerTrigger_SAP_CMD_Request_Test{

    private static RecordType newSAP_RecordType;
    private static CMD_Request__c testRequest;
    private static Customer__c testCustomer;

    private static void fetchNewSAPRecordType(){
        for(RecordType rt : [   
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SobjectType = 'CMD_Request__c' 
            AND DeveloperName LIKE '%SAP%' 
            AND IsActive=true
            LIMIT 1
        ]){
            newSAP_RecordType = rt;
        }    
    }

    private static void insertTestRequest(){
        testRequest = new CMD_Request__c(
            RecordTypeId = newSAP_RecordType.Id,
//          SP_GID__c = '100000000',
//            SP_CustomerID__c = 'a1ND0000001vB7GMAU',
            SP_Name__c = 'Test Name',
            SP_Street__c = 'Test Street',
            SP_City__c = 'Test City',
            SP_Country__c = 'Netherlands',
            SP_Telephone__c = '+1234567890',
            SP_Fax__c = '+1234567890',
            SP_Email__c = 'test@test.com',
            SP_Funloc__c = '100000',
            SP_Funloc_Id__c = 'a1UD0000000QhEjMAK',
            Business_Background_Comments__c = 'Test Business Background Comments',
            Global_Account__c = 'Test Global Account',
            Sales_Organisation__c = 'Test Sales Organisation',
            Company_Code__c = 'Test',
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
            Postal_Code__c = '100000'
        );
        insert testRequest;
    }
    
    private static void insertTestCustomer(){
        testCustomer = new Customer__c(
            CMD_Request_Id__c = testRequest.Id,
            CMD_Request_Partner_Function__c = 'SP',
            DNB_Verified__c = 'DNB Accepted',
            Legal_Name__c = 'Test Legal Name',
            Account_Name__c = 'Test Account Name',
            Street__c = 'TEST STREET',
            City__c = 'TEST CITY',
            Country__c = 'Netherlands',
            Zip__c = 'Test',
            Industry_Segment__c = 'AA - Appliances',
            Industry_Sub_Segment__c = 'A1 - Major Home Appliances',
            Role__c = 'Focused'
        );
        insert testCustomer;
    }

    @isTest(SeeAllData=true)
    static void thePositiveUnitTest(){
        fetchNewSAPRecordType();
        insertTestRequest();
        insertTestCustomer();
        System.assert( testCustomer.Name == testRequest.SP_GID__c );
    }
}