/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     18 Jul 2015
Description :      Class for NXP community users to search all question-
                   CommunityForum page
************************************************************************************************************/

public class CommunityForumController 
{
    public List<Question> lstQue;
    public List<question> lstSearchQues{get;set;}
    public String strQues{get;set;}
    public List<knowledgeArticleVersion> lstSearchFaq{get;set;}
    public Boolean isQuesList{get;set;}
    public Boolean isFaqList{get;set;}   
    public List<knowledgeArticleVersion> lstFaq;
    public Id userId { get; set; }
    
    public Community objCom{get;set;}
    
    public CommunityForumController()
    {
        objCom=[Select id,name from Community where name='NXP Community'];
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
     public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
     public void checkAll()
    {
        
        isQuesList=true;
        isFaqList=true;
        String strTitle= '%'+strQues+'%';
        lstSearchQues=new List<question>();
         if(strQues==null || strQues=='')
            {
                lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,NumReplies,creatorName,NumSubscriptions,createdby.id from question where communityId=:objCom.id order by createddate DESC LIMIT 250];
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