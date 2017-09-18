/*********************************************************************************************
@Created By :      Venakteshwar G
@Created Date :    3 Oct 2016
Description :      Community Live Chat survey controller where user can submit survey feedback after 
                   User Ends the chat and the Suveys are linked to respective Chat Transcript.
****************************************************************************************************/

public class CommunityLiveAgentChatSurveyController 
{
    public List<SelectOption> lstQuesValues{get;set;}
    public String chatKey{get;set;} 
    public String strResolved{get;set;}
    public String strResolutionTime{get;set;}
    public String strSupportPerson{get;set;}
    public String strLikeOurSupport{get;set;}
    public String strComment{get;set;}
    public boolean flgChinese{get;set;}
    public String RedirectionToLoginPage{get;set;}
    public CommunityLiveAgentChatSurveyController()
    {
        //below line is added by shridevi for redirecting to login page upon logout.
        RedirectionToLoginPage=(Site.getPathPrefix()+Label.Community_Login_URL);
     
    }
       
    //create picklist values based on question value field
    public List<SelectOption> getQuesValues()
    {
        lstQuesValues = new List<SelectOption>();
        List<Survey_question__c> objSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Chat Resolved ?' LIMIT 1];
        if(objSurveyQues.size()!=0 || objSurveyQues!=null)
        {
            List<String> lstStrQuesValue= objSurveyQues[0].value__c.split(',');
            for(string strValue: lstStrQuesValue)
            {
                lstQuesValues.add(new SelectOption(strValue,strValue));
            }            
        }
        return lstQuesValues;
    }
    
    //create picklist values based on question value field
    public List<SelectOption> getQuesValues1()
    {
        lstQuesValues = new List<SelectOption>();
        List<Survey_question__c> objSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Chat Like Our Support ?' LIMIT 1];
        if(objSurveyQues.size()!=0 || objSurveyQues!=null)
        {
            List<String> lstStrQuesValue= objSurveyQues[0].value__c.split(',');
            for(string strValue: lstStrQuesValue)
            {
                lstQuesValues.add(new SelectOption(strValue,strValue));
            }            
        }
        return lstQuesValues;
    }
       
    //method to submit survey answers for five question records
   
    public Pagereference submitSurvey()
    {
        List<Survey_question__c> lstSurveyQues = new List<Survey_question__c>();
        List<Live_Chat_Survey_Answer__c> lstSurveyAns = new List<Live_Chat_Survey_Answer__c>();
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Chat Resolved ?' LIMIT 1];
        if(lstSurveyQues.size()!=0 || lstSurveyQues!=null)
        {
            Live_Chat_Survey_Answer__c objAns= new Live_Chat_Survey_Answer__c();
            Id quesId;
            objAns.ChatKey__c = chatkey;
            quesId=lstSurveyQues[0].id;
            objAns.Chat_Survey_Question__c= quesId;
            objAns.Chat_Survey_Answer__c= strResolved;
            lstSurveyAns.add(objAns);
        }
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Chat Resolution Time ?' LIMIT 1];
        if(lstSurveyQues.size()!=0 || lstSurveyQues!=null)
        {
            Live_Chat_Survey_Answer__c objAns= new Live_Chat_Survey_Answer__c();
            objAns.ChatKey__c = chatkey;
            objAns.Chat_Survey_Question__c= lstSurveyQues[0].id;
            objAns.Chat_Survey_Answer__c= strResolutionTime;
            lstSurveyAns.add(objAns);
        }
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Chat Support Person ?' LIMIT 1];
        if(lstSurveyQues.size()!=0 || lstSurveyQues!=null)
        {
            Live_Chat_Survey_Answer__c objAns= new Live_Chat_Survey_Answer__c();
            objAns.ChatKey__c = chatkey;
            objAns.Chat_Survey_Question__c= lstSurveyQues[0].id;
            objAns.Chat_Survey_Answer__c= strSupportPerson;
            lstSurveyAns.add(objAns);
        }
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Chat Like Our Support ?' LIMIT 1];
        if(lstSurveyQues.size()!=0 || lstSurveyQues!=null)
        {
            Live_Chat_Survey_Answer__c objAns= new Live_Chat_Survey_Answer__c();
            objAns.ChatKey__c = chatkey;
            objAns.Chat_Survey_Question__c= lstSurveyQues[0].id;
            objAns.Chat_Survey_Answer__c= strLikeOurSupport;
            lstSurveyAns.add(objAns);
        }
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Chat Comments' LIMIT 1];
        if((lstSurveyQues.size()!=0 || lstSurveyQues!=null) && (strComment!=null || strComment!=''))
        {
            Live_Chat_Survey_Answer__c objAns= new Live_Chat_Survey_Answer__c();
            objAns.ChatKey__c = chatkey;
            objAns.Chat_Survey_Question__c= lstSurveyQues[0].id;
            objAns.Chat_Survey_Answer__c= strComment;
            lstSurveyAns.add(objAns);
        }
        
        try 
        {
            insert lstSurveyAns;  
            PageReference pageRef;
            pageRef=new PageReference('/CommunityLiveChatSurveySuccess');
            if(flgChinese==True)
            {  
            pageRef=new PageReference('/CommtyLiveSurveyChineseSuccessPage');
            }
            
            pageref.setRedirect(true);
            return pageref;
        }
        catch (DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in submitting survey feedback'));           
            return null;
        }
        
    }
    
    //method to link the Chat Surveys with the respective Live Chat Transcript records based on the Chta key
   Public static void linkChatSurveyToTranscript(List<LiveChatTranscript> lstliveChatTranscript)
   {   
   List<Live_Chat_Survey_Answer__c> lstChatSurvey= new List<Live_Chat_Survey_Answer__c>();
   List<Live_Chat_Survey_Answer__c> lstUpdateChatSurvey= new List<Live_Chat_Survey_Answer__c>();
   lstChatSurvey=[Select Id, ChatKey__c,  Chat_Survey_Answer__c,  Chat_Survey_Question__c, Live_Chat_Transcript__c From 
                Live_Chat_Survey_Answer__c where ChatKey__c!= null And Live_Chat_Transcript__c= null];
      
   Set<Live_Chat_Survey_Answer__c> setChatSurvey = new Set<Live_Chat_Survey_Answer__c>(lstChatSurvey); 
          
      for(LiveChatTranscript livchTrans :lstliveChatTranscript)
      {  
        for(Live_Chat_Survey_Answer__c objSur : setChatSurvey)
        {
          if(objSur.ChatKey__c == livchTrans.chatKey)
          {
             objSur.Live_Chat_Transcript__c = livchTrans.Id;
             lstUpdateChatSurvey.add(objSur);
             setChatSurvey.remove(objSur);
          }
        }  
              
      }
               update  lstUpdateChatSurvey;
           
  
 }
 
 //method to delete the related Chat survey answers of the Live Chat Transcript when the Chta Transcript is deleted
 Public static void deleteChatSurveyOfTranscript(List<LiveChatTranscript> lstliveChatTranscript)
 {
 List<Live_Chat_Survey_Answer__c> lstdelChatSurvey= new List<Live_Chat_Survey_Answer__c>();
 lstdelChatSurvey=[Select Id, ChatKey__c,  Chat_Survey_Answer__c,  Chat_Survey_Question__c, Live_Chat_Transcript__c From 
                Live_Chat_Survey_Answer__c where Live_Chat_Transcript__c In: lstliveChatTranscript];
 delete lstdelChatSurvey;
 }

}