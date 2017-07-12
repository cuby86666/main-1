/***************************************************************************************************
@Created By :      Amrutha R
@Created Date:     22 May 2015
@Description:      Trigger on question object to check whether it contains abusing words while posting 
				   to community.
*******************************************************************************************************/

trigger CommunityChatterQuestion_BeforeInsert on Question (before insert) 
{
    List<Filtered_Words__c> lstfilteredWords= new List<Filtered_Words__c>();
    lstfilteredWords= [Select Name From Filtered_Words__c];
    
    for (Question objQue: Trigger.new) 
    {
        for(Filtered_Words__c objfilteredWord : lstfilteredWords)
        {
            if(objQue.title.containsIgnoreCase(objfilteredWord.Name))
            {
                CommunityChatterQuestionReplyTrigger.sendEmailToModerators(objQue.title,objQue.body,objQue.id);
                break;
            }
            if(objQue.body.containsIgnoreCase(objfilteredWord.Name))
            {
                CommunityChatterQuestionReplyTrigger.sendEmailToModerators(objQue.title,objQue.body,objQue.id);
                break;
            }
        }
        for(Filtered_Words__c objfilteredWord : lstfilteredWords)
        {    
            if(objQue.title.containsIgnoreCase(objfilteredWord.Name))
            {
                objQue.title= CommunityChatterQuestionReplyTrigger.splitAndConcatenate(objQue.title,objfilteredWord.Name);
            }
            if(objQue.body.containsIgnoreCase(objfilteredWord.Name))
            {
                objQue.body= CommunityChatterQuestionReplyTrigger.splitAndConcatenate(objQue.body,objfilteredWord.Name);
            }
        }
    }
}