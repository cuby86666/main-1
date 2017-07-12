/*********************************************************************************
Name           :    UpdateStatus_NewUserRegistration
Author         :    
Date           :    12 June 2011
Description    :    This trigger sets new user status "User A/c Created" by calling
                    a Future class "FutureUpdateStatus".
**********************************************************************************/
trigger UpdateStatus_NewUserRegistration on User (after insert) {
    Set<String> ids = new Set<String>();
    List<New_User_Registeration__c> newUserList = new List<New_User_Registeration__c>();
    for(User usr:Trigger.new){
        if(usr.New_User_Registration_ID__c != Null && usr.New_User_Registration_ID__c.trim().length() > 0){
            ids.add(usr.New_User_Registration_ID__c);            
        }
    }
    if(ids.size()>0){
        FutureUpdateStatus.updateStatus(ids);       
    }    
}