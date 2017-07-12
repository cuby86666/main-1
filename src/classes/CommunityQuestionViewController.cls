/***************************************************************************************************************************************************************************************************************************************************** 
@Created By :       Avichal Kumar
@Created Date:      30th July 2015
@Description:       controller class for communityquestionview page
******************************************************************************************************************************************************************************************************************************************************/
/***************************************************************************************************************************************************************************************************************************************************** 
@Modified By :      Avichal Kumar 
@Modified Date:     18th Sept 2015
@Description:       added reply visibilty 
******************************************************************************************************************************************************************************************************************************************************/
/***************************************************************************************************************************************************************************************************************************************************** 
@Modified By :      Amrutha R
@Modified Date:     21 Sept 2015
@Description:       send notification features
******************************************************************************************************************************************************************************************************************************************************/
/***************************************************************************************************
@Modified By :      Amrutha R
@Modified Date:     23 Nov 2015
@Description:       Fixed Question Attachmnet issue
*******************************************************************************************************/


public class CommunityQuestionViewController
{

    public String strAnsVisibility { get; set; }
    public boolean AnsVisibility { get; set; }
    public list<Question> lstQuestion{get; Set;}
    Public list<Reply> lstReply{get; Set;}
    public boolean visibility{get;set;}
    public boolean visibility1{get;set;}
    public boolean isAttach{get;set;}
    public string question1{get;set;}
    public string shortQuestion{get;set;}
    public integer flag{get;set;}
    public boolean readMoreVisibility{get;set;}
    public boolean readLessVisibility{get;set;}
    public String strAnsBody{get;set;}
    public String strQuesId{get;set;}
    public String strAnsId{get;set;}
    public List<QuestionSubscription> setQuesSub{get;set;}
    public integer replyIndex{get;set;}
    public Set<id> setQuesSubIDs{get;set;}
    public Set<id> setQuesLikeIDs{get;set;}
    public Attachment objAttachment{get;set;}
    public Set<id> setAnsLikeIDs{get;set;}
    public String strUserName{get;set;}
    public Id userId { get; set; }
    public List<PermissionSetAssignment> lstPermSet{get;set;}
    public Set<Id> setModeratorIds {get;set;}
     public List<SelectOption> lstOptions;
    public boolean isInternal{get;set;}
    public List<Case> lstCase{get;set;}
    public List<Question_Attachment__c > lstQuestionAttachment{get;set;}
    public Question_Attachment__c objQuestionAttachment{get;set;}
    
