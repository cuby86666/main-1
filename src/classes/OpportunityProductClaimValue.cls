/**
 * Fields updated:
 *   OpportunityLineItem
 *	   LT_Value__c
 *     Claim_Value__c
 *	   Lost_Cancelled_LT_Value__c
 *     Lost_Cancelled_Claim_Value__c
 *   
 *   Opportunity
 *     AccountId
 *     TMMA_Override__c
 */
public class OpportunityProductClaimValue {
	@TestVisible 
    private static final Map<String, String> MAG_CLAIM_VALUE_QUARTERS = new Map<String, String>();
    
    private static final Boolean CROSS_UPDATE_ALLOWED;
    private static final String ACCOUNT_CBG;
    
    // TMMA
    private static final List<String> TMMA_OVERRIDE_FIELDS_OPPTY = new List<String>();
    private static final List<String> TMMA_OVERRIDE_FIELDS_OPPTY_PROD = new List<String>();
        
    // Used to prevent claim value calculation if triggered from other object changes, such as Product2 and Account.
    public static Boolean isUpdatable = true;
    
    static {
        Opportunity_Claim_Value_Setting__mdt claimValueSetting = ((List<Opportunity_Claim_Value_Setting__mdt>)new OpportunityClaimValueSettingsSelector().selectWhere('MasterLabel = \'Setting\'')).get(0);
        
        CROSS_UPDATE_ALLOWED = claimValueSetting.Cross_Update_Allowed__c;
        ACCOUNT_CBG = claimValueSetting.Account_CBG__c;
        
        List<Opportunity_Claim_Value_MAG_Setting__mdt> claimValueMagSettings = (List<Opportunity_Claim_Value_MAG_Setting__mdt>)new OpportunityClaimValueMagSettingsSelector().selectAll();
        
        for (Opportunity_Claim_Value_MAG_Setting__mdt ocvms : claimValueMagSettings) {
        	MAG_CLAIM_VALUE_QUARTERS.put(ocvms.MAG__c, ocvms.Claim_Value_Quarters__c);
        }
        
        // TMMA
        List<Opportunity_TMMA_Override_Setting__mdt> tmmaOverrideSettings = (List<Opportunity_TMMA_Override_Setting__mdt>)new OpportunityTmmaOverrideSettingsSelector().selectAll();
        
        for (Opportunity_TMMA_Override_Setting__mdt otos : tmmaOverrideSettings) {
        	if (otos.Object_Name__c == 'Opportunity') {
        		TMMA_OVERRIDE_FIELDS_OPPTY.add(otos.Field_Name__c);	
        	} else if (otos.Object_Name__c == 'OpportunityLineItem') {
        		TMMA_OVERRIDE_FIELDS_OPPTY_PROD.add(otos.Field_Name__c);	
        	}
        }
    }
   
    interface ClaimValueType {
        void setOpptyProdClaimValue(Opportunity oppty, OpportunityLineItem opptyLineItem, List<OpportunitySchedule__c> opptyScheds);
    }
    
    class LifetimeClaimValueType implements ClaimValueType {
        public void setOpptyProdClaimValue(Opportunity oppty, OpportunityLineItem opptyLineItem, List<OpportunitySchedule__c> opptyScheds) {
        	p('setOpptyProdClaimValue');
			List<Double> quarterQtys = new List<Double>();
			
            for (OpportunitySchedule__c opptySched : opptyScheds) {
            	quarterQtys.add(opptySched.Frozen_Oppty_Sched_Qty__c);
            }
           
            opptyLineItem.Claim_Value__c = calcOpptyProdClaimValue(oppty, opptyLineItem, quarterQtys);
            opptyLineItem.LT_Value__c = opptyLineItem.Claim_Value__c;            
        }
        
        private void p(String msg) {
			CommonUtils.p(this, '//-c', msg);
		}
    }
    
