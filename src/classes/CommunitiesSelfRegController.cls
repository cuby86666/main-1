/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
/***************************************************************************************************
@Modified By :       Prakhar Gupta
@Modified Date:      24 Aug 2014
@Description:        
===========================================================================================
@Modified By :       Amrutha
@Modified Date:      02 Feb 2015
@Description:        Changes according to new requirement- add more fields to registration form 
                     and new registration flow
============================================================================================
@Modified By :       Amrutha
@Modified Date:      29 April 2015
@Description:        Changes according to new requirement- Captcha implementation
============================================================================================
@Modified By :       Amrutha
@Modified Date:      22 Dec 2015
@Description:        Changes according to redirection to contact support page
====================================================================================
@Modified By :       Amrutha
@Modified Date:      15 feb 2016
@Description:        Optimised and removed unwanted 
==========================================================================
@Modified By :       Amrutha
@Modified Date:      10 Mar 2016
@Description:        Creating task while sending email, to track email status. 
=================================================================================
@Modified By :      Vinanthi
@ModifiedDate :     20 Jun 2016
Description :      Removed NER related fields from this class as part of SIR 977
===========================================================================================
@Modified By :      Nisha Agrawal
@ModifiedDate :     01 Sep 2016
@Description :      Removing the code piece which is linking contact with real CRM Account. SIR 1186
****************************************************************************************************/

