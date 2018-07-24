/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
/*********************************************************
@Modified By 		Nisha Agrawal
@Modified Date		Jul 17, 2018
@Description		Modified forwardToStartPage method to redirect to correct community landing page
 *********************************************************/

public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() 
    {
     	//TODO : get the correct SitePrefix for customer community page and redirect to COntext page for it
        //and redirect to Network.communitiesLanding() for rest of the communities
        
        System.debug('Inside Landing Controller+++++++++++++++++++++++++++++++++++'+USerinfo.getUSerType());
        if(Site.getPrefix() == '/LeadPortal')
        {
            return Network.communitiesLanding();
        }
        else
        {
            return new PageReference(Site.getPrefix()+'/CommunityContextPage');
        }
     
        // return new PageReference(Site.getPrefix()+'/_ui/chatter/service/ChatterAnswersUi') ;         
        //return new PageReference(Site.getPrefix()+'/CommunityContactSupport');
    }
    //Code added for custom login page
    /**
    public PageReference forwardToCustomAuthPage() 
    {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return new PageReference(Site.getPrefix() + '/SiteLogin?startURL=' +
        EncodingUtil.urlEncode(startURL, 'UTF-8'));
    }
    **/
    public PageReference forwardToCustomAuthPage() 
    {
    
    
    if (UserInfo.getUserType()=='Guest') {
        //return Page.CustomCommunityLogin; //and whatever startURL you want 
        return new PageReference(Site.getPrefix()+'/_ui/chatter/service/ChatterAnswersUi');
     } else { 
       // return Page.DemoLandingPage; //if one was provided, otherwise some default home/landing page
       return new PageReference(Site.getPrefix()+'/_ui/chatter/service/ChatterAnswersUi') ;
     } 
    }
    public CommunitiesLandingController() {}
}