public without sharing class ShareFile {

    public static void shareFile(List<FeedComment> lstFeedComments) {
    
        FeedComment objFeedComment = lstFeedComments[0];
        Id FeedItemId;
        if(objFeedComment.CommentType != 'ContentComment') return;
        List<Case> lstCase = [SELECT Id,FeedItemId
                                FROM Case
                                WHERE FeedItemId =:objFeedComment.FeedItemId];
        if(lstCase.isEmpty()) {
            
            return;
        }else {
            
            FeedItem objFeedItem;
            List<FeedItem> existingFeedItem = new List<FeedItem>([SELECT Title, ParentId 
                                                                  FROM FeedItem 
                                                                  WHERE Title = 'File Holder' 
                                                                  AND ParentId =:lstCase[0].Id]);
            
            if(existingFeedItem.isEmpty()){
                
                objFeedItem = new FeedItem(Title = 'File Holder', Body='File Holder', ParentId = lstCase[0].Id, Visibility = 'AllUsers');
                insert objFeedItem;
            }
            
            ContentVersion objContentVersion = [SELECT FileExtension,FileType,Title,VersionData FROM ContentVersion where Id =: objFeedComment.RelatedRecordId limit 1];
           
            FeedAttachment objFeedAttachment = new FeedAttachment(FeedEntityId = !existingFeedItem.isEmpty() ? existingFeedItem[0].Id : objFeedItem.Id,
                                                                  RecordId = objContentVersion.Id, Type = 'CONTENT');
            insert objFeedAttachment;
        }
        
        
    }
}