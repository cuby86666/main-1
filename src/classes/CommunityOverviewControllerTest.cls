/******************************************************************************************************
@Created By :      Avichal kumar
@CreatedDate :     08 Aug 2015
Description :      Test class for CommunityOverviewController
************************************************************************************************************/

/******************************************************************************************************
@Modified By :      Avichal kumar
@ModifiedDate :     07September 2015
Description :      Modified Test class for CommunityOverviewController(Null Pointer Exception Handling For Story Code )
************************************************************************************************************/

@isTest(SeeAllData=True)
public class CommunityOverviewControllerTest 
{

    //Method to create questions
    public Static question createQuestions()
    {
        Question objQue=new Question();
        objQue.title='test1';
        objQue.body='test1';
        return objQue;
    }
    
    //Method to create Stories
    public Static Idea createIdea()
    {
        Idea objIdea= new Idea(Title='test1',Body='test1Body');
        return objIdea;
    }
    
    
    // method to create rewards period 
    public Static Rewards_Programme_period__c createRewardPeriod()
    {
        Rewards_Programme_period__c objRewardPeriod= new Rewards_Programme_period__c();
        return objRewardPeriod;
    }
   
    //Method to create FAQ
    public Static FAQ__kav createFAQs()
    {
        FAQ__kav objFaq = new FAQ__kav();
        objFaq.Title = 'Test FAQ';
        objFaq.Summary = 'KB Summary';
        objFaq.URLName = 'test';
        objFaq.isvisibleinpkb=true;
        objFaq.language='en_US';
        return objFaq;
    }
    
    //Method to create Community Settings
    public Static CommunitySettings__c CreateCommunitySetting()
    {
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrlTest';
        return setting;
    
    }
    
