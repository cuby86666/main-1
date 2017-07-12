/*********************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     17 April 2015
Description :      Class for NXP community users to post and view stories
****************************************************************************************************/

/******************************************************************************************************
@Modified By :      Amrutha R
@Modified Date :    02 Aug 2015
Description :       New UI
*********************************************************************************************************/

/******************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date :    31 Aug 2015
Description :       Pagination Methods
*********************************************************************************************************/

public class CommunitiesSuccessStoriesController 
{

    public integer pageNum{get;set;}
    public  integer totalPages{get;set;}
    public List<IdeaComment> lstComments;
    public List<idea> lstIdeas{get;set;}
    public List<idea> lstIdeas1{get;set;}
    public idea objIdeaComments{get;set;}
    public String strIdeaTitle{get;set;}
    public String strIdeaBody{get;set;}
    public List<String> strCategories{get;set;}
    public String strCommentBody{get;set;}
    public List<SelectOption> lstOptions;
    public String CommunitiesStoryZoneId{get;set;}
    public Boolean isCommentPosted{get;set;}
    public String strIdeaId{get;set;}
    public string categoryFilterId{get;set;}
    public string sortFilterId{get;set;}
    public integer noOfStories{get;set;}
    public integer index{get;set;}
    
    private integer totalRecs;
    private integer OffsetSize = 0;
    private integer LimitSize = 5;
    public Id userId { get; set; }
   
   
    //Controller to fetch ideaList
    public CommunitiesSuccessStoriesController() 
    {
        index=5;
        categoryFilterId='All';
        sortFilterId='Recent';
        Community objCom=[Select id,name from Community where name='Success Stories'];
        CommunitiesStoryZoneId=objCom.id;
        
        lstIdeas= new list<idea>();
        lstIdeas= getstories1();
       // noOfStories=lstIdeas.size();
        if(ApexPages.currentPage().getParameters().get('id')!=null)
        {
            objIdeaComments= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById,createdby.Fullphotourl ,lastmodifiedDate FROM Idea where id=:ApexPages.currentPage().getParameters().get('id') ORDER BY CreatedDate desc];
        }
        pageNum=1;
            
    }
    
    public list<idea> getstories1()
    {
    lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById,createdby.Fullphotourl ,attachmentbody,lastmodifiedDate FROM Idea where communityId=:CommunitiesStoryZoneId order by CreatedDate desc limit :LimitSize   ];
    system.debug('++++++++++++++'+lstIdeas);
    lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,attachmentbody,lastmodifiedDate FROM Idea where communityId=:CommunitiesStoryZoneId order by CreatedDate desc  ];
    noOfStories=lstIdeas1.size();
        if(lstIdeas1.size() == 0)
        {
        totalpages = 0;
        }
        else
        { 
      
        totalpages=(integer)(lstIdeas1.size()/LimitSize);
        }
        
        if(noOfStories < limitsize && noOfStories > 0)
        {
            totalpages =1;
        }
        if(math.mod(noOfStories,LimitSize)!=0 && noOfStories > limitsize )
        {
        totalPages=totalPages+1;
        }
    
    Return lstideas;
    }

