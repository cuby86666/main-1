/******************************************************************************************************
@Created By :      Avichal kumar
@CreatedDate :     08 Aug 2015
Description :      Test class for CommunityAllleaderDisplayController
************************************************************************************************************/

@isTest(SeeAllData=True)

public class CommunityAllleaderDisplayControllerTest 
{ 
  
    //Positive case: To fetch leaders for leaderboard display 
    static testmethod void CommunityAllleaderDisplayControllerTest1() 
    {
        Id profileid = CommunityOverviewControllerTest.getProfileId();
        Id nxpCommunityId = CommunityOverviewControllerTest.getNxpCommunityId();
        
        User objUser = new User(alias = 'testing1',email='testingaa1@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaa1@test.com');
        insert objUser;
  
        system.runAs(objUser)
        { 
            test.starttest();
          
            Question objQue1= CommunityOverviewControllerTest.createQuestions();
            objQue1.CommunityId=nxpCommunityId;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
          
            Leaderboard_log__c objleaderboard =[select Community_user__c,Community_user__r.fullphotourl,Community_user__r.name,created_date__c,points__c,questionid__c,type__c from Leaderboard_log__c where questionid__c= :objQue1.Id Limit 1];   
            
        
            Rewards_Programme_period__c objRewardPeriod1 = CommunityOverviewControllerTest.createRewardPeriod();
            objRewardPeriod1.start_date__c = System.Today() - 30;
             
            objRewardPeriod1.End_Date__c = System.Today() + 150;
            objRewardPeriod1.Created_Date__c =System.Today();
            insert objRewardPeriod1;
            system.assert(objRewardPeriod1.Id!=null);
   
            Rewards_Programme_period__c objRewardPeriod2 = CommunityOverviewControllerTest.createRewardPeriod();
            objRewardPeriod2.start_date__c = System.Today() - 10 ;
             
            objRewardPeriod2.End_Date__c = System.Today() + 250;
            objRewardPeriod2.Created_Date__c =System.Today();
            insert objRewardPeriod2;
            system.assert(objRewardPeriod2.Id!=null);
        
            Rewards_Programme_period__c objRewardPeriod3 = CommunityOverviewControllerTest.createRewardPeriod();
            objRewardPeriod3.start_date__c = System.Today() - 15 ;
             
            objRewardPeriod3.End_Date__c = System.Today() + 250;
            objRewardPeriod3.Created_Date__c =System.Today();
            insert objRewardPeriod3;
            system.assert(objRewardPeriod3.Id!=null);
             
            CommunityAllleaderDisplayController.leaderboardWrapper empW = new CommunityAllleaderDisplayController.leaderboardWrapper(objleaderboard.Community_user__c,objleaderboard.Community_user__r.fullphotourl,objleaderboard.Community_user__r.Name);
            //Covering inner/wrapper class
             empW.points = 0;
            system.debug('+++++empW'+ empW);
                
            empW.compareTo(empW);
            test.stoptest();
        
            PageReference pageRef = Page.Communityoverview;
            Test.setCurrentPageReference(pageRef);
        
            CommunityAllleaderDisplayController comForumContrl= new CommunityAllleaderDisplayController();  
        }
    }
    
    //Negative case: No leaders (NO records created within rewards period) 
    
    static testmethod void CommunityAllleaderDisplayControllerTest2() 
    {
        Id profileid = CommunityOverviewControllerTest.getProfileId();
        Id nxpCommunityId = CommunityOverviewControllerTest.getNxpCommunityId();
        
        User objUser = new User(alias = 'testing1',email='testingaa2@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaa2@test.com');
        insert objUser;
        
      
        system.runAs(objUser)
        {   
            test.starttest();
        
            Question objQue1=CommunityOverviewControllerTest.createQuestions();
            objQue1.CommunityId=nxpCommunityId;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
            
            Leaderboard_log__c objleaderboard =[select Community_user__c,Community_user__r.fullphotourl,Community_user__r.name,created_date__c,points__c,questionid__c,type__c from Leaderboard_log__c where questionid__c= :objQue1.Id Limit 1];   
            system.debug('+++++++objleaderboard'+objleaderboard);
     
            Rewards_Programme_period__c objRewardPeriod1 = CommunityOverviewControllerTest.createRewardPeriod();
            objRewardPeriod1.start_date__c = System.Today() - 30;
             
            objRewardPeriod1.End_Date__c = System.Today() - 10;
            objRewardPeriod1.Created_Date__c =System.Today();
            insert objRewardPeriod1;
            system.assert(objRewardPeriod1.Id!=null);
    
            Rewards_Programme_period__c objRewardPeriod2 = CommunityOverviewControllerTest.createRewardPeriod();
            objRewardPeriod2.start_date__c = System.Today() - 30 ;
             
            objRewardPeriod2.End_Date__c = System.Today() -5;
            objRewardPeriod2.Created_Date__c =System.Today();
            insert objRewardPeriod2;
            system.assert(objRewardPeriod2.Id!=null);
  
            Rewards_Programme_period__c objRewardPeriod3 = CommunityOverviewControllerTest.createRewardPeriod();
            objRewardPeriod3.start_date__c = System.Today() - 15 ;
             
            objRewardPeriod3.End_Date__c = System.Today() -10;
            objRewardPeriod3.Created_Date__c =System.Today();
            insert objRewardPeriod3;
            system.assert(objRewardPeriod3.Id!=null);
            
            CommunityAllleaderDisplayController.leaderboardWrapper empW = new CommunityAllleaderDisplayController.leaderboardWrapper(objleaderboard.Community_user__c,objleaderboard.Community_user__r.fullphotourl,objleaderboard.Community_user__r.Name);
            //Covering inner/wrapper class
            empW.points = 0;
            empW.compareTo(empW);
            test.stoptest();
         
            PageReference pageRef = Page.Communityoverview;
            Test.setCurrentPageReference(pageRef);
        
            CommunityAllleaderDisplayController comForumContrl= new CommunityAllleaderDisplayController();  
        }
    } 
}