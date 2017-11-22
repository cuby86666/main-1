public class LeadConvertWrapper {
    
    public class LeadInitialReturns{
        @AuraEnabled public Lead leadCurrent;
        @AuraEnabled public list<Lead_Activity__c> listLdActivityCurrent;
        @AuraEnabled public Account leadAccountCurrent;
        @AuraEnabled public list<Opportunity> listOppty; 
    } 

}