/********************************************************
@Created By :    Nisha Agrawal
@Created Date:   Jun 22, 2018
@Description:    Class for all User Trigger Methods
*********************************************************/

public class UserTriggerHandler 
{
	public static void shareLeadRecordsToLPUsers(List<User> lstUsers)
    {
        //make a set of contacts linked to user
        Map<Id, Id> mapUserToLinkedContact = new Map<Id, Id>();
        Map<Id, String> mapUserToDistiUserRole = new Map<Id, String>();
        
        //ensure that we have profile id value
        if(LeadPortalLib.LP_EXTERNAL_PROFILE_Id == null)
        {
            LeadPortalLib.getExternalUserProfile();
        }
        
        for(User objUser : lstUsers)
        {
            //check if active Lead Portal User
            if(objUser.IsActive == true && objUser.ProfileId == LeadPortalLib.LP_EXTERNAL_PROFILE_Id && 
               objUser.Disti_Lead_Portal_User_Role__c != null) 
            {
                mapUserToLinkedContact.put(objUser.Id, objUser.ContactId);
                mapUserToDistiUserRole.put(objUser.Id, objUser.Disti_Lead_Portal_User_Role__c);
            }
        }
        
        //fetch the contact details like accountid , User Region etc
        //To get the leads assigned to other contacts in that region for that disti               
        Map<Id, Id> mapContactToAccountId = new Map<Id, Id>();
        Map<Id, String> mapContactToRegion = new Map<Id, String>();
        
        for(Contact objContact : [Select Id, AccountId, User_Region__c From Contact Where Id in: mapUserToLinkedContact.values()])
        {
            mapContactToAccountId.put(objContact.Id, objContact.AccountId);
            mapContactToRegion.put(objContact.Id , objContact.User_Region__c);
        }
        
        //fetch all the contacts for those distis regardless of regions
        //and create a map of account to contacts
        Map<Id, List<Contact>> mapAccountToContacts = new Map<Id, List<Contact>>();
        
        for(Contact objContact : [Select Id, AccountId From Contact Where AccountId in :mapContactToAccountId.values()])
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
        
        //map of Users to set of contact Ids for other contacts in that User region from that disti
        Map<Id , Set<Id>> mapUserToOtherContacts = new Map<Id, Set<Id>>();
        Set<Id> contactIdsToFetchLeads = new Set<Id>();
        Id accountLinkedToUser;
                    
        for(Id userId : mapUserToLinkedContact.keySet())
        {
            accountLinkedToUser = mapContactToAccountId.get(mapUserToLinkedContact.get(userId));
            
            if(mapAccountToContacts.containsKey(accountLinkedToUser))
            {
                for(Contact objContact : mapAccountToContacts.get(accountLinkedToUser))
                {
                    if(objContact.AccountId == accountLinkedToUser)
                    {
                        contactIdsToFetchLeads.add(objContact.Id);
                        
                        if(mapUserToOtherContacts.containsKey(userId))
                        {
                            mapUserToOtherContacts.get(userId).add(objContact.Id);
                        }
                        else
                        {
                            mapUserToOtherContacts.put(userId, new Set<Id>{objContact.Id});
                        }
                    }
                }
            }
        }
        
        //create a combined set of contact Ids for which we have to fecth leads              
        contactIdsToFetchLeads.addAll(mapUserToLinkedContact.values());
        
        //fetch all leads for the selecetd distributor contacts
        //create a map of contact to set of leads
        Map<Id, Set<Lead>> mapContactToLeads = new Map<Id, Set<Lead>>();
        
        for(Lead objLead : [Select Id, Distributor_Contact__c, Region__c From Lead Where Distributor_Contact__c  in : contactIdsToFetchLeads])
        {
            if(mapContactToLeads.containsKey(objLead.Distributor_Contact__c))
            {
                mapContactToLeads.get(objLead.Distributor_Contact__c).add(objLead);
            }
            else
            {
                mapContactToLeads.put(objLead.Distributor_Contact__c, new Set<Lead>{objLead});
            }
        }
        
        List<LeadPortalLib.CustomLeadShare> lstShares = new List<LeadPortalLib.CustomLeadShare>();
        Id linkedContactId;
            
        //scenario 1-  User is assigned as Disti Contact to Leads
        for(Id userId : mapUserToLinkedContact.keySet())
        {
            linkedContactId = mapUserToLinkedContact.get(userId);
            
            //check if any lead exists
            if(mapContactToLeads.containsKey(linkedContactId))
            {
                for(Lead objLead : mapContactToLeads.get(linkedContactId))
                {
                    lstShares.add(new LeadPortalLib.CustomLeadShare(objLead.Id, userId, LeadPortalLib.ACCESS_TYPE.Edit));  
                }
            }
        }
        
        String strUserRole;
        String strUserRegion;
                 
        //scenario 2- Leads assigned to other contacts from linked disti for the same lead region
        for(Id userId : mapUserToOtherContacts.keySet())
        {
            strUserRole = mapUserToDistiUserRole.get(userId);
            strUserRegion = mapContactToRegion.get(mapUserToLinkedContact.get(userId));
            
            for(Id otherContactId : mapUserToOtherContacts.get(userId))
            {
                //check if any lead exists for this contact
                if(mapContactToLeads.containsKey(otherContactId))
                {
                    for(Lead objLead : mapContactToLeads.get(otherContactId))
                    {
                        //check if lead region is same as user region
                        if(objLead.Region__c != null && strUserRegion != null && objLead.Region__c.toLowerCase() == strUserRegion.toLowerCase())
                        {
                             LeadPortalLib.ACCESS_TYPE leadAccess = (strUserRole == LeadPortalLib.PORTAL_ROLE_REGIONAL ?
                                                                 LeadPortalLib.ACCESS_TYPE.Edit :  LeadPortalLib.ACCESS_TYPE.Read);
                        	 lstShares.add(new LeadPortalLib.CustomLeadShare(objLead.Id, userId, leadAccess));
                        }
                    }
                }
            }
        }
        
        //TODO : Error Handling part
        //create sharing records
        LeadPortalLib.shareLeadAccessToUsers(lstShares); 
    }
}