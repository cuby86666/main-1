/*************************************************************************************************************
Name            :     UpdateOwnerInfo
Date            :     22 April, 2011
Author          :
Description     :     Trigger on case object before insert to update the Owner_Email and Supplied Phone field
*************************************************************************************************************/
//Debugged by Stan Hsu on Jan 25th 2015

trigger UpdateOwnerInfo on Case (before insert) {
    SET<ID> ownerids = new SET<ID>();
    MAP<ID, User> userMap = new MAP<ID, User>();
    List<Case> caseList = new List<Case>();
    List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE isactive =true and Name = 'Sales CRM' Limit 1];
     
    for(Case cs : Trigger.New){
        ownerids.add(cs.OwnerId);
    }
    if(ownerids.size() > 0){
        List<User> userList = [select id, Name, Email, Phone from user where id in : ownerids];
        if(userList.size() > 0){
            for(User usr : userList){
                userMap.put(usr.id, usr);
            }
        }
    }
    for(Case cs : Trigger.New){
        if(recordTypes.size() > 0){
            if(recordTypes.get(0).Id == cs.RecordTypeId){
                if( userMap.containsKey(cs.OwnerId) )
                {
                    if( userMap.get(cs.OwnerId).Email != null )
                    {
                        cs.Owner_Email__c = userMap.get(cs.OwnerId).Email;
                        cs.Owner_Work_Number__c = userMap.get(cs.OwnerId).Phone; //debugged by Stan Hsu
                    }
                }
            }
        }
        
    }
}