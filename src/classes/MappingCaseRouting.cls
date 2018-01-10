/*
Class Name    : MappingCaseRouting
JIRA Ticket   : NXP1-388
Description   : Class which updates GroupName,TopicName And RelatedToId fields of case based on question created from either group or topic
*/

public class MappingCaseRouting {
    
    public void onAfterInsert(List<Case> lstCaseNew){
        
        mapCaseRoutingFields(lstCaseNew); 
    }
    
    public void onBeforeInsert(List<Case> lstCaseNew){
        
        updateCaseDescription(lstCaseNew);
    }
    
    /*Method to update Description field on case*/
    private void updateCaseDescription(List<Case> lstCaseNew){
        
        system.debug('Contact_Title__c --**>> '+lstCaseNew);
        
        for(Case objcase : lstCaseNew ){
            
            if(objcase.Description !=NULL && objCase.Origin == 'Forum'){
                
                //This is to handle new lines in description
                objcase.Description = objcase.Description.replaceAll('<p>', '');
                objcase.Description  = objcase.Description.replaceAll('<p>','--n--');
                objcase.Description  = objcase.Description.replaceAll('</p>','--n--');
                
                //This is to strip all HTML tags
                objcase.Description  = objcase.Description.stripHtmlTags();
                
                objcase.Description  = String.join(objcase.Description .split('--n--'),' \n ');
            }
        }
    }
    
    private void mapCaseRoutingFields(List<Case> lstCaseNew){
        
        set<Id> setCommunityId = new set<Id>();
        Map<Id,Case> mapFeedItemIdToCaseForTopics = new Map<Id,Case>();
        Map<Id,Case> mapFeedItemIdToCase = new Map<Id,Case>();
        Map<Id, List<Case>> mapOfGropupIdToCases = new Map<Id,List<Case>>();
        List<Case> lstOfCases = new List<Case>();
        List<Case> lstEscalatedCases = new List<Case>();
        Map<Id,Case> mapFeedItemIdToCommunityCase = new Map<Id,Case>();
        List<FeedAttachment> lstFeedAttachment = new List<FeedAttachment>();
        List<Contact> lstContact = new List<Contact>();
        String strContactId;
        User objUser = new User();
        Contact objContact;
        String strFeedItemCreatedById;
        
        for(Case objCase : lstCaseNew) {
            System.debug('FeedItemId ::'+objCase.FeedItemId);
            if(objCase.FeedItemId != null) {
                
                lstEscalatedCases.add(objCase);
            }
        }
        
        system.debug('Contact_Title__c --**>> '+lstCaseNew);
        //This check confirms that this logic is going to execute only if Case is escalated from Question
        if(lstEscalatedCases.isEmpty()) return;        
        
        strFeedItemCreatedById = [SELECT ID, CreatedById FROM FeedItem WHERE ID =: lstEscalatedCases[0].FeedItemId].CreatedById;
        //query ContctId for the logged in user.
        objUser = [SELECT firstName,LastName,contactId,Contact.Company__c, Contact_ID__c, Contact.Community_web_country__c, Email, accountId from User where id = :strFeedItemCreatedById];
        
        strContactId = objUser.ContactId; 
        
        //If ContactId is blank then user is Internal user.
        if(String.isBlank(strContactId)){
            
            system.debug('>>>>>>>>>>>>>>>>>>strContactId2::'+strContactId);
            
            //If Internal user fetching custom Contact_Id__c. If Contact_Id__c is blank then creating new contact and associating with user.
            if(!String.isBlank(objUser.Contact_Id__c)) {
                
                //system.debug('Title --**>> '+[SELECT id,Title from contact where Id=:objUser.Contact_Id__c limit 1]);
                strContactId = objUser.Contact_Id__c;
            }else {
                
                List<Contact> contactRecords = [SELECT Title from contact where Email=:objUser.Email limit 1];
            
                //system.debug('Title --**>> '+contactRecords);
            
                if( !contactRecords.isEmpty() ){
                
                    //update the User and Contact records
                    objUser.Contact_Id__c = contactRecords[0].id;
                }else{ 
            
                    Contact userContact = new Contact( FirstName = objUser.FirstName,
                                                       LastName = objUser.LastName,
                                                       Email = objUser.Email,
                                                       accountId = objUser.accountId
                                                    );
                        insert userContact ;
                        
                        objUser.Contact_Id__c = userContact.id;
                }
                
                update objUser;
                strContactId = objUser.Contact_Id__c;
            }
        }
        
        system.debug('>>>>>>>>>>>>>>>>>>strContactId LAST::'+strContactId);
        
        if(!String.isBlank(strContactId) && UserInfo.getUserType() == 'Standard'){
            
            lstContact = [SELECT State_Province__c, Title, Community_Web_Country__c, Company__c From Contact WHERE Id =:strContactId];
            system.debug('>>>>>>>>>>>::lstContact'+lstContact);
            if(lstContact.isEmpty()) {
                
                return;
            }
            else {
                
                objContact = [SELECT State_Province__c, Title, Community_Web_Country__c, Company__c From Contact WHERE Id =:strContactId];
            } 
        }
        system.debug('>>>>>>>>>>>>>>>>>>objContact LAST::'+objContact);
        for(Case objCase : lstCaseNew){ 
            
            //fetching FeedItemId related to case
            if(objCase.FeedItemId !=NULL ){ //Additional check community id && setCommunityId.contains(objCase.communityId)
                
                mapFeedItemIdToCase.put(objCase.FeedItemId,objCase);
            }
            
            //Checking if Question is created from community or not.
            if(objCase.Origin == 'Forum' && objCase.FeedItemId != NULL){
                
                mapFeedItemIdToCommunityCase.put(objCase.FeedItemId,objCase);
                
            }           
        }
        
        //Calling schedule class to create Attachment records.
        if(!mapFeedItemIdToCommunityCase.isEmpty()){
            
            //FeedItem objFeedItem = [SELECT Id, ParentId, RelatedRecordId FROM FeedItem WHERE Id IN: mapFeedItemIdToCommunityCase.keyset() ]; 
            
            Datetime sysTime = System.now().addSeconds( 30 );      
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'SelfScheduleForFileAttchment' + sysTime, chronExpression, new MappingCaseRoutingUtil(mapFeedItemIdToCommunityCase, strContactId, true)); 
        } 
        
