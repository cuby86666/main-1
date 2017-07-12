@isTest

public class CommunityApexEmailHandlerTest
{ 
  // Create a new email and envelope object

public  static Messaging.InboundEmail email = new Messaging.InboundEmail();
public  static Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

public static void createContact()
    {
        Contact objContact=new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test@test.com');     
        insert   objContact;                                        
    }
  
private static Account createParentAccount()
    {
    RecordType objRecordType = [Select Id, DeveloperName From RecordType Where IsActive=true and  
                              SobjectType = 'Account' and DeveloperName ='Parent_Account' Limit 1];
        //Method to create a Parent Account
       
        Account objParentAccount = new Account(RecordTypeID= objRecordType.ID,
                                                Name = 'Bosch', Customer_Category__c= 'Longtail');
        return  objParentAccount;
    }
    
  private static Entitlement createEntitlement()
  {
  Account objParentAccount = createParentAccount();
  insert objParentAccount;
  system.assert(objParentAccount.id!=null);
  Entitlement objEntitlement = new Entitlement(AccountId=objParentAccount.id, Name='testingname');
  return objEntitlement; 
  }
    private static Entitlement_Contact__c createEntitlementContact(id contactId, id EntID )
    {
     Entitlement_Contact__c entitlementContact = new Entitlement_Contact__c();
    	entitlementContact.Contact__c = contactId;
    	entitlementContact.Entitlement__c = EntID;
    	entitlementContact.Status__c = 'Accepted';
    	entitlementContact.Type__c = 'Participant';
		
    	insert entitlementContact; 
        return entitlementContact;
       
    }
  
