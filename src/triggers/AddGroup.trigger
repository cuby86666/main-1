/**********************************************************************************************
@Modified By :  Scarlett Kang
@Modified Date: Aug 11 2016
@Description:   1608 Hot-fix SIR 1159 - Failed to create chatter user
***********************************************************************************************/
trigger AddGroup on User (after insert) 
{    
    Set<ID> NXPuserIds = new Set<ID>();
    Set<ID> NXPUserSFDCLicenseIds = new Set<ID>();//1608 SIR 1159 - Add by Scarlett, collect User Ids with SFDC License
    Set<ID> NERuserIds = new Set<ID>();
    Set<ID> profileIds = new Set<ID>();
    Map<ID,Profile> profiles;
    for(User u: Trigger.New){
        profileIds.add(u.ProfileId);
    }
    profiles = new Map<ID,Profile>
        ([
            SELECT Id, Name, UserLicense.LicenseDefinitionKey, UserLicense.Name
            FROM profile 
            WHERE UserLicense.LicenseDefinitionKey!='PID_Customer_Community_Login' 
            AND Id in :profileIds
        ]);
    
    for(User u: Trigger.New){
        Profile pf = profiles.get(u.ProfileId);
        if(pf != null){
            System.Debug('@@@Profile is '+pf.Name);
            if(
                pf.Name.left(3) != 'TS ' 
                && pf.Name.left(4) != 'NER ' 
            ){
                NXPuserIds.add(u.id);
            }
            /***1608 SIR 1159 - Added by Scarlett***/            
            if(pf.UserLicense.Name == 'Salesforce' || pf.UserLicense.Name == 'Salesforce Platform'){
                NXPUserSFDCLicenseIds.add(u.Id);
            }
            /***1608 SIR 1159 - Added by Scarlett***/ 
           /* else if( pf.Name.left(4) == 'NER ' 
            ){
                NERuserIds.add(u.id);
            }  */          
        }
    }
    
    ChatterAutoFollow.AddToGroups(NXPuserIds);   
    //GroupAutoFollow.EnrollNXPUser(NXPuserIds); //1608 SIR 1159 Scarlett
    GroupAutoFollow.EnrollNXPUser(NXPUserSFDCLicenseIds); //1608 SIR 1159 - Add by Scarlett, add users with SFDC license to public group
   // GroupAutoFollow.EnrollNERUser(NERuserIds);
    
    //ChatterAutoFollow.AddToGroups(trigger.newMap.keySet());
    /*
        if( u.Profile.Name == 'NXP Sales with SSO' || u.Profile.Name == 'NXP BU/BL with SSO'){
            userIds.add(u.id);
        }
    
    */
}