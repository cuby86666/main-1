/****************************************************************************************************
@LastModified By :  Nisha Agrawal
@Modified Date :   Jun 27, 2017
@Description :     Added @isTest annotation at class level and updated version from 19 to 39
*****************************************************************************************************/

@isTest
public with sharing class AptsAgreementTriggerTest {
//test class to exercise the Agreement trigger functionality

	static testMethod void updateManagerCheck() 
	{
		try 
		{
			Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c(Name = 'Agreement Trigger Test');
			agmt.Apttus__Status__c = 'Request';
			agmt.Apttus__Status_Category__c = 'Request';
			insert agmt;
	    	agmt = [select Name from Apttus__APTS_Agreement__c where Name = 'Agreement Trigger Test' limit 1];
			agmt.Approver_1_role__c = 'RSM';
			agmt.approver1__c = agmt.ownerId;
			agmt.Approver_2_role__c = 'Corporate Control';
			agmt.approver2__c = agmt.ownerId;
			agmt.Approver_3_role__c = 'RSM';
			agmt.approver3__c = agmt.ownerId;
			agmt.Approver_4_role__c = 'RSM';
			agmt.approver4__c = agmt.ownerId;
			agmt.Approver_5_role__c = 'RSM';
			agmt.approver5__c = agmt.ownerId;
			agmt.Approver_6_role__c = 'RSM';
			agmt.approver6__c = agmt.ownerId;
			agmt.Approver_7_role__c = 'RSM';
			agmt.approver_7__c = agmt.ownerId;
			agmt.Total_Agreement_Value_in_millions__c = 5;
			update agmt;        
	    	Apttus__APTS_Agreement__c agmtCheck = [select Name from Apttus__APTS_Agreement__c where Name = 'Agreement Trigger Test' limit 1];
	    	agmtCheck.approver1__c = agmt.ownerId;
			agmtCheck.Apttus__Status__c = 'Request Approval';
			update agmtCheck;
	    	agmtCheck = [select Name from Apttus__APTS_Agreement__c where Name = 'Agreement Trigger Test' limit 1];
			agmtCheck.Apttus__Status__c = 'Ready for Signatures';
			update agmtCheck;
		}catch (Exception e) 
		{
			System.assert(e.getMessage().contains('Testing Agreement triggers insert/update failed'), e.getMessage());
		}
	}
			
}