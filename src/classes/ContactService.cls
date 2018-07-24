//REST service to get contact details
@RestResource(urlMapping='/ContactService/*')
global with sharing class ContactService {
    
    //wrapper class for sending contact details
    global class ContactDetails{
        public String accountName;
        public String email;
        public String serviceLevel;
        public String company;
        public String firstName;
        public String lastName;
        public String contactId;
    }
        
    @HttpGet
    global static ContactDetails getContactDetails(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;        
        String contactIdOrEmail = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<Contact> contactRecords = new List<Contact>();
        if(contactIdOrEmail.contains('@')){
            contactRecords = [SELECT Id,Account.Name,Email,Community_web_country__c,Company__c,Contact_Service_Level__c,FirstName,LastName FROM Contact where Email = :contactIdOrEmail];
        }else{
            contactRecords = [SELECT Id,Account.Name,Email,Community_web_country__c,Company__c,Contact_Service_Level__c,FirstName,LastName FROM Contact where Id = :contactIdOrEmail];
        }
        ContactDetails cd;
        if(contactRecords!=null &&(!contactRecords.isEmpty())){
            cd=mapContactSObjectToWrapperClass(contactRecords.get(0));
        }
        
        return cd;
    }
    private static ContactDetails mapContactSObjectToWrapperClass(Contact con){
        ContactDetails cd = new ContactDetails();
        cd.accountName = con.Account.Name;
        cd.Email = con.Email;
        cd.serviceLevel = con.Contact_Service_Level__c;
        cd.company = con.Company__c;
        cd.firstName = con.FirstName;
        cd.lastName = con.LastName;
        cd.contactId = con.Id;
        return cd;
    }
}