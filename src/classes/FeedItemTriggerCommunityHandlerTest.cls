@isTest
private class FeedItemTriggerCommunityHandlerTest {

    static User objUser;
    static User portalUser;
    static Account portalAccount;
    static Contact portalContact;
    
    static list<CollaborationGroup > lstCG = new  list<CollaborationGroup>();
    static list<Topic> lstTopic = new  list<Topic>();
    static list<FeedItem> lstFeedItem = new  list<FeedItem >();
    static list<Case_Routing_Mapping__c> lstCaseRoutingMap = new list<Case_Routing_Mapping__c>();
    
    
    private static testMethod void test() {
        
        createData();
        
        System.runAs(objUser){
            
            System.debug('Limit queries aftr createdata *>'+System.limits.getQueries());
            
            lstCG  = new List<CollaborationGroup>{new CollaborationGroup(Name='TestCollGroup' + String.valueOf(System.now()), CollaborationType='public' ), 
                                                  new CollaborationGroup(Name='TestCollGroup-02' + String.valueOf(System.now()), CollaborationType='public')};
            Test.startTest();
            Insert lstCG;
             
            System.debug('Limit queries aftr collaborationGroup *>'+System.limits.getQueries());
            
            lstTopic = new List<Topic>{new Topic(Name = 'Test Topic-01')};
            Insert lstTopic;
            
            System.debug('Limit queries aftr Topic *>'+System.limits.getQueries());
            
            lstCaseRoutingMap = new List<Case_Routing_Mapping__c>{new Case_Routing_Mapping__c(Name = 'TestTopic', Related_To_Id__c= lstTopic[0].Id, CaseOwner__c= objUser.Id, CaseAdmin__c = objUser.Id ),
                                                        new Case_Routing_Mapping__c(Name = 'TestGroup-01', Related_To_Id__c= lstCG[0].Id, CaseOwner__c= objUser.Id, CaseAdmin__c = objUser.Id),
                                                        new Case_Routing_Mapping__c(Name = 'Default', Related_To_Id__c= objUser.Id, CaseOwner__c= objUser.Id,CaseAdmin__c = objUser.Id)};
            Insert lstCaseRoutingMap;
            
            System.debug('Limit queries aftr CRM *>'+System.limits.getQueries());
            
            lstFeedItem = new List<FeedItem>{new FeedItem(ParentId = lstCG[0].Id, Type = 'QuestionPost',Body='Test-01', Title = 'Test', CreatedById = portalUser.Id),
                                             new FeedItem(ParentId = lstTopic[0].Id,Type = 'QuestionPost', Body='Test-02', Title = 'Test2', CreatedById = portalUser.Id),
                                             new FeedItem(ParentId = lstCG[1].Id,Type = 'QuestionPost', Body='Test-03', Title = 'Test3', CreatedById = portalUser.Id)};
            
            System.debug('Limit queries b4 feedinsert *>'+System.limits.getQueries());
            
            Insert lstFeedItem;
            Test.stopTest();
            System.debug('Limit queries aftr feedinsert *>'+System.limits.getQueries());
            
            
            lstFeedItem[0].body = lstFeedItem[0].body+'Update';
            lstFeedItem[0].Title = lstFeedItem[0].Title+'Update Title';
            
            System.debug('Limit queries b4 feedUpdate *>'+System.limits.getQueries());
            Update lstFeedItem[0];
            
            System.debug('Limit queries aftr feedUpdate *>'+System.limits.getQueries());
            
            List<FeedAttachment> lstFAToInsert = new List<FeedAttachment>();
            
            ContentVersion objCV = new ContentVersion(Title = 'dummy', VersionData = blob.valueOf('text Dummy file'), PathOnClient = 'dummy.txt');
            Insert objCV;
            
            FeedAttachment objFeedAttach = new FeedAttachment(FeedEntityId = lstFeedItem[0].Id, RecordId = objCV.Id, Type = 'Content');
            Insert objFeedAttach;
            
            lstFAToInsert.add(new FeedAttachment(FeedEntityId = lstFeedItem[0].Id, RecordId = objCV.Id, Type = 'Content'));
            
            Case objCase = [SELECT Subject,Description,FeedItemId FROM Case WHERE FeedItemId =: lstFeedItem[0].Id];
            
            System.debug('Limit queries aftr caseQuery *>'+System.limits.getQueries());
            
            system.assert(objCase.Id != NULL);
            
            FeedItem objFeed = lstFeedItem[0];
            
            system.assert(objFeed.Id != NULL);
            system.assertEquals(objFeed.Body, objCase.Description);
            system.assertEquals(objFeed.Title, objCase.Subject);
            
            
            Datetime sysTime = System.now().addSeconds( 30 );      
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'SelfScheduleForFileAttchmentTest' + sysTime, chronExpression, new AddFileOnQuestionUpdateScheduler(lstFAToInsert)); 
            
            
        }

    }
    
    private static void createData(){
        
        portalAccount = new Account(name = 'portalAccount');
        Insert portalAccount;
        
        portalContact = new contact(LastName = 'portalContact', AccountId = portalAccount.Id, MailingState = 'United States', Title = 'Test Title'); //create a portal contact//MailingCountry = 'UK',
        Insert portalContact;
        
        List<Profile> lstProfiles = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' OR Name = 'NXP Customer Community Login User' limit 2];
        // NXP Customer Community Login User
        //Id PortalUserId = [SELECT Id FROM Profile WHERE Name = 'NXP Customer Community Login User' limit 1].Id;
        
        for(Profile objUserProfile : lstProfiles){
            
            if(objUserProfile.Name == 'NXP Customer Community Login User'){
                
                portalUser = new User(  email='testmail.test123@gmail.com',
                                        profileid = objUserProfile.Id, 
                                        UserName='testuser.test59@gmail.com', 
                                        Alias = 'GDS',
                                        TimeZoneSidKey='America/New_York',
                                        EmailEncodingKey='ISO-8859-1',
                                        LocaleSidKey='en_US', 
                                        LanguageLocaleKey='en_US',
                                        ContactId = portalContact.Id,
                                        PortalRole = 'Manager',
                                        FirstName = 'Genelia',
                                        LastName = 'Dsouza');
                
            }else if(objUserProfile.Name == 'System Administrator'){
                
                objUser = new User(alias = 'UTest', email='unit.test@test.com', emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
                                     profileid = objUserProfile.Id, timezonesidkey='America/Los_Angeles', username= 'unit.test@test123.com');
            }
        }
        Insert portalUser;
        Insert objUser;
        
    } 

}