/********************************************************************************
@Created By :    Scarlett Kang
@Created Date:   28 May 2015
@Description:    Test Class for Apttus_Approver_Table_Ext_Controller
********************************************************************************/
@isTest
public with sharing class Apttus_Approver_Table_Ext_ControllerTest {
	private static string TYPE_Global_Local_General_Purchase_Agreement_GPA = 'Global_Local_General_Purchase_Agreement_GPA';
	private static RecordType Global_Local_General_Purchase_Agreement_GPA;
	
	private static List<User> lstUser;
	private static User objUser;
	private static User objUser2;
	private static Apttus_Approver_Table__c objApttusApprover;
	private static Apttus_Approver_Table__c objApttusApproverMT;
	private static Apttus_Approver_Table__c objApttusApproverLegal;
	private static List<Apttus_Approver_Role__c> lstCustomSettingApprover;
	
	@isTest(seeAllData = TRUE)
	private static void fetchRecordType(){
		for(RecordType rt : [SELECT Id, DeveloperName
                     FROM   RecordType
                     WHERE  IsActive = TRUE 
                     AND SobjectType = 'Apttus_APTS_Agreement__c' AND DeveloperName =: TYPE_Global_Local_General_Purchase_Agreement_GPA
                     ])
        {
        	if(rt.DeveloperName == TYPE_Global_Local_General_Purchase_Agreement_GPA)
        		Global_Local_General_Purchase_Agreement_GPA = rt;
        }
	}
	
	private static void createUser(){
    	Profile objProfiles =[
            SELECT Id, Name 
            FROM Profile 
            WHERE Name LIKE '%Apttus%' LIMIT 1 
        ];
        
        lstUser = new List<User>();
        
        if(objProfiles != null){			
			for(Integer i = 0 ; i < 6 ; i++){	    		
	    		objUser = new User(
	    			alias = 'nUser' + i, 
		            email = 'Apttus_Approver_Table_Ext_ControllerTest.user' + i + '@test.com', 
		            emailencodingkey = 'UTF-8', 
		            lastname = 'test' + (i + 1), 
		            languagelocalekey = 'en_US', 
		            localesidkey ='en_US',
		            profileId = objProfiles.Id, 
		            timezonesidkey = 'America/Los_Angeles', 
		            username = 'Apttus_Approver_Table_Ext_ControllerTest.user' + i + '@test.com',
		            User_Region__c = 'Americas'
	    		);
				lstUser.add(objUser);
			}
			insert lstUser;			
        }
    }
	
	private static void createApttusApproverTable(){
		objApttusApprover = new Apttus_Approver_Table__c(
			Role__c = 'SBMT',
			Name = lstUser[1].Name,
			Former_Approver__c = lstUser[0].Id,
			User__c = lstUser[1].Id
		);
		insert objApttusApprover;
	}
	
	private static void createMTApprover(){
		//MT Approver
		objApttusApproverMT = new Apttus_Approver_Table__c(
			Role__c = 'Management Team',
			Name = lstUser[3].Name,
			Former_Approver__c = lstUser[2].Id,
			User__c = lstUser[3].Id
		);
		insert objApttusApproverMT;
	}
	
	private static void createLegalApprover(){
		//Legal Approver
		objApttusApproverLegal = new Apttus_Approver_Table__c(
			Role__c = 'Legal',
			Name = lstUser[5].Name,
			Former_Approver__c = lstUser[4].Id,
			User__c = lstUser[5].Id
		);
		insert objApttusApproverLegal;
	}
	
	static testMethod void myUnitTestApprover(){
		//prepare data
		fetchRecordType();
		createUser();
		createApttusApproverTable();
		
		Apttus__APTS_Agreement__c objAgreement = new Apttus__APTS_Agreement__c(
			RecordType = Global_Local_General_Purchase_Agreement_GPA,
			Name = 'Unit Test',
			Apttus__Status__c = 'Request',
			Apttus__Status_Category__c = 'Request',
			Approver_1_Role__c = 'SBMT',
			Approver1__c = lstUser[0].Id,
			Approver_2_Role__c = 'SBMT',
			Approver2__c = lstUser[0].Id,
			Approver_3_Role__c = 'SBMT',
			Approver3__c = lstUser[0].Id,
			Approver_4_Role__c = 'SBMT',
			Approver4__c = lstUser[0].Id,
			Approver_5_Role__c = 'SBMT',
			Approver5__c = lstUser[0].Id,
			Approver_6_Role__c = 'SBMT',
			Approver6__c = lstUser[0].Id,
			Approver_7_Role__c = 'SBMT',
			Approver_7__c = lstUser[0].Id,
			Approver_8_Role__c = 'SBMT',
			Approver8__c = lstUser[0].Id,
			Approver_9_Role__c = 'SBMT',
			Approver_9__c = lstUser[0].Id,
			MT_Approver_Role__c = 'Management Team',
			MT_Approver__c = lstUser[2].Id,
			Legal__c = lstUser[4].Id,
			Total_Agreement_Value_in_millions__c = 5,
			nxp_Liab_byond_policy__c = true,
			Explanation_for_Liability_Indemnity__c = 'test',
			nxp_Purchase_oblg_12mnth__c = true,
			Explanation_for_Purchase_12months__c = 'test',
			Management_Team__c = true
		);
		insert objAgreement;
						
	    ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(objApttusApprover);
        Apttus_Approver_Table_Ext_Controller theControllerExt 
            = new Apttus_Approver_Table_Ext_Controller( theStandardController );
		theControllerExt.Approvers();

	}
	
	static testMethod void myUnitTestMTApprover(){
		//prepare data
		fetchRecordType();
		createUser();
		createMTApprover();
		  
		Apttus__APTS_Agreement__c objAgreement = new Apttus__APTS_Agreement__c(
			RecordType = Global_Local_General_Purchase_Agreement_GPA,
			Name = 'Unit Test',
			Apttus__Status__c = 'Request',
			Apttus__Status_Category__c = 'Request',
			MT_Approver_Role__c = 'Management Team',
			MT_Approver__c = lstUser[2].Id,
			Legal__c = lstUser[4].Id,
			Total_Agreement_Value_in_millions__c = 5,
			nxp_Liab_byond_policy__c = true,
			Explanation_for_Liability_Indemnity__c = 'test',
			nxp_Purchase_oblg_12mnth__c = true,
			Explanation_for_Purchase_12months__c = 'test',
			Management_Team__c = true
		);
		insert objAgreement;
	
	    ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(objApttusApproverMT);
        Apttus_Approver_Table_Ext_Controller theControllerExt 
            = new Apttus_Approver_Table_Ext_Controller( theStandardController );
		theControllerExt.Approvers();
		
	}
	
	static testMethod void myUnitTestLegalApprover(){
		//prepare data
		fetchRecordType();
		createUser();
		createLegalApprover();
		  
		Apttus__APTS_Agreement__c objAgreement = new Apttus__APTS_Agreement__c(
			RecordType = Global_Local_General_Purchase_Agreement_GPA,
			Name = 'Unit Test',
			Apttus__Status__c = 'Request',
			Apttus__Status_Category__c = 'Request',
			MT_Approver_Role__c = 'Management Team',
			MT_Approver__c = lstUser[2].Id,
			Legal__c = lstUser[4].Id,
			Total_Agreement_Value_in_millions__c = 5,
			nxp_Liab_byond_policy__c = true,
			Explanation_for_Liability_Indemnity__c = 'test',
			nxp_Purchase_oblg_12mnth__c = true,
			Explanation_for_Purchase_12months__c = 'test',
			Management_Team__c = true
		);
		insert objAgreement;
	
	    ApexPages.StandardController theStandardController 
            = new ApexPages.standardController(objApttusApproverLegal);
        Apttus_Approver_Table_Ext_Controller theControllerExt 
            = new Apttus_Approver_Table_Ext_Controller( theStandardController );
		theControllerExt.Approvers();
		
	}
}