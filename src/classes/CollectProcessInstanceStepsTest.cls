@IsTest (seeAllData = true)
public class CollectProcessInstanceStepsTest{
    public static testMethod void theTest() {
        Test.StartTest();
        CollectProcessInstanceSteps testA = new CollectProcessInstanceSteps();
        testA.query = testA.query + ' ORDER BY ProcessInstance.CreatedDate LIMIT 1200';
        Database.executeBatch(testA, 1200);
        Test.StopTest();
    }
}