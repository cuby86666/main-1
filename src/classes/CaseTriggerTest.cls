/*********************************************************************************************
@Created By :       Prakhar Gupta
@Created Date :     30 Dec 2014
Description :      Test Class for triggers on Case object
********************************************************************************************/

/***************************************************************************************************
@Modified By :      Amrutha R
@Modified Date:     03 Mar 2015
@Description:       Test class for CaseTrigger class.
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date:     07 Apr 2016
@Description:       Cleanup of case assignment rules
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date:     27 jul 2016
@Description:       Entitlemet Based Routing
**********************************************************************************************************/

@isTest
private class CaseTriggerTest 
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
            objUser = new User(alias = 'nUser' + i, email= 'testing' + i +'@test.com', emailencodingkey='UTF-8',firstname='Name'+i, lastname='test'+i,languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', username= 'prakhartest' + datetime.now().millisecond() + i +'@test.com');
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
   
    
    /***************************************************************************      
      Case -Insert Case from WebForm->contact assigned with case is under child account->
        Case assigned to account owner
    ****************************************************************************/
   
    static testmethod void CaseTriggerTest1() 
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
        
        List<Case> lstCases = new List<Case>();
        
        
        
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
           lstCases.add(new Case(RecordTypeID = tsCommunity.Id,contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test'+i+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Web_Region__c = 'Test_region',  origin = 'Web',Case_Owner_Name__c='test',SuppliedEmail = 'test@test.com')); 
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
       
       
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }        
        
        lstCases = [Select Id, OwnerID,AccountID From Case];      
        
        //assert Account ids        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
        Test.StopTest();
        
    } 
  
    
 
    /***************************************************************************
      Case -Insert Case from WebForm->Contact assigned to case is under nxp community-> 
        Case assigned to 1st Line Support
    ****************************************************************************/
    
   static testmethod void CaseTriggerTest2() 
    {
        
        fetchRecordTypes();
        
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
      
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
        } 
        
        Group objGroup = new Group(Name='TS L1 Inbox', type='Queue');
        insert objGroup;
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
        System.assert(objQueueMapping.Id != null);
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
                                    
        List<Account> lstParentAccount = new List<Account>();
        
        for(integer i=0; i<5; i++)
        {
            lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, Name = 'Parent'+i,
                                            Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID'));
        }
        
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
                
        for(Account objParntAccount:lstParentAccount)
        {
            system.assert(objParntAccount.Id != null);
        }
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<5; i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(i-1).Id, 
                                             Region__c='TestRegion', Sales_Area__c ='TestArea', Industry_Segment__c = 'TestSegment', 
                                             Sub_Segment__c='TestSubSegment', Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
                
        for(Account objChldAccount:lstChildAccount)
        {
            system.assert(objChldAccount.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(Integer i =1; i<5; i++)
        {
            lstContacts.add(new Contact(AccountID=objNxpCommunityAccount.Id, FirstName = 'test'+i, LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com'));
        }
        
        if(lstContacts.size() > 0)
        {
            insert lstContacts;        
        }
              
        for(Contact objContact:lstContacts)
        {
            system.assert(objContact.Id != null);
        }
        
        Test.StartTest();
        
        List<Case> lstCases = new List<Case>();
        
        For(Integer i=1; i< 5; i++)
        {
            lstCases.add(new Case(RecordTypeID = tsCommunity.Id, contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                                Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                                email__c = 'test'+i+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                                Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                                Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                                Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                                Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                                Project_Stage__c = 'Development', Web_Region__c = 'Test_region', origin = 'Community'));
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
                
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }
        
        
        lstCases = [Select Id, OwnerID, AccountID From Case];
   
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
        
        Test.StopTest();
    }  
 
    /***************************************************************************
      Case -Insert Case from WebForm->contact assigned to case is under technical services -> 
        Case assigned to first line support
    ****************************************************************************/

    static testmethod void CaseTriggerTest3() 
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
        
        Group objGroup = new Group(Name='TS L1 inbox', type='Queue');
        insert objGroup;
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
        System.assert(objQueueMapping.Id != null);
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        System.assert(objTechServiceAccount.Id != null);
                                    
        List<Account> lstParentAccount = new List<Account>();
        
        for(integer i =1; i< RECORD_COUNT; i++)
        {
            lstParentAccount.add(new Account(RecordTypeID=parentAccount.Id, Name = 'Parent'+i,
                                            Customer_Category__c= 'TestCategory', NXP_GID__c = 'TestGID',
                                            Account_Manager_SAP_3__c = lstUsers.get(i-1).ID));
        }
        if(lstParentAccount.size() > 0)
        {
            insert lstParentAccount;        
        }
        
        //assert record ids        
        for(Account objParntAccount:lstParentAccount)
        {
            system.assert(objParntAccount.Id != null);
        }
        
        List<Account> lstChildAccount = new List<Account>();
        
        for(integer i=1; i<5; i++)
        {
            lstChildAccount.add(new Account(RecordTypeID=childAccount.Id, Name = 'Child'+i, ParentID = lstParentAccount.get(i-1).Id, 
                                             Region__c='TestRegion', Sales_Area__c ='TestArea', Industry_Segment__c = 'TestSegment', 
                                             Sub_Segment__c='TestSubSegment', Country__c = 'TestCountry'));
        }
        
        if(lstChildAccount.size() > 0)
        {
            insert lstChildAccount;        
        }
        
        //assert record ids        
        for(Account objChldAccount:lstChildAccount)
        {
            system.assert(objChldAccount.Id != null);
        }
        
        List<Contact> lstContacts = new List<Contact>();
        
        For(Integer i =1; i<5; i++)
        {
            lstContacts.add(new Contact(AccountID=objTechServiceAccount.Id, FirstName = 'test'+i, LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com'));
        }
        
        if(lstContacts.size() > 0)
        {
            insert lstContacts;        
        }
              
        for(Contact objContact:lstContacts)
        {
            system.assert(objContact.Id != null);
        }
        Test.StartTest();
        
        List<Case> lstCases = new List<Case>();
        
        For(integer i=1; i< RECORD_COUNT; i++)
        {
            lstCases.add(new Case(RecordTypeID = tsCommunity.Id, contactId=lstContacts[0].id,Status= 'New', Priority = 'Medium', 
                                Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                                email__c = 'test@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                                Company__c = 'Parent'+i, Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                                Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                                Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                                Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                                Project_Stage__c = 'Development', Web_Region__c = 'Test_region', origin = 'Web',SuppliedEmail = 'test@test.com'));
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }
        
        lstCases = [Select Id, OwnerID, AccountID From Case];
        
        //assert Account ids        
        for(integer i =0; i< lstCases.size(); i++)
        {
            System.assertEquals(lstContacts[0].accountId, lstCases.get(i).AccountID);
        }
                
        Test.StopTest();
    } 
       
      
    /***************************************************************************
      Case -Populate product values based on the product type number
    ****************************************************************************/

    @isTest(SeeAllData=true)
    static void CaseTriggerTest4()
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
        
        Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
        insert objNxpCommunityAccount;
        //assert record id
        System.assert(objNxpCommunityAccount.Id != null);
        
        Account objOtherAccount = createOtherAccountRecord();
        insert objOtherAccount;
        //assert record id
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
        insert objTechServiceAccount;
        //assert record id
        System.assert(objTechServiceAccount.Id != null);

        Group objGroup = new Group(Name='1st Line Support', type='Queue');
        insert objGroup;
        //assert record id
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
         //assert record id
        System.assert(objGroup.Id != null);
        
        List<Product2> lstProduct = new List<Product2>();
        
        for(integer i=1; i<6; i++)
        {
            lstProduct.add(new Product2(Name = 'Product'+i, Basic_Type__c='Type'+i, BL_Description__c = 'Description'+i, 
                                   BU__c='BU'+i, BU_Description__c='BU_Desc'+i, MAG__c= 'MAG'+i, BL__c='BL'+i,
                                   MAG_Description__c='MAG_Desc'+i, Thrust_Indicator__c = true,
                                   Product_Type__c='Type'+i, Sales_Item_Market_Segment__c = 'Segment'+i, IsActive = true));
        }
        
        if(lstProduct.size() > 0)
        {
            Insert lstProduct;
        }
        
        //assert record ids        
        for(Product2 objProduct:lstProduct)
        {
            system.assert(objProduct.Id != null);
        }
        List<Contact> lstContacts = new List<Contact>();
        
        For(Integer i =1; i<5; i++)
        {
            lstContacts.add(new Contact(AccountID=objTechServiceAccount.Id, FirstName = 'test'+i, LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test'+i+'@test.com'));
        }
        
        if(lstContacts.size() > 0)
        {
            insert lstContacts;        
        }
              
        for(Contact objContact:lstContacts)
        {
            system.assert(objContact.Id != null);
        }
        Test.StartTest();
        
        List<Case> lstCases = new List<Case>();
        
        For(Integer i=1; i< 6; i++)
        {
            lstCases.add(new Case(RecordTypeID = tsCommunity.Id,  Status= 'New', Priority = 'Medium', contactid=lstContacts[0].id,
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers',Product_Name__c=lstProduct[0].id,
                              email__c = 'test'+i+'@prakhartest'+i+'.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'Type'+i,
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test', Web_Country__c = 'America',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region'+i, origin = 'Community',MAG__c = 'MAG1'));
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
        
        //assert record ids        
        for(Case objCase:lstCases)
        {
            system.assert(objCase.Id != null);
        }
        
        lstCases = [Select Id, OwnerID, AccountID, BL__c, BL_Description__c,Product_Mag_Description__c,Basic_Type__c,
                    BU__c, BU_Description__c, MAG__c, MAG_Description__c, Basic_Type_Description__c
                    From Case Where Email__c Like '%@prakhartest%'];
            
        lstProduct=[Select Id, Basic_Type__c,BL_Description__c, Basic_Type_Description__c,BL__c,
                    BU__c,BU_Description__c,MAG__c, MAG_Description__c,Product_Type__c From Product2
                   Where Product_Type__c Like 'Type%' ];        
        
        
        
        Test.StopTest();
    } 
    
    static testmethod void CaseTriggerTest6() 
    {
       fetchRecordTypes(); 
       
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        List<String> lstUserName= new List<String>();
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
            lstUserName.add(objUser.name);
        } 
                                                  
        
        
       Group objGroup = new Group(Name='1st Line Support', type='Queue');
        insert objGroup;
        //assert record id
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
         //assert record id
        System.assert(objGroup.Id != null);
        
        
          Account objParentAccount = createParentAccount();
          insert objParentAccount;
          system.assert(objParentAccount.id!=null);
          System.runAs(new User(Id = UserInfo.getUserId()))
          {
          Entitlement objEntitlement = new Entitlement(AccountId=objParentAccount.id, Name='testingname',Route_To_Case_Owner__c= null, Route_to_Assigned_to__c=null, Startdate=system.today());
          insert objEntitlement;
              
             
            
          Test.StartTest();
          Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test', EntitlementId=objEntitlement.id ); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
                }
       Test.StopTest();
    }
    
    static testmethod void CaseTriggerTest5() 
    {
       fetchRecordTypes(); 
       
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        List<String> lstUserName= new List<String>();
       
              
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
           
        } 
        
       Group objGroup = new Group(Name='1st Line Support', type='Queue');
        insert objGroup;
        //assert record id
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
         //assert record id
        System.assert(objGroup.Id != null);
        
        
          Account objParentAccount = createParentAccount();
          insert objParentAccount;
          system.assert(objParentAccount.id!=null);
          System.runAs(new User(Id = UserInfo.getUserId()))
          {
          Entitlement objEntitlement = new Entitlement(AccountId=objParentAccount.id, Name='testingname',Route_To_Case_Owner__c= lstUsers[0].firstname, Route_to_Assigned_to__c=lstUsers[1].id, Startdate=system.today());
          insert objEntitlement;
          system.assert(objEntitlement.id!=null);
              
          Entitlement objentitlement1 = [SELECT Id,Route_To_Case_Owner__c,Route_to_Assigned_to__c FROM Entitlement WHERE Name='testingname' LIMIT 1];    
          system.assert(objEntitlement1.id!=null);   
          user objuser1 = [select id from user where firstname =:objentitlement1.Route_To_Case_Owner__c];
          system.assert(objuser1.id!=null);
              
          user objuser2 = [select id from user where id =:objentitlement1.Route_to_Assigned_to__c];
          system.assert(objuser2.id!=null);
        
          Test.StartTest();
          Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='Test',OwnerID=objuser1.id,Assigned_to__c=objuser2.id, EntitlementId=objEntitlement.id ); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
                }
       Test.StopTest();
    }
    static testmethod void CaseTriggerTest7() 
    {
       fetchRecordTypes(); 
       
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        List<String> lstUserName= new List<String>();
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
            lstUserName.add(objUser.name);
        } 
        
       Group objGroup = new Group(Name='1st Line Support', type='Queue');
        insert objGroup;
        //assert record id
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
         //assert record id
        System.assert(objGroup.Id != null);
        
        
          Account objParentAccount = createParentAccount();
          insert objParentAccount;
          system.assert(objParentAccount.id!=null);
          System.runAs(new User(Id = UserInfo.getUserId()))
          {
          Entitlement objEntitlement = new Entitlement(AccountId=objParentAccount.id, Name='testingname',Route_To_Case_Owner__c= lstUsers[0].id, Route_to_Assigned_to__c=null, Startdate=system.today());
          insert objEntitlement;
          Test.StartTest();
          Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='lstUsers[0].id',OwnerID=lstUsers[0].id,Assigned_to__c=null, EntitlementId=objEntitlement.id ); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
                }
       Test.StopTest();
    }
    static testmethod void CaseTriggerTest8() 
    {
       fetchRecordTypes(); 
       
        List<User> lstUsers =  createManagerUsers();
        if(lstUsers.size() > 0)
        {
            insert lstUsers;        
        }
        List<String> lstUserName= new List<String>();
        
        //assert record ids        
        for(user objUser:lstUsers)
        {
            system.assert(objUser.Id != null);
            lstUserName.add(objUser.name);
        } 
        
       Group objGroup = new Group(Name='1st Line Support', type='Queue');
        insert objGroup;
        //assert record id
        System.assert(objGroup.Id != null);
        
        QueueSobject objQueueMapping = new QueueSobject(QueueId = objGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            insert objQueueMapping;
        }
         //assert record id
        System.assert(objGroup.Id != null);
        
        
          Account objParentAccount = createParentAccount();
          insert objParentAccount;
          system.assert(objParentAccount.id!=null);
          System.runAs(new User(Id = UserInfo.getUserId()))
          {
          Entitlement objEntitlement = new Entitlement(AccountId=objParentAccount.id, Name='testingname',Route_To_Case_Owner__c= null, Route_to_Assigned_to__c=lstUsers[1].id, Startdate=system.today());
          insert objEntitlement;
         Test.StartTest();
          Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test',OwnerID=objGroup.Id,Assigned_to__c=lstUsers[1].id,EntitlementId=objEntitlement.id ); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
                }
       Test.StopTest();
    }
    public static list<Case_Service_Level_Criteria__c> createCaseServiceLevelCriteria()
    {
    list<Case_Service_Level_Criteria__c> listCaseSLC=new list<Case_Service_Level_Criteria__c>();
    listCaseSLC.add(new Case_Service_Level_Criteria__c(Contact_Service_Level__c='B2-OtherCompany',Case_Service_Level__c='10'));
    listCaseSLC.add(new Case_Service_Level_Criteria__c(Contact_Service_Level__c='B2-OtherCompany',Product_Service_Level__c='2',Project_Service_Level__c='4',Case_Service_Level__c='20'));
    listCaseSLC.add(new Case_Service_Level_Criteria__c(Contact_Service_Level__c='B2-OtherCompany',Project_Service_Level__c='4',Case_Service_Level__c='30'));
   // listCaseSLC.add(new Case_Service_Level_Criteria__c(Contact_Service_Level__c='B2-OtherCompany',Product_Service_Level__c='2',Case_Service_Level__c='40'));
    listCaseSLC.add(new Case_Service_Level_Criteria__c(Product_Service_Level__c='2',Project_Service_Level__c='4',Case_Service_Level__c='50'));
    // listCaseSLC.add(new Case_Service_Level_Criteria__c(Project_Service_Level__c='4',Case_Service_Level__c='60'));
    // listCaseSLC.add(new Case_Service_Level_Criteria__c(Product_Service_Level__c='2',Case_Service_Level__c='50'));
    insert listCaseSLC;
    return listCaseSLC;
    
    }
    public static list<Product_Service_Level_Criteria__c> createProductServiceLevelCriteria()
    {
           list<Product_Service_Level_Criteria__c> listPSLC=new list<Product_Service_Level_Criteria__c>();
           listPSLC.add(new Product_Service_Level_Criteria__c(Product__c='Audio and Media Processing',Product_Category__c='Data converters',Product_Sub__c='Audio converters',Product_Service_Level__c='3'));
           listPSLC.add(new Product_Service_Level_Criteria__c(Product__c='Audio and Media Processing',Product_Category__c='Media processors',Product_Sub__c='CD-DVD processors',Product_Service_Level__c='5'));
           listPSLC.add(new Product_Service_Level_Criteria__c(Product__c='Audio and Media Processing',Product_Category__c='Media processors',Product_Sub__c='',Product_Service_Level__c='2'));
           listPSLC.add(new Product_Service_Level_Criteria__c(Product__c='Audio and Media Processing',Product_Category__c='',Product_Sub__c='',Product_Service_Level__c='1'));
           
           insert listPSLC;
           return listPSLC;
    
    } 
    public static list<Project_Service_Level_Criteria__c> createProjectServiceLevelCriteria()
    {
         list<Project_Service_Level_Criteria__c> listProjectSLC=new list<Project_Service_Level_Criteria__c>();
         listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c='high',Project_Service_Level__c='10',Sub_Type__c='',Type__c='paid'));
         listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c='critical',Project_Service_Level__c='3',Sub_Type__c='development project',Type__c='free'));
         listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c='',Project_Service_Level__c='4',Sub_Type__c='development project',Type__c='free'));
         listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c='',Project_Service_Level__c='5',Sub_Type__c='',Type__c='free'));
         listProjectSLC.add(new Project_Service_Level_Criteria__c(Priority__c='high',Project_Service_Level__c='',Sub_Type__c='',Type__c='free'));
        
        insert listProjectSLC;
        return listProjectSLC;
    
    } 
    public static list<Entitlement> createEntitlements()
    {
        Account objParentAccount = createParentAccount();
          insert objParentAccount;
        list<Entitlement> listEntitlement=new list<Entitlement>();
        listEntitlement.add(new Entitlement(AccountId=objParentAccount.id, Name='testingname', Startdate=system.today(),Type='free',Entitlement_Sub_Type__c='development project',Priority__c='critical'));
        listEntitlement.add(new Entitlement(AccountId=objParentAccount.id, Name='testingname', Startdate=system.today(),Type='free',Entitlement_Sub_Type__c='development project',Priority__c='medium'));
        listEntitlement.add(new Entitlement(AccountId=objParentAccount.id, Name='testingname', Startdate=system.today(),Type='free',Entitlement_Sub_Type__c='',Priority__c='low'));
        listEntitlement.add(new Entitlement(AccountId=objParentAccount.id, Name='testingname', Startdate=system.today(),Type='',Entitlement_Sub_Type__c='',Priority__c='critical'));
        listEntitlement.add(new Entitlement(AccountId=objParentAccount.id, Name='testingname', Startdate=system.today(),Type='free',Entitlement_Sub_Type__c='',Priority__c='high'));
        insert listEntitlement;
        return listEntitlement;
    
    } 
    public static list<Case_priority_Criteria__C> createCasePriorityCriteria()
    {
        Account objParentAccount = createParentAccount();
          insert objParentAccount;
        list<Case_priority_Criteria__C> listCPC=new list<Case_priority_Criteria__C>();
        listCPC.add(new Case_priority_Criteria__C(Object__c='Case', Field__c='Priority',Field_Value__c='High',Score__c=400));
        listCPC.add(new Case_priority_Criteria__C(Object__c='Entitlement', Field__c='Type',Field_Value__c='Free',Score__c=500));
        listCPC.add(new Case_priority_Criteria__C(Object__c='Contact', Field__c='Contact Service Level',Field_Value__c='B2-OtherCompany',Score__c=400));
        //listCPC.add(new Case_priority_Criteria__C(Object__c='Case', Field__c='Priority',Field_Value__c='High',Score__c=400,Entitlement_Sub_Type__c='development project',Priority__c='critical'));
        
        insert listCPC;
        return listCPC;
    
    } 
    
    
    static testMethod void CaseTriggerTest9()
    {
        fetchRecordTypes(); 
        list<Product_Service_Level_Criteria__c> listPSLC=new list<Product_Service_Level_Criteria__c>();
        list<Project_Service_Level_Criteria__c> listProjectSLC=new list<Project_Service_Level_Criteria__c>();
        list<Case_Service_Level_Criteria__c> listCaseSLC=new list<Case_Service_Level_Criteria__c>();
        list<Entitlement> listEntitlement=new list<Entitlement>();
        list<Case_priority_Criteria__C> listCPC=new list<Case_priority_Criteria__C>();
        
         Account objParentAccount = createParentAccount();
          insert objParentAccount;
          account childAcc=new Account(RecordTypeID=childAccount.Id, Name = 'ChildAccount', ParentID =objParentAccount.Id, 
                                             Region__c='TestRegion', Sales_Area__c ='TestArea', Industry_Segment__c = 'TestSegment', 
                                             Sub_Segment__c='TestSubSegment', Country__c = 'TestCountry');
           insert childAcc;
           contact testContact=new Contact(AccountID=childAcc.Id, FirstName = 'test1', LastName = 'test', 
                                        Title = 'title', Phone = '8123978919', email = 'test@test.com'); 
        
            insert testContact;
        
        listPSLC=createProductServiceLevelCriteria();
        listProjectSLC=createProjectServiceLevelCriteria();
        listCaseSLC=createCaseServiceLevelCriteria();
        listEntitlement=createEntitlements();
        listCPC=createCasePriorityCriteria();
        listEntitlement=[select id,Entitlement_Pattern__c from entitlement where id in:listEntitlement];
        //objCase.FeedItemId
     // Milestone__c mile = new Milestone__c (Name = 'test');
       // insert mile;ParentId = mile.id,
       // FeedItem feed = new FeedItem (ParentId = mile.id,Body = 'CONTEXT::'+listEntitlement[4].Entitlement_Pattern__c);
       // insert feed;
        System.debug(listEntitlement);
           list<case> listCases=new list<case>();
           listCases.add(new case(RecordTypeID = tsCommunity.Id,contactId=testContact.id,EntitlementId=listEntitlement[0].id,Status= 'New', Priority = 'Medium',Product__c='Discretes and Logic',
                                   Product_Category__c = 'Bipolar transistors', Product_Sub__c = 'General purpose bipolar transistors', Subject = 'test_subject',Description = 'test_subject',Web_Region__c = 'Test_region',  origin = 'Community'));
           listCases.add(new case(RecordTypeID = tsCommunity.Id,contactId=testContact.id,EntitlementId=listEntitlement[1].id,Status= 'New', Priority = 'High',Product__c='Audio and Media Processing',
                                   Product_Category__c = 'Media processors', Product_Sub__c = 'Digital radio processors.', Subject = 'test_subject',Description = 'test_subject',Web_Region__c = 'Test_region',  origin = 'Community'));
           listCases.add(new case(RecordTypeID = tsCommunity.Id,contactId=testContact.id,EntitlementId=listEntitlement[2].id, Status= 'Pending Customer Reply', Priority = 'Low',Product__c='Audio and Media Processing',
                                   Product_Category__c = 'Media processors', Product_Sub__c = '', Subject = 'test_subject',Description = 'test_subject',Web_Region__c = 'Test_region',  origin = 'Community'));
               
           listCases.add(new case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium',
                                  Subject = 'test_subject',Description = 'test_subject',Web_Region__c = 'Test_region',  origin = 'Community'));
               
           listCases.add(new case(RecordTypeID = tsCommunity.Id,Status= 'Pending Customer Reply', Priority = 'Medium',
                                   Subject = 'test_subject',Description = 'CONTEXT::'+listEntitlement[4].Entitlement_Pattern__c,Web_Region__c = 'Test_region',  origin = 'Community_Question',Product__c='Audio and Media Processing',
                                   Product_Category__c = 'Media processors', Product_Sub__c = 'Digital radio processors.'));
           
            test.startTest();
             insert listCases;
            test.stoptest();
            listCases=[select id,Description,EntitlementId,Contact_Service_Level__c,Product_Service_Level__c,Project_Service_Level__c,case_Service_Level__c,score__c,priority,due_date__C from case where id in:listCases];
             
             System.debug('ent Id on case::'+listCases[4].EntitlementId+':: description ::'+listCases[4].description);
             System.debug('ent Id ::'+listEntitlement[4].id+'::pattern::'+listEntitlement[4].Entitlement_Pattern__c);
             
             
          
            system.assert(listCases[0].Product_Service_Level__c==null);
            system.assert(listCases[1].Product_Service_Level__c=='2');
            system.assert(listCases[0].Project_Service_Level__c=='3');
            system.assert(listCases[1].Project_Service_Level__c=='4');
            system.assert(listCases[2].Project_Service_Level__c=='5');
            system.assert(listCases[1].case_Service_Level__c=='20');
            system.assert(listCases[1].Score__C==900);
            system.assert(listCases[1].Priority=='High');
            system.assert(listCases[4].EntitlementId==listEntitlement[4].id);
            
      
            listCases[2].status='Pending Internal';
            update  listCases[2];
            system.debug(listCases);
       
        
    }
    
    
    static testMethod void CaseTriggerTest10()
    {
        fetchRecordTypes();
        List<User> lstUsers =  createManagerUsers();
        List<Case> listCases = new List<Case>();
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
        
        Test.starttest();
        List<Case> lstCases = new List<Case>();
        For(integer i=1; i< 5; i++)
        {
           lstCases.add(new Case(RecordTypeID = tsCommunity.Id,contactId=lstContacts[0].id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test'+i+'@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Web_Region__c = 'Test_region',  origin = 'Email',Case_Owner_Name__c='test',SuppliedEmail = 'test@test.com')); 
        }
        
        if(lstCases.size() > 0)
        {
            Insert lstCases;
        }
    
       Test.stopTest();
    
       listCases=[select id,Description,Origin,EntitlementId,Contact_Service_Level__c,Product_Service_Level__c,Project_Service_Level__c,case_Service_Level__c,score__c,priority,due_date__C from case where id in:lstCases];
       system.assert(listCases[0].origin=='Email');
       system.assert(listCases[1].origin=='Email');
    }
    
    
    static testMethod void CaseTriggerTest11()
    
    {
    
    
         fetchRecordTypes(); 
          Account objParentAccount = createParentAccount();
          insert objParentAccount;
          system.assert(objParentAccount.id!=null);
          
          
          Entitlement objEntitlement = new Entitlement(AccountId=objParentAccount.id, Name='testingname',Route_To_Case_Owner__c= null, Route_to_Assigned_to__c=null,Used_number_of_Hours__c=10,Total_Number_of_Hours__c=20,Remaining_Hours__c=10, Startdate=system.today());
          insert objEntitlement;


          Test.StartTest();
          Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Hours_spent_by_Support_person__c=5, Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test', EntitlementId=objEntitlement.id ); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
                
           Case C=[Select Hours_spent_by_Support_person__c from Case where id =:objCase.Id limit 1 ];
           C.Hours_spent_by_Support_person__c =6;
           update C;
           
             
                
       Test.StopTest();
        
        
    
    
    
    }
    
    
    static testMethod void CaseTriggerTest12()
    
    {
    
    
         fetchRecordTypes(); 
          Account objParentAccount = createParentAccount();
          insert objParentAccount;
          system.assert(objParentAccount.id!=null);
          
          
          Entitlement objEntitlement = new Entitlement(AccountId=objParentAccount.id,Used_number_of_Hours__c=null, Name='testingname',Route_To_Case_Owner__c= null, Route_to_Assigned_to__c=null,Total_Number_of_Hours__c=20,Remaining_Hours__c=10, Startdate=system.today());
          insert objEntitlement;


          Test.StartTest();
          Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development',Hours_spent_by_Support_person__c=6,Internal_Priority__c='Low', Web_Region__c = 'Test_region',  origin = 'Community',Case_Owner_Name__c='test', EntitlementId=objEntitlement.id ); 
 
                Insert objCase;
                system.assert(objCase.Id!=null);
                
           Case C=[Select Hours_spent_by_Support_person__c,Internal_Priority__c from Case where id =:objCase.Id limit 1 ];
           C.Hours_spent_by_Support_person__c =5;
           C.Internal_Priority__c='High';
           update C;
           
             
                
       Test.StopTest();
        
        
    
    
    
    }

}