/***************************************************************************************************
@Created By :      Amrutha R
@Created Date:     01 June 2015
@Description:      Test class for CommunityChatterQuestionReplyTrigger
*******************************************************************************************************/

@istest
public class CommunityChatterQuestionReplyTriggerTest 
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
    
    private static Filtered_Words__c CreateFilteredWords()
    {
        Filtered_Words__c objFilter= new Filtered_Words__c(Name='get');
        return objFilter;
    }
    
    //test method which inserts question and reply whose body and title contains filtered words
    static testmethod void CommunityChatterQuestionReplyTriggerTest1()
    {
        Test.startTest();
		fetchRecordType();
  		
        User objUser= createUser();
        insert objUser;
        system.assert(objUser.Id!=null);
        
        Filtered_Words__c objFilter= CreateFilteredWords();
        insert objFilter;
        system.assert(objFilter.Id!=null);
        
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.EmailVerficationLink__c= 'https://develop12-nxpcommunity.cs8.force.com/community';
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            Question objQues = new Question ();
   			objQues.title = 'How much vacation time do full-time employees get?';
            objQues.body = 'How much vacation time do full-time employees get?';
   			Community community = [ SELECT Id FROM Community WHERE Name = 'Success Stories' ];
   			objQues.communityId = community.id;
            insert objQues;
            
            Reply objRep= new Reply();
            objRep.QuestionId =objQues.id;
            objRep.body = 'How much vacation time do full-time employees get?';
            insert objRep;
        }
        test.stopTest();
    }
    
    //test method which inserts question and reply whose body and title doesnot contains filtered words
    static testmethod void CommunityChatterQuestionReplyTriggerTest2()
    {
        Test.startTest();
		fetchRecordType();
  		
        User objUser= createUser();
        insert objUser;
        system.assert(objUser.Id!=null);
        
        Filtered_Words__c objFilter= CreateFilteredWords();
        insert objFilter;
        system.assert(objFilter.Id!=null);
        
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.EmailVerficationLink__c= 'https://develop12-nxpcommunity.cs8.force.com/community';
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            Question objQues = new Question ();
   			objQues.title = 'How much vacation time do full-time employees?';
            objQues.body = 'How much vacation time do full-time employees get?';
   			Community community = [ SELECT Id FROM Community WHERE Name = 'Success Stories' ];
   			objQues.communityId = community.id;
            insert objQues;
            
            Reply objRep= new Reply();
            objRep.QuestionId =objQues.id;
            objRep.body = 'How much vacation time do full-time employees?';
            insert objRep;
        }
        test.stopTest();
    }
}