    public CommunityQuestionViewController() 
    {
        isAttach=false;
        strAnsVisibility='Public';
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
        flag=0;
        replyIndex=1;
        readMoreVisibility=true;
        lstQuestion = new list<question>();
        
        lstQuestion = [Select body,Title,origin,id,createdby.Name,createdby.Fullphotourl,Product_category__c,product_sub_category__c,createdby.id,Best_Reply_Id__c,Best_Reply_Selected_By_Id__c,createdDate,Numreplies,Number_of_Question_Likes__c,NumSubscriptions 
                                          From Question 
                                         WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
                                         
        // Code Added by Avichal Kumar 
                                        
        List<Attachment> lstAttachment= new List<Attachment>();
        lstQuestionAttachment= new List<Question_Attachment__c >();
        objQuestionAttachment= new Question_Attachment__c();
        lstQuestionAttachment=[select Question_Attachment__c from Question_Attachment__c where Question_Attachment__c =:ApexPages.currentPage().getParameters().get('id')];
        if(lstQuestionAttachment.size()!=0) 
        {
            lstAttachment=[select id from Attachment where parentId=:lstQuestionAttachment[0].id ];
            if(lstAttachment.size()!=0) 
        	{
                objAttachment=lstAttachment[0];
            	isAttach=true;
        	}
        }
        // Code Added by Avichal Kumar Ends
                             
        lstCase= [Select id, question.id,CaseNumber from case where question.id= :ApexPages.currentPage().getParameters().get('id')];                                 
        if(lstQuestion[0].product_sub_category__c=='Select Sub Category')
        {
        lstQuestion[0].product_sub_category__c=lstQuestion[0].Product_category__c;
        }                                         
        if(lstQuestion[0].Best_Reply_Selected_By_Id__c!=null)
        {
            strUserName= [Select Name from User where id=:lstQuestion[0].Best_Reply_Selected_By_Id__c].name;
        }
        
      
        lstReply = new list<Reply>();
        lstReply = [Select body,id,createdby.Name,createdby.fullphotourl,createdDate,Number_of_Answer_Likes__c,createdBy.id,visibility__c
                                          From Reply 
                                         WHERE QuestionId = :ApexPages.currentPage().getParameters().get('id') order by createddate DESC];  
                                         
        if(lstQuestion[0].body==null)
        { 
            readMoreVisibility=false;
            readLessVisibility=false; 
        }                                     
        if(lstQuestion[0].body!=null)
        {
            question1= lstQuestion[0].body;
        if(Question1.length()>100)
        {
         
            shortQuestion=question1.substring(0, 100);
            lstQuestion[0].body=shortQuestion;
            readMoreVisibility=true;
            readLessVisibility=false;
        }  
       else
       {
           readMoreVisibility=false;
           readLessVisibility=false; 
       } 
        }
                                      
       visibility=true;
       if(lstReply.size()> 1)
       {
           visibility1 = true;
       }
       
       else 
       {
           visibility1 = false;
       }   
             
        
                                                                        
       setQuesSub = [Select questionId from QuestionSubscription where SubscriberId =:userinfo.getuserid() and questionId=:lstQuestion[0].id];
       setQuesSubIDs= new Set<id>();
       for(QuestionSubscription obj:setQuesSub )
       {
           setQuesSubIDs.add(obj.questionId);
       }
       List<question_like__c> setQuesLike=[Select Id,questionId__c from question_like__c where createdById=:userinfo.getUserId() and questionId__c=:lstQuestion[0].id];
       setQuesLikeIDs= new Set<id>();
       for(question_like__c obj:setQuesLike )
       {
           setQuesLikeIDs.add(obj.questionId__c);
       }
       List<Answer_like__c> setAnsLike=[Select Id,replyId__c from answer_like__c where createdById=:userinfo.getUserId() ];
       setAnsLikeIDs= new Set<id>();
       for(answer_like__c obj:setAnsLike )
       {
           setAnsLikeIDs.add(obj.replyId__c);
       }
        
        
    }
    
    public List<SelectOption> getvisibilityoption()
    {        
        lstOptions = new List<SelectOption>();
        lstOptions.add(new SelectOption('Select option','Select option'));
        lstOptions.add(new SelectOption('Public','Public'));       
        lstOptions.add(new SelectOption('Internal','Internal'));
        
        return lstOptions;
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
    
    public PageReference deleteAnswer()
    {
        PageReference pageRef;
        List<Reply> objReps= [Select id,Body,questionId,question.title from reply where id=:strAnsId];
        if(objReps.size()!=0 || objReps!=null)
        {
            objReps[0].body= strAnsBody;
            delete objReps[0];
            try{
                pageRef=new PageReference('/CommunityQuestionView?id='+objReps[0].questionId);
                
            }
        
         catch (DMLException e) 
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in updating reply'));
              return null;
          } 
        }
        pageref.setRedirect(true);
        return pageref;
    }
    
    public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    //method to redirect page to catagory
    
    public PageReference categorySelected()
    {
         string strCategory=lstQuestion[0].product_sub_category__c;
                if(lstQuestion[0].product_sub_category__c=='general')
                {
                      if(lstQuestion[0].Product_category__c=='Automotive')
                              strCategory='Automotive General';
                      
                      if(lstQuestion[0].Product_category__c=='Interface Products')
                              
                              strCategory='Interface General';
                      
                      if(lstQuestion[0].Product_category__c=='Logic')
                              
                              strCategory='Logic General';
                      
                      if(lstQuestion[0].Product_category__c=='Other Products')
                              
                              strCategory='Other General';
                 
                 }
                 
                 if((lstQuestion[0].product_sub_category__c=='diodes') && (lstQuestion[0].Product_category__c=='RF'))
                 {
                       
                       strCategory='RF Diodes';
                  
                 }
                                                                                                 
                 PageReference lstQuePage = new PageReference('/community/CommunityForumQuestionList');
                 lstQuePage.getParameters().put('category',strCategory);
                 return lstQuePage.setRedirect(true);    
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
    
    public PageReference likeAns()
    {
        Answer_Like__c objAnsLike=new Answer_Like__c();
        objAnsLike.ReplyId__c=strAnsId;
        try 
        {
            insert objAnsLike;
            PageReference pageRef=new PageReference('/CommunityQuestionView?id='+lstquestion[0].id);
            pageref.setRedirect(true);
            return pageref;
        }
        catch (DMLException e) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in liking answer'));
        } 
        return null;
        
    }
    
    public PageReference bestAnswer()
    {
        lstQuestion[0].best_reply_id__c= strAnsId;
        lstQuestion[0].Best_Reply_Selected_By_Id__c=userinfo.getUserId();
        try 
        {
            update lstQuestion[0];
            PageReference pageRef=new PageReference('/CommunityQuestionView?id='+lstquestion[0].id);
            pageref.setRedirect(true);
            return pageref;
        }
        catch (DMLException e) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in selecting best answer'));
        } 
        return null;
    }
    
