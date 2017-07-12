/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     26 April 2016
Description :      Class for Case Change Owner so that by default queue is selected in the case owner type drop down and to keep the version log changes for the Case reassignment
****************************************************************************************************/

Public with Sharing class CommunityCaseChangeOwnerController{

    public String reasssignmentReason     {set;get;}     //To capture case's reassignment reason
    String previousUserName;                             // To display previousUserName as part of the version log
    public Case caseRecord                 {set;get;}    // To store caseRecord's details
    Id previousOwnerId, previousAssignedTo, currentAssignedTo;             // To capture the case owner id and assigned to and if it is not changed
    public CommunityCaseChangeOwnerController(ApexPages.StandardController controller) {
        
        caseRecord = (Case)controller.getRecord();
        
        //Query Reason for Case Reassignment
        caseRecord = [SELECT Reason_for_Case_Reassignment__c, Status, Assigned_to__c, OwnerId, Owner.FirstName, Owner.LastName from Case where id = :caseRecord.id];
        
        previousOwnerId = caseRecord.OwnerId;
        previousAssignedTo = caseRecord.Assigned_to__c;               
        
        
    }
    
    /*
    * @name         : saveRecord
    * @description  : saves the Case record with updated owner
    * @ Input param : Null
    * @ return type : Null
    */
    public void saveRecord(){
        
        if(String.isBlank(caseRecord.OwnerId)){
            caseRecord.OwnerId = previousOwnerId;
        }
        
        if(  caseRecord.Reason_for_Case_Reassignment__c  == null){
            caseRecord.Reason_for_Case_Reassignment__c  = '';
        }

        //If Reason is not provided then append Not Provided
        if(!String.isBlank( reasssignmentReason )){

            caseRecord.Reason_for_Case_Reassignment__c = '<br/><b>'+System.now()+':Reason:</b> '+reasssignmentReason +'<br/>--------------------------------------------------<br/> '+caseRecord.Reason_for_Case_Reassignment__c;
            
            
        }
        
        
        //If assigned to is changed or Owner is changed and Reason is not blank 
        
        if( ( (previousAssignedTo != caseRecord.Assigned_to__c && caseRecord.Assigned_To__c != null )||
                    ( previousOwnerId    != caseRecord.OwnerId && String.valueOf(caseRecord.OwnerId).startsWith(User.sObjectType.getDescribe().getKeyPrefix())) && 
                    !String.isBlank( reasssignmentReason )  ) ){            
            
            
            //Post the chatter comment with the user mention for owner Id if it is of type and assigned to - if it is of type user
            
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
      
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            List<ConnectApi.TextSegmentInput> textSegmentInputs = new List<ConnectApi.TextSegmentInput>();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
   
            
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            ConnectApi.TextSegmentInput textSegmentInputOwner = new ConnectApi.TextSegmentInput();
            
            if( previousOwnerId    != caseRecord.OwnerId ){
                mentionSegmentInput.id = caseRecord.ownerid;
               
            }
            
            if(previousAssignedTo != caseRecord.Assigned_to__c ){
                mentionSegmentInput.id = caseRecord.Assigned_To__c;
               
            }
   
            
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            textSegmentInput.text = 'Reason: '+ reasssignmentReason ;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = caseRecord.id;
            
            if(!Test.isRunningTest()  ){
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput, null);
            }
        }
        currentAssignedTo  = caseRecord.Assigned_To__c;
        caseRecord.Assigned_To__c = null;
        Database.update(caseRecord);
        
        //Performing Case update twice in order to retain the assigned To value because Workflow was setting Assigned To null
        if(currentAssignedTo != previousAssignedTo){
            caseRecord.Assigned_To__c = currentAssignedTo;
            Database.update(caseRecord);
        }
        
    }   

    
}