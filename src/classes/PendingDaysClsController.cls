public with sharing class PendingDaysClsController {
    public PendingDaysClsController(ApexPages.StandardController controller) {
    }
    public void Run_Calculate_Approver_Pending_Days(){
        RemoveExistingApproverHistory RAH = new RemoveExistingApproverHistory();
        Database.executeBatch(RAH, 400);
    }    
}