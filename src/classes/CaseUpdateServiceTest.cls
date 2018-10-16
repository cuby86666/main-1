/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Gunjan
 * Created Date : 24 Aug,2018
 * Description  : Test class to update some fields on case using webservice for SFDC-1971
 ------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = true)
private class CaseUpdateServiceTest {
  static User userRecord;
  
  static testMethod void testCaseUpdateService(){
    loadUserData();
    Account accRecord = new Account();
    accRecord.Name = 'NXP Community';
    insert accRecord;
            
    Contact conRecord = new Contact();
    conRecord.accountId = accRecord.id;
    conRecord.LastName = 'T';
    conRecord.Email = 'testuser@nxptest.com';
    insert conRecord;
    
    Entitlement entRecord = new Entitlement();
    entRecord.Name = 'development';
    entRecord.accountId = accRecord.id;
    insert entRecord;
              
    Entitlement_Contact__c entconRecord = new Entitlement_Contact__c();
    entconRecord.Entitlement__c= entRecord.id;
    entconRecord.Contact__c=conRecord.id;
    insert entconRecord;
       
    Case cse = new Case();
    cse.subject ='test';
    cse.Assigned_to__c = userRecord.Id;
    cse.contactid=conRecord.id;
    cse.EntitlementId=entRecord.id;
    cse.FeedItemId = NULL;
    insert cse; 
  
   CaseUpdateService.CaseInputDetails con = new CaseUpdateService.CaseInputDetails();
   con.CaseID =cse.Id;
   con.CaseStatus = 'In Progress';
   con.Priority = 'Low';
   con.FeedMessage='Update the feed message';
   con.CaseOwner='TS L1 Inbox';
   con.CaseAssignedTo='sudhish.nair@nxp.com';
   con.Topic='Documentation';
   
   
    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/CaseUpdateService/';
    request.httpMethod = 'PATCH';
    RestContext.request = request;      
    CaseUpdateService.OutputMessage results = CaseUpdateService.updateCase(con);
 
  }
  
  static testMethod void testCaseUpdateService1(){
    loadUserData();
    Account accRecord = new Account();
    accRecord.Name = 'NXP Community';
    insert accRecord;
            
    Contact conRecord = new Contact();
    conRecord.accountId = accRecord.id;
    conRecord.LastName = 'T';
    conRecord.Email = 'testuseremail@nxptest.com';
    insert conRecord;
    
    Entitlement entRecord = new Entitlement();
    entRecord.Name = 'development';
    entRecord.accountId = accRecord.id;
    insert entRecord;
              
    Entitlement_Contact__c entconRecord = new Entitlement_Contact__c();
    entconRecord.Entitlement__c= entRecord.id;
    entconRecord.Contact__c=conRecord.id;
    insert entconRecord;
       
    Case cse = new Case();
    cse.subject ='test';
    cse.Assigned_to__c = userRecord.Id;
    cse.contactid=conRecord.id;
    cse.EntitlementId=entRecord.id;
    cse.FeedItemId = NULL;
    insert cse; 
  
   CaseUpdateService.CaseInputDetails con = new CaseUpdateService.CaseInputDetails();
   con.CaseNumber =cse.CaseNumber;
   con.CaseStatus = 'Close';
   con.Priority = 'Low';
   con.FeedMessage='Update the feed message';
   con.CaseOwner='test@nxp.com';
   con.CaseAssignedTo='gunjan.singh@nxp.com';
   con.Topic='Documentation';
   
   CaseUpdateService.CaseInputDetails caseIn = new CaseUpdateService.CaseInputDetails();
   caseIn.CaseStatus = 'In Progress';
   caseIn.Priority = 'Low';
   caseIn.FeedMessage='Update the feed message';
   caseIn.CaseOwner='TS L1 Inbox';
   caseIn.CaseAssignedTo='gunjan.singh@nxp.com';
   caseIn.Topic='Documentation';
   
    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/CaseUpdateService/';
    request.httpMethod = 'PATCH';
    RestContext.request = request;      
    CaseUpdateService.OutputMessage results = CaseUpdateService.updateCase(con);
    CaseUpdateService.OutputMessage results1 = CaseUpdateService.updateCase(caseIn);
 
  }
   static void loadUserData(){
   
    Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%' limit 1]; 
 
    userRecord = new User ();
    userRecord.Email = 'gunjan.singh@nxp.com';
    userRecord.userName = 'gunjan.singh@nxp.com';
    userRecord.firstName='New';
    userRecord.LastName='Testing';
    userRecord.EmailEncodingKey='UTF-8';
    userRecord.LanguageLocaleKey='en_US';  
    userRecord.LocaleSidKey='en_US'; 
    userRecord.TimeZoneSidKey='America/Los_Angeles';
    userRecord.ProfileId = p.Id;
    userRecord.Alias = 'standt';
    insert userRecord;
   
   }
  
}