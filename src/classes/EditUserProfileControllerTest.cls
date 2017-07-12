/*********************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     09 Feb 2015
Description :      Class for NXP community users to edit profile
****************************************************************************************************/

@istest(SeeAllData=True)
public class EditUserProfileControllerTest 
{
    //case: positive case to update contact information
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    public static RecordType parentAccount;
    
    
    private static void fetchRecordType()
    {
        parentAccount=[Select Id, DeveloperName
                            From RecordType Where IsActive=true and
                            (SobjectType = 'Account' and 
                            DeveloperName =: ACCOUNT_ParentACCOUNT 
                            )
                            limit 1];
    } 
    
    private static Account createNxpCommunityParentAccount()
    {
        //Method to create a 'NXP Community' Parent Account
        Account objNxpCommunityParentAccount;
        objNxpCommunityParentAccount = new Account(RecordTypeID= parentAccount.ID,
                                                Name = 'NXP Community', Customer_Category__c= 'Longtail');
        return  objNxpCommunityParentAccount;
    } 
    
    //Method to create a  Contact
    private static Contact createContact()
    {
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@test.com', AccountID = objNxpCommunityParentAcc.Id);              
                
        return objContact;        
        
    }
    
    private static User CreateUser()
    {
        Contact objContact= createContact();
        insert objContact;
        system.assert(objContact.Id!=null);
        
        Profile objProfile= [SELECT Id FROM Profile WHERE name='NXP Customer Community Login User' Limit 1];
        User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',
                                contactId=objContact.Id);
        return objUser;
    }

    
    static testmethod void EditUserProfileControllerTest1() 
    {
        Test.startTest();
        fetchRecordType();
        
        User objUser= createUser();
        insert objUser;
        system.assert(objUser.Id!=null);
        
        Contact objContact=[select id from contact where id=: objUser.ContactId];
        
        
        system.runAs(objUser)
        {
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objContact);
            EditUserProfileController editUserCtrl = new EditUserProfileController(stdCtrl);
            
            editUserCtrl.objUser= objUser;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='Marketing';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='test';
            editUserCtrl.objCont= objContact;
            system.assert(editUserCtrl.objCont== objContact);
            string res= 'https://ap1.salesforce.com/resource/1377118388000/sample_pic';
            EditUserProfileController.strFileName='myFile';
            EditUserProfileController.blobValue=blob.valueof(res);
            editUserCtrl.contentType='image/jpg';
            editUserCtrl.fileSize=1;
            
            editUserCtrl.editContact();
            system.assert(editUserCtrl.editContact()==null);

        }
        Test.stopTest();
    }                      

    
    //case: negative case which displays error message as jobtitle is '--None--'
    static testmethod void EditUserProfileControllerTest2() 
    {
        Test.startTest();
        fetchRecordType();
        
        User objUser= createUser();
        insert objUser;
        system.assert(objUser.Id!=null);
        
        system.runAs(objUser)
        {
            Contact objContact=[select id from contact where id=: objUser.ContactId];

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objContact);
            EditUserProfileController editUserCtrl = new EditUserProfileController(stdCtrl);
            
            editUserCtrl.objUser= objUser;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='--None--';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='test';
            editUserCtrl.objCont= objContact;
            system.assert(editUserCtrl.objCont== objContact);
            
            editUserCtrl.editContact();
            system.assert(editUserCtrl.editContact()==null);

        }
        Test.stopTest();

    }

    //case: negative case which displays error message as company is '--None--'
    static testmethod void EditUserProfileControllerTest3() 
    {
        Test.startTest();
        fetchRecordType();
        
        User objUser= createUser();
        insert objUser;
        system.assert(objUser.Id!=null);
        
        system.runAs(objUser)
        {
            Contact objContact=[select id from contact where id=: objUser.ContactId];

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objContact);
            EditUserProfileController editUserCtrl = new EditUserProfileController(stdCtrl);
            
            editUserCtrl.objUser= objUser;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='test';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='--None--';
            objContact.Web_Region__c='test';
            editUserCtrl.objCont= objContact;
            system.assert(editUserCtrl.objCont== objContact);
            
            editUserCtrl.editContact();
            system.assert(editUserCtrl.editContact()==null);

        }
        Test.stopTest();

    }
    
    //case: negative case which displays error message as web region is '--None--'
    static testmethod void EditUserProfileControllerTest4() 
    {
        Test.startTest();
        fetchRecordType();
        
        User objUser= createUser();
        insert objUser;
        system.assert(objUser.Id!=null);
        
        system.runAs(objUser)
        {
            Contact objContact=[select id from contact where id=: objUser.ContactId];

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(objContact);
            EditUserProfileController editUserCtrl = new EditUserProfileController(stdCtrl);
            
            editUserCtrl.objUser= objUser;
            objContact.Phone='9988556622';
            objContact.Company__c='test';
            objContact.Job_Title__c='test';
            objContact.State_Province__c='test';
            objContact.Community_web_country__c='test';
            objContact.Web_Region__c='--None--';
            editUserCtrl.objCont= objContact;
            system.assert(editUserCtrl.objCont== objContact);
            
            editUserCtrl.editContact();
            system.assert(editUserCtrl.editContact()==null);

        }
        Test.stopTest();

    }
}