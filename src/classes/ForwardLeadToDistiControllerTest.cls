/**************************************************************************************
@Created By :    Nisha Agrawal
@Created Date:   Sep 25, 2018
@Description:    Test Class for server side controller ForwardLeadToDistiController 
******************************************************************************************/

@isTest
public class ForwardLeadToDistiControllerTest 
{
    private static Id parentAccountRecordTypeId;
    private static Id childAccountRecordTypeId;
	private static Id TMMARecordTypeId;
	private static String DISTI_PROFILE_NAME = 'NXP Distributor User';
    
    static testmethod void ForwardLeadToDistiControllerTest1()
    {
        //fetch record types for account
        parentAccountRecordTypeId = AccountHelper.getParentRecordTypeID();
        childAccountRecordTypeId = AccountHelper.getChildRecordTypeID();
        
        //fetch record types for Lead
        TMMARecordTypeId = LeadHelper.getTMMA_RecordTypeID();
        
        //create Hub Foundation records
        //Fetch the Record Type for Country and Region Mapping
        List<RecordType> lstRecordTypes = [Select Id, DeveloperName From RecordType Where DeveloperName = 'Country_and_Region' and SobjectType = 'Hub_Foundation__c' Limit 1];
        List<Hub_Foundation__c> lstHubFoundation = new List<Hub_Foundation__c>();
        system.assert(lstRecordTypes.size() > 0);
        
        lstHubFoundation.add(new Hub_Foundation__c(Country__c = 'USA' , Region__c = 'Americas' , Alpha_2_Code__c = 'US' , Alpha_3_Code__c = 'USA'));
        lstHubFoundation.add(new Hub_Foundation__c(Country__c = 'Germany' , Region__c = 'EMEA' , Alpha_2_Code__c = 'DE' , Alpha_3_Code__c = 'DEU'));
        
        insert lstHubFoundation;
        for(Hub_Foundation__c obj : lstHubFoundation)
        {
            system.assert(obj.Id != null);
        }
        
        //create parent account
        Account parentAccount = new Account(Name = 'Disti Parent 1', RecordTypeId = parentAccountRecordTypeId, Region__c = 'EMEA');
        insert parentAccount;
        system.assert(parentAccount.Id != null);
                
        //create child account
		Account childAccount = new Account(Name = 'Disti Child 1', ParentId = parentAccount.Id, RecordTypeId = childAccountRecordTypeId, 
                                         		Region__c = 'EMEA', Country__c = 'Test Country', ZIP_Postal_Code__c = '12345');  
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        //create contacts for child accounts
    	List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(new Contact(AccountId = childAccount.Id, FirstName = 'Test', LastName = 'Disti 1' , Email = 'test.contact1@nxp.com', Community_web_country__c = 'USA' ));
        lstContacts.add(new Contact(AccountId = childAccount.Id, FirstName = 'Test', LastName = 'Disti 2' , Email = 'test.contact2@nxp.com', Community_web_country__c = 'Germany' ));
        lstContacts.add(new Contact(AccountId = childAccount.Id, FirstName = 'Test', LastName = 'Disti 3' , Email = 'test.contact3@nxp.com', Community_web_country__c = 'USA' ));
        
        insert lstContacts;
        
        for(Contact obj : lstContacts)
        {
            system.assert(obj.Id != null);
        }
        
        //create LeadCountrySettings data for Country and Region mapping in Lead
        LeadCountrySettings__c leadCountrySettings = new LeadCountrySettings__c(Country_Code__c='DEU', Country__c='Germany',Name='Germany', Region__c='EMEA');
        insert leadCountrySettings;
        //create lead record
        Lead objLead = new lead(FirstName = 'Test', LastName = 'Lead', Company='Test company', RecordTypeId = TMMARecordTypeId ,  
                              Status='Open', Country = 'DEU',Email= 'test.lead1@nxp.com');
        insert objLead;
        system.assert(objLead.Id != null);
        
        //get the distributor user profile
        Profile objProfile = [Select Id from Profile Where Name = : DISTI_PROFILE_NAME limit 1];
        system.assert(objProfile.Id != null);
        
        User objDistiUser = TestUtil.createTestUser('test.contact1@nxp.com', 'testUser', objProfile.Id);
        objDistiUser.ContactId = lstContacts[0].Id;
        objDistiUser.Disti_Lead_Portal_User_Role__c = 'User';
        insert objDistiUser;
        
        system.assert(objDistiUser.Id != null);
        
        //assign the lead for the first time
        objLead.Distributor_Contact__c = lstContacts[0].Id;
        update objLead;
        
        //verify the results
        objLead = [Select Id, Distributor_Contact__c, Previous_Assignee__c, Original_Assignee__c From Lead
                              		Where Id =: objLead.Id Limit 1];
        system.assert(objLead.Distributor_Contact__c == lstContacts[0].Id);
		system.assert(objLead.Previous_Assignee__c == null);
		system.assert(objLead.Original_Assignee__c == null);
        
        //create partner community user and run as that user
		test.startTest();
        system.runAs(objDistiUser)
        {
            //forward the lead to colleague for the first time
            ForwardLeadToDistiController.forwardLeadWithinDisti(objLead.Id, lstContacts[1].Id);
            
            //verify the results
            objLead = [Select Id, Distributor_Contact__c, Previous_Assignee__c, Original_Assignee__c From Lead
                              		Where Id =: objLead.Id Limit 1];
            
            system.assert(objLead.Distributor_Contact__c == lstContacts[1].Id);
            system.assert(objLead.Previous_Assignee__c == lstContacts[0].Id);
            system.assert(objLead.Original_Assignee__c == lstContacts[0].Id);
            
            //forward the lead to colleague for the second time
            ForwardLeadToDistiController.forwardLeadWithinDisti(objLead.Id, lstContacts[2].Id);
            //verify the results
            objLead = [Select Id, Distributor_Contact__c, Previous_Assignee__c, Original_Assignee__c From Lead
                              		Where Id =: objLead.Id Limit 1];
            
            system.assert(objLead.Distributor_Contact__c == lstContacts[2].Id);
            system.assert(objLead.Previous_Assignee__c == lstContacts[1].Id);
            system.assert(objLead.Original_Assignee__c == lstContacts[0].Id);            
        }
        
        test.stopTest();
    }
}