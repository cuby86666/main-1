/*  
   @Last Modified By     : Manoj 
   @Last Modified Date   : 09 Mar, 2015 
   @Description : Added @isTest annotation at class level. 
*/


@isTest
Public Class TestNewContact {
@isTest
    private static void TestNewContact(){
        Account acc = new Account();
        acc.Name='Training1';
        insert acc;
        
        Id ProfileId = [Select id from profile where name = 'System Administrator' limit 1].Id;
        
        User testUser = new User();
        testUser.firstName = 'Test5454FirstName1';
        testUser.LastName = 'Test454LastName1';
        testUser.Alias = 'Ts4t1';
        testUser.Email = 'tes45t1@testorg.com';
        testUser.UserName= 'test11@te45storg.com' ;
        testUser.ProfileId = ProfileId;
        testUser.CommunityNickname = testUser.firstname+'_'+testUser.lastName;
        testUser.EmailEncodingKey ='ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey ='America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.Country = 'USA';
        testUser.ForecastEnabled = true;
        insert testUser;
        
        List<Contact> contList = [select id, FirstName, LastName, email, AccountId from contact where FirstName =: testUser.FirstName AND LastName =: testUser.LastName AND AccountId =: acc.id];
        Contact con = new Contact();
        if(contList.size() > 0){
            con = contList.get(0);
        }
        
        system.assert(con != null,'Contact Not Found');
    }
}