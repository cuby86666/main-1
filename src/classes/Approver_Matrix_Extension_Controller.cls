/****************************************************************************************************************
@Created By :   Scarlett Kang
@Created Date:  May 22, 2015
@Description:   Replace button on Approver Matrix to update opportunities when system admin change approver
******************************************************************************************************************/
/**********************
@ Updated By: Scarlett Kang
@ Update Date: 1506 Release
@ Description: Changed to Batch 
*******************************************
@ Updated By: Jewelslyn
@ Update Date: 1605 Release
@ Description: added new approver fields and removed old approver fields as part DW approval revision
*******************************************/
public with sharing class Approver_Matrix_Extension_Controller {
    private Approvers_Matrix__c ApproverM;
    public List<Opportunity> lstAffectedOpps;
    
    public Approver_Matrix_Extension_Controller( ApexPages.StandardController stdController ) {
        
        this.ApproverM = (Approvers_Matrix__c)stdController.getRecord();
        
        ApproverM = [
            SELECT  Id,
                    Approver__c,
                    Former_Approver__c,
                    criteria_2__c,
                    Type__c,
                    Criteria_1__c
            FROM    Approvers_Matrix__c
            WHERE   Id = :ApproverM.Id
        ];
    }
    
    public pageReference Approvers() {

        lstAffectedOpps = [
            SELECT  Id,
                    Account_Region__c,
                    Parent_Account_Segment_Approval__c
            FROM    Opportunity
            WHERE   (                    
                    BL_Approver_1__c=:ApproverM.Former_Approver__c
                    OR BL_Approver_2__c=:ApproverM.Former_Approver__c
                    OR BL_Approver_3__c=:ApproverM.Former_Approver__c
                    OR BL_Approver_4__c=:ApproverM.Former_Approver__c
                    OR BL_Approver_5__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_1__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_2__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_3__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_4__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_5__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_6__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_7__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_8__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_9__c=:ApproverM.Former_Approver__c
                    OR MAG_Approver_10__c=:ApproverM.Former_Approver__c
                    OR Sales_Director_Approver__c=:ApproverM.Former_Approver__c
                    OR Regional_VP_Approver__c=:ApproverM.Former_Approver__c 
                    ) 
                    AND 
                    (Design_Win_Approval_Process__c = 'Pending'
                    OR Design_Win_Approval_Process__c = 'Open')
        ];
         

        
        //update opportunity by batch job
        
        UpdateOpportunityBatch updateOpps = new UpdateOpportunityBatch();
        updateOpps.ApproverId = string.valueof(ApproverM.Former_Approver__c);
        ID batchprocessid = Database.executeBatch(updateOpps, 50);
        
        
                
        PageReference Approver_Matrix_Page = new PageReference('/' + ApproverM.Id);
        Approver_Matrix_Page.setRedirect(true);
        return Approver_Matrix_Page;
    }
}