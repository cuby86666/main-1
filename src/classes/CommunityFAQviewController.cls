/**********************************************************************************************************************************************************************************************************************************************************
@Created By :       Avichal Kumar
@Created Date:      31th July 2015
@Description:       Controller class for communityFAQview 
***********************************************************************************************************************************************************************************************************************************************************/
public with sharing class CommunityFAQviewController
{
    public list<FaqWrapper> lstFaqWrapper = new list<FaqWrapper>();
    public list<FaqWrapper> lstFaq{get; set;}
    
    
    public CommunityFAQviewController()
    {
        lstFaq=new  list<FaqWrapper>();
        lstFaq=getFaqQuestions(); 
    }
    
    public List<FaqWrapper> getFaqQuestions() 
    {
    set<id> faqIds = new set<id>();
    set<id> knowledgeids = new set<id>();
    
    lstFaqWrapper.clear();
    
    //list to get FAQ ids
    list<knowledgeArticleVersion> lstFaqIds = new list<knowledgeArticleVersion>();
    lstFaqIds=[select id,KnowledgeArticleid,title from knowledgeArticleVersion where (PublishStatus = 'online' and Language = 'en_US' and Isvisibleinpkb=true and id  = :ApexPages.currentPage().getParameters().get('id')) ];
   
    for(knowledgeArticleVersion objfaqids:lstFaqIds)
    {
        knowledgeids.add(objfaqids.KnowledgeArticleid);
    }
    
    // list to get FAQ questions and answers   
    list<Faq__kav> lstFaqQuestions = new list<Faq__kav>();
    lstFaqQuestions=[select id,question__c,Answer__c from Faq__kav Where id = :ApexPages.currentPage().getParameters().get('id')];
    
    //list to get FAQ Category
    list<Faq__DatacategorySelection> lstFaqCategory = new list<Faq__DatacategorySelection>();
    lstFaqCategory =[select parentid, DataCategoryGroupName, DataCategoryName FROM FAQ__DataCategorySelection where (IsDeleted = false and parentid = :ApexPages.currentPage().getParameters().get('id'))];
    
    //List To Get FAQ Rating
    list<Faq__votestat> lstFaqRating = new list<Faq__votestat>();
    lstFaqRating =[select parentid,Normalizedscore from faq__votestat where (channel='pkb' and parentid in :knowledgeids)];
    
    faqwrapper objfaqwrapper = new faqwrapper(ApexPages.currentPage().getParameters().get('id'));
    lstFaqWrapper.add(objfaqwrapper);
    
    
    for (FaqWrapper objFaqWrapper1 :lstFaqWrapper)
          {
          for(knowledgeArticleVersion objfaqids1:lstFaqIds)
          {
              if(objFaqWrapper1.id == objfaqids1.id)
              {
                  objFaqWrapper1.knowledgeArticleid = objfaqids1.KnowledgeArticleid;
              }
          }
                
          for (faq__kav objfaqQuestions:lstFaqQuestions)
          {
              if(objFaqWrapper1.id==objfaqQuestions.id)
              {
          
                  objFaqWrapper1.question=objfaqQuestions.question__c;
                  objFaqWrapper1.Answer=objfaqQuestions.answer__c;
              }
          }
          for (faq__datacategoryselection objfaqCategory:lstFaqCategory)
          {
              if(objFaqWrapper1.id==objfaqCategory.parentid)
              {
                  objFaqWrapper1.category= objfaqCategory.DataCategoryName;
              }
          }
          for (faq__votestat objfaqRating:lstFaqRating)
          {
              if(objFaqWrapper1.knowledgeArticleid==objfaqRating.parentid)
              {
                  objFaqWrapper1.Rating= objfaqRating.Normalizedscore;
              }
          }
          
          
          }
          return lstFaqWrapper;
    }
    
    //Wrapper class to display FAQs
    public class FaqWrapper
    {

       
        public string Question{get; set;}
        
        public string Answer{ get; set; }
        
        public Id id{get;set;}
        
        public Id knowledgeArticleid{get;set;}
        
        public string category {get;set;}
        
        public decimal rating{get;set;}
       
        
        public FaqWrapper(Id id)
        {
          
          this.id=id;
             
            
         }
     }
      
      
}