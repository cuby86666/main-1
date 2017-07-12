/*******************************************************************************************************
@Created By :      Amrutha R
@Created Date:     01 June 2015
@Description:      Common Class for all VF pages having tab section. To check whether user email is in public domain
************************************************************************************************************/
/*******************************************************************************************************
@Modified By :      Vinanthi
@Date:     14 Dec 2015
@Description:      written method to check when the user is internal or external
************************************************************************************************************/

public class CommunityTabsController 
{
     public List<Project_User__c> lstProjectUser =new List<Project_User__c>();
    

    public CommunityTabsController(CommunityEditReplyController controller) {

    }
	public CommunityTabsController(communityCaseController controller) {

    }

    public CommunityTabsController(SubmitCaseController controller) {

    }
    public Id userId { get; set; }


    public CommunityTabsController(CommunitiesSuccessStoriesController controller) {}
    
    public CommunityTabsController(CommunitySubmitProjectIssueController controller) {}

    public CommunityTabsController(CommunityQuestionViewController controller) {}

    public CommunityTabsController(CommunityForumQuestionListController controller) {}

    public CommunityTabsController(CommunityForumController controller) {}

    public CommunityTabsController(CommunityFAQviewController controller) {}

    public CommunityTabsController(CommunityFAQController controller) {}

    public CommunityTabsController(ApexPages.StandardController controller) {}

    public CommunityTabsController(CommunityAllleaderDisplayController controller) {}

    public CommunityTabsController(CommunityOverviewController controller) {}

    public CommunityTabsController(){}
    
    public boolean getpublicDomain()
    {
        User objUser= [Select id,name,email from User where id=:userinfo.getUserId()];
        Set<String> publicDomainsSet = new  Set<String>();
        for(Public_Domain__c objPublicDomain : [Select Domain_Name__c,Enable_Contact_Support_Filter__c From Public_Domain__c])
        {
            if(objPublicDomain.Enable_Contact_Support_Filter__c=='Yes')
            {
                publicDomainsSet.add(objPublicDomain.Domain_Name__c);
            }       
        } 
        if(publicDomainsSet.contains(objUser.email.substringafter('@')))
        {
            return true;
        }
        return false;
    }
    // method added by vinanthi
    public boolean getInternalExternalUser()
    {
    
    lstProjectUser=[select id from Project_User__c where User__r.id=:UserInfo.getUserId()];
    
   
     
     if(lstProjectUser.size()!=0 )
         {
         return true;
         }
      return false;
     }
     
     
    public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    
}