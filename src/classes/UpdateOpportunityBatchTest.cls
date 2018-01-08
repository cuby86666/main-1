/******************************************************************************
@Created By :    Scarlett Kang   
@Created Date:   May 12, 2015   
@Description:    New apex class is created    
********************************************************************************/
/**********************
@ Updated By: Scarlett Kang
@ Update Date: 1506 Release
@ Description: Changed to Batch 
*******************************************/

/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 


@isTest
private class UpdateOpportunityBatchTest {
	
    private static final String TYPE_SFDC_Oppty = 'SFDC_Oppty';
    private static final String TYPE_Global_Enterprise = 'Global_Enterprise';//ojb: Customer
    private static final String TYPE_Parent_Account = 'Parent_Account';
    private static final String TYPE_Child_Account = 'Child_Account';
    
    private static RecordType SFDC_Oppty;
    private static RecordType Global_Enterprise;
    private static RecordType Parent_Account;
    private static RecordType Child_Account;
    
    private static Customer__c objCustomer;
    private static Account objParentAccount;
    private static Account objChildAccount;
    private static User objUser;
   
    private static Approvers_Matrix__c objApproverMatrix;
    private static Opportunity objOpportunity;
    private static List<Opportunity> lstOpportunity;
    
    private static void fetchRecordType(){
        for(RecordType rt : [SELECT Id, DeveloperName
                     FROM   RecordType
                     WHERE  IsActive = TRUE 
                     AND ((SobjectType = 'Opportunity' AND DeveloperName =: TYPE_SFDC_Oppty)
                            OR (SobjectType = 'Customer__c' AND DeveloperName =: TYPE_Global_Enterprise)
                            OR (SobjectType = 'Account' AND DeveloperName =: TYPE_Parent_Account)
                            OR (SobjectType = 'Account' AND DeveloperName =: TYPE_Child_Account)
                     )
                      ])
        {
            if(rt.DeveloperName == TYPE_SFDC_Oppty)
                SFDC_Oppty = rt;
            if(rt.DeveloperName == TYPE_Global_Enterprise)
                Global_Enterprise = rt;
            if(rt.DeveloperName == TYPE_Parent_Account)
                Parent_Account = rt;
            if(rt.DeveloperName == TYPE_Child_Account)
                Child_Account = rt;
        }
    }
    
    private static void createCustomer()
    {
        objCustomer = new Customer__c(
            RecordTypeId = Global_Enterprise.Id, Account_Name__c = 'ut_Global_Enterprise ',
              Legal_Name__c = 'ut_Global_Enterprise ' , DUNS__c = 'ut_123', 
              Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
              House_Number__c = 'ut', Street__c = 'ut_street_1' ,
              Zip__c = 'ut_zip' , City__c = 'ut_city', Country__c = 'USA' ,  
              Industry_Segment__c = 'CC - Computing' ,
              Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
              Fulfillment_Channel__c = 'Disti',  Street_2__c = 'ut_street_2' ,
              Street_3__c = 'ut_street_3' ,State__c = 'test', Industry_Sub_Segment__c = 'F1 - Desktop',
              SIC_Code__c = 't' , NAICS_Code__c = 'ut_', 
              Website__c = 'http://www.test.com', EMail__c  = 'test.test@test.com',
              Fax__c = '+1234567890', Telephone__c = '+1234567890'
        );
                              
        insert objCustomer;
    }
    
    private static void createParentAccount(){
        createCustomer();
        
        Customer__c testCustomer = [SELECT Id, Name FROM Customer__c LIMIT 1];
        
        objParentAccount = new Account(
            RecordTypeId = Parent_Account.Id,
            NXP_GID__c = testCustomer.Name,
            Customer_Category__c = 'Key',
            Name ='Unit Test Parent Account', 
            Legal_Name__c = 'Unit Test Parent Acconut Legal Name',
            Status_of_D_B_Cleansing__c = 'D&B Data Accepted' , 
            D_B_Account_Name__c = 'DB Name' , 
            D_B_Street__c = 'DB Street' , 
            D_B_State_Province__c = 'DB State' , 
            D_B_City__c = 'DB City' , 
            D_B_Country__c = 'DB Country' , 
            D_B_ZIP_Postal_Code__c = 'DB Zip' , 
            D_B_SIC_Code__c = 'DB Sic' , 
            D_B_SIC_Code_Description__c = 'DB Sic Desc',
            Industry_Segment__c = 'AA - Appliances',
            House_Number__c = 'house',
            Street__c = 'Test street',
            Street2__c = 'Test Street 2',
            Street3__c = 'Test Street 3',
            City__c = 'Taipei',
            State_Province__c = 'Taipei',
            ZIP_Postal_Code__c = '11500',
            Country__c = 'Taiwan',
            Website = 'www.test.com',
            Email__c = 'test@test.com',
            Phone = '+886281709999',
            Fax = '+886281709999',
            Fulfillment_Channel__c = 'Direct',
            Role__c = 'OEM',
            Type = 'Customer'
        );
        insert objParentAccount;    
    }
    
