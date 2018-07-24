/*************************************************************************
@Created By:     Jewelslyn
@Description:    class for Lead Trigger to update the country ,state, region based on Lead country Settings.
------------------------------------------------------------------------------------
@Modified By:     Jewelslyn
@Modified Date:   22 Sep 2017
@Description:    Modified class to include random Token generation and to update the Disti contact
if disti contact is not same as Disti feedback email provided Disti feedback email exists in sfdc.
----------------------------------------------------------------------------------
@Modified By:     Jewelslyn
@Modified Date:   4 Dec 2017
@Description:    Modified trigger to include Sending emails to multiple distis
-------------------------------------------------------------------------------
@Modified By:    Nisha Agrawal
@Modified Date:  Jun 20, 2017
@Description:    Modified to include method to share lead records with Disti User (Lead Portal)
***************************************************************************************************/

public class LeadTriggerHandler {
    Private Static Final string TMMA_LEAD='TMMA Leads';
    private Static Final string ROM_LEAD='ROM Leads';
    public static map<string,string> mapCountryCodeToName;
    public static map<string,string> mapStateCodeToState;
    public static map<string,string> mapCountryToRegion;    
    public static boolean recursionCheck=true;
    public static void assignCountryNames(List<Lead> listNewLeads){
        list<LeadCountrySettings__c> lstLeadCountrySettings=[select id,Country__c,country_Code__c,State__c,Region__c,State_Code__c 
                                                             from LeadCountrySettings__c];
        mapCountryCodeToName=new map<string,string>();
        mapStateCodeToState=new map<string,string>(); 
        mapCountryToRegion=new map<string,string>();
        for(LeadCountrySettings__c settings:lstLeadCountrySettings){            
            if(settings.Country__c !=null && settings.country_Code__c!=null){
                if(!mapCountryCodeToName.containskey(settings.country_Code__c.toUpperCase())){
                    mapCountryCodeToName.put(settings.country_Code__c.toUpperCase(),settings.Country__c);
                }
            }
            if(settings.State__c !=null && settings.state_Code__c!=null){
                if(!mapStateCodeToState.containskey(settings.state_Code__c.toUpperCase())){
                    mapStateCodeToState.put(settings.state_Code__c.toUpperCase(),settings.State__c);
                }
            }
            if(settings.Region__c!=null && settings.country_Code__c !=null){
                if(!mapCountryToRegion.containskey(settings.country_Code__c.toUpperCase())){
                    mapCountryToRegion.put(settings.country_Code__c.toUpperCase(),settings.Region__c);
                }
            }
                system.debug('settRe:'+mapCountryToRegion);
        }
        for(lead ld:listNewLeads){
             ld.Region__c=null;           
            if(ld.country!=null){
                if(mapCountryToRegion.containsKey(ld.country.toUpperCase())){
                    system.debug('settRe1:'+mapCountryToRegion);
                    if(mapCountryToRegion.get(ld.country.toUpperCase()) !=null){
                        ld.Region__c=mapCountryToRegion.get(ld.country.toUpperCase());                    
                    }
                }   
                if(mapCountryCodeToName.containsKey(ld.country.toUpperCase())){   
                    if(mapCountryCodeToName.get(ld.country.toUpperCase()) !=null){
                        ld.country=mapCountryCodeToName.get(ld.country.toUpperCase());
                    }                    
                }                                                                
            }
            if(ld.State!=null){
               if(mapStateCodeToState.containskey(ld.State.toUpperCase()) && mapStateCodeToState.get(ld.State.toUpperCase()) !=null){                    
                   ld.State=mapStateCodeToState.get(ld.State.toUpperCase()); 
                } 
            }
            
        }        
    }
    public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
         return randStr; 
    }
    
    public static void assignRandomString(list<Lead> listLeads){
        for(lead ld:listLeads){
            ld.Token_Id__c=generateRandomString(8);
            system.debug('token::'+ld.Token_Id__c);
        }        
    }
    
   /* public static void distContactUpdate(list<lead> listDistiContactUpdateLds){
        set<string> strDistiFeedEmail=new set<string>();
        list<contact> listContact;
        map<id,string> mapLeadIdToDistiEmail=new map<id,string>();
        map<id,string> mapLeadIdToDistiFeedEmail=new map<id,string>();
        map<string,contact> mapConEmailToContact=new map<string,contact>();
        for(lead ld:listDistiContactUpdateLds){
            if(ld.Disti_Feedback_Email_Address__c!=null){
                strDistiFeedEmail.add(ld.Disti_Feedback_Email_Address__c);
            }
            if(!mapLeadIdToDistiEmail.containskey(ld.Id)){
               mapLeadIdToDistiEmail.put(ld.Id,ld.Distributor_Contact__r.email); 
            }
            if(!mapLeadIdToDistiFeedEmail.containskey(ld.Id)){
               mapLeadIdToDistiFeedEmail.put(ld.Id,ld.Disti_Feedback_Email_Address__c); 
            }
        }
        listContact=[Select Id, email,accountId from Contact where email In:strDistiFeedEmail];
        for(contact con:listContact){
            if(!mapConEmailToContact.containskey(con.Email)){
                mapConEmailToContact.put(con.Email,con);
                system.debug('Contactnew::'+mapConEmailToContact);
            }
        }
        for(lead ld:listDistiContactUpdateLds){
            if(mapLeadIdToDistiEmail.containskey(ld.Id) && mapLeadIdToDistiFeedEmail.containskey(ld.Id)){
                if(mapLeadIdToDistiEmail.get(ld.Id) != mapLeadIdToDistiFeedEmail.get(ld.Id) &&
                  mapConEmailToContact.containskey(mapLeadIdToDistiFeedEmail.get(ld.Id))){
                    ld.Distributor_Contact__c=mapConEmailToContact.get(mapLeadIdToDistiFeedEmail.get(ld.Id)).Id;
                }
            }
              
        }
    }*/
    public static void insertContactRoles(list<lead> listConvertedLeads){        
        set<string> setOppConIdExists=new set<string>();
        set<string> setOppIds=new Set<string>();
        map<string, opportunityContactRole> mapOppConRole=new map<string, opportunityContactRole>();
        string oppConId;
        for(lead ld:listConvertedLeads){            
            oppConId=ld.ConvertedOpportunityId +'*'+ ld.ConvertedContactId;         
            if(!mapOppConRole.containskey(oppConId)){
                mapOppConRole.put(oppConId,new OpportunityContactRole(opportunityId=ld.ConvertedOpportunityId,ContactId=
                                                                 ld.ConvertedContactId));
            }            
            setOppIds.add(ld.ConvertedOpportunityId);
        }
        list<opportunityContactRole> listOppConRole=[select id,opportunityId, ContactId from OpportunityContactRole
                                                    where OpportunityId IN:setOppIds];
        for(opportunityContactRole oppcon:listOppConRole){
            string oppConIdExists=oppcon.opportunityId +'*'+ oppcon.ContactId;            
            if(mapOppConRole.containskey(oppConIdExists)){
                mapOppConRole.remove(oppConIdExists);                
            }                        
        }
        if(!mapOppConRole.isEmpty()){
          Database.insert(mapOppConRole.values());       
        }               
    }
    public static void emailToMultipleDistis(list<lead> listLeads){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();        
        set<string> distiEmail=new set<string>();
        set<string> ownerEmail=new set<string>();        
        string distEmailAdd;
        string[] toaddress = New String[]{};
        string[] CcEmails = New String[]{};        
        string[] novaSilvaEmail = New String[]{};             
        for(lead ld:listLeads){
            if(ld.Distributor_Contact__c !=null){
                distiEmail.add(ld.Distributor_Contact__c);
                system.debug('disticon::'+ld.Distributor_Contact__c);
            }
            ownerEmail.add(ld.OwnerId);            
        }
        list<contact> listCon=[select id,email from contact where id IN:distiEmail];
        list<user> listUser=[select id, email from user where Id In:ownerEmail];
        map<id,string> mapConIdToDistiEmail=new map<id,string>();
        map<id,string> mapUserIdToEmail=new map<id,string>();
        for(contact con:listCon){
            if(!mapConIdToDistiEmail.containskey(con.Id)){
                mapConIdToDistiEmail.put(con.Id,con.email);
            }
        }
        for(user u:listUser){
            if(!mapUserIdToEmail.containskey(u.Id)){
                mapUserIdToEmail.put(u.Id,u.email);
            }
        }
        /*LeadCountrySettings__c leadSettings = LeadCountrySettings__c.getValues('NovaSilva');
        if(leadSettings !=null){
            novaSilvaEmail.add(leadSettings.NovaSilva_Email__c);
            system.debug('bccadd1::'+novaSilvaEmail);
        }*/
        string novaSilvaLabel=string.valueOf(System.Label.NovaSilva_Email);
                                     if(novaSilvaLabel !=null){
                                         novaSilvaEmail.add(novasilvaLabel); 
                                     }
        EmailTemplate emailTemp=[select id from EmailTemplate where DeveloperName='Contact_Details_of_Lead_to_Disti_V0'];        
        for(lead ld:listLeads){                                                
            Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
            system.debug('sendemail::'+sendEmail);
            if(ld.CC_Address__c !=null){
                 CcEmails = ld.CC_Address__c.split(';');
            }                               
            if(mapConIdToDistiEmail.containskey(ld.Distributor_Contact__c) && 
               mapUserIdToEmail.containskey(ld.OwnerId)){
                   toaddress = New String[] {mapConIdToDistiEmail.get(ld.Distributor_Contact__c),
                       mapUserIdToEmail.get(ld.OwnerId)};
               }                                    
                sendEmail.setToAddresses(toaddress);
            	system.debug('ccadd::'+CcEmails);
                sendEmail.setCCAddresses(CCEmails);
            	system.debug('bccadd::'+novaSilvaEmail);
                sendEmail.setBccAddresses(novaSilvaEmail);              
                sendEmail.setTemplateID(emailTemp.Id);           	 	
                sendEmail.setTargetObjectId(ld.Distributor_Contact__c);
                sendEmail.setWhatId(ld.Id);
                sendEmail.setSaveAsActivity(false);
                emails.add(sendEmail);                      
        }
        if (emails != NULL && emails.size() > 0)
        {
            try{
               Messaging.sendEmail(emails);
                recursionCheck=false;
            }
            catch(exception e){
                for(lead ld:listLeads){
                    ld.addError('Please enter Valid email Address seperated by ;');
                }
                
            }
            
        }                                    
    }
    
   //Method added by Nisha Agrawal on Jun 20, 2018 to share Lead access to Disti Users
    public static void shareLeadRecordsToLPUsers(List<Lead> newLeadList, Map<Id, Lead> oldLeadMap)
    {
        if(newLeadList != null && newLeadList.size() > 0 && oldLeadMap != null && oldLeadMap.size() > 0)
        {
            Lead oldLead;            
            Map<Id, Id> mapLeadToAssignedContacts = new Map<Id, Id>(); //Map of lead to assigned contacts
            Map<Id, Id> mapLeadToOldContacts = new Map<Id, Id>(); //Map of lead to previously assigned contacts
            Map<Id, String> mapLeadToRegions = new Map<Id, String>();            
            
            for(Lead objLead : newLeadList)
            {
                oldLead = oldLeadMap.get(objLead.Id); 
                //check if Distributor Contact field changed
                if(objLead.Distributor_Contact__c != null && objLead.Distributor_Contact__c != oldLead.Distributor_Contact__c)
                {
                    //Add the region to the set
                    mapLeadToRegions.put(objLead.Id, objLead.Region__c);
                                        
                    mapLeadToAssignedContacts.put(objLead.Id, objLead.Distributor_Contact__c);                    
                     
                    if(oldLead.Distributor_Contact__c != null)
                    {
                        mapLeadToOldContacts.put(objLead.Id, oldLead.Distributor_Contact__c);
                    }
                }
            }
            
            //To share with other contacts in that region for that disti               
            Map<Id, Id> mapContactToAccountId = new Map<Id, Id>();                
            for(Contact objContact : [Select Id, AccountId From Contact Where Id in :mapLeadToAssignedContacts.values() or Id in : mapLeadToOldContacts.values()])
            {
                mapContactToAccountId.put(objContact.Id, objContact.AccountId);
            }
            
            //Get the list of all contacts in lead region for assigned distributor account
            List<Contact> lstOtherContactsForAssignedDisti = [Select Id, AccountId, User_Region__c From Contact 
                                                              Where AccountId in :mapContactToAccountId.values() ];
            
            Map<Id, List<Contact>> mapAccountToContacts = new Map<Id, List<Contact>>();
                
            for(Contact objContact : lstOtherContactsForAssignedDisti)
            {
                if(mapAccountToContacts.containsKey(objContact.AccountId))
                {
                    mapAccountToContacts.get(objContact.AccountId).add(objContact);
                }
                else
                {
                    mapAccountToContacts.put(objContact.AccountId, new List<Contact>{objContact});
                }
            }            
            
            String leadRegion;           
            Map<Id , Set<Id>> mapLeadToOtherContacts = new Map<Id, Set<Id>>();  //map of Lead to set of ContactIds for other contacts 
            Map<Id, Set<Id>> mapLeadToContactsToRevokeAccess = new Map<Id, Set<Id>>(); //map of lead to set of contactIds to revoke access 
            Set<Id> contactIdsToFetchUsers = new Set<Id>();
            
            //Loop to create linking between leads to other contacts from assigned disti for same region
            for(Id leadId : mapLeadToAssignedContacts.keySet())
            {  
                leadRegion = (mapLeadToRegions.containsKey(leadId) ? mapLeadToRegions.get(leadId) : '');
                Id accountAssignedToLead = mapContactToAccountId.get(mapLeadToAssignedContacts.get(leadId));
                Id oldContactId;
                Id oldAccountId;
                
                //revoke the access for previously assigned contact, if its reassigned to different disti                                                
                if(mapLeadToOldContacts.containsKey(leadId)) //check if reassignment scenario
                {
                    oldContactId = mapLeadToOldContacts.get(leadId);
                    oldAccountId = mapContactToAccountId.get(oldContactId);
                    
                    if(oldAccountId == accountAssignedToLead)  //assigned to different contact in same disti
                    {                        
                       //TODO : for feed comment 
                    }
                    else
                    {
                        //different disti so revoke the access for previous assignee
                        Set<Id> otherContactsToRevoke = new Set<Id>();
                        //check for all other contacts from same disti
                        for(Contact objContact : mapAccountToContacts.get(oldAccountId))
                        {
                            otherContactsToRevoke.add(objContact.Id);
                        }
                        
                        mapLeadToContactsToRevokeAccess.put(leadId, new Set<Id>{oldContactId});
                    	mapLeadToContactsToRevokeAccess.get(leadId).addAll(otherContactsToRevoke);
                        
                        contactIdsToFetchUsers.add(oldContactId);
                        contactIdsToFetchUsers.addAll(otherContactsToRevoke);
                    }
                }
                
                //for finding new contacts from new assignee
                if(mapAccountToContacts.containsKey(accountAssignedToLead))
                {
                    Set<Id> otherContactsToAssign = new Set<Id>();
                    
                    for(Contact objContact : mapAccountToContacts.get(accountAssignedToLead))
                    {
                        if(objContact.AccountId == accountAssignedToLead && (leadRegion != null && objContact.User_Region__c != null && objContact.User_Region__c.toLowerCase() == leadRegion.toLowerCase()))
                        {
                            otherContactsToAssign.add(objContact.Id);
                        }
                    }
                    
					
                    contactIdsToFetchUsers.addAll(otherContactsToAssign);
                    
                    //remove previous assignee from other Contact's for this lead for reassignment scenario
                    if(oldContactId != null && otherContactsToAssign.contains(oldContactId))
                    {
						otherContactsToAssign.remove(oldContactId);
                    }
                    
                    mapLeadToOtherContacts.put(leadId, otherContactsToAssign);
                } 
            }                
            
            //create a combined set of contact Ids for which we have to fecth community users
            //It already have all the contacts to revoke and other contacts for asignment
            contactIdsToFetchUsers.addAll(mapLeadToAssignedContacts.values());
            
            //ensure that we have profile id value
            if(LeadPortalLib.LP_EXTERNAL_PROFILE_Id == null)
            {
                LeadPortalLib.getExternalUserProfile();
            }
            //check if active community users associated for the contacts and create a map of contact to user
            Map<Id, User> mapContactToUsers = new Map<Id, User>();
                
            for(User objUser : [Select Id, Disti_Lead_Portal_User_Role__c, ContactId From User 
                                Where IsActive = true and IsPortalEnabled = true and 
                                ProfileId =: LeadPortalLib.LP_EXTERNAL_PROFILE_Id and
                                ContactId in: contactIdsToFetchUsers])
            {
                mapContactToUsers.put(objUser.ContactId, objUser);
            }
            
            //Lets revoke the access for old assignees (if any)
            Map<Id, Set<Id>> mapLeadToUsersToRevokeAccess = new Map<Id, Set<Id>>();
            for(Id leadId : mapLeadToContactsToRevokeAccess.keySet())
            {
                for(Id contactId : mapLeadToContactsToRevokeAccess.get(leadId))
                {
                    if(mapContactToUsers.containsKey(contactId))
                    {
                        Id userId = mapContactToUsers.get(contactId).Id;
                        if(mapLeadToUsersToRevokeAccess.containsKey(leadId))        
                        {
                            mapLeadToUsersToRevokeAccess.get(leadId).add(userId);
                        }
                        else
                        {
                            mapLeadToUsersToRevokeAccess.put(leadId, new Set<Id>{userId});
                        }
                    }
                }
            }
            
            //TODO: Error Handling part
            LeadPortalLib.revokeLeadAccessFromUsers(mapLeadToUsersToRevokeAccess, null);
            
            //Lead Sharing record creation code begins here
            List<LeadPortalLib.CustomLeadShare> lstShares = new List<LeadPortalLib.CustomLeadShare>();
                
            //scenario 1-  User is assigned as Disti Contact
            for(Id leadId : mapLeadToAssignedContacts.keySet())
            { 
                Id assignedContactId = mapLeadToAssignedContacts.get(leadId);
                
                //check if partner user exists
                if(mapContactToUsers.containsKey(assignedContactId))
                {
                    lstShares.add(new LeadPortalLib.CustomLeadShare(leadId, mapContactToUsers.get(assignedContactId).Id, LeadPortalLib.ACCESS_TYPE.Edit));
                    
                    //remove this contact for this lead from other contacts list
                    if(mapLeadToOtherContacts.containsKey(leadId))
                    {
                        mapLeadToOtherContacts.get(leadId).remove(assignedContactId);
                    }
                }
            }
            //scenario 2-  Other Users from same region for that Disti          
            for(Id leadId : mapLeadToOtherContacts.keySet())
            {
                for(Id contactId : mapLeadToOtherContacts.get(leadId))
                {
                    //check if partner user exists
                    if(mapContactToUsers.containsKey(contactId))  
                    {
                        User objUser = mapContactToUsers.get(contactId);
                        LeadPortalLib.ACCESS_TYPE leadAccess = (objUser.Disti_Lead_Portal_User_Role__c == LeadPortalLib.PORTAL_ROLE_REGIONAL 
                                                                ? LeadPortalLib.ACCESS_TYPE.Edit :  LeadPortalLib.ACCESS_TYPE.Read);
                    
                        lstShares.add(new LeadPortalLib.CustomLeadShare(leadId, objUser.Id, leadAccess));
                    }
                }
            }
            
            //TODO : Error Handling part
            //create sharing records
            LeadPortalLib.shareLeadAccessToUsers(lstShares);
            
            //Lead Sharing record creation code ends here
        }
    }
    
       /* public static void assignNewDistiFromQueue(List<Lead> distiExpiredLeads){
        List<Id> modifiedLeadIds=new List<Id>();
        for(Lead ld:distiExpiredLeads){
            modifiedLeadIds.add(ld.Id);
        }
        List<Distributor_Lead_Tracker__c> modifiedDLT = new List<Distributor_Lead_Tracker__c>();
        //find assigned disti contacts and expire them
        List<Distributor_Lead_Tracker__c> assignedDistis = [SELECT Id,Status__c from Distributor_Lead_Tracker__c where (Status__c='Assigned' OR Status__c='Queued') and Lead_Id__c in:modifiedLeadIds];
        for(Distributor_Lead_Tracker__c dlt: assignedDistis){
            if(dlt.Status__c == 'Assigned'){
                dlt.Status__c= 'Expired';    
            }else{
                dlt.Status__c= 'Assigned';    
            } 
            modifiedDLT.add(dlt);
        }
        update modifiedDLT;
        
        
    }*/
    
       /*public static void rejectedleadswithreason(List<Lead> rejectedLeads){
         Map<Id,String > mapOfleadrejreason = new Map<Id,String>();
         Map<Id,String > mapOfleadstatus = new Map<Id,String>();
        List<Id> modifiedLeadIds=new List<Id>();
        for(Lead ld:rejectedLeads){
            mapOfleadrejreason.put(ld.Id,ld.Rejection_Reason__c );
            mapOfleadstatus.put(ld.Id,ld.Status);
            modifiedLeadIds.add(ld.Id);
        }
        List<Distributor_Lead_Tracker__c> modifiedDLT = new List<Distributor_Lead_Tracker__c>();
        List<Distributor_Lead_Tracker__c> assignedDistis = [SELECT Id,Status__c,Rejection_Reason__c,Lead_Id__c from Distributor_Lead_Tracker__c where (Status__c='Assigned' OR Status__c='Queued')and Lead_Id__c in:modifiedLeadIds];
        for(Distributor_Lead_Tracker__c dlt: assignedDistis){
            String mapleadrejreason = mapOfleadrejreason.get(dlt.Lead_Id__c);
            String mapleadstatus = mapOfleadstatus.get(dlt.Lead_Id__c);
            dlt.Rejection_Reason__c = mapleadrejreason ;
            dlt.Status__c = 'Rejected' ;
            modifiedDLT.add(dlt);
        }
           
        update modifiedDLT;
       
        
    }*/
}