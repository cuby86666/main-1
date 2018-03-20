@isTest
public class TestCustSamlJITHandler {
   @isTest
    public static void testUserCreation()
    {
        //Testing Creating Test Data
        Account a= new Account();
        a.Name='NXP Community';
        insert a;
        
        //Inserting Custom setting Record
         CommunitySettings__c cs = new CommunitySettings__c (Name = 'CommunityUrl');
         cs.CommunityUserAccountId__c = a.id;
         insert cs;
       //End of Test Data
        
        CustSamlJitHandler jitHandler =  new CustSamlJitHandler();
        Map<String,String> attributes = new Map<String,String>();
        attributes.put('User.Email','test@tesemail.com');
        attributes.put('User.FirstName','UserFirstName');
        attributes.put('User.LastName','UserLastName');
        attributes.put('User.CompanyName','NXP');
        attributes.put('User.Country','USA');
        User U=jitHandler.createUser(Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'), 'test@test.com', attributes, 'true');
        System.assertEquals('test@tesemail.com',U.Email);
        //jitHandler.updateUser(U.Id,Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'), 'test@test.com', attributes, 'true');
        
    }
    
    
     @isTest
    public static void testUserCreation2()
    {
        //Testing Creating Test Data
        Account a= new Account();
        a.Name='NXP Community';
        insert a;
        
        //Inserting Custom setting Record
         CommunitySettings__c cs = new CommunitySettings__c (Name = 'CommunityUrl');
         cs.CommunityUserAccountId__c = a.id;
         insert cs;
       //End of Test Data
        
        CustSamlJitHandler jitHandler =  new CustSamlJitHandler();
        Map<String,String> attributes = new Map<String,String>();
        attributes.put('User.Email','test@tesemail.com');
        attributes.put('User.FirstName','UserFirstName');
        attributes.put('User.LastName','UserLastName');
        attributes.put('User.CompanyName','NXP');
        attributes.put('User.Country','USA');
        jitHandler.createUser(Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'), 'notblankvalue', attributes, 'true');
        jitHandler.createUser(Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'), 'test@test.com', attributes, 'true');
        
    }
    
     @isTest
    public static void testUserCreation3()
    {
        //Testing Creating Test Data
        Account a= new Account();
        a.Name='NXP Community';
        insert a;
        
        //Inserting Custom setting Record
         CommunitySettings__c cs = new CommunitySettings__c (Name = 'CommunityUrl');
         cs.CommunityUserAccountId__c = a.id;
         insert cs;
         
       //Inserting User for Update method
       Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'test',
                           FirstName='testagain',
                           Alias = 'tagain',
                           Email = 'test@123.com',
                           Username = 'test1245@123.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
       insert Usr;
         
       //End of Test Data
        
        CustSamlJitHandler jitHandler =  new CustSamlJitHandler();
        Map<String,String> attributes = new Map<String,String>();
        attributes.put('User.Email','test@tesemail.com');
        attributes.put('User.FirstName','UserFirstName');
        attributes.put('User.LastName','UserLastName');
        attributes.put('User.CompanyName','NXP');
        attributes.put('User.Country','USA');
        jitHandler.updateUser(usr.Id,Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'), 'fedidnoblank', attributes, 'true');
        //jitHandler.createUser(Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'),Id.valueOf('00D4E0000008kQF'), 'test@test.com', attributes, 'true');
        
    }
}