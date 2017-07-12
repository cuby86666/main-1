/*********************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     05 Oct 2015
Description :      Test Class for CommunityEditReplyController 
****************************************************************************************************/

@isTest
public class CommunityEditReplyControllerTest
{
    //Method to create Answers
    private Static Reply createAnswers()
    {
        Reply objRep=new Reply();
       
        objRep.body='test1';
        return objRep;
    }
    
  
    //Positive case: To edit answer 
    static testmethod void CommunityEditReplyControllerTest1() 
    {
        test.starttest();
         Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
         Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'NXP Community' Limit 1];
         
         User objUser = new User(alias = 'testing1',email='testingaa32@test.com',emailencodingkey='UTF-8',
         lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
         timezonesidkey='America/Los_Angeles',username='testingaa32@test.com');
         insert objUser;
     
        system.runAs(objUser)
        { 
           
           CommunitySettings__c setting = new CommunitySettings__c();
           setting.Name = 'CommunityUrl';
           setting.Question_Post__c= 10;
           insert setting;
           system.assert(setting.Id!=null);
            
           Question objQue1=new Question();
           objQue1.title='test';
           objQue1.body='test';
           objQue1.CommunityId= objCommunity2.id;
           objQue1.Product_Category__c='Interface Products';
           objQue1.Product_Sub_Category__c='General';
           insert objQue1;
           system.assert(objQue1.Id!=null);
          
           reply objrep1=createAnswers();
           objrep1.questionId=objque1.id;
           objrep1.body='test1';
           insert objrep1;
           system.assert(objrep1.Id!=null);
           
        
           PageReference pageRef = Page.CommunityEditReply;
           Test.setCurrentPageReference(pageRef);
           System.currentPageReference().getParameters().put('strAnsId', objrep1.id);
           CommunityEditReplyController comForumContrl= new CommunityEditReplyController();
           comForumContrl.editAns();
        }
        test.stoptest();
    }
    
    //Negative case: To edit answer when body is null
    static testmethod void CommunityEditReplyControllerTest2() 
    {
        test.starttest();
         Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
         Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'NXP Community' Limit 1];
         
         User objUser = new User(alias = 'testing1',email='testingaa32@test.com',emailencodingkey='UTF-8',
         lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
         timezonesidkey='America/Los_Angeles',username='testingaa32@test.com');
         insert objUser;
     
        system.runAs(objUser)
        { 
           
           CommunitySettings__c setting = new CommunitySettings__c();
           setting.Name = 'CommunityUrl';
           setting.Question_Post__c= 10;
           insert setting;
           system.assert(setting.Id!=null);
            
           Question objQue1=new Question();
           objQue1.title='test';
           objQue1.body='test';
           objQue1.CommunityId= objCommunity2.id;
           objQue1.Product_Category__c='Interface Products';
           objQue1.Product_Sub_Category__c='General';
           insert objQue1;
           system.assert(objQue1.Id!=null);
          
           reply objrep1=createAnswers();
           objrep1.questionId=objque1.id;
           objrep1.body='test';
           insert objrep1;
           system.assert(objrep1.Id!=null);
          
        
           PageReference pageRef = Page.CommunityEditReply;
           Test.setCurrentPageReference(pageRef);
           System.currentPageReference().getParameters().put('strAnsId', objrep1.id);
           CommunityEditReplyController comForumContrl= new CommunityEditReplyController();
           comForumContrl.strAnsBody='';
           comForumContrl.editAns();
        }
         test.stoptest();
    }
}