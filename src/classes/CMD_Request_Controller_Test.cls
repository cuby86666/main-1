/******************************************************************************
@LastModified By :     Manoj
@Modified Date :   11 Mar 2015
@Description :     Modified to improve the code coverage
-------------------------------------------------------------------------------
@LastModified By :  Scarlett Kang
@Modified Date :   29 Apr 2015
@Description :     Modified to improve the code coverage
********************************************************************************/
@isTest
private class CMD_Request_Controller_Test 
{
    private static final String TYPE_Global_Enterprise = 'Global_Enterprise';//ojb: Customer
    private static final String TYPE_Country_and_Region = 'Country_and_Region';//obj: Hub Foundation
    private static final String TYPE_Parent_Account = 'Parent_Account';//obj: Account
    private static final String TYPE_Child_Account = 'Child_Account';//obj: Account
    private static final String TYPE_New_SFDC_Parent_Account = 'New_SFDC_Parent_Account';//obj: CMD Request
    private static final String TYPE_New_SFDC_Child_Account = 'New_SFDC_Parent_Account';//obj: CMD Request
        
    private static RecordType Global_Enterprise;
    private static RecordType Country_and_Region;
    private static RecordType Parent_Account;
    private static RecordType Child_Account;
    private static RecordType New_SFDC_Parent_Account;
    private static RecordType New_SFDC_Child_Account;
    
    private static List<Customer__c> lstCustomer;
    private static Customer__c objCustomer;
    private static List<Hub_Foundation__C> lstHubFoundation;
    private static Hub_Foundation__c objHubFoundation;
    private static Account objParentAccount;
    private static Account objChildAccount;
    private static User objUser;
    private static List<User> lstUser;
    private static CMD_Request__c objCMDRequest;
   
    
    private static void fetchRecordType(){
        for(RecordType rt : [SELECT Id, DeveloperName
                             FROM   RecordType
                             WHERE  IsActive = TRUE 
                             AND ((SobjectType = 'Customer__c' AND DeveloperName =: TYPE_Global_Enterprise)
                             /*
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z002_Ship_To)
                                 OR (SobjectType = 'SAP_CMD__c' AND DeveloperName =: TYPE_Z010_Intermediate_Consignee)
                                 */
                                 OR (SobjectType = 'Account' and DeveloperName =: TYPE_Parent_Account)
                                 OR (SobjectType = 'Account' and DeveloperName =: TYPE_Child_Account)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_New_SFDC_Parent_Account)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_New_SFDC_Child_Account)
                                 /*
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_SAP_New_Funloc_Request)
                                 OR (SobjectType = 'CMD_Request__c' and DeveloperName =: TYPE_SAP_Funloc_Edit_Request)
                                 */
                                 OR (SobjectType = 'Hub_Foundation__c' and DeveloperName =: TYPE_Country_and_Region )
                                 
                                 )
                              ])
        {
            if(rt.DeveloperName == TYPE_Global_Enterprise)
                Global_Enterprise = rt;
                /*
            if(rt.DeveloperName == TYPE_Z001_SOLDTO_SHIPTO_BILLTO_PAYER)
                Z001_SoldTo_ShipTo_BillTo_Payer = rt;
            if(rt.DeveloperName == TYPE_Z002_Ship_To) 
                Z002_Ship_To = rt;
            if(rt.DeveloperName == TYPE_Z010_Intermediate_Consignee)
              Z010_Intermediate_Consignee = rt;
            if(rt.DeveloperName == TYPE_New_SFDC_Parent_Account)
                New_SFDC_Parent_Account = rt;
            */
            if(rt.DeveloperName == TYPE_Parent_Account)
                Parent_Account = rt;            
            if(rt.DeveloperName == TYPE_Child_Account)
                Child_Account = rt;
            if(rt.DeveloperName == TYPE_New_SFDC_Parent_Account)
                New_SFDC_Parent_Account = rt;
            if(rt.DeveloperName == TYPE_New_SFDC_Child_Account)
                New_SFDC_Child_Account = rt;
            /*
            if(rt.DeveloperName == TYPE_SAP_New_Funloc_Request)
                SAP_New_Funloc_Request = rt;    
            if(rt.DeveloperName == TYPE_SAP_Funloc_Edit_Request)
                SAP_Funloc_Edit_Request = rt; 
                */
            if(rt.DeveloperName == TYPE_Country_and_Region)
                Country_and_Region = rt; 
                
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
    
    private static void createHubFundation(){
        objHubFoundation= new Hub_Foundation__c(
            RecordTypeId = Country_and_Region.Id,
            Alpha_2_Code__c =  'GC',
            Region__c = 'AP - GC',
            Country__c = 'Taiwan',
            Alpha_3_Code__c = 'AGC'
        );

        insert objHubFoundation;
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
                email = 'test.user@test.com', 
                emailencodingkey = 'UTF-8', 
                lastname = 'test', 
                languagelocalekey = 'en_US', 
                localesidkey ='en_US',
                profileId = objProfiles.Id, 
                timezonesidkey = 'America/Los_Angeles', 
                username = 'unittest.user.@test.com',
                User_Region__c = 'Americas'
            );
            insert objUser;
        }
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
            Industry_Segment__c = 'BB - C&I',
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
            Type = 'Customer',
            Account_Manager_AMEC__c = objUser.Id,
            Account_Manager_EMEA__c = objUser.Id,
            Account_Manager_GC__c = objUser.Id,
            Account_Manager_Japan__c = objUser.Id,
            Account_Manager_Korea__c = objUser.Id,
            Account_Manager_Korea_2__c = objUser.Id,
            Account_Manager_SAP__c = objUser.Id,
            Account_Manager_SAP_2__c = objUser.Id,
            Account_Manager_SAP_3__c = objUser.Id,
            Service_Manager_AMEC__c = objUser.Id,
            Service_Manager_EMEA__c = objUser.Id,
            Service_Manager_GC__c = objUser.Id,
            Service_Manager_Japan__c = objUser.Id,
            Service_Manager_Korea__c = objUser.Id,
            Service_Manager_SAP__c = objUser.Id
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
    
       
    private static void createCMDRequest(){
        objCMDRequest = new CMD_Request__c(
            RecordTypeId = New_SFDC_Child_Account.Id,
            Requester_SFDC__c = objUser.Id,
            Request_Status__c = 'Submitted',
            Requester_Email__c = objUser.Email,
            country__c='Taiwan',
            State_Province__c='kerala',
            Request_Type__c = 'SFDC New Child Account'
        );
        insert objCMDRequest;
    }    
  
    User testUser = new User
        (
            FirstName = 'Test' ,
            LastName = 'User' ,
            Username = 'test@test.com' ,
            Email = 'test@test.com'
        );
