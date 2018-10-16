/**********************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      26 Jul 2017
@Description:       Test Class for the trigger UpdateStatus_NewUserRegistration

Last Modified By     : Naveen Nayak 
Last Modified Date   : 13 July, 2018
Description : Changing Custom Object name New_User_Registration__C
**********************************************************************************/
@isTest
private class UpdateStatus_NewUserRegistrationTest 
{
    static testMethod void UpdateStatus_NewUserRegistrationTest1() 
    {
        
        //prepare test data
        New_User_Registration__c objRequest = new New_User_Registration__c(First_Name__c = 'Test', Last_Name__c = 'Test', Email_Address__c = 'ut.abc@nxp.com', Region__c = 'EMEA', Country__c = 'Netherlands', 
                                                                             Manager_Name__c = 'Test Manager', Manager_s_email__c = 'test.manager@nxp.com');
		insert objRequest;
        system.assert(objRequest.Id != null);
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        system.assert(lstProfiles.size() == 1);
        Profile objProfile = lstProfiles[0];
                
        Test.startTest();
        //create new user with new user registration id
        User objUser = TestUtil.createTestUser('ut.abc@nxp.com', 'utuser', objProfile.Id);
        
        objUser.New_User_Registration_ID__c = objRequest.Id;
        insert objUser;
        system.assert(objUser.Id != null);
        
        Test.stopTest();
        //since status is updated by future method so have to assert results after stopTest method only.
        List<New_User_Registration__c> lstRequests = [Select Id, Name, Status__c From New_User_Registration__c 
                                                      	Where id =: objRequest.Id Limit 1];
        system.assert(lstRequests.size() == 1);
        system.assert(lstRequests[0].Status__c == 'User A/c Created');
        
    } 
}