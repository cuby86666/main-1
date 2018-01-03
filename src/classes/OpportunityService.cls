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
	
	public static Map<Id, String> deriveMnOpportunityStages(Set<Id> opptyIds) {
		Map<Id, String> result = new Map<Id, String>();
		
		List<Opportunity> oppties = new OpportunitiesSelector().selectByIdWithProducts(opptyIds);
		
		for (Opportunity o : oppties) {
			if (isMnRecordType(o)) {
				String regStatus = o.Design_Reg_Status__c;
				Date regExpirationDate = o.Expiration_Date__c;
				String regPartStatus = null;
				String regPartWinStatus = null;
				
				for (OpportunityLineItem oli : o.OpportunityLineItems) {
					regPartStatus = oli.Registration_Status__c;
					regPartWinStatus = oli.Win_Status__c;
					break;	
				}
				
				result.put(o.Id, deriveMnOpportunityStage(regPartStatus, regPartWinStatus, regStatus, regExpirationDate));
			}
		}		
		
		return result;
	}
	
	public static String deriveMnOpportunityStage(String regPartStatus, String regPartWinStatus, String regStatus, Date regExpirationDate) {
		p('deriveMnOpportunityStage');
		String result = 'UNKNOWN';
		Boolean isExpired = (regExpirationDate != null && regExpirationDate < System.today()) ? true : false;
		
		if (new Set<String> {MnStages.REG_PART_STATUS_PENDING, MnStages.REG_PART_STATUS_REQUESTED}.contains(regPartStatus) &&
		    regPartWinStatus == MnStages.REG_PART_WIN_STATUS_PENDING &&
		    new Set<String> {MnStages.REG_STATUS_PENDING, MnStages.REG_STATUS_REQUESTED, MnStages.REG_STATUS_APPROVED}.contains(regStatus) &&
		    !isExpired) {
			result = Opportunities.STAGE_INITIAL_ENGAGEMENT;    	
		} else if (regPartStatus == MnStages.REG_PART_STATUS_APPROVED &&
    	           regPartWinStatus == MnStages.REG_PART_WIN_STATUS_PENDING &&
    	           new Set<String> {MnStages.REG_STATUS_PENDING, MnStages.REG_STATUS_REQUESTED, MnStages.REG_STATUS_APPROVED}.contains(regStatus) &&
    	           !isExpired) {
			result = Opportunities.STAGE_DISCOVERY;	
		} else if ((new Set<String> {MnStages.REG_PART_STATUS_PENDING, MnStages.REG_PART_STATUS_REQUESTED}.contains(regPartStatus) && regPartWinStatus.contains('Win') && new Set<String> {MnStages.REG_STATUS_PENDING, MnStages.REG_STATUS_REQUESTED, MnStages.REG_STATUS_APPROVED}.contains(regStatus)) ||
		           (new Set<String> {MnStages.REG_PART_STATUS_APPROVED, MnStages.REG_PART_STATUS_REJECTED}.contains(regPartStatus) && regPartWinStatus.contains('Win'))) {
			result = Opportunities.STAGE_COMMITMENT;	
		} else if (new Set<String> {MnStages.REG_PART_STATUS_PENDING, MnStages.REG_PART_STATUS_REQUESTED, MnStages.REG_PART_STATUS_APPROVED}.contains(regPartStatus) &&
    	           regPartWinStatus == MnStages.REG_PART_WIN_STATUS_PENDING &&
    	           new Set<String> {MnStages.REG_STATUS_PENDING, MnStages.REG_STATUS_REQUESTED, MnStages.REG_STATUS_APPROVED}.contains(regStatus) &&
    	           isExpired) {
			result = Opportunities.STAGE_LOST;	
		} else if ((new Set<String> {MnStages.REG_PART_STATUS_PENDING, MnStages.REG_PART_STATUS_REQUESTED}.contains(regPartStatus) && regStatus == MnStages.REG_STATUS_REJECTED) ||
		           (regPartStatus == MnStages.REG_PART_STATUS_APPROVED && regPartWinStatus == MnStages.REG_PART_WIN_STATUS_PENDING && regStatus == MnStages.REG_STATUS_REJECTED) ||
    	           (regPartStatus == MnStages.REG_PART_STATUS_REJECTED && regPartWinStatus == MnStages.REG_PART_WIN_STATUS_PENDING)) {
			result = Opportunities.STAGE_CANCELLED;
		}
		
		return result;
	}
	
	public static Set<Id> updateMnOpportunityAccounts(List<Opportunity> oppties, fflib_ISObjectUnitOfWork uow) {
		p('updateMnOpportunityAccounts');
		Set<String> gids = new Set<String>();
		Set<String> legacyIds = new Set<String>();
		Set<String> legacyOpptyOwners = new Set<String>();
		Id modelNRecordTypeId = OpportunitiesSelector.getMnRecordTypeId();
		for (Opportunity oppty : oppties) {
			if (oppty.RecordTypeId != modelNRecordTypeId) continue;
			if (oppty.Legacy_Opportunity_Owner__c != null) {
				legacyOpptyOwners.add(oppty.Legacy_Opportunity_Owner__c);
			}
			if (oppty.End_Customer_GID__c != null && !gids.contains(oppty.End_Customer_GID__c)) {
				gids.add(oppty.End_Customer_GID__c);
			}
			if (oppty.Distributor_Name__c != null && oppty.End_Customer_Region__c != null) {
				String legacyIdString = getMnDistiAccountLegacyId(oppty);
				if (!legacyIds.contains(legacyIdString)) legacyIds.add(legacyIdString);
			}
		}
		List<Account> accounts = new AccountsSelector().selectChildAccountsWithOwnerByGidOrLegacyId(gids, legacyIds);
		List<User> drApporvers = new UsersSelector().selectSalesforceUsersByEmail(legacyOpptyOwners);
		//convert List<Account> to Map<String,Account>
		Map<String,Account> accountsByGidOrLegacyId = new Map<String,Account>();
		for (Account account : accounts) {
			//System.debug('@@@@@ Account Owner=' + account.Owner.Name);
			if (account.NXP_GID__c != null && !accountsByGidOrLegacyId.containsKey(account.NXP_GID__c)) {
				accountsByGidOrLegacyId.put(account.NXP_GID__c, account);
			}
			if (account.Legacy_Id__c != null && !accountsByGidOrLegacyId.containsKey(account.Legacy_Id__c)) {
				accountsByGidOrLegacyId.put(account.Legacy_Id__c, account);
			}
		}

		//convert List<User> to Map<String,User>
		Map<String,User> usersByEmail = new Map<String,User>();
		for (User user : drApporvers) {
			usersByEmail.put(user.Email, user);
		}

		Set<Id> opptyIds = new Set<Id>();
		Set<Id> allMnOpptyIds = new Set<Id>();
		List<Opportunity> opptyUpdates = new List<Opportunity>();
		Set<Id> opptyUpdateIds = new Set<Id>();
		for (Opportunity oppty : oppties) {
			if (oppty.RecordTypeId != modelNRecordTypeId) continue;
			allMnOpptyIds.add(oppty.Id);
			//System.debug('@@@@@ Owner=' + oppty.Owner.Name);
			String newAccountId = oppty.AccountId;
			String newOwnerId = null;
			if (oppty.End_Customer_GID__c != null && accountsByGidOrLegacyId.containsKey(oppty.End_Customer_GID__c)) {
				//By GID Account
				Account accountByGID = accountsByGidOrLegacyId.get(oppty.End_Customer_GID__c);
				newAccountId = accountByGID.Id;
				if (accountByGID.Owner.IsActive) newOwnerId = accountByGID.OwnerId;
                //System.debug('@@@@@ Account change to ' + accountByGID.Name + ', owner change to account owner.');
				opptyIds.add(oppty.Id);					
			} else if (oppty.Distributor_Name__c != null && oppty.End_Customer_Region__c != null && 
				accountsByGidOrLegacyId.containsKey(getMnDistiAccountLegacyId(oppty))) {
				//By Legacy Id
				Account accountByLegacyId = accountsByGidOrLegacyId.get(getMnDistiAccountLegacyId(oppty));
				newAccountId = accountByLegacyId.Id;
                //System.debug('@@@@@ Account change to ' + accountByLegacyId.Name);
			} else {
				//Unknown Account
				Account unknownAccount = getUnknownAccount();
                if (unknownAccount != null) {
                	newAccountId = unknownAccount.Id;
                    //System.debug('@@@@@ Account change to Unknown.');
                }
			}

			newOwnerId = getMnDrOwnerId(oppty, newOwnerId, usersByEmail);

			if (oppty.AccountId != newAccountId || oppty.OwnerId != newOwnerId) {
				oppty.AccountId = newAccountId;
				oppty.OwnerId = newOwnerId;
				opptyUpdates.add(oppty);
				opptyUpdateIds.add(oppty.Id);
			}
		}
        
		//System.debug('@@@@@ current user:' + UserInfo.getName());

		//Scan MN Oppty Stages
        if (System.isBatch() && UserInfo.getProfileId() == '00e20000001Nc7gAAC') {
            Map<Id, String> mnOpptyStages = deriveMnOpportunityStages(allMnOpptyIds);
            for (Opportunity oppty : oppties) {
                if (mnOpptyStages.containsKey(oppty.Id) && oppty.StageName != mnOpptyStages.get(oppty.Id)) {
                    oppty.StageName = mnOpptyStages.get(oppty.Id);
                    if (oppty.StageName == Opportunities.STAGE_LOST) {
	                    oppty.Lost_Date__c = oppty.Expiration_Date__c;
            			oppty.Lost_Reason__c = 'Expired';
                    }
                    if (!opptyUpdateIds.contains(oppty.Id)) {
                        opptyUpdateIds.add(oppty.Id);
                        opptyUpdates.add(oppty);
                    }
                }
            }            
        }

		if (uow != null) {
			uow.registerDirty(opptyUpdates);
		}

		return opptyIds;
	}

	//=========== Model N Account Update utility functions ========================================
	private static String getMnDrOwnerId(Opportunity oppty, String newAccountOwnerId, Map<String,User> usersByEmail) {
		p('getMnDrOwnerId');
		String finalOwnerId = oppty.OwnerId;
		User dataAdminUser = getDataAdmin();
		//System.debug('@@@@@ Data Admin id=' + dataAdminUser.Id);
		// Tier 1,2,3,4 - TMMA and Account Owner is Active
        if (newAccountOwnerId != null) {
            if (oppty.OwnerId == dataAdminUser.Id) {
                finalOwnerId = newAccountOwnerId;
                //System.debug('@@@@@ change owner to new account owner');
            } else {
                finalOwnerId = oppty.OwnerId;
                //System.debug('@@@@@ keep owner');
            }            
        } else {
			if (oppty.Legacy_Opportunity_Owner__c == null) {
				if (dataAdminUser != null && oppty.OwnerId == null) finalOwnerId = dataAdminUser.Id;
			} else {
				User drApprover = usersByEmail.get(oppty.Legacy_Opportunity_Owner__c);
				if (drApprover == null) {
					if (dataAdminUser != null && oppty.OwnerId == null) finalOwnerId = dataAdminUser.Id;
				} else {
					if (oppty.OwnerId == dataAdminUser.Id) {
						finalOwnerId = drApprover.Id;
                        //System.debug('@@@@@ change owner to approver');
					}
				}
			}
		}
		return finalOwnerId;
	}

	static Account UNKNOWN_ACCOUNT = null;
	private static Account getUnknownAccount() {
		p('getUnknownAccount');
		if (UNKNOWN_ACCOUNT == null) {
			List<Account> accounts = new AccountsSelector().selectByName(new Set<String> {'Unknown'});
			if (accounts.size() > 0) {
				UNKNOWN_ACCOUNT = accounts.get(0);
			}
		}
		return UNKNOWN_ACCOUNT;
	}

	static User DATA_ADMIN = null;
	private static User getDataAdmin() {
		p('getDataAdmin');
		if (DATA_ADMIN == null) {
			List<User> users = new UsersSelector().selectByName(new Set<String> {'Data Admin'});
			if (users.size() > 0) {
				DATA_ADMIN = users.get(0);
			}
		}
		return DATA_ADMIN;
	}

	private static String getMnDistiAccountLegacyId(Opportunity oppty) {
		p('getMnDistiAccountLegacyId');
		return oppty.Distributor_Name__c + '-' + oppty.End_Customer_Region__c;
	}
	//=============================================================================================

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
	
	private static Boolean isMnRecordType(Opportunity oppty) {
		return oppty.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId();
    }
	
	private static void p(String msg) {
		CommonUtils.p(OpportunityService.class, '//-v', msg);
	}
    
}