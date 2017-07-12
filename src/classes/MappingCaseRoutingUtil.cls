/*
Class Name	  : MappingCaseRoutingUtil
JIRA Ticket   : NXP1-388
Description   : Class which updates GroupName,TopicName And RelatedToId fields of case based on question created from either group or topic 
                and updates Owner And Assignedto fields of case with matching CaseRoutingMapping record.
*/


global class MappingCaseRoutingUtil implements Schedulable {
    
     Public Map<Id,Case> mapFeedItemIdToCase = new Map<Id,Case>();
     public Map<Id, List<Case>> mapOfGroupToCases = new Map<Id, List<Case>>();
     Public string strContactId;
     Public Boolean isOnlyAttachmentProcess;
     Public Boolean onlyProcessCasesAssociatedToGroup;
    
    global MappingCaseRoutingUtil(Map<Id,Case> mapFeedItemIdToCase, String strContactId, Boolean isOnlyAttachmentProcess) {
        
        this.mapFeedItemIdToCase = mapFeedItemIdToCase;
        this.strContactId = strContactId;
        this.isOnlyAttachmentProcess = isOnlyAttachmentProcess;
        this.onlyProcessCasesAssociatedToGroup = false;
    }
    
    global MappingCaseRoutingUtil(Map<Id, List<Case>> mapOfGroupToCases) {
        
        this.mapOfGroupToCases = mapOfGroupToCases;
        this.onlyProcessCasesAssociatedToGroup = true;
    }
    
    global void execute(SchedulableContext SC) { 
        
        if(onlyProcessCasesAssociatedToGroup) {
            
            mapCaseRouting(mapOfGroupToCases);
        }
        
        case objcase; 
        Contact objContact;
        
        Map<Id,FeedAttachment> mapOfFeedAttachment = new Map<Id,FeedAttachment>();
        List<FeedAttachment> lstFAToInsert = new List<FeedAttachment>();
        List<FeedItem> lstFA = new List<FeedItem>();
        
        //FeedItem objFeedItem = [SELECT Id, ParentId, RelatedRecordId FROM FeedItem WHERE Id IN: mapFeedItemIdToCase.keyset() limit 1]; 
        lstFA = [SELECT Id, ParentId, RelatedRecordId FROM FeedItem WHERE Id IN: mapFeedItemIdToCase.keyset() limit 1];
        if(lstFA.isEmpty())
            return;
        
        //fetching the FeedAttachment related to FeedItem.    
        for(FeedAttachment objFeedAttach : [SELECT Id,RecordId,FeedEntityId,Title,Type,Value FROM FeedAttachment WHERE FeedEntityId =:lstFA[0].Id AND RecordId != NULL ] ){
            
            mapOfFeedAttachment.put(objFeedAttach.Id,objFeedAttach);
           
        }
         
        if(lstFA[0].RelatedRecordId!= NULL){
            
            FeedItem  newFeedItem = new FeedItem(Title = 'File Holder', Body='File Holder', ParentId = mapFeedItemIdToCase.get(lstFA[0].Id).Id, Visibility = 'AllUsers');
            insert newFeedItem;
            
            for(FeedAttachment objFA : mapOfFeedAttachment.values()){ 
                
                FeedAttachment objFeedAttachment = new FeedAttachment(FeedEntityId =  newFeedItem.Id,RecordId = objFA.RecordId, Type = 'CONTENT');
                lstFAToInsert.add(objFeedAttachment);
            }
            
            if(!lstFAToInsert.isEmpty())
                insert lstFAToInsert;
        }
        
        if(isOnlyAttachmentProcess) return;
            
        Map<Id, List<Case>> mapOfTopicIdToCase = new Map<Id,List<Case>>();
        List<Contact> lstContact = new List<Contact>();
        if(strContactId!=NULL && UserInfo.getUserType() == 'Standard'){
            
            lstContact = [SELECT State_Province__c, Title, Community_Web_Country__c, Company__c From Contact WHERE Id =:strContactId];
            if(lstContact.isEmpty()){
                
                return;
            }
            else{
                
                objContact = [SELECT State_Province__c, Title, Community_Web_Country__c, Company__c From Contact WHERE Id =:strContactId];
            }
        }
        
       //fetching the TopicId and Topic Name related to FeedItem
        for(TopicAssignment objTA : [   SELECT EntityId,Id,NetworkId,TopicId, Topic.Name
                                        FROM TopicAssignment
                                        WHERE EntityId IN : mapFeedItemIdToCase.keyset() ]) { 
           
            //If internal user creating question then associating contact on case with user's custom contact.
            if(UserInfo.getUserType() == 'Standard' && objContact != NULL){
               
                objcase = new case ( Id = mapFeedItemIdToCase.get(objTA.EntityId).Id,Contact = objContact ,ContactId = strContactId, RelatedToId__c = objTA.TopicId, Community_Topic_Name__c = objTA.Topic.Name);
            } 
           
            else{
                objcase = new case ( Id = mapFeedItemIdToCase.get(objTA.EntityId).Id,RelatedToId__c = objTA.TopicId, Community_Topic_Name__c = objTA.Topic.Name);
            }
           
           
           if(mapOfTopicIdToCase.containskey(objTA.TopicId)){
                    
                mapOfTopicIdToCase.get(objTA.TopicId).add(objcase); 
            }
            else{
                
                mapOfTopicIdToCase.put(objTA.TopicId, new List<Case> { objcase});
            }
                
        }
        
        //calling mapCaseRouting to Update case owner and Assigned to fields mapped with Case Route Mapping 
        mapCaseRouting(mapOfTopicIdToCase);
    }
    
    /*Method to update case field based on matching RelatedTo field */
    global static void mapCaseRouting(Map<Id,List<Case>> mapOfRelatedToIdToCase){
        
        Id defaultCaseOwner;
        Id defaultCaseAssignedTo; 
        set<Id> setOfMatchedMapping = new set<Id>();
        set<Id> setCaseId = new set<Id>();
        List<Case> lstOfAllCaseToUpdate = new List<Case>();
        Map<Id,List<Case>> mapOfRelatedIdToCaseTemp = new Map<Id,List<Case>>();
        Map<Id,Contact> mapOfContactIdToContact = new Map<Id,Contact>();

        //fetching matched CaseRoutingMapping record based on question created from group/topic and updating case fields with Case_Routing_Mapping__c
        for(Case_Routing_Mapping__c objCRM : [SELECT Id, Related_To_Id__c, Group_Name__c, Topic_Name__c, CaseAdmin__c,
                                                Case_Assigned_To__c,CaseOwner__c
                                                FROM Case_Routing_Mapping__c
                                                WHERE Related_To_Id__c != NULL 
                                                AND CaseOwner__c != NULL
                                                AND Related_To_Id__c IN : mapOfRelatedToIdToCase.keyset()]){
            
            setOfMatchedMapping.add(objCRM.Related_To_Id__c);  
            
            List<Case> lstCases = mapOfRelatedToIdToCase.get(objCRM.Related_To_Id__c);
            
            if(lstCases!=NULL) {
                
                for(Case objCase : lstCases) {
                    //check if a topic is assigned to multiple questions
                    if(!setCaseId.contains(objCase.Id)) {
                       
                        setCaseId.add(objCase.Id);
                        
                        objCase.OwnerId = objCRM.CaseOwner__c;
                        objCase.Assigned_to__c = objCRM.Case_Assigned_To__c;
                        
                        if(mapOfRelatedIdToCaseTemp.containskey(objCRM.Related_To_Id__c)){
                            
                            mapOfRelatedIdToCaseTemp.get(objCRM.Related_To_Id__c).add(objCase);
                        }
                        else{
                            mapOfRelatedIdToCaseTemp.put(objCRM.Related_To_Id__c, new List<Case> { objcase });
                        }
                        
                        mapOfRelatedToIdToCase = new Map<Id, List<Case>>();
                        mapOfRelatedToIdToCase.putAll(mapOfRelatedIdToCaseTemp);
                    }
                }
                
            }
        }
        //if no match found in Case_Routing_Mapping__c updating case with default record
        if(setOfMatchedMapping.size() < mapOfRelatedToIdToCase.size() ){
            
            for(Case_Routing_Mapping__c objCRM : [SELECT Id,Case_Assigned_To__c,CaseOwner__c
                                                  FROM Case_Routing_Mapping__c 
                                                  WHERE Name = 'Default' limit 1]){ 
                defaultCaseOwner = objCRM.CaseOwner__c;
                defaultCaseAssignedTo = objCRM.Case_Assigned_To__c;
            }

            for(Id rId : mapOfRelatedToIdToCase.keyset()) {
                
                List<Case> lstCases = mapOfRelatedToIdToCase.get(rId);
                
                if(!setOfMatchedMapping.contains(rId) && lstCases != NULL) {
                    
                    for(Case objcase : lstCases){
                        
                        if(!setCaseId.contains(objcase.Id)){
                            
                            setCaseId.add(objcase.Id);
                            
                            objcase.OwnerId = defaultCaseOwner;
                            objcase.Assigned_to__c = defaultCaseAssignedTo;
                            
                            if(mapOfRelatedIdToCaseTemp.containskey(rId)){
                            
                                mapOfRelatedIdToCaseTemp.get(rId).add(objCase);
                            }
                            else{
                                
                                mapOfRelatedIdToCaseTemp.put(rId, new List<Case> { objcase });
                            }
                        
                            mapOfRelatedToIdToCase = new Map<Id, List<Case>>();
                            mapOfRelatedToIdToCase.putAll(mapOfRelatedIdToCaseTemp);
                        }
                    }
                }
            }
        }
        set<Id> setContactId = new set<Id>();
        List<Case> lstContactRelatedCase = new List<Case>();
        
        //iterating over map to retrive listOfcases To Update
        for(List<case> objCase : mapOfRelatedToIdToCase.values()){
            
            lstOfAllCaseToUpdate.addAll(objCase);
        }
        
        //Logic for updating contact details on case for Internal user.
        for(Case objCaseContact : lstOfAllCaseToUpdate){
                
            if(objCaseContact.Contact!=NULL)
                mapOfContactIdToContact.put(objCaseContact.ContactId, objCaseContact.Contact);
            
        }
         
        if(UserInfo.getUserType() == 'Standard'){
            
            for(Case objCase : lstOfAllCaseToUpdate){
                
                if(!mapOfContactIdToContact.isEmpty()){ 
                    objCase.State_Province__c = mapOfContactIdToContact.get(objCase.ContactId).State_Province__c != NULL ? mapOfContactIdToContact.get(objCase.ContactId).State_Province__c : '';
                    system.debug('(objCase.ContactId).Title -+-+>>'+mapOfContactIdToContact.get(objCase.ContactId).Title);
                    objCase.Contact_Title__c = mapOfContactIdToContact.get(objCase.ContactId).Title != NULL ? mapOfContactIdToContact.get(objCase.ContactId).Title : '';
                    system.debug('(objCase.ContactId).Title -+-+>>'+objCase.Contact_Title__c);
                    objCase.Community_Web_Country__c = mapOfContactIdToContact.get(objCase.ContactId).Community_Web_Country__c != NULL ? mapOfContactIdToContact.get(objCase.ContactId).Community_Web_Country__c : '';
                    objCase.Company__c = mapOfContactIdToContact.get(objCase.ContactId).Company__c != NULL ? mapOfContactIdToContact.get(objCase.ContactId).Company__c : '';
                }
                
                lstContactRelatedCase.add(objCase);
            }
        }
        
        system.debug('>>>>>>>>>>>>>>>lstOfAllCaseToUpdateAFTER::' +lstOfAllCaseToUpdate);
        system.debug('>>>>>>>>>>>>>>>lstContactRelatedCase::' +lstContactRelatedCase);
        
        if(!lstContactRelatedCase.isEmpty())
            update lstContactRelatedCase;
        else
            update lstOfAllCaseToUpdate;
    }
}