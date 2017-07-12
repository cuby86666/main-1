/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     04 Aug 2015
Description :      Test class for CommunityForumQuestionListController
************************************************************************************************************/

@istest
public class CommunityForumQuestionListControllerTest 
{
    //Method to create questions
    private Static question createQuestions()
    {
        Question objQue=new Question();
        objQue.title='test1';
        objQue.body='test1';
        return objQue;
    }
    
    //Method to create answer
    private Static Reply createAnswers()
    {
        Reply objRep=new Reply();
        objRep.body='test';
        return objRep;
    }
    
    //Method to create FAQ
    private Static FAQ__kav createFAQs()
    {
        FAQ__kav objFaq = new FAQ__kav();
        objFaq.Title = 'Test FAQ';
        objFaq.Summary = 'KB Summary';
        objFaq.URLName = 'test';
        objFaq.isvisibleinpkb=true;
        objFaq.language='en_US';
        return objFaq;
    }
    
    //Method to create question data category
    private Static QuestiondatacategorySelection createQuestiondatacategorySelections()
    {
        QuestiondatacategorySelection objCatQue=new QuestiondatacategorySelection();
        objCatQue.DataCategoryGroupName= 'NXP';
        objCatQue.datacategoryname='Automotive';
        return objCatQue;
    }
    
    //Method to create Faq data category
    private Static Faq__datacategorySelection createFaqdatacategorySelections()
    {
        Faq__datacategorySelection objCatFaq=new Faq__datacategorySelection();
        objCatFaq.DataCategoryGroupName= 'NXP';
        objCatFaq.datacategoryname='Automotive';
        return objCatFaq;
    }
    
