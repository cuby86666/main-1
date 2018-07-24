/***************************************************************************************************
@Created By :      Ranganath C N
@Created Date:     18 May 2018
@Description:      SFDC-1601-Webservice to get CaseDetails 
*******************************************************************************************************/
@isTest   
private class CaseServiceTest {

  static testMethod void testDoGet() {
  
             Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
  
             User usr = new User(LastName = 'CN',
                           FirstName='rang',
                           Alias = 'ran',
                           Email = 'test1234@CN.BOSCH.COM',
                           Username = 'test@CN.BOSCH.COM',
                           ProfileId = profileId.Id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
                           insert usr;
         
            Account testaccount = new Account();
            testaccount.Name='john';
            insert testaccount;
            
            Contact testcontact = new Contact();
            testcontact.LastName = 'CNR';
            testcontact.email='test@CN.BOSCH.COM';
            insert testcontact;
            
            Product2 testproduct = new Product2();
            testproduct.Name='john';
            insert testproduct ;
         
    
            Case cont = new Case(       
                                    Case_Owner_Name__c = 'Ranganath CN',
                                    subject = 'testing',
                                    priority = 'Low',
                                    status = ' New',
                                    description= 'testing cases',
                                    origin= 'Phone',
                                    My_Question_is_Related__c= 'Web',
                                    email__c = 'test@CN.BOSCH.COM',
                                    Company__c= 'uyiuyi ',
                                    Community_Web_Country__c= 'yiiuyi',
                                    Product_Category__c = 'RF',
                                    Product_Sub__c = 'Mixers',
                                    JobTitle__c = 'Other',
                                    Facebook__c = 'test_fb',
                                    Twitter__c = 'test_twt',
                                     State_Province__c = 'test_state',
                                     Product_Type_Number__c = 'test',
                                     Product_application__c = 'test', 
                                     Expected_annual_unit_volume__c = 'test',
                                     Project_Stage__c = 'Development',
                                     Web_Region__c = 'Test_region'
                                   );
            insert cont;
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/CaseService/5005E0000040ox0QAA';  
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;

            List<CaseService.CaseDetails> results = CaseService.getCaseInformation();

          //  System.assertEquals('Ranganath CN',results.subject );
    

  } 

}