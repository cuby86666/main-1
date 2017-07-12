@IsTest
private class Test_FeedCommentTriggerHandler {
    
    static list<CollaborationGroup > lstCG = new  list<CollaborationGroup>();
    static list<Topic > lstTopic = new  list<Topic>();
    static list<FeedItem > lstFeedItem = new  list<FeedItem >();
    static list<FeedComment > lstFeedCommentToInsert = new  list<FeedComment >();
    static list<Case_Routing_Mapping__c> lstCRM = new list<Case_Routing_Mapping__c>();
    
    static list<Case > lstCaseRelatedTogroup = new  list<Case>();
    static list<Case > lstCaseRelatedToTopic = new  list<Case>();
    static list<Case > lstCaseToUpdateStatus = new  list<Case>();
    
    static user objUser;
    static user portalUser;
    static Account portalAccount;
    static Contact portalContact;
    
    private static void createData(){
        
        portalAccount = new Account(name = 'portalAccount');
        insert portalAccount;
        
        portalContact = new contact(LastName = 'portalContact', AccountId = portalAccount.Id, MailingState = 'United States', Title = 'Test Title'); //create a portal contact//MailingCountry = 'UK',
        insert portalContact;
        
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id;
        
        Id PortalUserId = [SELECT Id FROM Profile WHERE Name = 'NXP Customer Community Login User' limit 1].Id;
        
        portalUser = new User(  email='testmail.test123@gmail.com',
                                profileid = PortalUserId, 
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
        insert portalUser;
        
        objUser = new User(alias = 'UTest', email='unit.test@test.com', emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
                             profileid = ProfileId, timezonesidkey='America/Los_Angeles', username= 'unit.test@test123.com');
                             
        insert objUser;
         
        System.runAs(objUser){
            
            lstCG  = new List<CollaborationGroup>{  new CollaborationGroup(Name='TestCollGroup' + String.valueOf(System.now()), CollaborationType='public' ), 
                                                    new CollaborationGroup(Name='TestCollGroup-02' + String.valueOf(System.now()), CollaborationType='public')
                                                 };
            insert lstCG;
             
            
            lstTopic = new List<Topic>{new Topic(Name = 'Test Topic-01')
                                       
                                      };
            insert lstTopic;
            
            lstCRM = new List<Case_Routing_Mapping__c>{ new Case_Routing_Mapping__c(Name = 'TestTopic', Related_To_Id__c= lstTopic[0].Id, CaseOwner__c= objUser.Id, CaseAdmin__c = objUser.Id ),
                                                        new Case_Routing_Mapping__c(Name = 'TestGroup-01', Related_To_Id__c= lstCG[0].Id, CaseOwner__c= objUser.Id, CaseAdmin__c = objUser.Id),
                                                        new Case_Routing_Mapping__c(Name = 'Default', Related_To_Id__c= objUser.Id, CaseOwner__c= objUser.Id,CaseAdmin__c = objUser.Id)
                                                      };
            insert lstCRM;
            
                
            lstFeedItem = new List<FeedItem>{new FeedItem(ParentId = lstCG[0].Id, Type = 'QuestionPost',Body='Test-01', Title = 'Test', CreatedById = portalUser.Id),
                                             new FeedItem(ParentId = lstTopic[0].Id,Type = 'QuestionPost', Body='Test-02', Title = 'Test2', CreatedById = portalUser.Id),
                                             new FeedItem(ParentId = lstCG[1].Id,Type = 'QuestionPost', Body='Test-03', Title = 'Test3', CreatedById = portalUser.Id)
                                            };
            Test.startTest();
            insert lstFeedItem;
            Test.stopTest();
            
            if(!lstFeedItem.isEmpty()){
                
                lstCaseRelatedTogroup = [Select id, FeedItemId,status,RelatedToId__c From Case Where FeedItemId =: lstFeedItem[0].Id];
                
                lstCaseRelatedToTopic = [Select id, FeedItemId,status,RelatedToId__c From Case Where FeedItemId =: lstFeedItem[1].Id];
                
                lstCaseToUpdateStatus = [Select id,FeedItemId,status,RelatedToId__c From Case Where FeedItemId =: lstFeedItem[2].Id];
            }
            
            ContentVersion cv = new ContentVersion(title='foo', contentUrl='http:///www.foor.bar');
            insert cv;
            
            if(!lstCaseToUpdateStatus.isEmpty()){
           
                lstFeedCommentToInsert = new List<FeedComment>{new FeedComment(FeedItemId = lstFeedItem[0].Id, CommentBody = 'Test Comment1', CommentType = 'ContentComment', RelatedRecordId = cv.Id),
                                                                //new FeedComment(FeedItemId = lstFeedItem[1].Id, CommentBody = 'Test Comment2', CommentType = 'ContentComment', RelatedRecordId = cv.Id),
                                                                new FeedComment(FeedItemId = lstCaseToUpdateStatus[0].FeedItemId, CommentBody = 'Test Comment3', RelatedRecordId = cv.Id)
                                                               
                };
                insert lstFeedCommentToInsert;    
            }
            
      }
    } 
    
	private static testMethod void test() {
	    
	    createData();
	   
        //Test.startTest();
        
        if(!lstCaseToUpdateStatus.isEmpty()) {
            lstCaseToUpdateStatus[0].status = 'close';
            //update lstCaseToUpdateStatus;
            
            FeedComment objFeedcomment = new FeedComment(FeedItemId = lstCaseToUpdateStatus[0].FeedItemId, CommentBody = 'Test Comment3');
            insert objFeedcomment;
        }
        
        if(!lstCaseRelatedTogroup.isEmpty()) {
            //checking if status of case is updated when user posts a comment if status = new
            system.assertEquals('Received Reply',[Select Id,status from case where Id=:lstCaseRelatedTogroup[0].Id].status );
        }
        if(!lstCaseToUpdateStatus.isEmpty()) {
            //checking if status of case is updated when user posts a comment if status = close and close date is lessthan 30 days
            system.assertEquals('Received Reply',[Select Id,status from case where Id=:lstCaseToUpdateStatus[0].Id].status);
        }
        
        //Test.stopTest();

	}
	
	

}