    //Negative case: To fetch question under Automotive category,like. 
    //user has already followes a question, so it will unfollow. Filter by recent and most popular listview.
    static testmethod void CommunityForumQuestionListControllerTest1() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa23@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa23@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        setting.Question_Limit__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        FAQ__kav objFaq= new FAQ__kav();
        objFaq=createFAQs();
        insert objFaq;
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id];
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        Faq__datacategorySelection objCatFaq1=new Faq__datacategorySelection();
        objCatFaq1= createFaqdatacategorySelections();
        objCatFaq1.ParentId=objFaq.id;
        insert objCatFaq1;
        system.assert(objCatFaq1.Id!=null);
        
        system.runAs(objUser)
        {
            test.startTest();
            Question objQue1=new Question();
            objQue1=createQuestions();
            objQue1.CommunityId=objCom.id;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
            
            Question_Like__c objLike=new Question_Like__c();
            objLike.QuestionID__c=objQue1.id;
            insert objLike;
            system.assert(objLike.Id!=null);            
        
            QuestiondatacategorySelection objCatQue1=new QuestiondatacategorySelection();
            objCatQue1= createQuestiondatacategorySelections();
            objCatQue1.DataCategoryName=objQue1.Product_Category__c;
            objCatQue1.ParentId=objQue1.id;
            insert objCatQue1;
            system.assert(objCatQue1.Id!=null);
            
            Question objQue2=new Question();
            objQue2=createQuestions();
            objQue2.Body='testing for read more and read less functionality, test body more than 100 charactersssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss';
            objQue2.CommunityId=objCom.id;
            objQue2.Product_Category__c='Automotive';
            insert objQue2;
            system.assert(objQue2.Id!=null);
        
            QuestiondatacategorySelection objCatQue2=new QuestiondatacategorySelection();
            objCatQue2= createQuestiondatacategorySelections();
            objCatQue2.DataCategoryName=objQue2.Product_Category__c;
            objCatQue2.ParentId=objQue2.id;
            insert objCatQue2;
            system.assert(objCatQue2.Id!=null);
        
            Reply objRep= new Reply();
            objRep=createAnswers();
            objRep.QuestionId=objQue2.id;
            insert objRep;
            system.assert(objRep.Id!=null);
            
            QuestionSubscription objQueSub=new QuestionSubscription();
            objQueSub.QuestionId=objQue2.id;
            objQueSub.SubscriberId=objUser.id;
            insert objQueSub;
        
            
            PageReference pageRef = Page.CommunityForumQuestionList;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('category', 'Automotive');
            CommunityForumQuestionListController comForumContrl= new CommunityForumQuestionListController();
            comForumContrl.strQuesId=objQue2.id;
            comForumContrl.likeQues();
            comForumContrl.showMore();
            comForumContrl.followQues();
            comForumContrl.strQues='test';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();
            comForumContrl.getQuestionView();
            comForumContrl.getQuestionViewByDate();
            comForumContrl.fetchQuestions();
            
            
            comForumContrl.FirstPage();
            comForumContrl.previous();
            comForumContrl.LastPage();
            comForumContrl.next();
            comForumContrl.getprev();
            comForumContrl.deleteQuestion();
            comForumContrl.fetchQuestions1();
            comForumContrl.sortOrder='asc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            comForumContrl.questionFilterDate='Replies';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Recent Activity';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Most Popular';
            comForumContrl.fetchQuestions();
            test.stopTest();
        }
    }
    
    //Negative case: To fetch question where category is none. Filter by unanswered questions listview.
    static testmethod void CommunityForumQuestionListControllerTest2() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa24@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa24@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        setting.Question_Limit__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        FAQ__kav objFaq= new FAQ__kav();
        objFaq=createFAQs();
        insert objFaq;
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id];
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        Faq__datacategorySelection objCatFaq1=new Faq__datacategorySelection();
        objCatFaq1= createFaqdatacategorySelections();
        objCatFaq1.ParentId=objFaq.id;
        insert objCatFaq1;
        system.assert(objCatFaq1.Id!=null);
        
        system.runAs(objUser)
        {
            test.startTest();
            Question objQue1=new Question();
            objQue1=createQuestions();
            objQue1.CommunityId=objCom.id;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
        
            QuestiondatacategorySelection objCatQue1=new QuestiondatacategorySelection();
            objCatQue1= createQuestiondatacategorySelections();
            objCatQue1.DataCategoryName=objQue1.Product_Category__c;
            objCatQue1.ParentId=objQue1.id;
            insert objCatQue1;
            system.assert(objCatQue1.Id!=null);
            
            Question objQue2=new Question();
            objQue2=createQuestions();
            objQue2.CommunityId=objCom.id;
            objQue2.Product_Category__c='Other Products';
            insert objQue2;
            system.assert(objQue2.Id!=null);
        
            QuestiondatacategorySelection objCatQue2=new QuestiondatacategorySelection();
            objCatQue2= createQuestiondatacategorySelections();
            objCatQue2.DataCategoryName='Other_Products';
            objCatQue2.ParentId=objQue2.id;
            insert objCatQue2;
            system.assert(objCatQue2.Id!=null);
        
            Reply objRep= new Reply();
            objRep=createAnswers();
            objRep.QuestionId=objQue2.id;
            insert objRep;
            system.assert(objRep.Id!=null);
        
            PageReference pageRef = Page.CommunityForumQuestionList;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('category', '');
            CommunityForumQuestionListController comForumContrl= new CommunityForumQuestionListController();
            comForumContrl.strQuesId=objQue2.id;
            comForumContrl.likeQues();
            comForumContrl.showMore();
            comForumContrl.followQues();
            comForumContrl.strQues='';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();
            comForumContrl.questionFilterId='Unanswered Questions';
            comForumContrl.getQuestionView();
            comForumContrl.getQuestionViewByDate();
            comForumContrl.fetchQuestions();
           
            comForumContrl.sortOrder='desc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            
            
            comForumContrl.sortOrder='desc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            comForumContrl.questionFilterDate='Date Posted';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Replies';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Recent Activity';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Most Popular';
            comForumContrl.fetchQuestions();
            test.stopTest();
        }
    }
    
    //Positive case: To fetch question under general sub category,like and follow. Filter by Unsolved Questions listview.
    static testmethod void CommunityForumQuestionListControllerTest3() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa25@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa25@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        setting.Question_Limit__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            test.startTest();
            Question objQue1=new Question();
            objQue1=createQuestions();
            objQue1.CommunityId=objCom.id;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
        
            QuestiondatacategorySelection objCatQue1=new QuestiondatacategorySelection();
            objCatQue1= createQuestiondatacategorySelections();
            objCatQue1.DataCategoryName=objQue1.Product_Category__c;
            objCatQue1.ParentId=objQue1.id;
            insert objCatQue1;
            system.assert(objCatQue1.Id!=null);
            
            Question objQue2=new Question();
            objQue2=createQuestions();
            objQue2.CommunityId=objCom.id;
            objQue2.Product_Category__c='Automotive';
            
            insert objQue2;
            system.assert(objQue2.Id!=null);
        
            QuestiondatacategorySelection objCatQue2=new QuestiondatacategorySelection();
            objCatQue2= createQuestiondatacategorySelections();
            objCatQue2.DataCategoryName='Automotive';
            objCatQue2.ParentId=objQue2.id;
            insert objCatQue2;
            system.assert(objCatQue2.Id!=null);
        
            Reply objRep= new Reply();
            objRep=createAnswers();
            objRep.QuestionId=objQue2.id;
            insert objRep;
            system.assert(objRep.Id!=null);
        
            FAQ__kav objFaq= new FAQ__kav();
            objFaq=createFAQs();
            insert objFaq;
            system.assert(objFaq.Id!=null);
        
            Faq__datacategorySelection objCatFaq1=new Faq__datacategorySelection();
            objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
        
            PageReference pageRef = Page.CommunityForumQuestionList;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('category', 'Automotive');
            CommunityForumQuestionListController comForumContrl= new CommunityForumQuestionListController();
            
            comForumContrl.strQuesId=objQue2.id;
            comForumContrl.likeQues();
            comForumContrl.showMore();
            comForumContrl.followQues();
            comForumContrl.strQues='test';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();
            comForumContrl.questionFilterId='Unsolved Questions';
            comForumContrl.getQuestionView();
            comForumContrl.getQuestionViewByDate();
            comForumContrl.fetchQuestions();
            
            comForumContrl.sortOrder='asc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            
            comForumContrl.questionFilterDate='Likes';
             comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Recent Activity';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Most Popular';
           
            comForumContrl.fetchQuestions();
            test.stopTest();
        }
    }
    
    //Positive case: To fetch question under Interface Products category,general sub category,like and follow. 
    //Filter by Unsolved Questions listview.
    static testmethod void CommunityForumQuestionListControllerTest4() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa26@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa26@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        setting.Question_Limit__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            test.startTest();
            Question objQue1=new Question();
            objQue1=createQuestions();
            objQue1.CommunityId=objCom.id;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
        
            QuestiondatacategorySelection objCatQue1=new QuestiondatacategorySelection();
            objCatQue1= createQuestiondatacategorySelections();
            objCatQue1.DataCategoryName=objQue1.Product_Category__c;
            objCatQue1.ParentId=objQue1.id;
            insert objCatQue1;
            system.assert(objCatQue1.Id!=null);
            
            Question objQue2=new Question();
            objQue2=createQuestions();
            objQue2.CommunityId=objCom.id;
            objQue2.Product_Category__c='Interface Products';
            objQue2.Product_Sub_Category__c='Interface Products';
            insert objQue2;
            system.assert(objQue2.Id!=null);
        
            QuestiondatacategorySelection objCatQue2=new QuestiondatacategorySelection();
            objCatQue2= createQuestiondatacategorySelections();
            objCatQue2.DataCategoryName='Interface_Products';
            objCatQue2.ParentId=objQue2.id;
            insert objCatQue2;
            system.assert(objCatQue2.Id!=null);
        
            Reply objRep= new Reply();
            objRep=createAnswers();
            objRep.QuestionId=objQue2.id;
            insert objRep;
            system.assert(objRep.Id!=null);
        
            FAQ__kav objFaq= new FAQ__kav();
            objFaq=createFAQs();
            insert objFaq;
            system.assert(objFaq.Id!=null);
        
            Faq__datacategorySelection objCatFaq1=new Faq__datacategorySelection();
            objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
        
            PageReference pageRef = Page.CommunityForumQuestionList;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('category', 'Interface Products');
            CommunityForumQuestionListController comForumContrl= new CommunityForumQuestionListController();
            
            comForumContrl.strQuesId=objQue2.id;
            comForumContrl.likeQues();
            comForumContrl.showMore();
            comForumContrl.followQues();
            comForumContrl.strQues='test';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();
            comForumContrl.questionFilterId='Unsolved Questions';
            comForumContrl.getQuestionView();
            comForumContrl.getQuestionViewByDate();
            comForumContrl.fetchQuestions();
            comForumContrl.sortOrder='desc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            comForumContrl.questionFilterDate='Likes';
            comForumContrl.fetchQuestions();
            
            comForumContrl.questionFilterDate='Recent Activity';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Most Popular';
            comForumContrl.fetchQuestions();
            test.stopTest();
        }
    }
    
    //Positive case: To fetch question under Logic category,general sub category,like and follow. 
    //Filter by Unsolved Questions listview.
    static testmethod void CommunityForumQuestionListControllerTest5() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa27@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa27@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        setting.Question_Limit__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            test.startTest();
            Question objQue1=new Question();
            objQue1=createQuestions();
            objQue1.CommunityId=objCom.id;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
        
            QuestiondatacategorySelection objCatQue1=new QuestiondatacategorySelection();
            objCatQue1= createQuestiondatacategorySelections();
            objCatQue1.DataCategoryName=objQue1.Product_Category__c;
            objCatQue1.ParentId=objQue1.id;
            insert objCatQue1;
            system.assert(objCatQue1.Id!=null);
            
            Question objQue2=new Question();
            objQue2=createQuestions();
            objQue2.CommunityId=objCom.id;
            objQue2.Product_Category__c='Logic';

            insert objQue2;
            system.assert(objQue2.Id!=null);
        
            QuestiondatacategorySelection objCatQue2=new QuestiondatacategorySelection();
            objCatQue2= createQuestiondatacategorySelections();
            objCatQue2.DataCategoryName='Logic';
            objCatQue2.ParentId=objQue2.id;
            insert objCatQue2;
            system.assert(objCatQue2.Id!=null);
        
            Reply objRep= new Reply();
            objRep=createAnswers();
            objRep.QuestionId=objQue2.id;
            insert objRep;
            system.assert(objRep.Id!=null);
        
            FAQ__kav objFaq= new FAQ__kav();
            objFaq=createFAQs();
            insert objFaq;
            system.assert(objFaq.Id!=null);
        
            Faq__datacategorySelection objCatFaq1=new Faq__datacategorySelection();
            objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
        
            PageReference pageRef = Page.CommunityForumQuestionList;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('category', 'Logic');
            CommunityForumQuestionListController comForumContrl= new CommunityForumQuestionListController();
            
            comForumContrl.strQuesId=objQue2.id;
            comForumContrl.likeQues();
            comForumContrl.showMore();
            comForumContrl.followQues();
            comForumContrl.strQues='test';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();
            comForumContrl.questionFilterId='Unsolved Questions';
            comForumContrl.getQuestionView();
            comForumContrl.getQuestionViewByDate();
            comForumContrl.fetchQuestions();
            comForumContrl.sortOrder='asc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            comForumContrl.questionFilterDate='Recent Activity';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Date Posted';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Most Popular';
            comForumContrl.fetchQuestions();
            test.stopTest();
        }
    }
    
    //Positive case: To fetch question under other product category,general sub category,like and follow. 
    //Filter by Unsolved Questions listview.
    static testmethod void CommunityForumQuestionListControllerTest6() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa28@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa28@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        setting.Question_Limit__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            test.startTest();
            Question objQue1=new Question();
            objQue1=createQuestions();
            objQue1.CommunityId=objCom.id;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
        
            QuestiondatacategorySelection objCatQue1=new QuestiondatacategorySelection();
            objCatQue1= createQuestiondatacategorySelections();
            objCatQue1.DataCategoryName=objQue1.Product_Category__c;
            objCatQue1.ParentId=objQue1.id;
            insert objCatQue1;
            system.assert(objCatQue1.Id!=null);
            
            Question objQue2=new Question();
            objQue2=createQuestions();
            objQue2.CommunityId=objCom.id;
            objQue2.Product_Category__c='Other Products';

            insert objQue2;
            system.assert(objQue2.Id!=null);
        
            QuestiondatacategorySelection objCatQue2=new QuestiondatacategorySelection();
            objCatQue2= createQuestiondatacategorySelections();
            objCatQue2.DataCategoryName='Other_Products';
            objCatQue2.ParentId=objQue2.id;
            insert objCatQue2;
            system.assert(objCatQue2.Id!=null);
        
            Reply objRep= new Reply();
            objRep=createAnswers();
            objRep.QuestionId=objQue2.id;
            insert objRep;
            system.assert(objRep.Id!=null);
        
            FAQ__kav objFaq= new FAQ__kav();
            objFaq=createFAQs();
            insert objFaq;
            system.assert(objFaq.Id!=null);
        
            Faq__datacategorySelection objCatFaq1=new Faq__datacategorySelection();
            objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
        
            PageReference pageRef = Page.CommunityForumQuestionList;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('category', 'Other Products');
            CommunityForumQuestionListController comForumContrl= new CommunityForumQuestionListController();
            
            comForumContrl.strQuesId=objQue2.id;
            comForumContrl.likeQues();
            comForumContrl.showMore();
            comForumContrl.followQues();
            comForumContrl.strQues='test';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();
            comForumContrl.questionFilterId='Unsolved Questions';
            comForumContrl.getQuestionView();
            comForumContrl.getQuestionViewByDate();
            comForumContrl.fetchQuestions();
            comForumContrl.sortOrder='asc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            comForumContrl.questionFilterDate='Most Popular';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Recent Activity';
            comForumContrl.fetchQuestions();
            test.stopTest();
        }
    }
    
    //Positive case: To fetch question under RF category,Diodes sub category,like and follow. 
    //Filter by Unsolved Questions listview.
    static testmethod void CommunityForumQuestionListControllerTest7() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa29@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa29@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        setting.Question_Limit__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            test.startTest();
            Question objQue1=new Question();
            objQue1=createQuestions();
            objQue1.CommunityId=objCom.id;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
        
            QuestiondatacategorySelection objCatQue1=new QuestiondatacategorySelection();
            objCatQue1= createQuestiondatacategorySelections();
            objCatQue1.DataCategoryName=objQue1.Product_Category__c;
            objCatQue1.ParentId=objQue1.id;
            insert objCatQue1;
            system.assert(objCatQue1.Id!=null);
            
            Question objQue2=new Question();
            objQue2=createQuestions();
            objQue2.CommunityId=objCom.id;
            objQue2.Product_Category__c='RF';
            objQue2.Product_Sub_Category__c='Diodes';
            insert objQue2;
            system.assert(objQue2.Id!=null);
        
            QuestiondatacategorySelection objCatQue2=new QuestiondatacategorySelection();
            objCatQue2= createQuestiondatacategorySelections();
            objCatQue2.DataCategoryName='Diodes';
            objCatQue2.ParentId=objQue2.id;
            insert objCatQue2;
            system.assert(objCatQue2.Id!=null);
        
            Reply objRep= new Reply();
            objRep=createAnswers();
            objRep.QuestionId=objQue2.id;
            insert objRep;
            system.assert(objRep.Id!=null);
        
            FAQ__kav objFaq= new FAQ__kav();
            objFaq=createFAQs();
            insert objFaq;
            system.assert(objFaq.Id!=null);
        
            Faq__datacategorySelection objCatFaq1=new Faq__datacategorySelection();
            objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
        
            PageReference pageRef = Page.CommunityForumQuestionList;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('category', 'RF Diodes');
            CommunityForumQuestionListController comForumContrl= new CommunityForumQuestionListController();
            
            comForumContrl.strQuesId=objQue2.id;
            comForumContrl.likeQues();
            comForumContrl.showMore();
            comForumContrl.followQues();
            comForumContrl.strQues='test';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();
            comForumContrl.questionFilterId='Unsolved Questions';
            comForumContrl.getQuestionView();
            comForumContrl.getQuestionViewByDate();
            comForumContrl.fetchQuestions();
            comForumContrl.sortOrder='desc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            comForumContrl.questionFilterDate='Recent Activity';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Most Popular';
            comForumContrl.fetchQuestions();
            test.stopTest();
        }
    }
    
    
    //Positive case: To fetch question under RF category,Diodes sub category,like and follow. 
    //Filter by solved Questions listview.
    static testmethod void CommunityForumQuestionListControllerTest8() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa30@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa30@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        setting.Question_Limit__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            test.startTest();
            Question objQue1=new Question();
            objQue1=createQuestions();
            objQue1.CommunityId=objCom.id;
            objQue1.Product_Category__c='Automotive';
            insert objQue1;
            system.assert(objQue1.Id!=null);
        
            QuestiondatacategorySelection objCatQue1=new QuestiondatacategorySelection();
            objCatQue1= createQuestiondatacategorySelections();
            objCatQue1.DataCategoryName=objQue1.Product_Category__c;
            objCatQue1.ParentId=objQue1.id;
            insert objCatQue1;
            system.assert(objCatQue1.Id!=null);
            
            Question objQue2=new Question();
            objQue2=createQuestions();
            objQue2.CommunityId=objCom.id;
            objQue2.Product_Category__c='RF';
            objQue2.Product_Sub_Category__c='General';
            insert objQue2;
            system.assert(objQue2.Id!=null);
        
            QuestiondatacategorySelection objCatQue2=new QuestiondatacategorySelection();
            objCatQue2= createQuestiondatacategorySelections();
            objCatQue2.DataCategoryName='Diodes';
            objCatQue2.ParentId=objQue2.id;
            insert objCatQue2;
            system.assert(objCatQue2.Id!=null);
        
            Reply objRep= new Reply();
            objRep=createAnswers();
            objRep.QuestionId=objQue2.id;
            insert objRep;
            system.assert(objRep.Id!=null);
        
            FAQ__kav objFaq= new FAQ__kav();
            objFaq=createFAQs();
            insert objFaq;
            system.assert(objFaq.Id!=null);
        
            Faq__datacategorySelection objCatFaq1=new Faq__datacategorySelection();
            objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
        
            PageReference pageRef = Page.CommunityForumQuestionList;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('category', 'Diodes');
            CommunityForumQuestionListController comForumContrl= new CommunityForumQuestionListController();
            
            comForumContrl.strQuesId=objQue2.id;
            comForumContrl.likeQues();
            comForumContrl.showMore();
            comForumContrl.followQues();
            comForumContrl.strQues='test';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();
            comForumContrl.questionFilterId='Solved Questions';
            comForumContrl.getQuestionView();
            comForumContrl.getQuestionViewByDate();
            comForumContrl.fetchQuestions();
            comForumContrl.sortOrder='asc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            comForumContrl.questionFilterDate='Recent Activity';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Most Popular';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Replies';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Likes';
            comForumContrl.fetchQuestions();
            
            test.stopTest();
        }
    }
    
    //Positive case: To fetch question under Microcontrollers category,X80C51 sub category,like and follow. 
    //Filter by solved Questions listview.
    static testmethod void CommunityForumQuestionListControllerTest9() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa31@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa31@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        setting.Question_Limit__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            test.startTest();
            Question objQue1=new Question();
            objQue1=createQuestions();
            objQue1.CommunityId=objCom.id;
            objQue1.Product_Category__c='Microcontrollers';
            insert objQue1;
            system.assert(objQue1.Id!=null);
        
            QuestiondatacategorySelection objCatQue1=new QuestiondatacategorySelection();
            objCatQue1= createQuestiondatacategorySelections();
            objCatQue1.DataCategoryName=objQue1.Product_Category__c;
            objCatQue1.ParentId=objQue1.id;
            insert objCatQue1;
            system.assert(objCatQue1.Id!=null);
            
            Question objQue2=new Question();
            objQue2=createQuestions();
            objQue2.CommunityId=objCom.id;
            objQue2.Product_Category__c='Microcontrollers';
            objQue2.Product_Sub_Category__c='X80C51';
            insert objQue2;
            system.assert(objQue2.Id!=null);
        
            QuestiondatacategorySelection objCatQue2=new QuestiondatacategorySelection();
            objCatQue2= createQuestiondatacategorySelections();
            objCatQue2.DataCategoryName='X80C51';
            objCatQue2.ParentId=objQue2.id;
            insert objCatQue2;
            system.assert(objCatQue2.Id!=null);
        
            Reply objRep= new Reply();
            objRep=createAnswers();
            objRep.QuestionId=objQue2.id;
            insert objRep;
            system.assert(objRep.Id!=null);
        
            FAQ__kav objFaq= new FAQ__kav();
            objFaq=createFAQs();
            insert objFaq;
            system.assert(objFaq.Id!=null);
        
            Faq__datacategorySelection objCatFaq1=new Faq__datacategorySelection();
            objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
        
            PageReference pageRef = Page.CommunityForumQuestionList;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('category', 'X80C51');
            CommunityForumQuestionListController comForumContrl= new CommunityForumQuestionListController();
            
            comForumContrl.strQuesId=objQue2.id;
            comForumContrl.likeQues();
            comForumContrl.showMore();
            comForumContrl.followQues();
            comForumContrl.strQues='test';
            comForumContrl.checkAll();
            comForumContrl.checkQues();
            comForumContrl.checkFaq();
            comForumContrl.questionFilterId='Solved Questions';
            comForumContrl.getQuestionView();
            comForumContrl.getQuestionViewByDate();
            comForumContrl.fetchQuestions();
            comForumContrl.sortOrder='desc';
            comForumContrl.sortOnReplies1(); 
            comForumContrl.sortOnReplies(); 
            comForumContrl.sortOnLikes1();
            comForumContrl.sortOnLikes();
            comForumContrl.sortOnLastPost1();
            comForumContrl.sortOnLastPost();
            comForumContrl.questionFilterDate='Recent Activity';
            comForumContrl.fetchQuestions();
            comForumContrl.questionFilterDate='Most Popular';
            comForumContrl.fetchQuestions();
            
            
            comForumContrl.questionFilterDate='Date Posted';
            comForumContrl.fetchQuestions();
            
            comForumContrl.questionFilterDate='Replies';
            comForumContrl.fetchQuestions();
            
            comForumContrl.questionFilterDate='Likes';
            comForumContrl.fetchQuestions();
            test.stopTest();
        }
    }
    
}