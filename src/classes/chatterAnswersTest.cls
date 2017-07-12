/* @Created By: Baji
 * @Created Date:10 Mar, 2015
 * @Description: To improve code coverage
 */
@isTest
public class chatterAnswersTest {
    
    static testMethod Void testChatterAnswers(){
        Account acc = new Account();
        acc.Name='Training1';
        insert acc;
        
        Id ProfileId = [Select id from profile where name = 'System Administrator' limit 1].Id;
        
        User testUser = new User();
        testUser.firstName = 'Test5454FirstName2';
        testUser.LastName = 'Test454LastName2';
        testUser.Alias = 'Ts4t2';
        testUser.Email = 'tes45t2@testorg.com';
        testUser.UserName= 'test12@te45storg.com' ;
        testUser.ProfileId = ProfileId;
        testUser.CommunityNickname = testUser.firstname+'_'+testUser.lastName;
        testUser.EmailEncodingKey ='ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey ='America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.Country = 'USA';
        testUser.ForecastEnabled = true;
        insert testUser;
        ChatterAnswers c = new ChatterAnswers();
        c.createAccount(testUser.firstname,testUser.Lastname,testUser.id);
        // ChatterAnswers.createAccount(testUser.firstname,testUser.Lastname,testUser.id);
        
    }

}