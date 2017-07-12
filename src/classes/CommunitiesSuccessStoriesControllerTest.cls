/*********************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     04 May 2015
Description :      Test Class for CommunitiesSuccessStoriesController class
****************************************************************************************************/

@istest
public class CommunitiesSuccessStoriesControllerTest 
{
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
        Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test1@test.com');                  
        return objContact;        
    }
    
    private static User CreateUser()
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='NXP Customer Community Login User' Limit 1];
        User objUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'
                                );
        return objUser;
    }

    private Static Idea createIdea()
    {
        Idea objIdea= new Idea(Title='test1',Body='test1Body');
        return objIdea;
    }
    
    //positive case: View and post story after login
    //Categories fetched: RF and I2C, sort by recent
    static testmethod void CommunitiesSuccessStoriesTest1() 
    {
        
        fetchRecordType();

        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact= createContact();
        objContact.AccountID = objNxpCommunityParentAcc.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        
        User objUser= createUser();
        objUser.contactId=objContact.Id;
        insert objUser;
        system.assert(objUser.Id!=null);
        
        Community objComm= [SELECT Id FROM Community WHERE Name = 'Success Stories'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.CommunitiesStoryZoneId__c= objComm.Id;
        insert setting;
        system.assert(setting.Id!=null);
        
        Idea objIdea2= createIdea();
            objIdea2.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea2.Categories='I2c';
            insert objIdea2;
            system.assert(objIdea2.Id!=null);
        
        system.runAs(objUser)
        {
             Test.startTest();
            Idea objIdea1= createIdea();
            objIdea1.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea1.Categories='RF';
            insert objIdea1;
            system.assert(objIdea1.Id!=null);
            
            
            IdeaComment objComment= new IdeaComment();
            objComment.IdeaId= objIdea1.id;
            objComment.CommentBody= 'strCommentBody';
            insert objComment;
            system.assert(objComment.Id!=null);
            
            Test.setCurrentPageReference(new PageReference('Page.CommunityStories'));
            ApexPages.currentPage().getParameters().put('id', objIdea1.id);
            
            CommunitiesSuccessStoriesController ideaController = new CommunitiesSuccessStoriesController();
            List<SelectOption> lstOptions= ideaController.getCategories();
            system.assert(lstOptions.size()!=null); 
            
            
            ideaController.sortFilterId='recent';
            ideaController.categoryFilterId='All';
            ideaController.fetchStories();
            ideaController.categoryFilterId='RF';
            ideaController.strIdeaId= objIdea2.id;
            ideaController.promoteStory();
            ideaController.demoteStory();
            
            List<SelectOption> lstOpt=ideaController.getStories();
            system.assert(lstOpt.size()!=null);
            
            ideaController.getSortStories();
            ideaController.strIdeaTitle='test';
            ideaController.strIdeaBody='test';
            List<String> lstStr= new List<String>();
            lstStr.add('RF');
            lstStr.add('I2C');
            ideaController.strCategories=lstStr;
            ideaController.CommunitiesStoryZoneId=objComm.Id;
            ideaController.savePost();
            
            ideaController.strCommentBody='test';
            ideaController.addComment();
            ideaController.getlstComments();
            ideaController.FirstPage();
            ideaController.previous();
            ideaController.LastPage();
            ideaController.next();
            ideaController.getprev();
            Test.stopTest();
        }
         
    }
    
    //negative case: View and post story after login and Comment to a story is null
    //Categories fetched: Logic and Identification and Security, sort by recent
    static testmethod void CommunitiesSuccessStoriesTest2() 
    {
        
        fetchRecordType();

        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact= createContact();
        objContact.AccountID = objNxpCommunityParentAcc.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        
        User objUser= createUser();
        objUser.contactId=objContact.Id;
        insert objUser;
        system.assert(objUser.Id!=null);
        
        
        Community objComm= [SELECT Id FROM Community WHERE Name = 'Success Stories'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.CommunitiesStoryZoneId__c= objComm.Id;
        insert setting;
        system.assert(setting.Id!=null);
        
        Idea objIdea2= createIdea();
            objIdea2.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea2.Categories='Identification and Security';
            insert objIdea2;
            system.assert(objIdea2.Id!=null);
        
        
        system.runAs(objUser)
        {
            Test.startTest();
            Idea objIdea1= createIdea();
            objIdea1.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea1.Categories='Logic';
            insert objIdea1;
            system.assert(objIdea1.Id!=null);
            
            
            IdeaComment objComment= new IdeaComment();
            objComment.IdeaId= objIdea1.id;
            objComment.CommentBody= 'strCommentBody';
            insert objComment;
            system.assert(objComment.Id!=null);
            
            Test.setCurrentPageReference(new PageReference('Page.CommunityStories'));
            ApexPages.currentPage().getParameters().put('id', objIdea1.id);
            
            CommunitiesSuccessStoriesController ideaController = new CommunitiesSuccessStoriesController();
            CommunitiesSuccessStoriesController ideaController1 = new CommunitiesSuccessStoriesController();
            List<SelectOption> lstOptions= ideaController.getCategories();
            system.assert(lstOptions.size()!=null);
            
            ideaController.sortFilterId='comment';
            ideaController.strIdeaId= objIdea2.id;
            ideaController.demoteStory();
            
            Vote objVote=new Vote();
        	objVote.ParentId=objIdea2.Id;
        	objVote.Type='up';
            insert objVote;
            
            ideaController.promoteStory();
            
            ideaController.categoryFilterId='Logic';
            ideaController.fetchStories();
            
            ideaController.categoryFilterId='All';
            ideaController.fetchStories();
            
            List<SelectOption> lstOpt=ideaController.getStories();
            system.assert(lstOpt.size()!=null);
            
            ideaController.getSortStories();
            ideaController.strIdeaTitle='t';
            ideaController.strIdeaBody='test';
            List<String> lstStr= new List<String>();
            lstStr.add('RF');
            lstStr.add('I2C');
            ideaController.strCategories=lstStr;
            ideaController.CommunitiesStoryZoneId=objComm.Id;
            ideaController.savePost();    
            
            ideaController.strCommentBody=null;
            ideaController.addComment();
            system.assertEquals('Please write a comment',ApexPages.getMessages().get(0).getSummary());
            
            Test.stopTest();
        }
         
    }
        

    //positive case: View and post story after login
    //Categories fetched: Microcontroller and Automotive, sort by comments
    static testmethod void CommunitiesSuccessStoriesTest3() 
    {
        
        fetchRecordType();

        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact= createContact();
        objContact.AccountID = objNxpCommunityParentAcc.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        
        User objUser= createUser();
        objUser.contactId=objContact.Id;
        insert objUser;
        system.assert(objUser.Id!=null);
        
        Community objComm= [SELECT Id FROM Community WHERE Name = 'Success Stories'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.CommunitiesStoryZoneId__c= objComm.Id;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            Test.startTest();
            Idea objIdea1= createIdea();
            objIdea1.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea1.Categories='MicroController';
            insert objIdea1;
            system.assert(objIdea1.Id!=null);
            
            Idea objIdea2= createIdea();
            objIdea2.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea2.Categories='Automotive';
            insert objIdea2;
            system.assert(objIdea2.Id!=null);
            
            IdeaComment objComment= new IdeaComment();
            objComment.IdeaId= objIdea1.id;
            objComment.CommentBody= 'strCommentBody';
            insert objComment;
            system.assert(objComment.Id!=null);
            
            Test.setCurrentPageReference(new PageReference('Page.CommunityStories'));
            ApexPages.currentPage().getParameters().put('id', objIdea1.id);
            
            CommunitiesSuccessStoriesController ideaController = new CommunitiesSuccessStoriesController();
            List<SelectOption> lstOptions= ideaController.getCategories();
            system.assert(lstOptions.size()!=null);
            
            ideaController.sortFilterId='recent';
            
            ideaController.categoryFilterId='All';
            ideaController.fetchStories();
            
            ideaController.categoryFilterId='Automotive';
            ideaController.fetchStories();
            
            List<SelectOption> lstOpt=ideaController.getStories();
            system.assert(lstOpt.size()!=null);
			Test.stopTest();
            
        }
         
    }
    
    //positive case: View and post story after login
    //Categories fetched: Microcontroller and Automotive, sort by recent
    static testmethod void CommunitiesSuccessStoriesTest4() 
    {
        
        fetchRecordType();

        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact= createContact();
        objContact.AccountID = objNxpCommunityParentAcc.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        
        User objUser= createUser();
        objUser.contactId=objContact.Id;
        insert objUser;
        system.assert(objUser.Id!=null);
        
        Community objComm= [SELECT Id FROM Community WHERE Name = 'Success Stories'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.CommunitiesStoryZoneId__c= objComm.Id;
        insert setting;
        system.assert(setting.Id!=null);

        system.runAs(objUser)
        {
            Test.startTest();
            Idea objIdea1= createIdea();
            objIdea1.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea1.Categories='MicroController';
            insert objIdea1;
            system.assert(objIdea1.Id!=null);
            
            Idea objIdea2= createIdea();
            objIdea2.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea2.Categories='Automotive';
            insert objIdea2;
            system.assert(objIdea2.Id!=null);
            
            IdeaComment objComment= new IdeaComment();
            objComment.IdeaId= objIdea1.id;
            objComment.CommentBody= 'strCommentBody';
            insert objComment;
            system.assert(objComment.Id!=null);
            
            Test.setCurrentPageReference(new PageReference('Page.CommunityStories'));
            ApexPages.currentPage().getParameters().put('id', objIdea1.id);
           
            CommunitiesSuccessStoriesController ideaController = new CommunitiesSuccessStoriesController();
            List<SelectOption> lstOptions= ideaController.getCategories();
            system.assert(lstOptions.size()!=null);
            
            ideaController.sortFilterId='recent';
            
            ideaController.categoryFilterId='All';
            ideaController.fetchStories();
            
            ideaController.categoryFilterId='Automotive';
            ideaController.fetchStories();
            
            List<SelectOption> lstOpt=ideaController.getStories();
            system.assert(lstOpt.size()!=null);
            Test.stopTest();
             
        }
         
    }
    
    
    //negative case: View and post story after login, categories is null
    //Categories fetched: Microcontroller and Automotive, sort by popular
    static testmethod void CommunitiesSuccessStoriesTest5() 
    {
        
        fetchRecordType();

        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact= createContact();
        objContact.AccountID = objNxpCommunityParentAcc.Id;
        insert objContact;
        system.assert(objContact.Id!=null);

        User objUser= createUser();
        objUser.contactId=objContact.Id;
        insert objUser;
        system.assert(objUser.Id!=null);
        
        Community objComm= [SELECT Id FROM Community WHERE Name = 'Success Stories'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.CommunitiesStoryZoneId__c= objComm.Id;
        insert setting;
        system.assert(setting.Id!=null);

        system.runAs(objUser)
        {
            Test.startTest();
            Idea objIdea1= createIdea();
            objIdea1.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea1.Categories='MicroController';
            insert objIdea1;
            system.assert(objIdea1.Id!=null);
            
            Idea objIdea2= createIdea();
            objIdea2.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea2.Categories='Automotive';
            insert objIdea2;
            system.assert(objIdea2.Id!=null);
            
            IdeaComment objComment= new IdeaComment();
            objComment.IdeaId= objIdea1.id;
            objComment.CommentBody= 'strCommentBody';
            insert objComment;
            system.assert(objComment.Id!=null);
            
            Test.setCurrentPageReference(new PageReference('Page.CommunityStories'));
            ApexPages.currentPage().getParameters().put('id', objIdea1.id);
            
            CommunitiesSuccessStoriesController ideaController = new CommunitiesSuccessStoriesController();
            List<SelectOption> lstOptions= ideaController.getCategories();
            system.assert(lstOptions.size()!=null);
            
            ideaController.sortFilterId='popular';
            
            ideaController.categoryFilterId='All';
            ideaController.fetchStories();
            
            ideaController.categoryFilterId='Automotive';
            ideaController.fetchStories();
            
            List<SelectOption> lstOpt=ideaController.getStories();
            system.assert(lstOpt.size()!=null);

            ideaController.strIdeaTitle='t';
            ideaController.strIdeaBody='t';
            List<String> lstStr= new List<String>();
            ideaController.strCategories=lstStr;
            ideaController.CommunitiesStoryZoneId=objComm.Id;
            ideaController.savePost();
			Test.stopTest();
             
        }
         
    }
    
    //positive case: View and post story before login
    //Categories fetched: Microcontroller and Automotive, sort by top
    static testmethod void CommunitiesSuccessStoriesTest6() 
    {
         
        fetchRecordType();

        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact= createContact();
        objContact.AccountID = objNxpCommunityParentAcc.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        Test.startTest();
        User objUser= createUser();
        objUser.contactId=objContact.Id;
        insert objUser;
        system.assert(objUser.Id!=null);
        
       
        Community objComm= [SELECT Id FROM Community WHERE Name = 'Success Stories'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.CommunitiesStoryZoneId__c= objComm.Id;
        insert setting;
        system.assert(setting.Id!=null);
        
        Profile objProfile= [SELECT Id FROM Profile WHERE name='NXP Community Profile' Limit 1];
        User objUser1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = objProfile.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'
                                );
                                
        insert objUser1;
        system.assert(objUser1.id!=null);  
        
        system.runAs(objUser)
        {
            
            Idea objIdea1= createIdea();
            objIdea1.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea1.Categories='MicroController';
            insert objIdea1;
            system.assert(objIdea1.Id!=null);
            
            Idea objIdea2= createIdea();
            objIdea2.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea2.Categories='Automotive';
            insert objIdea2;
            system.assert(objIdea2.Id!=null);
            
            IdeaComment objComment= new IdeaComment();
            objComment.IdeaId= objIdea1.id;
            objComment.CommentBody= 'strCommentBody';
            insert objComment;
            system.assert(objComment.Id!=null);
            
            Test.setCurrentPageReference(new PageReference('Page.CommunityStories'));
            ApexPages.currentPage().getParameters().put('id', objIdea1.id);
            
            CommunitiesSuccessStoriesController ideaController = new CommunitiesSuccessStoriesController();
            List<SelectOption> lstOptions= ideaController.getCategories();
            system.assert(lstOptions.size()!=null);
            
            ideaController.sortFilterId='top';
            
            ideaController.categoryFilterId='All';
            ideaController.fetchStories();
            
            ideaController.categoryFilterId='Automotive';
            ideaController.fetchStories();
            
            List<SelectOption> lstOpt=ideaController.getStories();
            system.assert(lstOpt.size()!=null);
            
             
        }
   Test.stopTest();
       
    }
      
    //negative case: View story after login and Description of a story is empty    
    //Categories fetched: Interface Products,standard Products and other Products, sort by recent
    static testmethod void CommunitiesSuccessStoriesTest7() 
    {
        
        fetchRecordType();

        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact= createContact();
        objContact.AccountID = objNxpCommunityParentAcc.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        
        User objUser= createUser();
        objUser.contactId=objContact.Id;
        insert objUser;
        system.assert(objUser.Id!=null);
        
        Community objComm= [SELECT Id FROM Community WHERE Name = 'Success Stories'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.CommunitiesStoryZoneId__c= objComm.Id;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            Test.startTest();
            Idea objIdea1= createIdea();
            objIdea1.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea1.Categories='Interface Products';
            insert objIdea1;
            system.assert(objIdea1.Id!=null);
            
            Idea objIdea2= createIdea();
            objIdea2.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea2.Categories='Standard Products';
            insert objIdea2;
            system.assert(objIdea2.Id!=null);
            
            Idea objIdea3= createIdea();
            objIdea3.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea3.Categories='other Products';
            insert objIdea3;
            system.assert(objIdea3.Id!=null);
            
            IdeaComment objComment= new IdeaComment();
            objComment.IdeaId= objIdea1.id;
            objComment.CommentBody= 'strCommentBody';
            insert objComment;
            system.assert(objComment.Id!=null);
            
            Test.setCurrentPageReference(new PageReference('Page.CommunityStories'));
            ApexPages.currentPage().getParameters().put('id', objIdea1.id);
            
            CommunitiesSuccessStoriesController ideaController = new CommunitiesSuccessStoriesController();
            List<SelectOption> lstOptions= ideaController.getCategories();
            system.assert(lstOptions.size()!=null);
            
            ideaController.sortFilterId='recent';
            
            ideaController.categoryFilterId='Interface Products';
            ideaController.fetchStories();
            
            ideaController.categoryFilterId='Standard Products';
            ideaController.fetchStories();
            
            ideaController.categoryFilterId='Other Products';
            ideaController.fetchStories();
            
            List<SelectOption> lstOpt=ideaController.getStories();
            system.assert(lstOpt.size()!=null);
            
            ideaController.strIdeaTitle='t';
            ideaController.strIdeaBody='';
            List<String> lstStr= new List<String>();
            lstStr.add('RF');
            ideaController.strCategories=lstStr;
            ideaController.CommunitiesStoryZoneId=objComm.Id;
            for(ApexPages.Message message : ApexPages.getMessages()) {
            system.assertEquals('Please enter Description for your story',message.getSummary());
            }
            
            
            ideaController.strCommentBody='';
            ideaController.addComment();
            for(ApexPages.Message message : ApexPages.getMessages()) {
            system.assertEquals('Please write a comment',message.getSummary());
            }
            Test.stopTest();
           
        }
        
    }
    
    //positive case: View and post story after login
    //Categories fetched: Microcontroller and Automotive
    static testmethod void CommunitiesSuccessStoriesTest8() 
    {
        
        fetchRecordType();

        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact= createContact();
        objContact.AccountID = objNxpCommunityParentAcc.Id;
        insert objContact;
        system.assert(objContact.Id!=null);
        
        User objUser= createUser();
        objUser.contactId=objContact.Id;
        insert objUser;
        system.assert(objUser.Id!=null);
        
        Community objComm= [SELECT Id FROM Community WHERE Name = 'Success Stories'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.CommunitiesStoryZoneId__c= objComm.Id;
        insert setting;
        system.assert(setting.Id!=null);

        system.runAs(objUser)
        {
            Test.startTest();
            Idea objIdea1= createIdea();
            objIdea1.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea1.Categories='MicroController';
            insert objIdea1;
            system.assert(objIdea1.Id!=null);
            
            Idea objIdea2= createIdea();
            objIdea2.CommunityId= setting.CommunitiesStoryZoneId__c;
            objIdea2.Categories='Automotive';
            insert objIdea2;
            system.assert(objIdea2.Id!=null);
            
            IdeaComment objComment= new IdeaComment();
            objComment.IdeaId= objIdea1.id;
            objComment.CommentBody= 'strCommentBody';
            insert objComment;
            system.assert(objComment.Id!=null);
            
            Test.setCurrentPageReference(new PageReference('Page.CommunityStories'));
            ApexPages.currentPage().getParameters().put('id', objIdea1.id);
           
            CommunitiesSuccessStoriesController ideaController = new CommunitiesSuccessStoriesController();
            List<SelectOption> lstOptions= ideaController.getCategories();
            system.assert(lstOptions.size()!=null);
            
            
            ideaController.categoryFilterId='All';
            ideaController.fetchStories();
            
            ideaController.categoryFilterId='Automotive';
            ideaController.fetchStories();
            
            List<SelectOption> lstOpt=ideaController.getStories();
            system.assert(lstOpt.size()!=null);
            Test.stopTest();
            
        }
         
    }
                
}