public with sharing class CustomerQualityAgreementApproverRules implements AgreementApproverRules {
    /*
        
        
        

        Approver 4(BL/BU Manager):BL Marketing Manager / Stakeholder ≤ 10M$
                                  BL General Manager ≤ 100M$
                                  BU General Manager > 100M$ or Red Flag
                                  
       

        Approver 6(GSM):          BL Controller  ≤ 10M$
                                  BU Controller ≤ 100M$ ≤ 100M$
                                  Regional GSM Controller and GSM Controller   > 100M$ or Red Flag

        
        Approver 9:               BU Quality Manager

    */
    public Apttus__APTS_Agreement__c populateApprovers(Apttus__APTS_Agreement__c agreement){
        
        
         //Adding null to wipe out old values just in case user edits  record
       agreement.Approver_1_role__c=null;
       agreement.Approver_2_role__c=null;
       agreement.Approver_3_role__c=null;
       agreement.Approver_4_role__c=null;
       agreement.Approver_5_role__c=null;
       agreement.Approver_6_role__c=null;
       agreement.Approver_7_role__c=null;
       agreement.Approver_8_role__c=null;
         
       
       
       if(agreement.Total_Agreement_Value_in_millions__c <=10 ){
            agreement.Approver_4_role__c = 'BL Marketing Manager / Stakeholder';
            
            agreement.Approver_6_role__c = 'BL Controller';
        }else if(agreement.Total_Agreement_Value_in_millions__c >10 && agreement.Total_Agreement_Value_in_millions__c <=100 ){
            agreement.Approver_4_role__c = 'BL General Manager';
            
            agreement.Approver_6_role__c = 'BU Controller';
        }else if(agreement.Total_Agreement_Value_in_millions__c >100){
            agreement.Approver_4_role__c = 'BU General Manager';
            
            agreement.Approver_6_role__c = 'Regional GSM Controller';
            agreement.Approver_7_role__c = 'GSM Controller';
        }
        
        
        //Block to check for Red Flag
         if(agreement.Availability_of_Products__c==true||agreement.Best_Price_Provisions__c==true||agreement.Capacity_Requirements_Commitments__c==true||
                agreement.Development_Commitments__c==true||agreement.Exclusivity__c==true||agreement.Intellectual_Property__c==true||
                agreement.Limitation_of_Liability__c==true||agreement.Preproduction_Shipments__c==true||agreement.Transferring_Title_Red_Flags__c==true||
                agreement.Liquidated_Damage_Provisions__c==true||agreement.Epidemic_Failure_Provisions__c==true||agreement.Unusual_Risk__c==true)
                
         {
             agreement.Approver_4_role__c = 'BU General Manager';
             
             agreement.Approver_6_role__c = 'Regional GSM Controller';
             agreement.Approver_7_role__c = 'GSM Controller';
         
         
         
         }
        
        
         
         
         agreement.Approver_9_role__c = 'BU Quality Manager';

        

        return agreement;
    }
}