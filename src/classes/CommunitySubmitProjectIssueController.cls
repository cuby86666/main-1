/***************************************************************************************************************************************
@created by: Vinanthi ittigi
@Created Date : 12 dec 2015
Description: Apex class to display project issue on community pages as well as on crm.

****************************************************************************************************************************************/

public class CommunitySubmitProjectIssueController
{

    public List<string> lstProjectName { get; set;}
    public List<Project_Issue_Comment__c> lstProjectIssueCmt{ get; set;}
    public string strProjectName { get; set;}
    public String commentBody{get;set;}
    public boolean isAttach{get;set;}
    public string strTitle { get; set;}
    public string strCompany { get; set;}
    public string strDescription { get; set;}
    public string strStatus { get; set;}
    public String strIssueId{get;set;}
    public String strAttachmentId{get;set;}
    public List<SelectOption> lstStatusValues ;    
    public List<Project_User__c> lstProjectUser { get; set;}    
    public List<SelectOption> lstProjectNameValues{get;set;}
    public Attachment objAttachment {get;set;}
    public Project_Issue__c objProjectIssue{get;set;}
    public Id userId { get; set; }
    public List<SelectOption> lstOptions;
    public List<Project_Detail__c> lstProjectDetail{ get; set;}
    public Contact objCont {get;set;}
    public Project_Issue__c objIssue{get; set;}
    public boolean isIntExtUser{get;set;}
    public boolean isNotIntExtUser{get;set;}
    public boolean Submitissue{get;set;}
    public boolean Updateissue{get;set;}
    public List<Project_User__c> allProject {get; set;}
    public List<Project_Issue__c> finalissueListProj {get; set;}    
        
    
    //Redirection to login page if guest user    
    public PageReference getPageReference()
    {
        if (UserInfo.getUserType()=='Guest') 
        {
            return new PageReference('/communityLogin?pagename=communityProjectIssueList');
        }
            
        return null;
    }
    
    //Redirection to login page if guest user
    public PageReference getPageReference1()
    {
        if (UserInfo.getUserType()=='Guest') 
        {
            return new PageReference('/communityLogin?pagename=communitySubmitProjectIssue');
        }
            
        return null;
     }
        