public with sharing class CommunitiesSelfRegController 
{
    private static final String Child_ACCOUNT = 'Child Account';
    private static final String TS_ACCOUNT = 'Technical Services';
    private static final String NXP_ACCOUNT = 'NXP Community';
    
    public String emailVerificationLink;
    public String userId;
    public String strFirstName {get; set;}
    public String strLastName {get; set;}
    public String strEmail {get; set;}
    public String strPassword {get; set {strPassword = value == null ? value : value.trim(); } }
    public String strConfirmPassword {get; set { strConfirmPassword = value == null ? value : value.trim(); } }
    public String strCommunityNickname {get; set { strCommunityNickname = value == null ? value : value.trim(); } }
    public Boolean isCheck{get;set;}
    public Contact objCaseCont { get; set; }
    public Contact objCommunityCont { get; set; }
    public string strPhone { get; set; }   
    public String strFacebook { get; set;}
    public String strLinkedIn { get; set;}
    public String strTwitter {get; set;}
    public String strState {get; set;}
    public String strJobTitle { get; set; }
    public String strWebRegion { get; set; }
    public String strCountry { get; set; }
    public String strCompany{get; set;}
    public String strEmailDomain;
    public List<SelectOption> lstOptions;
    public User objUser;
    public User objUser1;
    public List<User> lstUser;
    public List<Contact> lstDupCont;
    public Boolean isVerified { get; set; }
    public Boolean dupEmailFlag { get; set; }
    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean isVerifiedCaptcha { get; private set; }
    List<String> characters;
    public String input {get; set;}
    public String char1;
    public String char2;
    public String char3;
    public String char4;
    public String char5;
    public String char6;
    public String strPageName{get;set;}
    public Boolean isRedirect{get;set;}
   
    public CommunitiesSelfRegController() 
    {
        if(Apexpages.currentPage().getUrl().contains('pagename'))
        {
            strPageName=ApexPages.currentPage().getParameters().get('pagename');
        }
        this.isVerifiedCaptcha = false;
        characters = new List<String>{'a','b','c','d','e','f','g','h',
            'i','j','k','l','m','n','o','p','q','r','s','t','u','v','w',
            'x','y','z','1','2','3','4','5','6','7','8','9','0'
        };
    }
    
    //This methods simply returns a random number between 0 and the size of the character list
    public Integer randomNumber()
    {
        Integer random = Math.Round(Math.Random() * characters.Size());
        if(random == characters.size()){
            random--;
        }
        return random;
    }
 
    /*Here we have 6 get methods that return 6 random characters to the page.
    For chars 1,3, and 5 (the black characters) we are saving the the values so 
    that we can compare them with the user's input */
    public String getChar1()
    {
        char1 = characters[randomNumber()];
        return char1;
    }
    public String getChar2()
    {
        char2 = characters[randomNumber()];
        return char2;
    }
    public String getChar3()
    {
        char3 = characters[randomNumber()];
        return char3;
    }
    public String getChar4()
    {
        char4 =characters[randomNumber()];
        return char4;
    }
    public String getChar5()
    {
        char5 = characters[randomNumber()];
        return char5;
    }
    public String getChar6()
    {
        char6 = characters[randomNumber()];
        return char6;
    }
    
    private boolean isValidPassword() 
    {
        return strPassword == strConfirmPassword;
    }
    
    public List<SelectOption> getJobTitles() 
    {
        lstOptions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Job_Title__c.getDescribe();
        List<Schema.PicklistEntry> lstPicklist = fieldResult.getPicklistValues();
        lstOptions.add(new SelectOption('--None--','Select Job title'));        
        for( Schema.PicklistEntry picklist : lstPicklist)
        {
            lstOptions.add(new SelectOption(picklist.getLabel(), picklist.getValue()));
        }
        return lstOptions;
    }    
 
    public List<SelectOption> getCountries()      
    {
        lstOptions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Contact.Community_Web_Country__c.getDescribe();
        List<Schema.PicklistEntry> lstPicklist = fieldResult.getPicklistValues();
        lstOptions.add(new SelectOption('--None--','Select Country'));
        for( Schema.PicklistEntry picklist : lstPicklist)
        {
            lstOptions.add(new SelectOption(picklist.getLabel(), picklist.getValue()));
        }
        return lstOptions;
    }
    
    public List<SelectOption> getWebRegions() 
    {
        lstOptions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.Web_Region__c.getDescribe();
        List<Schema.PicklistEntry> lstPicklist = fieldResult.getPicklistValues();
        lstOptions.add(new SelectOption('--None--','Select Region'));
        for( Schema.PicklistEntry picklist : lstPicklist)
        {
            lstOptions.add(new SelectOption(picklist.getLabel(), picklist.getValue()));
        }      
        return lstOptions;

    }
    
    //method for user registration 
    public PageReference registerUser() 
    {        
        PageReference successPage;
        //'NXP community' account and 'NXP Customer Community Login User' profile
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        String accountId= cs.CommunityUserAccountId__c; 
        String profileId= cs.CommunityUserProfileId__c;
        
        //if nxp user
        if (strEmail.toLowercase().substringafter('@').equals('nxp.com'))
        {
            String InternalUSerSignUpUrl= cs.InternalUserSignUpUrl__c; 
            PageReference pageRef = new PageReference(InternalUserSignUpUrl+'?firstName='+strFirstName+'&lastName='+strLastName+'&email='+strEmail);
            pageRef.setRedirect(true);
            return pageRef;
        }
        //if external user
        else
        {
            if (strCountry == '--None--'|| strCountry == '' || strCountry =='Select Country')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Country'));
            }
            if(strJobTitle == '--None--'|| strJobTitle == '' || strJobTitle =='Select Job title')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Job Title'));     
            }
            if (!isValidPassword()) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Passwords dont match'));
            } 
            if(isCheck==false)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Agree Terms and Conditions'));
            }
            if(input.length() != 6 || input.subString(0,1) != char1 || input.subString(1,2) != char2 || input.subString(2,3) != char3 || input.subString(3,4) != char4 || input.subString(4,5) != char5 || input.subString(5,6) != char6)
            {
                input='';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid CAPTCHA, Please enter again'));
            }
            lstUser= [select id,email from user where email=: strEmail LIMIT 1];
            
            if(lstUser.size()>0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Email address already in use, Please use different email address to register'));     
            }
            //Code added by Vinanthi for duplicate contact check.
            dupEmailFlag = false;
            lstDupCont=[select id,email,accountID FROM Contact WHERE email=: strEmail and accountID!= null LIMIT 1];
            if(lstDupCont.size()>0)
            {
             accountId= lstDupCont[0].accountID;
            }
            
            
            if(ApexPages.hasMessages()==true)
            {
                return null;
            }

            objUser = new User(Username = strEmail,Email = strEmail,FirstName = strFirstName,LastName = strLastName,
                              CommunityNickname = strCommunityNickname,ProfileId = profileId,UserPermissionsChatterAnswersUser=true,
                              Email_verification_status__c='Activation pending');
            try
            {
                userId = Site.createExternalUser(objUser,accountId, strPassword);
                system.debug('user ID'+userId);
               // objUser1= [select id,contactid from user where id =:userId ];
            }
            catch(Site.ExternalUserCreateException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured during registration'+e.getDisplayMessages()));     
                return null;   
            }
            catch(DMLException e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured during registration'));     
                return null;   
            }
            
            //code added by vinanthi for dup contact check
         /*   if(dupEmailFlag)
            {
             
            Contact objdupCont = [select id from contact where id =: objUser1.contactid limit 1];
            objUser1.contact=lstDupCont[0];
            try{
                update objUser1;
                //delete objdupCont;
                }
                catch(DMLException e)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured during user update'));     
                    return null;
                }
                try{
                delete objdupCont;
                }
                catch(DMLException e)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured during duplicate contact deletion'));     
                    return null;
                }
            } */
            
            //Delete contact for registered user if present in Technical service account
            Contact [] lstCont = [Select Id, Email,Name, Phone, Account.Name from Contact 
                                where Email =: strEmail and Account.Name =: TS_ACCOUNT  Limit 1 ];
            if(lstCont.size()>0)
            {
                objCaseCont = lstCont[0];
            }
            if(lstCont.size()>0)
            {
                try
                {
                    delete objCaseCont;
                }
                catch(DMLException e)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured during registration'));     
                    return null;
                }
            }
            
            //Update NXP community contact mapped and created with external user
            //Contact [] lstCommunityCont = [Select Id, Email, Phone, Account.Name from Contact 
             //                           where Email =: strEmail and Account.Name =: NXP_ACCOUNT  Limit 1 ];    
            if(userId != null){
            objUser1= [select id,contactid from user where id =:userId limit 1];
            
            
            if(objUser1.contactid != null )
            {   
                objCommunityCont = [select id from contact where id=: objUser1.contactid limit 1];
                objCommunityCont.Phone =  strPhone;
                objCommunityCont.Facebook__c= strFacebook;
                objCommunityCont.Linkedin__c= strLinkedIn;
                objCommunityCont.Twitter__c= strTwitter;
                objCommunityCont.State_Province__c= strState;
                objCommunityCont.Job_Title__c= strJobTitle;
                objCommunityCont.Company__c= strCompany;
                objCommunityCont.Community_web_country__c= strCountry;
                objCommunityCont.Web_Region__c= strWebRegion;
                try
                {
                    update objCommunityCont;
                }
                catch(DMLException e)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured during registration'));     
                    return null;
                }
            }     
            }
            if (userId != null) 
            { 
                if(emailVerification())
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured while sending verification email'));     
                    return null;
                }
                else
                {
                    successPage = new PageReference('/community/CommunitiesSelfRegSuccess');
                    successPage.setRedirect(true);
                    return successpage;
                }
            }
        }
        return null;
    }   
    
    //method to send email to user for verification
    public Boolean emailVerification()
    {
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        User objUser= [Select id, name,contactid from user where id=:userId];
        Task objTask=new task(WhoId = objUser.contactid);
        Integer errorCount=0;
        emailVerificationLink= cs.EmailVerficationLink__c;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {strEmail};
        String strBody = 'Hello '+ strFirstName + ',\n\n'
                         + 'Please click on the following link to complete the email verification process and to activate your account. \n' 
                         + emailVerificationLink + '/CommunitiesEmailVerfication'
                         + '?email=' + strEmail 
                         + (strPageName!=null ? '&pageName=' +strPageName +'\n\n': '\n\n') 
                         + 'Thank You. \n\n' + 'Best regards,\n' + 'NXP Technical Support team';
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('NXP Technical Support');
        mail.setSubject( 'NXP Technical Support: User Verification for '+ strEmail );
        mail.setPlainTextBody(strBody);
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
            return true;
        }
        return false;
    }
    
    //method to confirm user email
    public PageReference confirmEmailRequest()
    {
        isRedirect=false;
        if(ApexPages.currentPage().getParameters().get('pagename')!=null)
        {
            strPageName=ApexPages.currentPage().getParameters().get('pagename');
            isRedirect=true;
        }
        
        User[] lstUser= [Select Id,Email,Email_verification_status__c From User Where 
                         Email=: ApexPages.currentPage().getParameters().get('email') LIMIT 1];
        if(lstUser.size()>0)
        {
            if(lstUser[0].Email_verification_status__c=='Activation pending')
            {
                lstUser[0].Email_verification_status__c='Activated';
                update lstUser[0];
                isVerified = true;
                //accountContactMapping(lstUser[0]); //Commented by Nisha on Sep 01 for SIR 1186
            }
            else if(lstUser[0].Email_verification_status__c=='Activated')
            {
                isVerified = true;
            }
            return null;
        }
        else
        {
            isVerified = false;
            return null;
        }
        
    }
    
    /* - commented By Nisha for SIR 1186
    public void accountContactMapping(User objUsr)
    {
        Boolean isAssignByLastModifiedDate=false;
        Boolean isAssignByCountry=false;
        List<Account> lstAcnts= new List<Account>();
        List<Account> lstCrmAcnts= new List<Account>();
        List<String> lstCrmAcntNames= new List<String>();
        List<Contact> lstContacts= new List<contact>();
        List<Contact> lstCrmContact = new List<Contact>();
        List<String> lstContactEmails= new List<String>();
        List<Case> lstCases= new List<Case>(); 
        List<Case> lstAllCases;
        Set<String> publicDomainsSet = new  Set<String>();
        Map<String,String> mapAcnts= new Map<String,String>();
        RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
        RecordType techRecordType=[Select Id,name from recordtype where name='Tech Support' LIMIT 1];
        Account tsAccount=[Select Id,Name From Account where Name=:TS_ACCOUNT LIMIT 1];
        
        for(Public_Domain__c objPublicDomain : [Select Domain_Name__c From Public_Domain__c])
        {
            publicDomainsSet.add(objPublicDomain.Domain_Name__c);        
        }  
        
        User objUser=[Select Id, Name, Email, ContactId,profile.id From User Where Id=: objUsr.Id LIMIT 1];
        Contact objContact=[Select Id,AccountId,Name,Email,Community_web_country__c,Company__c,Assigned_Merged_from_NXP_Community__c,
                            CanAllowPortalSelfReg,AssistantName,AssistantPhone,Birthdate,CurrencyIsoCode,ownerId,
                            Jigsaw,Department,Description,DoNotCall,HasOptedOutOfEmail,Fax,HasOptedOutOfFax,HomePhone,LeadSource,MobilePhone,OtherPhone,ReportsToId,Title,
                            Autocreated__c,Contact_ID_Full__c,CSC_Contact__c,
                            Custom_Description__c,KeyContact__c,No_Longer_w_Company__c,NPS_Survey__c, NXP_News__c, 
                            Salutation__c,User_Region__c,MailingCity,MailingCountry,MailingPostalCode, 
                            MailingState,MailingStreet,OtherCity,OtherCountry,OtherPostalCode,OtherState,OtherStreet From Contact 
                            Where Id=: objUser.ContactId LIMIT 1];
        lstCases= [Select Id,ContactId,AccountId,RecordTypeId,Email__c From Case Where AccountId=: tsAccount.Id and Email__c=: objContact.Email and (RecordTypeId=:tsRecordType.Id or RecordTypeId=:techRecordType.id)];
        if(lstCases.size()!=0)
        {
            lstAllCases= new List<Case>();
            for(Case objCase: lstcases)
            {
                objCase.contactId=objContact.id;
                objCase.accountId= objContact.AccountId;
                lstAllCases.add(objCase);
              
            }
            update lstAllCases;
        }
        
        lstAcnts= [Select Id,Name,Country__c From Account Where Recordtype.Name=: CHILD_ACCOUNT And Name!=: TS_ACCOUNT 
                   And Name!=: NXP_ACCOUNT];
        for(Account objAcnt: lstAcnts)
        {
            mapAcnts.put(objAcnt.Name, objAcnt.Country__c);
        }
        //Case 1: check email address of contacts under child account
        lstContacts=[Select Id, Email,AccountId,Account.Name,CanAllowPortalSelfReg,AssistantName,AssistantPhone,Birthdate,
                     CurrencyIsoCode,ownerId,Jigsaw,Department,Description,DoNotCall,HasOptedOutOfEmail,Fax,
                     HasOptedOutOfFax,HomePhone,LeadSource,MobilePhone,OtherPhone,ReportsToId,Title,
                     Autocreated__c,Contact_ID_Full__c,CSC_Contact__c,
                     Custom_Description__c,KeyContact__c,No_Longer_w_Company__c,NPS_Survey__c, NXP_News__c, 
                     Salutation__c,User_Region__c,MailingCity,MailingCountry,MailingPostalCode,
                     MailingState,MailingStreet,OtherCity,OtherCountry,OtherPostalCode,OtherState,OtherStreet From Contact 
                     Where AccountId IN: lstAcnts];
        
        if((lstContacts!=null) && (objContact.Email.substringafter('@')!='nxp.com') && (! publicDomainsSet.contains(objContact.Email.substringafter('@'))))
        {
            for(contact objCont: lstContacts)
            {
                if(objCont.Email!=null && objContact.Email!=null)
                {
                    if(objCont.Email==objContact.Email)
                    {
                        lstCrmContact.add(objCont);
                    }
                }
            }
            if(lstCrmContact.size()!=0)
            {
                //Case 1a: single contact with same email address then merge
                if(lstCrmContact.size()==1)
                {
                    lstAllCases= new List<Case>();
                    for(Contact objCont: lstCrmContact)
                    {
                        objContact.AccountId= objCont.AccountId;
                        
                        lstCases= [Select Id,ContactId,AccountId,RecordTypeId From Case Where (ContactId=: objContact.id or Email__c=: objContact.Email) and (RecordTypeId=:tsRecordType.Id or RecordTypeId=:techRecordType.id)];
                        if(lstCases.size()!=0)
                        {
                            
                            for(Case objCase: lstcases)
                            {
                                objCase.contactId=objContact.id;
                                objCase.accountId= objCont.AccountId;
                                lstAllCases.add(objCase);
                            }
                            
                        }
                    }
                    update objContact;
                    update lstAllCases;
                }
                //Case 1b: multiple contacts with same email address 
                else if(lstCrmContact.size()>1)
                {
                   
                    for(Contact objCrmContact: lstCrmContact)
                    {
                        String objAcnt;
                        
                        if(mapAcnts.containsKey(objCrmContact.Account.Name))
                        {
                            objAcnt=mapAcnts.get(objCrmContact.Account.Name);                          
                        }
                        //Case 1b: 1.merge if company name same as child account name
                        if(objCrmContact.Account.Name.equalsIgnoreCase(objContact.Company__c))
                        {
                            objContact.AccountId= objCrmContact.AccountId;
                            
                            isAssignByCountry= false;
                            isAssignByLastModifiedDate=false;
                            break;
                        }
                        
                        //Case 1b: 2.merge if country name same as child account name
                        else if(objAcnt!=null && objAcnt.equalsIgnoreCase(objContact.Community_web_country__c))
                        {
                            lstCrmAcntNames.add(objCrmContact.Account.Name);
                            lstContactEmails.add(objCrmContact.email);
                            isAssignByCountry= true;
                            isAssignByLastModifiedDate=false;
                            break;
                        }
                        //Case 1b: 3.merge with contact having recently modified child account
                        else
                        {
                            lstCrmAcntNames.add(objCrmContact.Account.Name);
                            isAssignByLastModifiedDate= true;
                            isAssignByCountry= false;
                        }
                    }
                    if(isAssignByLastModifiedDate==false && isAssignByCountry==false)
                    {
                    update objContact;
                    lstCases= [Select Id,ContactId,AccountId,RecordTypeId From Case Where (ContactId=: objContact.id or Email__c=: objContact.Email) and (RecordTypeId=:tsRecordType.Id or RecordTypeId=:techRecordType.id)];
                    lstAllCases= new List<Case>();
                    if(lstCases.size()!=0)
                    {
                         
                         for(Case objCase: lstcases)
                         {
                              objCase.contactId=objContact.id;
                              objCase.accountId= objContact.AccountId;
                              lstAllCases.add(objCase);
                         }
                                
                    } 
                    
                    update lstAllCases;
                    }
                    if(isAssignByLastModifiedDate==true)
                    {
                        lstCrmAcnts=[Select Id,Name,LastModifiedDate From Account Where Name IN: lstCrmAcntNames 
                                     order by LastModifiedDate DESC];
                        List<Contact> objCrmContact= [Select Id,AccountId,Name,Email,Community_web_country__c,Company__c,Assigned_Merged_from_NXP_Community__c,
                                                CanAllowPortalSelfReg,AssistantName,AssistantPhone,Birthdate,CurrencyIsoCode,ownerId,
                                                Jigsaw,Department,Description,DoNotCall,HasOptedOutOfEmail,Fax,HasOptedOutOfFax,HomePhone,
                                                LastCURequestDate,LastCUUpdateDate,LeadSource,MobilePhone,OtherPhone,ReportsToId,Title,
                                                Autocreated__c,Contact_ID_Full__c,CSC_Contact__c,
                                                Custom_Description__c,KeyContact__c,No_Longer_w_Company__c,NPS_Survey__c, NXP_News__c, 
                                                Salutation__c,User_Region__c,MailingCity,MailingCountry,MailingPostalCode, 
                                                MailingState,MailingStreet,OtherCity,OtherCountry,OtherPostalCode,OtherState,OtherStreet from Contact 
                                                where Id In:lstCrmContact and Account.Name=: lstCrmAcnts[0].Name LIMIT 1];
                        if(objCrmContact.size()!=0 && objCrmContact[0].AccountId!=null)
                        {
                         
                        objContact.AccountId= objCrmContact[0].AccountId;
                        
                        update objContact;
                        lstCases= [Select Id,ContactId,AccountId,RecordTypeId From Case Where (ContactId=: objContact.id or Email__c=: objContact.Email) and (RecordTypeId=:tsRecordType.Id or RecordTypeId=:techRecordType.id)];
                        if(lstCases.size()!=0)
                        {
                            lstAllCases= new List<Case>();
                            for(Case objCase: lstcases)
                            {
                                objCase.contactId=objContact.id;
                                objCase.accountId= objContact.AccountId;
                                lstAllCases.add(objCase);
                            }
                            update lstAllCases;
                        }
                               
                        }
                    }
                    if(isAssignByCountry==true)
                    {
                        lstCrmAcnts=[Select Id,Name,LastModifiedDate From Account Where Name IN: lstCrmAcntNames 
                                     order by LastModifiedDate DESC];
                        List<Contact> objCrmContact= [Select Id,AccountId,Name,Email,Community_web_country__c,Company__c,Assigned_Merged_from_NXP_Community__c,
                                                CanAllowPortalSelfReg,AssistantName,AssistantPhone,Birthdate,CurrencyIsoCode,ownerId,
                                                Jigsaw,Department,Description,DoNotCall,HasOptedOutOfEmail,Fax,HasOptedOutOfFax,HomePhone,
                                                LastCURequestDate,LastCUUpdateDate,LeadSource,MobilePhone,OtherPhone,ReportsToId,Title,
                                                Autocreated__c,Contact_ID_Full__c,CSC_Contact__c,
                                                Custom_Description__c,KeyContact__c,No_Longer_w_Company__c,NPS_Survey__c, NXP_News__c, 
                                                Salutation__c,User_Region__c,MailingCity,MailingCountry,MailingPostalCode, 
                                                MailingState,MailingStreet,OtherCity,OtherCountry,OtherPostalCode,OtherState,OtherStreet from Contact 
                                                where Id In:lstCrmContact and Email In:lstContactEmails 
                                                and Account.Name=: lstCrmAcnts[0].Name LIMIT 1];
                        if(objCrmContact.size()!=0 && objCrmContact[0].AccountId!=null)
                        {
                         
                        objContact.AccountId= objCrmContact[0].AccountId;
                        
                        update objContact;
                        lstCases= [Select Id,ContactId,AccountId,RecordTypeId From Case Where (ContactId=: objContact.id or Email__c=: objContact.Email) and (RecordTypeId=:tsRecordType.Id or RecordTypeId=:techRecordType.id)];
                        if(lstCases.size()!=0)
                        {
                            lstAllCases= new List<Case>();
                            for(Case objCase: lstcases)
                            {
                                objCase.contactId=objContact.id;
                                objCase.accountId= objContact.AccountId;
                                lstAllCases.add(objCase);
                            }
                            update lstAllCases;
                        }
                        }
                    }
                }
            }
            
            //Case 2: check email domain of contacts under child account
            else if(lstContacts!=null)
            {
                for(contact objCont: lstContacts)
                {
                    if(objCont.Email!=null && objContact.Email!=null)
                    {
                        if(objCont.Email.substringafter('@').equalsIgnoreCase(objContact.Email.substringafter('@')))
                        {
                            lstCrmContact.add(objCont);
                        }
                    }
                    
                }
                if(lstCrmContact.size()!=0)
                {
                    //Case 2a: single contact with same email domain then assign
                    if(lstCrmContact.size()==1)
                    {
                        lstAllCases= new List<Case>();
                        for(Contact objCont: lstCrmContact)
                        {
                            objContact.AccountId= objCont.AccountId;
                            objContact.Assigned_Merged_from_NXP_Community__c='Assigned';
                            
                            lstCases= [Select Id,ContactId,AccountId,RecordTypeId From Case Where (ContactId=: objContact.id or Email__c=: objContact.Email) and (RecordTypeId=:tsRecordType.Id or RecordTypeId=:techRecordType.id)];
                            if(lstCases.size()!=0)
                            {
                                
                                for(Case objCase: lstcases)
                                {
                                    objCase.contactId=objContact.id;
                                    objCase.accountId= objCont.AccountId;
                                    lstAllCases.add(objCase);
                                }
                                
                            }
                        }
                        update objContact;
                        update lstAllCases;
                    }
                    //Case 2b: multiple contacts with same email domain 
                    else if(lstCrmContact.size()>1)
                    {
                        String strObjContactId;
                        String strObjContactAcntId;
                        for(Contact objCrmContact: lstCrmContact)
                        {
                            String objAcnt;
                            if(mapAcnts.containsKey(objCrmContact.Account.Name))
                            {
                                objAcnt=mapAcnts.get(objCrmContact.Account.Name);                          
                            }
                            //Case 2b: 1.assign if company name same as child account name
                            if(objCrmContact.Account.Name.equalsIgnoreCase(objContact.Company__c))
                            {
                                objContact.AccountId= objCrmContact.AccountId;
                                
                                objContact.Assigned_Merged_from_NXP_Community__c='Assigned';
                                isAssignByCountry= false;
                                isAssignByLastModifiedDate=false;
                                
                                
                                break;
                            }
                            //Case 2b: 2.assign if country name same as child account name
                            else if(objAcnt!=null && objAcnt.equalsIgnoreCase(objContact.Community_web_country__c))
                            {
                                lstCrmAcntNames.add(objCrmContact.Account.Name);
                                lstContactEmails.add(objCrmContact.email);
                                isAssignByCountry= true;
                                isAssignByLastModifiedDate=false;
                            }
                            //Case 2b: 3.assign recently modified child account
                            else
                            {
                                lstCrmAcntNames.add(objCrmContact.Account.Name);
                                isAssignByLastModifiedDate= true; 
                                isAssignByCountry= false;
                            }
                        }
                        if(isAssignByLastModifiedDate==false && isAssignByCountry==false)
                        {
                        update objContact;
                        lstCases= [Select Id,ContactId,AccountId,RecordTypeId From Case Where (ContactId=: objContact.id or Email__c=: objContact.Email) and (RecordTypeId=:tsRecordType.Id or RecordTypeId=:techRecordType.id)];
                        lstAllCases= new List<Case>();
                        if(lstCases.size()!=0)
                        {
                            
                            for(Case objCase: lstcases)
                            {
                                objCase.contactId=objContact.id;
                                objCase.accountId= objContact.AccountId;
                                lstAllCases.add(objCase);
                            }
                                
                        }
                        update lstAllCases;
                        }
                        if(isAssignByLastModifiedDate==true)
                        {
                            
                            lstCrmAcnts=[Select Id,Name,LastModifiedDate From Account Where Name IN: lstCrmAcntNames 
                                         order by LastModifiedDate DESC];
                            List<Contact> objCrmContact= [Select Id,Name,AccountId,Account.Name,email from Contact 
                                                    where Id In:lstCrmContact and Account.Name=: lstCrmAcnts[0].Name LIMIT 1];
                            if(objCrmContact.size()!=0 && objCrmContact[0].AccountId!=null)
                            {
                         
                            objContact.AccountId= objCrmContact[0].AccountId;
                            objContact.Assigned_Merged_from_NXP_Community__c='Assigned';
                            update objContact;
                            
                            lstCases= [Select Id,ContactId,AccountId,RecordTypeId From Case Where (ContactId=: objContact.id or Email__c=: objContact.Email) and (RecordTypeId=:tsRecordType.Id or RecordTypeId=:techRecordType.id)];
                            
                            if(lstCases.size()!=0)
                            {
                                
                                lstAllCases= new List<Case>();
                                for(Case objCase: lstcases)
                                {
                                    objCase.contactId=objContact.id;
                                    objCase.accountId= objContact.AccountId;
                                    lstAllCases.add(objCase);
                                }
                                update lstAllCases;
                            }
                            }
                        }
                        if(isAssignByCountry==true)
                        {
                            lstCrmAcnts=[Select Id,Name,LastModifiedDate From Account Where Name IN: lstCrmAcntNames 
                                         order by LastModifiedDate DESC];
                            List<Contact> objCrmContact= [Select Id,Name,AccountId,Account.Name,email from Contact 
                                                    where Id In:lstCrmContact and Email In:lstContactEmails 
                                                    and Account.Name=: lstCrmAcnts[0].Name LIMIT 1];
                            if(objCrmContact.size()!=0 && objCrmContact[0].AccountId!=null)
                            {
                         
                            objContact.AccountId= objCrmContact[0].AccountId;
                            objContact.Assigned_Merged_from_NXP_Community__c='Assigned';
                            update objContact;
                            lstCases= [Select Id,ContactId,AccountId,RecordTypeId From Case Where (ContactId=: objContact.id or Email__c=: objContact.Email) and (RecordTypeId=:tsRecordType.Id or RecordTypeId=:techRecordType.id)];
                            if(lstCases.size()!=0)
                            {
                                lstAllCases= new List<Case>();
                                for(Case objCase: lstcases)
                                {
                                    objCase.contactId=objContact.id;
                                    objCase.accountId= objContact.AccountId;
                                    lstAllCases.add(objCase);
                                }
                                update lstAllCases;
                            }
                            }
                        }
                    }  
                }
            }
        }                 
    }

     */
    //method to redirect to login page
    public PageReference SignInPage()
    {      
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        String communityLoginUrl= cs.CommunityLoginUrl__c;   
        PageReference page = new PageReference(communityLoginUrl);
        page.setRedirect(true);
        return page;
    } 
     
    
}