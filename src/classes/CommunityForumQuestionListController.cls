/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     18 Jul 2015
Description :      Class for NXP community users to view,like,follow and submit answers question-
                   CommunityForumQuestionList,CommunityForumQuestionGrid pages
************************************************************************************************************/
/******************************************************************************************************
@Modified By :      Avichal Kumar
@ModifiedDate :     1 September 2015
Description :      Methods For Pagination
************************************************************************************************************/
/******************************************************************************************************
@Modified By :      Amrutha R   
@ModifiedDate :     23 Nov 2015
Description :       Fixed Pagination issue
************************************************************************************************************/

public class CommunityForumQuestionListController 
{
    public boolean descRep { get; set; }
    public boolean ascRep { get; set; }
    public boolean descLike { get; set; }
    public boolean ascLike { get; set; }
    public boolean descLast { get; set; }
    public boolean ascLast { get; set; }
    public boolean repliesFlag { get; set; }
    public boolean filterFlag { get; set; }
    public boolean likesFlag { get; set; }
    public boolean lastPostFlag { get; set; }
    public String sortOrder{get;set;}
    public String strCategory{get;set;}
    public String filterCategory{get;set;}
    public List<question> lstQues{get;set;}
    public List<question> lstQues1{get;set;}
    public List<question> lstSearchQues{get;set;}
    public List<knowledgeArticleVersion> lstSearchFaq{get;set;}
    public list<Reply> lstReply{get; Set;}
    public List<QuestionSubscription> setQuesSub{get;set;}
    public Set<ID> setQuesIds= new Set<ID>();
    public String questionFilterId {get;set;}
    public String questionFilterDate{get;set;}
    public Boolean searchList{get;set;}
    public String strQues{get;set;}
    public String strUrl{get;set;}
    public String strQuesId{get;set;}
    public Set<id> setQuesSubIDs{get;set;}
    public Set<id> setQuesLikeIDs{get;set;}
    public Boolean searchResult{get;set;}
    public List<Question> lstQue;
    public Map<id,question> lstQue1{get;set;}
    public List<knowledgeArticleVersion> lstFaq;
    public List<QuestiondatacategorySelection> lstQueSel;
    public integer index{get;set;}
    public List<Faq__datacategorySelection> lstFaqSel;
    public Boolean isQuesList{get;set;}
    public Boolean isFaqList{get;set;}
    public Boolean chatBox{get;set;}
    public Community objCom{get;set;}
    public integer noOfQues{get;set;}
    public List<Id> lstofQuesIds;
    public List<Id> lstofFaqIds;
    private integer totalRecs=0;
    private integer OffsetSize = 0;
    private integer LimitSize= 10;
    public String strCategoryName{get;set;}
    public Boolean isMainForum{get;set;}
    public Boolean isNotMainForum{get;set;}
    public Integer pageNum{get;set;}
    public Integer totalPages{get;set;}
    public Id userId { get; set; }
    public List<PermissionSetAssignment> lstPermSet{get;set;}
    public Set<Id> setModeratorIds {get;set;}
    public List<Case> lstCase{get;set;}
    public boolean isInternal{get;set;}
    public Integer questionLimit{get;set;}
    
