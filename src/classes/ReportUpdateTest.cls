@isTest
public class ReportUpdateTest{
    public static TestMethod  void runTest(){
        List<RecordType> rtypes = [Select Name, Id From RecordType 
                  where sObjectType='Account' and isActive=true AND Name='Parent Account'];
        // Dummy Parent Account
        Account acc = new Account(Name='Test Parent Account',Customer_Category__c='Regional');
        acc.Init_Comm_Prob__c = 13;
        acc.Init_Lost_Prob__c = 23;
        acc.Disc_Comm_Prob__c =8;
        acc.Disc_Lost_Prob__c = 8;
        acc.Asse_Comm_Prob__c = 5;
        acc.Asse_Lost_Prob__c = 10;
        acc.Reco_Comm_Prob__c = 6;
        acc.Reco_Lost_Prob__c = 5;
        acc.Deci_Comm_Prob__c = 0;
        acc.Deci_Lost_Prob__c = 0;
        if(rtypes.size() > 0){
            acc.RecordTypeId = rtypes[0].Id;
        }
        insert acc;
    }
}