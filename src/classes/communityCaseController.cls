/******************************************************************************************************
@Modified By :      Amrutha R
@Modified Date :    15 Feb 2015
Description :       code modified as per change in the requirement- contact information is not editable
*********************************************************************************************************/

/******************************************************************************************************
@Modified By :      Amrutha R
@Modified Date :    25 Jul 2015
Description :       New UI
*********************************************************************************************************/
/******************************************************************************************************
@Modified By :      Amrutha R
@Modified Date :    27 Jan 2016
Description :       Added code to fetch attachments and emails
*********************************************************************************************************/

/******************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date :    17 feb 2016
Description :      Description : code is modified for inserting multiple attachment for cases.

*********************************************************************************************************/
/******************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date :    15 mar 2016
Description :      Description : code is modified for fetching createddate and bodylength for attachment in cases.

*********************************************************************************************************/
/******************************************************************************************************
@Modified By :      Shridevi Badiger
@Created Date:     28 jun 2017
@Description:      As part of SIR 518-removing the usage of tech support record type to disable it.
*******************************************************************************************************/

public with sharing class communityCaseController 
{
 
    public List<Case>caseList{get; set;}
    public String commentBody{get;set;}
    public List<Contact> lstCont= new List<Contact>();
    public Contact objCont {get;set;}
    public User objUser {get; set;}
    public Case objCase {get;set;}
    public Attachment myAttachment {get;set;}
    public Boolean isContInfo{get; set;}
    public Boolean isCaseInfo{get; set;}
    public Id userId { get; set; }
    public boolean isAttach{get;set;}
    public boolean isAttach1{get;set;}
    public List<casecomment> lstCaseCmt{get;set;}
    public List<emailMessage> lstEmailMsgs{get;set;}
    public EmailMessage objEmailMsg{get;set;}
    public boolean ishtmlBody {get;set;}
    public boolean isTextBody {get;set;}
    public static string strFileName{get;set;}
    public static Blob fileContent{get;set;}
    public String contentType {get; set;} 
    public Integer fileSize  {get;set;}
    
    public PageReference getPageReference()
    {
        if (UserInfo.getUserType()=='Guest') 
        {
            //return new PageReference('/communityLogin?pagename=communityCaseList');
            return new PageReference(Site.getPathPrefix()+Label.Community_Login_URL);
        }
        return null;
    }
    
    public PageReference getPageReference1()
    {
        if (UserInfo.getUserType()=='Guest') 
        {
            //return new PageReference('/communityLogin?pagename=communityContactSupport');
            return new PageReference(Site.getPathPrefix()+Label.Community_Login_URL);
        }
        return null;
    }
    public communityCaseController()
    {
           
    }
   
    public communityCaseController(ApexPages.StandardController controller) 
    {
        if (UserInfo.getUserType()!='Guest')
        {
            /********CODE BY Amrutha to display contact information from contact object*****/
        objUser = [Select id,contactId,Email,Name,firstname,lastname from user where id=:userInfo.getUserId()];
         // Removed the Usage of Tech Support Record Type as part of SIR 518.
        List<RecordType> lstRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
        
        caseList = [SELECT origin,Status, Email__c,Subject,Priority,CaseNumber,ID,createddate,Product_Type_Number__c,LastModifiedDate,createdById FROM 
                    Case where (Email__c=:objUser.Email or case.contact.email=:objUser.Email)
                    and RecordTypeId IN:lstRecordType order by createddate DESC];

        objCase=new Case();
        objCase=(Case)controller.getRecord();
        isCaseInfo=true;
        isContInfo=false;
        lstCaseCmt= [Select id, isPublished, commentbody,CreatedDate,CreatedBy.Name,
                                      LastModifiedBy.Name, LastModifiedDate from casecomment where
                                      parentId=:objCase.id and isPublished=true];
      
         List<attachment> lstAttachment = [select id,createddate from Attachment where parentId=:objCase.id ];
        if(lstAttachment.size()!=0) 
        {
            
            isAttach=true;
        }
        lstEmailMsgs = [Select id,parentid,TextBody,subject,htmlbody,fromaddress,toaddress,createdDate from emailmessage 
                        where parentid=:objCase.id order by createddate DESC];
        if(ApexPages.currentPage().getParameters().get('strQuesId')!=null)
        {
            escalateToCase();
        }
        
        if (!objUser.Email.contains('nxp.com'))
        {
            isContInfo=true;
            isCaseInfo=false;
            list<Contact> lstCont= new List<Contact>();
            lstCont = [Select id,accountId,name,firstname, lastname,email,Phone,Facebook__c,Linkedin__c,
                   Twitter__c,State_Province__c,Job_Title__c,Company__c,Community_web_country__c,Web_Region__c 
                   from Contact where id=: objUser.ContactId Limit 1];
            if(lstCont.size()!=0 || lstCont!=null)
            {
                objCont= lstCont[0];
           
                if(objCont.Phone==null || objCont.Job_Title__c==null || objCont.Company__c==null|| objCont.Community_web_country__c==null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,' Please update your contact information on My Profile page before submitting a case'));
                }
            }
            else
            {
                isCaseInfo=true;
                isContInfo=false;
                objUser = [Select id,contactId,Email,Name,firstname,lastname from user where id=:userInfo.getUserId()];
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,' Contact information is not populated as you donot have enough rights to the customer contact information or contact is empty. Please update contact information before submitting a case'));
            }
        }
        
        /*****code end by Amrutha****/
        myAttachment = new Attachment();
        }
        
    }
    
    public void getEmailDetails()
    {
        objEmailMsg = [Select id,parentid,TextBody,subject,fromaddress,FromName,toaddress,createdDate,BccAddress,CcAddress,
                       HtmlBody,Status,messagedate,createdby.name,lastmodifiedby.name,lastmodifieddate from emailmessage
                       where  id=:ApexPages.currentPage().getParameters().get('id') order by createddate DESC];
        if(objEmailMsg.HtmlBody==null)
        {
            isTextBody=true;
        }
        else
        {
            ishtmlBody=true;
        }
        objCase=[select id,casenumber from case where id=:objEmailMsg.parentid];
    }
    
    public void escalateToCase()
    {
        List<Question> objQues=[Select id,title,body,createdBy.id,Product_Category__c,Product_Sub_Category__c from Question where id=: ApexPages.currentPage().getParameters().get('strQuesId') LIMIT 1];
        if(objQues!=null || objQues.size()!=0)
        {
            objCase.Subject= objQues[0].title;
            objCase.Description = objQues[0].body;
            objCase.Origin='Post Escalation';
            objCase.QuestionId= objQues[0].id;
            
            objUser = [Select id,contactId,Email,Name,firstname,lastname from user where id=:objQues[0].createdBy.id];
            if(objUser.email==null)
            {
                isCaseInfo=true;
                isContInfo=false;
                objUser = [Select id,contactId,Email,Name,firstname,lastname from user where id=:userInfo.getUserId()];
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,' Contact information is not populated as you donot have enough rights to the customer contact information or contact is empty. Please update contact information before submitting a case.'));
            }
        }
    }
    
    public PageReference redirectToCaseSubmitPage()
    {
        PageReference pageref= new PageReference('/community/apex/CommunitiesCaseSubmit');
        pageref.setRedirect(true);
        return pageref;
        
    }
   
    public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.userprofiles.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    public PageReference redirectToAddAttachment()
    {
    
        PageReference pageref= new PageReference('/community/apex/CommunitiesAddAttachment?id='+objCase.id);
        pageref.setRedirect(true);
        return pageref;
        
    }
    
    public PageReference redirecttostandardpage()
    {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(!(profileName.contains('NXP - Overage High Volume Customer Portal User'))){
            PageReference pageref= new PageReference('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2F500%2Fo&save_new_url=%2F500%2Fe%3FretURL%3D%252F500%252Fo');
            pageref.setRedirect(true);
            return pageref;
        }
        return null;
    }
    //method added by Avichal to upload Multiple Attachment (Mar 16 release)
    
    public Pagereference uploadAttachment()
    {
        
        if(myAttachment.body == null && myAttachment.name == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,' Please choose a file before pressing upload attachment button'));
            return null;    
        } 
       
        else
        {
            CommunityCaseAttachmentController cntrlCaseAttachment= new CommunityCaseAttachmentController();
            cntrlCaseAttachment.caseAttachment(myattachment,ApexPages.currentPage().getParameters().get('id'));
             isAttach=true;
        } 
         myAttachment=new Attachment();
        return null;
    }
    
    public List<attachment> getLstAttachment()
    {
        List<attachment> lstAttachment2 = [select id,createddate,bodylength,name from Attachment where parentId=:objCase.id ];
        if(lstAttachment2.size()!=0)
        {
            isAttach=true;
        }
        return lstAttachment2 ;
    }
    
     //method added by Avichal to upload Multiple Attachment (Mar 16 release) Ends
    
    public PageReference saveCase()
    {   
       RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
        try{
            Id userId=objUser.Id;
            Id contactId;
            if(userId!=null){
                List<User> u=[Select contactId,contact.Name,userType from user where id=:userId];
                If(u.size()!=0 && u[0].contactId!=null){
                    objCase.contactID=u[0].contactId;
                    objCase.Email__c= objCont.Email;
                    objCase.First_Name__c= objCont.FirstName;
                    objCase.Last_Name__c= objCont.LastName;
                    objCase.Phone_Number__c=objCont.Phone;
                    objCase.Company__c= objCont.Company__c;
                    objCase.JobTitle__c= objCont.Job_Title__c;
                    objCase.Facebook__c=objCont.Facebook__c;
                    objCase.Linkedin__c=objCont.Linkedin__c;
                    objCase.Twitter__c=objCont.Twitter__c;
                    objCase.State_Province__c=objCont.State_Province__c;
                    objCase.Community_web_country__c=objCont.Community_web_country__c;
                    objCase.Web_Region__c=objCont.Web_Region__c;
                    objCase.RecordTypeId=tsRecordType.Id;
                    if(objCase.Phone_Number__c==null || objCase.Company__c==null || objCase.JobTitle__c==null ||objCase.Community_web_country__c==null)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,' Please update your contact information on My Profile page before submitting a case'));
                        return null;
                    }
                }
                else
                {
                    User objUser=[Select id,Name,firstname,lastname,email from user where id=:userId];
                    List<Account>lstAccount=[select Id, Name From Account Where Name = 'NXP Community' limit 1];
                    List<Contact> lstCont= new List<Contact>();
                    if(objUser.Email!=null)
                    {
                        lstCont=[Select id,name,email,account.name from contact where account.name='NXP Community' and email=: objUser.Email LIMIT 1];
                    }
                    if(lstCont.size()==0)
                    {
                        Contact objContact= new Contact();
                        objContact.FirstName= objUser.FirstName;
                        objContact.LastName= objuser.LastName;
                        objContact.Email= objUser.Email;
                        objContact.Phone= objCase.Phone_Number__c;
                        objContact.Company__c= objCase.Company__c;
                        objContact.Community_web_country__c= objCase.Community_Web_Country__c;
                        objContact.Job_Title__c= objCase.JobTitle__c;
                        objContact.Facebook__c= objCase.Facebook__c;
                        objContact.State_Province__c= objCase.State_Province__c;
                        objContact.Web_Region__c= objCase.Web_Region__c;
                        objContact.Twitter__c= objCase.Twitter__c;
                        objContact.Linkedin__c= objCase.Linkedin__c;
                        objContact.AccountId= lstAccount[0].id;
                        insert objContact;
                        objCase.contactID=objContact.Id;
                        objCase.RecordTypeId= tsRecordType.id;
                    }
                    else
                    {
                        objCase.contactID=lstCont[0].Id;
                        objCase.RecordTypeId= tsRecordType.id;
                    }
                    
                }
            }
            /********CODE BY Amrutha to display error message*****/
            
            /*****code end by Amrutha****/
                Database.SaveResult sr = Database.insert(objCase, false);
                System.Debug('??????????????????????????Parent Case Id is'+sr.getId());
              
           
        }
        catch(System.DMLException e)
        {
            ApexPages.addMessages(e);
            PageReference pageref= new PageReference('/community/apex/CommunitiesCaseDetailView?id='+objCase.id);
            
        }
        PageReference pageref= new PageReference('/community/CommunitiesCaseDetailView?id='+objCase.id );
        pageref.GetParameters().Put('msg2', 'Thank you. Your case has been submitted '); 
        return pageref;
    }
    
    public PageReference saveComment()
    { 
        CaseComment cmt= new CaseComment();
        cmt.CommentBody=commentBody;
        cmt.ParentId=objCase.id;
        cmt.IsPublished=true;
        try
        {
            insert(cmt);
            //apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Comment has been added to case');
            //ApexPages.addMessage(msg);
        }
        catch (System.DMLException e)
        {
                ApexPages.addMessages(e);
                PageReference pageref= new PageReference('/community/apex/CommunitiesCaseDetailView?id='+objCase.id);
        }
        PageReference pageref= new PageReference('/community/CommunitiesCaseDetailView?id='+objCase.id );
        pageref.GetParameters().Put('msg', 'Comment has been added to case');
        pageref.setRedirect(true);
        return pageref;
    }
    
    public void Init()
    {
        String message = '' + ApexPages.currentPage().getParameters().get('msg');
        String message2= '' + ApexPages.currentPage().getParameters().get('msg2');
        String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer'); 
        
        // Use the referrer parameter to only show the message when coming from Page 1
         if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('CommunitiesCaseComment') && message != 'null')
         {
             apexpages.Message msg1 = new Apexpages.Message(ApexPages.Severity.Info,message);
             apexPages.addMessage(msg1);
         }
        if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('CommunitiesCaseSubmit') && message2 != 'null')
        {
            apexpages.Message msg2 = new Apexpages.Message(ApexPages.Severity.Info,message2);
            apexPages.addMessage(msg2);
        }
        
    }
    
    public PageReference addComment(){
        PageReference pr= new PageReference('/community/CommunitiesCaseComment?id='+objCase.id);
        return pr;
    }
    
    public PageReference addAttachment(){
        myAttachment.ParentId=objCase.id;
        try{
            insert(myAttachment);
        }catch(System.DMLException e){
            ApexPages.addMessages(e);
            PageReference pageref= new PageReference('/community/apex/CommunitiesCaseDetailView?id='+objCase.id);
        }
        PageReference pageref= new PageReference('/community/CommunitiesCaseDetailView?id='+objCase.id );
        return pageref;
    }
}