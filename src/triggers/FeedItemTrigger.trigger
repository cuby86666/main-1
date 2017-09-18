trigger FeedItemTrigger on FeedItem (before insert, After Update) {
    
    if(trigger.isAfter){
        
        FeedItemTriggerCommunityHandler objFeedItemTriggerCommunityHandler = new FeedItemTriggerCommunityHandler();
        if(trigger.isUpdate){
            
            system.debug('updateTRigger -->'+Trigger.new);
            
            objFeedItemTriggerCommunityHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if(Trigger.isBefore) {
        
        if(Trigger.isInsert) {
            
            if(UserInfo.getUserType() == 'Standard') {
                
                FeedItemTriggerCommunityHandler.updateLastQuestionNetworkId(Trigger.new);  
            }
        }
    }
}