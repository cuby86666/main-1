@RestResource(urlMapping='/CreateCaseService/*')
global with sharing class CaseCreateService {
    global class CaseInputDetails {
        public String caseOwner;
        public String assignedToEmail;
        public String subject;
        public String description;
        public String product;
        public String topic;
        public ContactDetails contactDetails;
    }
    
    global class ContactDetails{
        public String accountName;
        public String email;
        public String serviceLevel;
        public String company;
        public String firstName;
        public String lastName;
        public String contactId;
    }    
    
    global class CaseResult {
        public String caseOwnerId;
        public String caseNumber;
        public String assignedToId;
        public String subject;
        public String description;
        public String productId;
        public String topic;
        public String caseId;
        public ContactDetails contactDetails;        
    }
    
    @HttpPost
    global static CaseResult createCase(CaseInputDetails caseInput){
        Case newCaseRecord = new Case();
        //search for case owner
        if(caseInput.caseOwner !=null && caseInput.caseOwner.trim() != ''){
            if(caseInput.caseOwner.contains('@')){
                newCaseRecord.OwnerId= getUserIdForEmail(caseInput.caseOwner);
            }else{
                newCaseRecord.OwnerId =getQueueIdForQueueName(caseInput.caseOwner);
            }
            if(newCaseRecord.OwnerId ==null){
                newCaseRecord.OwnerId= getQueueIdForQueueName('TS L1 Inbox');
            }
        }

        if(caseInput.assignedToEmail !=null && caseInput.assignedToEmail.trim() != ''){
            if(caseInput.assignedToEmail.contains('@')){
                newCaseRecord.Assigned_to__c= getUserIdForEmail(caseInput.assignedToEmail);
            }
        }        
        
        newCaseRecord.Subject = caseInput.Subject;
        newCaseRecord.Description = caseInput.Description;
        newCaseRecord.My_Question_is_Related__c = caseInput.Topic;
        newCaseRecord.Product_Name__c = findProductByName(caseInput.Product);
        newCaseRecord.Origin = 'Forum';
        ContactDetails cond = findAndCreateContact(caseInput.contactDetails);
        newCaseRecord.ContactId = cond.contactId;
        Database.SaveResult result = Database.insert(newCaseRecord);
        if(result.isSuccess()){
            Case newCase = [SELECT Id,casenumber,OwnerId,Product_Name__c,Assigned_to__c,Subject,Description,My_Question_is_Related__c,ContactId from Case where id=:result.getId()];
            return mapCaseSobjectToCaseResult(newCase);
        }
        return null;
    }
    private static String findProductByName(String prname){
        List<Product2> prodLst = [select id from product2 where name=:prname];
        if(prodLst!=null && (!prodLst.isEmpty())){
            return prodLst.get(0).id;
        }
        return null;
    }
    private static String getUserIdForEmail(String email){
        List<User> caseOwnerUsers = [SELECT Id from User where Email=:email];
        if(caseOwnerUsers!=null && (!caseOwnerUsers.isEmpty())){
            return caseOwnerUsers.get(0).Id;
        }        
        return null;
    }
    private static String getQueueIdForQueueName(String queuename){
        List<Group> ownerQueue = [select Id from Group where Type = 'Queue' and Name=:queuename];
        if(ownerQueue!=null && (!ownerQueue.isEmpty())){
            return ownerQueue.get(0).Id;
        }
        return null;
    }    

    private static ContactDetails findAndCreateContact(ContactDetails cd){
        List<Contact> contacts = [SELECT Id,Account.Name,Email,Community_web_country__c,Company__c,Contact_Service_Level__c,FirstName,LastName FROM Contact where Email = :cd.Email];
        if(contacts!=null &&(!contacts.isEmpty())){
            return mapContactSObjectToWrapperClass(contacts.get(0));
        }else{
            List<Account> accs = [SELECT Id from Account where Name='NXP Community'];
            Contact con = new Contact();
            con.Email=  cd.Email;
            con.Company__c = cd.company;
            con.firstName = cd.FirstName;
            con.lastName = cd.LastName;
            if(accs!=null && (!accs.isEmpty())){
                con.AccountId = accs.get(0).id;                    
            }
            insert con;
            List<Contact> recentlyInsertedCon = [SELECT Id,Account.Name,Email,Community_web_country__c,Company__c,Contact_Service_Level__c,FirstName,LastName FROM Contact where Email = :cd.Email];            
            return mapContactSObjectToWrapperClass(recentlyInsertedCon.get(0));            
        }
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
    private static CaseResult mapCaseSobjectToCaseResult(Case c){
        CaseResult cr = new CaseResult();
        cr.casenumber = c.casenumber;
        cr.caseOwnerId=c.OwnerId;
        cr.assignedToId=c.Assigned_to__c;
        cr.Subject=c.Subject;
        cr.description=c.Description;
        cr.productId=c.Product_Name__c;
        cr.topic=c.My_Question_is_Related__c;
        cr.caseId=c.Id; 
        Contact caseContact = [SELECT Id,Account.Name,Email,Community_web_country__c,Company__c,Contact_Service_Level__c,FirstName,LastName FROM Contact where Id = :c.ContactId];
        cr.contactDetails = mapContactSObjectToWrapperClass(caseContact);
        return cr;
    }
}