    class ShortLivedClaimValueType implements ClaimValueType {
        public void setOpptyProdClaimValue(Opportunity oppty, OpportunityLineItem opptyLineItem, List<OpportunitySchedule__c> opptyScheds) {
        	p('setOpptyProdClaimValue');
        	List<Double> quarterQtys = new List<Double>();
        	List<Double> claimValueQtrQtys = new List<Double>();
    		Date prodDate = oppty.Production_Date__c;
    		String prodYrQtr = prodDate.year() + '0' + (((prodDate.month() - 1) / 3) + 1);
            Integer startIndex = -1;
    	
    		for (Integer i = 0; i < opptyScheds.size(); i++) {
    			OpportunitySchedule__c opptySched = opptyScheds.get(i);
    			Date schedDate = opptySched.Sched_Date__c;
    			String yrQtr = schedDate.year() + '0' + (((schedDate.month() - 1) / 3) + 1); 	
    		
    			if (yrQtr.equals(prodYrQtr)) {
    				startIndex = i;
    			}
    		
    			quarterQtys.add(opptySched.Frozen_Oppty_Sched_Qty__c);
    		}
        	
        	Integer magClaimValueQuarters = Integer.valueOf(MAG_CLAIM_VALUE_QUARTERS.get(opptyLineItem.MAG__c));
            Integer endIndex = startIndex + magClaimValueQuarters;
            
            for (Integer i = startIndex; (i < endIndex && i < quarterQtys.size()); i++) {
            	claimValueQtrQtys.add(quarterQtys.get(i));     
            }
            
            opptyLineItem.Claim_Value__c = calcOpptyProdClaimValue(oppty, opptyLineItem, claimValueQtrQtys);
            opptyLineItem.LT_Value__c = calcOpptyProdClaimValue(oppty, opptyLineItem, quarterQtys);            
        } 
        
        private void p(String msg) {
			CommonUtils.p(this, '//-c', msg);
		}       
    }
    
    public static void setOpportunityProductClaimValues(List<OpportunityLineItem> opptyLineItems) {
        p2('setOpportunityProductClaimValues');
        if (!(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && isUpdatable())) return;
                
        setOpptyProdClaimValues(opptyLineItems);
    }
    
    private static void setOpptyProdClaimValues(List<OpportunityLineItem> opptyLineItems) {
        p2('setOpptyProdClaimValues');
        if (opptyLineItems.size() == 0) return;
                	
        Map<Id, Opportunity> opptyDetails = getOpptyDetails(opptyLineItems);
        ClaimValueType claimValueType;
        
    	List<OpportunitySchedule__c> opptysScheds = new OpportunitySchedulesSelector().selectByOpptyId(opptyDetails.keySet());
    		
    	if (opptysScheds.size() == 0) return;
            
        for (OpportunityLineItem oli : opptyLineItems) {
        	Opportunity oppty = opptyDetails.get(oli.OpportunityId);
            	
            List<OpportunitySchedule__c> opptyScheds = getOpptyScheds(opptysScheds, oppty);
                    
			claimValueType = getClaimValueType(oppty, oli);
            claimValueType.setOpptyProdClaimValue(oppty, oli, opptyScheds);
                    
            setOpptyProdCancelledClaimValue(oli);
			p2('SFDC type oppty prod => lost/cancelled: ' + oli.Prod_Lost_Cancelled__c + ', claim value: ' + oli.Claim_Value__c + ', cancelled claim value: ' + oli.Lost_Cancelled_Claim_Value__c + ', lifetime value: ' + oli.LT_Value__c + ', cancelled lifetime value: ' + oli.Lost_Cancelled_LT_Value__c);
        }
    }
    
    private static Map<Id, Opportunity> getOpptyDetails(List<OpportunityLineItem> opptyLineItems) {
    	p2('getOpptyDetails');
        Set<Id> opptyIds = getOpptyIds(opptyLineItems);
          
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(new OpportunitiesSelector().selectByIdWithAccountAndOwner(opptyIds)); 
         
        return result;
    }
    
    private static ClaimValueType getClaimValueType(Opportunity oppty, OpportunityLineItem opptyLineItem) {
    	p2('getClaimValueType');
		if (isLifetime(oppty, opptyLineItem)) {
  			return new LifetimeClaimValueType();           
        } else {
            return new ShortLivedClaimValueType();
        }
    }
    
    @TestVisible
    private static Boolean isLifetime(Opportunity oppty, OpportunityLineItem opptyLineItem) {  
    	p2('isLifetime');  	
   		if (oppty.AccountId == null || oppty.Account.CMD_Industry_Segment__c == null || opptyLineItem.MAG__c == null) {
    		return true;	
    	}
    	
        String opptyAcctCBG = oppty.Account.CMD_Industry_Segment__c;
		String magClaimValueQuarters = MAG_CLAIM_VALUE_QUARTERS.get(opptyLineItem.MAG__c);
        
        if ((magClaimValueQuarters == null) && Test.isRunningTest()) {
        	return true;	
        }
        
        if ((opptyAcctCBG == ACCOUNT_CBG) || !magClaimValueQuarters.isNumeric()) {
        	return true;    
        } else {
            return false;
        }
    }
    
