/**********************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      17 Jun 2013
@Description:       Test Class for Controller class SearchCustomerController

@Continued By : Stan Hsu
**************************************************************************************/
@isTest
private class SearchCustomerControllerTest 
{
    private static RecordType globalCustomer;
    private static RecordType locationCustomer;

    static testMethod void NoSearchResultTest() 
    {
        findRecordTypes();
        
        Customer__c theGlobal = new Customer__c
        (
            RecordTypeId = globalCustomer.Id ,
            Account_Name__c = 'Test Global Parent' ,
            Legal_Name__c = 'Test Global Parent' ,
            DUNS__c = 'Test' ,
            Industry_Segment__c = 'Test Industry Segment' ,
            Industry_Sub_Segment__c = 'Test Sub Segment' ,
            GSM_Classification__c = 'Test Classification' ,
            Role__c = 'Test Role' ,
            Region__c = 'Test Region' ,
            House_Number__c = 'Test' ,
            Street__c = 'Test Street' ,
            City__c = 'Test City' ,
            Country__c = 'Test Country' ,
            Zip__c = 'Test Zip' ,
            DNB_Verified__c = 'true'
        );
        insert theGlobal;

        List<Customer__c> locationCustomers = new List<Customer__c>();
        
        integer i=0;        
        for(i=0; i < 10; i++)
        {          
            Customer__c theLocation = new Customer__c
            (
                Global_Enterprise__c = theGlobal.Id ,
                RecordTypeId = locationCustomer.Id ,
                Sales__c = true ,
                Account_Name__c = 'Test Location Child ' + String.valueOf(i) ,
                Legal_Name__c = 'Test Location Child ' + String.valueOf(i) ,
                DUNS__c = 'Test' + String.valueOf(i) ,
                Industry_Segment__c = 'Test Industry Segment ' + String.valueOf(i) ,
                Industry_Sub_Segment__c = 'Test Sub Segment ' + String.valueOf(i) ,
                GSM_Classification__c = 'Test Classification ' + String.valueOf(i) ,
                Role__c = 'Test Role ' + String.valueOf(i) ,
                Region__c = 'Test Region ' + String.valueOf(i) ,
                House_Number__c = String.valueOf(i) ,
                Street__c = 'Test Street ' + String.valueOf(i) ,
                City__c = 'Test City ' + String.valueOf(i) ,
                Country__c = 'Test Country ' + String.valueOf(i) ,
                Postal_Code__c = 'Test' + String.valueOf(i) , 
                Zip__c = 'Test' + String.valueOf(i) ,
                DNB_Verified__c = 'true'
            );
            locationCustomers.add( theLocation );
        }
        insert locationCustomers;
        
        ApexPages.StandardSetController setController = new Apexpages.StandardSetController(new List<Customer__c>());
        SearchCustomerController controller = new SearchCustomerController(setController);
        controller.clearResults();
        
        Test.startTest();
            controller.filterCustomer.Legal_Name__c = 'Test' ;
            controller.searchCustomers();
            System.assert(controller.lstCustomerType != null);
            System.assert(controller.lstCustomerType.size() > 0);               
            controller.clearResults();

            controller.filterCustomer.DUNS__c = 'Test' ;
            controller.searchCustomers();
            System.assert(controller.lstCustomerType != null);
            System.assert(controller.lstCustomerType.size() > 0);               
            controller.clearResults();

            controller.filterCustomer.RecordTypeId = globalCustomer.Id ;
            controller.searchCustomers();
            System.assert(controller.lstCustomerType != null);
            System.assert(controller.lstCustomerType.size() > 0);               
            controller.clearResults();

            controller.filterCustomer.Country__c = 'Test' ;
            controller.searchCustomers();
            System.assert(controller.lstCustomerType != null);
            System.assert(controller.lstCustomerType.size() > 0);               
            controller.clearResults();

            controller.filterCustomer.Postal_Code__c = 'Test' ;
            controller.searchCustomers();
            System.assert(controller.lstCustomerType != null);
            System.assert(controller.lstCustomerType.size() > 0);               
            controller.clearResults();

            controller.filterCustomer.City__c = 'Test' ;
            controller.searchCustomers();
            System.assert(controller.lstCustomerType != null);
            System.assert(controller.lstCustomerType.size() > 0);               
            controller.clearResults();

            controller.filterCustomer.Street__c = 'Test' ;
            controller.searchCustomers();
            System.assert(controller.lstCustomerType != null);
            System.assert(controller.lstCustomerType.size() > 0);               
            controller.clearResults();
        Test.stopTest();        

    }   

    private static void findRecordTypes()
    {
        for( RecordType RT : 
            [
                SELECT  Id, DeveloperName
                FROM    RecordType
                WHERE   SobjectType = 'Customer__c' 
                AND (   DeveloperName = 'Global_Enterprise'
                    OR DeveloperName = 'Location' ) 
                AND IsActive = true
             ] )
        {
            if( RT.DeveloperName == 'Global_Enterprise' )
            {
                globalCustomer = RT;
            }
            else if( RT.DeveloperName == 'Location' )
            {
                locationCustomer = RT;
            }
        }    
    }
}