//method to show more stories increment of 5
   /* public void showMore()
    {
       index+=5;
        
    }*/
     public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    //method to get comments
    public List<IdeaComment> getlstComments() 
    {
        return [Select id,ideaId,CommentBody,CreatedById,createdby.Fullphotourl, CreatedDate,creatorName  From IdeaComment where ideaId=:ApexPages.currentPage().getParameters().get('id') order by createddate desc];
    }
    
    //method to get categories
    public List<SelectOption> getCategories() 
    {
        lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('Automotive', 'Automotive'));
        lstOptions.add(new SelectOption('RF', 'RF'));
        lstOptions.add(new SelectOption('Microcontroller', 'Microcontroller'));
        lstOptions.add(new SelectOption('Logic', 'Logic'));       
        lstOptions.add(new SelectOption('I2C', 'I2C'));
        lstOptions.add(new SelectOption('Identification and Security', 'Identification and Security'));
        lstOptions.add(new SelectOption('Interface Products', 'Interface Products'));
        lstOptions.add(new SelectOption('Standard Products', 'Standard Products'));
        lstOptions.add(new SelectOption('Other Products', 'Other Products'));
        return lstOptions;
    }
    
     public PageReference fetchStories1() 
     {
     offsetSize=0;
     fetchStories();
     
     if(Totalpages > 0)
    {
    pageNum=1;
    }
    else
    {
    pageNum=0;
    }
        return null;
    }


    //method to fetch stories based on listview
    public void fetchStories()
    {
        system.debug('++fetch '+categoryFilterId);
        
        if(categoryFilterId == 'All')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId order by CreatedDate desc limit:limitSize offset:offsetSize];
             lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId order by CreatedDate desc ]; 
         
        }
        else if (categoryFilterId != 'All')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId ) order by CreatedDate desc limit:limitSize offset:offsetSize];
             lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId ) order by CreatedDate desc ];
      
        }
        if(categoryFilterId == 'All' && sortFilterId=='Recent')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId order by CreatedDate desc limit:limitSize offset:offsetSize];
             lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId order by CreatedDate desc ];
        }
        else if (categoryFilterId != 'All'  && sortFilterId=='Recent')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId ) order by CreatedDate desc limit:limitSize offset:offsetSize];
             lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId ) order by CreatedDate desc ];
       
        }
        
        else if(categoryFilterId == 'All' && sortFilterId=='Popular')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId order by CreatedDate desc limit:limitSize offset:offsetSize];
             lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId order by CreatedDate desc ];     
         
        }
               
        else if (categoryFilterId != 'All' && sortFilterId=='Popular')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId) order by CreatedDate desc limit:limitSize offset:offsetSize];
            lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId) order by CreatedDate desc ]; 
      
        }
        else if(categoryFilterId == 'All' && sortFilterId=='Top')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId order by votetotal desc limit:limitSize offset:offsetSize ];
             
             lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId order by votetotal desc ];
        }
        else if (categoryFilterId != 'All' && sortFilterId=='Top')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId) order by votetotal desc limit:limitSize offset:offsetSize ];
             lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId) order by votetotal desc ];
       
        }
        else if(categoryFilterId == 'All' && sortFilterId=='Comment')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and numcomments>0 order by CreatedDate desc limit:limitSize offset:offsetSize ];
            lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and numcomments>0 order by CreatedDate desc  ];
         
        }
        else if (categoryFilterId != 'All' && sortFilterId=='Comment')
        {
             lstIdeas= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,createdby.Fullphotourl,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId) and numcomments>0 order by CreatedDate desc limit:limitSize offset:offsetSize ];
             lstIdeas1= [SELECT Id, Title,body, categories,votetotal,creatorName,createdDate,numcomments,CreatedById ,lastmodifiedDate  FROM Idea where communityId=:CommunitiesStoryZoneId and categories includes (:categoryFilterId) and numcomments>0 order by CreatedDate desc  ];
      
        }
         totalRecs=lstIdeas1.size();
         if(lstIdeas1.size() == 0)
        {
        totalpages = 0;
        }
        else
        { 
      
        totalpages=(integer)(lstIdeas1.size()/LimitSize);
        }
        
        if(totalRecs < limitsize && totalrecs > 0)
        {
            totalpages =1;
        }
        if(math.mod(lstIdeas1.size(),LimitSize)!=0 && lstIdeas1.size() > LimitSize )
        {
        totalPages=totalPages+1;
        }
    }
     
    public List<SelectOption> getStories() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All Categories'));
        options.add(new SelectOption('Automotive', 'Automotive'));
        options.add(new SelectOption('RF', 'RF'));
        options.add(new SelectOption('Microcontroller', 'Microcontroller'));
        options.add(new SelectOption('Logic', 'Logic'));
        options.add(new SelectOption('I2C', 'I2C'));
        options.add(new SelectOption('Identification and Security', 'Identification and Security'));
        options.add(new SelectOption('Interface Products', 'Interface Products'));
        options.add(new SelectOption('Standard Products', 'Standard Products'));
        options.add(new SelectOption('Other Products', 'Other Products'));
        return options;
    }
    
    public List<SelectOption> getSortStories() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Recent', 'Recent'));
        options.add(new SelectOption('Popular', 'Popular'));
        options.add(new SelectOption('Top', 'Top'));
        options.add(new SelectOption('Comment', 'Comment'));
        return options;
    }
    
    public void promoteStory()
    {
          
         List<Vote> lstVoteId=[Select id,parentId,createdby.Fullphotourl,createdById from Vote where parentId=:strIdeaId and createdById=:userinfo.getuserid()];
         if(lstVoteId.size()==0 || lstVoteId[0].id==null)
         {
             Vote objVote=new Vote();
             objVote.parentId=strIdeaId;
             objVote.type='Up';
             insert objVote;
             
         }

    }
    
    public void demoteStory()
    {
        List<Vote> lstVoteId=[Select id,parentId,createdby.Fullphotourl,createdById from Vote where parentId=:strIdeaId and createdById=:userinfo.getuserid()];
        
        if(lstVoteId.size()==0 || lstVoteId[0].id==null)
         {
             
         }
        else
        {
            delete lstVoteId[0];
        }
    }
    
    
    
    //method to save post
    public PageReference savePost()
    { 
         Community objCom=[Select id,name from Community where name='Success Stories'];
        CommunitiesStoryZoneId=objCom.id;
        if(strIdeaTitle=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter title for your story'));
            return null;
        }
        if(strCategories.size()==0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Category'));
            return null;
        }
        if(strIdeaBody=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Description for your story'));
            return null;
        }
       else
       {
            Idea objIdea= new Idea();
            objIdea.Title= strIdeaTitle;
            objIdea.Body= strIdeaBody;
            objIdea.CommunityId= CommunitiesStoryZoneId;
            String strCategory= '';
            Boolean Start = true;
            if(!strCategories.isEmpty()) 
            {           
            for(String Str : strCategories) 
            {
                if(Start) 
                {
                    strCategory= Str;
                    Start = false;
                } 
                else 
                {               
                    strCategory= strCategory + ';' + Str;
                }
            }
           }
        objIdea.Categories = strCategory;
        try 
        {
            insert objIdea;
        }
        catch (DMLException e) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in posting story'));
            return null;
        } 
        
        PageReference page= new PageReference('/community/CommunityStories');
        page.setRedirect(true);
        return page;
       }
        
    }
    
    
    //method to add comment to a story
    public void addComment()
    {
       if(strCommentBody == null|| strCommentBody == '')
       {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please write a comment'));
       }
       else
       {
            IdeaComment objComment= new IdeaComment(IdeaId= objIdeaComments.id,CommentBody= strCommentBody);
            insert objComment;
            strCommentBody=null;
            isCommentPosted=true;
       }
    }
 /** Pagination DS **/ 
    public void FirstPage()
      {
       fetchStories();
       OffsetSize = 0;
        if(Totalpages > 0)
          {
          pageNum=1;
          }
          else
          {
          PageNum=0;
          }
          fetchStories();
          
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
          
           fetchStories();
          
          
  
      }
      public void next()
      { 
       fetchStories(); 
          if(pageNum<totalPages)
          {
              pageNum=pageNum+1;
          }
       if(OffsetSize < totalRecs - limitsize)
         {
             OffsetSize = OffsetSize + LimitSize;
         }   
        
        fetchStories();  
      }   
      public void LastPage()
      {   
        
         fetchStories();
         pageNum=totalPages;
         if(totalRecs >= limitsize)
          {  
         if(math.mod(totalRecs,LimitSize)==0)
         { 
         OffsetSize = totalRecs - LimitSize-math.mod(totalRecs,LimitSize);
         }
         else
         {
           
          OffsetSize = totalRecs - math.mod(totalRecs,LimitSize);
         }
         }
         fetchStories();
          
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
   /** Pagination DS **/  
  
}