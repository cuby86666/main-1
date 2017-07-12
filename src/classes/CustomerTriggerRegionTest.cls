@isTest
public class CustomerTriggerRegionTest
{
    private static RecordType globalCustomerRT;
    private static RecordType locationCustomerRT;
    private static Hub_Foundation__c testHubFoundation;
    private static Hub_Foundation__c testHubFoundation2;

    public static testMethod void TestInsertParentChild() 
    {
        fetchRecordTypes();
        makeTestHubFoundations();
        
        Map<string,Customer__c> locationNamesMap = new Map<string,Customer__c>();

        Customer__c theGlobal = new Customer__c
        (
            RecordTypeId = globalCustomerRT.Id ,
            Type__c = 'Customer' ,
            Sales__c = true ,
            Account_Name__c = 'Test Global Parent' ,
            Legal_Name__c = 'Test Global Parent' ,
            DUNS__c = 'TestP' ,
            Industry_Segment__c = 'Test Industry Segment' ,
            Industry_Sub_Segment__c = 'Test Sub Segment' ,
            GSM_Classification__c = 'Test Classification' ,
            Role__c = 'Test Role' ,
            Fulfillment_Channel__c = 'Test Channel ' ,
            House_Number__c = 'Test' ,
            Street__c = 'Test Street' ,
            City__c = 'Test City' ,
            State__c = 'Test State' ,
            Country__c = 'Test Country' ,
            Zip__c = 'Test Zip'  ,
            DNB_Verified__c = 'true' 
        );
        insert theGlobal;

        Customer__c testGlobal = 
        [
            SELECT Id, Country__c, Region__c 
            FROM Customer__c
            WHERE Id = :theGlobal.Id
        ];
        System.assertEquals( testGlobal.Country__c , 'Test Country' ) ;
        System.assertEquals( testGlobal.Region__c , 'Test Region' ) ;

        Customer__c theLocation = new Customer__c
        (
            RecordTypeId = locationCustomerRT.Id ,
            Global_Enterprise__c = theGlobal.Id ,
            Type__c = 'Customer' ,
            Sales__c = true ,
            Account_Name__c = 'Test Location Child' ,
            Legal_Name__c = 'Test Location Child'  ,
            DUNS__c = 'TestC'  ,
            Industry_Segment__c = 'Test Industry Segment '  ,
            Industry_Sub_Segment__c = 'Test Sub Segment '  ,
            GSM_Classification__c = 'Test Classification '  ,
            Role__c = 'Test Role '  ,
            Fulfillment_Channel__c = 'Test Channel ' ,
            House_Number__c = 'Test' ,
            Street__c = 'Test Street '  ,
            City__c = 'Test City '  ,
            State__c = 'Test State '  ,
            Country__c = 'Test Country 2' ,
            Zip__c = 'Test'  ,
            DNB_Verified__c = 'true' 
        );
        insert theLocation;
        
        Customer__c testLocation = 
        [
            SELECT Id, Country__c, Region__c 
            FROM Customer__c
            WHERE Id = :theLocation.Id
        ];
        System.assertEquals( testLocation.Country__c , 'Test Country 2' ) ; 
        System.assertEquals( testLocation.Region__c , 'Test Region 2' ) ;                        
    }    
   
    private static void makeTestHubFoundations()
    {
        testHubFoundation = new Hub_Foundation__c 
        (
            Country__c = 'Test Country' ,
            Region__c = 'Test Region' ,
            Alpha_2_Code__c = 'TT' ,
            Alpha_3_Code__c = 'TTT'
        );
        insert testHubFoundation ;
        
        testHubFoundation2 = new Hub_Foundation__c 
        (
            Country__c = 'Test Country 2' ,
            Region__c = 'Test Region 2' ,
            Alpha_2_Code__c = 'T2' ,
            Alpha_3_Code__c = 'TT2'
        );
        insert testHubFoundation2 ;
    }

    @isTest(SeeAllData=true)
    private static void fetchRecordTypes()
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
                globalCustomerRT = RT;
            }
            else if( RT.DeveloperName == 'Location' )
            {
                locationCustomerRT = RT;
            }
        }    
    }
}