    private static void createChildAccount(){
        objChildAccount = new Account(
            RecordTypeId = Child_Account.Id,
            Name = 'Unit Test Child Account',
            Parent = objParentAccount,
            Region__c = 'AP - GC',
            Country__c = 'Taiwan',
            NXP_GID__c = objParentAccount.NXP_GID__c,
            DUNS_Number__c = '11111111'
        );
        insert objChildAccount;
    }
    
    private static void createUser(){
        Profile objProfiles =[
            SELECT Id, Name 
            FROM Profile 
            WHERE Name = 'Standard User' LIMIT 1 
        ];
        
        if(objProfiles != null){
            objUser = new user(
                alias = 'nUser', 
                email = 'UpdateOpportunityBatchTest.user@test.com', 
                emailencodingkey = 'UTF-8', 
                lastname = 'test', 
                languagelocalekey = 'en_US', 
                localesidkey ='en_US',
                profileId = objProfiles.Id, 
                timezonesidkey = 'America/Los_Angeles', 
                username = 'UpdateOpportunityBatchTest.user@test.com',
                User_Region__c = 'Americas'
            );
            insert objUser;
        }
    }
    
   
    
    private static void createApproverMatrix(){
        //Regional VP
        objApproverMatrix = new Approvers_Matrix__c(
            Approver__c = objUser.Id,
            criteria_2__c = 'AP - GC',
            Type__c = 'Regional VP',
            Threshold_1__c = 0
        );
        insert objApproverMatrix;
        
        //Regional Controller
        objApproverMatrix = new Approvers_Matrix__c(
            Approver__c = objUser.Id,
            criteria_2__c = 'AP - GC',
            Type__c = 'Regional Controller',
            Threshold_1__c = 0
        );
        insert objApproverMatrix;
    }
    
    private static void createOpportunity(){
        lstOpportunity = new List<Opportunity>();
         
        for(integer i  = 0 ; i < 10 ; i++){
            objOpportunity = new Opportunity(
                RecordType = SFDC_Oppty,
                Name = 'Test Opportunity' + i,
                AccountId = objChildAccount.Id,
                Channel__c = 'Test',
                Production_Date__c = Date.valueof(Date.today().year() + '-06-10'),
                CloseDate = Date.valueof(Date.today().year() + '-05-10'),
                StageName = 'Test',
                //Top_10_BU__c = 'BU Automotive',
                Reference_Design__c = false,
                Locked_Exchange_Rate__c = 1.00,
                X2015_Pieces__c = 10000,
                X2016_Pieces__c = 10000,
                X2017_Pieces__c = 10000,
                X2018_Pieces__c = 10000,
                X2019_Pieces__c = 10000,
                X2020_Pieces__c = 10000
            );
            lstOpportunity.add(objOpportunity);
        }
        
        if(lstOpportunity.size() > 0)
            insert lstOpportunity;
    }
    
    static testMethod void myUnitTest(){
        //prepare data
        fetchRecordType();
        createParentAccount();
        createChildAccount();
        createUser();
    
        createApproverMatrix();
        createOpportunity();
        
        List<Opportunity> lstTestOpportunity = [SELECT Id FROM Opportunity];
        system.assert(lstTestOpportunity.size() > 0);
        
        UpdateOpportunityBatch updateOpptyTest = new UpdateOpportunityBatch();
        updateOpptyTest.ApproverId = string.valueof(objUser.Id);
        Database.executeBatch(updateOpptyTest);
    }
    
}