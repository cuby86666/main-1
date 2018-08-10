@IsTest
public class CollectProcessInstanceWorkItemTest{
     @isTest(SeeAllData=true) 
     static void theTest() {       
        Test.StartTest();    
        CollectProcessInstanceWorkItem workItem = new CollectProcessInstanceWorkItem();
        workItem.query = workItem.query + ' AND ProcessInstance.TargetObject.Name != null ORDER BY ProcessInstance.CreatedDate ASC LIMIT 800';
        Database.executeBatch(workItem, 800); 
        //ID batchprocessid = Database.executeBatch(workItem, 200);
        //Database.executeBatch(new CollectProcessInstanceWorkItem());
        Test.StopTest();
    }
}