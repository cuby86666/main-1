/**
 * An apex page controller that exposes the site login functionality
 */
/***************************************************************************************************
@Modified By :       Amrutha
@Modified Date:      13 Feb 2015
@Description:        Changes according to new requirement- new registration flow
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :       Shridevi
@Modified Date:      27 July 2017
@Description:        As part of SIR 750, added a varible to redirect to login page, commented the methods SignUpPage()and resendEmailVerification()
*******************************************************************************************************/
global with sharing class SiteLoginController 
{
    global String username {get; set;}
    global String password {get; set;}
    public Boolean isResend{get;set;}
    public Boolean isReactivation{get;set;}
    public String emailVerificationLink;
    public String userId;
    public String InternalUserSignInUrl{get;set;}
    public Boolean isRedirect{get;set;}
    public String strPageName{get;set;}
    public Boolean isSent{get;set;}
    public String RedirectionToLoginPage{get;set;}
    global SiteLoginController () 
    {
    //below line is added by shridevi for redirecting to login page instead of communityRegistration page since the page has been deleted.
        RedirectionToLoginPage=(Site.getPathPrefix()+Label.Community_Login_URL);
        
        isResend=false;
        strPageName=ApexPages.currentPage().getParameters().get('pagename');
        string returl= ApexPages.currentPage().getParameters().get('pagename');
        String urlVal = Apexpages.currentPage().getUrl();
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        InternalUserSignInUrl= cs.InternalUserSignInUrl__c;
        if(retUrl!=null && urlVal.contains('pagename'))
        { 
            isRedirect= true;
        }
        else
        { 
            isRedirect=false;
        }
    }
    
    global PageReference login() 
    {
        String startUrl;
        string returl= ApexPages.currentPage().getParameters().get('pagename');
        String urlVal = Apexpages.currentPage().getUrl();
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        emailVerificationLink= cs.EmailVerficationLink__c;
        
        //code added by Avichal kumar
        if(retUrl!=null && urlVal.contains('pagename'))
        { 
            startUrl=  '/community/'+retUrl; 
            isRedirect= true;
        }
        else
        {
            //startUrl=  '/community/CommunityOverview'; 
            //startUrl=  '/community/CommunityContactSupport';
            startUrl=  '/community/CommunityContextPage';
            isRedirect=false;
        }
        //code added by Avichal Kumar ends
        
        
        if(username.toLowercase().substringafter('@').equals('nxp.com'))
        {
            String InternalUserSignInUrl= cs.InternalUserSignInUrl__c;
            System.debug('InternalUserSignInUrl::'+InternalUserSignInUrl);
            PageReference pg = new PageReference(InternalUserSignInUrl);
            System.debug('PageReference::'+pg);
            
            
            pg.setRedirect(true);
            
            return pg;
                        
        }
        else
        {
             
            if (! username.toLowerCase().substringafter('@').equals('nxp.com'))
            {
                User[] lstUser= [select id, email,username,Email_verification_status__c,LastLoginDate from User where username=: username LIMIT 1];
                if(lstUser.size()>0)
                {
                    if(lstUser[0].Email_verification_status__c=='Activated' || lstUser[0].Email_verification_status__c==null)
                    {
                        return Site.login(username, password, startUrl);
                    }
                    
                    else if(lstUser[0].Email_verification_status__c=='Activation pending')
                    {
                        isResend=true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Email verification is not done!! Please click on the link sent to your registered email address for email verification'));
                        return null;                    
                    }   
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'No user found, incorrect user name'));
                    return null; 
                }
                //Code end by Amrutha              
            }
        }
        return null;
        
    }
      //code for future reference for internal login
   /* public PageReference internalLogin()
    {
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        PageReference newpg = new PageReference('/CommunitiesLanding');
        String InternalUserSignInUrl= cs.InternalUserSignInUrl__c;
            PageReference pg = new PageReference(InternalUserSignInUrl);
            system.debug('+++pg '+InternalUserSignInUrl);
            if(ApexPages.currentPage().getParameters().get('pagename')!=null || 
                ApexPages.currentPage().getParameters().get('pagename')!='')
            {
                pg.getParameters().put('pagename', ApexPages.currentPage().getParameters().get('pagename'));
                
            }
            pg.setRedirect(true);
            
            return pg;
    }*/
    /********resendEmailVerification() and SignUpPage() methods are commented by shridevi as part of SIR 750*****
    public void resendEmailVerification()
    {
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        emailVerificationLink= cs.EmailVerficationLink__c;
        User objUser= [select id, firstname, email,contactId from user where email=: ApexPages.currentPage().getParameters().get('email') LIMIT 1];
        Task objTask=new task(WhoId = objUser.contactid);
        Integer errorCount=0;        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {objUser.Email};
        String strBody ='Hello '+ objUser.FirstName + ',\n\n'
                                +'Please click on the following link to complete the email verification process and to activate your account. \n' 
                                + emailVerificationLink + '/CommunitiesEmailVerfication'
                                + '?email=' + objUser.Email + '\n\n'
                                + 'Thank You. \n\n'+ 'Best regards,\n'+ 'NXP Technical Support team';
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('NXP Technical Support');
        mail.setSubject( 'NXP Technical Support: User Verification for '+ objUser.Email );
        mail.setPlainTextBody(strBody);
        isSent=true;
        Messaging.SendEmailResult[] results;
        //create task whenever this method is called, to track if any error occurs while sending email. 
        //Task will be under registered contact
        try
        {
            results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if (results[0].success) 
            {
                objTask.Subject ='The email was sent successfully.';
            } 
            else 
            {
                objTask.Subject ='The email was not sent. '+ results[0].errors[0].message;
                errorCount++;
            }
        }
        catch(System.EmailException ex)
        {
            objTask.Subject ='The email was not sent. '+ ex.getMessage();
            errorCount++;
        }
        try
        {
            insert objTask;
        }
        catch(DMLException e)
        {
            errorCount++;
        }
        if(errorCount>0)
        {
            isSent=false;
        }
    }
   
       public PageReference SignUpPage()
    {
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        String communitySingnUpUrl= cs.CommunitySignUpUrl__c;   
        PageReference page = new PageReference(communitySingnUpUrl);
        page.setRedirect(true);
        return page;
    } 
    
    *****************************Ends Here************************************************/
    
}