    private static void setOpptyProdCancelledClaimValue(OpportunityLineItem opptyLineItem) {
    	p2('setOpptyProdCancelledClaimValue');
    	opptyLineItem.Lost_Cancelled_Claim_Value__c = 0;
    	opptyLineItem.Lost_Cancelled_LT_Value__c = 0;
    	
        if (OpportunityLineItems.LOST_CANCELLED.contains(opptyLineItem.Prod_Lost_Cancelled__c)) {
            opptyLineItem.Lost_Cancelled_Claim_Value__c = opptyLineItem.Claim_Value__c;
            opptyLineItem.Claim_Value__c = 0;
            opptyLineItem.Lost_Cancelled_LT_Value__c = opptyLineItem.LT_Value__c;
            opptyLineItem.LT_Value__c = 0;
        }    
    }
    
    private static List<OpportunitySchedule__c> getOpptyScheds(List<OpportunitySchedule__c> opptyScheds, Opportunity oppty) {
    	p2('getOpptyScheds');
    	List<OpportunitySchedule__c> result = new List<OpportunitySchedule__c>();
    	
    	for (OpportunitySchedule__c os : opptyScheds) {
    		if (os.Opportunity__c == oppty.Id) {
    			result.add(os);
    		}
    	}
    	
    	return result;
    }
    
    private static Double calcOpptyProdClaimValue(Opportunity oppty, OpportunityLineItem opptyLineItem, List<Double> quarterQtys) {
    	p2('calcOpptyProdClaimValue');
    	Decimal price = 0;
    	Decimal sumQuarterValue = 0;
    	
    	for (Integer i = 0; i < quarterQtys.size(); i++) {
    		price = OpportunityLineItems.calcOpportunityProductSchedulePrice(opptyLineItem.UnitPrice, opptyLineItem.Price_Erosion_Rate__c, i);
    		sumQuarterValue += (quarterQtys.get(i) != null ? quarterQtys.get(i) : 0) * price;
    	}
    	
    	Double result = sumQuarterValue * opptyLineItem.Component_Multiplier__c * (opptyLineItem.Share__c / 100);
    	
    	return result;
    }
    
    private static Boolean isUpdatable() {
    	p2('isUpdatable');
        return (isUpdatable || CROSS_UPDATE_ALLOWED) ? true : false;    
    }
    
    private static Map<Id, Opportunity> getOpptyRecordTypeIds(List<OpportunityLineItem> opptyLineItems) {
    	p2('getOpptyRecordTypeIds');
        Set<Id> opptyIds = new Set<Id>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
            opptyIds.add(oli.OpportunityId);
        }
        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
        
