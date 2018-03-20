/*************************************************************************
@Created By:     Jewelslyn
@Description:    Test class for lead owner Assignment.
**************************************************************************/

@isTest
public class LeadOwnerAssignmentHandlerTest {
    
    
    public static final String TEST_USER_PROFILE = 'Standard User';
    public static final String TEST_USER_EMAIL_0 = 'testuser@testorg.com.test';
    public static final String TEST_USER_EMAIL_1 = 'testuser1@testorg.com.test';
    public static final String TEST_USER_EMAIL_2 = 'testuser2@testorg.com.test';
    public static final String TEST_USER_EMAIL_3 = 'testuser3@testorg.com.test';
    public static list<User> listUser=new list<user>();
    public static list<contact> listContact=new list<contact>();
             
    @testSetup
    static void setup(){
        map<id,string> mapUserName=new map<id,String>();
        LeadOwnerAssignmentHandler.init();
                
        Profile p = [SELECT Id FROM Profile WHERE Name = :TEST_USER_PROFILE];
        
        // insert a test user
        
        User u = new User(Alias = 'test', Email = TEST_USER_EMAIL_0, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_0);
        listUser.add(u);
        User u2 = new User(Alias = 'test1', Email = TEST_USER_EMAIL_1, 
            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id, UserName = TEST_USER_EMAIL_1);
        listUser.add(u2);
        insert listUser;
        
        //user u3=[Select id, name from User where name=:label.Lead_Default_Owner];
        //system.debug('username::'+u3);
        
        
        // Insert  accounts
        List<account> listAcc=new list<Account>();
        account a3=new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12045',recordTypeId=LeadOwnerAssignmentHandler.PARENT_RECORD_TYPE);
        insert a3;
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',ParentId=a3.Id,country__c='Test Country',state_province__c='Test State'));                
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - ROM',
                                NXP_GID__c='12345',ParentId=a3.Id,country__c='Test Country',state_province__c='Test State'));                
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                NXP_GID__c='12245',ParentId=a3.Id));                       
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 1',
                                ParentId=a3.Id,country__c='Test Country',state_province__c='Test State'));                
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 4 - TMMA',
                               NXP_GID__c='12145',ParentId=a3.Id,country__c='Test Country',city__c='Test City'));                       
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 2',
                                NXP_GID__c='12245',ParentId=a3.Id,country__c='Test Country',city__c='Test city'));                
        listAcc.add(new Account(Name = 'Test Account', Region__c = 'EMEA',OwnerId=u.Id,customer_category__c='Tier 3',
                                NXP_GID__c='12245',ParentId=a3.Id,country__c='Test Country1',city__c='Test citys'));        
        insert listAcc;        
        
        // Insert contacts
        
        for(account a:listAcc){
            listContact.add(new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_0,AccountId=a.Id));                
        	listContact.add(new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_1,AccountId=a.Id));                
        	listContact.add(new Contact(FirstName='Test',LastName='Contact',  Title = 'strTitle',
                                  email = TEST_USER_EMAIL_2,AccountId=a.Id));
            
        }                
        insert listContact;
        
        //Insert Lead Owner assignment
        list<LeadOwnerAssignment__c> listLeadOwnerAssignmt=new list<LeadOwnerAssignment__c>();
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country',city__c='Test City1',End_ZIP_Code__c='14',
                                                             Lead_Owner__c=u.Id,Start_ZIP_Code__c='10',State__c='Test State 1'));
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country',city__c='Test City',
                                                             Lead_Owner__c=u.Id,State__c='Test State'));
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country',city__c='Test City',
                                                             Lead_Owner__c=u.Id,State__c='Test State 1'));
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country Ch',
                                                             Lead_Owner__c=u.Id,CBG__c = 'Automotive'));                                                             
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country Ch',
                                                             Lead_Owner__c=u.Id,city__c='Test City',State__c='Test State 2',
                                                             CBG__c = 'Consumer'));
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country Ch',
                                                             Lead_Owner__c=u.Id,city__c='Test City 2',State__c='Test State 2',
                                                             CBG__c = 'Consumer'));
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country Ch',
                                                             Lead_Owner__c=u.Id,city__c='Other',State__c='Test State 2',
                                                             CBG__c = 'Consumer'));
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country Ch',
                                                             Lead_Owner__c=u.Id,city__c='Test City 2',State__c='Test State 1',
                                                             CBG__c = 'Consumer'));       
        listLeadOwnerAssignmt.add(new LeadOwnerAssignment__c(Country__c='Test Country Ch',
                                                             Lead_Owner__c=u.Id,city__c='Test City',CBG__c = 'Medical'));                                                             
        insert listLeadOwnerAssignmt;
        
        //Insert Leads
        
        list<lead> listLead=new list<lead>();
    
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
        user u3=[Select id, name from User where name=:label.Lead_Default_Owner];
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country', postalCode='12',email=TEST_USER_EMAIL_3,createdDate=d,
                              ownerId=u3.Id));
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country', postalCode='12-01',email=TEST_USER_EMAIL_3,createdDate=d,
                              ownerId=u3.Id));                                                        
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country', state='Test State',email=TEST_USER_EMAIL_3,createdDate=d,
                              ownerId=u3.Id));                             
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',email=TEST_USER_EMAIL_3,createdDate=d,                            
                               ownerId=u3.Id));                                    
        listLead.add(new lead(FirstName='Test',LastName='Ind3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country Ch', email=TEST_USER_EMAIL_3,createdDate=d,Industry='Automotive',                            
                               ownerId=u3.Id)); 
        listLead.add(new lead(FirstName='Test',LastName='Ind4', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country Ch',State='Test State 2', city='Test City',email=TEST_USER_EMAIL_3,createdDate=d,                            
                              Industry='Consumer', ownerId=u3.Id));
        listLead.add(new lead(FirstName='Test',LastName='Ind5', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country', email=TEST_USER_EMAIL_3,createdDate=d,Industry='consumer',                            
                               ownerId=u3.Id));
        listLead.add(new lead(FirstName='Test',LastName='Ind5', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country Ch',city='Test City', email=TEST_USER_EMAIL_3,createdDate=d,Industry='Medical',                            
                               ownerId=u3.Id));        
        listLead.add(new lead(FirstName='Test',LastName='Lead3', Company='TestCompany',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country Ch', city='Test City0',email=TEST_USER_EMAIL_3,createdDate=d,State='Test State 2',
                                     ownerId=u3.Id,Industry='Consumer'));
        insert listLead;
        
        
        system.debug('leadowner::'+u3.Name);
        /*system.runAs(U3){
        lead nxpCreationLead=new lead(FirstName='Test',LastName='Lead3', Company='Test compan3',RecordTypeId=LeadOwnerAssignmentHandler.ROM_LEAD_RECORD_TYPE, 
                              status='Open',country='Test Country', city='Test City',email=TEST_USER_EMAIL_3,createdDate=d,State='Test State 1',
                                     ownerId=u3.Id);
        insert nxpCreationLead;
            system.debug('lead::'+nxpCreationLead.Owner.Name); 
            system.debug('leadId::'+nxpCreationLead.OwnerId);
        }*/
       
    }
    
    
    @isTest
    static void testContactBasedMapping(){
        Test.starttest();
       
         DateTime d = System.now().addHours(-2);
        list<Lead> listLeadUncategorized=[SELECT id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,
                                          RecordTypeId,Description,street,city,country,state,company,Industry from Lead
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
                                          RecordTypeId,Description,street,city,country,state,company,Industry from Lead
                                          where RecordType.Name='Uncategorized Leads'And createdDate <=:d];
        system.assert(listLeadUncategorized.size()!=0);        
        LeadOwnerAssignmentBatch batchController = new LeadOwnerAssignmentBatch();
        Database.executebatch(batchController); 
        Test.stopTest();
    }        
}