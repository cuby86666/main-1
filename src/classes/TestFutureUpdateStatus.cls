/*  
   @Last Modified By     : Manoj 
   @Last Modified Date   : 09 Mar, 2015 
   @Description : Added @isTest annotation at class level. 
*/

@isTest
public class TestFutureUpdateStatus{
    @isTest
    private static void TestFutureUpdateStatus(){
        New_User_Registeration__c nur = new New_User_Registeration__c();
        nur.First_Name__c = 'Test';
        nur.Last_Name__c = 'Test';
        insert nur;                        
        Set<string> ids = new Set<string>();
        ids.add(nur.id);        
        FutureUpdateStatus.updateStatus(ids);
        List<New_User_Registeration__c> nwList = [select id,name,status__C from New_User_Registeration__c where id in: ids and status__C = 'User A/c Created'];
        system.assert(ids.size() != nwLIst.size(), 'Updation Failed');
    }
}