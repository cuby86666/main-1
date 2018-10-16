/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Gunjan
 * Created Date : 24 Aug,2018
 * Description  : Webservice class to update fields on case for SFDC-1971
 ------------------------------------------------------------------------------------------------------------------*/


@RestResource(urlMapping='/UpdateCaseService/*')
global with sharing class CaseUpdateService {
    global class CaseInputDetails{
        public String CaseID ;
        public String CaseNumber;
        public String CaseStatus;
        public String Priority;
        public String FeedMessage;
        public String CaseOwner;
        public String CaseAssignedTo;
        public String Topic;
    }
    
    global class OutputMessage {
        public String message;
    }
    
    @HttpPatch
    global static OutputMessage updateCase(CaseInputDetails caseInput){
         
        if(caseInput.CaseID != Null || caseInput.CaseNumber != Null){
            Database.DMLOptions caseAssignmentRuleOptions = new Database.DMLOptions();
            caseAssignmentRuleOptions.assignmentRuleHeader.useDefaultRule = false;
            Case caseRecord = new Case();
            if(caseInput.CaseID != Null){
                caseRecord = [Select Id,status,My_Question_is_Related__c,Assigned_to__r.Email,CaseNumber,LastModifiedBy.email,Priority,OwnerId,FeedItemId,ClosedDate,CreatedDate from Case where Id= :caseInput.CaseID ];
            }
            if(caseInput.CaseNumber != Null){
                caseRecord = [Select Id,status,My_Question_is_Related__c,Assigned_to__r.Email,CaseNumber,LastModifiedBy.email,Priority,OwnerId,FeedItemId,ClosedDate,CreatedDate from Case where CaseNumber = :caseInput.CaseNumber];
            }
            caseRecord.setOptions(caseAssignmentRuleOptions);
            Long dt1Long = 0;
            if(caseRecord.ClosedDate != Null){
                dt1Long = caseRecord.ClosedDate.getTime();
            }
        
            Long dt2Long = system.now().getTime();
            Long milliseconds = dt2Long - dt1Long;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long days = hours / 24;
            system.debug('Value of days'+ days);
            
            if(caseRecord.status != 'Close' || (caseRecord.status == 'Close' && days < 30)){
                    system.debug('Inside If');
             
                    if(caseInput.FeedMessage != Null){
                        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                        
                        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                        
                        textSegmentInput.text = caseInput.FeedMessage;
                        messageBodyInput.messageSegments.add(textSegmentInput);
                        
                        feedItemInput.body = messageBodyInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId = caseInput.CaseID;
                        
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                    
                    }
                    
                    if(caseInput.CaseStatus !=null){
                        caseRecord.status = caseInput.CaseStatus;
                    }   
              
                if(caseInput.Priority !=null){
                        caseRecord.Priority= caseInput.Priority;
                }
                
                if(caseInput.CaseOwner !=null && caseInput.CaseOwner.trim() != ''){
                   if(caseInput.CaseOwner.contains('@')){
                        caseRecord.OwnerId= getUserIdForEmail(caseInput.CaseOwner);
                        system.debug('value of caseRecord.OwnerId'+caseRecord.OwnerId);
                    }else{
                         caseRecord.OwnerId =getQueueIdForQueueName(caseInput.CaseOwner);
                    }
                       
                }
                if(caseInput.CaseAssignedTo !=null && caseInput.CaseAssignedTo.trim() != ''){
                       if(caseInput.CaseAssignedTo.contains('@')){
                           caseRecord.Assigned_to__c= getUserIdForEmail(caseInput.CaseAssignedTo);
                       }
                }
                    
                if(caseInput.Topic!=null){
                        caseRecord.My_Question_is_Related__c= caseInput.Topic;
                }
                
                Database.SaveResult result = Database.update(caseRecord);
                if(result.isSuccess()){
                    return sendOutput(Label.SuccessMesg);
                }
                
                else{
                    for(Database.Error err : result.getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Case fields that affected this error: ' + err.getFields());
                        return sendOutput('The following error has occurred.'+ err.getStatusCode() + ': ' + err.getMessage() +'Case fields that affected this error: ' + err.getFields());
                        
                    }
                } 
              }
              
              else{
                  return sendOutput('Update is not allowed as Case has been closed for more than 30 days');
              }
              
        }
        
        else{
            if(caseInput.CaseID == Null && caseInput.CaseNumber == Null){
                return sendOutput(Label.ErrorMesg);
            }
        }
        
        return null;     
    }
    
    private static String getUserIdForEmail(String email){
        List<User> caseOwnerUsers = [SELECT Id from User where Email=:email];
        if(caseOwnerUsers!=null && (!caseOwnerUsers.isEmpty())){
            return caseOwnerUsers.get(0).Id;
        }        
        return null;
    }
    
    private static String getQueueIdForQueueName(String queuename){
        List<Group> ownerQueue = [select Id from Group where Type = 'Queue' and Name=:queuename];
        if(ownerQueue!=null && (!ownerQueue.isEmpty())){
            return ownerQueue.get(0).Id;
        }
        return null;
    } 
    
    private static OutputMessage sendOutput(String message){
        OutputMessage outputMsg = new OutputMessage ();
        outputMsg.message = message;
        return outputMsg ;
    }  
    
 }