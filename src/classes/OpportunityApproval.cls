public class OpportunityApproval {
	@TestVisible
	private static final Map<ApproverLabel, String> APPROVER_LABELS = new Map<ApproverLabel, String>();
	
	private static final List<String> MAG_APPROVER_FIELDS = new List<String>();
	private static final List<String> BL_APPROVER_FIELDS = new List<String>();
	private static final List<String> ALL_APPROVER_FIELDS = new List<String>();
	
	private static Approver approver;
	private static Boolean isUpdatable = true;
	
	static {
		APPROVER_LABELS.put(ApproverLabel.SALES_DIRECTOR_APPROVER, Opportunity.Sales_Director_Approver__c.getDescribe().getLabel());	
		APPROVER_LABELS.put(ApproverLabel.REGIONAL_VP_APPROVER, Opportunity.Regional_VP_Approver__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.VP_APPROVER_2, Opportunity.VP_Approver_2__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_1, Opportunity.MAG_Approver_1__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_2, Opportunity.MAG_Approver_2__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_3, Opportunity.MAG_Approver_3__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_4, Opportunity.MAG_Approver_4__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_5, Opportunity.MAG_Approver_5__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_6, Opportunity.MAG_Approver_6__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_7, Opportunity.MAG_Approver_7__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_8, Opportunity.MAG_Approver_8__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_9, Opportunity.MAG_Approver_9__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.MAG_APPROVER_10, Opportunity.MAG_Approver_10__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_1, Opportunity.BL_Approver_1__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_2, Opportunity.BL_Approver_2__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_3, Opportunity.BL_Approver_3__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_4, Opportunity.BL_Approver_4__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.BL_APPROVER_5, Opportunity.BL_Approver_5__c.getDescribe().getLabel());
		
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_1__c.getDescribe().getName());
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_2__c.getDescribe().getName());
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_3__c.getDescribe().getName());
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_4__c.getDescribe().getName());
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_5__c.getDescribe().getName());
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_6__c.getDescribe().getName());
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_7__c.getDescribe().getName());
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_8__c.getDescribe().getName());
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_9__c.getDescribe().getName());
		MAG_APPROVER_FIELDS.add(Opportunity.MAG_Approver_10__c.getDescribe().getName());
		
		BL_APPROVER_FIELDS.add(Opportunity.BL_Approver_1__c.getDescribe().getName());
		BL_APPROVER_FIELDS.add(Opportunity.BL_Approver_2__c.getDescribe().getName());
		BL_APPROVER_FIELDS.add(Opportunity.BL_Approver_3__c.getDescribe().getName());
		BL_APPROVER_FIELDS.add(Opportunity.BL_Approver_4__c.getDescribe().getName());
		BL_APPROVER_FIELDS.add(Opportunity.BL_Approver_5__c.getDescribe().getName());
		
		ALL_APPROVER_FIELDS.add(Opportunity.Sales_Director_Approver__c.getDescribe().getName());
		ALL_APPROVER_FIELDS.add(Opportunity.Regional_VP_Approver__c.getDescribe().getName());
		ALL_APPROVER_FIELDS.add(Opportunity.VP_Approver_2__c.getDescribe().getName());
		ALL_APPROVER_FIELDS.addAll(MAG_APPROVER_FIELDS);
		ALL_APPROVER_FIELDS.addAll(BL_APPROVER_FIELDS);
	}
	
	@TestVisible
	enum ApproverLabel {SALES_DIRECTOR_APPROVER,
						REGIONAL_VP_APPROVER, VP_APPROVER_2, 
						MAG_APPROVER_1, MAG_APPROVER_2, MAG_APPROVER_3, MAG_APPROVER_4, MAG_APPROVER_5, MAG_APPROVER_6, MAG_APPROVER_7, MAG_APPROVER_8, MAG_APPROVER_9, MAG_APPROVER_10,
						BL_APPROVER_1, BL_APPROVER_2, BL_APPROVER_3, BL_APPROVER_4, BL_APPROVER_5} 
	
	class OpportunityApprovalException extends Exception {}
	
	interface Approver {
		ID getOpptySalesDirectorApproverID();
		ID setOpptySalesDirectorApproverID();
		ID getOpptyVpApprover1ID();
		ID setOpptyVpApprover1ID();
		ID getOpptyVpApprover2ID();
		ID setOpptyVpApprover2ID(); 
		Map<String, ID> setOpptyVpApproverIDs();
		Map<String, ID> getOpptyMagApproverIDs();
		Map<String, ID> setOpptyMagApproverIDs();
		Map<String, ID> getOpptyBlApproverIDs();
		Map<String, ID> setOpptyBlApproverIDs();
		Map<String, String> getOpptyAllApprovers(); 
		void setOpptyAllApprovers();
	}
	
	abstract class AbstractApprover implements Approver {
		protected ID opptyID;
		protected Opportunity oppty; 
		
		AbstractApprover(ID opptyID) {
			this.opptyID = opptyID;
			this.oppty = [select LT_Value_USD__c, Account.CMD_Industry_Segment__c, Account.Region__c, Owner.MT_1__c, Owner.MT_2__c from Opportunity where Id = :opptyID];	
		}
		
		abstract ID getOpptySalesDirectorApproverID();
		abstract ID getOpptyVpApprover1ID();
				
		protected abstract List<Approvers_Matrix__c> getMagApprovers(Set<String> mags);
		protected abstract List<Approvers_Matrix__c> getBlApprovers(Set<String> bls);
				
		public virtual ID getOpptyVpApprover2ID() {
			return null;
		}
		
		public Map<String, ID> getOpptyMagApproverIDs() {
			Map<String, ID> result = new Map<String, ID>();
			
			Map<String, Double> magLtValues = new Map<String, Double>();
			
			List<AggregateResult> opptyProdMagLtValues = 
				[select PricebookEntry.Product2.MAG__c mag, sum(LT_Value_USD__c) totalMagLtValue
               	   from OpportunityLineItem 
              	  where OpportunityId = :this.opptyID 
              	    and Prod_Lost_Cancelled__c = null
             	 group by PricebookEntry.Product2.MAG__c]; 
             	 
			for (AggregateResult ar : opptyProdMagLtValues) {
				magLtValues.put((String)ar.get('mag'), (Double)ar.get('totalMagLtValue'));		
			} 
			
			List<Approvers_Matrix__c> amMagApprovers = getMagApprovers(magLtValues.keySet());
			Map<String, ID> magApproverIDs = new Map<String, ID>();
			Map<String, Double> magThresholds = new Map<String, Double>();
			
			for (Approvers_Matrix__c am : amMagApprovers) {
				magApproverIDs.put(am.Criteria_1__c, am.Approver__c);
				magThresholds.put(am.Criteria_1__c, am.Threshold_1__c);	
			}           	 

			for (String mag : magLtValues.keySet()) {
				if (magApproverIDs.containsKey(mag)) {
					if (magLtValues.get(mag) > magThresholds.get(mag)) {
						result.put(mag, magApproverIDs.get(mag));	
					}	
				} else {
					result.put(mag, CommonUtils.getDataAdminUserID());
				}
			}
						
			return result;
		}
		
		public Map<String, ID> getOpptyBlApproverIDs() {
			Map<String, ID> result = new Map<String, ID>();
			
			Map<String, Double> blLtValues = new Map<String, Double>();
			
			List<AggregateResult> opptyProdBlLtValues = 
				[select PricebookEntry.Product2.BL__c bl, sum(LT_Value_USD__c) totalBlLtValue
               	   from OpportunityLineItem 
              	  where OpportunityId = :this.opptyID 
              	    and Prod_Lost_Cancelled__c = null
             	 group by PricebookEntry.Product2.BL__c];
             	 
			for (AggregateResult ar : opptyProdBlLtValues) {
				blLtValues.put((String)ar.get('bl'), (Double)ar.get('totalBlLtValue'));		
			} 
			
			List<Approvers_Matrix__c> amBlApprovers = getBlApprovers(blLtValues.keySet());
			Map<String, ID> blApproverIDs = new Map<String, ID>();
			Map<String, Double> blThresholds = new Map<String, Double>();
			
			for (Approvers_Matrix__c am : amBlApprovers) {
				blApproverIDs.put(am.Criteria_1__c, am.Approver__c);
				blThresholds.put(am.Criteria_1__c, am.Threshold_1__c);	
			}           	 

			for (String bl : blLtValues.keySet()) {
				if (blApproverIDs.containsKey(bl)) {
					if (blLtValues.get(bl) > blThresholds.get(bl)) {
						result.put(bl, blApproverIDs.get(bl));	
					}	
				} else {
					result.put(bl, CommonUtils.getDataAdminUserID());
				}
			}           	 
			
			return result;
		}
				
		public ID setOpptySalesDirectorApproverID() {
			this.oppty.Sales_Director_Approver__c = getOpptySalesDirectorApproverID();
			
			if (this.oppty.Sales_Director_Approver__c != null) {
				createOpptyShares(new List<ID>{this.oppty.Sales_Director_Approver__c});
				updateOppty();
			}
			
			return this.oppty.Sales_Director_Approver__c; 
		}
		
		public ID setOpptyVpApprover1ID() {
			this.oppty.Regional_VP_Approver__c = getOpptyVpApprover1ID();
			
			if (this.oppty.Regional_VP_Approver__c != null) {
				createOpptyShares(new List<ID>{this.oppty.Regional_VP_Approver__c});
				updateOppty();
			}	
			
			return this.oppty.Regional_VP_Approver__c; 
		}
		
		public ID setOpptyVpApprover2ID() {
			this.oppty.VP_Approver_2__c = getOpptyVpApprover2ID();
			
			if (this.oppty.VP_Approver_2__c != null) {
				createOpptyShares(new List<ID>{this.oppty.VP_Approver_2__c});
				updateOppty();
			}
			
			return this.oppty.VP_Approver_2__c; 	
		}
		
		public Map<String, ID> setOpptyVpApproverIDs() {
			Map<String, ID> result = new Map<String, ID>();
			
			ID vpApprover1ID = getOpptyVpApprover1ID();
			ID vpApprover2ID = getOpptyVpApprover2ID();
			vpApprover2ID = (vpApprover1ID != vpApprover2ID) ? vpApprover2ID : null; // De-duplication   
			
			this.oppty.Regional_VP_Approver__c = vpApprover1ID;
			this.oppty.VP_Approver_2__c = vpApprover2ID; 
			
			if (vpApprover1ID != null) {
				result.put(Opportunity.Regional_VP_Approver__c.getDescribe().getName(), vpApprover1ID);	
			}
			
			if (vpApprover2ID != null) {
				result.put(Opportunity.VP_Approver_2__c.getDescribe().getName(), vpApprover2ID);	
			}
			
			if (result.size() > 0) {
				createOpptyShares(result.values());
				updateOppty();
			}
			
			return result;	
		}
		
		public Map<String, ID> setOpptyMagApproverIDs() {
			Map<String, ID> result = new Map<String, ID>();
			
			Map<String, ID> magApproverIDs = getOpptyMagApproverIDs();
			List<ID> approverIDs = new List<ID>(new Set<ID>(magApproverIDs.values())); // De-duplication
			
			if (approverIDs.size() > MAG_APPROVER_FIELDS.size()) {
				throw new OpportunityApprovalException('The approval process allows a maximum of ' + MAG_APPROVER_FIELDS.size() + ' MAG Approvers on the Opportunity. Please contact Global Sales Application Support.');
			}
			
			for (Integer i = 0; i < approverIDs.size(); i++) {
				String fieldName = MAG_APPROVER_FIELDS.get(i);
				ID approverID = approverIDs.get(i);  
				
				this.oppty.put(fieldName, approverID);
				result.put(fieldName, approverID);	
			}
			
			if (result.size() > 0) {
				createOpptyShares(approverIDs);
				updateOppty();
			}
				
			return result;
		}
		
		public Map<String, ID> setOpptyBlApproverIDs() {
			Map<String, ID> result = new Map<String, ID>();
			
			Map<String, ID> blApproverIDs = getOpptyBlApproverIDs();
			List<ID> approverIDs = new List<ID>(new Set<ID>(blApproverIDs.values())); // De-duplication  
			
			if (approverIDs.size() > BL_APPROVER_FIELDS.size()) {
				throw new OpportunityApprovalException('The approval process allows a maximum of ' + BL_APPROVER_FIELDS.size() + ' BL Approvers on the Opportunity. Please contact Global Sales Application Support.');
			}
			
			for (Integer i = 0; i < approverIDs.size(); i++) {
				String fieldName = BL_APPROVER_FIELDS.get(i);
				ID approverID = approverIDs.get(i);  
				
				this.oppty.put(fieldName, approverID);
				result.put(fieldName, approverID);	
			}
			
			if (result.size() > 0) {
				createOpptyShares(approverIDs);
				updateOppty();
			}
			
			return result;
		}
		
		public Map<String, String> getOpptyAllApprovers() {
			Map<String, String> result = new Map<String, String>();
			
			Map<ApproverLabel, ID> approverIDs = getOpptyAllApproverIDs();
			Map<ID, User> userNames = getUserNames(approverIDs.values());
			
			for (ApproverLabel al : approverIDs.keySet()) {
				result.put(APPROVER_LABELS.get(al), (userNames.get(approverIDs.get(al)) != null) ? userNames.get(approverIDs.get(al)).Name : null);
			}
			
			return result;	
		}
		
		public void setOpptyAllApprovers() {
			resetOpptyAllApprovers();
			
			List<ID> approverIDs = getOpptyAllApproverIDs().values();
			
			isUpdatable = true;
			
			if (approverIDs.size() > 0) {
				createOpptyShares(approverIDs);	
			}
			
			updateOppty();
		}
		
		protected Double getOpptyLtValueUSD() {
			return this.oppty.LT_Value_USD__c; 
		}
		
		protected ID getOpptyOwnerMT1() {
			return this.oppty.Owner.MT_1__c; 
		}
		
		protected ID getOpptyOwnerMT2() {
			return this.oppty.Owner.MT_2__c; 
		}
		
		private void resetOpptyAllApprovers() {
			for (String fieldName : ALL_APPROVER_FIELDS) {
				this.oppty.put(fieldName, null);	
			}		
		}
		
		private Map<ApproverLabel, ID> getOpptyAllApproverIDs() {
			isUpdatable = false;
			
			Map<ApproverLabel, ID> result = new Map<ApproverLabel, ID>();
			
			result.put(ApproverLabel.SALES_DIRECTOR_APPROVER, setOpptySalesDirectorApproverID());
			
			Map<String, ID> approverIDs = new Map<String, ID>();
			approverIDs.putAll(setOpptyVpApproverIDs());
			approverIDs.putAll(setOpptyMagApproverIDs());
			approverIDs.putAll(setOpptyBlApproverIDs());
			
			for (String fieldName : approverIDs.keySet()) {
				for (ApproverLabel al : ApproverLabel.values()) {
					if (fieldName.containsIgnoreCase(al.name())) {
						result.put(al, approverIDs.get(fieldName));
						break;
					}
				}	
			}
			
			return result;
		}
		
		private Map<ID, User> getUserNames(List<ID> userIDs) {
			return new Map<ID, User>([select Name from User where Id in :userIDs]);
		}
		
		private void updateOppty() {
			if (!isUpdatable) return;
			
			update this.oppty;	
		}
		
		private void createOpptyShares(List<ID> userIDs) {
			if (!isUpdatable) return;
			
			List<OpportunityShare> opptyShares = new List<OpportunityShare>();
			
			for (ID uid : userIDs) {
				if (uid != null) {
					opptyShares.add(new OpportunityShare(OpportunityId = this.opptyID, OpportunityAccessLevel = 'Read', UserOrGroupId = uid));	
				}
			} 
			
			if (opptyShares.size() > 0) {
				insert opptyShares;	
			}
		}
	}
	
	abstract class MajorAccountApprover extends AbstractApprover {
		MajorAccountApprover(ID opptyID) {
			super(opptyID);
		}
		
		protected ID getApproverID(Approvers_Matrix__c approverMatrix) {
			return (getOpptyLtValueUSD() > approverMatrix.Threshold_1__c) ? approverMatrix.Approver__c : null;	
		}	
	}
	
	class StarApprover extends MajorAccountApprover {
		StarApprover(ID opptyID) {
			super(opptyID);
		}
		
		public override ID getOpptySalesDirectorApproverID() {
			return getApproverID(ApproverMatrixHelper.getDirectOpptyGamSTAR());
		}
		
		public override ID getOpptyVpApprover1ID() {
			return getApproverID(ApproverMatrixHelper.getDirectOpptyEvpSTAR());
		}
		
		protected override List<Approvers_Matrix__c> getMagApprovers(Set<String> mags) {
			return ApproverMatrixHelper.getDirectOpptyMagApproversSTAR(mags);
		}
		
		protected override List<Approvers_Matrix__c> getBlApprovers(Set<String> bls) {
			return ApproverMatrixHelper.getDirectOpptyBlApproversSTAR(bls);
		}
	}
	
	class SamsungApprover extends MajorAccountApprover {
		SamsungApprover(ID opptyID) {
			super(opptyID);
		}
		
		public override ID getOpptySalesDirectorApproverID() {
			return getApproverID(ApproverMatrixHelper.getDirectOpptyGamSamsung());
		}
		
		public override ID getOpptyVpApprover1ID() {
			return getApproverID(ApproverMatrixHelper.getDirectOpptyEvpSamsung());
		}
		
		protected override List<Approvers_Matrix__c> getMagApprovers(Set<String> mags) {
			return ApproverMatrixHelper.getDirectOpptyMagApprovers(mags);
		}
		
		protected override List<Approvers_Matrix__c> getBlApprovers(Set<String> bls) {
			return ApproverMatrixHelper.getDirectOpptyBlApprovers(bls);
		}
	}
	
	class GeneralApprover extends AbstractApprover {
		GeneralApprover(ID opptyID) {
			super(opptyID);
		}
		
		public override ID getOpptySalesDirectorApproverID() {
			return (getOpptyLtValueUSD() > ApproverMatrixHelper.getDirectOpptyGsmSalesDirector().Threshold_1__c) ? getOpptyOwnerMT2() : null;
		}
		
		public override ID getOpptyVpApprover1ID() {
			ID result;
			
			Approvers_Matrix__c amSegmentVpAuto = ApproverMatrixHelper.getDirectOpptySegmentVpAuto();
			Approvers_Matrix__c amGsmVp1 = ApproverMatrixHelper.getDirectOpptyGsmVp1();
			
			if (getOpptyOwnerMT2() == null) {
				if (oppty.Account.CMD_Industry_Segment__c == amSegmentVpAuto.Criteria_1__c) {
					result = amSegmentVpAuto.Approver__c;	
				} else {
					result = getOpptyOwnerMT1(); 
				}
			} else {
				if (oppty.Account.CMD_Industry_Segment__c == amSegmentVpAuto.Criteria_1__c) {
					if (getOpptyLtValueUSD() > amSegmentVpAuto.Threshold_1__c) {
						result = amSegmentVpAuto.Approver__c;	
					}
				} else {
					if (getOpptyLtValueUSD() > amGsmVp1.Threshold_1__c) {
						result = getOpptyOwnerMT1();	
					}
				}
			}
			
			return result;
		}
		
		public override ID getOpptyVpApprover2ID() {
			ID result;
			
			Approvers_Matrix__c amGsmVp2AutoGC = ApproverMatrixHelper.getDirectOpptyGsmVp2AutoGC();
			Approvers_Matrix__c amGsmVp2AutoSAP = ApproverMatrixHelper.getDirectOpptyGsmVp2AutoSAP();
			
			if (getOpptyOwnerMT2() == null) {
				if ((oppty.Account.CMD_Industry_Segment__c == amGsmVp2AutoGC.Criteria_1__c && oppty.Account.Region__c == amGsmVp2AutoGC.Criteria_2__c) ||
					(oppty.Account.CMD_Industry_Segment__c == amGsmVp2AutoSAP.Criteria_1__c && oppty.Account.Region__c == amGsmVp2AutoSAP.Criteria_2__c)) {
					result = getOpptyOwnerMT1();	
				}
			} else {
				if ((oppty.Account.CMD_Industry_Segment__c == amGsmVp2AutoGC.Criteria_1__c && oppty.Account.Region__c == amGsmVp2AutoGC.Criteria_2__c && getOpptyLtValueUSD() > amGsmVp2AutoGC.Threshold_1__c) ||
					(oppty.Account.CMD_Industry_Segment__c == amGsmVp2AutoSAP.Criteria_1__c && oppty.Account.Region__c == amGsmVp2AutoSAP.Criteria_2__c && getOpptyLtValueUSD() > amGsmVp2AutoSAP.Threshold_1__c)) {
					result = getOpptyOwnerMT1();	
				}	
			}
			
			return result;
		}
		
		protected override List<Approvers_Matrix__c> getMagApprovers(Set<String> mags) {
			return ApproverMatrixHelper.getDirectOpptyMagApprovers(mags);	
		}
		
		protected override List<Approvers_Matrix__c> getBlApprovers(Set<String> bls) {
			return ApproverMatrixHelper.getDirectOpptyBlApprovers(bls);
		}
	} 
	
	public static Map<String, String> getAllApprovers(ID opptyID) {
		return getApprover(opptyID).getOpptyAllApprovers();	
	}
	
	public static void setAllApprovers(ID opptyID) {
		getApprover(opptyID).setOpptyAllApprovers();
	}
	
	@TestVisible
	private static ID getSalesDirectorApproverID(ID opptyID) {
		return getApprover(opptyID).getOpptySalesDirectorApproverID();
	} 
	
	@TestVisible
	private static void setSalesDirectorApproverID(ID opptyID) {
		getApprover(opptyID).setOpptySalesDirectorApproverID();	
	}
	
	@TestVisible
	private static ID getVpApprover1ID(ID opptyID) {
		return getApprover(opptyID).getOpptyVpApprover1ID();
	}
	
	@TestVisible
	private static void setVpApprover1ID(ID opptyID) {
		getApprover(opptyID).setOpptyVpApprover1ID();	
	}
	
	@TestVisible
	private static ID getVpApprover2ID(ID opptyID) {
		return getApprover(opptyID).getOpptyVpApprover2ID();
	}
	
	@TestVisible
	private static void setVpApprover2ID(ID opptyID) {
		getApprover(opptyID).setOpptyVpApprover2ID();	
	}
	
	@TestVisible
	private static void setVpApproverIDs(ID opptyID) {
		getApprover(opptyID).setOpptyVpApproverIDs();	
	}
	
	@TestVisible
	private static Map<String, ID> getMagApproverIDs(ID opptyID) {
		return getApprover(opptyID).getOpptyMagApproverIDs();
	}
	
	@TestVisible
	private static void setMagApproverIDs(ID opptyID) {
		getApprover(opptyID).setOpptyMagApproverIDs();
	}
	
	@TestVisible
	private static Map<String, ID> getBlApproverIDs(ID opptyID) {
		return getApprover(opptyID).getOpptyBlApproverIDs();
	}
	
	@TestVisible
	private static void setBlApproverIDs(ID opptyID) {
		getApprover(opptyID).setOpptyBlApproverIDs();
	}
	
	private static Approver getApprover(ID opptyID) {
		if (approver == null) {
			setApprover(opptyID);	
		}
		
		return approver;		
	}
	
	private static void setApprover(ID opptyID) {
		String parentAccountName = getParentAccountName(opptyID);
		
		if (parentAccountName == AccountHelper.PARENT_ACCOUNT_STAR) {
			approver = new StarApprover(opptyID);
		} else if (parentAccountName == AccountHelper.PARENT_ACCOUNT_SAMSUNG) {
			approver = new SamsungApprover(opptyID);
		} else {
			approver = new GeneralApprover(opptyID);	
		}	
	}
	
	private static String getParentAccountName(ID opptyID) {
		Opportunity oppty = [select Account.Parent.Name from Opportunity where Id = :opptyID];
		
		return oppty.Account.Parent.Name;
	}   
}