        for(FeedItem objFeedItem : [SELECT Id, ParentId, RelatedRecordId FROM FeedItem WHERE Id IN:mapFeedItemIdToCase.keyset()]){
            //checking if FeedItem related to case is group or not.
            if(String.valueOf(objFeedItem.ParentId).startsWith('0F9')) {
                
                case objcase = new case(Id = mapFeedItemIdToCase.get(objFeedItem.Id).Id , RelatedToId__c = objFeedItem.ParentId);
                
                if(mapOfGropupIdToCases.containskey(objFeedItem.ParentId)){
                    
                     mapOfGropupIdToCases.get(objFeedItem.ParentId).add(objcase); 
                }
                else{
                    
                     mapOfGropupIdToCases.put(objFeedItem.ParentId, new List<Case> { objcase });
                }
            }
            //checking if FeedItem related to case is Topic or not.
            else if(String.valueOf(objFeedItem.ParentId).startsWith('005')){
                
                mapFeedItemIdToCaseForTopics.put(objFeedItem.Id, mapFeedItemIdToCase.get(objFeedItem.Id));
            }
        }
        
        //if FeedItem related to case is Topic then calling schedule class to update case fields related to Topic.                
        if(!mapFeedItemIdToCaseForTopics.isEmpty()){
            
            Datetime sysTime = System.now().addSeconds( 30 );      
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'SelfSchedule' + sysTime, chronExpression, new MappingCaseRoutingUtil(mapFeedItemIdToCaseForTopics, strContactId, false)); 
        }
        
        //fetching groupname based on group to update Community_Group_Name__c in case
        for(CollaborationGroup objCG: [Select Id, Name From CollaborationGroup Where Id IN : mapOfGropupIdToCases.keyset()]){
            
            for(Case objCase : mapOfGropupIdToCases.get(objCG.Id)){
                    
                objCase.Community_Group_Name__c = objCG.Name;
                
                //If Internal user then updating Contact of case with existing custom contact related to user if exists or creating new contact and associating with user.
                if(UserInfo.getUserType() == 'Standard'){
                    
                    objCase.ContactId = strContactId;
                    if(objContact!=NULL)
                        objCase.Contact = objContact;
                }
                
                lstOfCases.add(objCase);
            }
            mapOfGropupIdToCases.put(objCG.Id, lstOfCases);
        }        
        //Calling mapCaseRouting common method to update case with matched MappedCaseRouting record.
        MappingCaseRoutingUtil.mapCaseRouting(mapOfGropupIdToCases);
        /*if(!mapOfGropupIdToCases.isEmpty()){
            
            Datetime sysTime = System.now().addSeconds( 30 );      
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'SelfSchedule - GroupCases ' + sysTime, chronExpression, new MappingCaseRoutingUtil(mapOfGropupIdToCases)); 
        }*/
    } 
}