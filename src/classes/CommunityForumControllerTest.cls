/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     05 Aug 2015
Description :      Test class for CommunityForumController
************************************************************************************************************/

@isTest
public class CommunityForumControllerTest 
{
	//Method to create questions
    private Static question createQuestions()
    {
        Question objQue=new Question();
        objQue.title='test1';
        objQue.body='test1';
        return objQue;
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
    
    //Positive case: To fetch question for 'test' result. 
    static testmethod void CommunityForumControllerTest1() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa39@test.com',emailencodingkey='UTF-8',
	    lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa39@test.com');
	    insert objUser;
        
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
            Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.Question_Post__c= 10;
        	insert setting;
        	system.assert(setting.Id!=null);
            
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
            
            QuestionSubscription objQueSub=new QuestionSubscription();
            objQueSub.QuestionId=objQue2.id;
            objQueSub.SubscriberId=objUser.id;
            insert objQueSub;
        
        
        	PageReference pageRef = Page.CommunityForumQuestionList;
        	Test.setCurrentPageReference(pageRef);
        	System.currentPageReference().getParameters().put('category', 'Automotive');
        	CommunityForumController comForumContrl= new CommunityForumController();
        	comForumContrl.strQues='test';
        	comForumContrl.checkAll();
        	comForumContrl.checkQues();
            comForumContrl.checkFaq();
            test.stopTest();
        }
    }
    
    //Negative case: To fetch question where search field is null. 
    static testmethod void CommunityForumControllerTest2() 
    {
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa40@test.com',emailencodingkey='UTF-8',
	    lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa40@test.com');
	    insert objUser;
        
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
            Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
            CommunitySettings__c setting = new CommunitySettings__c();
        	setting.Name = 'CommunityUrl';
        	setting.Question_Post__c= 10;
        	insert setting;
        	system.assert(setting.Id!=null);
            
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
            
            QuestionSubscription objQueSub=new QuestionSubscription();
            objQueSub.QuestionId=objQue2.id;
            objQueSub.SubscriberId=objUser.id;
            insert objQueSub;
        
        	
        
        	PageReference pageRef = Page.CommunityForumQuestionList;
        	Test.setCurrentPageReference(pageRef);
        	System.currentPageReference().getParameters().put('category', 'Automotive');
        	CommunityForumController comForumContrl= new CommunityForumController();
        	comForumContrl.strQues='';
        	comForumContrl.checkAll();
        	comForumContrl.checkQues();
            comForumContrl.checkFaq();
            test.stopTest();
        }
    }
}