trigger FeedItemTrigger on FeedItem (After Update) {
    
    if(trigger.isAfter){
        
        FeedItemTriggerCommunityHandler objFeedItemTriggerCommunityHandler = new FeedItemTriggerCommunityHandler();
        if(trigger.isUpdate){
            
            system.debug('updateTRigger -->'+Trigger.new);
            
            objFeedItemTriggerCommunityHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}