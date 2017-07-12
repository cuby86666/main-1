/***********************************************************************************************************************************************************************************************************
@Created By :       Avichal Kumar
@Created Date:      1st July 2015
@Description:       Trigger to give points to community users for question post 
*************************************************************************************************************************************************************************************************************/
trigger CommunityQuestion_AfterInsert on Question (after insert) 
{
    list<Leaderboard_log__c> lstleaderboard = new list<Leaderboard_log__c>();
    CommunitySettings__c IdeaPostPoints = CommunitySettings__c.getValues('CommunityUrl');
    Decimal QuestionPost = IdeaPostPoints.Question_Post__c;
    CommunityQuestionTrigger comQuesTrigger= new CommunityQuestionTrigger();
    
    for (question objques : Trigger.new)
    {
    	Leaderboard_log__c objleaderboard = new Leaderboard_log__c ();
    
    	objleaderboard.community_user__c=UserInfo.getUserId();
    	objleaderboard.points__c= QuestionPost;
    	objleaderboard.type__c= 'Question Post';
    	objleaderboard.action_by__c=UserInfo.getUserId();
    	objleaderboard.Created_Date__c=system.today();
    	objleaderboard.QuestionId__c=objques.id;
    	lstleaderboard.add(objleaderboard);
    	
        comQuesTrigger.sendMailToGroup(objQues);
    }
    insert lstleaderboard; 
}