     //Contructor   
     public CommunitySubmitProjectIssueController()
     {
         
         isNotIntExtUser=true;
         isIntExtUser=false;
         isAttach=false;
         submitissue=true;
         updateissue=false;
        
         //if edit question
         if(ApexPages.currentPage().getParameters().get('strIssueId')!=null)
         {
             submitissue=false;
             updateissue=true;
             List<Project_issue__c> objIssue=[Select id,title__c,status__c,Description__c,Project_Name__c,user_company__c from Project_issue__c where id=: ApexPages.currentPage().getParameters().get('strIssueId') LIMIT 1];
             List<Attachment> lstAttach=[select id,name,body from attachment where parentid=:ApexPages.currentPage().getParameters().get('strIssueId') LIMIT 1];
             if(objIssue!=null || objIssue.size()!=0)
             {
                 strTitle= objIssue[0].title__c;
                 strDescription= objIssue[0].Description__c;
                 strCompany=  objIssue[0].user_company__c;
                 strProjectName=  objIssue[0].Project_Name__c;
                 strStatus= objissue[0].status__c;
             }
             
               /* if(lstAttach.size()!=0)
                 {
                     system.debug('%%%'+lstAttach[0].name);
                     objAttachment.name=lstAttach[0].name;
                     objAttachment.body=lstAttach[0].body;
                     system.debug(objAttachment.name);
                 }*/

                
         }
         
             objProjectIssue= new Project_Issue__c();
             objAttachment= new attachment();
             lstProjectNameValues= new List<SelectOption>();
             lstProjectName = new List<string>();
       
              lstProjectUser =[select Project__r.Name from Project_User__c where User__r.id=:UserInfo.getUserId()];
       
             if(lstProjectUser.size()!=0)
             {
                 isIntExtUser=true;
                 isNotIntExtUser=false;
             }
             User objUser = [Select id,contactId,Email,Name,firstname,lastname from user where id=:userInfo.getUserId()];
             finalissueListProj = new List<Project_Issue__c>();
             allProject = new List<Project_User__c>(); 
             allProject = [SELECT id, Project__r.Name, user__c, User_Type__c from Project_User__c where user__r.id=:UserInfo.getUserId()]; 
             List<String> lstProjectName= new List<String>();
            
             for(Project_User__c proUser: allProject )
             {
                 lstProjectName.add(proUser.Project__r.Name);     
             }
             finalissueListProj = [SELECT id,Title__c,Status__c,name,owner.name,OwnerId,Project_Name__c,LastModifiedDate,createddate from Project_Issue__c
                          where (CreatedBy.id=:objUser.id or ownerId=:objUser.id or Project_Name__c In :lstProjectName)  order by createddate DESC];
             
             if(objUser.contactId!=null)
             {
                 objCont = [Select id,Company__c,Community_web_country__c,Web_Region__c 
                           from Contact where id=: objUser.ContactId Limit 1];
                 if(objCont.Company__c!=null)
                 {
                     strCompany =objCont.Company__c;
                 }
                
             }
             else
             {
                strCompany ='Internal (NXP Semiconductors)';
             }
             
             /*
             if(lstProjectUser.size()>0)
             {
                 for(Project_User__c objProjInt:lstProjectUser  )
                 {
                     system.debug('+++proj '+objProjInt.Project__r.Name);
                     lstProjectName.add(objProjInt.Project__r.Name);
                 }
             } */
            
             system.debug('+++ name'+lstProjectName);
         
             if(lstProjectName.size()!=0)
             {
                 system.debug('+++lstprojname1');
                 lstProjectNameValues.add(new SelectOption('Select project','Select project'));
                 for(string strValue: lstProjectName)
                 {
                     if(strValue!=null)
                     {
                         lstProjectNameValues.add(new SelectOption(strValue,strValue));
                     }
                        
                 }   
             }
             List<Attachment> lstAttachment= new List<Attachment>();
             if(ApexPages.currentPage().getParameters().get('id')!=null)
             {
                 objIssue=[SELECT id,Title__c,Status__c,name,Owner.id,LastModifiedDate,owner.name,createddate,CreatedBy.Name,Description__c,LastModifiedBy.Name,project_name__c,
                           User_Company__c from Project_Issue__c
                          where id=:ApexPages.currentPage().getParameters().get('id')];
                 lstProjectIssueCmt=[SELECT Comment__c,LastModifiedDate,CreatedBy.Name,createddate,LastModifiedBy.Name  from Project_Issue_Comment__c where Project_Issue__r.id=:ApexPages.currentPage().getParameters().get('id')];
                 system.debug('!!!!!!!!!!'+lstProjectIssueCmt);
             }
             
             lstAttachment=[select id from Attachment where parentId=:ApexPages.currentPage().getParameters().get('id') ];
             if(lstAttachment.size()!=0) 
                 {
                     objAttachment=lstAttachment[0];
                     isAttach=true;
                 }
             
     }
     
     //Method to display status values on edit of issues
     public List<SelectOption> getStatusValues()
     {        
         lstStatusValues = new List<SelectOption>();
         lstStatusValues .add(new SelectOption('Select Status','Select Status'));
         lstStatusValues .add(new SelectOption('New','New'));
         lstStatusValues.add(new SelectOption('Assigned','Assigned'));       
         lstStatusValues .add(new SelectOption('Pending','Pending'));
         lstStatusValues .add(new SelectOption('Solved','Solved'));   
         return lstStatusValues ;
      }
     
      //Method to post comment on issues
      public PageReference saveComment()
      { 
          Project_Issue_Comment__c cmt= new Project_Issue_Comment__c();
          cmt.Comment__c=commentBody;
          cmt.Project_Issue__c=ApexPages.currentPage().getParameters().get('id');
          try
          {
              insert(cmt);
              //apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Comment has been added to case');
              //ApexPages.addMessage(msg);
          }
          catch (System.DMLException e)
          {
              ApexPages.addMessages(e);
              PageReference pageref= new PageReference('/community/CommunityProjectIssueDetail?id='+ApexPages.currentPage().getParameters().get('id'));
          }
          PageReference pageref= new PageReference('/community/CommunityProjectIssueDetail?id='+ApexPages.currentPage().getParameters().get('id') );
          pageref.GetParameters().Put('msg', 'Comment has been added to case');
          pageref.setRedirect(true);
          return pageref;
      }
      