    public PageReference followQues()
    {
        Boolean checkQuesId=false;
        Community objCom= [Select id,name From Community where name='NXP Community'];
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
              PageReference pageRef=new PageReference('/CommunityQuestionView?id='+lstquestion[0].id);
            pageref.setRedirect(true);
            return pageref;
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
              PageReference pageRef=new PageReference('/CommunityQuestionView?id='+lstquestion[0].id);
              pageref.setRedirect(true);
              return pageref;
          }
          catch (DMLException e) 
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in unfollowing question'));
          } 
        }
        return null;
    }
    
    public void viewAllAnswers()
    {

        visibility = true;
        visibility1 = False;
         
        replyIndex=lstReply.size();    
    }
    
    public void readMore()
    {
       
        lstQuestion[0].body=question1;
        readMoreVisibility=false;
        readLessVisibility=true;
      
    }
    
    public void readLess()
    {
        lstQuestion[0].body=shortQuestion;
        readMoreVisibility=true;
        readLessVisibility=false; 
    }
    
    public PageReference submitAns()
    {
        Reply objRep=new Reply();
        objRep.Body= strAnsBody;
        objRep.QuestionId= ApexPages.currentPage().getParameters().get('id');
        objRep.visibility__c=strAnsVisibility;
        if(objRep.visibility__c=='Select option' || objRep.visibility__c=='None' || objRep.visibility__c=='')
        {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select visibility'));
             return null;
        }
        
        try{
        insert objRep;
            sendEmailToUsers(objRep.QuestionId);
            PageReference pageRef=new PageReference('/CommunityQuestionView?id='+lstquestion[0].id);
            pageref.setRedirect(true);
            return pageref;
        }
        
         catch (DMLException e) 
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in inserting reply'));
              return null;
          } 
                                  
        strAnsBody='';
        return null;
    }
    
    //Method to send email if reply is posted for a question. 
    //Email is sent to user who posted question and users who follow that question
    public Static void sendEmailToUsers(Id strId)
    {
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        String emailVerficationLink= cs.EmailVerficationLink__c;
        List<String> lstUserEmail= new List<String>();
        List<question> lstUser= [Select Id,CreatedBy.email,title,body from question Where id=: strId LIMIT 1];
        List<questionSubscription> lstUsers= [select id, questionid,Subscriber.email from questionSubscription Where questionid=: strId];
        if(lstUser.size()>0 || lstUsers.size()>0)
        {
            lstUserEmail.add(lstUser[0].CreatedBy.email);
            for(questionSubscription objSub: lstUsers)
            {
                lstUserEmail.add(objSub.Subscriber.email);
            }
            
        } 
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(String strEmail :lstUserEmail) 
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {strEmail};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('NXP Technical Support');
            mail.setSubject( 'NXP Community - Answer Posted' );
            mail.setPlainTextBody('Dear User,\n\n'
                                +userinfo.getName() + ' has answered to a question posted by you or followed by you. \n'
                                +'\nQuestion Title: ' +lstUser[0].Title+ '\n'
                                + lstUser[0].Body
                                +'\n\n'
                                + emailVerficationLink
                                + '/CommunityQuestionView?id='+strId
                                +'\n\nPlease check. Thank you.'
                                +'\n\nBest Regards,\n'
                                +'NXP Community'
                                );
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
}