        return result;
    }
    
    private static Set<Id> getOpptyIds(List<OpportunityLineItem> opptyLineItems) {
    	p2('getOpptyIds');
        Set<Id> result = new Set<Id>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
            result.add(oli.OpportunityId);
        }
        
        return result;
    }
    
    // TMMA
    public static void bypassOpportunityProductMnUpdateForTmmaOverride(Map<Id, OpportunityLineItem> opptyLineItemsOld, Map<Id, OpportunityLineItem> opptyLineItemsNew) {
    	p2('bypassOpportunityProductMnUpdateForTmmaOverride');
    	Map<Id, Opportunity> opptys = getOpptyRecordTypeIds(opptyLineItemsNew.values());
        
        for (OpportunityLineItem oliNew : opptyLineItemsNew.values()) {
        	OpportunityLineItem oliOld = opptyLineItemsOld.get(oliNew.Id);    
            Opportunity oppty = opptys.get(oliNew.OpportunityId);
            
            if (isMnRecordType(oppty) && isTmmaOverride(oppty) && CommonUtils.isDataAdminUser()) {
            	setTmmaOverrideFields(oliOld, oliNew, TMMA_OVERRIDE_FIELDS_OPPTY_PROD);
            }
        }	
    }
    
    public static void updateTmmaOverrideIfOpportunityProductMnUpdatedByTmma(Map<Id, OpportunityLineItem> opptyLineItemsOld, Map<Id, OpportunityLineItem> opptyLineItemsNew, fflib_ISObjectUnitOfWork uow) {
    	p2('updateTmmaOverrideIfOpportunityProductMnUpdatedByTmma');
    	Map<Id, Opportunity> opptys = getOpptyRecordTypeIds(opptyLineItemsNew.values());
    	
    	Map<Id, Opportunity> opptyMNs = new Map<Id, Opportunity>();
    	
    	for (Opportunity o : opptys.values()) {
    		if (isMnRecordType(o)) {
    			opptyMNs.put(o.Id, o);
    		}
    	}
    	
    	if (opptyMNs.size() == 0) return;
    	
    	for (OpportunityLineItem oliNew : opptyLineItemsNew.values()) {
    		OpportunityLineItem oliOld = opptyLineItemsOld.get(oliNew.Id);    
            Opportunity oppty = opptyMNs.get(oliNew.OpportunityId);
            
            if (oppty != null && isMnRecordType(oppty) && !CommonUtils.isDataAdminUser() && isTmmaOverrideFieldsChanged(oliOld, oliNew, TMMA_OVERRIDE_FIELDS_OPPTY_PROD)) {
            	oppty.TMMA_Override__c = true;
            	uow.registerDirty(oppty);
            }		
    	}
    }
    
    public static void bypassOpportunityMnUpdateForTmmaOverride(Map<Id, Opportunity> opptiesOld, Map<Id, Opportunity> opptiesNew) {
    	p2('bypassOpportunityMnUpdateForTmmaOverride');
    	for (Opportunity oNew : opptiesNew.values()) {
        	Opportunity oOld = opptiesOld.get(oNew.Id);    
                        
            if (isMnRecordType(oNew) && isTmmaOverride(oNew) && CommonUtils.isDataAdminUser()) {
            	setTmmaOverrideFields(oOld, oNew, TMMA_OVERRIDE_FIELDS_OPPTY);
            }
        }
    }
    
    public static void updateMnOpportunityAccounts(List<Opportunity> oppties) {
    	p2('updateMnOpportunityAccounts');	
    	List<Opportunity> mnOppties = new List<Opportunity>();
    	
    	for (Opportunity o : oppties) {
        	if (isMnRecordType(o) && CommonUtils.isAdmin()) {
            	mnOppties.add(o);
            }
        }
        
        if (mnOppties.size() > 0) {
        	OpportunityService.updateMnOpportunityAccounts(mnOppties, null);	
        }
    }
    
    public static void updateTmmaOverrideIfOpportunityMnUpdatedByTmma(Map<Id, Opportunity> opptiesOld, Map<Id, Opportunity> opptiesNew) {
    	p2('updateTmmaOverrideIfOpportunityMnUpdatedByTmma');
    	for (Opportunity oNew : opptiesNew.values()) {
        	Opportunity oOld = opptiesOld.get(oNew.Id);
        	
        	if (isMnRecordType(oNew) && !CommonUtils.isDataAdminUser() && isTmmaOverrideFieldsChanged(oOld, oNew, TMMA_OVERRIDE_FIELDS_OPPTY)) {
            	oNew.TMMA_Override__c = true;	
            }
    	}	
    }
    
    private static void setTmmaOverrideFields(SObject soOld, SObject soNew, List<String> fieldNames) {
    	p2('setTmmaOverrideFields');
    	for (String fn : fieldNames) {
        	soNew.put(fn, soOld.get(fn));	
        }	
    }
    
    private static Boolean isTmmaOverrideFieldsChanged(SObject soOld, SObject soNew, List<String> fieldNames) {
    	p2('isTmmaOverrideFieldsChanged');
    	Boolean result = false;
    	
    	for (String fn : fieldNames) {
    		result |= (soOld.get(fn) != soNew.get(fn));
    	}
    	
    	return result;
    }
    
    private static Boolean isTmmaOverride(Opportunity oppty) {
    	return oppty.TMMA_Override__c;
    }
    
    private static Boolean isMnRecordType(Opportunity oppty) {
		return oppty.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId();
    }
    
    private static void p2(String msg) {
		CommonUtils.p(OpportunityProductClaimValue.class, '//-c', msg);
	}
	
}