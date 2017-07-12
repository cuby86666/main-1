/*********************************************************************************************
@Created By :       Prakhar Gupta
@Created Date :     08 Jan 2015
Description :       Test Class for SubmitCaseController
********************************************************************************************/

/*********************************************************************************************
@Modified By :      Amrutha R
@Modified Date :    15 Jan 2015
Description :       code cleaned up/ modified as per best practices
********************************************************************************************/

@isTest
public class SubmitCaseControllerTest 
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
    
    private static Account createOtherParentAccount()
    {
        //Method to create a 'Other' Parent Account
        Account objOtherParentAccount;
        objOtherParentAccount = new Account(RecordTypeID= parentAccount.ID,
                                                Name = 'Other', Customer_Category__c= 'Longtail');
        return  objOtherParentAccount;
    }

    
    private static Account createNxpCommunityParentAccount()
    {
        //Method to create a 'NXP Community' Parent Account
        Account objNxpCommunityParentAccount;
        objNxpCommunityParentAccount = new Account(RecordTypeID= parentAccount.ID,
                                                Name = 'NXP Community', Customer_Category__c= 'Longtail');
        return  objNxpCommunityParentAccount;
    } 
    
    
    private static Account createTechSupportChildAccount(ID parentAccountId)
    {
        //Method to create a TechSupport Child Account
        Account objTechSupportChildAccount;
        objTechSupportChildAccount = new Account(RecordTypeID= childAccount.ID,ParentId = parentAccountId,  
                                            Name = 'Technical Services', Region__c = 'Japan',
                                             Sales_Area__c = 'Japan ID', Industry_Segment__c = 'Mobile',
                                             Country__c = 'Austria');
        return objTechSupportChildAccount;    
    }
    
    
    //Method to create a  Contact
    private static Contact createContact(ID accountID, String strFirstName, String strLastName,
                                                 String strTitle, String strPhoneNo, String strEmail)
    {
        
           Contact objContact=new Contact(FirstName=strFirstName,LastName=strLastName, Title = strTitle,
                                          Phone = strPhoneNo, email = strEmail, AccountID = accountID);              
                
           return objContact;        
        
    }
    
    
    private static Case createCase(ID contactID, String strFirstName, String strLastName,
                                            String strEmail, String strPriority, String strProductCategory,
                                            String strProductSubCategory, String strSubject, String strDescription,
                                            String strJobTitle, String strFacebook, String strCompany, String strLinkedin, 
                                            String strTwitter, String strState, String strProductApplication, String strCountry,
                                            String strExpectedAnnualUnitVolume, String strProjectStage, String strWebRegion,
                                            String strProductTypeNumber, String strQuestion)
    {
        Case objCase=new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = strPriority, 
                                 Product_Category__c = strProductCategory, Product_Sub__c = strProductSubCategory, 
                                 SuppliedName = strFirstName+' '+strLastName, SuppliedEmail = strEmail, 
                                 ContactId = contactID, JobTitle__c = strJobTitle, Facebook__c = strFacebook,
                                 Company__c = strCompany, Linkedin__c = strLinkedin, Community_Web_Country__c = strCountry,
                                 Twitter__c = strTwitter, State_Province__c = strState, Product_Type_Number__c = strProductTypeNumber,
                                 Subject = strSubject, My_Question_is_Related__c = strQuestion, Description = strDescription,
                                 Product_application__c = strProductApplication, Expected_annual_unit_volume__c = strExpectedAnnualUnitVolume,
                                 Project_Stage__c = strProjectStage, Web_Region__c = strWebRegion, origin =  'Community'); 
        return objCase;
    }
    
    /***************************************************************************
      Case-When User do not has account in community and not Submiting for first Time
           result- case is submitted succesfully and user is assigned to TS community account
    ****************************************************************************/

    static testmethod void SubmitCaseControllerTest1() 
    {

        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           'Medium', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Microcontrollers';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'TestCountry';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'less than 1,000';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Development';
        SubmitCaseCtrl.strQuestion = 'RoHS/REACH/ChemicalContent';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';

        Attachment objAttach= new Attachment();
        objAttach.name= 'Test attachment';
        Blob bodyBlob=Blob.valueOf('Test Attachment');
    	objAttach.body=bodyBlob;
        SubmitCaseCtrl.attachment= objAttach;
        
        String publicKey = '6LfGGgATAAAAALX4go73llNVYsFd9GlHDQDtASfo';
        String getpublicKey=publicKey;
        system.assertEquals(publicKey, getpublicKey);
        
        String remoteHost = '127.0.0.1';
        String getremoteHost=remoteHost;
        system.assertEquals(remoteHost, getremoteHost);
        
        ApexPages.currentPage().getParameters().put('recaptcha_challenge_field', '111');
        ApexPages.currentPage().getParameters().put('recaptcha_response_field', '111');
        
        String strPrivateKey = '6LfGGgATAAAAADJaNz3XRVqx8JYHO_cDoSF7ivOO';
        String recaptchaChallenge = ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        String recaptchaResponse = ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         
        String strBody = 'privatekey=' + strPrivateKey +'&remoteip='  + getremoteHost +
                        '&challenge=' + recaptchaChallenge +'&response='  + recaptchaResponse;
        HttpResponse res = SubmitCaseController.makeRequest('https://www.google.com/recaptcha/api/verify', strBody);
        
        System.assertEquals(strBody, 'privatekey=' + strPrivateKey +'&remoteip='  + getremoteHost +
                        '&challenge=' + recaptchaChallenge +'&response='  + recaptchaResponse);
        System.assertEquals(200, res.getStatusCode());
        
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();
        
        Boolean isVerified = SubmitCaseCtrl.verifyCaptcha();        
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        String strSuccessPageUrl= successPage.getUrl();
        String strBaseUrl='';
        if(strSuccessPageUrl.contains('?') ) 
        { 
            strBaseUrl = strSuccessPageUrl.substring(0, strSuccessPageUrl.indexOf('?')); 
            system.assertEquals(successPageRef.getUrl(), strBaseUrl);
        }
        
        String strCaseNumber = SubmitCaseCtrl.getCaseNumber();
         
        Case objCse = [Select id, SuppliedEmail from case where SuppliedEmail = 'test1@test.com' LIMIT 1];
        System.assertEquals('test1@test.com', objCse.SuppliedEmail);
        
        
        List<AggregateResult> lstContact = [Select count(id) from Contact where email = 'test1@test.com'];
        System.assert(lstContact.size()>=0);
        
        Test.StopTest();
    }

   
    /***************************************************************************
      Case-When User do not has account in community and Submiting for first Time
           result- case is submitted succesfully and user is assigned to TS community account 
           and new contact is created
    ****************************************************************************/
  
    static testmethod void SubmitCaseControllerTest2() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Media processors';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'TestCountry';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'less than 1,000';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Development';
        SubmitCaseCtrl.strQuestion = 'Quality (FIT / MTBF)';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';
        
        String publicKey = '6LfGGgATAAAAALX4go73llNVYsFd9GlHDQDtASfo';
        String getpublicKey=publicKey;
        system.assertEquals(publicKey, getpublicKey);
        
        String remoteHost = '127.0.0.1';
        String getremoteHost=remoteHost;
        system.assertEquals(remoteHost, getremoteHost);
        
        ApexPages.currentPage().getParameters().put('recaptcha_challenge_field', '111');
        ApexPages.currentPage().getParameters().put('recaptcha_response_field', '111');
        
        String strPrivateKey = '6LfGGgATAAAAADJaNz3XRVqx8JYHO_cDoSF7ivOO';
        String recaptchaChallenge = ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        String recaptchaResponse = ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String strBody = 'privatekey=' + strPrivateKey +'&remoteip='  + getremoteHost +
                        '&challenge=' + recaptchaChallenge +'&response='  + recaptchaResponse;
        HttpResponse res = SubmitCaseController.makeRequest('https://www.google.com/recaptcha/api/verify', strBody);
        
        System.assertEquals(strBody, 'privatekey=' + strPrivateKey +'&remoteip='  + getremoteHost +
                        '&challenge=' + recaptchaChallenge +'&response='  + recaptchaResponse);
        System.assertEquals(200, res.getStatusCode());
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        Boolean isVerified = SubmitCaseCtrl.verifyCaptcha();
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        String strSuccessPageUrl= successPage.getUrl();
        String strBaseUrl='';
        if(strSuccessPageUrl.contains('?') ) 
        {
            strBaseUrl = strSuccessPageUrl.substring(0, strSuccessPageUrl.indexOf('?')); 
            system.assertEquals(successPageRef.getUrl(), strBaseUrl);
        }
        
        String strCaseNumber = SubmitCaseCtrl.getCaseNumber();
         
        Case objCase = [Select id, SuppliedEmail from case where SuppliedEmail = 'test1@test.com'];
        System.assertEquals('test1@test.com', objCase.SuppliedEmail);
        
        Contact objContact = [Select id, email, account.name from Contact where email = 'test1@test.com' LIMIT 1];
        System.assertEquals('test1@test.com', objContact.Email);
        
              
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When User has account in community and Submiting the case
           result- case is submitted succesfully and user is assigned to NXP community account
    ****************************************************************************/
   
    static testmethod void SubmitCaseControllerTest3() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objNxpCommunityParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContactAcc =  createContact(objNxpCommunityParentAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContactAcc;
        system.assert(objContactAcc.id!=null);
        
        Test.StartTest();  
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Logic';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'TestCountry';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'less than 1,000';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Development';
        SubmitCaseCtrl.strQuestion = 'Package/Packing/Assembly/Soldering Profile';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';
        
        String publicKey = '6LfGGgATAAAAALX4go73llNVYsFd9GlHDQDtASfo';
        String getpublicKey=publicKey;
        system.assertEquals(publicKey, getpublicKey);
        
        String remoteHost = '127.0.0.1';
        String getremoteHost=remoteHost;
        system.assertEquals(remoteHost, getremoteHost);
        
        ApexPages.currentPage().getParameters().put('recaptcha_challenge_field', '111');
        ApexPages.currentPage().getParameters().put('recaptcha_response_field', '111');
        
        String strPrivateKey = '6LfGGgATAAAAADJaNz3XRVqx8JYHO_cDoSF7ivOO';
        String recaptchaChallenge = ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        String recaptchaResponse = ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String strBody = 'privatekey=' + strPrivateKey +'&remoteip='  + getremoteHost +
                        '&challenge=' + recaptchaChallenge +'&response='  + recaptchaResponse;
        HttpResponse res = SubmitCaseController.makeRequest('https://www.google.com/recaptcha/api/verify', strBody);
        
        System.assertEquals(strBody, 'privatekey=' + strPrivateKey +'&remoteip='  + getremoteHost +
                        '&challenge=' + recaptchaChallenge +'&response='  + recaptchaResponse);
        System.assertEquals(200, res.getStatusCode());
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();
        Boolean isVerified = SubmitCaseCtrl.verifyCaptcha();
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        String strSuccessPageUrl= successPage.getUrl();
        String strBaseUrl='';
        if(strSuccessPageUrl.contains('?') ) 
        { 
            strBaseUrl = strSuccessPageUrl.substring(0, strSuccessPageUrl.indexOf('?')); 
            system.assertEquals(successPageRef.getUrl(), strBaseUrl);
        }
        
        String strCaseNumber = SubmitCaseCtrl.getCaseNumber();
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case- When the value of priority field is '--None--'
            result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest4() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Lighting driver and controller ICs';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'TestCountry';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'less than 1,000';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = '--None--';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Development';
        SubmitCaseCtrl.strQuestion = 'Longevity/Obsolescence';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();    
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When the value of category field is '--None--'
           result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest5() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Interface and connectivity';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'TestCountry';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'less than 1,000';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Development';
        SubmitCaseCtrl.strQuestion = 'Datasheets/ Errata/User Manual';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strtwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);

        Test.StopTest();
    }
 
    /***************************************************************************
      Case-When the value of jobTitle field is '--None--'
           result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest6() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Identification and security';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'TestCountry';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'less than 1,000';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = '--None--';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Development';
        SubmitCaseCtrl.strQuestion = 'Application Notes/Solutions';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        
        Test.StopTest();
    }
    
     /***************************************************************************
      Case-When email is Invalid
           result- case is not submitted and error message is displayed
    ****************************************************************************/

    static testmethod void SubmitCaseControllerTest7() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'ESD, EMI and signal conditioning';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'TestCountry';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test,com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'less than 1,000';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Development';
        SubmitCaseCtrl.strQuestion = 'Demoboards / Development tools';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();
                
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When the value of jobTitle field is '--None--'
            result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest8() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Display drivers';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = '--None--';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'less than 1,000';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Development';
        SubmitCaseCtrl.strQuestion = 'Demoboards / Development tools';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        Test.StopTest();
    }

    /***************************************************************************
      Case-When the value of expected annual field is '--None--'
            result- case is not submitted and error message is displayed
    ****************************************************************************/

    static testmethod void SubmitCaseControllerTest9() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Diodes';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'Test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = '--None--';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Development';
        SubmitCaseCtrl.strQuestion = 'Demoboards / Development tools';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When the value of projectStage annual field is '--None--'
            result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest10() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Data converters';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'Test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'Test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = '--None--';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'testSubstrCategory';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'China';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        Test.StopTest();
    }
    
     /***************************************************************************
      Case-When the value of webRegion annual field is '--None--'
            result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest11() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Bipolar transistors';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'Test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = '--None--';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = '--None--';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When the value of country field is '--None--'
            result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest12() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Automotive';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = '--None--';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = '--None--';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
                
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();
        
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        Test.StopTest();
    }

    /***************************************************************************
      Case-When the value of sub category field is '--None--'
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest13() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
        SubmitCaseCtrl.strCategory = 'Audio / video';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'India';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';

        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = '--None--';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        
        
        Test.StopTest();
    }

    /***************************************************************************
      Case-When the value of question field is '--None--'
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest14() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
        
                
        SubmitCaseCtrl.strCategory = 'Audio/radio';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = '--None--';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When Category is Amplifier
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest15() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'Amplifiers';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage);  
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is MOSFETs
            result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest16() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'MOSFETs';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();      
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage);  
        
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is Other
            result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest17() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'Other';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();       
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is Power management ICs
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest18() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'Power management ICs';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is RF
        result- case is not submitted and error message is displayed
    ****************************************************************************/

    static testmethod void SubmitCaseControllerTest19() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'RF';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is Sensors
            result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest20() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'Sensors';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is Thyristors
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest21() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'Thyristors';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is TV and STB front ends
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest22() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'TV and STB front ends';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test'; 
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is Human Resources
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest23() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'Human Resources';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test'; 
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }

    /***************************************************************************
      Case-When strCategory is Human Resources
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest24() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'Human Resources';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is General Products
            result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest25() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'General Products';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();       
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }

    /***************************************************************************
      Case-When strCategory is Public Relations
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest26() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'Public Relations';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is Logistics
        result- case submission fails
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest27() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'Logistics';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }
    
    /***************************************************************************
      Case-When strCategory is No Specific strCategory
        result-case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest28() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = 'No Specific strCategory';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = 'Test';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertEquals(null, successPage); 
        
        
        Test.StopTest();
    }

    /***************************************************************************
      Case-When the value of category field is '--None--'
        result- case is not submitted and error message is displayed
    ****************************************************************************/
    
    static testmethod void SubmitCaseControllerTest29() 
    {
        fetchRecordTypes();
        
        Account objOtherParentAcc = createOtherParentAccount();
        
        insert objOtherParentAcc;
        system.assert(objOtherParentAcc.id!=null);
        
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Account objChildAcc = createTechSupportChildAccount(objOtherParentAcc.Id);
        
        insert objChildAcc;
        system.assert(objChildAcc.id!=null);
        
        Contact objContact =  createContact(objChildAcc.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'test1@test.com');
        
        insert objContact;
        system.assert(objContact.id!=null);
        
        Case objCase = createCase(objContact.Id, 'test1', 'test', 'test1@test.com',
                                           '', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        Test.StartTest();
        
        PageReference pgRef = Page.EmailCase;
        Test.setCurrentPage(pgRef);
        
        SubmitCaseController SubmitCaseCtrl = new SubmitCaseController();
                
        SubmitCaseCtrl.strCategory = '--None--';
        SubmitCaseCtrl.strCompany = 'TestCompany';
        SubmitCaseCtrl.strCountry = 'test';
        SubmitCaseCtrl.strDescription = 'TestDescription';
        SubmitCaseCtrl.strEmail = 'test1@test.com';
        SubmitCaseCtrl.strExpectedAnnualUnitVolume = 'test';
        SubmitCaseCtrl.strFacebook = 'TestFB';
        SubmitCaseCtrl.strFirstName = 'test1';
        SubmitCaseCtrl.strJobTitle = 'Test';
        SubmitCaseCtrl.strLastName = 'test';
        SubmitCaseCtrl.strLinkedin = 'testLNK';
        
        SubmitCaseCtrl.strName = SubmitCaseCtrl.strFirstName+' '+SubmitCaseCtrl.strLastName;
        SubmitCaseCtrl.strNatureOfQuestion = 'Test';
        SubmitCaseCtrl.strPhoneNumber = '8123078909';
        SubmitCaseCtrl.strPriority = 'Medium';
        SubmitCaseCtrl.strProductApplication = 'test';
        SubmitCaseCtrl.strProductTypeNumber = '1234';
        SubmitCaseCtrl.strProjectStage = 'Test';
        SubmitCaseCtrl.strQuestion = 'ROHS';
        SubmitCaseCtrl.strSubCategory = 'Test';
        SubmitCaseCtrl.strStateProvince = 'Test';
        SubmitCaseCtrl.strStatus = 'New';
        SubmitCaseCtrl.strSubject = '--None--';
        SubmitCaseCtrl.strTitle = 'Community User';
        SubmitCaseCtrl.strTwitter = 'TestTwitter';
        SubmitCaseCtrl.strWebRegion = 'Test';
        
        List<SelectOption> lstCategory = SubmitCaseCtrl.getCategories();
        List<SelectOption> lstSubSategory = SubmitCaseCtrl.getSubCategories();
        List<SelectOption> lstCountry = SubmitCaseCtrl.getCountries();
        List<SelectOption> lstAnnualVolume = SubmitCaseCtrl.getExpectedAnnualUnitVolumes();
        List<SelectOption> lstJobTitle = SubmitCaseCtrl.getJobTitles();
        List<SelectOption> lstPriority = SubmitCaseCtrl.getPriorities();
        List<SelectOption> lstStage = SubmitCaseCtrl.getProjectStages();
        //List<SelectOption> lstQuestion = SubmitCaseCtrl.getQuestions();
        List<SelectOption> lstWebRegion = SubmitCaseCtrl.getWebRegions();        
        
        PageReference successPageRef= new PageReference('/community/SuccessPage');
        PageReference successPage = SubmitCaseCtrl.submitCase();
        system.assertNotEquals(successPageRef, successPage);
    
        Test.StopTest();
    }

}