/*****************************************************************************************
@Created By :   Ranganath C N
@Created Date:  31 Aug 2018
@Description:    To display Survey_answres update in case object feed as a part of SFDC-1967.
*******************************************************************************************/
public class surveyfeedcaseclass
{
    public static void casefeed(List<Survey_Answer__c> surveyupdate,map<id,Survey_Answer__c> surveyOld)
    {
         Map<Id,String> surveyquest = new Map<Id,String>();
         set<id> setSurveyCase = new set<id> ();
         
         for(Survey_Answer__c objSurvAnswer :surveyupdate ){
          //   surveymapcase.put(c.Id,c.Case__c);
             setSurveyCase.add(objSurvAnswer.Case__c);
          }
    
        list<FeedItem> lstFeeds = new list<FeedItem>();  
        
        List<Case> lstCases= new List<Case>();
        lstCases = [select Id from case where id=:setSurveyCase];
    
        List<Survey_Question__c> lstSurveyQuestion = new List<Survey_Question__c>();
        lstSurveyQuestion = [select id,Question__c from Survey_Question__c];
    
        for(Survey_Question__c objSurQues: lstSurveyQuestion){
        surveyquest.put(objSurQues.Id,objSurQues.Question__c);
        }
        
        for(Survey_Answer__c objSurAns :surveyupdate ){
            for(Case objCase : lstCases){
                if(objSurAns.Case__c == objCase.id)
                {
                    FeedItem feed = new FeedItem(); 
                    feed.ParentId= objCase.Id;
                   // String aa = Trigger.oldMap.get(sa.Id).Answer__c;
                   String surAns = surveyOld.get(objSurAns.Id).Answer__c;
                    String question = surveyquest.get(objSurAns.Survey_Question__c); 
                    feed.Body = 'changed the value' + ' ' + 'from'  + ' ' + surAns +' '+ 'to' + ' ' +  objSurAns.Answer__c + ' '+'for question' + ' '+ '\'' + + ' ' +question + ' '+ '\'';
                    lstFeeds.add(feed);
                }
          }
     }
     
      insert lstFeeds;
    }
}