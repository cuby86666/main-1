@isTest
private class Test_MappingCaseRouting {
    
    static list<CollaborationGroup > lstGroup = new  list<CollaborationGroup>();
    static list<Topic > lstTopic = new  list<Topic>();
    static list<FeedItem > lstFeedItem = new  list<FeedItem >();
    static list<Case_Routing_Mapping__c> lstCRM = new list<Case_Routing_Mapping__c>();
    static list<Case > lstCaseRelatedToGroup = new  list<Case>();
    static list<Case > lstCaseRelatedToTopic = new  list<Case>();
    static list<Case > lstCaseDefault = new  list<Case>();   
    
    static user objUser;
    static user portalUser;
    static Account portalAccount;
    static Contact portalContact;
    static user InternalUser;
    
    private static void createData(){
        
        Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id;
        
        objUser = [Select id,IsActive FROM User Where ProfileId =:ProfileId AND IsActive=true  limit 1];
        
        portalAccount = new Account(name = 'portalAccount');
        insert portalAccount;
        
        portalContact = new contact(LastName = 'portalContact', AccountId = portalAccount.Id, MailingState = 'United States', MailingCountry = 'UK', Title = 'Test Title'); //create a portal contact
        insert portalContact;
        
        Id PortalUserId = [SELECT Id FROM Profile WHERE Name = 'NXP Customer Community Login User' limit 1].Id;
        
        Contact internalUserContact = new contact(LastName = 'portalContact', AccountId = portalAccount.Id, MailingState = 'United States', MailingCountry = 'UK', Title = 'Test Title'); //create a portal contact
        insert internalUserContact;
            
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
        
        InternalUser = new User(email='testmail.test96@gmail.com',
                                profileid = ProfileId, 
                                UserName='testinternal.test59@gmail.com', 
                                Alias = 'GDS',
                                TimeZoneSidKey='America/New_York',
                                EmailEncodingKey='ISO-8859-1',
                                LocaleSidKey='en_US', 
                                LanguageLocaleKey='en_US',
                                FirstName = 'Data',
                                LastName = 'Test',
                                Contact_Id__c = internalUserContact.Id); 
        insert InternalUser;
        
        System.runAs(InternalUser){
            
            lstGroup  = new List<CollaborationGroup>{new CollaborationGroup(Name='TestGroup' + String.valueOf(System.now()), CollaborationType='public'), 
                                                     new CollaborationGroup(Name='TestGroup-02' + String.valueOf(System.now()), CollaborationType='public')
                                                    };
            insert lstGroup;
            
            lstTopic = new List<Topic>{new Topic(Name = 'Test Topic-01'),
                                       new Topic(Name = 'Test Topic-02'),
                                       new Topic(Name = 'Test Topic-03')
                                     };
            insert lstTopic;
            
            lstCRM = new List<Case_Routing_Mapping__c>{ new Case_Routing_Mapping__c(Name = 'TestTopic', Related_To_Id__c= lstTopic[0].Id, CaseOwner__c= InternalUser.Id, Case_Assigned_To__c = InternalUser.Id),
                                                        new Case_Routing_Mapping__c(Name = 'TestGroup-01', Related_To_Id__c= lstGroup[0].Id, CaseOwner__c= InternalUser.Id, Case_Assigned_To__c = InternalUser.Id),
                                                        new Case_Routing_Mapping__c(Name = 'Default', Related_To_Id__c= InternalUser.Id, CaseOwner__c= InternalUser.Id, Case_Assigned_To__c = InternalUser.Id)
                                                        
                                                      };
            insert lstCRM;
            
            ContentVersion cv = new ContentVersion(title='foo', contentUrl='http:///www.foor.bar');
            insert cv;
            
            lstFeedItem = new List<FeedItem>{new FeedItem(ParentId = lstGroup[0].Id, Body='Test-01', Title = 'Test1',CreatedById = portalUser.Id, Visibility = 'AllUsers', Type = 'QuestionPost'),
                                             new FeedItem(ParentId = lstGroup[1].Id,Type = 'QuestionPost', Body='Test-03', Title = 'Test3',CreatedById = portalUser.Id, Visibility = 'AllUsers'),
                                             new FeedItem(ParentId = lstTopic[1].Id,Type = 'QuestionPost', Body='Test-04', Title = 'Test4',CreatedById = portalUser.Id, Visibility = 'AllUsers'),
                                             new FeedItem(Title = 'Test', Body='File Holder', ParentId = lstGroup[0].Id, Visibility = 'AllUsers',CreatedById = InternalUser.Id, Type='ContentPost', RelatedRecordId = cv.Id)
                                            };
            
            Test.startTest();
            insert lstFeedItem;
            Test.stopTest();
            if(!lstFeedItem.isEmpty()){
                
                lstCaseRelatedToGroup =  [Select id, FeedItemId,status,Community_Group_Name__c,RelatedToId__c,OwnerId,Assigned_to__c From Case Where FeedItemId =: lstFeedItem[0].Id];
                
                lstCaseDefault = [Select id, FeedItemId,Community_Group_Name__c,Community_Topic_Name__c,RelatedToId__c,status,OwnerId,Assigned_to__c From Case Where FeedItemId =: lstFeedItem[1].Id];
                
                lstCaseRelatedToTopic = [Select id, FeedItemId,Community_Topic_Name__c,RelatedToId__c,status,OwnerId,Assigned_to__c From Case Where FeedItemId =: lstFeedItem[2].Id];
            }
            system.debug('>>>>>>>>>>>>>lstCaseRelatedToGroup::'+lstCaseRelatedToGroup);
            system.debug('>>>>>>>>>>>>>lstCaseDefault::'+lstCaseDefault);
            system.debug('>>>>>>>>>>>>>lstCaseRelatedToTopic::'+lstCaseRelatedToTopic);
        }
    }
    private static testMethod void test() {
        
        //Test.startTest();
        createData();
       // Test.stopTest();
        
        /*CHECKS RELATED TO GROUP */
        //checking if GroupName of the case is updated with related group or not
        if(!lstCaseRelatedToGroup.isEmpty()) {  
            
            system.assertNotEquals(NULL, [SELECT id,Community_Group_Name__c FROM Case where Id =: lstCaseRelatedToGroup[0].Id].Community_Group_Name__c);
            
            //checking if RelatedToId__c of the case is updated or not
            system.assertNotEquals(NULL, [SELECT Id, RelatedToId__c FROM Case WHERE Id=:lstCaseRelatedToGroup[0].Id].RelatedToId__c);
        }
        if(!lstCRM.isEmpty() && !lstCaseRelatedToGroup.isEmpty()){
            //checking if OwnerId of the case is updated with matched CaseOwner__c of Case_Routing_Mapping__c
            system.assertEquals(lstCRM[1].CaseOwner__c, [SELECT Id, OwnerId FROM Case WHERE Id=:lstCaseRelatedToGroup[0].Id].OwnerId);
            
            //checking if Assigned_to__c of the case is updated with matched Case_Assigned_To__c of Case_Routing_Mapping__c
            system.assertEquals(lstCRM[1].Case_Assigned_To__c, [SELECT Id, Assigned_to__c FROM Case WHERE Id=:lstCaseRelatedToGroup[0].Id].Assigned_to__c);
        }
        /*CHECKS RELATED TO TOPIC */
        
         if(!lstCaseRelatedToTopic.isEmpty()) { 
         
            //checking if TopicName of the case is updated with related Topic or not
            system.assertEquals('Test Topic-02' ,[SELECT id,Community_Topic_Name__c FROM Case where Id =: lstCaseRelatedToTopic[0].Id].Community_Topic_Name__c);
            
            //checking if RelatedToId__c of the case is updated with or not
            system.assertNotEquals(NULL, [SELECT Id, RelatedToId__c FROM Case WHERE Id=:lstCaseRelatedToTopic[0].Id].RelatedToId__c);
         }
         if(!lstCRM.isEmpty() && !lstCaseRelatedToGroup.isEmpty()){
             
            //checking if OwnerId of the case is updated with matched CaseOwner__c of Case_Routing_Mapping__c
            system.assertEquals(lstCRM[0].CaseOwner__c, [SELECT Id, OwnerId FROM Case WHERE Id=:lstCaseRelatedToTopic[0].Id].OwnerId);
            
            //checking if Assigned_to__c of the case is updated with matched Case_Assigned_To__c of Case_Routing_Mapping__c
            system.assertEquals(lstCRM[0].Case_Assigned_To__c, [SELECT Id, Assigned_to__c FROM Case WHERE Id=:lstCaseRelatedToTopic[0].Id].Assigned_to__c);
        }
        /*CHECKS RELATED TO DEFAULT MAPPING */
         if(!lstCaseDefault.isEmpty()) {
            //checking if GroupName of the case is updated with related Group or not
            system.assertnotEquals(NULL, [SELECT id,Community_Group_Name__c FROM Case where Id =: lstCaseDefault[0].Id].Community_Group_Name__c);
            
            //checking if RelatedToId__c of the case is updated with or not
            system.assertNotEquals(NULL, [SELECT Id, RelatedToId__c FROM Case WHERE Id=:lstCaseDefault[0].Id].RelatedToId__c);
         }
         if(!lstCRM.isEmpty() && !lstCaseDefault.isEmpty()){
            //checking if OwnerId of the case is updated with Default  CaseOwner__c of Case_Routing_Mapping__c
            system.assertEquals(lstCRM[2].CaseOwner__c, [SELECT Id, OwnerId FROM Case WHERE Id=:lstCaseDefault[0].Id].OwnerId);
            
            //checking if Assigned_to__c of the case is updated with Default  Case_Assigned_To__c of Case_Routing_Mapping__c
            system.assertEquals(lstCRM[2].Case_Assigned_To__c, [SELECT Id, Assigned_to__c FROM Case WHERE Id=:lstCaseDefault[0].Id].Assigned_to__c);
        }         
    }
}