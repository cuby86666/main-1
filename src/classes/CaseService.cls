/***************************************************************************************************
@Created By :      Ranganath C N
@Created Date:     08 May 2018
@Description:      SFDC-1601-Webservice to get CaseDetails 
*******************************************************************************************************/
//REST service to get Case details
@RestResource(urlMapping='/CaseService/*')
global with sharing class CaseService{
    
    //wrapper class for sending case details
    global class CaseDetails{
        public String Owner_Name;
        public String Case_ID;
        public String Subject;
        public String Priority;
        public String Status;
        public String Description;
        public String Origin;
        public String Record_Type;
        public String Assigned_To_UserName;
        public String Assigned_To_UserEmail;
        public String Topic;
        public String Product_Name;
        public String Contact_Service_Level;
        public String Case_Number;
        public String Contact_Account_Name;
        public String Contact_Email;
        public String Contact_Company;
        public String Contact_Country;
        public String Contact_Name;
      //  public String contactLastname;
    }
    //SUDHISH: return List<CaseDetails>    
    @HttpGet
    global static List<CaseDetails> getCaseInformation(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;        
        String caseIdOrEmail = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        system.debug('1'+' '+caseIdOrEmail);
        List<Case> caseRecords = new List<Case>();
        if(caseIdOrEmail.contains('@')){
            caseRecords = [Select id,Case_Owner_Name__c,subject,priority,status,description,origin,RecordType.Name,Assigned_to__r.name,Assigned_to__r.Email,My_Question_is_Related__c,Product.Name,Contact_Service_Level__c,casenumber,Account.name,Email_Contact__c,
                                Company__c,Community_Web_Country__c,contact.name from case  where contact.email= :caseIdOrEmail];
        }else{
            caseRecords = [Select id,Case_Owner_Name__c,subject,priority,status,description,origin,RecordType.Name,Assigned_to__r.name,Assigned_to__r.Email,My_Question_is_Related__c,Product.Name,Contact_Service_Level__c,casenumber,Account.name,Email_Contact__c,
                                Company__c,Community_Web_Country__c,contact.name from case  where Id = :caseIdOrEmail];
        }
        //SUDHISH: Loop through case recods got from query. Provide to mapping method and add them to a list
        //return List
        //Initialize List here
        //then loop though records
         List<CaseDetails> records = new List<CaseDetails>();
        for(Case c: caseRecords){
         CaseDetails cd = mapCaseSObjectToWrapperClass(c);
        system.debug('2'+' '+cd);
         records.add(cd);
        }
        List<CaseDetails> cd;
        if(records!=null &&(!records.isEmpty())){
            cd=records;
        }
        
        return cd;
        
    }
    
    
    private static CaseDetails mapCaseSObjectToWrapperClass(Case c){
        CaseDetails cd = new CaseDetails();
        cd.Case_ID = c.id;
        system.debug('3'+' '+c.Id);
        cd.Owner_Name = c.Case_Owner_Name__c;
        cd.Subject =  c.subject;
        cd.Priority =  c.priority;
        cd.Status =  c.status;
        cd.Description =  c.description;
        cd.Origin =  c.origin;
        cd.Record_Type =  c.RecordType.Name;
        cd.Assigned_To_UserName =c.Assigned_to__r.name;
        cd.Assigned_To_UserEmail = c.Assigned_to__r.Email;
        cd.Topic =  c.My_Question_is_Related__c;
        cd.Product_Name =  c.Product.Name;
        cd.Contact_Service_Level =   c.Contact_Service_Level__c;
        cd.Case_Number =   c.casenumber;
        cd.Contact_Account_Name =   c.Account.name;
        cd.Contact_Email =  c.Email_Contact__c;
        cd.Contact_Company =  c.Company__c;
        cd.Contact_Country =  c.Community_Web_Country__c;
        cd.Contact_Name=  c.contact.name;
        //cd.contactLastname;
        return cd;
    }
}