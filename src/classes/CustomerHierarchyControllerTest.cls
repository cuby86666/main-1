/**********************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      17 Jun 2013
@Description:       Test Class for Controller class CustomerHierarchyController
***********************************************************************************************/

@isTest
private class CustomerHierarchyControllerTest 
{
	private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
	private static final String TYPE_LOCATION = 'Location';
	private static final String TYPE_DIVISION = 'Division';

	private static Map<String, RecordType> mapTypeNameToRecordTypes = new Map<String, RecordType>();
	
	private static void fetchCustomerRecordTypes()
    {
    	//get the record type
	    for(RecordType rt : [Select Id, DeveloperName From RecordType Where SobjectType = 'Customer__c' and IsActive=true ])
	    {
	        mapTypeNameToRecordTypes.put(rt.DeveloperName , rt);
	    }	
    }
			
	//Case - Customer Type = Location and GE -> Division -> Location 
    static testMethod void CustomerHierarchyControllerTest1() 
    {
		//prepare test data
        fetchCustomerRecordTypes();
        
        //create test customers
        
        Customer__c geCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_GLOBALENTERPRISE).Id, 
        											Legal_Name__c = 'ut_global_enterprise' , Account_Name__c = 'ut_global_enterprise', 
        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_ge_city',
        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive', 
        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM', 
        											GSM_Classification__c = 'Longtail');
        insert geCustomer;        
        system.assert(geCustomer.Id != null);        											
        
        
        Customer__c divisionCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_DIVISION).Id, 
        												Global_Enterprise__c = geCustomer.Id ,
	        											Legal_Name__c = 'ut_division' , Account_Name__c = 'ut_division', 
	        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_div_city',
	        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
	        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM');
        insert divisionCustomer;        
        system.assert(divisionCustomer.Id != null);        										
        
        Customer__c loctaionCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_LOCATION).Id, 
        												Global_Enterprise__c = geCustomer.Id , Parent_Division__c = divisionCustomer.Id ,  
	        											Legal_Name__c = 'ut_location' , Account_Name__c = 'ut_Account_Name', 
	        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_loc_city',
	        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
	        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM');
		insert loctaionCustomer;        
        system.assert(loctaionCustomer.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.CustomerHierarchy;
        pgRef.getParameters().put('Id', loctaionCustomer.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardController stdController = new Apexpages.StandardController(loctaionCustomer);
        CustomerHierarchyController controller  = new CustomerHierarchyController(stdController);
        
        String strExpectedHierarchy = '{"data":[{"state":"open","data":"ut_global_enterprise - ut_ge_city","children":[{"state":"open","data":"ut_division - ut_div_city","children":[{"state":"open","data":"ut_location - ut_loc_city","children":[]}]}]}]}';
        String strActualHierarchy = controller.strHierarchyJson;
        
        //assert the result
        system.assert(!String.isEmpty(strActualHierarchy));
        system.assert(strActualHierarchy.trim() == strExpectedHierarchy.trim());
                
        //stop the test
        Test.stopTest();
    }     
    
    
    //Case - Customer Type = Location and GE -> Location
    static testMethod void CustomerHierarchyControllerTest2() 
    {
        //prepare test data
        fetchCustomerRecordTypes();
        
        //create test customers
        
        Customer__c geCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_GLOBALENTERPRISE).Id, 
        											Legal_Name__c = 'ut_global_enterprise' , Account_Name__c = 'ut_global_enterprise', 
        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_ge_city',
        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM',
        											GSM_Classification__c = 'Longtail');
        insert geCustomer;        
        system.assert(geCustomer.Id != null);        											
        
        Customer__c loctaionCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_LOCATION).Id, 
    												Global_Enterprise__c = geCustomer.Id ,  
        											Legal_Name__c = 'ut_location' , Account_Name__c = 'ut_Account_Name', 
        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_loc_city',
        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM');
		insert loctaionCustomer;        
        system.assert(loctaionCustomer.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.CustomerHierarchy;
        pgRef.getParameters().put('Id', loctaionCustomer.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardController stdController = new Apexpages.StandardController(loctaionCustomer);
        CustomerHierarchyController controller  = new CustomerHierarchyController(stdController);
        
        String strExpectedHierarchy = ' {"data":[{"state":"open","data":"ut_global_enterprise - ut_ge_city","children":[{"state":"open","data":"ut_location - ut_loc_city","children":[]}]}]}';
        String strActualHierarchy = controller.strHierarchyJson;
        
        //assert the result
        system.assert(!String.isEmpty(strActualHierarchy));
        system.assert(strActualHierarchy.trim() == strExpectedHierarchy.trim());
                
        //stop the test
        Test.stopTest();
    }
    
    //Case - Customer Type = Location and Division -> Location
    static testMethod void CustomerHierarchyControllerTest3() 
    {
        //prepare test data
        fetchCustomerRecordTypes();
        
        //create test customers
        
        Customer__c divisionCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_DIVISION).Id, 
	        											Legal_Name__c = 'ut_division' , Account_Name__c = 'ut_division', 
	        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_div_city',
	        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
	        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM');
        insert divisionCustomer;        
        system.assert(divisionCustomer.Id != null);        											
        
        Customer__c loctaionCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_LOCATION).Id, 
        												Parent_Division__c = divisionCustomer.Id ,  
	        											Legal_Name__c = 'ut_location' , Account_Name__c = 'ut_Account_Name', 
	        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_loc_city',
	        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
	        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM');
		insert loctaionCustomer;        
        system.assert(loctaionCustomer.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.CustomerHierarchy;
        pgRef.getParameters().put('Id', loctaionCustomer.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardController stdController = new Apexpages.StandardController(loctaionCustomer);
        CustomerHierarchyController controller  = new CustomerHierarchyController(stdController);
        
        String strExpectedHierarchy = ' {"data":[{"state":"open","data":"ut_division - ut_div_city","children":[{"state":"open","data":"ut_location - ut_loc_city","children":[]}]}]}';
        String strActualHierarchy = controller.strHierarchyJson;
        
        //assert the result
        system.assert(!String.isEmpty(strActualHierarchy));
        system.assert(strActualHierarchy.trim() == strExpectedHierarchy.trim());
                
        //stop the test
        Test.stopTest();
    }
        
    //Case - Customer Type = Location and Location(No hierarchy)
    static testMethod void CustomerHierarchyControllerTest4() 
    {
        //prepare test data
        fetchCustomerRecordTypes();
        //create test customer
        Customer__c objCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_LOCATION).Id, 
        											Legal_Name__c = 'ut_location' , Account_Name__c = 'ut_Account_Name', 
        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_city',
        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM');
		insert objCustomer;
        
        system.assert(objCustomer.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.CustomerHierarchy;
        pgRef.getParameters().put('Id', objCustomer.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardController stdController = new Apexpages.StandardController(objCustomer);
        CustomerHierarchyController controller  = new CustomerHierarchyController(stdController);
        
        String strExpectedHierarchy = '{"data":[{"state":"open","data":"ut_location - ut_city","children":[]}]}';
        String strActualHierarchy = controller.strHierarchyJson;
        
        //assert the result
        system.assert(!String.isEmpty(strActualHierarchy));
        system.assert(strActualHierarchy.trim() == strExpectedHierarchy.trim());
                
        //stop the test
        Test.stopTest();
    }
    
    
    //Case - Customer Type = Location and GE -> Division -> Sub Division -> Location 
    static testMethod void CustomerHierarchyControllerTest5() 
    {
        //prepare test data
        fetchCustomerRecordTypes();
        
        //create test customers
        
        Customer__c geCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_GLOBALENTERPRISE).Id, 
        											Legal_Name__c = 'ut_global_enterprise' , Account_Name__c = 'ut_global_enterprise', 
        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_ge_city',
        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM', 
        											GSM_Classification__c = 'Longtail');
        insert geCustomer;        
        system.assert(geCustomer.Id != null);        											
        
        Customer__c divisionCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_DIVISION).Id, 
        												Global_Enterprise__c = geCustomer.Id ,
	        											Legal_Name__c = 'ut_division' , Account_Name__c = 'ut_division', 
	        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_div_city',
	        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
	        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM');
        insert divisionCustomer;        
        system.assert(divisionCustomer.Id != null);        											
        
        Customer__c subDivisionCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_DIVISION).Id, 
        												Global_Enterprise__c = geCustomer.Id ,Parent_Division__c = divisionCustomer.Id ,
	        											Legal_Name__c = 'ut_sub_division' , Account_Name__c = 'ut_sub_division', 
	        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_sub_div_city',
	        											Country__c = 'India', Zip__c = '12345', Industry_Segment__c = 'Automotive',
	        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM');
        insert subDivisionCustomer;        
        system.assert(subDivisionCustomer.Id != null); 
        
        Customer__c loctaionCustomer = new Customer__c(RecordTypeId = mapTypeNameToRecordTypes.get(TYPE_LOCATION).Id, 
        												Global_Enterprise__c = geCustomer.Id , Parent_Division__c = subDivisionCustomer.Id ,  
	        											Legal_Name__c = 'ut_location' , Account_Name__c = 'ut_Account_Name', 
	        											House_Number__c = 'ut_hn' , Street__c ='ut_street' , City__c = 'ut_loc_city',
	        											Country__c = 'India', Zip__c = '12345' ,
	        											Industry_Segment__c = 'Automotive',
	        											DNB_Verified__c = 'DNB Rejected : Not found', Role__c = 'OEM');
		insert loctaionCustomer;        
        system.assert(loctaionCustomer.Id != null);
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.CustomerHierarchy;
        pgRef.getParameters().put('Id', loctaionCustomer.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardController stdController = new Apexpages.StandardController(loctaionCustomer);
        CustomerHierarchyController controller  = new CustomerHierarchyController(stdController);
        
        String strExpectedHierarchy = ' {"data":[{"state":"open","data":"ut_global_enterprise - ut_ge_city","children":[{"state":"open","data":"ut_division - ut_div_city","children":[{"state":"open","data":"ut_sub_division - ut_sub_div_city","children":[{"state":"open","data":"ut_location - ut_loc_city","children":[]}]}]}]}]}';
        String strActualHierarchy = controller.strHierarchyJson;
        
        //assert the result
        system.assert(!String.isEmpty(strActualHierarchy));
        system.assert(strActualHierarchy.trim() == strExpectedHierarchy.trim());
                
        //stop the test
        Test.stopTest();
    }
       
}