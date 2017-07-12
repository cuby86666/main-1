/******************************************************************************************************
@Created By :      Avichal kumar
@CreatedDate :     10 Aug 2015
Description :      Test class for CommunityFAQController
************************************************************************************************************/

/******************************************************************************************************
@Modified By :      Avichal kumar
@ModifiedDate :     07 Sept 2015
Description :      Modified  Test class for CommunityFAQController(Subcategory Test data) 
************************************************************************************************************/

@isTest(seealldata=true)
public class CommunityFAQControllerTest 
{    
    //Method to create Faq data category
    public Static Faq__datacategorySelection createFaqdatacategorySelections()
    {
        Faq__datacategorySelection objCatFaq=new Faq__datacategorySelection();
        objCatFaq.DataCategoryGroupName= 'NXP';
        objCatFaq.datacategoryname='Automotive';
        return objCatFaq;
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
    
    
    
    //Positive case: To fetch FAQs for 'test' result 
    static testmethod void CommunityFAQControllerTest1() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa3@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa3@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.starttest();      
   
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
             test.stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strQues='test'; 
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.FirstPage();
             comForumContrl.previous();
             comForumContrl.next();
             comForumContrl.LastPage();
             comForumContrl.getprev();
             comForumContrl.getnxt();
             comForumContrl.strcategory= 'Identification and Security';
             comForumContrl.strsubcategory='Authentication';
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();
        }
    }
    
    //Positive case: To fetch Faqs for 'null' or ' ' string 
    static testmethod void CommunityFAQControllerTest2() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa4@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa4@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
             Test.starttest();  
        
             Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
             objCatFaq1.ParentId=objFaq.id;
             insert objCatFaq1;
             system.assert(objCatFaq1.Id!=null);
              
             Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
             
             //Covering inner/wrapper class 
             CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objfaq.id);
             Test.StopTest();       
            
             PageReference pageRef = Page.CommunityFaq;
             Test.setCurrentPageReference(pageRef);
            
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strQues=''; 
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.strcategory= 'Microcontrollers';
             comForumContrl.strsubcategory='chinese';
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();
          
        }
    }
    
    
    //Positive case: To fetch All FAQs  
    static testmethod void CommunityFAQControllerTest3() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa5@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa5@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.StartTest();        
   
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
             Test.Stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strcategory='Automotive';
             comForumContrl.strsubcategory='select sub category';
           
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();  
        }
    }
    
    
    //Positive case: To fetch FAQs for different catagory 
    static testmethod void CommunityFAQControllerTest4() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa6@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa6@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.starttest();      
     
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
            Test.stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strcategory='Automotive';
             comForumContrl.strsubcategory='General';
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();  
        }
    }
    
    //Positive case: To fetch FAQs for different catagory 
    static testmethod void CommunityFAQControllerTest5() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa6@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa6@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.starttest();      
     
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
            Test.stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strcategory=null;
             comForumContrl.strsubcategory=null;
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();
        }
    }
    
        //Positive case: To fetch FAQs for different catagory 
    static testmethod void CommunityFAQControllerTest6() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa6@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa6@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.starttest();      
     
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
            Test.stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strcategory='Interface Products';
             comForumContrl.strsubcategory='General';
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();
        }
    }
    
        //Positive case: To fetch FAQs for different catagory 
    static testmethod void CommunityFAQControllerTest7() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa6@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa6@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.starttest();      
     
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
            Test.stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strcategory='Logic';
             comForumContrl.strsubcategory='General';
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();
        }
    }
    
        //Positive case: To fetch FAQs for different catagory 
    static testmethod void CommunityFAQControllerTest8() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa6@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa6@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.starttest();      
     
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
            Test.stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strcategory='RF';
             comForumContrl.strsubcategory='Diodes';
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();
        }
    }
    
        //Positive case: To fetch FAQs for different catagory 
    static testmethod void CommunityFAQControllerTest9() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa6@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa6@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.starttest();      
     
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
            Test.stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strcategory='Standard Product';
             comForumContrl.strsubcategory='Diodes';
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();
        }
    }
    
        //Positive case: To fetch FAQs for different catagory 
    static testmethod void CommunityFAQControllerTest10() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa6@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa6@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.starttest();      
     
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
            Test.stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strcategory='Other Product';
             comForumContrl.strsubcategory='General';
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();
        }
    }
    
            //Positive case: To fetch FAQs for different catagory 
    static testmethod void CommunityFAQControllerTest11() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa6@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa6@test.com');
        insert objUser;
    
        FAQ__kav  objFaq=createFAQs();
        insert objFaq;
        
        //retrieve master article Id created on FAQ__kav record insertion
        //in order to get the KnowledgeArticleId
        objFaq = [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id = :objFaq.Id Limit 1];
        
        //publish it
        KbManagement.PublishingService.publishArticle(objFaq.KnowledgeArticleId, true);
        system.assert(objFaq.Id!=null);
        
        system.runAs(objUser)
        {
            Test.starttest();      
     
            Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
            objCatFaq1.DataCategoryGroupName= 'NXP';
            objCatFaq1.datacategoryname='Automotive';
            objCatFaq1.ParentId=objFaq.id;
            insert objCatFaq1;
            system.assert(objCatFaq1.Id!=null);
          
            Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
            
            //Covering inner/wrapper class
            CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
                
            Test.stoptest();   
        
            PageReference pageRef = Page.communityFaq;
            Test.setCurrentPageReference(pageRef);
        
             CommunityFAQController comForumContrl= new CommunityFAQController();
             comForumContrl.strcategory='Select Category';
             comForumContrl.strsubcategory='Select sub Category';
             comForumContrl.checkQues();
             comForumContrl.getCatagorizedFAQ2();
             comForumContrl.CatagorizedFAQ();
             comForumContrl.CatagorizedFAQ1();
             comForumContrl.getCategories();
             comForumContrl.getSubCategories();
        }
    }
}