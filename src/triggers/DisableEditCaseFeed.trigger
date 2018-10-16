/*****************************************************************************************
@Created By :   Ranganath C N
@Created Date:  07 Sep 2018
@Description:    To disable the edit and delete feed as a part of SFDC-1967.
*******************************************************************************************/
trigger DisableEditCaseFeed on FeedItem (before update,before delete) 
{
    if(trigger.isUpdate){
               for(FeedItem f : Trigger.new){
               
               if (((String)f.parentId).startsWith('500')   ) {
               
               f.addError('Your administrator has disabled this action in feed post and comment.'); 
          }  
       }   
    }    
       if(trigger.isDelete){
        for(FeedItem f : Trigger.old){
               
               if (((String)f.parentId).startsWith('500')   ) {
               
               f.addError('Your administrator has disabled this action in feed post and comment.'); 
        }
      }
    }
        
  }