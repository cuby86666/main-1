/*************************************************************************
@Modified By: 		Nisha Agrawal
@Modified Date: 	18 Aug 2017
@Description:		Modified class to optimize the code, improve the code coverage 
					and remove seealldata =true
**************************************************************************/
@isTest
private class PreAccountController_Test 
{
    private static final string PRE_ACCOUNT = 'PreAccount';
    private static final string PARENT_ACCOUNT = 'Parent_Account';
    private static final string CHILD_ACCOUNT = 'Child Account';

    private static Id preAccountRecordTypeId;
    private static Id parentAccountRecordTypeId;
    private static Id childAccountRecordTypeId;

    //code block commented by Nisha Agrawal on Aug 18, 2017 to optimize the code, use helper class methods
    /*
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
*/
    User testUser = new User(	FirstName = 'Test' ,
            					LastName = 'User' ,
            					Username = 'test@test.com' ,
            					Email = 'test@test.com'
        					);

    static testMethod void preAccountToParentTest()
    {
    	//fetchPreAccountRecordType(); //commented by Nisha Agrawal to improve coverage
    	//fetchParentAccountRecordType(); //commented by Nisha Agrawal to improve coverage
    	
        // code block added by Nisha Agrawal to improve coverage
    	preAccountRecordTypeId = AccountHelper.getPreAccountRecordTypeID();
    	parentAccountRecordTypeId = AccountHelper.getParentRecordTypeID();
        
        Account testAccount = new Account(	RecordTypeId = preAccountRecordTypeId ,
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
        
        /* code commented by Nisha Agrawal to improve the coverage 
         //preAccountController testController = new preAccountController( testAccount ); 
        //testController.makeParentAccount();
        */
        
        //code block added by Nisha Agrawal to improve code coverage
        preAccountController testController = new preAccountController( testAccount ); 
        PageReference returnPage = testController.makeParentAccount();
        system.assert(returnPage == null);
        
        PageReference objPage = Page.PreAccount_to_Parent_Account;
        objPage.getParameters().put('Id', testAccount.Id);
        Test.setCurrentPage(objPage);
        
        returnPage = testController.makeParentAccount();
        //assert the results
        system.assert(returnPage != null);
        List<Account> lstAccounts = [Select Id, Name, RecordTypeId From Account Where Id =: testAccount.Id Limit 1];
        system.assert(lstAccounts.size() == 1);
        system.assert(lstAccounts[0].RecordTypeId == parentAccountRecordTypeId);
        //code block ends here added by Nisha Agrawal
    }

    static testMethod void preAccountToChildTest()
    {
    	//fetchPreAccountRecordType(); // commented by Nisha Agrawal to improve coverage
    	//fetchParentAccountRecordType(); // commented by Nisha Agrawal to improve coverage
    	
        //code block added by Nisha Agrawal
    	preAccountRecordTypeId = AccountHelper.getPreAccountRecordTypeID();
    	childAccountRecordTypeId = AccountHelper.getChildRecordTypeID();
        
        Account testAccount = new Account(	RecordTypeId = preAccountRecordTypeId ,
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
        
        /* code commented by Nisha Agrawal to improve the coverage 
         //preAccountController testController = new preAccountController( testAccount ); 
        //testController.makeChildAccount();
        */
        
        //code block added by Nisha Agrawal to improve code coverage
        preAccountController testController = new preAccountController( testAccount ); 
        PageReference returnPage = testController.makeChildAccount();
        system.assert(returnPage == null);
        
        PageReference objPage = Page.PreAccount_to_Child_Account;
        objPage.getParameters().put('Id', testAccount.Id);
        Test.setCurrentPage(objPage);
        
        returnPage = testController.makeChildAccount();
        //assert the results
        system.assert(returnPage != null);
        List<Account> lstAccounts = [Select Id, Name, RecordTypeId From Account Where Id =: testAccount.Id Limit 1];
        system.assert(lstAccounts.size() == 1);
        system.assert(lstAccounts[0].RecordTypeId == childAccountRecordTypeId);
        //code block ends here added by Nisha Agrawal
    }

    static testMethod void preAccountToComboTest()
    {
    	//fetchPreAccountRecordType();
    	//fetchParentAccountRecordType();
    	preAccountRecordTypeId = AccountHelper.getPreAccountRecordTypeID();
    	parentAccountRecordTypeId = AccountHelper.getParentRecordTypeID();
        childAccountRecordTypeId = AccountHelper.getChildRecordTypeID();
        
        Account testAccount = new Account(	RecordTypeId = preAccountRecordTypeId ,
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
                
        /* code commented by Nisha Agrawal to improve the coverage 
         //preAccountController testController = new preAccountController( testAccount ); 
        //testController.makeAccountCombo();
        */
        
        //code block added by Nisha Agrawal to improve code coverage
        preAccountController testController = new preAccountController( testAccount ); 
        PageReference returnPage = testController.makeAccountCombo();
        system.assert(returnPage == null);
        
        PageReference objPage = Page.PreAccount_to_Account_Combo;
        objPage.getParameters().put('Id', testAccount.Id);
        Test.setCurrentPage(objPage);
        
        returnPage = testController.makeAccountCombo();
        //assert the results
        system.assert(returnPage != null);
        List<Account> lstAccounts = [Select Id, Name, RecordTypeId From Account Where NXP_GId__c =: testAccount.NXP_GID__c];
        system.assert(lstAccounts.size() == 2);
        
        if(lstAccounts[0].Id == testAccount.Id)
        {
        	system.assert(lstAccounts[0].RecordTypeId == parentAccountRecordTypeId);
            system.assert(lstAccounts[1].RecordTypeId == childAccountRecordTypeId);
        }
        else
        {
            system.assert(lstAccounts[1].RecordTypeId == parentAccountRecordTypeId);
            system.assert(lstAccounts[0].RecordTypeId == childAccountRecordTypeId);
        }
        
        //code block ends here added by Nisha Agrawal
    }
}