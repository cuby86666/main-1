@isTest
public class LeadOwnerAssignmentHandlerTest {
    
    
    public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser3@testorg.com.test';
             
    @testSetup
    static void setup(){
        map<id,string> mapUserName=new map<id,String>();
        LeadOwnerAssignmentHandler.init();
        List<LeadCountrySettings__c> leadCountrySettings = new list<LeadCountrySettings__c>();
        leadCountrySettings.add(new LeadCountrySettings__c(country_Code__c='TCN', Country__c='Test Country',Name='TestCountry'));
        leadCountrySettings.add(new LeadCountrySettings__c(State_Code__c='TST', State__c='Test State',Name='TestState'));
        insert leadCountrySettings;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
        insert u;
        user u1=[select id, name from user where name=:label.Lead_Default_Owner];
        if(!mapUserName.containskey(u1.Id)){
            mapUserName.put(u1.Id,u1.Name);
        }
        
        // Insert  accounts
        Account a3 = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12045',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);        
        insert a3;
        Account a = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',ParentId=a3.Id,country__c='Test Country',state_province__c='Test State');        
        insert a;
        Account a1 = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - ROM',
                                NXP_GID__c='12345',ParentId=a3.Id,country__c='Test Country',state_province__c='Test State');        
        insert a1;
        Account a2 = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12245',ParentId=a3.Id);        
        insert a2;        
        Account a4 = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                ParentId=a3.Id,country__c='Test Country',state_province__c='Test State');        
        insert a4;
        Account a5 = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',ParentId=a3.Id,country__c='Test Country',city__c='Test City');        
        insert a5;        
        Account a7 = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12245',ParentId=a3.Id,country__c='Test Country',city__c='Test city');        
        insert a7;
        Account a8 = new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12245',ParentId=a3.Id,country__c='Test Country1',city__c='Test citys');        
        insert a8;        
        
        // Insert contacts
        Contact con = new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_0,AccountId=a.Id);        
        insert con;
        Contact con1 = new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_1,AccountId=a1.Id);        
        insert con1;
        Contact con2 = new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_2,AccountId=a2.Id);        
        insert con2;
        
        //Insert Lead Owner assignment
        list<LeadOwnerAssignment__c> listLeadOwnerAssignmt=new list<LeadOwnerAssignment__c>();
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country',city__c='Test City1',End_ZIP_Code__c='14',
                                                             Lead_Owner__c=u.Id,Start_ZIP_Code__c='10',State__c='Test State 1'));
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country',city__c='Test City',
                                                             Lead_Owner__c=u.Id,State__c='Test State'));
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country',city__c='Test City',
                                                             Lead_Owner__c=u.Id,State__c='Test State 1'));
        insert listLeadOwnerAssignmt;
        
        //Insert Leads
        
        list<lead> listLead=new list<lead>();
		//dateTime d=system.now()-3; 
        DateTime d = System.now().addHours(-3);
        listLead.add(new lead(firstName='Test', LastName='Lead', Company='Test Company',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',state='Test State',email=TEST_USER_EMAIL_0,
                             createdDate=d));                             
		listLead.add(new lead(FirstName='Test',LastName='Lead1', Company='Test Company1',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',state='Test State',email=TEST_USER_EMAIL_1,
                             createdDate=d));
		listLead.add(new lead(FirstName='Test',LastName='Lead2', Company='Test Company2',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',state='Test State',email=TEST_USER_EMAIL_2,
                             createdDate=d));		
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',state='Test State',email=TEST_USER_EMAIL_3,
                              NXP_Global_Customer_Master_ID__c='12345',createdDate=d));
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',state='Test State',email=TEST_USER_EMAIL_3,
                              NXP_Global_Customer_Master_ID__c='12145',createdDate=d));
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',state='Test State',email=TEST_USER_EMAIL_3,
                              NXP_Global_Customer_Master_ID__c='12245',createdDate=d));
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country1', city='Test City1',state='Test State',email=TEST_USER_EMAIL_3,
                              NXP_Global_Customer_Master_ID__c='12045',createdDate=d));
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',email=TEST_USER_EMAIL_3,
                              NXP_Global_Customer_Master_ID__c='12045',createdDate=d));
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country', state='Test State',email=TEST_USER_EMAIL_3,
                              NXP_Global_Customer_Master_ID__c='12045',createdDate=d));
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='Test Country', state='Test State',email=TEST_USER_EMAIL_3,
                              NXP_Global_Customer_Master_ID__c='120456',createdDate=d));
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.UNCATEGORIZED_RECORD_TYPE, 
                              status='Open',country='TCN', state='TST',email=TEST_USER_EMAIL_3,createdDate=d));
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country', postalCode='12',email=TEST_USER_EMAIL_3,createdDate=d)); 
                                                         
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country', state='Test State',email=TEST_USER_EMAIL_3,createdDate=d));
                             
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',email=TEST_USER_EMAIL_3,createdDate=d
                              ));
                             
        system.debug('ownername::'+listLead[13].OwnerId);
                              
        insert listLead;
        
        
        
                                                           
    }
    @isTest
    static void testContactBasedMapping(){
        Test.starttest();
       
       	DateTime d = System.now().addHours(-2);
        list<Lead> listLeadUncategorized=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company from Lead
                                          where RecordType.Name='Uncategorized Leads'And createdDate <=:d];
        system.assert(listLeadUncategorized.size()!=0);        
        LeadOwnerAssignmentBatch batchController = new LeadOwnerAssignmentBatch();
        Database.executebatch(batchController);                 
        Test.stopTest();
    }
    @isTest
    static void testGidBasedMapping(){
        Test.startTest();
        DateTime d = System.now().addHours(-2);
        list<Lead> listLeadUncategorized=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company from Lead
                                          where RecordType.Name='Uncategorized Leads'And createdDate <=:d];
        system.assert(listLeadUncategorized.size()!=0);        
        LeadOwnerAssignmentBatch batchController = new LeadOwnerAssignmentBatch();
        Database.executebatch(batchController); 
        Test.stopTest();
    }                
}