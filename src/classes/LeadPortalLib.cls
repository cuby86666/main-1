/************************************************************************
@Created By :    Nisha Agrawal
@Created Date:   Jun 20, 2018
@Description:    Library class for Lead Portal related functionality
----------------------------------------------------------------------
@Modified By :    	Nisha Agrawal
@Modified Date:   	Jul 31, 2018
@Description:    	Modified to solve MixedDML issue from User trigger
****************************************************************************/

public class LeadPortalLib 
{
    private static string SHARING_REASON = 'Manual';
    public static Id LP_EXTERNAL_PROFILE_Id;
    public static string LP_EXTERNAL_PROFILE = 'NXP Distributor User';
    public static string PORTAL_ROLE_USER = 'User';
    public static string PORTAL_ROLE_REGIONAL = 'Regional User';
        
    public enum ACCESS_TYPE {Read, Edit}
    
        
    public static void getExternalUserProfile()
    {
    	if(LP_EXTERNAL_PROFILE_Id == null)
        {
            List<Profile> lstProfiles = [Select Id, Name from Profile Where Name =: LP_EXTERNAL_PROFILE limit 1];
            if(lstProfiles.size() > 0)
            {
                LP_EXTERNAL_PROFILE_Id = lstProfiles[0].Id;
            }
        }
    }
    
    @future
    public static void shareLeadAccessToUsers(String leadSharesAsJSON)
    {
        //deserilize JSON to object list        
        List<CustomLeadShare> lstShares = (List<CustomLeadShare>)JSON.deserialize(leadSharesAsJSON, List<CustomLeadShare>.Class);
        shareLeadAccessToUsers(lstShares);
    }
    
    public static void shareLeadAccessToUsers(List<CustomLeadShare> lst)
    {
        if(lst != null)
        {
			List<LeadShare> lstLeadSharings = new List<LeadShare>();
           
            for(CustomLeadShare objShare : lst) 
            {
               lstLeadSharings.add(new LeadShare(LeadId = objShare.RecordId, UserOrGroupId = objShare.AssigneeId, LeadAccessLevel = String.ValueOf(objShare.RecordAccess), RowCause = SHARING_REASON)); 
            }
            
            if(lstLeadSharings.size() > 0)
            {
				//calling method from MixedDMLOps class to avoid mixed DML issue in test class context
				List<Database.SaveResult> lstResults = MixedDMLOps.ins(lstLeadSharings);
                
                for(Database.SaveResult objResult : lstResults)
                {
                    if(!objResult.isSuccess())
                    {                 
                        // Get first save result error.
                        Database.Error err = objResult.getErrors()[0];
                        
                        // Check if the error is related to trival access level. Access level must be more permissive than 
                        // the object's default. These sharing records are not required and thus an insert exception is acceptable. 
                        if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                           err.getMessage().contains('AccessLevel'))
                        {
                            continue;
                        }
                        else
                        {
                            //TODO : exception handling
							//system.debug('==error, failed to create share record : ' + err.getMessage());                            
                        }
                    }
                }   
			}
        }
    }
    
     //if leadAccess param is null then delete the record regardless of access
    public static void revokeLeadAccessFromUsers(Map<Id, Set<Id>> mapLeadToUsers, ACCESS_TYPE leadAccess)
    {
        if(mapLeadToUsers != null)
        {
            Set<Id> userIds = new Set<Id>();
            for(Id leadId : mapLeadToUsers.keySet())
            {
                userIds.addAll(mapLeadToUsers.get(leadId));
            }
            
            List<LeadShare> shareRecordsToDelete = new List<LeadShare>();
            
            for(LeadShare objShare : [Select Id, LeadId, UserOrGroupId, LeadAccessLevel, RowCause From LeadShare 
                                      Where RowCause = : SHARING_REASON and LeadId in: mapLeadToUsers.keySet() and UserOrGroupId in : userIds ])
            {
                if(leadAccess == null || (leadAccess != null && String.valueOf(leadAccess) == objShare.LeadAccessLevel) )
                {
                    if(mapLeadToUsers.containsKey(objShare.LeadId))    
                    {
                        if(mapLeadToUsers.get(objShare.LeadId) != null && mapLeadToUsers.get(objShare.LeadId).contains(objShare.UserOrGroupId))
                        {
                            shareRecordsToDelete.add(objShare);
                        }
                    }
                }
            }
            
            if(shareRecordsToDelete.size() > 0)
            {
                //TODO: Error Handling
                delete shareRecordsToDelete;
            }
        }
    }
    
    //Map of Lead Ids to Set of User Ids who should get access
    public static void shareLeadAccessToUsers(Map<Id, Set<Id>> mapLeadToUsers, ACCESS_TYPE leadAccess)
    {
        if(mapLeadToUsers != null)
        {
            List<LeadShare> lstLeadSharings = new List<LeadShare>();
        	
            //TODO : uncomment below code
            /*
            for(Id leadId : mapLeadToUsers.keySet())
            {
                for(Id userId : mapLeadToUsers.get(leadId))
                {
                    lstLeadSharings.add(new LeadShare(LeadId = leadId, UserOrGroupId = userId, LeadAccessLevel = String.ValueOf(leadAccess), RowCause = SHARING_REASON));
                }
            }            
            if(lstLeadSharings.size() > 0)
            {
				List<Database.SaveResult> lstResults = Database.insert(lstLeadSharings,false);
				
                for(Database.SaveResult objResult : lstResults)
                {
                    if(!objResult.isSuccess())
                    {                 
                        // Get first save result error.
                        Database.Error err = objResult.getErrors()[0];
                        
                        // Check if the error is related to trival access level. Access level must be more permissive than 
                        // the object's default. These sharing records are not required and thus an insert exception is acceptable. 
                        if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                           err.getMessage().contains('AccessLevel'))
                        {
                            continue;
                        }
                        else
                        {                            
                        }
                    }
                }   
			} */	
        } 
    }
    
    public class CustomLeadShare
    {
        public Id RecordId {get; set;}
        public Id AssigneeId {get; set;}
        public ACCESS_TYPE RecordAccess {get; set;}
        
        public CustomLeadShare(Id leadId, Id userId, ACCESS_TYPE leadAccess)
        {
            RecordId = leadId;
            AssigneeId = userId;
            RecordAccess = leadAccess;
        }
    }
}