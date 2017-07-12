/******************************************************************************************************
@Created By :      Avichal Kumar
@CreatedDate :     22 Dec 2015
Description :      Test class for CommunitySubmitProjectIssueController
************************************************************************************************************/
@isTest(SeeAllData=True)
public class CommunitySubmitProjectIssueContTest
{ 


 private static final String CASE_TSCOMMUNITY = 'TS_Community';
    private static final String CASE_TSWEBMASTER = 'TS_Webmaster';
    private static final String ACCOUNT_CHILDACCOUNT = 'Child_Account';
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    
    public static RecordType tsCommunity;
    public static RecordType webMaster;
    public static RecordType childAccount;
    public static RecordType parentAccount;
    
private static void fetchRecordTypes()
    {
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              ((SobjectType = 'Case' and (DeveloperName =: CASE_TSCOMMUNITY or DeveloperName =: CASE_TSWEBMASTER)) or
                               (SobjectType = 'Account' and (DeveloperName =: ACCOUNT_CHILDACCOUNT or DeveloperName =: ACCOUNT_ParentACCOUNT)) 
                              )
                              Limit 4])
        {
            if(rt.DeveloperName == CASE_TSCOMMUNITY)
            {
                tsCommunity = rt;
            }
            else if(rt.DeveloperName == CASE_TSWEBMASTER)
            {
                webMaster = rt;
            }
            else if(rt.DeveloperName == ACCOUNT_CHILDACCOUNT)
            {
                childAccount = rt;
            }
            else if(rt.DeveloperName == ACCOUNT_ParentACCOUNT)
            {
                parentAccount = rt; 
            }            
        }
    } 
    
//Method to create projects
    public Static Project_Detail__c createprojects()
    {
        Project_Detail__c objproj=new Project_Detail__c();
        objproj.Name='test1';
        return objproj;
    }
//Method to create project issues
     public Static Project_Issue__c createprojectissues()
    {
        Project_Issue__c objprojissue =new Project_Issue__c();
        objprojissue.Project_Name__c='test1';
        objprojissue.Title__c='title1';
        return objprojissue;
    }
//Method to create project issue Comments
     public Static Project_Issue_Comment__c createprojectIssueComments()
    {
        Project_Issue_Comment__c objprojIssueComment =new Project_Issue_Comment__c();
        objprojIssueComment.Comment__c='test1';
      
        return objprojIssueComment;
    }    
    
