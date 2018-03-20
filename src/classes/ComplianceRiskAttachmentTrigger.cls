/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Baji
 * Created Date : 22 Jan,2017
 * Description   : To update file details on risk assessment based on the files uploaded, edited or deleted.
 ------------------------------------------------------------------------------------------------------------------*/

public class ComplianceRiskAttachmentTrigger {

    Public static set<id> setAttParentId = new set<id>();
    Public static Map<id,Attachment> mapAttachDetails = new Map<id,Attachment>();
    Public static List<Compliance_Risk__c> lstRiskAsmtupdate = new List<Compliance_Risk__c>();
    
    Public static void captureFileDetailsRiskAssmt( List<attachment> lstAttachmts) {  
      for(Attachment objAttach : lstAttachmts)
       {
           setAttParentId.add(objAttach.parentId);
           system.debug('attparentid1' + objAttach.parentId);
       }
      List<Attachment> lstAttmts = [SELECT Id,Name,parentId,lastmodifieddate
                                           FROM Attachment 
                                           WHERE id=:lstAttachmts];
          system.debug('linkidsize^^' + lstAttmts.size());
          system.debug('linkidlist^^' + lstAttmts);
      for(Attachment objAttmt: lstAttmts)
        {
          system.debug('linkid2^^' + objAttmt.parentid);
          mapAttachDetails.put(objAttmt.parentid,objAttmt);
        }
 
      List<Compliance_Risk__c> lstRiskAsmt = [SELECT Id,opportunity__r.stagename,opportunity__r.Number_of_Compliance_Asse_Evidences__c,Compliance_Risk_Assessment_File_Name__c ,Compliance_Risk_Assessment_Uploaded__c,Compliance_Risk_Last_Modfied_Date__c,
                                            Project_Report_File_Name__c,Project_Report_Uploaded__c,Project_Report_Last_Modified_Date__c,
                                            Tender_Spec_File_Name__c,Tender_Spec_Uploaded__c,Tender_Specification_Last_Modified_Date__c,
                                            Background_Check_File_Name__c,Background_Check_Uploaded__c,Background_Check_Last_Modified_Date__c,
                                            Customer_Meeting_File_Name__c,Customer_Meeting_Uploaded__c,Customer_Meeting_Last_Modified_Date__c
                                            FROM Compliance_Risk__c
                                            WHERE Id =:setAttParentId];
          system.debug('RiskAsmtid3' + lstRiskAsmt);
      
      
   
       for(Compliance_Risk__c  objRiskAsmt :  lstRiskAsmt)
        {
          for(attachment  objAtt : lstAttachmts ){
             if(objRiskAsmt.id == objAtt.parentId){
                if(mapAttachDetails.containskey(objRiskAsmt.id)){
                    if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR001'))
                    {
                        if((trigger.isInsert && objRiskAsmt.Compliance_Risk_Assessment_Uploaded__c == false) || trigger.isUpdate){
                        objRiskAsmt.Compliance_Risk_Assessment_File_Name__c = mapAttachDetails.get(objRiskAsmt.id).name;
                        objRiskAsmt.Compliance_Risk_Assessment_Uploaded__c = true;
                        objRiskAsmt.Compliance_Risk_Last_Modfied_Date__c = Date.valueOf(mapAttachDetails.get(objRiskAsmt.id).lastmodifieddate);
                        lstRiskAsmtupdate.add(objRiskAsmt);
                        system.debug('RiskAsmtupdate31' + lstRiskAsmtupdate);
                       }
                      else if(trigger.isInsert && objRiskAsmt.Compliance_Risk_Assessment_Uploaded__c == true && objRiskAsmt.opportunity__r.stagename != 'Commitment') {
                        objAtt.addError('Please upload latest version of evidence after removing the current version.');
                        }
                    }            
                
            
                   if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR002'))
                    {
                        if((trigger.isInsert && objRiskAsmt.Project_Report_Uploaded__c == false)|| trigger.isUpdate){
                        objRiskAsmt.Project_Report_File_Name__c = mapAttachDetails.get(objRiskAsmt.id).name;
                        objRiskAsmt.Project_Report_Uploaded__c = true;
                        objRiskAsmt.Project_Report_Last_Modified_Date__c = Date.valueOf(mapAttachDetails.get(objRiskAsmt.id).lastmodifieddate);
                        lstRiskAsmtupdate.add(objRiskAsmt);
                        system.debug('RiskAsmtupdate32' + lstRiskAsmtupdate);
                       }
                     else if(trigger.isInsert && objRiskAsmt.Project_Report_Uploaded__c == true && objRiskAsmt.opportunity__r.stagename != 'Commitment') {
                        objAtt.addError('Please upload latest version of evidence after removing the current version.');
                        }
                    } 
                if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR003'))
                    {
                        if((trigger.isInsert && objRiskAsmt.Tender_Spec_Uploaded__c == false) || trigger.isUpdate) {
                        objRiskAsmt.Tender_Spec_File_Name__c = mapAttachDetails.get(objRiskAsmt.id).name;
                        objRiskAsmt.Tender_Spec_Uploaded__c = true;
                        objRiskAsmt.Tender_Specification_Last_Modified_Date__c = Date.valueOf(mapAttachDetails.get(objRiskAsmt.id).lastmodifieddate);
                        lstRiskAsmtupdate.add(objRiskAsmt);
                        system.debug('RiskAsmtupdate33' + lstRiskAsmtupdate);
                       }
                     else if(trigger.isInsert && objRiskAsmt.Tender_Spec_Uploaded__c == true && objRiskAsmt.opportunity__r.stagename != 'Commitment') {
                        objAtt.addError('Please upload latest version of evidence after removing the current version.');
                        }
                    }
                if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR004'))
                    {
                        if((trigger.isInsert && objRiskAsmt.Background_Check_Uploaded__c == false) || trigger.isUpdate){
                        objRiskAsmt.Background_Check_File_Name__c = mapAttachDetails.get(objRiskAsmt.id).name;
                        objRiskAsmt.Background_Check_Uploaded__c = true;
                        objRiskAsmt.Background_Check_Last_Modified_Date__c = Date.valueOf(mapAttachDetails.get(objRiskAsmt.id).lastmodifieddate);
                        lstRiskAsmtupdate.add(objRiskAsmt);
                        system.debug('RiskAsmtupdate34' + lstRiskAsmtupdate);
                       }
                     else if(trigger.isInsert && objRiskAsmt.Background_Check_Uploaded__c == true && objRiskAsmt.opportunity__r.stagename != 'Commitment') {
                        objAtt.addError('Please upload latest version of evidence after removing the current version.');
                        }
                    }
                if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR005'))
                    {
                        if((trigger.isInsert && objRiskAsmt.Customer_Meeting_Uploaded__c == false) || trigger.isUpdate){
                        objRiskAsmt.Customer_Meeting_File_Name__c = mapAttachDetails.get(objRiskAsmt.id).name;
                        objRiskAsmt.Customer_Meeting_Uploaded__c = true;
                        objRiskAsmt.Customer_Meeting_Last_Modified_Date__c = Date.valueOf(mapAttachDetails.get(objRiskAsmt.id).lastmodifieddate);
                        lstRiskAsmtupdate.add(objRiskAsmt);
                        system.debug('RiskAsmtupdate35' + lstRiskAsmtupdate);
                       }
                     else if(trigger.isInsert && objRiskAsmt.Customer_Meeting_Uploaded__c == true && objRiskAsmt.opportunity__r.stagename != 'Commitment') {
                        objAtt.addError('Please upload latest version of evidence after removing the current version.');
                        }
                    }
                 }
              }
            }
          }
     try{
         update lstRiskAsmtupdate;  
     }
        
      catch(exception e){
       for(Compliance_Risk__c  objRiskAsmt :  lstRiskAsmt){
       for(attachment  objAtt : lstAttachmts ){
       if(objRiskAsmt.opportunity__r.stagename == 'Commitment')
        {
                objAtt.addError('Cannot Upload/Edit/Delete evidences if opportunity is at Commitment stage.');
        }
       }
     }
   }
  }
  
 
  Public static void removeFileDetailsRiskAssmt( List<attachment> lstDelAttachmts) {  
    
    for(Attachment objAttach : lstDelAttachmts)
             {
               setAttParentId.add(objAttach.parentId);
               system.debug('attparentid1' + objAttach.parentId);
             }
    List<Attachment> lstAttmtsDel = [SELECT Id,Name,parentId,lastmodifieddate
                                           FROM Attachment 
                                           WHERE id=:lstDelAttachmts];
      system.debug('linkidsize^^' + lstAttmtsDel.size());
      system.debug('linkidlist^^' + lstAttmtsDel);
         for(Attachment objAttmt: lstAttmtsDel)
             {
                  system.debug('linkid2^^' + objAttmt.parentid);
                  mapAttachDetails.put(objAttmt.parentid,objAttmt);
                  
              }
 
    List<Compliance_Risk__c> lstRiskAsmt = [SELECT Id,opportunity__r.stagename,Compliance_Risk_Assessment_File_Name__c ,Compliance_Risk_Assessment_Uploaded__c,Compliance_Risk_Last_Modfied_Date__c,
                                            Project_Report_File_Name__c,Project_Report_Uploaded__c,Project_Report_Last_Modified_Date__c,
                                            Tender_Spec_File_Name__c,Tender_Spec_Uploaded__c,Tender_Specification_Last_Modified_Date__c,
                                            Background_Check_File_Name__c,Background_Check_Uploaded__c,Background_Check_Last_Modified_Date__c,
                                            Customer_Meeting_File_Name__c,Customer_Meeting_Uploaded__c,Customer_Meeting_Last_Modified_Date__c
                                         FROM Compliance_Risk__c
                                         WHERE Id =:setAttParentId];
      system.debug('RiskAsmtid3' + lstRiskAsmt);
  
       for(Compliance_Risk__c  objRiskAsmt :  lstRiskAsmt)
        {
          if(mapAttachDetails.containskey(objRiskAsmt.id)){
            if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR001'))
                {
                    objRiskAsmt.Compliance_Risk_Assessment_File_Name__c = '';
                    objRiskAsmt.Compliance_Risk_Assessment_Uploaded__c = false;
                    objRiskAsmt.Compliance_Risk_Last_Modfied_Date__c = null;
                    lstRiskAsmtupdate.add(objRiskAsmt);
                    system.debug('RiskAsmtdelete31' + lstRiskAsmtupdate);
                }
                
            
             if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR002'))
                {
                    objRiskAsmt.Project_Report_File_Name__c = '';
                    objRiskAsmt.Project_Report_Uploaded__c = false;
                    objRiskAsmt.Project_Report_Last_Modified_Date__c = null;
                    lstRiskAsmtupdate.add(objRiskAsmt);
                    system.debug('RiskAsmtdelete32' + lstRiskAsmtupdate);
                }
                
            if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR003'))
                {
                    objRiskAsmt.Tender_Spec_File_Name__c = '';
                    objRiskAsmt.Tender_Spec_Uploaded__c = false;
                    objRiskAsmt.Tender_Specification_Last_Modified_Date__c = null;
                    lstRiskAsmtupdate.add(objRiskAsmt);
                    system.debug('RiskAsmtdelete33' + lstRiskAsmtupdate);
                }
            if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR004'))
                {
                    objRiskAsmt.Background_Check_File_Name__c = '';
                    objRiskAsmt.Background_Check_Uploaded__c = false;
                    objRiskAsmt.Background_Check_Last_Modified_Date__c = null;
                    lstRiskAsmtupdate.add(objRiskAsmt);
                    system.debug('RiskAsmtdelete34' + lstRiskAsmtupdate);
                }
            if((mapAttachDetails.get(objRiskAsmt.id).name).contains('CR005'))
                {
                    objRiskAsmt.Customer_Meeting_File_Name__c = '';
                    objRiskAsmt.Customer_Meeting_Uploaded__c = false;
                    objRiskAsmt.Customer_Meeting_Last_Modified_Date__c = null;
                    lstRiskAsmtupdate.add(objRiskAsmt);
                    system.debug('RiskAsmtdelete35' + lstRiskAsmtupdate);
              }
       }
   }
   try{  
    update lstRiskAsmtupdate;
   }
   catch(exception e){
   for(Compliance_Risk__c  objRiskAsmt :  lstRiskAsmt){
   if(objRiskAsmt.opportunity__r.stagename == 'Commitment')
    {
      for(attachment  objAtt :  lstDelAttachmts)
           {
               objAtt.addError('Cannot Upload/Edit/Delete evidences if opportunity is at Commitment stage.');
           }
      }
    }
   }  
  }
 }