/****************************************************************************************************************************************************************************************************************  
@Created By :       Avichal Kumar
@Created Date:      9 Aug 2015
@Description:       Trigger to give points to community users for questlike and best reply
*****************************************************************************************************************************************************************************************************************/

trigger CommunityQuestion_Afterupdate on Question (after update) 
{
    list<Leaderboard_log__c> lstleaderboard = new list<Leaderboard_log__c>();
    CommunitySettings__c IdeaPostPoints = CommunitySettings__c.getValues('CommunityUrl');
    Decimal Questionlike = IdeaPostPoints.Question_like__c;
    Decimal BestAnswer = IdeaPostPoints.Question_BestReply__c;
    set<id> quesIds = new set<id>();
    map<id,id> mapRlyCreatedIds = new map<id,id>();
    Decimal likesCount = 0; 
    integer Flag = 0;
    id bestreplyid;
    
    for(question objques1:Trigger.old)
    {
        likesCount = objques1.Number_of_Question_Likes__c;
        bestreplyid = objques1.Best_Reply_Id__c;
    }
    
    for (question objques1 : Trigger.new)
    {
      quesIds.add(objques1.id);
    }
    
    for (reply rly : [select id,createdbyid from reply where questionid=:quesIds])
    {
    mapRlyCreatedIds.put(rly.id,rly.createdbyid);
    }
    
    for (question objques1 : Trigger.new)
    {
    Leaderboard_log__c objleaderboard = new Leaderboard_log__c ();
    if((likesCount + 1) == objques1.Number_of_Question_Likes__c)
    {
    objleaderboard.community_user__c=objques1.createdbyid;
    objleaderboard.points__c= Questionlike;
    objleaderboard.type__c= 'Question like';
    objleaderboard.action_by__c=UserInfo.getUserId();
    objleaderboard.Created_Date__c=system.today();
    objleaderboard.QuestionId__c=objques1.id;
    lstleaderboard.add(objleaderboard);
    flag=1;
    break;
    }
    
    if(bestreplyid ==NULL && objques1.Best_Reply_Id__c != NULL && ((likesCount + 1) != objques1.Number_of_Question_Likes__c) )
    {
    Leaderboard_log__c objleaderboard1 = new Leaderboard_log__c ();
    objleaderboard1.points__c= BestAnswer;
    objleaderboard1.Community_user__c=mapRlyCreatedIds.get(objques1.Best_Reply_Id__c) ;
    objleaderboard1.type__c= 'Best Answer';
    objleaderboard1.Created_Date__c=system.today();
    objleaderboard1.QuestionId__c=objques1.id;
    objleaderboard1.action_by__c=UserInfo.getUserId();
    lstleaderboard.add(objleaderboard1);
    }
    
    }
    insert lstleaderboard;  
}