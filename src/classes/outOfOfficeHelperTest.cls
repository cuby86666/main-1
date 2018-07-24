/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Ranganath
 * Created Date : 04 May,2018
 * Description   : To check overlap for back-up person
 ------------------------------------------------------------------------------------------------------------------*/
@isTest
private class outOfOfficeHelperTest 
{

 static testMethod void outOfOfficeTest() 
    {
              Id std_Id;
              Id support_Id;
              string STD_User='Standard User';
              String Sup_User='NXP Tech Support';
                
              if(std_Id==null && support_Id==null)
              {        
              for(profile p:[Select Id,Name From Profile Where  (Name =:STD_User OR Name =:Sup_User)])
              {         
              if(p.Name ==STD_User ) 
              {
                  std_Id=p.id;  
              }
              else if(p.Name == Sup_User)
              {
                  support_Id=p.id;  
              }
          }
         }
        User user1 = new User(Username='Uname@testuser.org',
                                LastName='LName',
                                Email='usertotestnick1@test.com',
                                Alias='Alias',
                                CommunityNickname='usertotestnick1',
                                TimeZoneSidKey='America/Los_Angeles',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='UTF-8',
                                ProfileId=std_Id ,
                                LanguageLocaleKey='en_US');
        User user2 = new User(Username='Uname1@testuser.org',
                                LastName='LName1',
                                Email='usertotestnick2@test.com',
                                Alias='Alias1',
                                CommunityNickname='usertotestnick2',
                                TimeZoneSidKey='America/Los_Angeles',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='UTF-8',
                                ProfileId=support_Id,
                                LanguageLocaleKey='en_US');
        
        List<User> allUsers = new List<User>();
        allUsers.add(user1);
        allUsers.add(user2);
        insert(allUsers);
        
        Map<Id, User> allUsersMap = new Map<Id, User>(allUsers);
        List<Id> userIds = new List<Id>(allUsersMap.keyset());
        Id user1Id = userIds.get(0);
        Id user2Id = userIds.get(1);
        Date Today= Date.today();
        Date nextDay = Date.today().addDays(+1);
        
        Test.startTest();
        Out_Of_Office_Log__c outOfOfficeLog = new Out_Of_Office_Log__c();
        outOfOfficeLog.Person_taking_time_off__c=user1Id;
        outOfOfficeLog.Backup_Person__c=user2Id;
        outOfOfficeLog.Start_Date__c = Today;
        outOfOfficeLog.End_Date__c=nextDay ;
        insert outOfOfficeLog;
        
        Out_Of_Office_Log__c outOfOfficeLog2 = new Out_Of_Office_Log__c();
        outOfOfficeLog2.Person_taking_time_off__c=user2Id;
        outOfOfficeLog2.Backup_Person__c=user1Id;
        outOfOfficeLog2.Start_Date__c = Today;
        outOfOfficeLog2.End_Date__c=nextDay ;
        try{
        insert outOfOfficeLog2;
        } catch(exception e){}
      
       Test.stopTest();
    }
   }