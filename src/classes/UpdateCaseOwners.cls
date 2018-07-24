global without sharing class  UpdateCaseOwners implements Schedulable {

    global void execute(SchedulableContext context) {
    
        List<Out_Of_Office_Log__c> OOOAgents = [SELECT Person_taking_time_off__c, Backup_Person__c,Start_Date__c,End_Date__c
            FROM Out_Of_Office_Log__c
            WHERE Start_Date__c <= TODAY AND 
                End_Date__c >= TODAY];
        
        //build mapping from time-off guy to his backup
        Map<Id,Out_Of_Office_Log__c > mapOfBackupPerson = new Map<Id,Out_Of_Office_Log__c >();
        for (Out_Of_Office_Log__c OOOAgent : OOOAgents) {
            mapOfBackupPerson.put(OOOAgent.Person_taking_time_off__c,OOOAgent);
        }
        
        //find cases for people taking off
        System.debug(' backup records '+mapOfBackupPerson.keySet());
        List<Case> allOOOCases = [SELECT       Assigned_to__c, Id 
                                        FROM Case 
                                        WHERE   Assigned_to__c in :mapOfBackupPerson.keySet()
                                            AND IsClosed = false and RecordType.name='TS Community'  
                                            AND Status!='Answered Back' AND Status!='Pending SW Release'];
                                            
                                            
        
        List<Case> casesToUpdate = new List<Case>(); 
        List<FeedItem> feedItemList = new List<FeedItem>();
        
        //iterate through cases and update assigned to
        for(Case ooocase : allOOOCases){
            if(ooocase.Assigned_to__c !=null){
                //find backup person from map
                Out_Of_Office_Log__c backupPerson = mapOfBackupPerson.get(ooocase.Assigned_to__c);
                ooocase.Assigned_to__c = backupPerson.Backup_Person__c;
                //If backupPerson Becomes ill
                Out_Of_Office_Log__c backupPersonill = mapOfBackupPerson.get(ooocase.Assigned_to__c);
                if(backupPersonill!=null && backupPerson.Start_Date__c >= 
                            backupPersonill.Start_Date__c && backupPerson.End_Date__c <= backupPersonill.End_Date__c ){
                                ooocase.Assigned_to__c = backupPersonill.Backup_Person__c;
                }
                //add case to update list
                if (Schema.sObjectType.Case.isUpdateable()) {
                    casesToUpdate.add(ooocase);
                }
                //create feed item
                FeedItem fi = new FeedItem(ParentId = ooocase.Id, 
                                           Body='Case was re-assigned since onwer of the case is out of office.', 
                                           Type = 'TextPost');
                                        
                if (Schema.sObjectType.FeedItem.isCreateable()) {
                   feedItemList.add(fi);
                }
            }
        }
        
        
        
        if(casesToUpdate !=null && casesToUpdate.isEmpty()==false){
            Database.update(casesToUpdate,false);
        }
        if(feedItemList !=null && feedItemList.isEmpty()==false){
            Database.insert(feedItemList,false);
        }
        
    
    }
    
    public static void scheduleUpdateCaseOwners() {
        
        System.schedule('Case Ownership Hourly Update', '0 0 * * * ?', new UpdateCaseOwners());
    
    }

}