//Method to assign users to projects
      public Static Project_User__c createprojectusers()
    {
        Project_User__c objprojuser =new Project_User__c();
        
        return objprojuser;
    }
    
     private Static user getManagerUserid() 
    {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        system.assert(objProfile.Id != null);
        
        User objUser= new User(alias = 'nUser' , email= 'testing@test.com', emailencodingkey='UTF-8', lastname='test',languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id,UserRoleId = portalRole.Id, timezonesidkey='America/Los_Angeles', username= 'prakhartest' + datetime.now().millisecond() +'@test.com' );
         insert objuser;   
        return objUser;
    }
    
     //Method to create Community Settings
    public Static CommunitySettings__c CreateCommunitySetting()
    {
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrlTest';
        return setting;
    
    }
    
    //Method to get profile
    public Static id getProfileId()
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        return objprofile.id;
    
    }
    public Static id getProfileId1()
    {
        Profile objprofile= [SELECT Id FROM Profile WHERE name='NXP Customer Community Login User' Limit 1];
        return objprofile.id;
    
    }
    private static Account createNxpCommunityParentAccount()
    {
        //Method to create a 'NXP Community' Parent Account
        Account objNxpCommunityParentAccount;
        objNxpCommunityParentAccount = new Account(RecordTypeID= parentAccount.ID,
                                                Name = 'NXP Community', Customer_Category__c= 'Longtail');
        return  objNxpCommunityParentAccount;
    } 

    //Method to create a  Contact
    private static Contact createContact()
    {
        Account objNxpCommunityParentAcc = createNxpCommunityParentAccount();
        
        insert objNxpCommunityParentAcc;
        system.assert(objNxpCommunityParentAcc.id!=null);
        
        Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919',  AccountID = objNxpCommunityParentAcc.Id,company__c='test');              
                
        return objContact;        
        
    }
    
    static testmethod void CommunitySubmitProjectIssueContTest1() 
    {
        
        Id profileid = getProfileId();
        
       
        
        User objUser = new User(alias = 'testing1',email='testingaav19@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaav19@test.com' );
        insert objUser;
        
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Project_Issue_CRM_link__c= 'test';
       
        insert setting;
        system.assert(setting.Id!=null);
        
        
        system.runAs(objUser)
        {          
            test.starttest();
      
            Project_Detail__c objproj1=createprojects();
            objproj1.Name='test1';
            objproj1.MAG__c='R01';
            objproj1.Project_Description__c='asdfghjkl';
            insert objproj1;
            system.assert(objproj1.Id!=null);
            
            Project_Issue__c objprojissue1 = createprojectissues();
            objprojissue1.Project_Name__c='test1';
            objprojissue1.Title__c='title1';
            objprojissue1.MAG__c= objproj1.MAG__c; 
            insert objprojissue1;
            system.assert(objprojissue1.Id!=null);
            
            Project_Issue_Comment__c objprojectissuecomment1 = createprojectIssueComments();
            objprojectissuecomment1.comment__c ='test1';
             objprojectissuecomment1.Project_Issue__c = objprojissue1.Id;
             insert objprojectissuecomment1;
            system.assert(objprojectissuecomment1.Id!=null);
             
            
            Project_User__c  objprojuser1 = createprojectusers();
            objprojuser1.User__c=objUser.id;
          
            objprojuser1.Project__c=objproj1.Id;
            insert objprojuser1;
            system.assert(objprojuser1.Id!=null);
            
            Attachment objAttach=new Attachment();
            objAttach.Body=Blob.valueOf('Unit Test Attachment Body');
            
             PageReference pageRef = Page.CommunitySubmitProjectIssueCrm;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('strissueId', objprojissue1.Id);
            
            
            
      
            test.stoptest();
          
            
        
            CommunitySubmitProjectIssueController comForumContrl= new CommunitySubmitProjectIssueController();
            comForumContrl.strProjectName='test1';
             comForumContrl.strTitle='title1';
              comForumContrl.strDescription='test1';
               comForumContrl.strCompany='internal(Semiconductors)';
               
            
            comForumContrl.objAttachment=objAttach;
            comForumContrl.saveCommentCrm();
            comForumContrl.saveProjectIssueCrm();
            comForumContrl.getPageReference();
            comForumContrl.getPageReference1();
            comForumContrl.strissueid= objprojissue1.Id;
            comForumContrl.UpdateProjectIssueCrm();
           
            
        }
    }
     static testmethod void CommunitySubmitProjectIssueContTest2() 
    {
        
        Id profileid = getProfileId1();
        
        fetchRecordTypes();
        Contact objContact=createContact();
        objContact.email='testingaav20@test.com';
        insert objContact;
        test.starttest();
          
        User objUser = new User(alias = 'testing2',email='testingaav20@test.com',emailencodingkey='UTF-8',
        lastname='Testing2', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaav20@test.com',contactId=objContact.id);
        insert objUser;
       
       CommunitySettings__c setting = CreateCommunitySetting();
        setting.Project_Issue_CRM_link__c= 'test';
       
        insert setting;
        system.assert(setting.Id!=null);
        
        
        system.runAs(objUser)
        {          
            
      
            Project_Detail__c objproj1=createprojects();
            objproj1.Name='test1';
            objproj1.MAG__c='R01';
            objproj1.Project_Description__c='asdfghjkl';
            insert objproj1;
            system.assert(objproj1.Id!=null);
            
            Project_Issue__c objprojissue1 = createprojectissues();
            objprojissue1.Project_Name__c='test1';
            objprojissue1.Title__c='title1';
            objprojissue1.MAG__c= objproj1.MAG__c; 
            insert objprojissue1;
            system.assert(objprojissue1.Id!=null);
            
           Project_User__c  objprojuser1 = createprojectusers();
            objprojuser1.User__c=objUser.id;
          
            objprojuser1.Project__c=objproj1.Id;
            insert objprojuser1;
            system.assert(objprojuser1.Id!=null);
          
      
            
            Attachment objAttach=new Attachment();
            objAttach.Body=Blob.valueOf('Unit Test Attachment Body');
            
            
            PageReference pageRef = Page.CommunityprojectIssueList;
            Test.setCurrentPageReference(pageRef);
            
            CommunitySubmitProjectIssueController comForumContrl= new CommunitySubmitProjectIssueController();
            comForumContrl.userId= objUser.id;
            comForumContrl.objAttachment= objAttach;
            comForumContrl.strProjectName='test1';
            comForumContrl.saveComment();
            comForumContrl.saveProjectIssue();
            comForumContrl.saveProjectIssueCrm();
            comForumContrl.saveCommentCrm();
            comForumContrl.getPageReference();
            comForumContrl.getPageReference1();
            comForumContrl.strissueid= objprojissue1.Id;
           
        }
        test.stoptest();
        
    }   
    
    static testmethod void CommunitySubmitProjectIssueContTest3() 
    {
        
        Id profileid = getProfileId1();
        
        fetchRecordTypes();
        Contact objContact=createContact();
        objContact.email='testingaav21@test.com';
        insert objContact;
        test.starttest();
          
        User objUser = new User(alias = 'testing2',email='testingaav21@test.com',emailencodingkey='UTF-8',
        lastname='Testing2', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaav21@test.com',contactId=objContact.id);
        insert objUser;
        
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Project_Issue_CRM_link__c= 'test';
       
        insert setting;
        system.assert(setting.Id!=null);
       
        
        
        system.runAs(objUser)
        {          
            
      
            Project_Detail__c objproj1=createprojects();
            objproj1.Name='test1';
            objproj1.MAG__c='R01';
            objproj1.Project_Description__c='asdfghjkl';
            insert objproj1;
            system.assert(objproj1.Id!=null);
            
            Project_Issue__c objprojissue1 = createprojectissues();
            objprojissue1.Project_Name__c='test1';
            objprojissue1.Title__c='title1';
            objprojissue1.MAG__c= objproj1.MAG__c; 
            insert objprojissue1;
            system.assert(objprojissue1.Id!=null);
            
           Project_User__c  objprojuser1 = createprojectusers();
            objprojuser1.User__c=objUser.id;
          
            objprojuser1.Project__c=objproj1.Id;
            insert objprojuser1;
            system.assert(objprojuser1.Id!=null);
          
      
            
          
            PageReference pageRef = Page.CommunityprojectIssueList;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('id', objprojissue1.id);
            CommunitySubmitProjectIssueController comForumContrl= new CommunitySubmitProjectIssueController();
            comForumContrl.strProjectName='select project';
            comForumContrl.saveComment();
            comForumContrl.saveCommentCrm();
            comForumContrl.saveProjectIssue();
            comForumContrl.saveProjectIssueCrm();
            comForumContrl.strissueid= objprojissue1.Id;
            comForumContrl.deleteissue();
           
            
        }
        test.stoptest();
        
    }   
    /*
    static testmethod void CommunitySubmitProjectIssueContTest4() 
    {
        
        profile objProf= [Select id, name from profile where name='NXP Community Profile'];
        
       
        
        User objUser = new User(alias = 'testing1',email='testingaav22@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProf.id,
        timezonesidkey='America/Los_Angeles',username='testingaav22@test.com' );
        insert objUser;
        
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Project_Issue_CRM_link__c= 'test';
       
        insert setting;
        system.assert(setting.Id!=null);
        
        
        system.runAs(objUser)
        {
          
            PageReference pageRef = Page.CommunityprojectIssueList;
            Test.setCurrentPageReference(pageRef);
        
            CommunitySubmitProjectIssueController comForumContrl= new CommunitySubmitProjectIssueController();
            
            comForumContrl.getPageReference();
            comForumContrl.getPageReference1();
            
            
        }
    } */

    static testmethod void CommunitySubmitProjectIssueContTest5() 
    {
        
        Id profileid = getProfileId();
        
       
        
        User objUser = new User(alias = 'testing1',email='testingaav19@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaav19@test.com' );
        insert objUser;
        
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Project_Issue_CRM_link__c= 'test';
       
        insert setting;
        system.assert(setting.Id!=null);
        
        
        system.runAs(objUser)
        {          
            test.starttest();
      
            Project_Detail__c objproj1=createprojects();
            objproj1.Name='test1';
            objproj1.MAG__c='R01';
            objproj1.Project_Description__c='asdfghjkl';
            insert objproj1;
            system.assert(objproj1.Id!=null);
            
            Project_Issue__c objprojissue1 = createprojectissues();
            objprojissue1.Project_Name__c='test1';
            objprojissue1.Title__c='title1';
            objprojissue1.MAG__c= objproj1.MAG__c; 
            insert objprojissue1;
            system.assert(objprojissue1.Id!=null);
            
           
            
            Project_User__c  objprojuser1 = createprojectusers();
            objprojuser1.User__c=objUser.id;
          
            objprojuser1.Project__c=objproj1.Id;
            insert objprojuser1;
            system.assert(objprojuser1.Id!=null);
            
            Attachment objAttach=new Attachment();
            objAttach.Body=Blob.valueOf('Unit Test Attachment Body');
            
             PageReference pageRef = Page.CommunityProjectIssueDetailCrm;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('Id', objprojissue1.Id);
            
            
            
      
            test.stoptest();
          
            
        
            CommunitySubmitProjectIssueController comForumContrl= new CommunitySubmitProjectIssueController();
            comForumContrl.strProjectName='select project';
             comForumContrl.strTitle='title1';
              comForumContrl.strDescription='test1';
               comForumContrl.strCompany='internal(Semiconductors)';
               
            
            comForumContrl.objAttachment=objAttach;
            comForumContrl.saveCommentCrm();
            comForumContrl.saveProjectIssueCrm();
            comForumContrl.getPageReference();
            comForumContrl.getPageReference1();
            comForumContrl.strissueid= objprojissue1.Id;
            comForumContrl.UpdateProjectIssueCrm();
           
            
        }
    }
    static testmethod void CommunitySubmitProjectIssueContTest6() 
    {
        
        Id profileid = getProfileId();
        
       
        
        User objUser = new User(alias = 'testing1',email='testingaav19@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaav19@test.com' );
        insert objUser;
        
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Project_Issue_CRM_link__c= 'test';
       
        insert setting;
        system.assert(setting.Id!=null);
        
        
        system.runAs(objUser)
        {          
            test.starttest();
      
            Project_Detail__c objproj1=createprojects();
            objproj1.Name='test1';
            objproj1.MAG__c='R01';
            objproj1.Project_Description__c='asdfghjkl';
            insert objproj1;
            system.assert(objproj1.Id!=null);
            
            Project_Issue__c objprojissue1 = createprojectissues();
            objprojissue1.Project_Name__c='test1';
            objprojissue1.Title__c='title1';
            objprojissue1.MAG__c= objproj1.MAG__c; 
            insert objprojissue1;
            system.assert(objprojissue1.Id!=null);
            
            Project_Issue_Comment__c objprojectissuecomment1 = createprojectIssueComments();
            objprojectissuecomment1.comment__c ='test1';
             objprojectissuecomment1.Project_Issue__c = objprojissue1.Id;
             insert objprojectissuecomment1;
            system.assert(objprojectissuecomment1.Id!=null);
             
            
            Project_User__c  objprojuser1 = createprojectusers();
            objprojuser1.User__c=objUser.id;
          
            objprojuser1.Project__c=objproj1.Id;
            insert objprojuser1;
            system.assert(objprojuser1.Id!=null);
            
            Attachment objAttach=new Attachment();
            objAttach.Body=Blob.valueOf('Unit Test Attachment Body');
            
             PageReference pageRef = Page.CommunitySubmitProjectIssueCrm;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('strissueId', objprojissue1.Id);
            
            
            
      
            test.stoptest();
          
            
        
            CommunitySubmitProjectIssueController comForumContrl= new CommunitySubmitProjectIssueController();
            comForumContrl.strProjectName='test1';
            comForumContrl.strStatus='select status';
             comForumContrl.strTitle='title1';
              comForumContrl.strDescription='test1';
               comForumContrl.strCompany='internal(Semiconductors)';
               
            
            comForumContrl.objAttachment=objAttach;
            comForumContrl.saveCommentCrm();
            comForumContrl.saveProjectIssueCrm();
            comForumContrl.getPageReference();
            comForumContrl.getPageReference1();
            comForumContrl.strissueid= objprojissue1.Id;
            comForumContrl.UpdateProjectIssueCrm();
             comForumContrl.getStatusValues();
            
           
            
        }
    }
    
     static testmethod void CommunitySubmitProjectIssueContTest7() 
    {
        
        Id profileid = getProfileId();
        
       
        
        User objUser = new User(alias = 'testing1',email='testingaav19@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = profileid,
        timezonesidkey='America/Los_Angeles',username='testingaav19@test.com' );
        insert objUser;
        
        CommunitySettings__c setting = CreateCommunitySetting();
        setting.Project_Issue_CRM_link__c= 'test';
       
        insert setting;
        system.assert(setting.Id!=null);
        
        
        system.runAs(objUser)
        {          
            test.starttest();
      
            Project_Detail__c objproj1=createprojects();
            objproj1.Name='test1';
            objproj1.MAG__c='R01';
            objproj1.Project_Description__c='asdfghjkl';
            insert objproj1;
            system.assert(objproj1.Id!=null);
            
            Project_Issue__c objprojissue1 = createprojectissues();
            objprojissue1.Project_Name__c='test1';
            objprojissue1.Title__c='title1';
            objprojissue1.MAG__c= objproj1.MAG__c; 
            insert objprojissue1;
            system.assert(objprojissue1.Id!=null);
            
            Project_Issue_Comment__c objprojectissuecomment1 = createprojectIssueComments();
            objprojectissuecomment1.comment__c ='test1';
             objprojectissuecomment1.Project_Issue__c = objprojissue1.Id;
             insert objprojectissuecomment1;
            system.assert(objprojectissuecomment1.Id!=null);
             
            
            Project_User__c  objprojuser1 = createprojectusers();
            objprojuser1.User__c=objUser.id;
          
            objprojuser1.Project__c=objproj1.Id;
            insert objprojuser1;
            system.assert(objprojuser1.Id!=null);
            
            Attachment objAttach=new Attachment();
            objAttach.Body=Blob.valueOf('Unit Test Attachment Body');
            objattach.name='Test Attach';
            objattach.Parentid=objprojissue1.Id;
             insert  objAttach;
              system.assert(objAttach.Id!=null);
            
            
             PageReference pageRef = Page.CommunitySubmitProjectIssueCrm;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('Id', objprojissue1.Id);
            
            
            
      
            test.stoptest();
          
            
        
            CommunitySubmitProjectIssueController comForumContrl= new CommunitySubmitProjectIssueController();
            
            comForumContrl.getPageReference();
            comForumContrl.getPageReference1();
            comForumContrl.strissueid= objprojissue1.Id;
            comForumContrl.strAttachmentId = objAttach.Id; 
            comForumContrl.deleteAttachment();
          
        }
    }
    
}