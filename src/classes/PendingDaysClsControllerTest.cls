@IsTest
public class PendingDaysClsControllerTest{
    public static testmethod void theTest(){
        PendingDaysClsController cls = new PendingDaysClsController
        (new ApexPages.StandardController(new Approver_History__c()));
        
        cls.Run_Calculate_Approver_Pending_Days();
    }
}