/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
/***************************************************************************************************
@Modified By :       Amrutha
@Modified Date:      17 Feb 2015
@Description:        Test class for communitiesSelfRegController
================================================================================
@Modified By :       Amrutha
@Modified Date:      17 Feb 2016
@Description:        Modified according to changes in communitiesSelfRegController
===========================================================================================
@Modified By :      Nisha Agrawal
@ModifiedDate :     01 Sep 2016
@Description :      Fixing the issue of duplicate email in contact (SIR 1155) as well as removing code part for SIR1186. 
******************************************************************************************************/

@IsTest public with sharing class CommunitiesSelfRegControllerTest 
{ 
    private static final String CASE_TSCOMMUNITY = 'TS_Community';
    private static final String CASE_TSWEBMASTER = 'TS_Webmaster';
    private static final String ACCOUNT_CHILDACCOUNT = 'Child_Account';
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    
    public static RecordType tsCommunity;
    public static RecordType webMaster;
    public static RecordType childAccount;
    public static RecordType parentAccount;
        
    private static void fetchRecordTypes()
    {
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              ((SobjectType = 'Case' and (DeveloperName =: CASE_TSCOMMUNITY or DeveloperName =: CASE_TSWEBMASTER)) or
                               (SobjectType = 'Account' and (DeveloperName =: ACCOUNT_CHILDACCOUNT or DeveloperName =: ACCOUNT_ParentACCOUNT)) 
                              )
                              Limit 4])
        {
            if(rt.DeveloperName == CASE_TSCOMMUNITY)
            {
                tsCommunity = rt;
            }
            else if(rt.DeveloperName == CASE_TSWEBMASTER)
            {
                webMaster = rt;
            }
            else if(rt.DeveloperName == ACCOUNT_CHILDACCOUNT)
            {
                childAccount = rt;
            }
            else if(rt.DeveloperName == ACCOUNT_ParentACCOUNT)
            {
                parentAccount = rt; 
            }            
        }
    } 
     
    
    private static Account createParentAccount()
    {
        //Method to create a Parent Account
        Account objParentAccount;
        objParentAccount = new Account(RecordTypeID= parentAccount.ID,
                                                Name = 'Bosch', Customer_Category__c= 'Longtail');
        return  objParentAccount;
    }
    
    private static Account createChildAccount(ID parentAccountId)
    {
        User objUsr =  createManagerUsers();
        insert objUsr;
        system.assert(objUsr.id!=null);
        //Method to create a Child Account
        Account objChildAccount;
        objChildAccount = new Account(RecordTypeID= childAccount.ID,ParentId = parentAccountId, ownerId=objUsr.id, 
                                            Name = 'Bosch Japan', Region__c = 'Japan',
                                             Sales_Area__c = 'Japan ID', Industry_Segment__c = 'Mobile',
                                             Country__c = 'Japan');
        return objChildAccount;    
    }

    //Create user records to assign to account owner
    private Static User createManagerUsers() 
    {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        system.assert(objProfile.Id != null);
        
        User objUser= new User(alias = 'nUser' , email= 'testing@test.com', emailencodingkey='UTF-8', lastname='test',languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id,UserRoleId = portalRole.Id, timezonesidkey='America/Los_Angeles', username= 'prakhartest' + datetime.now().millisecond() +'@test.com' );
            
        return objUser;
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
    
    private static List<Contact> createContact()    
    {
        
        List<Contact> lstContact= new List<Contact>();
        Contact objContact1=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@test.com', CanAllowPortalSelfReg=false); 
        lstContact.add(objContact1);
        Contact objContact2=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@bosch.com', 
                                          Community_web_country__c='Japan',Company__c='Bosch Japan',CanAllowPortalSelfReg=false); 
        lstContact.add(objContact2);
        Contact objContact3=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@bosch.com', 
                                          Community_web_country__c='Japan',Company__c='Bosch',CanAllowPortalSelfReg=false); 
        lstContact.add(objContact3);
        Contact objContact4=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@abc.com', 
                                          Community_web_country__c='test',Company__c='test',CanAllowPortalSelfReg=false); 
        lstContact.add(objContact4);
        Contact objContact5=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@samsung.com', 
                                          Community_web_country__c='test',Company__c='test',CanAllowPortalSelfReg=false); 
        lstContact.add(objContact5);
        Contact objContact6=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test3@abc.com', 
                                          Community_web_country__c='test1',Company__c='test',CanAllowPortalSelfReg=false); 
        lstContact.add(objContact6);
        Contact objContact7=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test3@abc.com', 
                                          Community_web_country__c='test1',Company__c='test',CanAllowPortalSelfReg=false); 
        lstContact.add(objContact7);
                
        return lstContact;        
        
    }
    
    
    private static User CreateUser()
    {
        
        Profile objProfile= [SELECT Id FROM Profile WHERE name='NXP Customer Community Login User' Limit 1];
        User objUser = new User(Alias = 'standt', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                      LocaleSidKey='en_US', ProfileId = objProfile.Id,
                    TimeZoneSidKey='America/Los_Angeles');
        return objUser;
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

     //positive case to create portal user
    public static testmethod void testCommunitiesSelfRegController1() 
    {
        fetchRecordTypes();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        Profile objProf= [Select id,name from profile where name='NXP Customer Community Login User'];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.CommunityUserProfileId__c= objProf.Id;
            setting.CommunityUserAccountId__c= objNxpCommunityAccount.Id;
            setting.CommunityLoginUrl__c= '/community/CommunityLogin';
        	insert setting;
        	CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
        	selfRegController.strFirstName = 'FirstName';
        	selfRegController.strLastName = 'LastName';
        	selfRegController.strEmail = 'test@tcs.com';
        	selfRegController.strCommunityNickname = 'test';
        	selfRegController.strPhone =  '9954565564';
        	selfRegController.strFacebook= 'facebook';
        	selfRegController.strLinkedIn= 'linkedIn';
        	selfRegController.strTwitter= 'twitter';
        	selfRegController.strState= 'state';
        	selfRegController.strJobTitle= 'Marketing';
        	selfRegController.strCompany= 'test';
        	selfRegController.isCheck=true;
            selfRegController.input='test';
        
       		selfRegController.strPassword = 'abcd123';
        	selfRegController.strConfirmPassword = 'abcd123';
     
        	Test.startTest();
        
        	selfRegController.getJobTitles();
        	selfRegController.getCountries();
        	selfRegController.getWebRegions();
        	selfRegController.input='test11';
      		selfRegController.getChar1();
        	selfRegController.getChar2();
        	selfRegController.getChar3();
        	selfRegController.getChar4();
        	selfRegController.getChar5();
        	selfRegController.getChar6();
        
        	// registerUser will always return null when the page isn't accessed as a guest user
        	system.assertEquals(selfRegController.userId, null);
        	System.assert(selfRegController.registerUser()==null); 
        	selfRegController.userId=objUsr.id;
        	selfRegController.emailVerification();
        	selfRegController.SignInPage();
            Test.stopTest();
        }
        
    }    
    
    //negative case where password validation fails
    public static testmethod void testCommunitiesSelfRegController2() 
    {
        fetchRecordTypes();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        Profile objProf= [Select id,name from profile where name='NXP Customer Community Login User'];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.CommunityUserProfileId__c= objProf.Id;
            setting.CommunityUserAccountId__c= objNxpCommunityAccount.Id;
        	insert setting;
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            selfRegController.strFirstName = 'FirstName';
            selfRegController.strLastName = 'LastName';
            selfRegController.strEmail = 'test@tcs.com';
            selfRegController.strCommunityNickname = 'test';
            selfRegController.strPhone =  '9954565564';
            selfRegController.strFacebook= 'facebook';
            selfRegController.strLinkedIn= 'linkedIn';
            selfRegController.strTwitter= 'twitter';
            selfRegController.strState= 'state';
            selfRegController.strJobTitle= 'Marketing';
            selfRegController.strCompany= 'test';
            selfRegController.isCheck=true;
            selfRegController.input='test';
            
            selfRegController.strPassword = 'abcd123';
            selfRegController.strConfirmPassword = 'abcd1235';
            
            Test.startTest();
            // registerUser will always return null when the page isn't accessed as a guest user
            system.assertEquals(selfRegController.userId, null);
            System.assert(selfRegController.registerUser()==null);
                    
            Test.stopTest();
        }
    }
    
    //negative case where terms and conditions checkbox is not checked
    public static testmethod void testCommunitiesSelfRegController3() 
    {
        fetchRecordTypes();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        Profile objProf= [Select id,name from profile where name='NXP Customer Community Login User'];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.CommunityUserProfileId__c= objProf.Id;
            setting.CommunityUserAccountId__c= objNxpCommunityAccount.Id;
        	insert setting;
            
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            selfRegController.strFirstName = 'FirstName';
            selfRegController.strLastName = 'LastName';
            selfRegController.strEmail = 'test@tcs.com';
            selfRegController.strCommunityNickname = 'test';
            selfRegController.strPhone =  '9954565564';
            selfRegController.strFacebook= 'facebook';
            selfRegController.strLinkedIn= 'linkedIn';
            selfRegController.strTwitter= 'twitter';
            selfRegController.strState= 'state';
            selfRegController.strJobTitle= 'Marketing';
            selfRegController.strCompany= 'test';
            selfRegController.isCheck=false;
            selfRegController.input='test';
            
            selfRegController.strPassword = 'abcd123';
            selfRegController.strConfirmPassword = 'abcd123';
            
            Test.startTest();
            // registerUser will always return null when the page isn't accessed as a guest user
            system.assertEquals(selfRegController.userId, null);
            System.assert(selfRegController.registerUser()==null);
    
            Test.stopTest();
        }
    }
    
    //negative case where jobtitle is not selected
    public static testmethod void testCommunitiesSelfRegController4() 
    {
        fetchRecordTypes();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        Profile objProf= [Select id,name from profile where name='NXP Customer Community Login User'];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.CommunityUserProfileId__c= objProf.Id;
            setting.CommunityUserAccountId__c= objNxpCommunityAccount.Id;
        	insert setting;
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            selfRegController.strFirstName = 'FirstName';
            selfRegController.strLastName = 'LastName';
            selfRegController.strEmail = 'test@tcs.com';
            selfRegController.strCommunityNickname = 'test';
            selfRegController.strPhone =  '9954565564';
            selfRegController.strFacebook= 'facebook';
            selfRegController.strLinkedIn= 'linkedIn';
            selfRegController.strTwitter= 'twitter';
            selfRegController.strState= 'state';
            selfRegController.strJobTitle= '--None--';
            selfRegController.strCompany= 'test';
            selfRegController.isCheck=true;
            selfRegController.input='test';
          
            selfRegController.strPassword = 'abcd123';
            selfRegController.strConfirmPassword = 'abcd123';
            
            Test.startTest();
            selfRegController.registerUser();
            selfRegController.strJobTitle= '--None--';
            selfRegController.strCompany= '--None--';
            // registerUser will always return null when the page isn't accessed as a guest user
            system.assertEquals(selfRegController.userId, null);
            System.assert(selfRegController.registerUser()==null);
            Test.stopTest();
        }
    }
    
    //positive case where nxp.com user is created 
    public static testmethod void testCommunitiesSelfRegController5() 
    {
        fetchRecordTypes();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        Profile objProf= [Select id,name from profile where name='NXP Customer Community Login User'];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.CommunityUserProfileId__c= objProf.Id;
            setting.CommunityUserAccountId__c= objNxpCommunityAccount.Id;
        	insert setting;
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            selfRegController.strFirstName = 'FirstName';
            selfRegController.strLastName = 'LastName';
            selfRegController.strEmail = 'test1@nxp.com';
            selfRegController.strCommunityNickname = 'test';
            selfRegController.strPhone =  '9954565564';
            selfRegController.strFacebook= 'facebook';
            selfRegController.strLinkedIn= 'linkedIn';
            selfRegController.strTwitter= 'twitter';
            selfRegController.strState= 'state';
            selfRegController.strJobTitle= 'Marketing';
            selfRegController.strCompany= 'test';
            selfRegController.isCheck=true;
            selfRegController.input='test';
           
            selfRegController.strPassword = 'abcd123';
            selfRegController.strConfirmPassword = 'abcd123';
            
            Test.startTest();
            
            // registerUser will always return null when the page isn't accessed as a guest user
            system.assertEquals(selfRegController.userId, null);
            System.assert(selfRegController.registerUser()!=null);
     
            Test.stopTest();
        }
    }
    
    //positive case where contact under NXP community account is updated 
    public static testmethod void testCommunitiesSelfRegController6() 
    {
        Test.startTest();
        fetchRecordTypes();
        
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        Profile objProf= [Select id,name from profile where name='NXP Customer Community Login User'];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
            
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objParentAccount = createParentAccount();
        
          	insert objParentAccount;
          	system.assert(objParentAccount.id!=null);
            
          	Account objChildAccount = createChildAccount(objParentAccount.id);
          	insert objChildAccount;
          	system.assert(objChildAccount.id!=null);
            
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.CommunityUserProfileId__c= objProf.Id;
            setting.CommunityUserAccountId__c= objNxpCommunityAccount.Id;
        	insert setting;
            
          	Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                           Phone = '8123978919', email = 'test1@test.com', AccountID = objNxpCommunityAccount.id,
                                           Community_web_country__c='test',Company__c='test');
          	insert objContact;
          	system.assert(objContact.id!=null);
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            selfRegController.strFirstName = 'FirstName';
            selfRegController.strLastName = 'LastName';
            selfRegController.strEmail = objContact.Email;
            selfRegController.strCommunityNickname = 'test';
            selfRegController.strPhone =  '9954565564';
            selfRegController.strFacebook= 'facebook';
            selfRegController.strLinkedIn= 'linkedIn';
            selfRegController.strTwitter= 'twitter';
            selfRegController.strState= 'state';
            selfRegController.strJobTitle= 'Marketing';
            selfRegController.strCompany= 'test';
            selfRegController.isCheck=true;
            selfRegController.char1='t';
            selfRegController.char2='e';
            selfRegController.char3='s';
            selfRegController.char4='t';
            selfRegController.char5='1';
            selfRegController.char6='1';
            selfRegController.input='test11';
            selfRegController.strPassword = 'abcd123';
            selfRegController.strConfirmPassword = 'abcd123';
            selfRegController.registerUser();
        }
        Test.stopTest();
        
    }
    
    //positive case where contact under technical services account is deleted 
    public static testmethod void testCommunitiesSelfRegController7() 
    {
    	Test.startTest();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        fetchRecordTypes();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        Profile objProf= [Select id,name from profile where name='NXP Customer Community Login User'];
        system.runAs(objUsr)
        {
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
            
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.CommunityUserProfileId__c= objProf.Id;
            setting.CommunityUserAccountId__c= objNxpCommunityAccount.Id;
        	insert setting;
     
            Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                           Phone = '8123978919', email = 'test1@test.com', AccountID = objTechServiceAccount.id,
                                           Community_web_country__c='test',Company__c='test');
          	insert objContact;
          	system.assert(objContact.id!=null);
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            selfRegController.strFirstName = 'FirstName';
            selfRegController.strLastName = 'LastName';
            selfRegController.strEmail = objContact.Email;
            selfRegController.strCommunityNickname = 'test';
            selfRegController.strPhone =  '9954565564';
            selfRegController.strFacebook= 'facebook';
            selfRegController.strLinkedIn= 'linkedIn';
            selfRegController.strTwitter= 'twitter';
            selfRegController.strState= 'state';
            selfRegController.strJobTitle= 'Marketing';
            selfRegController.strCompany= 'test';
            selfRegController.isCheck=true;
            selfRegController.char1='t';
            selfRegController.char2='e';
            selfRegController.char3='s';
            selfRegController.char4='t';
            selfRegController.char5='1';
            selfRegController.char6='1';
            selfRegController.input='test11';
            selfRegController.strPassword = 'abcd123';
            selfRegController.strConfirmPassword = 'abcd123';
            selfRegController.registerUser();
       
            selfRegController.getJobTitles();
       
            Test.stopTest();
        }
    }
    
    /* commented by Nisha on Sep 01 for SIR 1185 and 1155
    //merge: positive case where same email address exist in single contact
    public static testmethod void testCommunitiesSelfRegController8()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        fetchRecordTypes();
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
            
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
                
            Account objChildAccount = createChildAccount(objParentAccount.id);
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
                
            Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                               Phone = '8123978919', email = 'test1@test.com', AccountID = objNxpCommunityAccount.id,
                                               Community_web_country__c='test',Company__c='test');
            insert objContact;
            system.assert(objContact.id!=null);
            User objUser= createUser();
            objUser.ContactId= objContact.id;
            objUser.Email= 'test1@test.com';
            objUser.Username= 'test1@test.com';
            objUser.Email_verification_status__c='Activation pending';
            insert objUser;
            system.assert(objUser.id!=null);
                
            List<Contact> lstContact= new List<Contact>();
            List<Contact> lstContact1= new List<Contact>();
            lstContact= createContact();
            for(Contact objCont: lstContact)
            {
                objCont.AccountID = objChildAccount.Id;
                lstContact1.add(objCont);
            }
            insert lstContact1;
            system.assert(lstContact1!=null);
                
            List<Public_Domain__c> lstPublicDomains = createPublicDomainRecords();        
            if(lstPublicDomains.size() > 0)
            {
                Insert lstPublicDomains;
            }
            
            //assert record ids        
            for(Public_Domain__c objPublicDomain:lstPublicDomains)
            {
                system.assert(objPublicDomain.Id != null);
            }
    
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            ApexPages.currentPage().getParameters().put('email', objUser.Email);
            selfRegController.confirmEmailRequest();
            system.assert(selfRegController.confirmEmailRequest()==null);
         }
         Test.stopTest();
    }
    
    //merge: positive case where same email address exist in multiple contacts and company name matches account name
    public static testmethod void testCommunitiesSelfRegController9()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        fetchRecordTypes();
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
            
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                           Phone = '8123978919', email = 'test1@bosch.com', AccountID = objNxpCommunityAccount.id,
                                           Community_web_country__c='test',Company__c='Bosch Japan');
            insert objContact;
            system.assert(objContact.id!=null);
            
            User objUser= createUser();
            objUser.ContactId= objContact.id;
            objUser.Email= 'test1@bosch.com';
            objUser.Username= 'test1@bosch.com';
            objUser.Email_verification_status__c='Activation pending';
            insert objUser;
            system.assert(objUser.id!=null);
            
            List<Contact> lstContact= new List<Contact>();
            List<Contact> lstContact1= new List<Contact>();
            lstContact= createContact();
            for(Contact objCont: lstContact)
            {
                objCont.AccountID = objChildAccount.Id;
                lstContact1.add(objCont);
            }
            insert lstContact1;
            system.assert(lstContact1!=null);
            
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            ApexPages.currentPage().getParameters().put('email', objUser.Email);
            selfRegController.confirmEmailRequest();
            system.assert(selfRegController.confirmEmailRequest()==null);
        }
        Test.stopTest();
    }

    //merge:positive case where same email address exist in multiple contacts and country name matches account name
    public static testmethod void testCommunitiesSelfRegController10()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        fetchRecordTypes();
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
            
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                           Phone = '8123978919', email = 'test1@bosch.com', AccountID = objNxpCommunityAccount.id,
                                           Community_web_country__c='Japan',Company__c='test');
            insert objContact;
            system.assert(objContact.id!=null);
            
            User objUser= createUser();
            objUser.ContactId= objContact.id;
            objUser.Email= 'test1@bosch.com';
            objUser.Username= 'test1@bosch.com';
            objUser.Email_verification_status__c='Activation pending';
            insert objUser;
            system.assert(objUser.id!=null);
            
            List<Contact> lstContact= new List<Contact>();
            List<Contact> lstContact1= new List<Contact>();
            lstContact= createContact();
            for(Contact objCont: lstContact)
            {
                objCont.AccountID = objChildAccount.Id;
                lstContact1.add(objCont);
            }
            insert lstContact1;
            system.assert(lstContact1!=null);
            
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            ApexPages.currentPage().getParameters().put('email', objUser.Email);
            selfRegController.confirmEmailRequest();
          system.assert(selfRegController.confirmEmailRequest()==null);
        }
        Test.stopTest();
    }

    //merge: positive case where same email address exist in multiple contacts and merge by last modified date
    public static testmethod void testCommunitiesSelfRegController11()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        fetchRecordTypes();
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
        
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
        
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                           Phone = '8123978919', email = 'test3@abc.com', AccountID = objNxpCommunityAccount.id,
                                           Community_web_country__c='test',Company__c='Bosch');
            insert objContact;
            system.assert(objContact.id!=null);
        
            User objUser= createUser();
          	objUser.ContactId= objContact.id;
            objUser.Email= 'test3@abc.com';
            objUser.Username= 'test3@abc.com';
            objUser.Email_verification_status__c='Activation pending';
            insert objUser;
            system.assert(objUser.id!=null);
           
            List<Contact> lstContact= new List<Contact>();
            List<Contact> lstContact1= new List<Contact>();
            lstContact= createContact();
            for(Contact objCont: lstContact)
            {
                objCont.AccountID = objChildAccount.Id;
                lstContact1.add(objCont);
            }
            insert lstContact1;
            system.assert(lstContact1!=null);
            
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            ApexPages.currentPage().getParameters().put('email', objUser.Email);
            selfRegController.confirmEmailRequest();
            system.assert(selfRegController.confirmEmailRequest()==null);
        }
        Test.stopTest();
    }
  
    //assign: positive case where same email address exist in multiple contacts and country name matches account name
    public static testmethod void testCommunitiesSelfRegController12()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        fetchRecordTypes();
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
        
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
        
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                           Phone = '8123978919', email = 'test22@bosch.com', AccountID = objNxpCommunityAccount.id,
                                           Community_web_country__c='Japan',Company__c='test');
            insert objContact;
            system.assert(objContact.id!=null);
        
        	User objUser= createUser();
            objUser.ContactId= objContact.id;
            objUser.Email= 'test22@bosch.com';
            objUser.Username= 'test22@bosch.com';
            objUser.Email_verification_status__c='Activation pending';
            insert objUser;
            system.assert(objUser.id!=null);
       
            List<Contact> lstContact= new List<Contact>();
            List<Contact> lstContact1= new List<Contact>();
            lstContact= createContact();
            for(Contact objCont: lstContact)
            {
                objCont.AccountID = objChildAccount.Id;
                lstContact1.add(objCont);
            }
            insert lstContact1;
            system.assert(lstContact1!=null);
            
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            ApexPages.currentPage().getParameters().put('email', objUser.Email);
            selfRegController.confirmEmailRequest();
            //selfRegController.accountContactMapping(objUser);
            system.assert(selfRegController.confirmEmailRequest()==null);
        }
        Test.stopTest();
    }
    
    //assign: positive case where same email address exist in multiple contacts and company name matches account name
    public static testmethod void testCommunitiesSelfRegController13()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        fetchRecordTypes();
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
        
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
        
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                           Phone = '8123978919', email = 'test22@bosch.com', AccountID = objNxpCommunityAccount.id,
                                           Community_web_country__c='test',Company__c='Bosch Japan');
            insert objContact;
            system.assert(objContact.id!=null);
        
            User objUser= createUser();
            objUser.ContactId= objContact.id;
            objUser.Email= 'test22@bosch.com';
            objUser.Username= 'test22@bosch.com';
            objUser.Email_verification_status__c='Activation pending';
            insert objUser;
            system.assert(objUser.id!=null);
       
            List<Contact> lstContact= new List<Contact>();
            List<Contact> lstContact1= new List<Contact>();
            lstContact= createContact();
            for(Contact objCont: lstContact)
            {
                objCont.AccountID = objChildAccount.Id;
                lstContact1.add(objCont);
            }
            insert lstContact1;
            system.assert(lstContact1!=null);
            
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            ApexPages.currentPage().getParameters().put('email', objUser.Email);
            selfRegController.confirmEmailRequest();
            system.assert(selfRegController.confirmEmailRequest()==null);
        }
        Test.stopTest();
    }

    //assign: positive case where same email address exist in single contact
    public static testmethod void testCommunitiesSelfRegController14()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        fetchRecordTypes();
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
        
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
        
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                           Phone = '8123978919', email = 'test2@test.com', AccountID = objNxpCommunityAccount.id,
                                           Community_web_country__c='test',Company__c='test');
            insert objContact;
            system.assert(objContact.id!=null);
        
            User objUser= createUser();
            objUser.ContactId= objContact.id;
            objUser.Email= 'test2@test.com';
            objUser.Username= 'test2@test.com';
            objUser.Email_verification_status__c='Activation pending';
            insert objUser;
            system.assert(objUser.id!=null);
       
            List<Contact> lstContact= new List<Contact>();
            List<Contact> lstContact1= new List<Contact>();
            lstContact= createContact();
            for(Contact objCont: lstContact)
            {
                objCont.AccountID = objChildAccount.Id;
                lstContact1.add(objCont);
            }
            insert lstContact1;
            system.assert(lstContact1!=null);
            
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            ApexPages.currentPage().getParameters().put('email', objUser.Email);
            selfRegController.confirmEmailRequest();
            //selfRegController.accountContactMapping(objUser);
            system.assert(selfRegController.confirmEmailRequest()==null);
        }
        Test.stopTest();
    }
    
    //assign: positive case where same email address exist in multiple contacts and assign by last modified date
    public static testmethod void testCommunitiesSelfRegController15()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        System.currentPageReference().getParameters().put('pagename', 'test');
        fetchRecordTypes();
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
        
            Account objOtherAccount = createOtherAccountRecord();
            insert objOtherAccount;
            System.assert(objOtherAccount.Id != null);
        
            Account objTechServiceAccount = createTechServiceAccountRecord(objOtherAccount.ID);
            insert objTechServiceAccount;
            System.assert(objTechServiceAccount.Id != null);
            
            Account objParentAccount = createParentAccount();
        
            insert objParentAccount;
            system.assert(objParentAccount.id!=null);
        
            Account objChildAccount = createChildAccount(objParentAccount.id);
            insert objChildAccount;
            system.assert(objChildAccount.id!=null);
            
            Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                           Phone = '8123978919', email = 'test2@abc.com', AccountID = objNxpCommunityAccount.id,
                                           Community_web_country__c='test',Company__c='test');
            insert objContact;
            system.assert(objContact.id!=null);
        
            User objUser= createUser();
            objUser.ContactId= objContact.id;
            objUser.Email= 'test2@abc.com';
            objUser.Username= 'test2@abc.com';
            objUser.Email_verification_status__c='Activation pending';
            insert objUser;
            system.assert(objUser.id!=null);
       
            List<Contact> lstContact= new List<Contact>();
            List<Contact> lstContact1= new List<Contact>();
            lstContact= createContact();
            for(Contact objCont: lstContact)
            {
                objCont.AccountID = objChildAccount.Id;
                lstContact1.add(objCont);
            }
            insert lstContact1;
            system.assert(lstContact1!=null);
            
        	CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.EmailVerficationLink__c= '/community/CommunitiesEmailVerfication';
        	insert setting;
        	system.assert(setting.Id!=null);
            
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            ApexPages.currentPage().getParameters().put('email', objUser.Email);
            selfRegController.strEmail=objUser.Email;
            selfRegController.userId=objUser.id;
            selfRegController.emailVerification();
            selfRegController.confirmEmailRequest();
            system.assert(selfRegController.confirmEmailRequest()==null);
        }
        Test.stopTest();
    }
  */  
    //negative case where country is not selected
    public static testmethod void testCommunitiesSelfRegController16() 
    {
        
        fetchRecordTypes();
        Test.setCurrentPageReference(new PageReference('/CommunityRegistration'));
        User objUsr =  [ Select Id from User where Id=: userinfo.getUserId()];
        Profile objProf= [Select id,name from profile where name='NXP Customer Community Login User'];
        system.runAs(objUsr)
        {
            Account objNxpCommunityAccount = createNxpCommunityAccountRecord();
            insert objNxpCommunityAccount;
            System.assert(objNxpCommunityAccount.Id != null);
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.CommunityUserProfileId__c= objProf.Id;
            setting.CommunityUserAccountId__c= objNxpCommunityAccount.Id;
        	insert setting;
            
            CommunitiesSelfRegController selfRegController = new CommunitiesSelfRegController();
            selfRegController.strFirstName = 'FirstName';
            selfRegController.strLastName = 'LastName';
            selfRegController.strEmail = 'test@tcs.com';
            selfRegController.strCommunityNickname = 'test';
            selfRegController.strPhone =  '9954565564';
            selfRegController.strFacebook= 'facebook';
            selfRegController.strLinkedIn= 'linkedIn';
            selfRegController.strTwitter= 'twitter';
            selfRegController.strState= 'state';
            selfRegController.strJobTitle= 'test';
            selfRegController.strCompany= 'test';
            selfRegController.isCheck=true;
            selfRegController.strCountry='--None--';
            selfRegController.strWebRegion='test';
            selfRegController.input='test';
          
            selfRegController.strPassword = 'abcd123';
            selfRegController.strConfirmPassword = 'abcd123';
            
            Test.startTest();
            selfRegController.registerUser();
       
            selfRegController.getJobTitles();
            // registerUser will always return null when the page isn't accessed as a guest user
            system.assertEquals(selfRegController.userId, null);
            System.assert(selfRegController.registerUser()==null);
            Test.stopTest();
        }
    }
    
    
}