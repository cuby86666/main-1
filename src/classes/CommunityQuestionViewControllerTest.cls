/******************************************************************************************************
@Created By :      Avichal kumar
@CreatedDate :     08 Aug 2015
Description :      Test class for CommunityQuestionViewController
************************************************************************************************************/

@isTest(SeeAllData=True)
public class CommunityQuestionViewControllerTest 
{   
    //Method to create Answers
    private Static Reply createAnswers()
    {
        Reply objRep=new Reply();
       
        objRep.body='test1';
        return objRep;
    }
    
    //Method to create Answerlikes
    private Static Answer_like__c createAnswerlikes()
    {
        Answer_like__c objAnslike=new Answer_like__c();
        return objAnslike;
    }
    
    //Method to create Questionlikes
    private Static Question_like__c createquestionlikes()
    {
        Question_like__c objQueslike=new Question_like__c();
        return objQueslike;
    }
    
    //Method to create question data category
    public Static QuestiondatacategorySelection createQuestiondatacategorySelections()
    {
        QuestiondatacategorySelection objCatQue=new QuestiondatacategorySelection();
        objCatQue.DataCategoryGroupName= 'NXP';
        objCatQue.datacategoryname='Automotive';
        return objCatQue;
    }
  
    //Positive case: To fetch question when id is not null 
    static testmethod void CommunityQuestionViewControllerTest1() 
    {
        test.starttest();
         Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
         Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'Success Stories' Limit 1];
         
         User objUser = new User(alias = 'testing1',email='testingaa32@test.com',emailencodingkey='UTF-8',
         lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
         timezonesidkey='America/Los_Angeles',username='testingaa32@test.com');
         insert objUser;
     
