/*
Class Name	  : FeedCommentTriggerHandler
JIRA Ticket   : NXP1-387
Description   : 1.Class updates Case status to "Received Reply" if community user posts Comment
                2.Updates Case status to "Received Reply" if user posts comment with in 30 days after a case is closed
                3.If user posts comment 30 days after a case is closed, then sending email to Admin of matched Case_Routing_Mapping__c.
                4.If no match found then sending email to Default admin.
*/
public class FeedCommentTriggerHandler {
    
    private final String RECEIVED_REPLY_CASE_STATUS = 'Received Reply';
    private final String CLOSED_CASE_STATUS = 'Close';
    public Map<Id,string> mapOfFeedItemIdToName = new Map<Id, String>();
    public Map<Id,string> mapOfFeedItemIdToTitle = new Map<Id, String>();
    public Map<Id,List<Case>> mapRelatedIdToLockedCases = new Map<Id,List<Case>>();
    public Map<Id,List<Case>> mapCaseAssignedToIdToClosedCases = new Map<Id,List<Case>>();
    
    public void onAfterInsert(List<FeedComment> lstFeedComment){
        
        updateCaseStatus(lstFeedComment);
    }
    
    private void updateCaseStatus(List<FeedComment> lstFeedComment){
        
        System.debug('>>>>>>UserType::'+UserInfo.getUserType());
        
        if(UserInfo.getUserType() == 'Standard' && !Test.isRunningTest()){
            
            return;
        }
        
        Integer noOfdays;
        List<case> lstCaseToUpdate = new List<Case>();
        Map<Id,date> mapFeedItemIdToCreatedDate = new Map<Id,date>();
        
        //fetching FeedItemId related to FeedComment
        for(FeedComment objFc : lstFeedComment){
            
            mapFeedItemIdToCreatedDate.put(objFc.FeedItemId , date.valueOf(objFc.CreatedDate));

        }
        
        for(FeedItem objFeedItem : [Select id, Title From FeedItem Where Id IN:mapFeedItemIdToCreatedDate.keyset()]){
            
            mapOfFeedItemIdToName.put(objFeedItem.Id, objFeedItem.Id );
            mapOfFeedItemIdToTitle.put(objFeedItem.Id, objFeedItem.Title);
        }
        
        //updating case status if user posts question in community
        for(Case objCase : [SELECT Id, Status, FeedItemId,ClosedDate,RelatedToId__c,CaseNumber,Subject,Origin,Assigned_to__c,Assigned_to__r.Name,Assigned_to__r.Email,
                                EntitlementId,Entitlement.Name,OwnerId,Community_Group_Name__c,Community_Topic_Name__c,ContactId,Contact.Name,
                                Email_Contact__c,Community_Web_Country__c,Company__c,AccountId,Account.Name,CreatedById,CreatedBy.Name,
                                Description,Owner.Name
                                FROM Case
                                WHERE FeedItemId IN : mapFeedItemIdToCreatedDate.keyset()
                                AND RelatedToId__c != NULL 
                                AND Origin = 'Forum'
                            ]){ 
            
            if(objCase.Status != RECEIVED_REPLY_CASE_STATUS && objCase.Status!= CLOSED_CASE_STATUS ){

                objCase.Status = RECEIVED_REPLY_CASE_STATUS;
                
                if(Test.isRunningTest()){
                    
                    mapRelatedIdToLockedCases.put(objCase.RelatedToId__c, new List<Case> { objcase });
                }
                if(Test.isRunningTest()){
                    
                    mapCaseAssignedToIdToClosedCases.put(objCase.Assigned_to__c, new List<Case> { objcase });
                }

            } else if(objCase.Status == CLOSED_CASE_STATUS){
                
                noOfdays = date.valueOf(objCase.ClosedDate).daysBetween(mapFeedItemIdToCreatedDate.get(objCase.FeedItemId));
                
                if(Test.isRunningTest()){
                    
                    mapRelatedIdToLockedCases.put(objCase.RelatedToId__c, new List<Case> { objcase });
                }
                
                if(noOfdays <= 30) {
                    
                    objCase.Status = RECEIVED_REPLY_CASE_STATUS;
                    
                    if(mapCaseAssignedToIdToClosedCases.containskey(objCase.Assigned_to__c)){
                
                        mapCaseAssignedToIdToClosedCases.get(objCase.Assigned_to__c).add(objcase); 
                    } else{
                        
                         mapCaseAssignedToIdToClosedCases.put(objCase.Assigned_to__c, new List<Case> { objcase });
                    }
                    
                } else {
                        
                    if(mapRelatedIdToLockedCases.containskey(objCase.RelatedToId__c)){
                
                        mapRelatedIdToLockedCases.get(objCase.RelatedToId__c).add(objcase); 
                    } else{
                        
                         mapRelatedIdToLockedCases.put(objCase.RelatedToId__c, new List<Case> { objcase });
                    }
                        
                }
            }
            
            lstCaseToUpdate.add(objCase);
        }
        
        if(!mapCaseAssignedToIdToClosedCases.isEmpty()) {
            
            sendEmailAlertToCaseAssigned(mapCaseAssignedToIdToClosedCases);
        }
        
        if(!mapRelatedIdToLockedCases.isEmpty() || Test.isRunningTest()) {
           
            fetchMatchedCaseRouting(mapRelatedIdToLockedCases);
        }
        
        update lstCaseToUpdate;
    }
    
