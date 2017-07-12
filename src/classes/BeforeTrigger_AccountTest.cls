/***********************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      10 Apr 2013
@Description:       Test Class for Trigger BeforeTrigger_Account
*************************************************************************************************************/

@isTest
private class BeforeTrigger_AccountTest 
{

	/**********************************************************************
    //Case - Child Account D&B Data update
    ***********************************************************************/
   
    static testmethod void BeforeTrigger_AccountTest1()
    {
        //get the record type
        List<RecordType> lstRecordTypes = [Select Id, DeveloperName, SobjectType  
											From RecordType
                                           	Where SobjectType = 'Account' and DeveloperName = 'Child_Account' and IsActive=true
                                           	Limit 1];
        RecordType childAccount;
        if(lstRecordTypes.size() > 0)
        {
            childAccount = lstRecordTypes[0];
        }
        
        //start the Test       
        Test.startTest();
        //prepare test data
        Account objAccount = new Account(Name='Unit Test Account', RecordTypeId = childAccount.Id , Status_of_D_B_Cleansing__c = 'D&B Data Accepted' , D_B_Account_Name__c = 'DB Name' , 
        									D_B_Street__c = 'DB Street' , D_B_State_Province__c = 'DB State' , D_B_City__c = 'DB City' , D_B_Country__c = 'DB Country' , 
        									D_B_ZIP_Postal_Code__c = 'DB Zip' , D_B_SIC_Code__c = 'DB Sic' , D_B_SIC_Code_Description__c = 'DB Sic Desc' );
        insert objAccount;
       
        //assert the results
        System.assert(objAccount.Id != null);
       
        //fetch the account details 
        objAccount = [Select Id , Name, Street__c , City__c  , ZIP_Postal_Code__c , Country__c , State_Province__c , Sic, SicDesc ,
                        NAICS__c, AnnualRevenue , NumberOfEmployees ,DUNS_Ultimate__c, DUNS_Number__c, D_B_Account_Name__c , D_B_Street__c , 
                        D_B_City__c , D_B_ZIP_Postal_Code__c , D_B_Country__c , D_B_State_Province__c, D_B_SIC_Code__c , D_B_SIC_Code_Description__c,
                        D_B_NAICS_Code__c , D_B_Annual_Revenue__c , D_B_Employees__c , D_B_Global_Ultimate_Company_Name__c , D_B_Number__c
                     From Account
                     Where Id= :objAccount.Id Limit 1  ];
                 
        System.assert(objAccount.Name == objAccount.D_B_Account_Name__c);                   
        System.assert(objAccount.Street__c == objAccount.D_B_Street__c);
        System.assert(objAccount.City__c == objAccount.D_B_City__c);
        System.assert(objAccount.ZIP_Postal_Code__c == objAccount.D_B_ZIP_Postal_Code__c);
        System.assert(objAccount.Country__c == objAccount.D_B_Country__c);
        System.assert(objAccount.State_Province__c == objAccount.D_B_State_Province__c);
        System.assert(objAccount.Sic == objAccount.D_B_SIC_Code__c);
        System.assert(objAccount.SicDesc == objAccount.D_B_SIC_Code_Description__c);
        System.assert(objAccount.NAICS__c == objAccount.D_B_NAICS_Code__c);
        System.assert(objAccount.DUNS_Ultimate__c == objAccount.D_B_Global_Ultimate_Company_Name__c);
        System.assert(objAccount.DUNS_Number__c == objAccount.D_B_Number__c);
        
       //Stop the Test
       Test.stopTest();
    }
    
    /**********************************************************************
    //Case - Single Record - Pre Account Type Record
    ***********************************************************************/
    
    static testmethod void BeforeTrigger_AccountTest2()
    {
    	List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
    	
    	if(lstProfiles.size() > 0)
        {
        	//prepare test data
        	Profile objProfile = lstProfiles[0];
            
            //insert User
            User objUser = TestUtil.createTestUser('ut.abc@test.com', 'utuser', objProfile.Id);
            insert objUser;
            system.assert(objUser.Id != null);
            
			String PARENT_ACCOUNT = 'Parent_Account';
			String PRE_ACCOUNT = 'Pre_Account'; 
			
			RecordType parentAccount;
			RecordType preChildAccount;
			
			for(RecordType rt : [Select Id, DeveloperName
                           From RecordType
                           Where SobjectType = 'Account' and ( DeveloperName =: PARENT_ACCOUNT or DeveloperName =: PRE_ACCOUNT ) and IsActive=true
                           Limit 2])
			{
				if(rt.DeveloperName == PARENT_ACCOUNT)
		   		{
		   			parentAccount = rt;
		   		}
		   		else if(rt.DeveloperName == PRE_ACCOUNT)
		   		{
		   			preChildAccount = rt;
		   		}
			}
			
            //insert Parent Account
            Account objParent = new Account(Name = 'ut_parent', Account_Manager__c = objUser.Id, RecordTypeId = parentAccount.Id);
            insert objParent;
            system.assert(objParent.Id != null);
            
            //start the Test       
	        Test.startTest();
	        
	        Account objPreAccount = new Account(Name='Unit Test Account', RecordTypeId = preChildAccount.Id, ParentId = objParent.Id);
	        insert objPreAccount;
	        
	        //assert the results
	        System.assert(objPreAccount.Id != null);
	       
	        //fetch the account details
	        objPreAccount = [Select Id , Name, Parent.Account_Manager__c , Account_Manager_prechild__c
	                     	From Account
	                     	Where Id= :objPreAccount.Id 
	                     	Limit 1 ];
	                           
	        System.assert(objPreAccount.Account_Manager_prechild__c != null);
	        System.assert(objPreAccount.Parent.Account_Manager__c != null);
	        System.assert(objPreAccount.Account_Manager_prechild__c == objPreAccount.Parent.Account_Manager__c);
	        System.assert(objPreAccount.Account_Manager_prechild__c == objUser.Id);
	       
	       //Stop the Test
	       Test.stopTest();            
        } 
    }
}