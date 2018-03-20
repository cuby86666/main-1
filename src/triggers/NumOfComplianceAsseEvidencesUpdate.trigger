trigger NumOfComplianceAsseEvidencesUpdate on Compliance_Risk__c (after update) {
 List<Opportunity> lstOpp = new List<Opportunity>();
 public static set<id> setOpptyId = new set<id>();

    List<Compliance_Risk__c> lstRiskAsmt = [SELECT Id,opportunity__r.stagename,opportunity__r.Number_of_Compliance_Asse_Evidences__c,Compliance_Risk_Assessment_File_Name__c ,Compliance_Risk_Assessment_Uploaded__c,Compliance_Risk_Last_Modfied_Date__c,
                                            Project_Report_File_Name__c,Project_Report_Uploaded__c,Project_Report_Last_Modified_Date__c,
                                            Tender_Spec_File_Name__c,Tender_Spec_Uploaded__c,Tender_Specification_Last_Modified_Date__c,
                                            Background_Check_File_Name__c,Background_Check_Uploaded__c,Background_Check_Last_Modified_Date__c,
                                            Customer_Meeting_File_Name__c,Customer_Meeting_Uploaded__c,Customer_Meeting_Last_Modified_Date__c
                                            FROM Compliance_Risk__c
                                            WHERE Id =:trigger.new];
      system.debug('RiskAsmtids' + lstRiskAsmt);
      
      for(Compliance_Risk__c  objRiskAsmt :  lstRiskAsmt){
          setOpptyId.add(objRiskAsmt.opportunity__c);
      }
      
   List<Opportunity> lstOppty = [Select id from Opportunity where id=:setOpptyId];
      
       for(Compliance_Risk__c  objRiskAsmt :  lstRiskAsmt){
         for(Opportunity  objOpp :  lstOppty){
             if(objRiskAsmt.opportunity__c == objOpp.id){
              system.debug('&&opptyid' + objOpp.id);
                 if(objRiskAsmt.Compliance_Risk_Assessment_Uploaded__c == true && objRiskAsmt.Project_Report_Uploaded__c == true && objRiskAsmt.Tender_Spec_Uploaded__c == true &&
                    objRiskAsmt.Background_Check_Uploaded__c && objRiskAsmt.Customer_Meeting_Uploaded__c == true){
                    objOpp.Number_of_Compliance_Asse_Evidences__c = 5;
                    lstOpp.add(objOpp);
               }
               else{
               objOpp.Number_of_Compliance_Asse_Evidences__c =null;
               lstOpp.add(objOpp);
               }
              }
             }
           }
            system.debug('%%opptylist' + lstOpp);
  update lstOpp;
}