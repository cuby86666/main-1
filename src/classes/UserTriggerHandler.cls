/**************************************************************************************
@Created By :    Nisha Agrawal
@Created Date:   Jun 22, 2018
@Description:    Class for all User Trigger Methods
---------------------------------------------------------------------
@Modified By :    Nisha Agrawal
@Modified Date:   Jul 31, 2018
@Description:     (CDLP-140)Modified shareLeadRecordsToLPUsers method to include User 
					update scenario for Role promotion
******************************************************************************************/

public class UserTriggerHandler 
{
    public static boolean IsFirstRun_LP  = true;
    
    public static void shareLeadRecordsToLPUsers(List<User> newUserList, Map<Id, User> oldUserMap)
    {
        if(IsFirstRun_LP)
        {
            //make a set of contacts linked to user
            Map<Id, Id> mapUserToLinkedContact = new Map<Id, Id>();
            Map<Id, String> mapUserToDistiUserRole = new Map<Id, String>();
            Set<Id> promotedUsers = new Set<Id>();
            
            //ensure that we have profile id value
            if(LeadPortalLib.LP_EXTERNAL_PROFILE_Id == null)
            {
                LeadPortalLib.getExternalUserProfile();
            }
            
            User oldUser;
            for(User objUser : newUserList)
            {
                //check if active Lead Portal User
                if(objUser.IsActive == true && objUser.ProfileId == LeadPortalLib.LP_EXTERNAL_PROFILE_Id && 
                   objUser.Disti_Lead_Portal_User_Role__c != null) 
                {          
                    //check if any existing user
                    oldUser = (oldUserMap != null ? oldUserMap.get(objUser.Id): null) ;
                    if(oldUser != null &&  oldUser.Disti_Lead_Portal_User_Role__c != null && oldUser.Disti_Lead_Portal_User_Role__c != objUser.Disti_Lead_Portal_User_Role__c ) //check if role changed
                    {
                        if(oldUser.Disti_Lead_Portal_User_Role__c == LeadPortalLib.PORTAL_ROLE_USER && 
                            objUser.Disti_Lead_Portal_User_Role__c == LeadPortalLib.PORTAL_ROLE_REGIONAL) //User got promoted from User to Regional Role
                        {
                            promotedUsers.add(objUser.Id);
                        }
                    }
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
            Map<Id, Set<Id>> mapAccountToContacts = new Map<Id, Set<Id>>();
            
            for(Contact objContact : [Select Id, AccountId From Contact Where AccountId in :mapContactToAccountId.values()])
            {
                if(mapAccountToContacts.containsKey(objContact.AccountId))
                {
                    mapAccountToContacts.get(objContact.AccountId).add(objContact.Id);
                }
                else
                {
                    mapAccountToContacts.put(objContact.AccountId, new Set<Id>{objContact.Id});
                }
            }
            
            //map of Users to set of contact Ids for other contacts in that User region from that disti
            Map<Id , Set<Id>> mapUserToOtherContacts = new Map<Id, Set<Id>>();
            Set<Id> contactIdsToFetchLeads = new Set<Id>();
            Id accountLinkedToUser;
                        
            for(Id userId : mapUserToLinkedContact.keySet())
            {
                Id contactLinkedToUser = mapUserToLinkedContact.get(userId);
                accountLinkedToUser = mapContactToAccountId.get(contactLinkedToUser);
                
                if(mapAccountToContacts.containsKey(accountLinkedToUser))
                {
                    Set<Id> otherContacts = mapAccountToContacts.get(accountLinkedToUser);                    
                    //remove contact linked to user from otherContacts set
                    otherContacts.remove(contactLinkedToUser);
                    
                    contactIdsToFetchLeads.addAll(otherContacts);
                    mapUserToOtherContacts.put(userId, otherContacts);
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
                if(oldUserMap != null && oldUserMap.containsKey(userId)) // no change in sharing if user record changed
                {
                    continue;
                }
                else
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
            }
            
            String strUserRole;
            String strUserRegion;
                     
            //scenario 2- Leads assigned to other contacts from linked disti for the same lead region
            for(Id userId : mapUserToOtherContacts.keySet())
            {
                //create sharing records if either new user or user got promoted to regional role
                if( (oldUserMap == null) || ( oldUserMap != null && oldUserMap.containsKey(userId) && promotedUsers.contains(userId)))
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
            }
            
            //TODO : Error Handling part
            //create sharing records
            if(lstShares.size() > 0)
            {
                //Call future method only to avoid mixed DML issue
                String strShareAsJSON = JSON.serialize(lstShares);
                LeadPortalLib.shareLeadAccessToUsers(strShareAsJSON); 
            }            
            
            IsFirstRun_LP = false;   
		}
    }
}