@isTest
private class CMD_Request_BeforeInsertUpdate_Test 
{
/*    private static User testUser = new User(	FirstName = 'Test' ,
            									LastName = 'User' ,
            									Username = 'test@test.com' ,
            									Email = 'test@test.com'
        									);
*/
	    private RecordType newSfdcParentAccount;
    	public string newSfdcParentAccountRTId;

	    private void fetchNewSfdcParentAccountRecordType()
    	{
        	for(RecordType rt : 
            	[   
                	Select Id, DeveloperName
	                From RecordType
    	            WHERE SobjectType = 'CMD_Request__c' 
        	        AND DeveloperName = 'New_SFDC_Parent_Account' 
            	    AND IsActive=true
                	Limit 1
	            ]
    	    )
        	{
            	newSfdcParentAccount = rt;
	            newSfdcParentAccountRTId = String.valueOf(rt.Id);            
    	    }    
    	}

    @isTest(SeeAllData=true) 
    static void myUnitTest() 
    {
//    	insert testUser;

//    	fetchNewSfdcParentAccountRecordType();
    	
        CMD_Request__c testRequest = new CMD_Request__c(	Requester_Name__c = 'TEST REQUESTER' ,
        													Requester_Email__c = 'test@test.com' ,
        													Street__c = 'TEST STREET' ,
        													City__c = 'TEST CITY' ,
        													Country__c = 'Taiwan' ,
        													Customer_Category__c = 'Focused' ,
        													Role__c = 'OEM' 	
        												);
    	insert testRequest;
    }
}