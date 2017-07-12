/******************************************************************************************************
@Created By :      Avichal kumar
@CreatedDate :     11 Aug 2015
Description :      Test class for CommunityFAQviewController
************************************************************************************************************/

@isTest(seealldata=true)
public class CommunityFAQviewControllerTest 
{    
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
    
    //Method to create Faq data category
    public Static Faq__datacategorySelection createFaqdatacategorySelections()
    {
        Faq__datacategorySelection objCatFaq=new Faq__datacategorySelection();
        objCatFaq.DataCategoryGroupName= 'NXP';
        objCatFaq.datacategoryname='Automotive';
        return objCatFaq;
    }
    
    //Positive case: To fetch FAQS for specific FAQ id result. 
    static testmethod void CommunityFAQviewControllerTest1() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa17@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa17@test.com');
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
          test.starttest();    
     
          Faq__datacategorySelection objCatFaq1= createFaqdatacategorySelections();
          objCatFaq1.DataCategoryGroupName= 'NXP';
          objCatFaq1.datacategoryname='Automotive';
          objCatFaq1.ParentId=objFaq.id;
          insert objCatFaq1;
          system.assert(objCatFaq1.Id!=null);
          
          Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
          
          //Covering inner/wrapper class 
          CommunityFAQviewController.FaqWrapper empW = new CommunityFAQviewController.FaqWrapper(objFaq.id);
           test.stoptest();    
        
          PageReference pageRef = Page.communityFaq;
          Test.setCurrentPageReference(pageRef);
          System.currentPageReference().getParameters().put('id', objfaq.id);
        
           CommunityFAQviewController comForumContrl= new CommunityFAQviewController();
        }
    }
    
    
    //Negative case: To fetch FAQ where search Faq id is null. 
    static testmethod void CommunityFAQviewControllerTest2() 
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        
        User objUser = new User(alias = 'testing1',email='testingaa18@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objprofile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa18@test.com');
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
           test.starttest(); 
         
           Faq__datacategorySelection objCatFaq1=createFaqdatacategorySelections();
           objCatFaq1.ParentId=objFaq.id;
           insert objCatFaq1;
           system.assert(objCatFaq1.Id!=null);
          
           Faq__Votestat objFaqVotestat = [select parentid,Normalizedscore from Faq__Votestat where parentid =:objFaq.KnowledgeArticleId Limit 1];
           
           //Covering inner/wrapper class
           CommunityFAQController.FaqWrapper empW = new CommunityFAQController.FaqWrapper(objFaq.id);
               
          test.stoptest();
          PageReference pageRef = Page.CommunityFaq;
          Test.setCurrentPageReference(pageRef);
          System.currentPageReference().getParameters().put('id',null);
          CommunityFAQviewController comForumContrl= new CommunityFAQviewController();  
        }
    }
}