/**********************************************************************************************
Name           :    UpdateStatus_NewUserRegistration
Date           :    12 June 2011
Description    :    This trigger sets new user status "User A/c Created" by calling
                    a Future class "FutureUpdateStatus".
**********************************************************************************************
@Modified By :  Scarlett Kang
@Modified Date: Aug 11 2016
@Description:   1608 Hot-fix SIR 1159 - Failed to create chatter user
***********************************************************************************************
Last Modified By     : Naveen Nayak 
Last Modified Date   : 13 July, 2018
Description : Changing Custom Object name New_User_Registration__C    
***********************************************************************************************/

trigger Users on User (after insert) {

    Set<String> setNewUserRegIds = new Set<String>();
    List<New_User_Registration__c> newUserList = new List<New_User_Registration__c>();
    for(User objUser:Trigger.new){
        if(objUser.New_User_Registration_ID__c != Null && objUser.New_User_Registration_ID__c.trim().length() > 0){
            setNewUserRegIds.add(objUser.New_User_Registration_ID__c);            
        }
    }
    if(setNewUserRegIds.size()>0){
        Users.updateStatus(setNewUserRegIds);
    }
     
    //Add to group, add users with SFDC license to public group
    Set<ID> setNXPuserIds = new Set<ID>();
    Set<ID> setNXPUserSFDCLicenseIds = new Set<ID>();//1608 SIR 1159 - Add by Scarlett, collect User Ids with SFDC License
    Set<ID> setProfileIds = new Set<ID>();
    Map<ID,Profile> mapProfiles;
    Public static string SALESFORCE_LICENSE = 'Salesforce';
    Public static string SALESFORCE_PLATFORM_LICENSE = 'Salesforce Platform';
  
    
    for(User objUser1: Trigger.New){
        setProfileIds.add(objUser1.ProfileId);
    }
    mapProfiles = new Map<ID,Profile>
        ([
            SELECT Id, Name, UserLicense.LicenseDefinitionKey, UserLicense.Name
            FROM profile 
            WHERE UserLicense.LicenseDefinitionKey!='PID_Customer_Community_Login' 
            AND Id in :setProfileIds
        ]);
    
      for(User objUser: Trigger.New){
    
        Profile pf = mapProfiles.get(objUser.ProfileId);
        if(pf != null){
            System.Debug('@@@Profile is '+pf.Name);
            if(
                pf.Name.left(3) != 'TS ' 
                && pf.Name.left(4) != 'NER ' 
            ){
                setNXPuserIds.add(objUser.id);
            }
            /***1608 SIR 1159 - Added by Scarlett***/            
            if(pf.UserLicense.Name == SALESFORCE_LICENSE || pf.UserLicense.Name == SALESFORCE_PLATFORM_LICENSE){
                setNXPUserSFDCLicenseIds.add(objUser.Id);
            }
                    
        }
    }
    
    Users.addToGroups(setNXPuserIds);
    Users.EnrollNXPUser(setNXPUserSFDCLicenseIds);
    
  }