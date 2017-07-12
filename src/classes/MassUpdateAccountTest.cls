@IsTest
public class MassUpdateAccountTest{
    static void prepareData(){
        // Create Parnet Account       
        //RecordType parentRType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Parent Account'];
        Account parentAcc1 = new Account
        (
        //RecordTypeId = parentRType.Id,
        Name = 'Test Account 1',
        Region__c = 'EMEA',
        Type = 'OEM',
        Industry_Segment__c = 'Industrial',
        Sub_Segment__c = 'Smart Metering',
        NumberOfEmployees = 1500,
        AnnualRevenue = 100000
        );
        insert parentAcc1 ;
        Account parentAcc2 = new Account
        (
        //RecordTypeId = parentRType.Id,
        Name = 'Test Account 2',
        Region__c = 'Korea',
        Type = 'OEM',
        Industry_Segment__c = 'Industrial',
        Sub_Segment__c = 'Smart Metering',
        NumberOfEmployees = 1500,
        AnnualRevenue = 100000
        );
        insert parentAcc2 ;
        
        //Create Child Account
        RecordType childRType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Child Account'];
        Account childAcc = new Account
        (
        //RecordTypeId = childRType .Id,
        Name = 'Test Child Account',
        Region__c = 'EMEA'
        );
        insert childAcc ;
    }
    static testMethod void theTest(){
        prepareData();
        
        Test.StartTest();
        MassUpdateAccount updateTask = new MassUpdateAccount();
        updateTask.query = updateTask.query + ' LIMIT 200';
        Database.executeBatch(updateTask, 200);
        Test.StopTest();
    }
}