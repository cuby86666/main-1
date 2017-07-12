/****************************************************************************************************************
@Created By :   Scarlett Kang
@Created Date:  May 26, 2015
@Description:   Replace button on Apttus Approver Table to update Agreement records when system admin change approver
******************************************************************************************************************/
public class Apttus_Approver_Table_Ext_Controller{
    private Apttus_Approver_Table__c apttusApprover;
    public List<Apttus__APTS_Agreement__c> agreementList;
    public Id ApproverId;
    
    public Apttus_Approver_Table_Ext_Controller( ApexPages.StandardController stdController ) {
        this.apttusApprover = (Apttus_Approver_Table__c)stdController.getRecord();
        
        apttusApprover = [
            SELECT  Id, 
                    Role__c,
                    User__c,
                    Former_Approver__c
            FROM    Apttus_Approver_Table__c
            WHERE   Id = :apttusApprover.Id
        ];
    }
     
    public pageReference Approvers() {
        /*
        agreementList = [         
            SELECT  Id,
                    Approver1__c,
                    Approver2__c,
                    Approver3__c,
                    Approver4__c,
                    Approver5__c,
                    Approver6__c,
                    Approver_7__c,
                    Approver8__c,
                    Approver_9__c,
                    Legal__c,
                    MT_Approver__c,
                    nxp_Additional_Approver__c
                    Approver_1_Role__c,
                    Approver_2_Role__c,
                    Approver_3_Role__c,
                    Approver_4_Role__c,
                    Approver_5_Role__c,
                    Approver_6_Role__c,
                    Approver_7_Role__c,
                    Approver_8_Role__c,
                    Approver_9_Role__c,
                    MT_Approver_Role__c
            FROM    Apttus__APTS_Agreement__c
            WHERE   (
                    Approver1__c = :apttusApprover.Former_Approver__c
                    OR Approver2__c = :apttusApprover.Former_Approver__c
                    OR Approver3__c = :apttusApprover.Former_Approver__c
                    OR Approver4__c = :apttusApprover.Former_Approver__c
                    OR Approver5__c = :apttusApprover.Former_Approver__c
                    OR Approver6__c = :apttusApprover.Former_Approver__c
                    OR Approver_7__c = :apttusApprover.Former_Approver__c
                    OR Approver8__c = :apttusApprover.Former_Approver__c
                    OR Approver_9__c = :apttusApprover.Former_Approver__c
                    OR Legal__c = :apttusApprover.Former_Approver__c
                    OR MT_Approver__c = :apttusApprover.Former_Approver__c
                    OR nxp_Additional_Approver__c = :apttusApprover.Former_Approver__c
                 ) 
/*
                  AND
                  (
                    Approver_1_Role__c = :apttusApprover.Role__c
                    OR Approver_2_Role__c = :apttusApprover.Role__c
          OR Approver_3_Role__c = :apttusApprover.Role__c
                    OR Approver_4_Role__c = :apttusApprover.Role__c
                    OR Approver_5_Role__c = :apttusApprover.Role__c
                    OR Approver_6_Role__c = :apttusApprover.Role__c
                    OR Approver_7_Role__c = :apttusApprover.Role__c
                    OR Approver_8_Role__c = :apttusApprover.Role__c
                    OR MT_Approver_Role__c = :apttusApprover.Role__c    
                    )
*/
/*
                AND Apttus__Status__c = 'Request Approval'
        ];
        */
        
        ApproverId = apttusApprover.Former_Approver__c;
        
        system.debug('Approver Id: ' + ApproverId + '***************');
        
        agreementList = [
            SELECT  Approver1__c, 
                    Approver2__c, 
                    Approver3__c, 
                    Approver4__c, 
                    Approver5__c, 
                    Approver6__c, 
                    Approver_7__c, 
                    Approver8__c, 
                    Approver_9__c, 
                    Legal__c, 
                    MT_Approver__c, 
                    nxp_Additional_Approver__c,
                    Approver_1_Role__c,
                    Approver_2_Role__c,
                    Approver_3_Role__c,
                    Approver_4_Role__c,
                    Approver_5_Role__c,
                    Approver_6_Role__c,
                    Approver_7_Role__c,
                    Approver_8_Role__c,
                    Approver_9_Role__c,
                    MT_Approver_Role__c 
            FROM    Apttus__APTS_Agreement__c
            WHERE   (Approver1__c = :apttusApprover.Former_Approver__c OR
                    Approver2__c = :apttusApprover.Former_Approver__c OR
                    Approver3__c =: apttusApprover.Former_Approver__c OR
                    Approver4__c =: apttusApprover.Former_Approver__c OR
                    Approver5__c =: apttusApprover.Former_Approver__c OR
                    Approver6__c =: apttusApprover.Former_Approver__c OR
                    Approver_7__c =: apttusApprover.Former_Approver__c OR
                    Approver8__c =: apttusApprover.Former_Approver__c OR
                    Approver_9__c =: apttusApprover.Former_Approver__c OR
                    Legal__c =: apttusApprover.Former_Approver__c OR
                    MT_Approver__c =: apttusApprover.Former_Approver__c OR
                    nxp_Additional_Approver__c  =: apttusApprover.Former_Approver__c)
                    AND 
                    (Apttus__Status__c = 'Request Approval'
                    OR Apttus__Status__c = 'Request'
                    )
        ];
        
        if(agreementList.Size() > 0){
            for(Apttus__APTS_Agreement__c agmt : agreementList){
                if(agmt.Approver_1_Role__c == apttusApprover.Role__c && agmt.Approver1__c == apttusApprover.Former_Approver__c){
                    agmt.Approver1__c = apttusApprover.User__c;
                    system.debug('Update Approver 1*****************');
                }
                if(agmt.Approver_2_Role__c == apttusApprover.Role__c && agmt.Approver2__c == apttusApprover.Former_Approver__c){
                    agmt.Approver2__c = apttusApprover.User__c;
                    system.debug('Update Approver 2*****************');
                }
                if(agmt.Approver_3_Role__c == apttusApprover.Role__c && agmt.Approver3__c == apttusApprover.Former_Approver__c)
                    agmt.Approver3__c = apttusApprover.User__c;
                if(agmt.Approver_4_Role__c == apttusApprover.Role__c && agmt.Approver4__c == apttusApprover.Former_Approver__c)
                    agmt.Approver4__c = apttusApprover.User__c;
                if(agmt.Approver_5_Role__c == apttusApprover.Role__c && agmt.Approver5__c == apttusApprover.Former_Approver__c)
                    agmt.Approver5__c = apttusApprover.User__c;
                if(agmt.Approver_6_Role__c == apttusApprover.Role__c && agmt.Approver6__c == apttusApprover.Former_Approver__c)
                    agmt.Approver6__c = apttusApprover.User__c;
                if(agmt.Approver_7_Role__c == apttusApprover.Role__c && agmt.Approver_7__c == apttusApprover.Former_Approver__c)
                    agmt.Approver_7__c = apttusApprover.User__c;
                if(agmt.Approver_8_Role__c == apttusApprover.Role__c && agmt.Approver8__c == apttusApprover.Former_Approver__c)
                    agmt.Approver8__c = apttusApprover.User__c;
                if(agmt.Approver_9_Role__c == apttusApprover.Role__c && agmt.Approver_9__c == apttusApprover.Former_Approver__c)
                    agmt.Approver_9__c = apttusApprover.User__c;
                if(apttusApprover.Role__c == 'Management Team' && agmt.MT_Approver__c == apttusApprover.Former_Approver__c)
                    agmt.MT_Approver__c = apttusApprover.User__c;
                if(apttusApprover.Role__c == 'Legal' && agmt.Legal__c == apttusApprover.Former_Approver__c){
                    system.debug('Update Legal success************');
                    agmt.Legal__c = apttusApprover.User__c;
                }
            }

            update agreementList;
        }
        
        PageReference Apttus_Approver_Matrix_Page = new PageReference('/' + apttusApprover.Id);
        Apttus_Approver_Matrix_Page.setRedirect(true);
        return Apttus_Approver_Matrix_Page;
    }
}