      //Method to post comment on issues on crm
      public PageReference saveCommentCrm()
      {   
          CommunitySettings__c ProjectIssueCRMlink = CommunitySettings__c.getValues('CommunityUrl');
          Project_Issue_Comment__c cmt= new Project_Issue_Comment__c();
          string Projectlink = ProjectIssueCRMlink.Project_Issue_CRM_link__c;
          cmt.Comment__c=commentBody;
          cmt.Project_Issue__c=ApexPages.currentPage().getParameters().get('id');
          try
          {
              insert(cmt);
              //apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Comment has been added to case');
              //ApexPages.addMessage(msg);
          }
          catch (System.DMLException e)
          {
              ApexPages.addMessages(e);
              PageReference pageref= new PageReference(Projectlink+'/apex/CommunityProjectIssueDetailCrm?id='+ApexPages.currentPage().getParameters().get('id'));
          }
          PageReference pageref= new PageReference(Projectlink+'/apex/CommunityProjectIssueDetailCrm?id='+ApexPages.currentPage().getParameters().get('id') );
          pageref.GetParameters().Put('msg', 'Comment has been added to case');
          pageref.setRedirect(true);
          return pageref;
      } 
      
      //Method to display loggedinuser photo
      public String getLargePhotoUrl() 
      {
          userid = UserInfo.getUserId();
          return ConnectApi.chatterusers.getPhoto(
          Network.getNetworkId(), userId).largePhotoUrl;
      }
     