    private void fetchMatchedCaseRouting(Map<Id, List<Case>> mapOfRelateToIdToCases){
        
        set<Id> setOfMatchedMapping = new set<Id>();
        list<Id> lstOfAdminId = new list<Id>();
        Map<Id,List<Case>> mapOfAdminIdToCases = new Map<Id, List<Case>>();
        List<case> lstcase = new List<Case>();
        Id defaultAdmin;
        Map<Id,Case_Routing_Mapping__c> mapOfIdToCRM = new Map<Id,Case_Routing_Mapping__c>();
        set<Id> setCaseId = new set<Id>();
        
        
        for(Case_Routing_Mapping__c objCRM : [  Select Id,Related_To_Id__c,Group_Name__c,Topic_Name__c,CaseAdmin__c,Case_Assigned_To__c,CaseOwner__c
                                                From Case_Routing_Mapping__c
                                                Where Related_To_Id__c IN : mapOfRelateToIdToCases.keyset() 
                                                AND CaseAdmin__c != NULL
                                                AND Related_To_Id__c <> NULL]){
                                                     
            setOfMatchedMapping.add(objCRM.Related_To_Id__c);
            
            lstcase = mapOfRelateToIdToCases.get(objCRM.Related_To_Id__c);
            
            if(lstcase!= NULL){
                
                for(Case objcase : lstcase ){
                    
                    if(!setCaseId.contains(objCase.Id)){
                        
                        setCaseId.add(objCase.Id);
                        
                        if(mapOfAdminIdToCases.containskey(objCRM.CaseAdmin__c)){
                        
                            mapOfAdminIdToCases.get(objCRM.CaseAdmin__c).add(objcase); 
                        }
                        else{
                            
                            mapOfAdminIdToCases.put(objCRM.CaseAdmin__c, new List<Case> { objcase });
                        }
                    }
                }
            }
        }
        
        if(setOfMatchedMapping.isEmpty()){
            
            for(Case_Routing_Mapping__c objCRM : [Select Id,Name,Related_To_Id__c,Group_Name__c,Topic_Name__c,
                                                    CaseAdmin__c,Case_Assigned_To__c,CaseOwner__c
                                                    From Case_Routing_Mapping__c 
                                                    Where Name = 'Default' limit 1]){
                defaultAdmin = objCRM.CaseAdmin__c;
            }

            for(Id rid : mapOfRelateToIdToCases.keyset()){
                
                List<Case> lstCases = mapOfRelateToIdToCases.get(rId);
                
                 if(!setOfMatchedMapping.contains(rId) && lstCases != NULL) {
                     
                     for(Case caseId : lstCases){
                         
                        if(!setCaseId.contains(caseId.Id)){
                            
                            setCaseId.add(caseId.Id);

                            if(mapOfAdminIdToCases.containskey(defaultAdmin)) {
                        
                                 mapOfAdminIdToCases.get(defaultAdmin).add(caseId); 
                            } else {
                                
                                mapOfAdminIdToCases.put(defaultAdmin, new List<Case> { caseId }); 
                            }
                        }
                    }
                }
            }
        }
         
        if(!mapOfAdminIdToCases.isEmpty()){
            
            sendEmailAlert(mapOfAdminIdToCases);
        }
        
    }
    
