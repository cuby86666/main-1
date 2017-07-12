public class BrandLicenseOutAgreementApproverRules implements AgreementApproverRules {
    public Apttus__APTS_Agreement__c populateApprovers(Apttus__APTS_Agreement__c agreement){
    
         agreement.Approver_1_Role__c=null;
         agreement.Approver_2_Role__c=null;
    
    
        if(agreement.Total_Agreement_Value_in_millions__c > 5){
           agreement.Approver_1_Role__c = 'Corporate Control';
        }
        if(agreement.Total_Agreement_Value_in_millions__c <10){
            agreement.Approver_2_Role__c = 'BL Marketing Manager / Stakeholder';
        }else if(agreement.Total_Agreement_Value_in_millions__c >=10 && agreement.Total_Agreement_Value_in_millions__c <=100){
            agreement.Approver_2_Role__c = 'BL General Manager';
        }else{
            agreement.Approver_2_Role__c = 'BU General Manager';
        }
        
        //Block to check for Red Flag
         if(agreement.Availability_of_Products__c==true||agreement.Best_Price_Provisions__c==true||agreement.Capacity_Requirements_Commitments__c==true||
                agreement.Development_Commitments__c==true||agreement.Exclusivity__c==true||agreement.Intellectual_Property__c==true||
                agreement.Limitation_of_Liability__c==true||agreement.Preproduction_Shipments__c==true||agreement.Transferring_Title_Red_Flags__c==true||
                agreement.Liquidated_Damage_Provisions__c==true||agreement.Epidemic_Failure_Provisions__c==true||agreement.Unusual_Risk__c==true)
                
         {
             agreement.Approver_2_Role__c = 'BU General Manager';
         
         
         
         }
        return agreement;
    }
}