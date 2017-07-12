public with sharing class CustomerPaymentSecurityApproverRules implements AgreementApproverRules
{

     /*
        Approver 2: GSM Credit Control Manager
        
        
     
     
    */

     public Apttus__APTS_Agreement__c populateApprovers(Apttus__APTS_Agreement__c agreement)
     {
          
          //Approver2
          agreement.Approver_2_role__c = 'GSM Credit Control Manager';
          
          
          
          return agreement;
     
     }






}