/****************************************************************************************************************************************************************************************************************
@Created By :       Avichal Kumar
@Created Date:      9th August 2015
@Description:       Trigger to give points to community users for answer like 
*****************************************************************************************************************************************************************************************************************/

trigger CommunityReply_Afterupdate on Reply (after update) 
{
    list<Leaderboard_log__c> lstleaderboard = new list<Leaderboard_log__c>();
    CommunitySettings__c IdeaPostPoints = CommunitySettings__c.getValues('CommunityUrl');
    Decimal Answerlike = IdeaPostPoints.Answer_like__c;
    Decimal likesCount = 0; 
    integer Flag = 0;
    
    for(Reply objAns1:Trigger.old)
    {
        likesCount = objAns1.Number_of_Answer_Likes__c;
    }
    
    for (Reply objAns : Trigger.new)
    {
        Leaderboard_log__c objleaderboard = new Leaderboard_log__c ();
        if((likesCount + 1) ==objAns.Number_of_Answer_Likes__c)
        {
            objleaderboard.community_user__c=objAns.createdbyid;
            objleaderboard.points__c= Answerlike;
            objleaderboard.type__c= 'Answer like';
            objleaderboard.action_by__c=UserInfo.getUserId();
            objleaderboard.Created_Date__c=system.today();
            objleaderboard.ReplyId__c=objAns.id;
            lstleaderboard.add(objleaderboard);
            flag=1;
            break;
        }
    
    }
    insert lstleaderboard; 
}