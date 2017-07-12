public class AgentContributionArticleController {
    // The constructor must take a ApexPages.KnowledgeArticleVersionStandardController as an argument
  public AgentContributionArticleController(ApexPages.KnowledgeArticleVersionStandardController ctl) {
        SObject article = ctl.getRecord();   //this is the SObject for the new article. 
                                             //It can optionally be cast to the proper article type, e.g. FAQ__kav article = (FAQ__kav) ctl.getRecord();
        
        String sourceId = ctl.getSourceId(); //this returns the id of the case that was closed.
        Case c = [select subject, resolution__c from Case where id=:sourceId];
        
        article.put('title', c.subject);  //this overrides the default behavior of pre-filling the title of the article with the subject of the closed case. 
        article.put('Question__c',c.subject);                    
        article.put('Answer__c',c.resolution__c);
    }
}