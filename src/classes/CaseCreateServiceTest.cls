/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Ranganath
 * Created Date : 08 May,2018
 * Description   : To get ContactDetails
 ------------------------------------------------------------------------------------------------------------------*/
@isTest   
private class CaseCreateServiceTest {

  static testMethod void testCaseCreateWithNewContact()
    {
        // initialize object of type CaseCreateService.CaseInputDetails
        // use that to call the service at line 21
        CaseCreateService.CaseInputDetails con = new CaseCreateService.CaseInputDetails();
        con.caseOwner='TS L1 Inbox';
        con.assignedToEmail='sudhish.nair@nxp.com';
        con.subject='Test case via service';
        con.description='Test case via service description';
        con.product='\"111R3CLQ2 | A5-266, 144LQFP\"';
        con.topic='Documentation';
        con.contactDetails =  new CaseCreateService.ContactDetails();
        con.contactDetails.email='test.email@client.com';
        con.contactDetails.firstName='FirstName';
        con.contactDetails.lastName='LastName';
        //initialize object in line 13 above with data.
    
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/CaseCreateService/';
        request.httpMethod = 'POST';
        RestContext.request = request;      
        CaseCreateService.CaseResult results = CaseCreateService.createCase(con);
       // CaseCreateService.CaseResult results1 = CaseCreateService.getContactIdIdForEmail('sudhish.nair@nxp.com');
        
        //query for created case and see case is created or not.
        
        System.assert(results !=null );
    }
      static testMethod void testCaseCreateWithExistingContact()
    {
        Contact cont = new Contact(FirstName='test1',
                                    LastName='strLastName', 
                                    Title = 'strTitle',
                                    Phone = '8123978919', 
                                    email = 'sudhish.nair@test.com',
                                    contact_service_level__c='',
                                    Mailingcountry='DEU');
        
        insert cont;
        
        // initialize object of type CaseCreateService.CaseInputDetails
        // use that to call the service at line 21
        CaseCreateService.CaseInputDetails con = new CaseCreateService.CaseInputDetails();
        con.caseOwner='TS L1 Inbox';
        con.assignedToEmail='sudhish.nair@nxp.com';
        con.subject='Test case via service';
        con.description='Test case via service description';
        con.product='\"111R3CLQ2 | A5-266, 144LQFP\"';
        con.topic='Documentation';
        con.contactDetails =  new CaseCreateService.ContactDetails();
        con.contactDetails.email='sudhish.nair@test.com';
        con.contactDetails.firstName='FirstName';
        con.contactDetails.lastName='LastName';
        //initialize object in line 13 above with data.
    
    
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/CaseCreateService/';
        request.httpMethod = 'POST';
        RestContext.request = request;      
        CaseCreateService.CaseResult results = CaseCreateService.createCase(con);
        
        System.assert(results !=null );
    }

}