/*    
    static testMethod void blankRequestTest() 
    {
        CMD_Request_Controller testRequest = new CMD_Request_Controller();
        testRequest.RequestType = 'New SFDC Parent Account';
        testRequest.SubmitRequest();
    }
*/
    static testMethod void newParentRequestTest()
    {
        //prepare Data
        fetchRecordType();
        //createCustomer();
        createHubFundation();
        createUser();
        createParentAccount();
        createCMDRequest();
        
        system.assert(objParentAccount.NXP_GID__c != null);
        system.assert(objUser != NULL);
        
        PageReference testPage = Page.CMD;
        Test.setCurrentPage(testPage); 
        /*Added by Scarlett*/
        ApexPages.currentPage().getParameters().put('src', 'sfdc');
        ApexPages.currentPage().getParameters().put('rt', 'New Parent Account Request');
        ApexPages.currentPage().getParameters().put('rid', objCMDRequest.Id);//request id
        ApexPages.currentPage().getParameters().put('rtid', New_SFDC_Parent_Account.Id);//Record type id
        ApexPages.currentPage().getParameters().put('uid', 'test');//user id
        ApexPages.currentPage().getParameters().put('ao', 'test');
        ApexPages.currentPage().getParameters().put('aid', objParentAccount.Id);
        ApexPages.currentPage().getParameters().put('pgid', objParentAccount.NXP_GID__c);//Parent Account GID
        ApexPages.currentPage().getParameters().put('re', objUser.Email);// requester email
        ApexPages.currentPage().getParameters().put('aam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('aeu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('agc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ajp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa3', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('seu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sgc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sjp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('skr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ssa', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('em', 'test.user@test.com');//email
        /*Added by Scarlett*/
        /*Added by Vinanthi*/
       
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCMDRequest);                                   

        CMD_Request_Controller testRequest = new CMD_Request_Controller(stdCtrl);
        testRequest.RequestType = 'New SFDC Child Account';
        testRequest.Requester_Name = 'Test User';
        testRequest.Requester_Email = 'test.user@test.com';
        testRequest.Account_Name = 'Test Parent Account';
        testRequest.Legal_Name = 'Test Parent Account Company';
        testRequest.House_Number = 'House';
        testRequest.Street = 'Test Street 1';
        testRequest.Street_2 = 'Test Street 2';
        testRequest.Street_3 = 'Test Street 3';
        testRequest.City = 'Test Street 3';
        testRequest.State = 'Test State Province';
        testRequest.Postal_Code = 'Postal Zip';
        testRequest.Country = 'Taiwan';
        testRequest.Fulfillment_Channel = 'Direct';
        testRequest.Customer_Category = 'Focus';
        testRequest.Role = 'OEM';
        testRequest.Type = 'Customer';
        testRequest.Industry_Segment = 'CC - Computing';
        testRequest.Website = 'www.test.com';
        testRequest.Email = 'stan@test.com';
        testRequest.Telephone = '+1234567890';
        testRequest.Fax = '+1234567890';
        /*
        testRequest.AM_AMEC = 'test@test.com';
        testRequest.AM_EMEA = 'test@test.com';
        testRequest.AM_GC = 'test@test.com';
        testRequest.AM_Japan = 'test@test.com';
        testRequest.AM_Korea = 'test@test.com';
        testRequest.AM_Korea_2 = 'test@test.com';
        testRequest.AM_SAP = 'test@test.com';
        testRequest.AM_SAP_2 = 'test@test.com';
        testRequest.AM_SAP_3 = 'test@test.com';
        testRequest.SM_AMEC = 'test@test.com';
        testRequest.SM_EMEA = 'test@test.com';
        testRequest.SM_GC = 'test@test.com';
        testRequest.SM_Japan = 'test@test.com';
        testRequest.SM_Korea = 'test@test.com';
        testRequest.SM_SAP = 'test@test.com';
        */
        testRequest.AM_AMEC = objUser.Email;
        testRequest.AM_EMEA = objUser.Email;
        testRequest.AM_GC = objUser.Email;
        testRequest.AM_Japan = objUser.Email;
        testRequest.AM_Korea = objUser.Email;
        testRequest.AM_Korea_2 = objUser.Email;
        testRequest.AM_SAP = objUser.Email;
        testRequest.AM_SAP_2 = objUser.Email;
        testRequest.AM_SAP_3 = objUser.Email;
        testRequest.SM_AMEC = objUser.Email;
        testRequest.SM_EMEA = objUser.Email;
        testRequest.SM_GC = objUser.Email;
        testRequest.SM_Japan = objUser.Email;
        testRequest.SM_Korea = objUser.Email;
        testRequest.SM_SAP = objUser.Email;   
        testRequest.Background_of_This_Request = 'test';
        
        /*Added by Scarlett on 2015.04.29*/
        testRequest.NXP_Global_ID = 'test';
        testRequest.SP_Account_Name = 'Test';
        testRequest.SP_Name_2 = 'Test';
        testRequest.SP_House_Number = 'Test';
        testRequest.SP_Street = 'Test';
        testRequest.SP_City = 'Test';
        testRequest.SP_ZIP = 'Test';
        testRequest.SP_Country = 'Test';
        testRequest.SP_POBox = 'Test';
        testRequest.SP_Email = 'Test';
        testRequest.SP_VAT_Registration_Number = 'Test';
        
        testRequest.SH_Account_Name = 'Test';
        testRequest.SH_Name_2 = 'Test';
        testRequest.SH_House_Number = 'Test';
        testRequest.SH_Street = 'Test';
        testRequest.SH_City = 'Test';
        testRequest.SH_ZIP = 'Test';
        testRequest.SH_Country = 'Test';
        testRequest.SH_Region = 'Test';
        testRequest.SH_Transportation_Zone = 'Test';
        
        testRequest.BP_Account_Name = 'Test';
        testRequest.BP_Name_2 = 'Test';
        testRequest.BP_House_Number = 'Test';
        testRequest.BP_Street = 'Test';
        testRequest.BP_City = 'Test';
        testRequest.BP_ZIP = 'Test';
        testRequest.BP_Country = 'Test';
        testRequest.BP_Region = 'Test';
        testRequest.BP_POBox = 'Test';
        
        testRequest.PY_Account_Name = 'Test';
        testRequest.PY_Name_2 = 'Test';
        testRequest.PY_House_Number = 'Test';
        testRequest.PY_Street = 'Test';
        testRequest.PY_City = 'Test';
        testRequest.PY_ZIP = 'Test';
        testRequest.PY_Country = 'Test';
        testRequest.PY_Email = 'Test';
        testRequest.PY_POBox = 'Test';
        
        testRequest.Sales_Organization = 'test';
        testRequest.Sales_Office = 'test';
        testRequest.BP_Funloc = '100000';
        testRequest.PY_Funloc = '100000';
        testRequest.SMO_Indicator = 'test';
        testRequest.EDI_Customer = 'test';
        testRequest.Predict_Sales_Amount = 'test';
        testRequest.Business_Background = 'test';
        testRequest.Edited_Customer_Id = 'test';
        testRequest.Legal_Name_Invalid = false;
        testRequest.Parent_Account_GID_Invalid = false;
        testRequest.SM_Korea_2 = 'test';
        testRequest.SM_SAP_2 = 'test';
        testRequest.SM_SAP_3 = 'test';
        testRequest.rType = 'test';
        
        testRequest.SubmitRequest();
        testRequest.ConfirmRequest();
        testRequest.getCountryPicklist();
        testRequest.getFulfillment_ChannelPicklist();
        testRequest.getCustomer_CategoryPicklist();
        testRequest.getRolePicklist();
        testRequest.getTypePicklist();
        testRequest.getIndustry_SegmentPicklist();
        //testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.getRegionPicklist();
        string managerEmailAddress = 'abc.xyz@test.com';
        CMD_Request_Controller objCmdReq = new CMD_Request_Controller();
        objCmdReq.ValidateManagerEmail(managerEmailAddress);
    }
    
    /****Added by Scarlett****/
    /**Negative test**/
    /**
    invalid email address
    Account Name = null; House Number = null; Street = null; Street2 = null; Street3 = null; City = null; Country = null;
    Website = null; Fulfillment channel = null; Customer category = null; Role = null; Industry Segment = null; Email = null
    **/
    static testMethod void newParentRequestTest2()
    {
        //prepare Data
        fetchRecordType();
        //createCustomer();
        createHubFundation();
        createUser();
        createParentAccount();
        createCMDRequest();
        
        system.assert(objParentAccount.NXP_GID__c != null);
        
        PageReference testPage = Page.CMD;
        Test.setCurrentPage(testPage); 
        /*Added by Scarlett*/
        //ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testPage);
        ApexPages.currentPage().getParameters().put('src', 'sfdc');
        ApexPages.currentPage().getParameters().put('rt', 'New Parent Account Request');
        ApexPages.currentPage().getParameters().put('rid', 'test');
        ApexPages.currentPage().getParameters().put('uid', 'test');//user id
        ApexPages.currentPage().getParameters().put('ao', 'test');
        //ApexPages.currentPage().getParameters().put('aid', 'test');//Account Id
        ApexPages.currentPage().getParameters().put('pgid', objParentAccount.NXP_GID__c);//Parent Account GID
        ApexPages.currentPage().getParameters().put('re', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('aam', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('aeu', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('agc', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('ajp', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('akr', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('akr2', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('asa', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('asa2', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('asa3', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('sam', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('seu', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('sgc', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('sjp', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('skr', 'test.usertest.com');
        ApexPages.currentPage().getParameters().put('ssa', 'test.usertest.com');
        /*Added by Scarlett*/
        /*Added by Vinanthi*/
   
         ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCMDRequest);  
         
        CMD_Request_Controller testRequest = new CMD_Request_Controller(stdCtrl);
        testRequest.RequestType = 'New SFDC Parent Account';
        testRequest.Requester_Name = 'Test User';
        testRequest.Requester_Email = 'test@test.com';
        //testRequest.Account_Name = 'Test Parent Account';
        testRequest.Legal_Name = 'Test Parent Account Company';
        //testRequest.House_Number = 'House';
        //testRequest.Street = 'Test Street 1';
        //testRequest.Street_2 = 'Test Street 2';
        //testRequest.Street_3 = 'Test Street 3';
        //testRequest.City = 'Test Street 3';
        testRequest.State = 'Test State Province';
        testRequest.Postal_Code = 'Postal Zip';
        //testRequest.Country = 'Taiwan';
        //testRequest.Fulfillment_Channel = 'Direct';
        //testRequest.Customer_Category = 'Focus';
        //testRequest.Role = 'OEM';
        testRequest.Type = 'Customer';
        //testRequest.Industry_Segment = 'AA - Appliances';
        //testRequest.Website = 'www.test.com';
        //testRequest.Email = 'stan@test.com';
        testRequest.Telephone = '+1234567890';
        testRequest.Fax = '+1234567890';
        testRequest.AM_AMEC = 'testtest.com';
        testRequest.AM_EMEA = 'testtest.com';
        testRequest.AM_GC = 'testtest.com';
        testRequest.AM_Japan = 'testtest.com';
        testRequest.AM_Korea = 'testtest.com';
        testRequest.AM_Korea_2 = 'testtest.com';
        testRequest.AM_SAP = 'testtest.com';
        testRequest.AM_SAP_2 = 'testtest.com';
        testRequest.AM_SAP_3 = 'testtest.com';
        testRequest.SM_AMEC = 'testtest.com';
        testRequest.SM_EMEA = 'testtest.com';
        testRequest.SM_GC = 'testtest.com';
        testRequest.SM_Japan = 'testtest.com';
        testRequest.SM_Korea = 'testtest.com';
        testRequest.SM_SAP = 'testtest.com';
        testRequest.Background_of_This_Request = 'test';
              
        testRequest.SubmitRequest();
        testRequest.getCountryPicklist();
        testRequest.getFulfillment_ChannelPicklist();
        testRequest.getCustomer_CategoryPicklist();
        testRequest.getRolePicklist();
        testRequest.getTypePicklist();
        testRequest.getIndustry_SegmentPicklist();
        //testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.getRegionPicklist();
    }
    
     /****Added by Scarlett****/
    /**Negative test**/
    /**
    length of Account Name > 30; length of House Number > 30; length of Street > 30; length of Street2 > 30; 
    length of Street3 > 30; 
    **/
    static testMethod void newParentRequestTest3()
    {
        //prepare Data
        fetchRecordType();
        //createCustomer();
        createHubFundation();
        createUser();
        createParentAccount();
        createCMDRequest();
        
        system.assert(objParentAccount.NXP_GID__c != null);
        
        PageReference testPage = Page.CMD;
        Test.setCurrentPage(testPage); 
        /*Added by Scarlett*/
        ApexPages.currentPage().getParameters().put('src', 'sfdc');
        ApexPages.currentPage().getParameters().put('rt', 'New Parent Account Request');
        ApexPages.currentPage().getParameters().put('rid', 'test');
        ApexPages.currentPage().getParameters().put('uid', 'test');//user id
        ApexPages.currentPage().getParameters().put('ao', 'test');
        ApexPages.currentPage().getParameters().put('aid', objParentAccount.Id);
        ApexPages.currentPage().getParameters().put('pgid', objParentAccount.NXP_GID__c);//Parent Account GID
        ApexPages.currentPage().getParameters().put('re', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('aam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('aeu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('agc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ajp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa3', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('seu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sgc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sjp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('skr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ssa', 'test.user@test.com');
        /*Added by Scarlett*/
        /*Added by Vinanthi*/
        
         ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCMDRequest);  

        CMD_Request_Controller testRequest = new CMD_Request_Controller(stdCtrl);
        testRequest.RequestType = 'New SFDC Parent Account';
        testRequest.Requester_Name = 'Test User';
        testRequest.Requester_Email = 'test@test.com';
        testRequest.Account_Name = 'Test Parent Account Test Parent Account Test Parent Account Test Parent Account' + 
            'Test Parent Account Test Parent Account Test Parent Account';
        testRequest.Legal_Name = 'Test Parent Account Company';
        testRequest.House_Number = 'House House House House House House House House House House House';
        testRequest.Street = 'Test Street 1 Test Street 1 Test Street 1 Test Street 1 Test Street 1' + 
            'Test Street 1 Test Street 1 Test Street 1 Test Street 1';
        testRequest.Street_2 = 'Test Street 2 Test Street 2 Test Street 2 Test Street 2 Test Street 2' + 
            'Test Street 2 Test Street 2 Test Street 2 Test Street 2';
        testRequest.Street_3 = 'Test Street 3 Test Street 3 Test Street 3 Test Street 3 Test Street 3' + 
            'Test Street 3 Test Street 3 Test Street 3 Test Street 3';
        testRequest.City = 'Test Street 3';
        testRequest.State = 'Test State Province';
        testRequest.Postal_Code = 'Postal Zip';
        testRequest.Country = 'Taiwan';
        testRequest.Fulfillment_Channel = 'Direct';
        testRequest.Customer_Category = 'Focus';
        testRequest.Role = 'OEM';
        testRequest.Type = 'Customer';
        testRequest.Industry_Segment = 'AA - Automotive';
        testRequest.Website = 'www.test.com';
        testRequest.Email = 'stan@test.com';
        testRequest.Telephone = '+1234567890';
        testRequest.Fax = '+1234567890';
        testRequest.AM_AMEC = 'test@test.com';
        testRequest.AM_EMEA = 'test@test.com';
        testRequest.AM_GC = 'test@test.com';
        testRequest.AM_Japan = 'test@test.com';
        testRequest.AM_Korea = 'test@test.com';
        testRequest.AM_Korea_2 = 'test@test.com';
        testRequest.AM_SAP = 'test@test.com';
        testRequest.AM_SAP_2 = 'test@test.com';
        testRequest.AM_SAP_3 = 'test@test.com';
        testRequest.SM_AMEC = 'test@test.com';
        testRequest.SM_EMEA = 'test@test.com';
        testRequest.SM_GC = 'test@test.com';
        testRequest.SM_Japan = 'test@test.com';
        testRequest.SM_Korea = 'test@test.com';
        testRequest.SM_SAP = 'test@test.com';

        testRequest.SubmitRequest();
        testRequest.getCountryPicklist();
        testRequest.getFulfillment_ChannelPicklist();
        testRequest.getCustomer_CategoryPicklist();
        testRequest.getRolePicklist();
        testRequest.getTypePicklist();
        testRequest.getIndustry_SegmentPicklist();
        //testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.getRegionPicklist();
    }


    static testMethod void editParentRequestTest()
    {
        //prepare Data
        fetchRecordType();
        //createCustomer();
        createHubFundation();
        createUser();
        createParentAccount();
        createCMDRequest();
        
        User testUser = [SELECT Id, Email FROM User Limit 1];
        system.assert(testUser != null);
        
        /*Added by Scarlett*/
        //ApexPages.currentPage().getParameters().put('src', 'sfdc');
        ApexPages.currentPage().getParameters().put('rt', 'Edit SFDC Parent Account');
        ApexPages.currentPage().getParameters().put('rid', 'test');
        ApexPages.currentPage().getParameters().put('uid', 'test');//user id
        ApexPages.currentPage().getParameters().put('ao', 'test');
        ApexPages.currentPage().getParameters().put('aid', objParentAccount.Id);
        ApexPages.currentPage().getParameters().put('pgid', objParentAccount.NXP_GID__c);//Parent Account GID
        ApexPages.currentPage().getParameters().put('re', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('aam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('aeu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('agc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ajp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa3', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('seu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sgc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sjp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('skr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ssa', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('is', 'AA - Appliances');//Industry Segment = 'AA - Appliances'
        /*Added by Scarlett*/
        /*Added by Vinanthi*/
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCMDRequest);

        CMD_Request_Controller testRequest = new CMD_Request_Controller(stdCtrl);
        testRequest.RequestType = 'Edit SFDC Parent Account';
        testRequest.Requester_Name = 'Test User';
        //testRequest.Requester_Email = 'test@test.com';
        testRequest.Requester_Email = 'test.user@test.com';
        /**Add by Scarlett on May 05, 2015**/
        testRequest.New_Owner_Email = 'test.user@test.com';
        //testRequest.Account_Name = 'Test Parent Account';
        testRequest.Account_Name = objParentAccount.Name;
        //testRequest.Legal_Name = 'Test Parent Account Company';
        testRequest.Legal_Name = objParentAccount.Legal_Name__c;
        //testRequest.House_Number = 'House';
        testRequest.House_Number = objParentAccount.House_Number__c;
        //testRequest.Street = 'Test Street 1';
        testRequest.Street = objParentAccount.Street__c;
        //testRequest.Street_2 = 'Test Street 2';
        testRequest.Street_2 = objParentAccount.Street2__c;
        //testRequest.Street_3 = 'Test Street 3';
        testRequest.Street_3 = objParentAccount.Street3__c;
        //testRequest.City = 'Test Street 3';
        testRequest.City = objParentAccount.City__c;
        //testRequest.State = 'Test State Province';
        testRequest.State = objParentAccount.State_Province__c;
        //testRequest.Postal_Code = 'Postal Zip';
        testRequest.Postal_Code = objParentAccount.ZIP_Postal_Code__c;
        testRequest.Country = 'Taiwan';
        testRequest.Website = 'www.test.com';
        //testRequest.Email = 'stan@test.com';
        testRequest.Email = objParentAccount.Email__c;
        //testRequest.Telephone = '+1234567890';
        testRequest.Telephone = objParentAccount.Phone;
        //testRequest.Fax = '+1234567890';
        testRequest.Fax = objParentAccount.Fax;
        testRequest.Fulfillment_Channel = 'Direct';
        //testRequest.Customer_Category = 'Focus';
        testRequest.Customer_Category = objParentAccount.Customer_Category__c;
        testRequest.Role = 'OEM';
        testRequest.Type = 'Customer';
        testRequest.Industry_Segment = 'AA - Appliances';
        /*
        testRequest.AM_AMEC = 'test@test.com';
        testRequest.AM_EMEA = 'test@test.com';
        testRequest.AM_GC = 'test@test.com';
        testRequest.AM_Japan = 'test@test.com';
        testRequest.AM_Korea = 'test@test.com';
        testRequest.AM_Korea_2 = 'test@test.com';
        testRequest.AM_SAP = 'test@test.com';
        testRequest.AM_SAP_2 = 'test@test.com';
        testRequest.AM_SAP_3 = 'test@test.com';
        testRequest.SM_AMEC = 'test@test.com';
        testRequest.SM_EMEA = 'test@test.com';
        testRequest.SM_GC = 'test@test.com';
        testRequest.SM_Japan = 'test@test.com';
        testRequest.SM_Korea = 'test@test.com';
        testRequest.SM_SAP = 'test@test.com';   
        */
        testRequest.AM_AMEC = objUser.Email;
        testRequest.AM_EMEA = objUser.Email;
        testRequest.AM_GC = objUser.Email;
        testRequest.AM_Japan = objUser.Email;
        testRequest.AM_Korea = objUser.Email;
        testRequest.AM_Korea_2 = objUser.Email;
        testRequest.AM_SAP = objUser.Email;
        testRequest.AM_SAP_2 = objUser.Email;
        testRequest.AM_SAP_3 = objUser.Email;
        testRequest.SM_AMEC = objUser.Email;
        testRequest.SM_EMEA = objUser.Email;
        testRequest.SM_GC = objUser.Email;
        testRequest.SM_Japan = objUser.Email;
        testRequest.SM_Korea = objUser.Email;
        testRequest.SM_SAP = objUser.Email;   
        testRequest.Background_of_This_Request = 'test';
        testRequest.SubmitRequest();
    }

    static testMethod void newChildRequestTest()
    {  
        fetchRecordType();
        //createCustomer();
        createHubFundation();
        createUser();
        createParentAccount();
        createChildAccount();
        createCMDRequest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCMDRequest);
        CMD_Request_Controller testRequest = new CMD_Request_Controller(stdCtrl);
        testRequest.RequestType = 'New SFDC Child Account';
        testRequest.Requester_Name = 'Test User';
        testRequest.Requester_Email = 'test@test.com';
        testRequest.Account_Name = 'Test Child Account';
        testRequest.Legal_Name = 'Test Child Account Company';
        //testRequest.Parent_Account_Name = 'Test Parent Account';
        testRequest.Parent_Account_GID = 'Test Parent Account Company';
        testRequest.House_Number = 'House';
        testRequest.Street = 'Test Street 1';
        testRequest.Street_2 = 'Test Street 2';
        testRequest.Street_3 = 'Test Street 3';
        testRequest.City = 'Test Street 3';
        testRequest.State = 'Test State Province';
        testRequest.Postal_Code = 'Postal Zip';
        testRequest.Country = 'Taiwan';
        testRequest.Website = 'www.test.com';
        testRequest.Email = 'stan@test.com';
        testRequest.Telephone = '+1234567890';
        testRequest.Fax = '+1234567890';
        testRequest.Fulfillment_Channel = 'Direct';
        testRequest.Customer_Category = 'Focus';
        testRequest.Role = 'OEM';
        testRequest.Type = 'Customer';
        testRequest.Industry_Segment = 'AA - Automotive';
        testRequest.Industry_Sub_Segment = 'A1 - Major Home Appliances';
        testRequest.SubmitRequest();
        testRequest.Industry_Segment = 'AA - Automotive';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'BB - C&I';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'CC - Computing';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'DD - Distribution';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'EE - EMS';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'FF - Infrastructure';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'GG - Mobile';
        testRequest.getIndustry_Sub_SegmentPicklist();
         testRequest.Industry_Segment = 'HH - Payment';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'II - Tagging & Authentication';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'JJ - Wireless Infrastructure and RF';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'KK - Mobile';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'LL - EMS';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'MM - Distribution';
        testRequest.getIndustry_Sub_SegmentPicklist();
            testRequest.Industry_Segment = 'NN - Healthcare';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'OO - Industrial';
        testRequest.getIndustry_Sub_SegmentPicklist();
          testRequest.getRegionPicklist();
         testRequest.Region = 'AP - GC';
         testRequest.getSales_AreaPicklist();
          testRequest.Region = 'AP - SAP';
         testRequest.getSales_AreaPicklist();
         testRequest.Region = 'AM - AMEC'; 
         testRequest.getSales_AreaPicklist();
         testRequest.Region = 'EU - EMEA';
         testRequest.getSales_AreaPicklist();
        testRequest.Region = 'AP - JAPAN';
         testRequest.getSales_AreaPicklist(); 
         testRequest.Region = 'AP - KOREA';
         testRequest.getSales_AreaPicklist();
        testRequest.SubmitSAP();
        testRequest.ConfirmRequest();       
    }
    
    
    static testMethod void newChildRequestTest1()
    {  
        fetchRecordType();
        //createCustomer();
        createHubFundation();
        createUser();
        createParentAccount();
        createChildAccount();
        createCMDRequest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCMDRequest);
        CMD_Request_Controller testRequest = new CMD_Request_Controller(stdCtrl);
        testRequest.RequestType = 'New SFDC Child Account';
        testRequest.Requester_Name = 'Test User';
        testRequest.Requester_Email = 'test@test.com';
        testRequest.Account_Name = 'Test Child Account';
        testRequest.Legal_Name = 'Test Child Account Company';
        //testRequest.Parent_Account_Name = 'Test Parent Account';
        testRequest.Parent_Account_GID = 'Test Parent Account Company';
        testRequest.House_Number = 'House';
        testRequest.Street = 'Test Street 1';
        testRequest.Street_2 = 'Test Street 2';
        testRequest.Street_3 = 'Test Street 3';
        testRequest.City = 'Test Street 3';
        testRequest.State = 'Test State Province';
        testRequest.Postal_Code = 'Postal Zip';
        testRequest.Country = 'Taiwan';
        testRequest.Website = 'www.test.com';
        testRequest.Email = 'stan@test.com';
        testRequest.Telephone = '+1234567890';
        testRequest.Fax = '+1234567890';
        testRequest.Fulfillment_Channel = 'Direct';
        testRequest.Customer_Category = 'Focus';
        testRequest.Role = 'OEM';
        testRequest.Type = 'Customer';
        testRequest.Industry_Segment = 'AA - Automotive';
        testRequest.Industry_Sub_Segment = '';
        testRequest.SubmitRequest();        
      
    }
    
    /***Added by Scarlett***/
    /***Create Child account edit request***/
    static testMethod void editChildRequestTest(){
        //prepare Data
        fetchRecordType();
        //createCustomer();
        createHubFundation();
        createUser();
        createParentAccount();
        createChildAccount();
        createCMDRequest();
        
        ApexPages.currentPage().getParameters().put('src', 'sfdc');
        ApexPages.currentPage().getParameters().put('rt', 'Edit SFDC Child Account');//Request Type
        ApexPages.currentPage().getParameters().put('rid', 'test');
        ApexPages.currentPage().getParameters().put('uid', objUser.Id);//user id
        ApexPages.currentPage().getParameters().put('ao', 'test');
        ApexPages.currentPage().getParameters().put('aid', objChildAccount.Id);//Edited Account
        ApexPages.currentPage().getParameters().put('pgid', objParentAccount.NXP_GID__c);//Parent Account GID
        ApexPages.currentPage().getParameters().put('pid', objChildAccount.ParentId);//ParentId
        ApexPages.currentPage().getParameters().put('duns', objChildAccount.DUNS_Number__c);//DUNS number
        ApexPages.currentPage().getParameters().put('reg', 'Americas');//Region
        /*
        ApexPages.currentPage().getParameters().put('re', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('aam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('aeu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('agc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ajp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa3', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('seu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sgc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sjp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('skr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ssa', 'test.user@test.com');
        */
         ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCMDRequest);       
        CMD_Request_Controller testRequest = new CMD_Request_Controller(stdCtrl);
        testRequest.RequestType = 'Edit SFDC Child Account';
        testRequest.Requester_Name = 'Test User';
        testRequest.Requester_Email = 'test.user@test.com';
        testRequest.Account_Name = objChildAccount.Name;
        testRequest.Legal_Name = objChildAccount.Legal_Name__c;
        testRequest.House_Number = 'House';
        testRequest.Street = 'Test Street 1';
        testRequest.Street_2 = 'Test Street 2';
        testRequest.Street_3 = 'Test Street 3';
        testRequest.City = 'Test Street 3';
        testRequest.State = 'Test State Province';
        testRequest.Postal_Code = 'Postal Zip';
        testRequest.Country = 'Taiwan';
        testRequest.Fulfillment_Channel = 'Direct';
        testRequest.Customer_Category = 'Focus';
        testRequest.Role = 'OEM';
        testRequest.Type = 'Customer';
        testRequest.Industry_Segment = 'AA - Appliances';
        testRequest.Website = 'www.test.com';
        testRequest.Email = 'stan@test.com';
        testRequest.Telephone = '+1234567890';
        testRequest.Fax = '+1234567890';
        /*
        testRequest.AM_AMEC = 'test@test.com';
        testRequest.AM_EMEA = 'test@test.com';
        testRequest.AM_GC = 'test@test.com';
        testRequest.AM_Japan = 'test@test.com';
        testRequest.AM_Korea = 'test@test.com';
        testRequest.AM_Korea_2 = 'test@test.com';
        testRequest.AM_SAP = 'test@test.com';
        testRequest.AM_SAP_2 = 'test@test.com';
        testRequest.AM_SAP_3 = 'test@test.com';
        testRequest.SM_AMEC = 'test@test.com';
        testRequest.SM_EMEA = 'test@test.com';
        testRequest.SM_GC = 'test@test.com';
        testRequest.SM_Japan = 'test@test.com';
        testRequest.SM_Korea = 'test@test.com';
        testRequest.SM_SAP = 'test@test.com';
        */
        testRequest.AM_AMEC = objUser.Email;
        testRequest.AM_EMEA = objUser.Email;
        testRequest.AM_GC = objUser.Email;
        testRequest.AM_Japan = objUser.Email;
        testRequest.AM_Korea = objUser.Email;
        testRequest.AM_Korea_2 = objUser.Email;
        testRequest.AM_SAP = objUser.Email;
        testRequest.AM_SAP_2 = objUser.Email;
        testRequest.AM_SAP_3 = objUser.Email;
        testRequest.SM_AMEC = objUser.Email;
        testRequest.SM_EMEA = objUser.Email;
        testRequest.SM_GC = objUser.Email;
        testRequest.SM_Japan = objUser.Email;
        testRequest.SM_Korea = objUser.Email;
        testRequest.SM_SAP = objUser.Email;   

        testRequest.Background_of_This_Request = 'test';
        testRequest.Industry_Segment = 'AA - Appliances';
        testRequest.Industry_Sub_Segment = 'A1 - Major Home Appliances';
        testRequest.New_Owner_Email = objUser.Email;
        
        testRequest.SubmitRequest();
        
        testRequest.Industry_Segment = 'AA - Appliances';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'BB - Energy Management';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'CC - Home/Building Automation (HABA)';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'DD - Automotive & Transportation';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'EE - Consumer';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'FF - Computing';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'GG - Secure Transactions';
        testRequest.getIndustry_Sub_SegmentPicklist();
         testRequest.Industry_Segment = 'HH - Secure Identity';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'II - Tagging & Authentication';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'KK - Mobile';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'LL - EMS';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'MM - Distribution';
        testRequest.getIndustry_Sub_SegmentPicklist();
            testRequest.Industry_Segment = 'NN - Healthcare';
        testRequest.getIndustry_Sub_SegmentPicklist();
        testRequest.Industry_Segment = 'OO - Industrial';
        testRequest.getIndustry_Sub_SegmentPicklist();
          testRequest.getRegionPicklist();
         testRequest.Region = 'AP - GC';
         testRequest.getSales_AreaPicklist();
          testRequest.Region = 'AP - SAP';
         testRequest.getSales_AreaPicklist();
         testRequest.Region = 'AM - AMEC'; 
         testRequest.getSales_AreaPicklist();
         testRequest.Region = 'EU - EMEA';
         testRequest.getSales_AreaPicklist();
        testRequest.Region = 'AP - JAPAN';
         testRequest.getSales_AreaPicklist(); 
         testRequest.Region = 'AP - KOREA';
         testRequest.getSales_AreaPicklist();
        //testRequest.SubmitSAP();
        testRequest.ConfirmRequest();  
    }
    
    /***Edti child account without Industry Segment and Industry Sub Segment***/
    static testMethod void editChildRequestTest2(){
        //prepare Data
        fetchRecordType();
        //createCustomer();
        createHubFundation();
        createUser();
        createParentAccount();
        createChildAccount();
        createCMDRequest();
        
        ApexPages.currentPage().getParameters().put('src', 'sfdc');
        ApexPages.currentPage().getParameters().put('rt', 'Edit SFDC Child Account');//Request Type
        ApexPages.currentPage().getParameters().put('rid', 'test');
        ApexPages.currentPage().getParameters().put('uid', objUser.Id);//user id
        ApexPages.currentPage().getParameters().put('ao', 'test');
        ApexPages.currentPage().getParameters().put('aid', objChildAccount.Id);//Edited Account
        ApexPages.currentPage().getParameters().put('pgid', objParentAccount.NXP_GID__c);//Parent Account GID
        ApexPages.currentPage().getParameters().put('pid', objChildAccount.ParentId);//ParentId
        ApexPages.currentPage().getParameters().put('duns', objChildAccount.DUNS_Number__c);//DUNS number
        ApexPages.currentPage().getParameters().put('reg', 'Americas');//Region
        ApexPages.currentPage().getParameters().put('reg', 'Americas');//Industry Segment
        /*
        ApexPages.currentPage().getParameters().put('re', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('aam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('aeu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('agc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ajp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('akr2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa2', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('asa3', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sam', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('seu', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sgc', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('sjp', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('skr', 'test.user@test.com');
        ApexPages.currentPage().getParameters().put('ssa', 'test.user@test.com');
        */
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objCMDRequest);       
        CMD_Request_Controller testRequest = new CMD_Request_Controller(stdCtrl);
        testRequest.RequestType = 'New SFDC Child Account';
        testRequest.Requester_Name = 'Test User';
        testRequest.Requester_Email = 'test.user@test.com';
        testRequest.Account_Name = objChildAccount.Name;
        testRequest.Legal_Name = objChildAccount.Legal_Name__c;
        testRequest.House_Number = 'House';
        testRequest.Street = 'Test Street 1';
        testRequest.Street_2 = 'Test Street 2';
        testRequest.Street_3 = 'Test Street 3';
        testRequest.City = 'Test Street 3';
        testRequest.State = 'Test State Province';
        testRequest.Postal_Code = 'Postal Zip';
        testRequest.Country = 'Taiwan';
        testRequest.Fulfillment_Channel = 'Direct';
        testRequest.Customer_Category = 'Focus';
        testRequest.Role = 'OEM';
        testRequest.Type = 'Customer';
        testRequest.Industry_Segment = 'AA - Appliances';
        testRequest.Website = 'www.test.com';
        testRequest.Email = 'stan@test.com';
        testRequest.Telephone = '+1234567890';
        testRequest.Fax = '+1234567890';
        testRequest.AM_AMEC = objUser.Email;
        testRequest.AM_EMEA = objUser.Email;
        testRequest.AM_GC = objUser.Email;
        testRequest.AM_Japan = objUser.Email;
        testRequest.AM_Korea = objUser.Email;
        testRequest.AM_Korea_2 = objUser.Email;
        testRequest.AM_SAP = objUser.Email;
        testRequest.AM_SAP_2 = objUser.Email;
        testRequest.AM_SAP_3 = objUser.Email;
        testRequest.SM_AMEC = objUser.Email;
        testRequest.SM_EMEA = objUser.Email;
        testRequest.SM_GC = objUser.Email;
        testRequest.SM_Japan = objUser.Email;
        testRequest.SM_Korea = objUser.Email;
        testRequest.SM_SAP = objUser.Email;   

        testRequest.Background_of_This_Request = 'test';
        //testRequest.Industry_Segment = 'AA - Appliances';
        //testRequest.Industry_Sub_Segment = 'A1 - Major Home Appliances';
        testRequest.New_Owner_Email = objUser.Email;
        testRequest.New_Owner_Name = objUser.Username;
        
        
        testRequest.New_Owner_Email = null;
        
        
        testRequest.SubmitRequest();
        //testRequest.SubmitSAP();
        testRequest.ConfirmRequest(); 
        CMD_Request_Controller.ConvertSubSegmentCode('test');
        testRequest.EmailCMD();
        //testRequest.Refresh();
        String str = CMD_Request_Controller.ConvertRegionCode('EMEA');
        String str1 = CMD_Request_Controller.ConvertRegionCode('Japan');
        String str2 = CMD_Request_Controller.ConvertRegionCode('Korea');
        String str3 = CMD_Request_Controller.ConvertRegionCode('Greater China');
        String str4 = CMD_Request_Controller.ConvertRegionCode('South Asia Pacific');
        String str5 = CMD_Request_Controller.ConvertRegionCode('test'); 
        
        List<CMD_Request__c> cmdList = new List<CMD_Request__c>();
        
            CMD_Request__c objCMDRequest1 = new CMD_Request__c(
            RecordTypeId = New_SFDC_Parent_Account.Id,
            Requester_SFDC__c = objUser.Id,
            Request_Status__c = 'Submitted',
            Requester_Email__c = objUser.Email,
            country__c='India',
            State_Province__c='kerala',
            Request_Type__c = 'SFDC New Parent Account'
        );
        insert objCMDRequest1;
        cmdList.add(objCMDRequest1);
        
            CMD_Request__c objCMDRequest2 = new CMD_Request__c(
                RecordTypeId = New_SFDC_Parent_Account.Id,
                Requester_SFDC__c = objUser.Id,
                Request_Status__c = 'Submitted',
                Requester_Email__c = objUser.Email,
                country__c='',
                State_Province__c='kerala',
                Request_Type__c = 'SFDC New Parent Account'
            );
        insert objCMDRequest2;
        cmdList.add(objCMDRequest2);
    
    }

}