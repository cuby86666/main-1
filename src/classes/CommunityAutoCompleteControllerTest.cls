@isTest
public class CommunityAutoCompleteControllerTest 
{
     static testMethod void CommunityAutoCompleteControllerTest1()
     {        
        //create some test account
        List<Account> accountList = new List<Account>();
        for(Integer i =0 ; i < 200 ; i++){
            accountList.add(new Account(Name='Test'+i));
        }
        //insert hte records
        insert accountList;
        Test.startTest();
            System.assertEquals(0,CommunityAutoCompleteController.getData('Product2','Name','Id','T').size());
            CommunityAutoCompleteController controller = new CommunityAutoCompleteController ();
        Test.stopTest();
        
    }

}