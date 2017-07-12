public class AgreementApproverRuleFactory {
    public static AgreementApproverRules createAgreementApproverRoles(Apttus__APTS_Agreement__c agreement){
        if(agreement.nxp_Agreement_Type__c == 'Brand License Out'){
            return new BrandLicenseOutAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Cooperation Agreement'){
            return new CooperationAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Customer Payment Security'){
            return new CustomerPaymentSecurityApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Design In / Development Agreement'){
            return new DesignInDevAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Distributor Agreement'){
            return new DistributorAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'IDH/PDH/VAR'){
            return new IDHPDHVARAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Customer Logistics / Inventory Agreement'){
            return new CustLogiInventAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Master Sales Agreement'){
            return new MasterSalesAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Other (SALES)'){
            return new OtherSalesAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Product Longevity Agreement'){
            return new ProductLongevityAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Pre-Production Agreement'){
            return new PreProductionAgreementtApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Distributor P4P / Rebate / T&C Allowance Agreement'){
            return new DistriP4PRebateTCAllowanceApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'OEM /EMS P4P / Rebate / T&C Allowance Agreement'){
            return new OEMEMSP4PRebTCAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Pricing Agreement (actual price load is done via Model N)'){
            return new PricingAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Customer Quality Agreement'){
            return new CustomerQualityAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Settlement Agreement over $250,000'){
            return new SettlementAgreementApproverRules();
        }
        
         if(agreement.nxp_Agreement_Type__c == 'Sales Representative Contract'){
            return new SalesRepContractAgreementApproverRules();
        }
        
         if(agreement.nxp_Agreement_Type__c == 'Sustainability Agreement'){
            return new SustainabilityAgreementApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Software or Technology License In / Out'){
            return new SoftwareTechLicenseOutApproverRules();
        }
        
        if(agreement.nxp_Agreement_Type__c == 'Tender Agent / Consultant Agreement'){
            return new TenderAgentAgreementApproverRules();
        }
        return null;
    }
}