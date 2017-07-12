/*  
   @Last Modified By     : Manoj 
   @Last Modified Date   : 09 Mar, 2015 
   @Description : Added @isTest annotation at class level. 
*/

@isTest
public class TestGroupMemberController{
    @isTest
    public static void unitTest(){
        Id ProfileId = [Select id from profile where name = 'System Administrator' limit 1].Id;
        User testUser = new User();
        testUser.firstName = 'TestFirstName';
        testUser.LastName = 'TestLastName';
        testUser.Alias = 'Tst';
        testUser.Email = 'testapttus@testorg.com';
        testUser.UserName= 'testapptus@testorg.com' ;
        testUser.ProfileId = ProfileId;
        testUser.CommunityNickname = testUser.firstname+'_'+testUser.lastName;
        testUser.EmailEncodingKey ='ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey ='America/Los_Angeles';
        testUser.LocaleSidKey = 'en_US';
        testUser.Country = 'USA';
        testUser.ForecastEnabled = true;
        insert testUser;
        
        Group gp = new Group();
        gp.name = 'test';
        insert gp;
        
        GroupMember gpmem = new GroupMember();
        gpmem.GroupId = gp.id;
        gpmem.UserOrGroupId = testUser.Id;
        insert gpmem;
        
        GroupMemberController gmc = new GroupMemberController();
        
    }
}