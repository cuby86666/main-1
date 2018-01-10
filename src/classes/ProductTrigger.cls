/*
@Created By :       Nisha Agrawal
@Created Date:      03 Oct 2012
@Description:       Apex class for Product Trigger methods
*/
/*
@Modified By :       Stan Hsu
@For Release:      15.04
@Description:       Standard Price Book debug
*/
/*
@Modified By :       Stan Hsu
@For Release:      15.10 Hotfix
@For SIR:       #520
*/
/*
Modified By :  Balaji G Dec 31, 2015
Description : Commented lines which creates records in PriceBookEntry with JPY currency as JPY currency is planned for deactivation
@For SIR:     # 238
*/

public with sharing class ProductTrigger {
    /**
     * This is a product field set for the criterias.
     */
    final static Set<String> fieldsSet = new Set<String> {
        'MAG__c',
        'BU__c', 
        'BL__c'     
    };
        
    public static Boolean IsFirstRun_AfterUpdate = true;
    public static Boolean IsFirstRun_AfterInsert = true;
    
    public static void updateOpptyLineItemProductStatus(Map<Id,Product2> productMap) {
        //J Added by Jason Tsai on April 26, 2016. 
        // To prevent claim value calculation if triggered from Product object change.
        OpportunityProductClaimValue.isUpdatable = false;
                                 
        List<OpportunityLineItem> oliList = [select id,Product_Status__c, Thrust_Indicator__c , PricebookEntryId,PricebookEntry.Product2Id , Opportunity.Design_Win_Approval_Process__c
                                               from OpportunityLineItem
                                              where PricebookEntry.Product2Id in: productMap.keySet() 
                                                and ((Opportunity.RecordTypeId = :OpportunitiesSelector.getSfdcRecordTypeId())
                                                and (Opportunity.Design_Win_Approval_Process__c =: 'Pending' or Opportunity.Design_Win_Approval_Process__c =: 'Rejected' or Opportunity.Design_Win_Approval_Process__c =: 'Open'))
                                            ];        
        if (oliList.size() > 0) {
            Product2 objProduct;
            
            for (OpportunityLineItem oli: oliList) {
                objProduct = productMap.get(oli.PricebookEntry.Product2Id);
                
                //Set Product Status
                if (oli.Opportunity.Design_Win_Approval_Process__c == 'Open' || oli.Opportunity.Design_Win_Approval_Process__c == 'Pending') {
                    oli.Product_Status__c = (objProduct.IsActive ? 0 : 1);
                }               
            }                       
            
            update oliList;
            
            //J Added by Jason Tsai on April 26, 2016. 
            // To prevent claim value calculation if triggered from Product object change. 
            OpportunityProductClaimValue.isUpdatable = true;
        }       
    }
    
    public static void updateOpportunityFields(List<Product2> lstNewProducts, List<Product2> lstOldProducts) {
        Set<Id> productIdSet = new Set<Id>();
        
        for (Integer i=0; Trigger.new != null && i < Trigger.new.size(); i++) {       
            if (Trigger.old != null && Trigger.old[i] != null) {
                SObject soProductNew = Trigger.new[i];
                SObject soProductOld = Trigger.old[i];
                Boolean bisFieldChange = false;
                
                for (String sfield : fieldsSet) {   
                    String oNewValue = (String) soProductNew.get(sfield);
                    String oOldValue = (String) soProductOld.get(sfield);
                    
                    if ((oOldValue == null && (oNewValue != null && oNewValue.length() > 0)) || 
                        (oNewValue == null && (oOldValue != null && oOldValue.length() > 0)) || 
                        (oNewValue != null && oOldValue != null && !oNewValue.equals(oOldValue))) {
                        bisFieldChange = true;
                    }
                }
                
                if (bisFieldChange) {
                    productIdSet.add(Trigger.new[i].Id);    
                }               
            }
        }
        
        if (!productIdSet.isEmpty()) {
            OpportuniLineItemTrigger.executeProductUpdate(productIdSet);    
        }
    }
    
    public static void insertProductIntoStandardPB(List<Product2> lstProducts) {
        //J Added by Jason Tsai on April 22, 2016
        // To solve the issue of not being able to create a product and price book entry in test classes
        ID pricebookId;
        
        if (Test.isRunningTest()) {
            pricebookId = Test.getStandardPricebookId();
        } else {
            sObject s = [Select ID From Pricebook2 Where IsStandard = TRUE ];
            pricebookId = s.Id;
        }
        //-J
        
        List<PricebookEntry> listPricebookEntries = new List<PricebookEntry>();
         
        if (pricebookId != null) {
        	for (Product2 theProduct : lstProducts) {
/* 2015.10 Hotfix SIR#520 ***** BEGIN ***/
            //if (theProduct.isActive == true) {
                listPricebookEntries.add
                    (
                        new PricebookEntry
                        (
                            Pricebook2Id=pricebookId, 
                            Product2Id=theProduct.ID, 
                            UnitPrice=0.00, 
                            CurrencyIsoCode='USD',
                            IsActive=TRUE, 
                            UseStandardPrice=FALSE
                        )
                    ); 

                listPricebookEntries.add
                    (
                        new PricebookEntry
                        (
                            Pricebook2Id=pricebookId, 
                            Product2Id=theProduct.ID, 
                            UnitPrice=0.00, 
                            CurrencyIsoCode='EUR',
                            IsActive=TRUE, 
                            UseStandardPrice=FALSE
                        )
                    ); 
            //}
            /* SFDC-1094: set all pricebookentry items to active, remove the logic of setting pricebookentry to inactive
            if (theProduct.isActive == false) {
                listPricebookEntries.add
                    (
                        new PricebookEntry
                        (
                            Pricebook2Id=pricebookId, 
                            Product2Id=theProduct.ID, 
                            UnitPrice=0.00, 
                            CurrencyIsoCode='USD',
                            IsActive=FALSE, 
                            UseStandardPrice=FALSE)); 
 
                listPricebookEntries.add
                    (
                        new PricebookEntry
                        (
                            Pricebook2Id=pricebookId, 
                            Product2Id=theProduct.ID, 
                            UnitPrice=0.00, 
                            CurrencyIsoCode='EUR',
                            IsActive=FALSE, 
                            UseStandardPrice=FALSE
                        )
                    ); 
            }*/
/* 2015.10 Hotfix SIR#520 ***** END ***/
        }
    }
        insert listPricebookEntries;
    }
    
}