/***************************************************************************************************
@Created By :      Amrutha R
@Created Date:     22 May 2015
@Description:      Trigger on reply object to check whether it contains abusing words while posting 
                   to community.
*******************************************************************************************************/

trigger CommunityChatterReply_BeforeInsert on Reply (before insert,after insert) 
{
    List<Filtered_Words__c> lstfilteredWords= new List<Filtered_Words__c>();
    lstfilteredWords= [Select Name From Filtered_Words__c];
    List<Reply> lstRep= new List<Reply>();
    
    for (Reply objRep: Trigger.new) 
    {
        Question objQue = [Select id,title from Question where id=:objRep.QuestionId];

        for(Filtered_Words__c objfilteredWord : lstfilteredWords)
        {
            if(objRep.body.containsIgnoreCase(objfilteredWord.Name))
            {
                CommunityChatterQuestionReplyTrigger.sendEmailToModerators(objQue.title,objRep.body,objQue.id);
                break;
            }
        }
        for(Filtered_Words__c objfilteredWord : lstfilteredWords)
        {
            if(objRep.body.containsIgnoreCase(objfilteredWord.Name))
            {
                objRep.body= CommunityChatterQuestionReplyTrigger.splitAndConcatenate(objRep.body,objfilteredWord.Name);
            }
        }
    }
}