    public CommunityForumQuestionListController()
    {   
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        questionLimit= (Integer)cs.Question_Limit__c;
        system.debug('+++limit '+questionLimit);
        User objUser = [Select id,Email,Name,firstname,lastname from user where id=:userInfo.getUserId()];
        if (objUser.email.toLowercase().substringafter('@').equals('nxp.com'))
        {
            isInternal=true;
        }
        else
        {
            isInternal=false;
        }
        setModeratorIds= new Set<Id>();
        lstPermSet= [Select Assignee.email,Assignee.id, PermissionSet.Name From PermissionSetAssignment Where permissionset.name='Community_Moderator'];
        for(PermissionSetAssignment objPermSet: lstPermSet)
        {
            setModeratorIds.add(objPermSet.Assignee.id);
        }
        objCom=[Select id,name from Community where name='NXP Community'];        
        index=10;
        ascRep=true;
        ascLike =true;
        ascLast =true;
        filterFlag =true;
        isQuesList=true;
        isFaqList=true;
        searchList=false;
        searchResult=false;
        chatBox=false;
        if(ApexPages.currentPage().getParameters().get('category')=='Microcontrollers')
        {
            chatBox=true;
        }
        
        if(ApexPages.currentPage().getParameters().get('category')==null || ApexPages.currentPage().getParameters().get('category')=='')
        {
            strUrl= 'Other Products';
        }  
        else
        {
            strUrl=ApexPages.currentPage().getParameters().get('category').substringBefore('?');
        }
        questionFilterId='All Questions';
        questionFilterDate='Date Posted';
        if(strUrl.contains('Diodes'))
        {
            strCategory= 'Diodes';
        }
        else
        {
            strCategory= strUrl;
        }  
        filterCategory=getDescribeDataCategoryGroupStructureResults();
        
        lstQues= new List<question>();
        lstSearchQues=new List<question>();
        lstofQuesIds=new List<Id>();
        lstQue = new List<question>();
        lstQue1 = new Map<id,question>();
        
        if(strUrl.equalsIgnoreCase('RF Diodes') )
        {
            lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,
                     createdby.id,Product_Category__c,Product_Sub_Category__c from question 
                     where communityId=:objCom.id and  Product_Category__c='RF' 
                     and Product_Sub_Category__c='Diodes' order by createddate DESC limit :LimitSize offset :OffsetSize];
            lstQue1 = new Map<id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,
                     createdby.id,Product_Category__c,Product_Sub_Category__c from question 
                     where communityId=:objCom.id and  Product_Category__c='RF' 
                     and Product_Sub_Category__c='Diodes' order by createddate DESC LIMIT :questionLimit]);
            
            
        }
        else if(strUrl.equalsIgnoreCase('Diodes') )
        {
            lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,
                     createdby.id,Product_Category__c,Product_Sub_Category__c from question 
                     where communityId=:objCom.id and  Product_Category__c='Discretes and Logic' 
                     and Product_Sub_Category__c='Diodes' order by createddate DESC limit :LimitSize offset :OffsetSize];
            lstQue1 = new Map<id,question>( [Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,
                     createdby.id,Product_Category__c,Product_Sub_Category__c from question 
                     where communityId=:objCom.id and  Product_Category__c='Discretes and Logic' 
                     and Product_Sub_Category__c='Diodes' order by createddate DESC LIMIT :questionLimit]);
            
        }
    
        else
        {
            lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,
                     createdby.id,Product_Category__c,Product_Sub_Category__c from question 
                     where communityId=:objCom.id and  (Product_Category__c=:strUrl 
                     or Product_Sub_Category__c=:strUrl) order by createddate DESC limit :LimitSize offset :OffsetSize];
            lstQue1 = new Map<id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,
                     createdby.id,Product_Category__c,Product_Sub_Category__c from question 
                     where communityId=:objCom.id and  (Product_Category__c=:strUrl 
                     or Product_Sub_Category__c=:strUrl) order by createddate DESC LIMIT :questionLimit]);
            
        } 
       
        strCategoryName='Main';
        isMainForum=true;
        isNotMainForum=false;
        for(Question objQue: lstQue)
        {
            lstQues.add(objQue);
            
            if(!strUrl.equalsIgnoreCase(objQue.Product_Category__c))
            {
                strCategoryName=objQue.Product_Category__c;
                isMainForum=false;
                isNotMainForum=true;
            }
            
            
        }
        for(Id id : lstQue1.keySet())
        {
            Question objQue= lstQue1.get(id);
            setQuesIds.add(objQue.id);
            if(!strUrl.equalsIgnoreCase(objQue.Product_Category__c))
            {
                strCategoryName=objQue.Product_Category__c;
                isMainForum=false;
                isNotMainForum=true;
            }
            
            lstSearchQues.add(objQue);  
        }
        lstCase= [Select id, question.id,CaseNumber from case where question.id IN: setQuesIds LIMIT 10];
        if(lstQue1.size()== 0)
        {
            pageNum=0;    
        }
        else
        {
            pageNum=1;
        }
        totalpages=(integer)(lstQue1.size()/limitsize);
        if(lstQue1.size() < limitsize && lstQue1.size() > 0)
        {
            totalpages = 1;
        }
        if((math.mod(lstQue1.size(),limitsize)!=0) && lstQue1.size() > limitsize)
        {
            totalpages = totalpages+1;
        }    
        
        
        lstReply = [Select body,id,createdby.Name,createdDate,Number_of_Answer_Likes__c,questionId,createdby.id From Reply WHERE QuestionId IN:setQuesIds];
        setQuesSub = [Select questionId from QuestionSubscription where SubscriberId =:userinfo.getuserid() and questionId IN:setQuesIds];
        setQuesSubIDs= new Set<id>();
        for(QuestionSubscription obj:setQuesSub )
        {
            setQuesSubIDs.add(obj.questionId);
        }
        List<question_like__c> setQuesLike=[Select Id,questionId__c from question_like__c where createdById=:userinfo.getUserId()];
        setQuesLikeIDs= new Set<id>();
        for(question_like__c obj:setQuesLike )
        {
            setQuesLikeIDs.add(obj.questionId__c);
        }
           
        noOfQues=lstQue1.size();
        
    }
    
    public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
        Network.getNetworkId(), userId).largePhotoUrl;
    }
    public void likeQues()
    {
        Question_Like__c objQuesLike=new Question_Like__c();
        objQuesLike.QuestionID__c=strQuesId;
        try 
        {
            insert objQuesLike;
        }
        catch (DMLException e) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in liking question'));
        } 
    }
    
    public void showMore()
    {
       index+=5; 
    }
    
    public void followQues()
    {
        Boolean checkQuesId=false;
        objCom= [Select id,name From Community where name='NXP Community'];
        QuestionSubscription objQuesSub=new QuestionSubscription();
        for(Id objSubId: setQuesSubIDs)
        {
            if(objSubId==strQuesId)
            {
               checkQuesId=true;
            }
        }
        if(checkQuesId==false)
        {
            objQuesSub.QuestionId= strQuesId;
            objQuesSub.SubscriberId=userinfo.getuserid();
            try 
            {
                insert objQuesSub;
            }
            catch (DMLException e) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in following question'));
            } 
        }
        else
        {
            objQuesSub = [Select questionId from QuestionSubscription where SubscriberId =:userinfo.getuserid() and questionId=:strQuesId];
            
            try 
            {
                delete objQuesSub;
            }
            catch (DMLException e) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in unfollowing question'));
            } 
        }
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        
    }

    public void checkAll()
    {
        isQuesList=true;
        isFaqList=true;
        String strTitle= '%'+strQues+'%';
        lstSearchQues=new List<question>();
        if(strQues==null || strQues=='' || strQues.length()==0)
        {
            lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,NumReplies,creatorName,NumSubscriptions,createdby.id from question where communityId=:objCom.id and id In:setQuesIds order by createddate DESC LIMIT 100];
        }
        else
        {
            lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,NumReplies,creatorName,NumSubscriptions,createdby.id from question where title like: strTitle and communityId=:objCom.id and id In:setQuesIds order by createddate DESC LIMIT 100];
        }
        for(Question objQue: lstQue)
        {
            lstSearchQues.add(objQue);
            
        }  
        lstSearchFaq=new List<knowledgeArticleVersion>();
        if(strQues==null || strQues=='')
        {
            lstFaq= [Select id,title from KnowledgeArticleVersion where (publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC LIMIT 200];
        }
        else
        {
            lstFaq= [Select id,title from KnowledgeArticleVersion where (title like: strTitle and publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC ];

        }
        lstofFaqIds=new List<Id>();
        for(KnowledgeArticleVersion objfaqId: lstFaq)
        {
            lstofFaqIds.add(objfaqId.id);
        }
        lstFaqSel= [Select id,parentid,datacategoryname from Faq__datacategorySelection where parentId IN:lstofFaqIds];
        for(knowledgeArticleVersion objFaq: lstFaq)
        {
            for(Faq__datacategorySelection objFaqSel: lstFaqSel)
            {
                if(objFaq.id==objFaqSel.parentId && objFaqSel.datacategoryname.equalsIgnoreCase(filterCategory))
                {
                    lstSearchFaq.add(objFaq);
                }                
            }
        }        
    }
    
    public void checkQues()
    {
        isQuesList=true;
        isFaqList=false;
        String strTitle= '%'+strQues+'%';
        lstSearchQues=new List<question>();
        if(strQues==null || strQues=='' || strQues.length()==0)
        {
            lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,NumReplies,creatorName,NumSubscriptions,createdby.id from question where communityId=:objCom.id and id In:setQuesIds order by createddate DESC LIMIT 100];
        }
        else
        {
            lstQue= [Select id,title,body,Number_of_Question_Likes__c,createdDate,NumReplies,creatorName,NumSubscriptions,createdby.id from question where title like: strTitle and communityId=:objCom.id and id In:setQuesIds order by createddate DESC LIMIT 100];
        }
        for(Question objQue: lstQue)
        {
            lstSearchQues.add(objQue);
            
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
            lstFaq= [Select id,title from KnowledgeArticleVersion where (publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC];
        }
        else
        {
            lstFaq= [Select id,title from KnowledgeArticleVersion where (title like: strTitle and publishstatus='online' and language='en_US' and isvisibleinpkb=true) order by createddate DESC];

        }
        lstofFaqIds=new List<Id>();
        for(KnowledgeArticleVersion objfaqId: lstFaq)
        {
            lstofFaqIds.add(objfaqId.id);
        }
        lstFaqSel= [Select id,parentid,datacategoryname from Faq__datacategorySelection where parentId IN:lstofFaqIds];
        for(knowledgeArticleVersion objFaq: lstFaq)
        {
            for(Faq__datacategorySelection objFaqSel: lstFaqSel)
            {
                if(objFaq.id==objFaqSel.parentId && objFaqSel.datacategoryname.equalsIgnoreCase(filterCategory))
                {
                    lstSearchFaq.add(objFaq);
                }                
            }
        } 
    }
    public PageReference fetchQuestions1() 
    {   
        offsetSize=0;
        fetchQuestions();
        likesFlag =false;
        filterFlag =true;
        repliesFlag =false;
        lastPostFlag =false;
        
        if(totalPages > 0)
        {
            pageNum=1;
        }
        else
        {
            pageNum=0;   
        }
        return null;
    }
    
     public PageReference sortOnReplies1() 
     {
        offsetSize=0;
        pageNum=1;
        sortOnReplies();
        return null;
    }

    
     public PageReference sortOnReplies() 
     {
        repliesFlag =true;
        likesFlag =false;
        lastPostFlag =false;
        filterFlag =false;
        questionFilterDate='replies';
        fetchQuestions();
        return null;
    }
    
    public PageReference sortOnLikes1() 
    {
        offsetSize=0;
        pageNum=1;
        sortOnLikes();
        return null;
    }
    
    public PageReference sortOnLikes()
    {
        questionFilterDate='Likes';
        likesFlag =true;
        filterFlag =false;
        repliesFlag =false;
        lastPostFlag =false;
        fetchQuestions();
        return null;
    }
    public PageReference sortOnLastPost1() 
    {
        offsetSize=0;
        pageNum=1;
        sortOnLastPost();
        return null;
    }
    
    public PageReference sortOnLastPost() 
    {
        questionFilterDate='Date Posted';
        lastPostFlag =true;
        likesFlag =false;
        filterFlag =false;
        repliesFlag =false;
        fetchQuestions();
        return null;
    }
    
    //method to fetch questions based on listview selected
    public void fetchQuestions()
    {
        lstQues = new List<question>();
        lstQues1 = new List<question>();
        Map<Id,question> mapQues;
        if(questionFilterId=='All Questions')
        {
            if(questionFilterDate=='Date Posted')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and  communityId=:objCom.id order by createddate DESC LIMIT :questionLimit]);
                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and communityId=:objCom.id order by createddate ASC limit :LimitSize offset :OffsetSize];
                    ascLast =false;
                    descLast=true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and communityId=:objCom.id order by createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLast =true;
                    descLast=false;
                }
            }
            else if(questionFilterDate=='Recent Activity')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and communityId=:objCom.id order by LastModifiedDate DESC,createddate DESC LIMIT :questionLimit]);

                lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and communityId=:objCom.id order by LastModifiedDate DESC,createddate DESC limit :LimitSize offset :OffsetSize];
            }
            else if(questionFilterDate=='Replies')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and communityId=:objCom.id order by NumReplies DESC,createddate DESC LIMIT :questionLimit]);

                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and communityId=:objCom.id order by NumReplies ASC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascRep =false;
                    descRep =true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and communityId=:objCom.id order by NumReplies DESC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascRep =true;
                    descRep =false;
                }
            }
            else if(questionFilterDate=='Most Popular')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and  communityId=:objCom.id order by upvotes DESC,NumReplies DESC,NumSubscriptions DESC,LastModifiedDate DESC LIMIT :questionLimit]);
                lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and  communityId=:objCom.id order by upvotes DESC,NumReplies DESC,NumSubscriptions DESC,LastModifiedDate DESC limit :LimitSize offset :OffsetSize];
                         
            }
            else if(questionFilterDate=='Likes')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and  communityId=:objCom.id order by upvotes DESC,NumReplies DESC,NumSubscriptions DESC,LastModifiedDate DESC LIMIT :questionLimit]);
                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and  communityId=:objCom.id order by Number_of_Question_Likes__c ASC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLike =false;
                    descLike =true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and  communityId=:objCom.id order by Number_of_Question_Likes__c DESC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLike =true;
                    descLike =false;
                }
            }
            totalRecs=mapQues.size();

        }
        else if(questionFilterId=='Unanswered Questions')
        {
            if(questionFilterDate=='Date Posted')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by createddate DESC LIMIT :questionLimit]);
                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by createddate ASC limit :LimitSize offset :OffsetSize];
                    ascLast =false;
                    descLast=true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLast =false;
                    descLast=true;
                }
            }
            else if(questionFilterDate=='Recent Activity')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by LastModifiedDate DESC,createddate DESC LIMIT :questionLimit]);

                lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by LastModifiedDate DESC,createddate DESC limit :LimitSize offset :OffsetSize];
            }
            else if(questionFilterDate=='Most Popular')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and  communityId=:objCom.id order by upvotes DESC,NumReplies DESC,NumSubscriptions DESC,LastModifiedDate DESC LIMIT :questionLimit]);
                lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and  communityId=:objCom.id order by upvotes DESC,NumReplies DESC,NumSubscriptions DESC,LastModifiedDate DESC limit :LimitSize offset :OffsetSize];
              
            }
            else if(questionFilterDate=='Likes')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by Number_of_Question_Likes__c DESC,createddate DESC LIMIT :questionLimit]);
                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by Number_of_Question_Likes__c ASC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLike =false;
                    descLike =true;
               }
               else
               {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by Number_of_Question_Likes__c DESC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLike =true;
                    descLike =false;
              }
            }
            else if(questionFilterDate=='Replies')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by NumReplies DESC,createddate DESC LIMIT :questionLimit]);

                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by NumReplies ASC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascRep =false;
                    descRep =true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and NumReplies=0 and communityId=:objCom.id order by NumReplies DESC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascRep =true;
                    descRep =false;
                }
            }
            totalRecs=mapQues.size();
        }
        else if(questionFilterId=='Unsolved Questions')
        {
            if(questionFilterDate=='Date Posted')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and communityId=:objCom.id order by createddate DESC LIMIT :questionLimit]);
                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and communityId=:objCom.id order by createddate ASC limit :LimitSize offset :OffsetSize];
                    ascLast =false;
                    descLast=true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and communityId=:objCom.id order by createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLast =true;
                    descLast=false;
                }
            }
            else if(questionFilterDate=='Recent Activity')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,BestReplyId,LastModifiedDate,createdby.id,NumSubscriptions from question where Id IN: setQuesIds and BestReplyId=null and  communityId=:objCom.id order by LastModifiedDate DESC LIMIT :questionLimit]);

                lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,BestReplyId,LastModifiedDate,createdby.id,NumSubscriptions from question where Id IN: setQuesIds and BestReplyId=null and  communityId=:objCom.id order by LastModifiedDate DESC limit :LimitSize offset :OffsetSize];
            }
            else if(questionFilterDate=='Replies')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and communityId=:objCom.id order by NumReplies DESC,createddate DESC LIMIT :questionLimit]);

                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and communityId=:objCom.id order by NumReplies ASC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascRep =false;
                    descRep =true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and communityId=:objCom.id order by NumReplies DESC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascRep =true;
                    descRep =false;
                }
            }
            else if(questionFilterDate=='Most Popular')
            {
                 mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,BestReplyId,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and  communityId=:objCom.id order by upvotes DESC,NumReplies DESC,NumSubscriptions DESC,LastModifiedDate DESC LIMIT :questionLimit]);
            
                 lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,BestReplyId,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and  communityId=:objCom.id order by upvotes DESC,NumReplies DESC,NumSubscriptions DESC,LastModifiedDate DESC limit :LimitSize offset :OffsetSize];

            }
            else if(questionFilterDate=='Likes')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and communityId=:objCom.id order by Number_of_Question_Likes__c DESC,createddate DESC  LIMIT :questionLimit]);
                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and communityId=:objCom.id order by Number_of_Question_Likes__c ASC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLike =false;
                    descLike =true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId=null and communityId=:objCom.id order by Number_of_Question_Likes__c DESC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLike =true;
                    descLike =false;
                }
            }
            
            totalRecs=mapQues.size();
        }
        else if(questionFilterId=='Solved Questions')
        {
            if(questionFilterDate=='Date Posted')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and communityId=:objCom.id order by createddate DESC LIMIT :questionLimit]);
                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and communityId=:objCom.id order by createddate ASC limit :LimitSize offset :OffsetSize];
                    ascLast =false;
                    descLast=true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and communityId=:objCom.id order by createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLast =true;
                    descLast=false;
                }
            }
            else if(questionFilterDate=='Recent Activity')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,BestReplyId,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and  communityId=:objCom.id order by LastModifiedDate DESC LIMIT :questionLimit]);
                lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,BestReplyId,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and  communityId=:objCom.id order by LastModifiedDate DESC limit :LimitSize offset :OffsetSize];
            }
            else if(questionFilterDate=='Most Popular')
            {
                 mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,BestReplyId,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and  communityId=:objCom.id order by upvotes DESC,NumReplies DESC,NumSubscriptions DESC,LastModifiedDate DESC LIMIT :questionLimit]);
           
                 lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,BestReplyId,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and  communityId=:objCom.id order by upvotes DESC,NumReplies DESC,NumSubscriptions DESC,LastModifiedDate DESC limit :LimitSize offset :OffsetSize];

            }
            
            else if(questionFilterDate=='Replies')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and communityId=:objCom.id order by NumReplies DESC,createddate DESC LIMIT :questionLimit]);

                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and communityId=:objCom.id order by NumReplies ASC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascRep =false;
                    descRep =true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and communityId=:objCom.id order by NumReplies DESC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascRep =true;
                    descRep =false;
                }
            }
            else if(questionFilterDate=='Likes')
            {
                mapQues= new Map<Id,question>([Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and communityId=:objCom.id order by Number_of_Question_Likes__c DESC,createddate DESC LIMIT :questionLimit]);
                if(sortOrder=='asc')
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and communityId=:objCom.id order by Number_of_Question_Likes__c ASC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLike =false;
                    descLike =true;
                }
                else
                {
                    lstQues=[Select id,title,body,Number_of_Question_Likes__c,createdDate,createdby.Fullphotourl,NumReplies,creatorName,NumSubscriptions,createdby.id from question where Id IN: setQuesIds and BestReplyId!=null and communityId=:objCom.id order by Number_of_Question_Likes__c DESC,createddate DESC limit :LimitSize offset :OffsetSize];
                    ascLike =true;
                    descLike =false;
                }
            }
            totalRecs=mapQues.size();
        }
        totalPages= (Integer)totalRecs/LimitSize;
        if(totalRecs < limitsize && totalRecs > 0)
        {
            totalpages = 1;
        }
        if(Math.mod(totalRecs,LimitSize)!=0 && totalRecs>limitSize)
        {
            totalPages=totalPages+1;
        }  
    }
    
    //method to get question listview selected
    public List<SelectOption> getQuestionView() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All Questions', 'All Questions'));
        options.add(new SelectOption('Unanswered Questions', 'Unanswered Questions'));
        options.add(new SelectOption('Unsolved Questions', 'Unsolved Questions'));
        options.add(new SelectOption('Solved Questions', 'Solved Questions'));
        return options;
    }
    
    //method to get question listview selected
    public List<SelectOption> getQuestionViewByDate() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Date Posted', 'Date Posted'));
        options.add(new SelectOption('Recent Activity', 'Recent Activity'));
        options.add(new SelectOption('Most Popular', 'Most Popular'));
        return options;
    }
    
    public PageReference deleteQuestion()
    {
        PageReference pageRef;
        List<Question> objQues=[Select id,title,body,createdBy.id,Product_Category__c,Product_Sub_Category__c from Question where id=: strQuesId LIMIT 1];
        if(objQues!=null || objQues.size()!=0)
        {
            try
            {
                delete objQues[0];
                pageRef=new PageReference('/CommunityForumQuestionGrid?category='+objQues[0].Product_Category__c);
                
            }
            catch (DMLException e) 
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error is Deleting Question'));
                return null;
            }
           
        }
         pageref.setRedirect(true);
         return pageref;
    }
    
   public String getDescribeDataCategoryGroupStructureResults()
   {
      List<DescribeDataCategoryGroupResult> describeCategoryResult;
      List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
      List<String> lstCategory=new List<String>();
      List<String> lstSubCategory=new List<String>();
      String strDataCategory;
      try 
      {
         List<String> objType = new List<String>();
         objType.add('Question');
         describeCategoryResult = Schema.describeDataCategoryGroups(objType);
         List<DataCategoryGroupSobjectTypePair> pairs =new List<DataCategoryGroupSobjectTypePair>();
         for(DescribeDataCategoryGroupResult singleResult :describeCategoryResult)
         {
            DataCategoryGroupSobjectTypePair p =new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            pairs.add(p);
         }
         //describeDataCategoryGroupStructures()
         describeCategoryStructureResult =Schema.describeDataCategoryGroupStructures(pairs, false);
         //Getting data from the result
         for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult)
         {
             DataCategory [] toplevelCategories =singleResult.getTopCategories();
             
                //Category- All
                for(DataCategory topcategory: toplevelCategories)
                {
                    //Category- Automotive,I2C,Microcontroller etc
                    for(DataCategory category : topcategory.getChildCategories()) 
                    {
                        if(strUrl.equalsIgnoreCase(category.getLabel()))
                        {
                            strDataCategory= category.getName();
                            break;
                        }
                        else
                        {
                            //Sub Category under above categories
                            for(DataCategory subCategory: category.getChildCategories())
                            {
                                
                                if(subCategory.getLabel().Contains('Transistors'))
                                {
                                    if(strUrl.equalsIgnoreCase('Transistors') && category.getLabel().equalsIgnoreCase('RF small signal'))
                                    {
                                        strDataCategory= subCategory.getName();
                                        break;
                                    }
                                }
                                else if(subCategory.getLabel().equalsIgnoreCase('Diodes'))
                                {
                                    if(strUrl.equalsIgnoreCase('RF Diodes') && category.getLabel().equalsIgnoreCase('RF small signal'))
                                    {
                                        strDataCategory= subCategory.getName();
                                        break;
                                    }
                                    else if(strUrl.equalsIgnoreCase('Diodes') && category.getLabel().equalsIgnoreCase('Standard Products'))
                                    {
                                        strDataCategory= subCategory.getName();
                                        break;
                                    }
                                } 
                                else if(subCategory.getLabel().contains(strUrl))
                                {
                                    strDataCategory= subCategory.getName();
                                    break;
                                }
                            }
                        }       
                    }
                }
            }
      } 
      catch (Exception e){}
      return strDataCategory;
    }
    
     
      public void FirstPage()
      {
          fetchQuestions();   
          OffsetSize = 0;
          if(totalpages > 0)
          {
              pageNum=1;
          }
          else
          {
              pageNum=0;
          }    
          if(repliesFlag == true)
          {
              sortOnReplies();
          }
          else if(filterFlag ==true)
          {
              fetchQuestions();
          }
          else if(likesFlag ==true)
          {
              sortOnLikes();
          }
          else if(lastPostFlag ==true)
          {
              sortOnLastPost();
          }
      }
    
    public void previous()
    {  
        if(pageNum>1)
        {
            pageNum=pageNum-1;
        }
        if(offsetSize >= limitsize)
        {
            OffsetSize = OffsetSize - LimitSize;
        }
        if(repliesFlag == true)
        {
            sortOnReplies();
        }
        else if(filterFlag ==true)
        {
            fetchQuestions();
        }
        else if(likesFlag ==true)
        {
            sortOnLikes();
        }
        else if(lastPostFlag ==true)
        {
            sortOnLastPost();
        }
    }
    
    public void next()
    {
        fetchQuestions();
        
        if(pageNum<totalPages)
        {
            pageNum=pageNum+1;
        }
        if(OffsetSize < totalRecs - limitsize)
        {
            OffsetSize = OffsetSize + LimitSize;
        }    
        if(repliesFlag == true)
        {
            sortOnReplies();
        }
        else if(filterFlag ==true)
        {
            fetchQuestions();
        }
        else if(likesFlag ==true)
        {
            sortOnLikes();
        }
        else if(lastPostFlag ==true)
        {
            sortOnLastPost();
        }
    }   
    
    public void LastPage()
    {   
        fetchQuestions();
        pageNum=totalPages;
        if(Totalrecs >= limitSize)
        {
            if((math.mod(totalRecs,LimitSize))==0)
            {
                OffsetSize = totalRecs - LimitSize - math.mod(totalRecs,LimitSize);
            }
            else
            {
                OffsetSize = totalRecs - math.mod(totalRecs,LimitSize);
            }
        }           
        if(repliesFlag == true)
        {
            sortOnReplies();
        }
        else if(filterFlag ==true)
        {
            fetchQuestions();
        }
        else if(likesFlag ==true)
        {
            sortOnLikes();
        }
        else if(lastPostFlag ==true)
        {
            sortOnLastPost();          
        }
        
    }    
    
    public boolean getprev()
    {
        if(OffsetSize == 0)
        {              
            return true;
        }
        else
        {
            return false;
        }
    }
    
}