   private static void createUser()
  {
   UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        system.assert(objProfile.Id != null);
        
        User objUser= new User(alias = 'nUser' , email= 'testing@test.com', emailencodingkey='UTF-8', lastname='test',languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id,UserRoleId = portalRole.Id, timezonesidkey='America/Los_Angeles', username= 'test8553477272@test.com' );
            
        insert objUser;
   }
    
// if contact does not exist
     static testmethod void TestEmailToSalesforce1(){
       
        createContact();
        email.plainTextBody = 'This should become a note';
        email.fromAddress ='test1@test.com';
        email.subject = 'Dummy Account Name 123';

        CommunityApexEmailHandler emailProcess = new CommunityApexEmailHandler();

        Test.startTest();

        Messaging.InboundEmailResult result = emailProcess.handleInboundEmail(email, env);
        system.assertEquals(result.success,true);
        Test.stopTest();
    
}

//wrong syntax
 static testmethod void TestEmailToSalesforce2(){
       
        createContact();
        //email.plainTextBody = 'This should become a note';
        email.fromAddress ='test@test.com';
        //email.subject = 'Dummy Account Name 123';

        CommunityApexEmailHandler emailProcess = new CommunityApexEmailHandler();

        Test.startTest();

        Messaging.InboundEmailResult result = emailProcess.handleInboundEmail(email, env);
        system.assertEquals(result.success,true);
        Test.stopTest();
    
}

// if context not found in entitlement
 static testmethod void TestEmailToSalesforce3(){
        
        createContact();
        email.plainTextBody = 'This should sfjlsfjljf context::myprojec562912 bhfhjfj become a note';
        email.fromAddress ='test@test.com';
        email.subject = 'Dummy Account Name 123';

        CommunityApexEmailHandler emailProcess = new CommunityApexEmailHandler();

        Test.startTest();

        Messaging.InboundEmailResult result = emailProcess.handleInboundEmail(email, env);
        system.assertEquals(result.success,true);
        Test.stopTest();
    
}

// when entitlement is inactive
static testmethod void TestEmailToSalesforce4(){
        
        Entitlement objEntitlement = createEntitlement();
        
        insert objEntitlement;
        system.assert(objEntitlement.id!=null);
        List<Entitlement> lstEntitlement =[select Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
        createContact();
        email.plainTextBody = 'This should sfjlsfjljf context::'+lstEntitlement[0].Entitlement_Pattern__c+'bhfhjfj become a note';
        email.fromAddress ='test@test.com';
        email.subject = 'Dummy Account Name 123';

        CommunityApexEmailHandler emailProcess = new CommunityApexEmailHandler();

        Test.startTest();

        Messaging.InboundEmailResult result = emailProcess.handleInboundEmail(email, env);
        system.assertEquals(result.success,true);
        Test.stopTest();
    
}
// for positive condition (case is created)
static testmethod void TestEmailToSalesforce5(){
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        createUser();
        }
        Entitlement objEntitlement = createEntitlement();
        
        objEntitlement.StartDate=date.today();
        insert objEntitlement;
        
        system.assert(objEntitlement.id!=null);
        List<Entitlement> lstEntitlement =[select Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
        createContact();
        email.plainTextBody = 'This should sfjlsfjljf context::'+lstEntitlement[0].Entitlement_Pattern__c+'bhfhjfj become a note';
        email.fromAddress ='test@test.com';
        email.subject = 'Dummy Account Name 123';

        CommunityApexEmailHandler emailProcess = new CommunityApexEmailHandler();

        Test.startTest();

        Messaging.InboundEmailResult result = emailProcess.handleInboundEmail(email, env);
        system.assertEquals(result.success,true);
        Test.stopTest();
    
}
// for positive condition (case is created) when email sent with attachment
static testmethod void TestEmailToSalesforce7(){
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        createUser();
        }
        Entitlement objEntitlement = createEntitlement();
        
        objEntitlement.StartDate=date.today();
        insert objEntitlement;
        
        system.assert(objEntitlement.id!=null);
        List<Entitlement> lstEntitlement =[select Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
        createContact();
       Messaging.InboundEmail.BinaryAttachment objFileAtt= new Messaging.InboundEmail.BinaryAttachment();
        objFileAtt.Body=Blob.valueof('Some random String');
        objFileAtt.fileName='xyz';
       
       email.BinaryAttachments=new Messaging.inboundEmail.BinaryAttachment[] { objFileAtt};
       Messaging.InboundEmail.TextAttachment objTextFileAtt= new Messaging.InboundEmail.TextAttachment();
       objTextFileAtt.Body='bmbjknkjk';
        objTextFileAtt.fileName='xyz';
        email.TextAttachments=new Messaging.inboundEmail.TextAttachment[] { objTextFileAtt};
        email.plainTextBody = 'This should sfjlsfjljf context::'+lstEntitlement[0].Entitlement_Pattern__c+'bhfhjfj become a note';
        email.fromAddress ='test@test.com';
        email.subject = 'Dummy Account Name 123';

        CommunityApexEmailHandler emailProcess = new CommunityApexEmailHandler();

        Test.startTest();

        Messaging.InboundEmailResult result = emailProcess.handleInboundEmail(email, env);
        system.assertEquals(result.success,true);
        Test.stopTest();
    
}
        
        
 static testmethod void TestEntitlementUpdate6()
 {
 Entitlement objEntitlement = createEntitlement();
 insert objEntitlement;
 system.assert(objEntitlement.id!=null);
 Entitlement objEntitlement1 = createEntitlement();
 insert objEntitlement1 ;
 system.assert(objEntitlement1.id!=null);
 update objEntitlement;
 }
 
 // for positive condition (case is created) assigned owner to default queue
static testmethod void TestEmailToSalesforce8(){

         Entitlement objEntitlement = createEntitlement();
        
        objEntitlement.StartDate=date.today();
        insert objEntitlement;
        
        system.assert(objEntitlement.id!=null);
        List<Entitlement> lstEntitlement =[select Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
        createContact();
        email.plainTextBody = 'This should sfjlsfjljf context::'+lstEntitlement[0].Entitlement_Pattern__c+'bhfhjfj become a note';
        email.fromAddress ='test@test.com';
        email.subject = 'Dummy Account Name 123';
		
        CommunityApexEmailHandler emailProcess = new CommunityApexEmailHandler();

        Test.startTest();

        Messaging.InboundEmailResult result = emailProcess.handleInboundEmail(email, env);
        system.assertEquals(result.success,true);
        Test.stopTest();
    
}
    /*
     // for positive condition notification sent to observer and participents
static testmethod void TestEmailToSalesforce9(){

         Entitlement objEntitlement = createEntitlement();
    	 Contact contact = new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test@test.com'); 
    	insert contact;
        Case objCase = new Case();
    	objEntitlement.StartDate=date.today();
        insert objEntitlement;
        system.assert(objEntitlement.id!=null);
        objCase.Entitlementid = objEntitlement.id;
    	objCase.Subject = 'test sub';
    	insert objCase;
    	Case qCase = [SELECT id, caseNumber, CreatedBy.Email, Email__c, EntitlementId, Subject, Entitlement.Name, Entitlement.CreatedBy.Name from Case where id =:objCase.id];
    	Entitlement_Contact__c entitlementContact = new Entitlement_Contact__c();
    	entitlementContact.Contact__c = contact.id;
    	entitlementContact.Entitlement__c = objEntitlement.id;
    	entitlementContact.Status__c = 'Accepted';
    	entitlementContact.Type__c = 'Participant';
    	insert entitlementContact;
		CommunityApexEmailHandler emailProcess = new CommunityApexEmailHandler();
        Test.startTest();
		boolean result = emailProcess.sendCaseCreateNotification([select Id, Subject, Body from EmailTemplate where DeveloperName = 'NXPCommunityCaseCreateNotification'], qCase);    
        system.assertEquals(result,true);
        Test.stopTest();
    
}*/
    
    // for positive condition notification sent to observer and participents
    
static testmethod void TestEmailToSalesforce9(){

         Entitlement objEntitlement = createEntitlement();
    	 Contact contact = new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test@test.com'); 
    	insert contact;
    Contact contact2 = new Contact(FirstName='test1',LastName='strLastName', Title = 'strTitle',
                                          Phone = '8123978919', email = 'test2@test.com'); 
    	insert contact2;
        //Case objCase = new Case();
        system.assert(contact.id!=null);
    	objEntitlement.StartDate=date.today();
        insert objEntitlement;
    
        system.assert(objEntitlement.id!=null);
        //objCase.Entitlementid = objEntitlement.id;
    	//objCase.Subject = 'test sub';
    	//insert objCase;
    	//Case qCase = [SELECT id, caseNumber, CreatedBy.Email, Email__c, EntitlementId, Subject, Entitlement.Name, Entitlement.CreatedBy.Name from Case where id =:objCase.id];
    	Entitlement_Contact__c objEntCont = createEntitlementContact(contact.id, objEntitlement.id);
    	Entitlement_Contact__c objEntCont2 = createEntitlementContact(contact2.id, objEntitlement.id);
    	system.assert(objEntCont.id!=null);
    //system.assertEquals('a2e5E0000008QLMQA2',objEntCont.id);
		
    List<Entitlement> lstEntitlement =[select id,Entitlement_Pattern__c from Entitlement where id=:objEntitlement.id];
   // Entitlement objEntitlement1= [select id FROM Entitlement where Entitlement_Pattern__c]
        email.plainTextBody = 'salesforce9 context::'+lstEntitlement[0].Entitlement_Pattern__c+' bhfhjfj become a note';
        email.fromAddress ='test@test.com';
        email.subject = 'Dummy Account Name 123';

        CommunityApexEmailHandler emailProcess = new CommunityApexEmailHandler();

        Test.startTest();

        Messaging.InboundEmailResult result = emailProcess.handleInboundEmail(email, env);
        system.assertEquals(result.success,true);
  
        Test.stopTest();
    
}
}