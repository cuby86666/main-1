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
        'BL__c',
        'SalesItem_ProductState__c'     
    };
        
    public static Boolean IsFirstRun_AfterUpdate = true;
    public static Boolean IsFirstRun_AfterInsert = true;
    
    public static void updateOpportunityFields(List<Product2> lstNewProducts, List<Product2> lstOldProducts) {
        Set<Id> prodIds = new Set<Id>();
        
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
                    prodIds.add(Trigger.new[i].Id);    
                }               
            }
        }
        
        if (!prodIds.isEmpty()) {
            updateOpptiesAndOpptyProds(prodIds);    
        }
    }
  
    @future
    private static void updateOpptiesAndOpptyProds(Set<Id> prodIds) {
    	for (List<OpportunityLineItem> olis : [select OpportunityId, Program__c from OpportunityLineItem where PricebookEntry.Product2.Id in :prodIds]) {
    	    if (olis.size() > 0) {
    	    	// To prevent claim value calculation if triggered from Product object change.
    	    	OpportunityProductClaimValue.isUpdatable = false;

            	update olis;

            	OpportunityProductClaimValue.isUpdatable = true;
            	
            	List<SObject> parents = (List<SObject>)dlrs.RollupService.rollup(olis);
				
				if (parents != null && parents.size() > 0) {
					update parents;	
				}
        	}
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
        	}
    	}
        
        insert listPricebookEntries;
    }
    
}