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
	
	public static Set<Id> updateModelNAccounts(List<Opportunity> oppties) {
		p('updateModelNAccounts');
		Set<String> gids = new Set<String>();
		Set<String> legacyIds = new Set<String>();
		for (Opportunity oppty : oppties) {
			/*if (oppty.GID__c != null && !gids.contains(oppty.GID__c)) {
				gids.add(oppty.GID__c);
			}
			if (oppty.Disti_Name__c != null && !legacyIds.contains(oppty.Disti_Name__c)) {
				legacyIds.add(oppty.Disti_Name__c);
			}*/
		}
		List<Account> accounts = new AccountsSelector().selectChildAccountsByGIDorLegacyId(gids, legacyIds);
		
		//convert List<Account> to Map<String,Account>
		Map<String,Account> accountsByGIDorLegacyId = new Map<String,Account>();
		for (Account account : accounts) {
			if (account.NXP_GID__c != null && !accountsByGIDorLegacyId.containsKey(account.NXP_GID__c)) {
				accountsByGIDorLegacyId.put(account.NXP_GID__c, account);
			}
			if (account.Legacy_Id__c != null && !accountsByGIDorLegacyId.containsKey(account.Legacy_Id__c)) {
				accountsByGIDorLegacyId.put(account.Legacy_Id__c, account);
			}
		}
		Set<Id> opptyIds = new Set<Id>();
		List<Opportunity> opptyUpdates = new List<Opportunity>();
		for (Opportunity oppty : oppties) {
			/*if (accountsByGIDorLegacyId.containsKey(oppty.GID__c)) {
				//By GID Account
				Account newAccount = accountsByGIDorLegacyId.get(oppty.GID__c));
				oppty.AccountId = newAccount.Id;
				opptyIds.add(oppty.Id);
				opptyUpdates.add(oppty);

			} else if (accountsByGIDorLegacyId.containsKey(oppty.Disti_Name__c)) {
				//By disti name + end customer region
				opptyUpdates.add(oppty);

			} else {
				//Unknown Account

			}*/
		}

		return null;
	}

	public static Set<Id> updateEndCustomerAccounts(List<Opportunity> oppties, Boolean uowRequired) {
		p('updateEndCustomerAccounts');
		String CUSTOMER_TMMA = 'Tier 4 - TMMA';
    	String CUSTOMER_TIER1 = 'Tier 1';
    	String CUSTOMER_TIER2 = 'Tier 2';
    	String CUSTOMER_TIER3 = 'Tier 3';
		
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		
		// If uowRequired is true, then add oppty to uow for updating by using uow.registerDirty(oppty)
		List<Opportunity> opptyUpdates = new List<Opportunity>();
		//Oppty original AccountId
        Map<Id,Id> accountIdsByOpptyId = new Map<Id,Id>();
		Set<Id> accountIds = new Set<Id>();
		
        //create End Customer set
        Set<String> endCustomers = new Set<String>();
        for (Opportunity oppty : oppties) {
            endCustomers.add(oppty.Legacy_End_Customer_Name_and_Location__c);
        }
        
		Map<String, Cross_Reference_Customer__c> crossRefCustsByEndCustNameLoc = 
			new CrossReferenceCustomersSelector().getByRecordTypeIdAndEndCustomerToMap(
			new Set<Id>{CrossReferenceCustomersSelector.getModelNRecordTypeId()}, endCustomers);
        
		for (Opportunity oppty : oppties) {
            //backup oppty original account id
            accountIdsByOpptyId.put(oppty.Id, oppty.AccountId);
            
			//check oppty is TMMA child account by end customer name and location
			if (crossRefCustsByEndCustNameLoc.containsKey(oppty.Legacy_End_Customer_Name_and_Location__c)) {
				//oppty account should be TMMA child account
				Cross_Reference_Customer__c cust = crossRefCustsByEndCustNameLoc.get(oppty.Legacy_End_Customer_Name_and_Location__c);
				if (oppty.AccountId != cust.Child_Account__c) {
					//current oppty account is not TMMA account
                	if (oppty.MN_Account_Id_Old__c == null) //backup original AccountId, if backup AccountId is null, do backup.
                        oppty.MN_Account_Id_Old__c = oppty.AccountId;

                    oppty.AccountId = cust.Child_Account__c; //assign TMMA account to oppty
                    opptyUpdates.add(oppty); //add oppty to update list
				}
			} else {
                //oppty account should not be TMMA child account
                /*** 2017-09-11 Modified by Rex Lai
                SFDC-815: Including Tier 1, Tier 2, Tier3 ***/
				if (oppty.Account.Customer_Category__c == CUSTOMER_TMMA || 
                    oppty.Account.Customer_Category__c == CUSTOMER_TIER1 || 
                    oppty.Account.Customer_Category__c == CUSTOMER_TIER2 || 
                    oppty.Account.Customer_Category__c == CUSTOMER_TIER3) {
                    //if current oppty account is TMMA
                        if (oppty.MN_Account_Id_Old__c != null && oppty.MN_Account_Id_Old__c.length() > 0) {
                            oppty.AccountId = oppty.MN_Account_Id_Old__c;
                            oppty.MN_Account_Id_Old__c = null;
                        }
                    opptyUpdates.add(oppty); //add oppty to update list
				}
			}
			accountIds.add(oppty.AccountId);
		}
		Set<Id> opptyIds = new Set<Id>();
		Map<ID, Account> accountsByAccountId = new Map<ID, Account>(new AccountsSelector().selectById(accountIds));
        for (Opportunity oppty : opptyUpdates) {
            if (!accountsByAccountId.containsKey(oppty.AccountId)) {
                //rollback original account id
                oppty.AccountId = accountIdsByOpptyId.get(oppty.Id);
            }
            opptyIds.add(oppty.Id);
        }
        
        if (uowRequired) {
        	uow.registerDirty(opptyUpdates);
        	uow.commitWork();
        }
		
		return opptyIds;
	}
	
	private static void p(String msg) {
		CommonUtils.p(OpportunityService.class, '//-v', msg);
	}
    
}