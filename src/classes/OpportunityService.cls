public with sharing class OpportunityService {
	
	public static Map<Id, List<DesignWinApprover>> getDesignWinApprovers(Set<Id> opptyIds) {
		p('getDesignWinApprovers');
		Map<Id, List<DesignWinApprover>> result = new Map<Id, List<DesignWinApprover>>();
		
		Map<Id, Map<String, String>> approversByOpptyId = OpportunityApproval.getAllApprovers(new OpportunitiesSelector().selectByIdWithAccountAndOwner(opptyIds));
		
		for (Id opptyId : approversByOpptyId.keySet()) {
			List<DesignWinApprover> approvers = new List<DesignWinApprover>();
			
			for (String label : approversByOpptyId.get(opptyId).keySet()) {
				DesignWinApprover approver = new DesignWinApprover();
				approver.label = label;
				approver.name = approversByOpptyId.get(opptyId).get(label);
				approvers.add(approver); 	
			}		
			
			result.put(opptyId, approvers);
		}
		
		return result;
	}
	
	public static void updateDesignWinApprovers(Set<Id> opptyIds) {
		p('updateDesignWinApprovers');
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		Opportunities oppties = new Opportunities(new OpportunitiesSelector().selectByIdWithAccountAndOwner(opptyIds));
		oppties.updateDesignWinApprovers(uow);	
		
		uow.commitWork();	
	}
	
	public class DesignWinApprover {
		public String label;
		public String name;
	}
	
	public static void updateModelNExpiredOpportunities(List<Opportunity> oppties) {
		p('updateModelNExpiredOpportunities');
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
        List<Opportunity> opptiesUpdated = new Opportunities(oppties).updateModelNExpiredOpportunities(uow);
        
        new OpportunityLineItems(new OpportunityLineItemsSelector().selectByOpptyIdWithOpportunity(new Map<Id, Opportunity>(opptiesUpdated).keySet())).updateModelNExpiredOpportunityProducts(uow);
        
        uow.commitWork();
	}
	
	public static Set<Id> updateEndCustomerAccounts(List<Opportunity> oppties, Boolean uowRequired) {
		p('updateEndCustomerAccounts');
		String CUSTOMER_TMMA = 'Tier 4 - TMMA';
    	String CUSTOMER_TIER1 = 'Tier 1';
    	String CUSTOMER_TIER2 = 'Tier 2';
    	String CUSTOMER_TIER3 = 'Tier 3';
		
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		// If uowRequired is true, then add oppty to uow for updating by using uow.registerDirty(oppty)
		List<Opportunity> lstOppUpdate = new List<Opportunity>();
		//Oppty original AccountId
        Map<Id,Id> mapOriginalAccountId = new Map<Id,Id>();
		Set<Id> setAccountId = new Set<Id>();
		
		Map<String, Cross_Reference_Customer__c> mapEndCustNameToLoc = 
			new CrossReferenceCustomersSelector().selectByRecordTypeIdToMap(CrossReferenceCustomersSelector.getModelNRecordTypeId());
		for (Opportunity opp : oppties) {
			//check oppty is TMMA child account by end customer name and location
			if (mapEndCustNameToLoc.containsKey(opp.Legacy_End_Customer_Name_and_Location__c)) {
				//oppty account should be TMMA child account
				Cross_Reference_Customer__c cust = mapEndCustNameToLoc.get(opp.Legacy_End_Customer_Name_and_Location__c);
				if (opp.AccountId != cust.Child_Account__c) {
					//current oppty account is not TMMA account
                	if (opp.MN_Account_Id_Old__c == null) //backup original AccountId, if backup AccountId is null, do backup.
                        opp.MN_Account_Id_Old__c = opp.AccountId;

                    opp.AccountId = cust.Child_Account__c; //assign TMMA account to oppty
                    lstOppUpdate.add(opp); //add oppty to update list
				}
			} else {
                //oppty account should not be TMMA child account
                /*** 2017-09-11 Modified by Rex Lai
                SFDC-815: Including Tier 1, Tier 2, Tier3 ***/
				if (opp.Account.Customer_Category__c == CUSTOMER_TMMA || 
                    opp.Account.Customer_Category__c == CUSTOMER_TIER1 || 
                    opp.Account.Customer_Category__c == CUSTOMER_TIER2 || 
                    opp.Account.Customer_Category__c == CUSTOMER_TIER3) {
                    //if current oppty account is TMMA
                        if (opp.MN_Account_Id_Old__c != null && opp.MN_Account_Id_Old__c.length() > 0) {
                            //backup oppty original account id
                            mapOriginalAccountId.put(opp.Id, opp.AccountId);
                            opp.AccountId = opp.MN_Account_Id_Old__c;
                            opp.MN_Account_Id_Old__c = null;
                        }
                    lstOppUpdate.add(opp); //add oppty to update list
				}
				setAccountId.add(opp.AccountId);
			}
		}
		Set<Id> setOppty = new Set<Id>();
		Map<ID, Account> mapAccount = new Map<ID, Account>(new AccountsSelector().selectById(setAccountId));
        for (Opportunity o : lstOppUpdate) {
            if (!mapAccount.containsKey(o.AccountId)) {
                //rollback original account id
                o.AccountId = mapOriginalAccountId.get(o.Id);
            }
            setOppty.add(o.Id);
            if (uowRequired) uow.registerDirty(o);
        }

		if (uowRequired) uow.commitWork();
		return setOppty;
	}
	
	private static void p(String msg) {
		CommonUtils.p(OpportunityService.class, '//-v', msg);
	}
    
}