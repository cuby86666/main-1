/***************************************************************************************************************************************************************************************************************
@Created By :       Avichal Kumar
@Created Date:      1st July 2015
@Description:       trigger to give points to community user for story post
****************************************************************************************************************************************************************************************************************/

trigger Communityidea_AfterInsert on Idea (after insert)
{
   list<Leaderboard_log__c> lstleaderboard = new list<Leaderboard_log__c>(); 
    
    CommunitySettings__c IdeaPostPoints = CommunitySettings__c.getValues('CommunityUrl');
    Decimal IdeaPost = IdeaPostPoints.Idea_Post__c;
    
    for (idea objidea : Trigger.new)
    {
        Leaderboard_log__c objleaderboard = new Leaderboard_log__c ();
        objleaderboard.community_user__c=UserInfo.getUserId();
        objleaderboard.points__c= IdeaPost;
        objleaderboard.type__c= 'Idea Post';
        objleaderboard.Created_Date__c=system.today();
        objleaderboard.IdeaId__c=objidea.id;
        objleaderboard.action_by__c=UserInfo.getUserId();
        lstleaderboard.add(objleaderboard);
        }
    insert lstleaderboard; 

}