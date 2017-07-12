/******************************************************************************************************
@Created By :      Avichal kumar
@CreatedDate :     17 july 2015
Description :      controller class for CommunityOverview page
************************************************************************************************************/

/******************************************************************************************************
@Modified By :      Avichal kumar
@ModifiedDate :     28 August 2015
Description :      Null Pointer Exception Handling For displaying Stories
************************************************************************************************************/


public with sharing class CommunityOverviewController 
{

    public String CommunitiesStoryZoneId{get;set;}
    public boolean showLeaderBoard { get; set; }
    public list<string> ordering{ get; set; }
    public integer index { get; set; }
    public List<leaderboardWrapper> lstleaderboarddisplay{get; set;}
    public List<question> lstquestiondisplay{get; set;}
    public List<idea> lststorydisplay{get; set;}
    public List<idea> lststorydisplay1{get; set;}
    public List<idea> lststorydisplay2{get; set;}
    public List<leaderboardWrapper> lstleaderboardwrapper=new List<leaderboardWrapper>();
    set<string> communityusers = new set<string>();
    public List<Question> lstQue;
    public List<question> lstSearchQues{get;set;}
    public String strQues{get;set;}
    public List<knowledgeArticleVersion> lstSearchFaq{get;set;}
    public Boolean isQuesList{get;set;}
    public Boolean isFaqList{get;set;}
    public List<knowledgeArticleVersion> lstFaq;
    public Community objCom{get;set;}
    public Id userId { get; set; }
    public string objsubstring{get;set;}
    public string objsubstring1{get;set;}
    public string objsubstring2{get;set;}
    public string objsubstring3{get;set;}
     public List<user> lstUser{get; set;}
    
    
    CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');

    public communityoverviewcontroller()
    {
         objCom=[Select id,name from Community where name='NXP Community'];

        CommunitiesStoryZoneId= cs.CommunitiesStoryZoneId__c;
        index=1;
        lstleaderboarddisplay=new List<leaderboardWrapper>();
        lstleaderboarddisplay=getLeaderBoardUsers();
        lstquestiondisplay=new List<Question>();
        lstquestiondisplay=getLatestQuestions();
        lststorydisplay=new List<idea>();
        lststorydisplay=getLatestStories();
        lststorydisplay1=new List<idea>();
        lststorydisplay2=new List<idea>();
        
        
    /*    if(lststorydisplay[0] != null )
        {
        string objstring = lststorydisplay[0].body;
        if (objstring.containsIgnoreCase('Src'))
        {
        integer objindex1 = objstring.indexof('src');
        integer objindex2 = objstring.indexof('"');
        string objsubstringold = objstring.substringAfter('src');
        objsubstring = objsubstringold.substringbetween('"','"');
        system.debug('+++++++'+objsubstring);
        }
        }
        
        if(lststorydisplay[1] != null )
        {
        string objstring1 = lststorydisplay[1].body;
        if (objstring1.containsIgnoreCase('Src'))
        {
        integer objindex11 = objstring1.indexof('src');
        integer objindex21 = objstring1.indexof('"');
        string objsubstringold1 = objstring1.substringAfter('src');
        objsubstring1 = objsubstringold1.substringbetween('"','"');
        system.debug('+++++++'+objsubstring1);
        }
        }
        
        if(lststorydisplay[2] != null )
        {
        string objstring2 = lststorydisplay[2].body;
        if (objstring2.containsIgnoreCase('Src'))
        {
        integer objindex12 = objstring2.indexof('src');
        integer objindex22 = objstring2.indexof('"');
        string objsubstringold2 = objstring2.substringAfter('src');
         objsubstring2 = objsubstringold2.substringbetween('"','"');
        system.debug('+++++++'+objsubstring2);
        }
        }
        
        if(lststorydisplay[3] != null )
        {
        string objstring3 = lststorydisplay[3].body;
        if (objstring3.containsIgnoreCase('Src'))
        {
        integer objindex13 = objstring3.indexof('src');
        integer objindex23 = objstring3.indexof('"');
        string objsubstringold3 = objstring3.substringAfter('src');
        objsubstring3 = objsubstringold3.substringbetween('"','"');
        system.debug('+++++++'+objsubstring3);
        }
        } */
        
        if(lststorydisplay.size()==1)
        {
        lststorydisplay1.add(lststorydisplay.get(0));
        }
        else if(lststorydisplay.size()==2)
        {
        lststorydisplay1.add(lststorydisplay.get(0));
        lststorydisplay1.add(lststorydisplay.get(1));
        }
        else if(lststorydisplay.size()==3)
        {
            lststorydisplay1.add(lststorydisplay.get(0));
        lststorydisplay1.add(lststorydisplay.get(1));
        lststorydisplay2.add(lststorydisplay.get(2));
        }
        else if(lststorydisplay.size()>3)
        {
            lststorydisplay1.add(lststorydisplay.get(0));
        lststorydisplay1.add(lststorydisplay.get(1));
        lststorydisplay2.add(lststorydisplay.get(2));
        lststorydisplay2.add(lststorydisplay.get(3));
        }
                
        
        if(lstleaderboarddisplay.size()==0)
        {
            showLeaderBoard = False;
        }
        If(lstleaderboarddisplay.size()!=0)
        {
        showLeaderBoard = True;
        }
        
        ordering=new list<string>();
        ordering.add('st');
        ordering.add('nd');
        ordering.add('rd');
        ordering.add('th');
        ordering.add('th');
        ordering.add('th');
        ordering.add('th');
        ordering.add('th');
        ordering.add('th');
        ordering.add('th');
        

    }
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
            groupedResults= [SELECT Community_user__r.id userId, sum(points__c) FROM Leaderboard_log__c where (Created_Date__c<=:finalRewardRecords.End_Date__c) and (Created_Date__c>=:finalRewardRecords.Start_Date__c) GROUP BY Community_user__r.id order by sum(points__c) desc limit 10 ];
            
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
        return lstleaderboardwrapper;
    }
    //code by Avichal Kumar ends
   
    public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.userprofiles.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    public List<idea> getLatestStories()
    {
        list<idea> lstlateststories = new list<idea> ();
        lstlateststories  = [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,attachmentbody,AttachmentContentType,attachmentname FROM Idea where communityId=:CommunitiesStoryZoneId order by CreatedDate desc limit 6];
        
        return lstlateststories ;
        
    }
    public List<question> getLatestQuestions()
    {
        list<question> lstlatestQuestion = new list<question> ();
        lstlatestQuestion = [Select id,body,title,CreatedBy.Name,CreatedDate from question where communityId=:objCom.id ORDER BY CreatedDate DESC limit 10];
        return lstlatestQuestion;
    }
    
    public class leaderboardWrapper implements Comparable
    {

       
        public string Communityuser{get; set;}
        public integer points{ get; set; }
        public Id Communityuserid{get;set;}
        public string PhotoURl {get;set;}
        
        //code by avichal Kumar dec release 
        public LeaderBoardWrapper(Id Communityuserid,string PhotoURl,string Communityuser )
        {        
           this.Communityuserid=Communityuserid;
           this.PhotoURl =PhotoURl ;
           this.Communityuser=Communityuser;
           
        }
        //code by avichal Kumar dec release ends
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
      
     public void checkQues()
    {
        isQuesList=true;
        isFaqList=false;
        String strTitle= '%'+strQues+'%';
        lstSearchQues=new List<question>();
        if(strQues==null || strQues=='')
        {
            lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,NumReplies,creatorName,NumSubscriptions,createdby.id from question where communityId=:objCom.id order by createddate DESC LIMIT 200];
        }
        else
        {
            lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,NumReplies,creatorName,NumSubscriptions,createdby.id from question where title like: strTitle and communityId=:objCom.id order by createddate DESC LIMIT 500];
        }
        for(Question objQue: lstQue)
        {
            lstSearchQues.add(objQue);   
        }    
    }
    
     public void checkAll()
    {
        
        isQuesList=true;
        isFaqList=true;
        String strTitle= '%'+strQues+'%';
        lstSearchQues=new List<question>();
         if(strQues==null || strQues=='')
            {
                lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,NumReplies,creatorName,NumSubscriptions,createdby.id from question where communityId=:objCom.id order by createddate DESC LIMIT 200];
            }
            else
            {
                lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,NumReplies,creatorName,NumSubscriptions,createdby.id from question where title like: strTitle and  communityId=:objCom.id order by createddate DESC LIMIT 250];
            }
            
            for(Question objQue: lstQue)
            {
                lstSearchQues.add(objQue);
                
            }  
            lstSearchFaq=new List<knowledgeArticleVersion>();
            if(strQues==null || strQues=='')
            {
                lstFaq= [Select id,title from KnowledgeArticleVersion where (publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC LIMIT 250];
            }
            else
            {
                lstFaq= [Select id,title from KnowledgeArticleVersion where (title like: strTitle and publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC LIMIT 250];
                
            }
            
            for(knowledgeArticleVersion objFaq: lstFaq)
            {
                lstSearchFaq.add(objFaq);
                
            } 
        }
         
    
    public void checkFaq()
    {
        isQuesList=false;
        isFaqList=true;
        String strTitle= '%'+strQues+'%';
        lstSearchFaq=new List<knowledgeArticleVersion>();
        if(strQues==null || strQues=='')
        {
            lstFaq= [Select id,title from KnowledgeArticleVersion where (publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC LIMIT 200];
        }
        else
        {
            lstFaq= [Select id,title from KnowledgeArticleVersion where (title like: strTitle and publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC LIMIT 500];

        }

        for(knowledgeArticleVersion objFaq: lstFaq)
        {
             lstSearchFaq.add(objFaq);
                
        } 
    } 

}