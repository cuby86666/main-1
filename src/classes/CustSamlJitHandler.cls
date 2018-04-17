//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class CustSamlJitHandler implements Auth.SamlJitHandler {
    private static final String s_communityName = 'NXP Community';

    private class JitException extends Exception{}

    private void handleUser(boolean create, User u, String contactId, Map<String, String> attributes,
        String federationIdentifier) {

        if(attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        } 
        System.debug('Email:' + u.Email);
        
        if(attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
        }
        System.debug('FirstName: ' + u.FirstName);
        
        if(attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        }
        System.debug('LastName: ' + u.LastName);

        if(attributes.containsKey('User.CompanyName')) {
            u.CompanyName = attributes.get('User.CompanyName');
        }
        System.debug('CompanyName: ' + u.CompanyName);
        
        if(attributes.containsKey('User.Country')) {
            u.Country = attributes.get('User.Country');
        }
        System.debug('Country: ' + u.Country);  

        if(create){
            System.debug('handleUser: CREATE USER LOGIC');
          if(attributes.containsKey('User.Email')) {
                u.Username = attributes.get('User.Email');
            }
            System.debug('Username: ' + u.Username);
            
            if(federationIdentifier != null && federationIdentifier.trim().length()>0) {
                u.FederationIdentifier = federationIdentifier;
            }
            System.debug('FederationIdentifier: ' + u.FederationIdentifier);

            u.CommunityNickname = createNickName(u.FirstName, u.LastName, u.FederationIdentifier);
            System.debug('CommunityNickname: ' + u.CommunityNickname);

            u.Alias = createAlias(attributes, u);
            System.debug('Alias: ' + u.Alias);
            
            u.EmailEncodingkey='ISO-8859-1';
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey='en_US';
            u.TimeZoneSidKey='GMT';
        }
        else
        {
            System.debug('handleUser: UPDATE USER LOGIC');
            if(u.FederationIdentifier == null || u.FederationIdentifier.trim().equals(''))
            {
                if(federationIdentifier != null && federationIdentifier.trim().length()>0) {
                    System.debug('Updated empty user federation id to: '+federationIdentifier);
                    u.FederationIdentifier = federationIdentifier;  
                }
            }
            if(u.CommunityNickname == null || u.CommunityNickname.trim().equals(''))
            {
                u.CommunityNickname = createNickName(u.FirstName, u.LastName, u.FederationIdentifier);
            }
            if(u.Alias == null || u.Alias.trim().equals(''))
            {
                u.Alias = createAlias(attributes, u);
            }
        }
        /*
         * If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
         * If your identity provider sends these User fields as attributes along with Contact 
         * or Account fields, you must modify the logic in this class to update either these 
         * User fields or the Contact and Account fields.
         * 
         * IsActive, ForecastEnabled, ProfileId, UserRoleId
         */
        //'NXP community' account and 'NXP Customer Community Login User' profile
        CommunitySettings__c cs = CommunitySettings__c.getValues('CommunityUrl');
        String cs_accountId= cs.CommunityUserAccountId__c; 
        String cs_profileId= cs.CommunityUserProfileId__c;
        String cs_employeeProfileId = cs.CommunityEmployeeProfileId__c;
        
        if(create) // only set profile for new users
        {
            if(u.Email!=null && (u.Email.tolowercase().contains('freescale.com') || u.Email.tolowercase().contains('nxp.com') ))
            {
                u.ProfileId = cs_employeeProfileId ;
            }
            else
            {
                u.ProfileId = cs_profileId;
            }
            System.debug('ProfileId: ' + u.ProfileId);
        }

        //Handle custom fields here
        if(create) {
            u.ContactId = contactId;
        }
        else
        {
            update(u);
        }
        System.debug('ContactId: ' + u.ContactId);
       
    }
    
    private String handleContact(boolean create, String accountId, User u11, Map<String, String> attributes) {
    
        System.debug('Inside handleContact');
        System.debug('Inside handleContact: attributes ' + attributes);
        System.debug('Inside handleContact: accountId ' + accountId);
        System.debug('Inside handleContact: usrObj ' + u11);
        
        Contact c=null;
        boolean newContact = false;

        String contactId= u11.ContactId;
        if(contactId == null)
        {
            //if no contact provided, then check if a contact exist by email
            if(attributes.containsKey('User.Email')) 
            {
                String contactEmail = attributes.get('User.Email');
                Contact[] ca = [select id, accountId from contact where email=:contactEmail order by LastModifiedDate DESC];
                if(ca.size()>0)
                {
                    c = ca[0];
                    newContact = false;
                }
            }
        }
        else
        {
            c = [SELECT Id, AccountId FROM Contact WHERE Id=:contactId];
            newContact = false;
        }
      
        if(c==null)
        {
            c = new Contact();
            newContact = true;
        }
        
    /*    if(!newContact && c.AccountId != accountId) {
            throw new JitException('Mismatched account: ' + c.AccountId + ', ' + accountId);
        }*/

        if(attributes.containsKey('User.Email')) {
            c.Email = attributes.get('User.Email');
        }
        if(attributes.containsKey('User.FirstName')) {
            c.FirstName = attributes.get('User.FirstName');
        }
        if(attributes.containsKey('User.LastName')) {
            c.LastName = attributes.get('User.LastName');
        }
        if(attributes.containsKey('User.CompanyName')) {
            c.Company__c = attributes.get('User.CompanyName');
        }
        if(attributes.containsKey('User.Country')) {
            c.Community_web_country__c = attributes.get('User.Country');
        }
        //set active community user flag as true
        c.Is_Active_Community_User__c = true;
        //set new checkbox to false here
        c.Not_Found_In_Marketing__c = false;
        if(newContact) {
            c.AccountId = accountId;
            System.debug('Account Id in HandleContact method: '+ accountId);
            System.debug('INSERTING new CONTACT: '+ c);
            try{
                 insert(c);
                } catch(Exception e)
                {
                    System.debug('EXCEPTION WHILE INSERTING CONTACT: ' + e.getMessage());
                }
         } else {
           System.debug('UPDATING CONTACT: '+ c.id);
           update(c);
        }

         System.debug('Inside handleContact: returning ' + c.Id);
         return c.Id;
    }

    private String handleAccount() {
        Account a;
         a = [SELECT Id,  name, AccountNumber FROM Account WHERE name=:s_communityName ];
         System.debug('Inside handleAccount, found acctObj: ' + a);
        return a.Id;
    }

    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        String accountId = handleAccount();
        String contactId = handleContact(create, accountId, u, attributes);
        handleUser(create, u, contactId, attributes, federationIdentifier);

    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        String email = null;
        
        for (String key : attributes.keySet())
        {
             System.debug('Attribute ' + key + ' : ' + attributes.get(key));
        }
    
        if(attributes.containsKey('User.Email')) 
        {
            email = attributes.get('User.Email');
        }

        User user = new User();
        boolean createUser = true;
        
        //check if user already exist. first check by federation id, if not found then check by email
        User[] ua = [SELECT Id, name, alias, email, CommunityNickname, FederationIdentifier, AccountId, ContactId FROM User WHERE federationidentifier=:federationIdentifier];
        if(ua.size()>0)
        {    
            System.debug('FOUND USER BY FEDERATION ID');
            createUser = false;
            user = ua[0];
        }
        else
        {
            if(email != null) 
            {
                //check by username instead of email as username should be an email and always unique
                ua = [SELECT Id, name, alias, email, CommunityNickname, FederationIdentifier, AccountId, ContactId FROM User WHERE username=:email];
                if(ua.size()>0)
                {
                    System.debug('FOUND USER BY USERNAME');
                    createUser = false;
                    user = ua[0];
                }
                else
                {
                    System.debug('USER NOT FOUND BY EITHER FEDERATION ID OR USERNAME');
                }
            }
            else
            {
                System.debug('User.Email attribute not provided');
            }
        }

        System.debug('User contact id: ' + user.ContactId);
        handleJit(createUser, user, samlSsoProviderId, portalId, federationIdentifier, attributes, assertion);
        System.debug('Returning userObj from createUser Method: ' + user);
       
        return user;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        for (String key: attributes.keySet())
        {
            System.debug('Attribute ' + key + ' : ' + attributes.get(key));
        }
        
        if(attributes.containsKey('User.Email')) 
        { 
            String email = attributes.get('User.Email');
        }
        
        System.debug('INSIDE updateUser METHOD');
        System.debug('userId: ' + userId);
        System.debug('samlSsoProviderId: ' + samlSsoProviderId);
        System.debug('communityId: ' + communityId);
        System.debug('portalId: ' + portalId);
        System.debug('federationIdentifier: ' + federationIdentifier);
        
        User u = [SELECT Id, name, alias, email, CommunityNickname, FederationIdentifier, AccountId, ContactId  FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, portalId,
        federationIdentifier, attributes, assertion);
    }
    
    private String createNickName(String firstName, String lastName, String federationId)
    {
        System.debug('createNickName method');
        System.debug('firstName: ' + firstName);
        System.debug('lastName: ' + lastName);
        System.debug('federationId: ' + federationId);
        
        List<String> checkNickNameList = new List<String>();
        checkNickNameList.add(firstName.substring(0,1) + lastName); //JSmith
        checkNickNameList.add(lastname + firstName.substring(0,1)); //SmithJ
        checkNickNameList.add(firstName + lastName.substring(0,1)); //JohnS
        if(lastName.length()>1)
        { 
            checkNickNameList.add(firstName + lastName.substring(0,2)); //JohnSm 
        }
        if(lastName.length()>2)
        {      
            checkNickNameList.add(firstName + lastName.substring(0,3)); //JohnSmi
        }
        checkNickNameList.add(firstName + federationId.substring(2,5).toUppercase()); //JohnDX586
        checkNickNameList.add(firstName + federationId.substring(3,5).toUppercase()); //JohnX586F
                        
        boolean isGood = false;
        String selectedNickName = '';
        
        for(String nickName : checkNickNameList)
        {
            User[] ua = [SELECT id, CommunityNickname FROM User WHERE CommunityNickname=:nickName];
            if(ua.size()==0)
            {
                isGood = true;
                selectedNickName = nickName;
                break;
            }
        }
        System.debug('Selected Nickname: ' + (isGood ? selectedNickName : 'NONE SELECTED'));
        return selectedNickName;
    }
    
    private String createAlias(Map<String, String> attributes, User u)
    {
        String alias = '';
         if(attributes.containsKey('User.Alias')) {
            alias = attributes.get('User.Alias');
        } else {
        //Alias limit of 8 chars. Does not have to be unique.
            if(u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.substring(0,1) + u.LastName;
            }
            if(alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
        }
        
        System.debug('Alias: ' + alias);
        return alias;
    }

}