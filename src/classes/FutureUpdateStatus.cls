/*********************************************************************************
Name           :    FutureUpdateStatus
Author         :    
Date           :    12 June 2011
Description    :    This Future Class is called by Trigger "UpdateStatus_NewUserRegistration". 

Last Modified By     : Naveen Nayak 
Last Modified Date   : 13 July, 2018
Description : Changing Custom Object name New_User_Registration__C
**********************************************************************************/
public class FutureUpdateStatus{
    
    @Future(callout=true)
    public static void updateStatus(Set<String> ids){
        
        List<New_User_Registration__c> newUserList = [Select id,name,status__c from New_User_Registration__c where id in: ids];
        if(newUserList.size()>0){
            for(New_User_Registration__c newUsr: newUserList){
                newUsr.status__c = 'User A/c Created';
            }
            update newUserList;
        } 
  }
  
}