global with sharing class LeadOwnerAssignmentSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        LeadOwnerAssignmentBatch leadBatch=new LeadOwnerAssignmentBatch();
        database.executeBatch(leadBatch);
    }

}