      //Method to save project issue from community pages
      public PageReference saveProjectIssue() 
      {
          system.debug('$$$$$ save project issue');
          if(strProjectName=='select project')
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Select  Project'));
              return null;
          }
          objProjectIssue.project_name__c=strProjectName;
          objProjectIssue.Status__c='New';
          //objProjectIssue.BL__c=strMag;
          objProjectIssue.Title__c=strTitle;
          objProjectIssue.Description__c=strDescription;
          if(strCompany!=null)
          {
              objProjectIssue.User_Company__c=strCompany;
          }
          lstProjectDetail=[select id,Owner.id,mag__c from Project_Detail__c where name =:strProjectName];
          objProjectIssue.mag__c=lstProjectDetail[0].mag__c;
          system.debug('+++==='+lstProjectDetail[0].owner.id);
          objProjectIssue.ownerid=lstProjectDetail[0].ownerid;
          try
          {
              insert objProjectIssue;
              system.debug(objProjectIssue);
              system.debug('<><><><><project issue owner'+objProjectIssue.owner);
              if(objAttachment.body!=null)
              {             
                  objAttachment.ParentId=objProjectIssue.id;
                    
                  insert(objAttachment);
                  system.Debug(objAttachment.id+'attachment');
              }
              PageReference pageref= new PageReference('/community/CommunityProjectIssueDetail?id='+objProjectIssue.id ); 
              return pageref;
          }
          catch(DMLException e)
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in inserting Project Issue'));
              return null;   
          }
          return null;
      }
      
      //Method to save project issue from CRM
      public PageReference saveProjectIssueCrm() 
      {
          CommunitySettings__c ProjectIssueCRMlink = CommunitySettings__c.getValues('CommunityUrl');
          string Projectlink = ProjectIssueCRMlink.Project_Issue_CRM_link__c;
          system.debug('$$$$$ save project issue');
          if(strProjectName=='select project')
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Select  Project'));
              return null;
          }
          objProjectIssue.project_name__c=strProjectName;
          objProjectIssue.Status__c='New';
          //objProjectIssue.BL__c=strMag;
          objProjectIssue.Title__c=strTitle;
          objProjectIssue.Description__c=strDescription;
          if(strCompany!=null)
          {
              objProjectIssue.User_Company__c=strCompany;
          }
          lstProjectDetail=[select id,Owner.id,mag__c from Project_Detail__c where name =:strProjectName];
          if(lstProjectDetail[0].mag__c != null)
          {
          objProjectIssue.mag__c=lstProjectDetail[0].mag__c;
          }
          system.debug('+++==='+lstProjectDetail[0].owner.id);
          objProjectIssue.ownerid=lstProjectDetail[0].ownerid;
          try
          {
              insert objProjectIssue;
              system.debug(objProjectIssue);
              system.debug('<><><><><project issue owner'+objProjectIssue.owner);
              if(objAttachment.body!=null)
              {             
                  objAttachment.ParentId=objProjectIssue.id;
                    
                  insert(objAttachment);
                  system.Debug(objAttachment.id+'attachment');
              }
              PageReference pageref= new PageReference(Projectlink+'/apex/CommunityProjectIssueDetailCrm?id='+objProjectIssue.id ); 
              return pageref;
          }
          catch(DMLException e)
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in inserting Project Issue'));
              return null;   
          }
          return null;
      }
      
      //Method to edit issue from crm
      public PageReference UpdateProjectIssueCrm() 
      {
          CommunitySettings__c ProjectIssueCRMlink = CommunitySettings__c.getValues('CommunityUrl');
          string Projectlink = ProjectIssueCRMlink.Project_Issue_CRM_link__c;
          List<Project_Issue__c> objProjectIssue=[Select id,title__c,status__c,Description__c,Project_Name__c,user_company__c from Project_issue__c where id=: ApexPages.currentPage().getParameters().get('strIssueId') LIMIT 1];
          system.debug('$$$$$ save project issue');
          if(strProjectName=='select project')
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Select  Project'));
              return null;
          }
            
          if(strStatus=='select status')
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Select  Status'));
              return null;
          }
          objProjectIssue[0].project_name__c=strProjectName;
          if(strstatus!= null || strstatus!= 'select status')
          {
              objProjectIssue[0].Status__c=strstatus;
          }
          //objProjectIssue.BL__c=strMag;
          objProjectIssue[0].Title__c=strTitle;
          objProjectIssue[0].Description__c=strDescription;
          if(strCompany!=null)
          {
              objProjectIssue[0].User_Company__c=strCompany;
                
          }
            
          try
          {
              upsert objProjectIssue;
              
                 /*  system.debug('<><><><><project issue owner'+objProjectIssue[0].owner);
                 if(objAttachment.body!=null)
                    { 
                       if(lstAttachment1.size() != 0)
                        {
                   
                        }            
                       objAttachment.ParentId=objProjectIssue[0].id;
                    
                       insert(objAttachment);
                        system.Debug(objAttachment.id+'attachment');
                    } */

              
             
                    
          PageReference pageref= new PageReference(Projectlink+'/apex/CommunityProjectIssueDetailCrm?id='+objProjectIssue[0].id ); 
          return pageref;
          }
          catch(DMLException e)
          {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in updating Project Issue'));
              return null;   
          }
          return null;
      }
      
      //Method to delete Attachment 
      public PageReference deleteAttachment()
      {   
          CommunitySettings__c ProjectIssueCRMlink = CommunitySettings__c.getValues('CommunityUrl');
          string Projectlink = ProjectIssueCRMlink.Project_Issue_CRM_link__c;
          PageReference pageRef;
          List<Attachment> objAttachment=[Select id, parentid from Attachment where id=: strAttachmentId LIMIT 1];
          if(objAttachment!=null || objAttachment.size()!=0)
          {
              try
              {
                  delete objAttachment[0];
                  pageRef=new PageReference(Projectlink+'/apex/CommunityProjectIssueDetailCrm?id='+objAttachment[0].parentid);
                    
              }
              catch (DMLException e) 
              {
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in Deleting Attachment'));
                  return null;
              }
               
          }
          pageref.setRedirect(true);
          return pageref;
      }

               
 
      //Method to delete issue from crm
      public PageReference deleteIssue()
      {   
          CommunitySettings__c ProjectIssueCRMlink = CommunitySettings__c.getValues('CommunityUrl');
          string Projectlink = ProjectIssueCRMlink.Project_Issue_CRM_link__c;
          PageReference pageRef;
          List<Project_Issue__c> objIssue=[Select id from Project_issue__c where id=: strIssueId LIMIT 1];
          if(objIssue!=null || objIssue.size()!=0)
          {
              try
              {
                  delete objIssue[0];
                  pageRef=new PageReference(Projectlink+'/apex/CommunityProjectIssuesCrm');
                    
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
    
     }