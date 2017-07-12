/*************************************************************************************************************************************************************************************************************
@Created By :       Avichal Kumar
@Created Date:      1 july 2015
@Description:       trigger to give points to community users for reply to post
**************************************************************************************************************************************************************************************************************/

trigger CommunityReply_AfterInsert on Reply (after insert) 
{
     list<Leaderboard_log__c> lstleaderboard = new list<Leaderboard_log__c>();
    CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
    Decimal AnswerPost= cs.Answer_post__c; 
            
    for (Reply objreply : Trigger.new)
    {
        Leaderboard_log__c objleaderboard = new Leaderboard_log__c ();
        objleaderboard.community_user__c=UserInfo.getUserId();
        objleaderboard.points__c= AnswerPost;
        objleaderboard.type__c= 'Answer Post';
        objleaderboard.Created_Date__c=system.today();
        objleaderboard.ReplyId__c=objreply.id;
        objleaderboard.action_by__c=UserInfo.getUserId();
        lstleaderboard.add(objleaderboard);
    }
    insert lstleaderboard; 

}