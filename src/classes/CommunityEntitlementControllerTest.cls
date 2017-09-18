/***************************************************************************************************
@Created By :      Avichal Kumar
@Created Date:     29 jun 2015
@Description:      Test Class for CommunityEntitlementController of Atfer update trigger on case to update related entitlement
**********************************************************************
@Last Modified By   : Shridevi Badiger
@Last Modified Date : 25-Aug-2017
@Description        : As part of SIR 828-Increased the code coverage of CommunityEntitlementController
*******************************************************************************************************/
@isTest
private class CommunityEntitlementControllerTest 
{
    private final static String CASE_TSCOMMUNITY = 'TS_COMMUNITY'; 
    private final static String CHILD_ACCOUNT = 'Child_Account';
    private final static String PARENT_ACCOUNT = 'Parent_Account';    
    private static final integer RECORD_COUNT = 17; //As there are total 17 Service/Account Manager
    
    private Static RecordType tsCommunity;
    private Static RecordType childAccount;
    private static RecordType parentAccount;
    
    //To fetch the record type
    private static void fetchRecordTypes()
    {        
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType Where IsActive=true and  
                              ((SobjectType = 'Case' and (DeveloperName =: CASE_TSCOMMUNITY)) or
                               (SobjectType = 'Account' and (DeveloperName =: Child_Account or DeveloperName =: Parent_Account))                              
                              ) Limit 3])
            
        if(rt.DeveloperName == CASE_TSCOMMUNITY)
        {
            tsCommunity = rt;
        }
        else if(rt.DeveloperName == CHILD_ACCOUNT)
        {
            childAccount = rt; 
        }
        else if(rt.DeveloperName == PARENT_ACCOUNT)
        {
            parentAccount = rt;
        } 
    }   
       
    //Create user records to assign to account owner
    private Static List<User> createManagerUsers() 
    {
        List<User> lstUsers = new List<User>();
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        system.assert(objProfile.Id != null);
        
        User objUser;
        for(integer i=1; i < RECORD_COUNT; i++)
        {
            objUser = new User(alias = 'nUser' + i, email= 'testing' + i +'@test.com', emailencodingkey='UTF-8', lastname='test'+i,languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', username= 'prakhartest' + datetime.now().millisecond() + i +'@test.com' );
            lstUsers.add(objUser);                                          
        }
        return lstUsers;
    }
    
    //Method to create a 'NXP Community' Parent Account
    private Static Account objAccount;    
    private static Account createNxpCommunityAccountRecord()
    {
        objAccount = new Account(RecordTypeID= parentAccount.ID,
                                 Name = 'NXP Community', Customer_Category__c= 'Longtail');
        return  objAccount;
    }
    
    //Method to create a 'Other' Parent Account    
    private static Account createOtherAccountRecord()
    {
        objAccount = new Account(RecordTypeID= parentAccount.ID,
                                 Name = 'Other', Customer_Category__c= 'Longtail');
        return  objAccount;
    }
    
    //Method to create a TechService Child Account
    private static Account createTechServiceAccountRecord(ID parentAccountId)
    {
        objAccount = new Account(RecordTypeID= childAccount.ID,ParentId = parentAccountId,  
                                 Name = 'Technical Services', Region__c = 'Japan',
                                 Sales_Area__c = 'Japan ID', Industry_Segment__c = 'Mobile',
                                 Country__c = 'Austria');
        return objAccount;    
    }
    
    //Method to create Public Domain object records
    private static List<Public_Domain__c> createPublicDomainRecords()
    {
        List<Public_Domain__c> lstPublicDomains = new List<Public_Domain__c>();
        
        lstPublicDomains.add(new Public_Domain__c(Domain_Name__c='gmail.com'));
        lstPublicDomains.add(new Public_Domain__c(Domain_Name__c='yahoo.com'));
        lstPublicDomains.add(new Public_Domain__c(Domain_Name__c='hotmail.com'));
        
        return lstPublicDomains;
    } 
     
     private static Account createParentAccount()
    {
        RecordType objRecordType = [Select Id, DeveloperName From RecordType Where IsActive=true and  
                                  SobjectType = 'Account' and DeveloperName ='Parent_Account' Limit 1];
            //Method to create a Parent Account
           
            Account objParentAccount = new Account(RecordTypeID= objRecordType.ID,
                                                    Name = 'Bosch', Customer_Category__c= 'Longtail');
            return  objParentAccount;
    }
     private static Entitlement createEntitlement()
     {
          Account objParentAccount = createParentAccount();
          insert objParentAccount;
          system.assert(objParentAccount.id!=null);
          Entitlement objEntitlement = new Entitlement(AccountId=objParentAccount.id, Name='testingname');
          return objEntitlement; 
     }
   
    
    
   
    static testmethod void CommunityEntitlementControllerTestTest1()
    {
        //Prepare the test data
        fetchRecordTypes();
                
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        }
        
        List<Account> lstParentAccount = new List<Account>();
        //Insert parent account with all Service/Account manager to cover the code
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, ownerId= lstUsers[0].id,Name = 'Parent1',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Account_Manager_SAP_3__c = lstUsers.get(0).ID));
        
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id,ownerId= lstUsers[0].id, Name = 'Parent2',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Service_Manager_AMEC__c = lstUsers.get(1).ID));
        
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
        
        //assert record ids        
        for(Account objParentAcc:lstParentAccount)
        {
            system.assert(objParentAcc.Id != null);
        }
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<RECORD_COUNT;i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(0).Id, 
                                             Region__c='TestRegion', Sales_Area__c ='TestArea', Industry_Segment__c = 'TestSegment', 
                                             Sub_Segment__c='TestSubSegment', Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
        
        //assert record ids        
        for(Account objChildAccount1:lstChildAccount)
        {
            system.assert(objChildAccount1.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
            lstContacts.add(new Contact(AccountID=lstChildAccount.get(i-1).Id, FirstName = 'test1', LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com'));  
        }   
        
        if(lstContacts.size() > 0)
        {
            Insert lstContacts;
        }
        
        //assert record ids        
        for(Contact objContact1:lstContacts)
        {
            system.assert(objContact1.Id != null);
        }
        
        Test.StartTest();
        
        Entitlement objEntitlement = createEntitlement();
        
        objEntitlement.StartDate=date.today();
        objEntitlement.Total_Number_of_Hours__c = 20.00;
        objEntitlement.Used_number_of_Hours__c = 4.00;
        objEntitlement.Remaining_Hours__c = 0.00;
        insert objEntitlement;
        
        system.assert(objEntitlement.id!=null);
        List<Entitlement> lstEntitlement =[select Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
        
        List<Case> lstCases = new List<Case>();
        
        
        
        
        
           lstCases.add(new Case(RecordTypeID = tsCommunity.Id,contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test'+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Web_Region__c = 'Test_region',Hours_spent_by_Support_person__c = 5.00,EntitlementId = objEntitlement.id,suppliedEmail='test'+'@test.com',origin = 'Web',Case_Owner_Name__c='test')); 
        
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        
       
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }  
         for(Case objCase:lstCases)
        {
            objcase.Hours_spent_by_Support_person__c = 14.00;
        }
        
        if(lstCases.size() > 0)
        {
            update lstCases;
        }
        
        
        
        lstCases = [Select Id, OwnerID,AccountID From Case];      
        
        //assert Account ids        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
        Test.StopTest();
        
    
    }
    static testmethod void CommunityEntitlementControllerTestTest2()
    {
        //Prepare the test data
        fetchRecordTypes();
                
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        }
        
        List<Account> lstParentAccount = new List<Account>();
        //Insert parent account with all Service/Account manager to cover the code
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, ownerId= lstUsers[0].id,Name = 'Parent1',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Account_Manager_SAP_3__c = lstUsers.get(0).ID));
        
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id,ownerId= lstUsers[0].id, Name = 'Parent2',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Service_Manager_AMEC__c = lstUsers.get(1).ID));
        
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
        
        //assert record ids        
        for(Account objParentAcc:lstParentAccount)
        {
            system.assert(objParentAcc.Id != null);
        }
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<RECORD_COUNT;i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(0).Id, 
                                             Region__c='TestRegion', Sales_Area__c ='TestArea', Industry_Segment__c = 'TestSegment', 
                                             Sub_Segment__c='TestSubSegment', Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
        
        //assert record ids        
        for(Account objChildAccount1:lstChildAccount)
        {
            system.assert(objChildAccount1.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
            lstContacts.add(new Contact(AccountID=lstChildAccount.get(i-1).Id, FirstName = 'test1', LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com'));  
        }   
        
        if(lstContacts.size() > 0)
        {
            Insert lstContacts;
        }
        
        //assert record ids        
        for(Contact objContact1:lstContacts)
        {
            system.assert(objContact1.Id != null);
        }
        
        Test.StartTest();
        
        Entitlement objEntitlement = createEntitlement();
        
        objEntitlement.StartDate=date.today();
        objEntitlement.Total_Number_of_Hours__c = 20.00;
        objEntitlement.Used_number_of_Hours__c = 0.00;
        objEntitlement.Remaining_Hours__c = 0.00;
        insert objEntitlement;
        
        system.assert(objEntitlement.id!=null);
        List<Entitlement> lstEntitlement =[select Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
        
        List<Case> lstCases = new List<Case>();
        
        
        
        
        
           lstCases.add(new Case(RecordTypeID = tsCommunity.Id,contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test'+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Web_Region__c = 'Test_region',Hours_spent_by_Support_person__c = 0.00,EntitlementId = objEntitlement.id,suppliedEmail='test'+'@test.com',origin = 'Web',Case_Owner_Name__c='test')); 
        
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        
       
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }  
         for(Case objCase:lstCases)
        {
            objcase.Hours_spent_by_Support_person__c = 14.00;
        }
        
        if(lstCases.size() > 0)
        {
            update lstCases;
        }
        
        
        
        lstCases = [Select Id, OwnerID,AccountID From Case];      
        
        //assert Account ids        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
        Test.StopTest();
        
    
    }
    static testmethod void CommunityEntitlementControllerTestTest4()
    {
        //Prepare the test data
        fetchRecordTypes();
                
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        }
        
        List<Account> lstParentAccount = new List<Account>();
        //Insert parent account with all Service/Account manager to cover the code
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, ownerId= lstUsers[0].id,Name = 'Parent1',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Account_Manager_SAP_3__c = lstUsers.get(0).ID));
        
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id,ownerId= lstUsers[0].id, Name = 'Parent2',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Service_Manager_AMEC__c = lstUsers.get(1).ID));
        
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
        
        //assert record ids        
        for(Account objParentAcc:lstParentAccount)
        {
            system.assert(objParentAcc.Id != null);
        }
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<RECORD_COUNT;i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(0).Id, 
                                             Region__c='TestRegion', Sales_Area__c ='TestArea', Industry_Segment__c = 'TestSegment', 
                                             Sub_Segment__c='TestSubSegment', Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
        
        //assert record ids        
        for(Account objChildAccount1:lstChildAccount)
        {
            system.assert(objChildAccount1.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
            lstContacts.add(new Contact(AccountID=lstChildAccount.get(i-1).Id, FirstName = 'test1', LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com'));  
        }   
        
        if(lstContacts.size() > 0)
        {
            Insert lstContacts;
        }
        
        //assert record ids        
        for(Contact objContact1:lstContacts)
        {
            system.assert(objContact1.Id != null);
        }
        
        Test.StartTest();
        
        Entitlement objEntitlement = createEntitlement();
        
        objEntitlement.StartDate=date.today();
        objEntitlement.Total_Number_of_Hours__c = 20.00;
        objEntitlement.Used_number_of_Hours__c = 15.00;
        objEntitlement.Remaining_Hours__c = 22.00;
        insert objEntitlement;
        
        system.assert(objEntitlement.id!=null);
        List<Entitlement> lstEntitlement =[select Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
        
        List<Case> lstCases = new List<Case>();
        
        
        
        
        
           lstCases.add(new Case(RecordTypeID = tsCommunity.Id,contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test'+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Web_Region__c = 'Test_region',Hours_spent_by_Support_person__c = 10.00,EntitlementId = objEntitlement.id,suppliedEmail='test'+'@test.com',origin = 'Web',Case_Owner_Name__c='test')); 
        
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        
       
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }  
         for(Case objCase:lstCases)
        {
            objcase.Hours_spent_by_Support_person__c = 2.00;
        }
        
        if(lstCases.size() > 0)
        {
            update lstCases;
        }
        
        
        
        lstCases = [Select Id, OwnerID,AccountID From Case];      
        
        //assert Account ids        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
        Test.StopTest();
        
    
    }
    static testmethod void CommunityEntitlementControllerTestTest3()
    {
        //Prepare the test data
        fetchRecordTypes();
                
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        }
        
        List<Account> lstParentAccount = new List<Account>();
        //Insert parent account with all Service/Account manager to cover the code
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, ownerId= lstUsers[0].id,Name = 'Parent1',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Account_Manager_SAP_3__c = lstUsers.get(0).ID));
        
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id,ownerId= lstUsers[0].id, Name = 'Parent2',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Service_Manager_AMEC__c = lstUsers.get(1).ID));
        
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
        
        //assert record ids        
        for(Account objParentAcc:lstParentAccount)
        {
            system.assert(objParentAcc.Id != null);
        }
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<RECORD_COUNT;i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(0).Id, 
                                             Region__c='TestRegion', Sales_Area__c ='TestArea', Industry_Segment__c = 'TestSegment', 
                                             Sub_Segment__c='TestSubSegment', Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
        
        //assert record ids        
        for(Account objChildAccount1:lstChildAccount)
        {
            system.assert(objChildAccount1.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
            lstContacts.add(new Contact(AccountID=lstChildAccount.get(i-1).Id, FirstName = 'test1', LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com'));  
        }   
        
        if(lstContacts.size() > 0)
        {
            Insert lstContacts;
        }
        
        //assert record ids        
        for(Contact objContact1:lstContacts)
        {
            system.assert(objContact1.Id != null);
        }
        
        Test.StartTest();
        
        Entitlement objEntitlement = createEntitlement();
        
        objEntitlement.StartDate=date.today();
        objEntitlement.Total_Number_of_Hours__c = 20.00;
        objEntitlement.Used_number_of_Hours__c = null;
        objEntitlement.Remaining_Hours__c = 20.00;
        insert objEntitlement;
        objEntitlement.Remaining_Hours__c = 22.00;
        update objEntitlement;
        system.assert(objEntitlement.id!=null);
        List<Entitlement> lstEntitlement =[select Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
        
        List<Case> lstCases = new List<Case>();
        
        
        
        
        
           lstCases.add(new Case(RecordTypeID = tsCommunity.Id,contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test'+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Web_Region__c = 'Test_region',Hours_spent_by_Support_person__c = 10.00,EntitlementId = objEntitlement.id,suppliedEmail='test'+'@test.com',origin = 'Web',Case_Owner_Name__c='test')); 
        
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        
       
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }  
         for(Case objCase:lstCases)
        {
            objcase.Hours_spent_by_Support_person__c = 5.00;
        }
        
        if(lstCases.size() > 0)
        {
            update lstCases;
        }
        
        
        
        lstCases = [Select Id, OwnerID,AccountID From Case];      
        
        //assert Account ids        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
         Test.StopTest();
       
        
        
        
    
    }
    static testmethod void CommunityEntitlementControllerTestTest5()
    {
        //Prepare the test data
        fetchRecordTypes();
                
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        }
        
        List<Account> lstParentAccount = new List<Account>();
        //Insert parent account with all Service/Account manager to cover the code
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, ownerId= lstUsers[0].id,Name = 'Parent1',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Account_Manager_SAP_3__c = lstUsers.get(0).ID));
        
        lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id,ownerId= lstUsers[0].id, Name = 'Parent2',
                                         Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                         Service_Manager_AMEC__c = lstUsers.get(1).ID));
        
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
        
        //assert record ids        
        for(Account objParentAcc:lstParentAccount)
        {
            system.assert(objParentAcc.Id != null);
        }
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<RECORD_COUNT;i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(0).Id, 
                                             Region__c='TestRegion', Sales_Area__c ='TestArea', Industry_Segment__c = 'TestSegment', 
                                             Sub_Segment__c='TestSubSegment', Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
        
        //assert record ids        
        for(Account objChildAccount1:lstChildAccount)
        {
            system.assert(objChildAccount1.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
            lstContacts.add(new Contact(AccountID=lstChildAccount.get(i-1).Id, FirstName = 'test1', LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com'));  
        }   
        
        if(lstContacts.size() > 0)
        {
            Insert lstContacts;
        }
        
        //assert record ids        
        for(Contact objContact1:lstContacts)
        {
            system.assert(objContact1.Id != null);
        }
        
        Test.StartTest();
        
        Entitlement objEntitlement = createEntitlement();
        
        objEntitlement.StartDate=date.today();
        objEntitlement.Total_Number_of_Hours__c = 20.00;
        objEntitlement.Used_number_of_Hours__c = 0.00;
        objEntitlement.Remaining_Hours__c = 23.00;
        insert objEntitlement;
        
        system.assert(objEntitlement.id!=null);
        List<Entitlement> lstEntitlement =[select Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
        
        List<Case> lstCases = new List<Case>();
        
        
        
        
        
           lstCases.add(new Case(RecordTypeID = tsCommunity.Id,contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test'+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Web_Region__c = 'Test_region',Hours_spent_by_Support_person__c = 30.00,EntitlementId = objEntitlement.id,suppliedEmail='test'+'@test.com',origin = 'Web',Case_Owner_Name__c='test')); 
        
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        
       
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }  
         for(Case objCase:lstCases)
        {
            objcase.Hours_spent_by_Support_person__c = 25.00;
        }
        
        if(lstCases.size() > 0)
        {
            update lstCases;
        }
        
        
        
        lstCases = [Select Id, OwnerID,AccountID From Case];      
        
        //assert Account ids        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
       
          Test.StopTest();
          objEntitlement.Total_Number_of_Hours__c = 20.00;
          objEntitlement.Used_number_of_Hours__c = NULL;
      
          update objEntitlement;
         
          lstCases[0].Hours_spent_by_Support_person__c=50;
          update  lstCases;
       
    
    }
}