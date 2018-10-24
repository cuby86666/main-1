public with sharing class OpportunityService {
	
	private static final Date NIL_DATE = Date.newInstance(0, 0, 0);
	private static final String STAGE_COMMITMENT = Opportunities.STAGE_COMMITMENT;
	
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
	
    //SFDC-1154
    public static void updateProbabilityToWin(Set<Id> opptyIds){
        p('updateProbabilityToWin');
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        OpportunityLineItems opptyProds = new OpportunityLineItems(new OpportunityLineItemsSelector().selectByOpptyIdWithProduct(opptyIds, OpportunityLineItems.LOST_CANCELLED));
    	opptyProds.updateOpptyProdProbabilityToWin(uow);	
        
        uow.commitWork();	
    }
	
	public class DesignWinApprover {
		public String label;
		public String name;
	}
	
	public static Map<Id, String> deriveMnOpportunityStages(Set<Id> opptyIds) {
		p('deriveMnOpportunityStages');
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
	
	public static void updateMnOpportunityAccountsAndOwners(List<Opportunity> oppties, fflib_ISObjectUnitOfWork uow) {
		p('updateMnOpportunityAccountsAndOwners');
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
				
				if (!legacyIds.contains(legacyIdString)) {
					legacyIds.add(legacyIdString);
				}
			}
		}
		
		List<Account> accounts = new AccountsSelector().selectChildAccountsWithOwnerByGidOrLegacyId(gids, legacyIds);
		List<User> drApporvers = new UsersSelector().selectSalesforceUsersByUsername(legacyOpptyOwners);
		Map<String, Account> accountsByGidOrLegacyId = new Map<String, Account>();
		
		for (Account account : accounts) {
			if (account.NXP_GID__c != null && !accountsByGidOrLegacyId.containsKey(account.NXP_GID__c)) {
				accountsByGidOrLegacyId.put(account.NXP_GID__c, account);
			}
			
			if (account.Legacy_Id__c != null && !accountsByGidOrLegacyId.containsKey(account.Legacy_Id__c)) {
				accountsByGidOrLegacyId.put(account.Legacy_Id__c, account);
			}
		}

		Map<String, User> drApporversByUsername = new Map<String, User>();
		
		for (User user : drApporvers) {
			drApporversByUsername.put(user.Username, user);
		}

		List<Opportunity> opptyUpdates = new List<Opportunity>();
		
		Account unknownAccount = getUnknownAccount();

		for (Opportunity oppty : oppties) {
			if (oppty.RecordTypeId != modelNRecordTypeId) continue;
			
			Id drApproverId = drApporversByUsername.get(oppty.Legacy_Opportunity_Owner__c) != null ? drApporversByUsername.get(oppty.Legacy_Opportunity_Owner__c).Id : null;
			Id newAccountId = oppty.AccountId;
			Id newAccountOwnerId = null;
			Id newOwnerId = oppty.OwnerId;

			if (oppty.End_Customer_GID__c != null && accountsByGidOrLegacyId.containsKey(oppty.End_Customer_GID__c)) {
				Account accountByGid = accountsByGidOrLegacyId.get(oppty.End_Customer_GID__c);
				newAccountId = accountByGid.Id;

				if (accountByGid.OwnerId != CommonUtils.getDataAdminUserId() && accountByGid.Owner.IsActive) {
					newAccountOwnerId = accountByGid.OwnerId;
				}
            } else if (oppty.Distributor_Name__c != null && oppty.End_Customer_Region__c != null && accountsByGidOrLegacyId.containsKey(getMnDistiAccountLegacyId(oppty))) {
				Account accountByLegacyId = accountsByGidOrLegacyId.get(getMnDistiAccountLegacyId(oppty));
				newAccountId = accountByLegacyId.Id;
            } else if (unknownAccount != null) {
				newAccountId = unknownAccount.Id;
            }

			if (oppty.OwnerId == CommonUtils.getDataAdminUserId()) {
				if (newAccountOwnerId != null) {
					newOwnerId = newAccountOwnerId; 	
				} else if (drApproverId != null) {
					newOwnerId = drApproverId; 	
				}
			} 

			if (oppty.AccountId != newAccountId || oppty.OwnerId != newOwnerId) {
				oppty.AccountId = newAccountId;
				oppty.OwnerId = newOwnerId;
				opptyUpdates.add(oppty);
			}
		}
        
		if (uow != null) {
			uow.registerDirty(opptyUpdates);
		}
	}
	
	public static void setMnOpportunityCloseDateAndProdDate(Opportunity oppty, Date prodDate, Date partWinDate) {
		p('setMnOpportunityCloseDateAndProdDate(oppty, prodDate, partWinDate)');
		setMnOpportunityCloseDateAndProdDate(oppty, null, null, prodDate, partWinDate);
	}
	
	public static void setMnOpportunityCloseDateAndProdDate(Opportunity oppty, Opportunity opptyOld, Date closeDate, Date prodDate, Date partWinDate) {
		p('setMnOpportunityCloseDateAndProdDate(oppty, opptyOld, closeDate, prodDate, partWinDate)');
		if (isCommitment(oppty) && !isCommitment(opptyOld)) {
			oppty.CloseDate = partWinDate;
			
			if (prodDate < partWinDate) {
				oppty.Production_Date__c = partWinDate.addMonths(6);
			} else {
				oppty.Production_Date__c = prodDate;
			} 
		} else {
			oppty.CloseDate = (closeDate != null ? closeDate : prodDate);	
			oppty.Production_Date__c = prodDate;
		}	
	}
	
	private static Boolean isCommitment(Opportunity oppty) {
    	p('isCommitment');
    	return (oppty != null && oppty.StageName == STAGE_COMMITMENT) ? true : false;
    }
	
	public static void setMnOpportunityLostCancelledInfo(Opportunity oppty, Date actionDate) {
		p('setMnOpportunityLostCancelledInfo');	
		setMnOpptyLostCancelledInfo(oppty, actionDate);
	}
	
	private static void setMnOpptyLostCancelledInfo(Opportunity oppty) {
		p('setMnOpptyLostCancelledInfo(oppty)');	
		setMnOpptyLostCancelledInfo(oppty, NIL_DATE);
	}
	
	private static void setMnOpptyLostCancelledInfo(Opportunity oppty, Date actionDate) {
		p('setMnOpptyLostCancelledInfo(oppty, actionDate)');	
		
		if (oppty.StageName == Opportunities.STAGE_LOST) {
			oppty.Lost_Date__c = oppty.Expiration_Date__c;
			oppty.Lost_Reason__c = Opportunities.MN_LOST_REASON;
		} else if (oppty.StageName == Opportunities.STAGE_CANCELLED && actionDate != NIL_DATE) { // actionDate can be null, so cannot use null as condition check.
			oppty.Lost_Date__c = actionDate;
			oppty.Lost_Reason__c = oppty.Design_Reg_Reject_Reason__c;		
		} else {
			oppty.Lost_Date__c = null;
			oppty.Lost_Reason__c = null;	
		}
	}
	
	public static Set<Id> updateMnOpportunityStages(List<Opportunity> oppties, fflib_ISObjectUnitOfWork uow) {
		List<Opportunity> opptyUpdates = new List<Opportunity>();
		Set<Id> opptyUpdateIds = new Set<Id>();
		Set<Id> allMnOpptyIds = new Set<Id>();
		Id modelNRecordTypeId = OpportunitiesSelector.getMnRecordTypeId();

		for (Opportunity oppty : oppties) {
			if (oppty.RecordTypeId != modelNRecordTypeId) continue;

			allMnOpptyIds.add(oppty.Id);
		}
		//Scan MN Oppty Stages
        //if (System.isBatch() && CommonUtils.isAdmin()) {
        Map<Id, String> mnOpptyStages = deriveMnOpportunityStages(allMnOpptyIds);

        for (Opportunity oppty : oppties) {
            if (mnOpptyStages.containsKey(oppty.Id) && oppty.StageName != mnOpptyStages.get(oppty.Id)) {
                oppty.StageName = mnOpptyStages.get(oppty.Id);

				setMnOpptyLostCancelledInfo(oppty); // SFDC-1407 
				
                if (!opptyUpdateIds.contains(oppty.Id)) {
                    opptyUpdateIds.add(oppty.Id);
                    opptyUpdates.add(oppty);
                }
            }
        }            
        //}

		if (uow != null) {
			uow.registerDirty(opptyUpdates);
		}

		return opptyUpdateIds;
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

	@TestVisible
	private static String getMnDistiAccountLegacyId(Opportunity oppty) {
		p('getMnDistiAccountLegacyId');
		return oppty.Distributor_Name__c + '-' + oppty.End_Customer_Region__c;
	}
	
	public static void shiftOpportunitySchedules(List<OpportunitySchedule__c> opptyScheds, Date prodDate) {
    	p('shiftOpportunitySchedules');
    	if (opptyScheds != null && opptyScheds.size() > 0) {
    		List<Date> schedDates = generateOpportunityScheduleDates(prodDate, opptyScheds.size());
    		
    		for (Integer i = 0; i < opptyScheds.size(); i++) {
    			opptyScheds.get(i).Sched_Date__c = schedDates.get(i);	
    		}	
    	}
    }
   
    public static List<Date> generateOpportunityScheduleDates(Date prodDate, Integer qtrs) {
    	p('generateOpportunityScheduleDates');
    	List<Date> result = new List<Date>();
    	
    	Integer prodQtr = ((prodDate.month() - 1) / 3) + 1;
		Integer prodQtrStartMonth = 3 * prodQtr - 2;	// qtr + 2 * (qtr - 1)
		Date prodQtrStartDate = Date.newInstance(prodDate.year(), prodQtrStartMonth, 1);
    	
    	for (Integer i = 0; i < qtrs; i++) {
    		if (i == 0) {
    			result.add(prodDate);		
    		} else {
    			result.add(prodQtrStartDate.addMonths(3 * i));
    		}
    	}
    	
    	return result; 
    } 
    
    public static Boolean isSfdcRecordType(Opportunity oppty) {
		p('isSfdcRecordType');
		return oppty.RecordTypeId == OpportunitiesSelector.getSfdcRecordTypeId();
    }
    
    public static Boolean isMnRecordType(Opportunity oppty) {
    	p('isMnRecordType');
		return oppty.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId();
    }
	
	private static void p(String msg) {
		CommonUtils.p(OpportunityService.class, '//-v', msg);
	}
    
}