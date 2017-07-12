@isTest(SeeAllData=true) 
private class PreAccountController_Test 
{
    private static final string PRE_ACCOUNT = 'PreAccount';
    private static final string PARENT_ACCOUNT = 'Parent_Account';
    private static final string CHILD_ACCOUNT = 'Child Account';

    private static RecordType preAccountRecordType;
    private static RecordType parentAccountRecordType;
    private static RecordType childAccountRecordType;

	private static void fetchPreAccountRecordType()
	{
	    for( RecordType rt : [	SELECT Id, DeveloperName
								FROM RecordType
	                           	WHERE SobjectType = 'Account' 
	                           	AND DeveloperName = :PRE_ACCOUNT 
	                           	AND IsActive = TRUE
	                           	LIMIT 1
	                        ])
	    {
	        preAccountRecordType = rt;
	    }		
	}

	private static void fetchParentAccountRecordType()
	{
	    for( RecordType rt : [	SELECT Id, DeveloperName
								FROM RecordType
	                           	WHERE SobjectType = 'Account' 
	                           	AND DeveloperName = :PARENT_ACCOUNT 
	                           	AND IsActive = TRUE
	                           	LIMIT 1
	                        ])
	    {
	        parentAccountRecordType = rt;
	    }		
	}

	private static void fetchChildAccountRecordType()
	{
	    for( RecordType rt : [	SELECT Id, DeveloperName
								FROM RecordType
	                           	WHERE SobjectType = 'Account' 
	                           	AND DeveloperName = :CHILD_ACCOUNT 
	                           	AND IsActive = TRUE
	                           	LIMIT 1
	                        ])
	    {
	        childAccountRecordType = rt;
	    }		
	}

    User testUser = new User(	FirstName = 'Test' ,
            					LastName = 'User' ,
            					Username = 'test@test.com' ,
            					Email = 'test@test.com'
        					);

    static testMethod void preAccountToParentTest()
    {
    	fetchPreAccountRecordType();
    	fetchParentAccountRecordType();
    	
        Account testAccount = new Account(	RecordTypeId = preAccountRecordType.Id ,
            								NXP_GID__c = '88888888' ,
     										Name = 'TEST ACCOUNT' ,
     										Legal_Name__c = 'TEST LEGAL NAME' ,
            								DUNS_Number__c = '1234567890' ,
            								House_Number__c = 'HOUSE123' ,
            								Street__c = 'TEST STREET 1',
            								Street2__c = 'TEST STREET 2',
            								Street3__c = 'TEST STREET 3',
            								City__c = 'TEST CITY' ,
            								State_Province__c = 'TEST STATE',
            								ZIP_Postal_Code__c = 'ZIP',
            								Country__c = 'Taiwan',
								            Website = 'www.web.com',
            								Email__c = 'email@email.com',
            								Phone = '+1234567890',
            								Fax = '+1234567890',
            								Region__c = 'Greater China',
            								Fulfillment_Channel__c = 'Direct' ,
            								Customer_Category__c = 'Focused' ,
            								Role__c = 'OEM' ,
            								Type = 'Customer' ,
            								Industry_Segment__c = 'Appliances',
            								Sub_Segment__c = 'Major Home Appliances',
            								SIC_Code__c = '1234 - SIC TEST',
            								NAICS_Code__c = '123 - NAICS TEST'         		
        								);
        insert testAccount;
        
        preAccountController testController = new preAccountController( testAccount ); 
        testController.makeParentAccount();
    }

    static testMethod void preAccountToChildTest()
    {
    	fetchPreAccountRecordType();
    	fetchParentAccountRecordType();
    	
        Account testAccount = new Account(	RecordTypeId = preAccountRecordType.Id ,
            								NXP_GID__c = '88888888' ,
     										Name = 'TEST ACCOUNT' ,
     										Legal_Name__c = 'TEST LEGAL NAME' ,
            								DUNS_Number__c = '1234567890' ,
            								House_Number__c = 'HOUSE123' ,
            								Street__c = 'TEST STREET 1',
            								Street2__c = 'TEST STREET 2',
            								Street3__c = 'TEST STREET 3',
            								City__c = 'TEST CITY' ,
            								State_Province__c = 'TEST STATE',
            								ZIP_Postal_Code__c = 'ZIP',
            								Country__c = 'Taiwan',
								            Website = 'www.web.com',
            								Email__c = 'email@email.com',
            								Phone = '+1234567890',
            								Fax = '+1234567890',
            								Region__c = 'Greater China',
            								Fulfillment_Channel__c = 'Direct' ,
            								Customer_Category__c = 'Focused' ,
            								Role__c = 'OEM' ,
            								Type = 'Customer' ,
            								Industry_Segment__c = 'Appliances',
            								Sub_Segment__c = 'Major Home Appliances',
            								SIC_Code__c = '1234 - SIC TEST',
            								NAICS_Code__c = '123 - NAICS TEST'         		
        								);
        insert testAccount;
        
        preAccountController testController = new preAccountController( testAccount ); 
        testController.makeChildAccount();
    }

    static testMethod void preAccountToComboTest()
    {
    	fetchPreAccountRecordType();
    	fetchParentAccountRecordType();
    	
        Account testAccount = new Account(	RecordTypeId = preAccountRecordType.Id ,
            								NXP_GID__c = '88888888' ,
     										Name = 'TEST ACCOUNT' ,
     										Legal_Name__c = 'TEST LEGAL NAME' ,
            								DUNS_Number__c = '1234567890' ,
            								House_Number__c = 'HOUSE123' ,
            								Street__c = 'TEST STREET 1',
            								Street2__c = 'TEST STREET 2',
            								Street3__c = 'TEST STREET 3',
            								City__c = 'TEST CITY' ,
            								State_Province__c = 'TEST STATE',
            								ZIP_Postal_Code__c = 'ZIP',
            								Country__c = 'Taiwan',
								            Website = 'www.web.com',
            								Email__c = 'email@email.com',
            								Phone = '+1234567890',
            								Fax = '+1234567890',
            								Region__c = 'Greater China',
            								Fulfillment_Channel__c = 'Direct' ,
            								Customer_Category__c = 'Focused' ,
            								Role__c = 'OEM' ,
            								Type = 'Customer' ,
            								Industry_Segment__c = 'Appliances',
            								Sub_Segment__c = 'Major Home Appliances',
            								SIC_Code__c = '1234 - SIC TEST',
            								NAICS_Code__c = '123 - NAICS TEST'         		
        								);
        insert testAccount;
        
        preAccountController testController = new preAccountController( testAccount ); 
        testController.makeAccountCombo();
    }
}