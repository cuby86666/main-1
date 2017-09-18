public class FeedItemTriggerCommunityHandler {
    
    public void onAfterUpdate(List<FeedItem> lstFeedItemNew, Map<Id,FeedItem> mapFeedItemOld){
        
        System.debug('Limit queries onAfterUpdate Handler 1 *>'+System.limits.getQueries());
        
        updateCase(lstFeedItemNew, mapFeedItemOld);
        // addFileOnUpdate(lstFeedItemNew);
        
        System.debug('Limit queries onAfterUpdate Handler 11 *>'+System.limits.getQueries());
        
        addFileOnUpdate(lstFeedItemNew);
        // updateCase(lstFeedItemNew, mapFeedItemOld);
    }
    
    private void addFileOnUpdate(List<FeedItem> lstFeedItemNew) {
        
        Id caseId;
        Boolean isNewFileHolder = false;
        FeedItem objFileHolder;
        FeedItem objQuestionFeedItem = lstFeedItemNew[0];
        Set<Id> setExistingRecordId = new Set<Id>();
        List<FeedAttachment> lstFAToInsert = new List<FeedAttachment>();
        
        System.debug('Limit queries addFileOnUpdate Handler 2 *>'+System.limits.getQueries());
        
        For(Case objCase : [SELECT Id 
                            FROM Case 
                            WHERE FeedItemId =: objQuestionFeedItem.Id 
                            LIMIT 1]) {
           
            caseId = objCase.Id;
        }
        
        System.debug('Limit queries addFileOnUpdate Handler 3 *>'+System.limits.getQueries());
        
        if(caseId == null) return;
        
        System.debug('Limit queries addFileOnUpdate Handler 4 *>'+System.limits.getQueries());
        
        for(FeedItem objFeed : [SELECT Id, ParentId 
                                FROM FeedItem 
                                WHERE Title = 'File Holder' 
                                AND ParentId =: caseId
                                LIMIT 1]){
                                             
            objFileHolder = objFeed;
        }
        
        System.debug('Limit queries addFileOnUpdate Handler 5 *>'+System.limits.getQueries());
        
        if(objFileHolder == null) {
            
            objFileHolder = new FeedItem(Title = 'File Holder', Body='File Holder', ParentId = caseId, Visibility = 'AllUsers');
            isNewFileHolder = true;
            insert objFileHolder;
        }
        
        if(!isNewFileHolder) {
            
            System.debug('Limit queries addFileOnUpdate Handler 6 *>'+System.limits.getQueries());
           
            for(FeedAttachment objFeedAttach : [SELECT RecordId
                                                FROM FeedAttachment
                                                WHERE FeedEntityId =: objFileHolder.Id
                                                AND RecordId != NULL ] ){
                
                setExistingRecordId.add(objFeedAttach.RecordId);
            }
            
            System.debug('Limit queries addFileOnUpdate Handler 7 *>'+System.limits.getQueries());
        }
        
        System.debug('Limit queries addFileOnUpdate Handler 8 *>'+System.limits.getQueries());
        
        for(FeedAttachment objFeedAttach : [SELECT Id,RecordId,FeedEntityId,Title,Type,Value
                                            FROM FeedAttachment
                                            WHERE FeedEntityId =: objQuestionFeedItem.Id
                                            AND RecordId != NULL
                                            AND RecordId NOT IN: setExistingRecordId] ){
            
            FeedAttachment objFeedAttachment = new FeedAttachment(FeedEntityId =  objFileHolder.Id, RecordId = objFeedAttach.RecordId, Type = 'CONTENT');
            lstFAToInsert.add(objFeedAttachment);
        }
        
        System.debug('Limit queries addFileOnUpdate Handler 9 *>'+System.limits.getQueries());
        
        Datetime sysTime = System.now().addSeconds( 30 );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        if(!Test.isRunningTest()){
            
            System.schedule( 'SelfScheduleForFileAttchment' + sysTime, chronExpression, new AddFileOnQuestionUpdateScheduler(lstFAToInsert)); 
        }
        
        System.debug('Limit queries addFileOnUpdate Handler 10 *>'+System.limits.getQueries());
    }
    
    private void updateCase(List<FeedItem> lstFeedItemNew, Map<Id,FeedItem> mapFeedItemOld){
        
        //map of feedid to feedBody
        Map<String,FeedItem> mapFeedIdToFeedItem = new Map<String,FeedItem>();
        //list of cases to be updated
        List<Case> lstCaseToUpdate = new List<Case>();
        
        for(FeedItem objFeedItem : lstFeedItemNew){
            
            // system.debug('obj Body ->'+objFeedItem);
            FeedItem objFeedItemOld = mapFeedItemOld.get(objFeedItem.Id);
            
            if(objFeedItemOld.Type == 'QuestionPost') {
                
                if(objFeedItemOld.Body != objFeedItem.Body || objFeedItemOld.Title != objFeedItem.Title){
                
                    //populate map
                    mapFeedIdToFeedItem.put(objFeedItem.Id,objFeedItem);
                }
            }   
        }
        
        System.debug('Limit queries updateCase Handler 2 *>'+System.limits.getQueries());
        
        //case query loop  with WHERE feeditemId IN map.keyset()
        for(Case objCase : [SELECT FeedItemId,Subject,Description 
                            FROM Case 
                            WHERE FeedItemId IN: mapFeedIdToFeedItem.keyset()]){
                                
            //map.get(feedItemId) --> desc new  != case.desc
            String feedBody = mapFeedIdToFeedItem.get(objCase.feedItemId).body;
            
            objCase.Subject = mapFeedIdToFeedItem.get(objCase.feedItemId).Title;
            
            if(feedBody != objCase.Description){
                
                feedBody = feedBody.replaceAll('<p>', '');                
                feedBody = feedBody.replaceAll('<p>','--n--');
                feedBody = feedBody.replaceAll('</p>','--n--');
                feedBody = feedBody.replaceAll('<code>','\t');
                feedBody = feedBody.replaceAll('</code>','');
                feedBody = feedBody.stripHtmlTags();
                feedBody  = String.join(feedBody.split('--n--'),' \n ');
                
                objCase.Description = feedBody;
                lstCaseToUpdate.add(objCase);
            }
        }
        
        System.debug('Limit queries updateCase Handler 3 *>'+System.limits.getQueries());
        
        Update lstCaseToUpdate;
        
        System.debug('Limit queries aftr updateCase Handler 4*>'+System.limits.getQueries());
    }
    
    public static void updateLastQuestionNetworkId(List<FeedItem> lstFeedItemNew) {
        
        for(FeedItem objFeedItem : lstFeedItemNew) {
            
            if(objFeedItem.Type == 'QuestionPost') {
                
                update new User(Id = UserInfo.getUserId(),
                    Last_Question_Posted_Network__c = objFeedItem.NetworkScope);
                    
                break;
            }
        }
    }
}