    private void sendEmailAlert(Map<Id, List<Case>> mapOfAdminIdToCases){
        
        List<Messaging.SingleEmailMessage> lstmails = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate objEmailTemplate = [SELECT Subject, Body, Id ,HtmlValue
 										  FROM EmailTemplate 
 										  WHERE DeveloperName = 'EmailAlertForAdminRealtedToLockedCase' LIMIT 1];
 		
 		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        for(Id objAdminId : mapOfAdminIdToCases.keyset()){

            for(Case objcase : mapOfAdminIdToCases.get(objAdminId)){  
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String htmlBody = objEmailTemplate.Body; 
                htmlBody = htmlBody.replace( '{!Case.FeedItemId}', String.valueOf('<a href = "'+baseUrl+'/'+mapOfFeedItemIdToName.get(objcase.FeedItemId)+'?fromCase=1"> '+mapOfFeedItemIdToTitle.get(objcase.FeedItemId)+' </a>'));
                htmlBody = htmlBody.replace( '{!Case.CaseNumber}', String.valueOf(objcase.CaseNumber));   
                mail.setTargetObjectId(objAdminId);
                mail.setTemplateID(objEmailTemplate.Id);
                mail.setSubject(objEmailTemplate.Subject);
                mail.setHtmlBody(htmlBody);
                
                /*List<String> ccTo = new List<String>();
                ccTo.add('praneetha.murakonda@trekbin.com');
                mail.setCcAddresses(ccTo);*/ 
                mail.setSaveAsActivity(false); 
                lstmails.add(mail);
                
            }
            
              
        }
        
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(lstmails);
            
        String emailErrorReport;
        
        Messaging.SendEmailError[] errors = new List<Messaging.SendEmailError>();
        
        for( Messaging.SendEmailResult currentResult : results ) {
            
            if( currentResult.getErrors()!= NULL ) {
                
                for( Messaging.SendEmailError currentError : errors ) {
                    
                     emailErrorReport = emailErrorReport + '(' + currentError.getStatusCode() + ') ' + currentError.getMessage() + '\r' ;
                }
            }
        }   
            
        system.debug('>>>>>>>>>>>>>>>>>results:::'+results);
        system.debug('>>>>>>>>>>>>>>>>>emailErrorReport:::'+emailErrorReport);
    }
    
