/* Createdby : Sumanth
   CreatedDate :
   Description : to share customer record with CAS engineers
*/ 
/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 
/* Last ModifiedBy : Anil Somani
   Last ModifiedDate : 24 Jan 2018
   Description : Selecting Standard User directly instead of randomly selecting user from the org.
*/

@istest
public class CustomerObjectSharingTest
{
    private static final String TEST_USER_PROFILE = 'Standard User';
    private static final String TEST_USER = 'T_user';
    
    static testmethod void CustomerObjectSharingTest1()
    {
       date mydate1 = date.parse('05/24/2017');
       date mydate2 = date.parse('05/01/2017');
       
       //Create Parent Account
       Account a = new Account();
       a.Name='Test parent';
       insert a;
       
       //Create Child Account
       Account Child = new Account();
       child.name='Test Child';
       child.Parent=a;
       child.RecordtypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Child Account').getRecordTypeId();
       insert child;
       
       //Create opportunity
       Opportunity Opp = new Opportunity();
       Opp.Name='Test opty';
       Opp.CloseDate=mydate1;
       Opp.Production_Date__c=mydate2;
       Opp.CurrencyIsoCode='USD';
       Opp.Account=Child;
       opp.Channel__c='Direct';
       opp.StageName='Discovery';
       opp.X2010_Pieces__c=1;
       opp.X2011_Pieces__c=1;
       opp.X2012_Pieces__c=1;
       opp.X2013_Pieces__c=1;
       opp.X2014_Pieces__c=1;
       opp.X2015_Pieces__c=1;
       opp.X2010_Pieces__c=1;
       opp.X2016_Pieces__c=1;
       opp.X2017_Pieces__c=1;
       opp.X2018_Pieces__c=1;
       opp.X2019_Pieces__c=1;
       opp.X2020_Pieces__c=1;
       opp.X2021_Pieces__c=1;
       opp.X2022_Pieces__c=1;
       opp.X2023_Pieces__c=1;
       opp.X2024_Pieces__c=1;
       opp.X2025_Pieces__c=1;
       opp.X2026_Pieces__c=1;
       opp.X2027_Pieces__c=1;
       opp.X2028_Pieces__c=1;
       opp.X2029_Pieces__c=1;
       opp.X2030_Pieces__c=1;
       opp.Executive_Summary__c='test';
       insert opp;
       
       
       //Insert Customer Project
       Customer_Project__c CP = new Customer_Project__c();
       CP.Name='Test Project';
       CP.Opportunity__c=opp.id;
       CP.Project_Phase__c='Development';
       CP.Project_Status__c='Green';
       insert CP;
       
       
       //Insert Techincal Project Team
       Profile p = [select Id from Profile where Name = :TEST_USER_PROFILE];
       // insert a test user
       List<User> listUser=new list<user>();
       listUser.add(createUser(TEST_USER,TEST_USER , p.Id,'test@test.com'));
       listUser.add(createUser(TEST_USER,TEST_USER , p.Id,'test1@test1.com'));
       
       insert listUser;
       listUser= [SELECT Id FROM User where Id in:listUser and IsActive = true LIMIT 2 ];
       
       Technical_Support_Team__c Team = new Technical_Support_Team__c();
       Team.Customer_Project__c=CP.Id;
       Team.CAS_1_Engineer__c=listUser[0].id;
       Team.CAS_2_Engineer__c=listUser[1].id;
       
       insert Team;
       
       list<Customer_Project__share> shares=[SELECT Id, UserOrGroupId, AccessLevel,RowCause FROM Customer_Project__share WHERE ParentId = :CP.Id AND (UserOrGroupId= :listUser[0].id OR UserOrGroupId= :listUser[1].id) ];
       
       System.assertEquals(shares.size(), 2);
       //for delete condition
       
       delete team;
       
    }

    static User createUser(String alias, String lastName, ID profileID, String email)
    {
       User user = new User(EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
       user.Alias = alias;
       user.LastName = lastName;
       user.ProfileId = profileID;
       user.Email = email;
       user.UserName = 'abcd'+email;
       
       return user;  
    }
}