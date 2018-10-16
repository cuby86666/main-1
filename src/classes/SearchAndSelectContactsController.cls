public class SearchAndSelectContactsController {
    @AuraEnabled 
    public static String searchContactsInSF(String searchText,Integer numOfResults){
        
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
        
        List<List<sObject>> allResults = [FIND :searchText IN ALL FIELDS RETURNING Contact(Id,Name,Email,Account.Name,Company__c) LIMIT 40];
        List<ContactResultWrapper> lstRet = new List<ContactResultWrapper>();
        
        if(allResults!=null && (!allResults.isEmpty())){
            List<SObject> sobjList= allResults.get(0);
            for(SObject s : sobjList){
                ContactResultWrapper obj = new ContactResultWrapper();
                Contact c = (Contact)s;
                obj.contactId = c.Id;
                obj.contactName = c.Name ;
                obj.emailId = c.Email;
                obj.customerName = c.Account.Name!='NXP Community'?c.Account.Name:c.Company__c;
                obj.itemText = obj.contactName+'('+obj.emailId+')'+obj.customerName;
                lstRet.add(obj);
            } 
        }
         return JSON.serialize(lstRet) ;
    }
    
    public class ContactResultWrapper{
        public String contactId {get;set;}
        public String contactName {get;set;}
        public String emailId {get;set;}
        public String customerName {get;set;}
        public String itemText {set;get;}
        
    }
}