    //Method to get profile
    public Static id getProfileId()
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        return objprofile.id;
    
    }
    
    //Method to get NXP Community id
    public Static id getNxpCommunityId()
    {
        Community objCommunity1= [SELECT Id FROM Community WHERE Name = 'NXP Community' Limit 1];
        return objCommunity1.id;
    
    }
    
    //Method to get SuccessStory Community Id()
    public Static id getStoryCommunityId()
    {
        Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'Success Stories' Limit 1];
        return objCommunity2.id;
    } 
    
    
    //Positive case: To fetch question for 'test' result 
    static testmethod void CommunityOverviewControllerTest1() 
    {
        
        Id profileid = getProfileId();
        Id nxpCommunityId = getNxpCommunityId();
        Id storyCommunityId = getStoryCommunityId();
        
        User objUser = new User(alias = 'testing1',email='testingaa19@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaa19@test.com');
        insert objUser;
        
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Question_Post__c= 10;
        setting.CommunitiesStoryZoneId__c= storyCommunityId;
        insert setting;
        system.assert(setting.Id!=null);
     
        FAQ__kav objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {          
            test.starttest();
      
            Question objQue1=createQuestions();
            objQue1.CommunityId=nxpCommunityId;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
            
            Idea objIdea1 = createIdea();
            objIdea1.CommunityId= storyCommunityId;
            objIdea1.Categories='RF';
            insert objIdea1;
            system.assert(objIdea1.Id!=null);
            
             Rewards_Programme_period__c objRewardPeriod1 = createRewardPeriod();
            objRewardPeriod1.start_date__c = System.Today() - 30;
             
            objRewardPeriod1.End_Date__c = System.Today() -15;
            objRewardPeriod1.Created_Date__c =System.Today();
            insert objRewardPeriod1;
            system.assert(objRewardPeriod1.Id!=null);
     
            Rewards_Programme_period__c objRewardPeriod2 = createRewardPeriod();
            objRewardPeriod2.start_date__c = System.Today() - 10 ;
             
            objRewardPeriod2.End_Date__c = System.Today() - 5;
            objRewardPeriod2.Created_Date__c =System.Today();
            insert objRewardPeriod2;
            system.assert(objRewardPeriod2.Id!=null);
    
            Rewards_Programme_period__c objRewardPeriod3 = createRewardPeriod();
            objRewardPeriod3.start_date__c = System.Today() - 15 ;
             
            objRewardPeriod3.End_Date__c = System.Today() - 10 ;
            objRewardPeriod3.Created_Date__c =System.Today();
            insert objRewardPeriod3;
            system.assert(objRewardPeriod3.Id!=null);
         
            Leaderboard_log__c objleaderboard =[select Community_user__r.id,Community_user__r.name,Community_user__r.FullPhotoUrl,created_date__c,points__c,questionid__c,type__c from Leaderboard_log__c where questionid__c= :objQue1.Id Limit 1];
            
          
            
             
            CommunityOverviewController.leaderboardWrapper empW = new CommunityOverviewController.leaderboardWrapper(objleaderboard.Community_user__r.id,objleaderboard.Community_user__r.FullPhotoUrl,objleaderboard.Community_user__r.name);
            //Covering inner/wrapper class
            empW.points = 0;
            
                
            empW.compareTo(empW); 
      
            test.stoptest();
          
            PageReference pageRef = Page.Communityoverview;
            Test.setCurrentPageReference(pageRef);
        
            CommunityOverviewController comForumContrl= new CommunityOverviewController();
            comForumContrl.strQues='test';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();  
        }
    }
    
    //Negative case: To fetch question For search String 'null' or ''
    static testmethod void CommunityOverviewControllerTest2() 
    {
        Id profileid = getProfileId();
        Id nxpCommunityId = getNxpCommunityId();
        Id storyCommunityId = getStoryCommunityId();
        
        User objUser = new User(alias = 'testing1',email='testingaa20@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaa20@test.com');
        insert objUser;
   
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Question_Post__c= 10;
        setting.CommunitiesStoryZoneId__c= storyCommunityId;
        insert setting;
        system.assert(setting.Id!=null);
    
        FAQ__kav objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {  
          test.starttest();
      
          Question objQue1=createQuestions();
          objQue1.CommunityId=nxpCommunityId;
          objQue1.Product_Category__c='Automotive';
          insert objQue1;
          system.assert(objQue1.Id!=null);
 
          Idea objIdea2 = createIdea();
          objIdea2.CommunityId= storyCommunityId;
          objIdea2.Categories='I2c';
          insert objIdea2;
          system.assert(objIdea2.Id!=null);
          
           Rewards_Programme_period__c objRewardPeriod1 = createRewardPeriod();
            objRewardPeriod1.start_date__c = System.Today() - 30;
             
            objRewardPeriod1.End_Date__c = System.Today() -15;
            objRewardPeriod1.Created_Date__c =System.Today();
            insert objRewardPeriod1;
            system.assert(objRewardPeriod1.Id!=null);
     
            Rewards_Programme_period__c objRewardPeriod2 = createRewardPeriod();
            objRewardPeriod2.start_date__c = System.Today() - 10 ;
             
            objRewardPeriod2.End_Date__c = System.Today() - 5;
            objRewardPeriod2.Created_Date__c =System.Today();
            insert objRewardPeriod2;
            system.assert(objRewardPeriod2.Id!=null);
    
            Rewards_Programme_period__c objRewardPeriod3 = createRewardPeriod();
            objRewardPeriod3.start_date__c = System.Today() - 15 ;
             
            objRewardPeriod3.End_Date__c = System.Today() - 10 ;
            objRewardPeriod3.Created_Date__c =System.Today();
            insert objRewardPeriod3;
            system.assert(objRewardPeriod3.Id!=null);
         
            Leaderboard_log__c objleaderboard =[select Community_user__r.id,Community_user__r.name,Community_user__r.FullPhotoUrl,created_date__c,points__c,questionid__c,type__c from Leaderboard_log__c where questionid__c= :objQue1.Id Limit 1];
            
          
            
             
            CommunityOverviewController.leaderboardWrapper empW = new CommunityOverviewController.leaderboardWrapper(objleaderboard.Community_user__r.id,objleaderboard.Community_user__r.FullPhotoUrl,objleaderboard.Community_user__r.name);
            //Covering inner/wrapper class
            empW.points = 0;
            
                
            empW.compareTo(empW); 
          
          test.stoptest();
         
          PageReference pageRef = Page.Communityoverview;
          Test.setCurrentPageReference(pageRef);
        
          CommunityOverviewController comForumContrl= new CommunityOverviewController();
          comForumContrl.strQues='';
          comForumContrl.checkAll();
          comForumContrl.checkQues();
          comForumContrl.checkFaq();  
        }
    }
    
    
    //Positive case:Leader board display
    static testmethod void CommunityOverviewControllerTest3() 
    {
        Id profileid = getProfileId();
        Id nxpCommunityId = getNxpCommunityId();
        Id storyCommunityId = getStoryCommunityId();
        
        User objUser = new User(alias = 'testing1',email='testingaa21@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaa21@test.com');
        insert objUser;
     
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Question_Post__c= 10;
        setting.CommunitiesStoryZoneId__c= storyCommunityId;
        insert setting;system.assert(setting.Id!=null);
    
        FAQ__kav objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {          
            test.starttest();
         
            Question objQue1=createQuestions();
            objQue1.CommunityId=nxpCommunityId;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
            
            Idea objIdea3 = createIdea();
            objIdea3.CommunityId= storyCommunityId;
            objIdea3.Categories='Automotive';
            insert objIdea3;
            system.assert(objIdea3.Id!=null);
            
            Rewards_Programme_period__c objRewardPeriod1 = createRewardPeriod();
            objRewardPeriod1.start_date__c = System.Today() -30;
             
            objRewardPeriod1.End_Date__c = System.Today() + 15;
            objRewardPeriod1.Created_Date__c =System.Today();
            insert objRewardPeriod1;
            system.assert(objRewardPeriod1.Id!=null);
     
            Rewards_Programme_period__c objRewardPeriod2 = createRewardPeriod();
            objRewardPeriod2.start_date__c = System.Today() - 10 ;
             
            objRewardPeriod2.End_Date__c = System.Today() + 5;
            objRewardPeriod2.Created_Date__c =System.Today();
            insert objRewardPeriod2;
            system.assert(objRewardPeriod2.Id!=null);
    
            Rewards_Programme_period__c objRewardPeriod3 = createRewardPeriod();
            objRewardPeriod3.start_date__c = System.Today() - 15 ;
             
            objRewardPeriod3.End_Date__c = System.Today() + 10 ;
            objRewardPeriod3.Created_Date__c =System.Today();
            insert objRewardPeriod3;
            system.assert(objRewardPeriod3.Id!=null);
         
            Leaderboard_log__c objleaderboard =[select Community_user__r.id,Community_user__r.name,Community_user__r.FullPhotoUrl,created_date__c,points__c,questionid__c,type__c from Leaderboard_log__c where questionid__c= :objQue1.Id Limit 1];
           
         
            
            
             
            CommunityOverviewController.leaderboardWrapper empW = new CommunityOverviewController.leaderboardWrapper(objleaderboard.Community_user__r.id,objleaderboard.Community_user__r.FullPhotoUrl,objleaderboard.Community_user__r.name);
            //Covering inner/wrapper class
            empW.points = 0;
           
                
            empW.compareTo(empW); 
            
            test.stoptest();
               
            PageReference pageRef = Page.Communityoverview;
            Test.setCurrentPageReference(pageRef);
        
            CommunityOverviewController comForumContrl= new CommunityOverviewController();
             
        }
    }
    
     //negative case:Leader board display(no leaders)
    static testmethod void CommunityOverviewControllerTest4() 
    {
        
        Id profileid = getProfileId();
        Id nxpCommunityId = getNxpCommunityId();
        Id storyCommunityId = getStoryCommunityId();
          
        User objUser = new User(alias = 'testing1',email='testingaa22@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaa22@test.com');
        insert objUser;
     
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Question_Post__c= 10;
        setting.CommunitiesStoryZoneId__c= storyCommunityId;
        insert setting;system.assert(setting.Id!=null);
   
        FAQ__kav objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {          
            test.starttest();
          
            Question objQue1=createQuestions();
            objQue1.CommunityId=nxpCommunityId;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
       
            Idea objIdea4 = createIdea();
            objIdea4.CommunityId= storyCommunityId;
            objIdea4.Categories='Automotive';
            insert objIdea4;
            system.assert(objIdea4.Id!=null);
            
            Rewards_Programme_period__c objRewardPeriod1 = createRewardPeriod();
            objRewardPeriod1.start_date__c = System.Today() - 30;
             
            objRewardPeriod1.End_Date__c = System.Today() -15;
            objRewardPeriod1.Created_Date__c =System.Today();
            insert objRewardPeriod1;
            system.assert(objRewardPeriod1.Id!=null);
     
            Rewards_Programme_period__c objRewardPeriod2 = createRewardPeriod();
            objRewardPeriod2.start_date__c = System.Today() - 10 ;
             
            objRewardPeriod2.End_Date__c = System.Today() - 5;
            objRewardPeriod2.Created_Date__c =System.Today();
            insert objRewardPeriod2;
            system.assert(objRewardPeriod2.Id!=null);
    
            Rewards_Programme_period__c objRewardPeriod3 = createRewardPeriod();
            objRewardPeriod3.start_date__c = System.Today() - 15 ;
             
            objRewardPeriod3.End_Date__c = System.Today() - 10 ;
            objRewardPeriod3.Created_Date__c =System.Today();
            insert objRewardPeriod3;
            system.assert(objRewardPeriod3.Id!=null);
         
            Leaderboard_log__c objleaderboard =[select Community_user__r.id,Community_user__r.name,Community_user__r.FullPhotoUrl,created_date__c,points__c,questionid__c,type__c from Leaderboard_log__c where questionid__c= :objQue1.Id Limit 1];
            
          
            
             
            CommunityOverviewController.leaderboardWrapper empW = new CommunityOverviewController.leaderboardWrapper(objleaderboard.Community_user__r.id,objleaderboard.Community_user__r.FullPhotoUrl,objleaderboard.Community_user__r.name);
            //Covering inner/wrapper class
            empW.points = 0;
            
                
            empW.compareTo(empW); 
            
            test.stoptest();
              
            PageReference pageRef = Page.Communityoverview;
            Test.setCurrentPageReference(pageRef);
        
            CommunityOverviewController comForumContrl= new CommunityOverviewController();
             
        }
    } 
}