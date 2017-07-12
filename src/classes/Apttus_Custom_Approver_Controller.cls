public without sharing class Apttus_Custom_Approver_Controller
{
    private final Apttus__APTS_Agreement__c currentAgreement;
    
    public Apttus_Custom_Approver_Controller(ApexPages.StandardController controller) {
        currentAgreement = (Apttus__APTS_Agreement__c )controller.getRecord();
    }
    
    public List<SelectOption> getLegal_Picklist() {
        return getApprover_Picklist('Legal');
/*        Schema.DescribeFieldResult F = Customer__c.Industry_Segment__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;*/
    }

    public List<SelectOption> getApprover1_Picklist() {
        return getApprover_Picklist(currentAgreement.Approver_1_Role__c);
    }

    public List<SelectOption> getApprover2_Picklist() {
        return getApprover_Picklist(currentAgreement.Approver_2_Role__c);
    }

    public List<SelectOption> getApprover3_Picklist() {
        return getApprover_Picklist(currentAgreement.Approver_3_Role__c);
    }

    public List<SelectOption> getApprover4_Picklist() {
        return getApprover_Picklist(currentAgreement.Approver_4_Role__c);
    }

    public List<SelectOption> getApprover5_Picklist() {
        return getApprover_Picklist(currentAgreement.Approver_5_Role__c);
    }

    public List<SelectOption> getApprover6_Picklist() {
        return getApprover_Picklist(currentAgreement.Approver_6_Role__c);
    }

    public List<SelectOption> getApprover7_Picklist() {
        return getApprover_Picklist(currentAgreement.Approver_7_Role__c);
    }

    public List<SelectOption> getApprover8_Picklist() {
        return getApprover_Picklist(currentAgreement.Approver_8_Role__c);
    }
    
    public List<SelectOption> getApprover9_Picklist() {
        return getApprover_Picklist(currentAgreement.Approver_9_Role__c);
    }
    
    public List<SelectOption> getMTApprover_Picklist() {
        return getApprover_Picklist(currentAgreement.MT_Approver_Role__c);
    }
    
    public List<SelectOption> getApprover_Picklist(String role)
    {
        System.debug('########## Role=' + role);
        List<SelectOption> options = new List<SelectOption>();
        List<Apttus_Approver_Table__c> approver = 
            [SELECT Name, Role__c, User__c 
                FROM Apttus_Approver_Table__c
                WHERE Role__c = :role
                ORDER BY Name];
        options.add(new SelectOption('','--None--'));
        for(Apttus_Approver_Table__c apttus : approver)
        {
            options.add(new SelectOption(apttus.User__c,apttus.Name));
            System.debug('########## User__c=' + apttus.User__c + ', Name=' + apttus.Name);
        }
        return options;
    }

    public void SubmitApprovers()
    {
        try {
            //currentAgreement.nxp_complete_checked__c = true;
            update currentAgreement;
        }catch(Exception e){
            System.debug(e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getdmlMessage(0)));
        }
/*        PageReference currentPage = new PageReference( ApexPages.CurrentPage().getUrl() );
        currentPage.setRedirect(true);
        return currentPage;*/
    }
}