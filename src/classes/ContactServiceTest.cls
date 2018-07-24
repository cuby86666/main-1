/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Ranganath
 * Created Date : 08 May,2018
 * Description   : To get ContactDetails
 ------------------------------------------------------------------------------------------------------------------*/
@isTest   
private class ContactServiceTest {

  static testMethod void testDoGet() {
        Contact cont = new Contact(FirstName='test1',
                                    LastName='strLastName', 
                                    Title = 'strTitle',
                                    Phone = '8123978919', 
                                    email = 'test1@CN.BOSCH.COM',
                                    contact_service_level__c='',
                                    Mailingcountry='DEU');
        
        insert cont;
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/ContactService/test1@CN.BOSCH.COM';  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    ContactService.ContactDetails results = ContactService.getContactDetails();

    System.assertEquals('test1', results.firstName);
    

  } 

}