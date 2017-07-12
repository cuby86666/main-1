/******************************************************************************************************************************************************************************************************************************************************* 
@Created By :       Avichal Kumar
@Created Date:      30th July 2015
@Description:       controller class for CommunityAllLeaderDisplay VF Page
********************************************************************************************************************************************************************************************************************************************************/

public with sharing class  CommunityAllleaderDisplayController 
{

    public List<leaderboardWrapper>  lstleaderboarddisplay{get; set;}
    public List<leaderboardWrapper> lstleaderboarddisplay1{get; set;}
    public List<leaderboardWrapper>  lstleaderboarddisplay2 {get; set;}
    public List<leaderboardWrapper>  lstleaderboardwrapper=new List<leaderboardWrapper>();
    set<string> communityusers = new set<string>();
    public integer index1{get;set;}
    public integer index2;
    public integer index3;
    public Id userId { get; set; }
    public List<user> lstUser{get; set;}

    public  CommunityAllleaderDisplayController()

    {
        lstleaderboarddisplay=new List<leaderboardWrapper>();
        lstleaderboarddisplay=getLeaderBoardUsers();
        lstleaderboarddisplay1=new List<leaderboardWrapper>();
        lstleaderboarddisplay2 =new List<leaderboardWrapper>();
        index2= lstleaderboarddisplay.size();
     
        if((math.mod(index2,2)) ==0)
        {
            index1=(( lstleaderboarddisplay.size())/2);
        }
        if((math.mod(index2,2)) ==1)
        {
            index1=((( lstleaderboarddisplay.size())/2)+ 1);
        }
     
        for(integer i=0;i<index1;i++)
        {
            lstleaderboarddisplay1.add( lstleaderboarddisplay.get(i));
        }
        for(integer i=index1;i<index2;i++)
        {
           lstleaderboarddisplay2 .add( lstleaderboarddisplay.get(i));
        }
    }
    
    public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
         return ConnectApi.chatterusers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    //Methods to get leaderboard users 
    public List<leaderboardWrapper> getLeaderBoardUsers() 
    {
        lstleaderboardwrapper.clear();
        list<Leaderboard_log__c> lstLeaderBoard=new list<Leaderboard_log__c>();
        list<Rewards_Programme_period__c> rewardsListWthSameEndDates=new list<Rewards_Programme_period__c>();                   
        Rewards_Programme_period__c finalRewardRecords=new Rewards_Programme_period__c(); 
        list<Rewards_Programme_period__c> rewardsList=[select id,End_Date__c,Start_Date__c from Rewards_Programme_period__c order by End_Date__c DESC];             
          
       if(rewardsList.size()!=0)
        {
                          
            for (Rewards_Programme_period__c rewardObj:rewardsList)
            {
                if(rewardObj.End_Date__c==rewardsList[0].End_Date__c)
                rewardsListWthSameEndDates.add(rewardObj);
                   
            }
            finalRewardRecords=rewardsListWthSameEndDates[0];
          
            for (Rewards_Programme_period__c rewardObj1:rewardsListWthSameEndDates)
            {
                if(finalRewardRecords.Start_Date__c <= rewardObj1.Start_Date__c)
                {
                    finalRewardRecords=rewardObj1;
                }             
            }    
          //  lstLeaderBoard = [select Community_user__c From Leaderboard_log__c where (Created_Date__c<=:finalRewardRecords.End_Date__c) and (Created_Date__c>=:finalRewardRecords.Start_Date__c) ];
        
        
            List<aggregateResult> groupedResults=new List<aggregateResult>();
            groupedResults= [SELECT Community_user__r.id userId, sum(points__c) FROM Leaderboard_log__c where (Created_Date__c<=:finalRewardRecords.End_Date__c) and (Created_Date__c>=:finalRewardRecords.Start_Date__c) GROUP BY Community_user__r.id order by sum(points__c) desc limit 401 ];
            
            for (AggregateResult ar : groupedResults) 
            {
                Communityusers.add((string)(ar.get('userId')));    
            }
                  
         /*   for (Leaderboard_log__c objleaderBoard:lstLeaderBoard)
            {
                Communityusers.add(objleaderBoard.Community_user__c);
            } */
            
            
            
           
            lstUser=[select Name,FullPhotoUrl from User where id in :Communityusers ];
            
            //code by Avichal Dec release  
            for(User objUser :lstUser)
            {
          
                leaderboardWrapper objleaderboardWrapper=new leaderboardWrapper(objUser.id,objUser.FullPhotoUrl,objUser.name );
                lstleaderboardwrapper.add(objleaderboardWrapper);
                
            }
           
           /* code for future refernce 
           for (leaderboardWrapper objleaderboardwrapper1 :lstleaderboardwrapper)
            {
                objleaderboardwrapper1.points = 0;
            for (Leaderboard_log__c objleaderBoard1:lstLeaderBoard)
            {
                if(objleaderboardwrapper1.Communityuserid == objleaderBoard1.Community_user__r.id)
                {
                if(objleaderBoard1.points__c != NULL)
                {
                    objleaderboardwrapper1.points = objleaderboardwrapper1.points + objleaderBoard1.points__c;
                    objleaderboardwrapper1.Communityuser=objleaderBoard1.Community_user__r.Name;
                    objleaderboardwrapper1.PhotoURl=objleaderBoard1.Community_user__r.FullPhotoUrl;
                }
                else
                {
                    continue;
                }    
                }
            }
            }  code for future reference ends */
            
            
                
            for(leaderboardWrapper objleaderboardwrapper1 :lstleaderboardwrapper)
            {
           
                for (AggregateResult ar : groupedResults) 
                {
               
                        if(ar.get('userId')==objleaderboardwrapper1.Communityuserid)
                        {
                        system.debug('+++++++ entering points');
                        objleaderboardwrapper1.points=integer.valueof((decimal)ar.get('expr0'));
                        }
        
    
                 }
             }
             lstleaderboardwrapper.sort(); 
        }
            for (integer i=0;i< lstleaderboardwrapper.size();i++)
            {
               lstleaderboardwrapper[i].Rank = i+1;
               index3= lstleaderboardwrapper[i].Rank;
        
        
            if(math.mod(index3,100)==11 || math.mod(index3,100)==12 ||math.mod(index3,100)==13)
            {
                lstleaderboardwrapper[i].ordering = 'th';
            }
        
     
            else if(math.mod(index3,10)==1  )
            {
                lstleaderboardwrapper[i].ordering='st';
            }
            else if(math.mod(index3,10)==2 )
            {
                lstleaderboardwrapper[i].ordering='nd';
            }
            else if(math.mod(index3,10)==3 )
            {
               lstleaderboardwrapper[i].ordering='rd';
            }
            else
            {
               lstleaderboardwrapper[i].ordering='th';
            }
            } 
              
            return lstleaderboardwrapper;
      
        
    }
    //Wrapper class for leaderboard display
    public class leaderboardWrapper implements Comparable
    {

       
        public string Communityuser{get; set;}
        public Decimal points{ get; set; }
        public Id Communityuserid{get;set;}
        public string PhotoURl {get;set;}
        Public integer Rank{get;set;}
        Public  String Ordering{get;set;}
       
        
        public LeaderBoardWrapper(Id Communityuserid,string photoURL,string communityuser)
        {
            this.Communityuserid=Communityuserid;
           this.PhotoURl =PhotoURl ;
           this.Communityuser=Communityuser;
        }
        public Integer compareTo(Object compareTo) 
        {
     
            // Cast argument to AccountHistoryWrapper
            LeaderBoardWrapper aHW = (LeaderBoardWrapper)compareTo;
     
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (points < aHW.points) 
            {
                // Set return value to a positive value.
                returnValue = 1;
            } 
            else if (points > aHW.points)
            {
                // Set return value to a negative value.
                returnValue = -1;
            }
     
            return returnValue;    
        }
        
     } 
}