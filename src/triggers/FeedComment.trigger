trigger FeedComment  on FeedComment  (after insert) {    
    
    FeedCommentTriggerHandler objhandler = new FeedCommentTriggerHandler();
    
    if(Trigger.isAfter && Trigger.isInsert){ // && !FeedCommentTriggerHandler.isCalledOnce
        
        objhandler.onAfterInsert(Trigger.New);
        ShareFile.shareFile(Trigger.New); 
        //FeedCommentTriggerHandler.isCalledOnce = true;
    }
}