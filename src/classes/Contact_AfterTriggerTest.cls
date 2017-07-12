/**************************************************************************************
 @Modified By 		Nisha Agrawal
 @Modified Date 	Aug 31, 2016
 @Description 		Updated test class for Email duplicate issue in Contact SIR 1155
*******************************************************************************************/
@isTest
public class Contact_AfterTriggerTest {

    Static Final String CASE_TSCOMMUNITY = 'TS_Community';
    final static String CASE_TSWEBMASTER = 'TS_Webmaster';
    final static String ACCOUNT_CHILDACCOUNT = 'Child_Account';
    final static String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    Static Final String Case_Origin = 'Community';

    public static RecordType ObjCaseTSCOMMUNITY;
    public static RecordType ObjCaseWebMaster;
    public static RecordType ObjAccountChildAccount;
    public static RecordType ObjAccountParentAccount;
    
    public static void fetchRecordTypes()
    {      
         ObjCaseTSCOMMUNITY=[Select Id, DeveloperName
                       From RecordType Where IsActive=true and
                       (SobjectType = 'Case' and 
                        DeveloperName =: CASE_TSCOMMUNITY
                       )
                       limit 1];
        
        ObjCaseWebMaster=[Select Id, DeveloperName
                       From RecordType Where IsActive=true and
                       (SobjectType = 'Case' and 
                        DeveloperName =: CASE_TSWEBMASTER 
                       )
                       limit 1];
        
        ObjAccountChildAccount=[Select Id, DeveloperName
                            From RecordType Where IsActive=true and
                            (SobjectType = 'Account' and 
                            DeveloperName =: ACCOUNT_CHILDACCOUNT 
                            )
                            limit 1];
        
        ObjAccountParentAccount=[Select Id, DeveloperName
                            From RecordType Where IsActive=true and
                            (SobjectType = 'Account' and 
                            DeveloperName =: ACCOUNT_ParentACCOUNT 
                            )
                            limit 1];
        
    }
    
    private Static Account objParentAccount1;    
    private static Account createParentAccount1()
    {
        objParentAccount1 = new Account(RecordTypeID= ObjAccountParentAccount.ID,
                                                Name = 'Other', Customer_Category__c= 'Longtail');
        return  objParentAccount1;
    }
    
    private Static Account objParentAccount2;    
    private static Account createParentAccount2()
    {
        objParentAccount2 = new Account(RecordTypeID= ObjAccountParentAccount.ID,
                                                Name = 'NXP Community', Customer_Category__c= 'Longtail');
        return  objParentAccount2;
    }
    
    //Method to create a TechSupport Child Account
    private static Account createChildAccount(ID parentAccountId)
    {
        //hd
        Account objChildAccount = new Account(RecordTypeID= ObjAccountChildAccount.ID,ParentId = parentAccountId,  
                                            Name = 'Technical Services', Region__c = 'Japan',
                                             Sales_Area__c = 'Japan ID', Industry_Segment__c = 'Mobile',
                                             Country__c = 'Austria');
        return objChildAccount;    
    }
    
    //Method to create a list of Contacts
    private static Contact createContact(ID accountID, String firstName, String lastName,
                                                 String title, String phoneNo, String email)
    {
        
           Contact objContact=new Contact(FirstName=firstName,LastName=lastName, Title = title,
                                          Phone = phoneNo, email = email, AccountID = accountID);              
                
           return objContact;        
        
    }
    
    private static List<Case> createlstCases(String firstName, String lastName, ID contactID,
                                            String email, String priority, String productCategory,
                                            String productSubCategory, String subject, String description,
                                            String jobTitle, String facebook, String company, String linkedin, 
                                            String twitter, String state, String productApplication, String country,
                                            String expectedAnnualUnitVolume, String projectStage, String webRegion,
                                            String productTypeNumber, String question)
    {
        //one time
        List<Case> lstCases=new List<Case>();
        //To DO ONe Case Insert   
        for( Integer i=0 ; i < 2 ; i++ )
        {
           Case objCase=new Case(RecordTypeID = ObjCaseTSCOMMUNITY.Id, Status= 'New', Priority = priority, 
                                 Product_Category__c = productCategory, Product_Sub__c = productSubCategory, 
                                 SuppliedName = firstName+' '+lastName, SuppliedEmail=email, 
                                 ContactId = contactID, JobTitle__c = jobTitle, Facebook__c = facebook,
                                 Company__c = company, Linkedin__c = linkedin, Community_Web_Country__c = country,
                                 Twitter__c = twitter, State_Province__c = state, Product_Type_Number__c = productTypeNumber,
                                 Subject = subject, My_Question_is_Related__c = question, Description = description,
                                 Product_application__c = productApplication, Expected_annual_unit_volume__c = expectedAnnualUnitVolume,
                                 Project_Stage__c = projectStage, Web_Region__c = webRegion, origin =  Case_Origin);
           lstCases.add(objCase); 
        }
        return lstCases;
    }
    
    /***************************************************************************
      Case 1-When User Sign Up to Community case will be attach 
    ****************************************************************************/
    
    static testmethod void SubmitCase1() 
    {
        //Prepare the test data
        
        fetchRecordTypes();
        
        Account objParent1 = createParentAccount1();
        
        insert objParent1;
        
        Account objParent2 = createParentAccount2();
        
        insert objParent2;
        
        Account objChild = createChildAccount(objParent1.Id);
        
        insert objChild;
        
        Test.StartTest();
        
        Contact objContact =  createContact(objParent2.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'prakhar.gupta@nxp.com');
        
        insert objContact; 
        
        System.assertEquals('prakhar.gupta@nxp.com', objContact.Email );
        
        List<Case> lstCase = createlstCases('test1', 'test',  objContact.Id, objContact.Email,
                                           'Medium', 'RF', 'Mixers', 'test_subject', 'test_description',
                                           'Other', 'test_fb', 'test_Company', 'test_lnk', 'test_twt',
                                           'test_state', 'testApp', 'test_country', '20000', 'Development',
                                           'China', 'test', 'ROHS');
        
        insert lstCase ;        
        
        //changed by Nisha on Sep 01 for duplicate email issue
        Contact objContact1 =  createContact(objParent2.Id, 'test1', 'test', 'title', 
                                              '8123978919', 'prakhar.gupta1@nxp.com');

        insert objContact1;
        
        Test.StopTest();
    }
}