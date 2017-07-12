/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to GSASTestUtility.createTestData().
*/ 

@isTest
public class RecordLockUtilityTest {
    static testMethod void lockTest() {
        GSASTestUtility.createTestDataWithoutFFC();
        Opportunity[] aryOppty = [Select Id from Opportunity];
        List<Id> lstIds = new List<Id>();
        for(Opportunity oppty : aryOppty) {
            lstIds.add(oppty.Id);
        }
        Test.startTest();
        RecordLockUtility.lock(lstIds);
        Test.stopTest();
    }
    static testMethod void unlockTest() {
        GSASTestUtility.createTestDataWithoutFFC();
        Opportunity[] aryOppty = [Select Id from Opportunity];
        List<Id> lstIds = new List<Id>();
        for(Opportunity oppty : aryOppty) {
            lstIds.add(oppty.Id);
        }
        Test.startTest();
        RecordLockUtility.unlock(lstIds);
        Test.stopTest();
    }
    static testMethod void lockBatchTest() {
        GSASTestUtility.createTestDataWithoutFFC();
        Opportunity[] aryOppty = [Select Id from Opportunity];
        //create RecordLockId record
        List<RecordLockId__c> lstRecLockId = new List<RecordLockId__c>();
        for(Opportunity opp : aryOppty) {
            lstRecLockId.add(new RecordLockId__c(Name = opp.Id));
        }
        insert lstRecLockId;
        Test.startTest();
        RecordLockUtilityBatch obj = new RecordLockUtilityBatch('lock', true);
        database.executebatch(obj);
        Test.stopTest();
    }
    static testMethod void unlockBatchTest() {
        GSASTestUtility.createTestDataWithoutFFC();
        Opportunity[] aryOppty = [Select Id from Opportunity];
        //create RecordLockId record
        List<RecordLockId__c> lstRecLockId = new List<RecordLockId__c>();
        for(Opportunity opp : aryOppty) {
            lstRecLockId.add(new RecordLockId__c(Name = opp.Id));
        }
        insert lstRecLockId;
        Test.startTest();
        RecordLockUtilityBatch obj = new RecordLockUtilityBatch('unlock');
        database.executebatch(obj);
        Test.stopTest();        
    }
}