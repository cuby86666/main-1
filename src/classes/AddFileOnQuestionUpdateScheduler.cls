global class AddFileOnQuestionUpdateScheduler implements Schedulable {
    
    public List<FeedAttachment> lstFeedAttach = new List<FeedAttachment>();
     
    global AddFileOnQuestionUpdateScheduler(List<FeedAttachment> lstFeedAttachment){
        
        this.lstFeedAttach = lstFeedAttachment;
    }
     
    global void execute(SchedulableContext SC) { 
     
        insert lstFeedAttach;
    }
}