        system.runAs(objUser)
        { 
           
          
          Question objQue1=CommunityOverviewControllerTest.createQuestions();
          objQue1.CommunityId= objCommunity2.id;
          objQue1.Product_Category__c='Interface Products';
          objQue1.Product_Sub_Category__c='General';
          insert objQue1;
          system.assert(objQue1.Id!=null);
          
     
          QuestionSubscription objQueSub=new QuestionSubscription();
          objQueSub.QuestionId=objQue1.id;
          objQueSub.SubscriberId=objUser.id;
          insert objQueSub;
          
          
        
          PageReference pageRef = Page.CommunityQuestionview; 
          Test.setCurrentPageReference(pageRef);
          System.currentPageReference().getParameters().put('id', objque1.id);
          CommunityQuestionViewController comForumContrl= new CommunityQuestionViewController();
          comForumContrl.followques();
          comForumContrl.categorySelected();
          comForumContrl.getvisibilityoption();
          comForumContrl.strQuesId=objque1.id;
          comForumContrl.deletequestion();
        }
        test.stoptest();
    }
    
    //Positive case: To fetch question and question body has more than 100 characters
    static testmethod void CommunityQuestionViewControllerTest2() 
    {
        test.starttest();
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
         Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'Success Stories' Limit 1];
         
         User objUser = new User(alias = 'testing1',email='testingaa33@test.com',emailencodingkey='UTF-8',
         lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
         timezonesidkey='America/Los_Angeles',username='testingaa33@test.com');
         insert objUser;
      
        Question objQue1=CommunityOverviewControllerTest.createQuestions();
        objQue1.Body='testing for read more and read less functionality, test body more than 100 charactersssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss';
        objQue1.CommunityId= objCommunity2.Id;
        objQue1.Product_Category__c='Automotive';
        objQue1.Product_Sub_Category__c='General';
        insert objQue1;
        system.assert(objQue1.Id!=null);
        
        system.runAs(objUser)
        {  
          Question objQue2=CommunityOverviewControllerTest.createQuestions();
          objQue2.Body='testing for read more and read less functionality, test body more than 100 charactersssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss';
          objQue2.CommunityId= objCommunity2.Id;
          objQue2.Product_Category__c='Automotive';
          insert objQue2;
          system.assert(objQue2.Id!=null);
   
          QuestiondatacategorySelection objCatQue2= createQuestiondatacategorySelections();
          objCatQue2.DataCategoryName=objQue2.Product_Category__c;
          objCatQue2.ParentId=objQue2.id;
          insert objCatQue2;
          system.assert(objCatQue2.Id!=null);
          
          QuestionSubscription objQueSub=new QuestionSubscription();
          objQueSub.QuestionId=objQue1.id;
          objQueSub.SubscriberId=objUser.id;
          insert objQueSub;
          
        
          PageReference pageRef = Page.CommunityQuestionview;
          Test.setCurrentPageReference(pageRef);
          System.currentPageReference().getParameters().put('id', objque1.id);
          
          CommunityQuestionViewController comForumContrl= new CommunityQuestionViewController();
          
          comForumContrl.readless();
          comForumContrl.readmore();
          comForumContrl.strQuesId=objQue1.id;
          comForumContrl.followQues();
            comForumContrl.categorySelected();
        }
        test.stoptest();
    }
    
    //Positive case: To Submit Answer 
    static testmethod void CommunityQuestionViewControllerTest3() 
    {
        test.starttest();
         Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
         Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'Success Stories' Limit 1];
         
         User objUser = new User(alias = 'testing1',email='testingaa34@test.com',emailencodingkey='UTF-8',
         lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
         timezonesidkey='America/Los_Angeles',username='testingaa34@test.com');
         insert objUser;
    
        system.runAs(objUser)
        {
          
          Question objQue1=CommunityOverviewControllerTest.createQuestions();
          objQue1.body='test123';
          objQue1.CommunityId=objCommunity2.Id;
          objQue1.Product_Category__c='Logic';
            objQue1.Product_Sub_Category__c='General';
          insert objQue1;
          system.assert(objQue1.Id!=null);
      
          reply objrep1=createAnswers();
          objrep1.questionId=objque1.id;
          objrep1.body='test1';
          insert objrep1;
          system.assert(objrep1.Id!=null);
          
          
 
          PageReference pageRef = Page.CommunityQuestionview;
          Test.setCurrentPageReference(pageRef);
          System.currentPageReference().getParameters().put('id', objque1.id);
          CommunityQuestionViewController comForumContrl= new CommunityQuestionViewController();
   
           comForumContrl.strAnsBody='test1';
           comForumContrl.submitans();
           comForumContrl.viewAllAnswers();
           comForumContrl.categorySelected();
           comForumContrl.strAnsId=objrep1.id;
           comForumContrl.deleteAnswer();
        }
        test.stoptest();
    }
    
    //Positive case: Question likes 
    static testmethod void CommunityQuestionViewControllerTest4() 
    {
         test.starttest();
         Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
         Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'Success Stories' Limit 1];
         
         User objUser = new User(alias = 'testing1',email='testingaa35@test.com',emailencodingkey='UTF-8',
         lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
         timezonesidkey='America/Los_Angeles',username='testingaa35@test.com');
         insert objUser;
       
        system.runAs(objUser)
        {
          Question objQue1=CommunityOverviewControllerTest.createQuestions();
          objQue1.CommunityId= objCommunity2.Id;
          objQue1.Product_Category__c='Other Products';
            objQue1.Product_Sub_Category__c='General';
          insert objQue1;
          system.assert(objQue1.Id!=null);
       
    
          Question_Like__c objqueslike1=createquestionlikes();
          objqueslike1.QuestionID__c=objque1.id;
          insert objqueslike1;
          system.assert(objqueslike1.Id!=null);
          
         
      
          PageReference pageRef = Page.CommunityQuestionview;
          Test.setCurrentPageReference(pageRef);
          System.currentPageReference().getParameters().put('id', objque1.id);
          CommunityQuestionViewController comForumContrl= new CommunityQuestionViewController();
           
           comForumContrl.strquesid=objque1.id;
           comForumContrl.likeques();
           comForumContrl.categorySelected();
        }
         test.stoptest();
    }
    
     //Positive case:Answer likes 
    static testmethod void CommunityQuestionViewControllerTest5() 
    {
         test.starttest();
         Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
         Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'Success Stories' Limit 1];
         
         User objUser = new User(alias = 'testing1',email='testingaa36@test.com',emailencodingkey='UTF-8',
         lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
         timezonesidkey='America/Los_Angeles',username='testingaa36@test.com');
         insert objUser;
     
        system.runAs(objUser)
        {
          
          Question objQue1=CommunityOverviewControllerTest.createQuestions();
          objQue1.CommunityId= objCommunity2.Id;
          objQue1.Product_Category__c='RF';
            objQue1.Product_Sub_Category__c='Diodes';
          insert objQue1;
          system.assert(objQue1.Id!=null);
    
          reply objrep1=createAnswers();
          objrep1.questionId=objque1.id;
          objrep1.body='test1';
          insert objrep1;
          system.assert(objrep1.Id!=null);
    
          Answer_like__c objanslike1 = createAnswerlikes();
          objanslike1.ReplyId__c= objrep1.id;
          insert objanslike1;
          system.assert(objanslike1.Id!=null);
          
          
    
          PageReference pageRef = Page.CommunityQuestionview;
          Test.setCurrentPageReference(pageRef);
          System.currentPageReference().getParameters().put('id', objque1.id);
          CommunityQuestionViewController comForumContrl= new CommunityQuestionViewController();
        
           comForumContrl.viewAllAnswers();
           comForumContrl.strAnsId=objrep1.id;
           comForumContrl.likeAns();
           comForumContrl.bestAnswer();
           comForumContrl.categorySelected();
        }
        test.stoptest();
    }
    
    
    //Positive case: Best Answer
    static testmethod void CommunityQuestionViewControllerTest6() 
    {
        test.starttest();
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
         Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'Success Stories' Limit 1];
         
         User objUser = new User(alias = 'testing1',email='testingaa37@test.com',emailencodingkey='UTF-8',
         lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
         timezonesidkey='America/Los_Angeles',username='testingaa37@test.com');
         insert objUser;
      
        system.runAs(objUser)
        {  
          
          Question objQue2=CommunityOverviewControllerTest.createQuestions();
          objQue2.Body='testing for read more and read less functionality, test body more than 100 charactersssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss';
          objQue2.CommunityId= objCommunity2.Id;
          objQue2.Product_Category__c='Automotive';
          insert objQue2;
          system.assert(objQue2.Id!=null);
          
          reply objrep1=createAnswers();
          objrep1.questionId=objQue2.id;
          objrep1.body='test1';
          insert objrep1;
          system.assert(objrep1.Id!=null);
          
          objQue2.best_reply_id__c=objRep1.id;
          objQue2.Best_Reply_Selected_By_Id__c = objuser.id;
          update objque2;
   
          QuestiondatacategorySelection objCatQue2= createQuestiondatacategorySelections();
          objCatQue2.DataCategoryName=objQue2.Product_Category__c;
          objCatQue2.ParentId=objQue2.id;
          insert objCatQue2;
          system.assert(objCatQue2.Id!=null);
          
          PageReference pageRef = Page.CommunityQuestionview;
          Test.setCurrentPageReference(pageRef);
          System.currentPageReference().getParameters().put('id', objque2.id);
          
          CommunityQuestionViewController comForumContrl= new CommunityQuestionViewController();
          
          comForumContrl.bestAnswer();
          comForumContrl.strAnsId = objrep1.id;
          
        }
        test.stoptest();
    }
    
    //Positive case: Question with more than one replies
    static testmethod void CommunityQuestionViewControllerTest7() 
    {
        test.starttest();
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
         Community objCommunity2= [SELECT Id FROM Community WHERE Name = 'Success Stories' Limit 1];
         
         User objUser = new User(alias = 'testing1',email='testingaa38@test.com',emailencodingkey='UTF-8',
         lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
         timezonesidkey='America/Los_Angeles',username='testingaa38@test.com');
         insert objUser;
      
      
        system.runAs(objUser)
        {  
          
          Question objQue2=CommunityOverviewControllerTest.createQuestions();
          objQue2.Body='testing for read more and read less functionality, test body more than 100 charactersssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss';
          objQue2.CommunityId= objCommunity2.Id;
          objQue2.Product_Category__c='Automotive';
          insert objQue2;
          system.assert(objQue2.Id!=null);
          
          QuestiondatacategorySelection objCatQue2= createQuestiondatacategorySelections();
          objCatQue2.DataCategoryName=objQue2.Product_Category__c;
          objCatQue2.ParentId=objQue2.id;
          insert objCatQue2;
          system.assert(objCatQue2.Id!=null);
          
          reply objrep1=createAnswers();
          objrep1.questionId=objQue2.id;
          objrep1.body='test1';
          insert objrep1;
          system.assert(objrep1.Id!=null);
          
          reply objrep2=createAnswers();
          objrep2.questionId=objQue2.id;
          objrep2.body='test1';
          insert objrep2;
          system.assert(objrep2.Id!=null);
          
          PageReference pageRef = Page.CommunityQuestionview;
          Test.setCurrentPageReference(pageRef);
          System.currentPageReference().getParameters().put('id', objque2.id);
          
          CommunityQuestionViewController comForumContrl= new CommunityQuestionViewController();
          
          comForumContrl.bestAnswer();
          comForumContrl.strAnsId = objrep1.id;

        }
        test.stoptest();
    }
   
}