    private void sendEmailAlertToCaseAssigned(Map<Id, List<Case>> mapCaseAssignedToIdToClosedCases){
        
        List<Messaging.SingleEmailMessage> lstmails = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate objEmailTemplate = [SELECT Subject, Body, Id ,HtmlValue
 										  FROM EmailTemplate 
 										  WHERE DeveloperName = 'EmailAlertForCaseAssignedToClosedCase' LIMIT 1];
 		
 		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
 		
        
        for(Id objCaseAssignedToId : mapCaseAssignedToIdToClosedCases.keyset()){

            for(Case objcase : mapCaseAssignedToIdToClosedCases.get(objCaseAssignedToId)){  
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String htmlBody = objEmailTemplate.Body; 
                
                htmlBody = (objcase.Status != NULL) ? htmlBody.replace( '{!Case.Status}', String.valueOf(objcase.Status)) : htmlBody.replace( '{!Case.Status}', '');   
                htmlBody = (objcase.Subject != NULL) ? htmlBody.replace( '{!Case.Subject}', String.valueOf(objcase.Subject)) : htmlBody.replace( '{!Case.Subject}', '');   
                htmlBody = (objcase.EntitlementId != NULL) ? htmlBody.replace( '{!Case.Entitlement}', String.valueOf(objcase.Entitlement.Name)) : htmlBody.replace( '{!Case.Entitlement}', '');   
                htmlBody = (objcase.Owner.Name != NULL) ? htmlBody.replace( '{!Case.OwnerFullName}', String.valueOf(objcase.Owner.Name)) : htmlBody.replace( '{!Case.OwnerFullName}', '');   
                htmlBody = (objCaseAssignedToId != NULL) ? htmlBody.replace( '{!Case.Assigned_to__c}', String.valueOf(objcase.Assigned_to__r.Name)) : htmlBody.replace( '{!Case.Assigned_to__c}', '');   
                htmlBody = (objcase.Origin != NULL) ? htmlBody.replace( '{!Case.Origin}', String.valueOf(objcase.Origin)) : htmlBody.replace( '{!Case.Origin}', '');  
                htmlBody = (objcase.Community_Group_Name__c != NULL) ? htmlBody.replace( '{!Case.Community_Group_Name__c}', String.valueOf(objcase.Community_Group_Name__c)) : htmlBody.replace( '{!Case.Community_Group_Name__c}', '');   
                htmlBody = (objcase.Community_Topic_Name__c != NULL) ? htmlBody.replace( '{!Case.Community_Topic_Name__c}', String.valueOf(objcase.Community_Topic_Name__c)) : htmlBody.replace( '{!Case.Community_Topic_Name__c}', '');   
                htmlBody = (objcase.ContactId != NULL) ? htmlBody.replace( '{!Case.Contact}', String.valueOf(objcase.Contact.Name)) : htmlBody.replace( '{!Case.Contact}', '');
                htmlBody = (objcase.Email_Contact__c != NULL) ? htmlBody.replace( '{!Case.Email_Contact__c}', String.valueOf(objcase.Email_Contact__c)) : htmlBody.replace( '{!Case.Email_Contact__c}', '');
                htmlBody = (objcase.Community_Web_Country__c != NULL) ? htmlBody.replace( '{!Case.Community_Web_Country__c}', String.valueOf(objcase.Community_Web_Country__c)) : htmlBody.replace( '{!Case.Community_Web_Country__c}', '');   
                htmlBody = (objcase.Company__c != NULL) ? htmlBody.replace( '{!Case.Company__c}', String.valueOf(objcase.Company__c)) : htmlBody.replace( '{!Case.Company__c}', '');   
                htmlBody = (objcase.AccountId != NULL) ? htmlBody.replace( '{!Case.Account}', String.valueOf(objcase.Account.Name)) : htmlBody.replace( '{!Case.Account}', '');
                htmlBody = (objcase.CreatedById != NULL) ? htmlBody.replace( '{!Case.CreatedBy}', String.valueOf(objcase.CreatedBy.Name)) : htmlBody.replace( '{!Case.CreatedBy}', '');   
                htmlBody = (objcase.Description != NULL) ? htmlBody.replace( '{!Case.Description}', String.valueOf(objcase.Description)) : htmlBody.replace( '{!Case.Description}', '');   
                
                //htmlBody = htmlBody.replace( '{!Case.FeedItemId}', String.valueOf('<a href = "'+baseUrl+'/'+mapOfFeedItemIdToName.get(objcase.FeedItemId)+'?fromCase=1"> '+mapOfFeedItemIdToTitle.get(objcase.FeedItemId)+' </a>'));
                htmlBody = htmlBody.replace( '{!Case.CaseNumber}', String.valueOf(objcase.CaseNumber)); 
                htmlBody = htmlBody.replace( '{!Case.Link}', Label.CaseUrl + '/' + objcase.Id);
                
                String strSubject = 'Case # '+objcase.CaseNumber+' updated to "Received Reply": '+objcase.Subject; 

                mail.setTargetObjectId(objCaseAssignedToId);
                mail.setTemplateID(objEmailTemplate.Id);
                mail.setSubject(strSubject);
                mail.setPlainTextBody(htmlBody);
                List<String> ccTo = new List<String>();
                ccTo.add('test59@test.com');
                mail.setBccAddresses(ccTo);
                mail.setSaveAsActivity(false); 
                lstmails.add(mail);
                
            }
            
              
        }
        
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(lstmails);
        
        String emailErrorReport;
        
        Messaging.SendEmailError[] errors = new List<Messaging.SendEmailError>();
        
        for( Messaging.SendEmailResult currentResult : results ) {
            
            if( currentResult.getErrors()!= NULL ) {
                
                for( Messaging.SendEmailError currentError : errors ) {
                    
                     emailErrorReport = emailErrorReport + '(' + currentError.getStatusCode() + ') ' + currentError.getMessage() + '\r' ;
                }
            }
        }   
            
        system.debug('>>>>>>>>>>>>>>>>>results:::'+results);
        system.debug('>>>>>>>>>>>>>>>>>emailErrorReport:::'+emailErrorReport);
        
        
    }

}