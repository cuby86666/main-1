/*************************************************************************
@Created By:     Manikanta
@Description:    Test class for ShareLeadActivity
**************************************************************************/

@istest
 
public class ShareLeadActivityTest {
    public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser3@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser4@testorg.com.test';
    
    @testSetup
    static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        // insert a test user
            User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
        insert u;
             //Insert Accounts
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',country__c='Austria',state_province__c='Test State',Role__c='Distributor');        
        insert a;
              //Insert Contact   
        Contact con3 = new Contact(FirstName='Test',LastName='Contact', Title = 'strTitle',
                                  email = TEST_USER_EMAIL_3,AccountId=a.Id);        
        insert con3;
        
        //Insert Lead

        Lead leadrec = new Lead( LastName = 'TestLead', 
                                company= 'Testcompany', 
                                Job_Description__c = 'Director', Normalized_Title__c ='Consultant',
                                Industry = 'TestIndustry',email = TEST_USER_EMAIL_3,Phone = '12345',HasOptedOutOfEmail = false,DoNotCall =false,city = 'testcity',
                                state='teststate',street='teststreet',PostalCode = '12345',Country ='India',Rating = '5',Status = 'Open');  
        insert leadrec;
        
        // Insert Lead Activities
        
        Lead_activity__c leadact =new Lead_activity__c(Action__c ='Ordered',Object__c='TestObject',Specific_Interest__c='Test',related_to_lead__c = leadrec.id);    
        Insert leadact;
        
        // Insert Distributor_Lead_Tracker__c
         Distributor_Lead_Tracker__c disit = new Distributor_Lead_Tracker__c(Status__c ='Assigned',Lead_Id__c = leadrec.id,Distributor_Contact__c = con3.id );
        Insert disit;
         Distributor_Lead_Tracker__c disit1 = new Distributor_Lead_Tracker__c(Status__c ='Queued',Lead_Id__c = leadrec.id,Distributor_Contact__c = con3.id );
            Insert disit1;
    }
    
     @istest
    static  void testgetleads(){
        Test.startTest();
        lead LeadReturns = [select id,Name,company,Job_Description__c,Normalized_Title__c,Address,Industry,Email,
              Phone,HasOptedOutOfEmail,DoNotCall,city,state,street,PostalCode,Country,Rating,Status,Owner.Email from lead];
        ShareLeadActivity.getleads(LeadReturns.Id);
         ShareLeadActivity.fetchLeadact(LeadReturns.Id);
        List<String> ss = new List<String> ();
        ss.add('Test');
        ss.add('Test1');
       
       ShareLeadActivity.getDistiContactsForLead(LeadReturns.Id,ss);
     //  LeadDistiContactDetails ldc = new LeadDistiContactDetails();
     //  DistiContact dis =new DistiContact(LeadReturns.id,'test','test1','Open');
         Test.stopTest();
    }
    
     @isTest
    static void testshareLead(){
      Test.startTest();
        Lead LeadReturns=[select id,Name,company,Job_Description__c,Normalized_Title__c,Industry,Email,
              Phone,HasOptedOutOfEmail,DoNotCall,city,state,street,PostalCode,Country,Rating,Status,Owner.Email from lead];
       List<Lead_activity__c> leadac = [select id from Lead_activity__c where related_to_lead__c =:LeadReturns.Id ];
        List<Id> idds = new List<Id>();
        for(Lead_activity__c lds: leadac){
            idds.add(lds.id);
        }
        Contact c = [select id from contact];
                         
             ShareLeadActivity.shareLead(LeadReturns.Id,'Testname','Testcompany','Director','Consultant','TestIndustry','test@test.com',
                                        '12345',true,false,idds,'teststreet','testcity','teststate','India','254585',c.id,'tetr@test.com','testrer@test.com','notestodisti');
        ShareLeadActivity.shareLead(LeadReturns.Id,'Testname','Testcompany','Director','Consultant','TestIndustry','test@test.com',
                                        '12345',true,false,idds,'teststreet','testcity','teststate','India','254585',c.id,null,'testrer@test.com','notestodisti');
                                   
                                  
             
      Test.stopTest();
    }
    
  
}