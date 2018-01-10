public class OpportunityApproval {
	
	@TestVisible
	private static final Map<ApproverLabel, String> APPROVER_LABELS = new Map<ApproverLabel, String>();
	
	private static final List<String> MAG_APPROVER_FIELDS = new List<String>();
	private static final List<String> BL_APPROVER_FIELDS = new List<String>();
	private static final List<String> ALL_APPROVER_FIELDS = new List<String>();
	// Account constants
	private static final String PARENT_ACCOUNT_STAR = 'STAR';
	private static final String PARENT_ACCOUNT_SAMSUNG = 'Samsung';
	
	private static Boolean isUpdatable = true;
	private static Map<Id, User> users;
	private static Map<Id, List<OpportunityLineItemsSelector.OpportunityProductValueSummary>> opptyProdValMagSummariesByOpptyId;
	private static Map<Id, List<OpportunityLineItemsSelector.OpportunityProductValueSummary>> opptyProdValBlSummariesByOpptyId;
	
	static {
		APPROVER_LABELS.put(ApproverLabel.SALES_DIRECTOR_APPROVER, Opportunity.Sales_Director_Approver__c.getDescribe().getLabel());	
		APPROVER_LABELS.put(ApproverLabel.REGIONAL_VP_APPROVER, Opportunity.Regional_VP_Approver__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.VP_APPROVER_2, Opportunity.VP_Approver_2__c.getDescribe().getLabel());
		APPROVER_LABELS.put(ApproverLabel.GLOBAL_KEY_ACCOUNT_MANAGER, Opportunity.Global_Key_Account_Manager__c.getDescribe().getLabel()); 
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
		ALL_APPROVER_FIELDS.add(Opportunity.Global_Key_Account_Manager__c.getDescribe().getName());
		ALL_APPROVER_FIELDS.addAll(MAG_APPROVER_FIELDS);
		ALL_APPROVER_FIELDS.addAll(BL_APPROVER_FIELDS);
	}
	
	@TestVisible
	enum ApproverLabel {SALES_DIRECTOR_APPROVER,
						REGIONAL_VP_APPROVER, VP_APPROVER_2, 
						MAG_APPROVER_1, MAG_APPROVER_2, MAG_APPROVER_3, MAG_APPROVER_4, MAG_APPROVER_5, MAG_APPROVER_6, MAG_APPROVER_7, MAG_APPROVER_8, MAG_APPROVER_9, MAG_APPROVER_10,
						BL_APPROVER_1, BL_APPROVER_2, BL_APPROVER_3, BL_APPROVER_4, BL_APPROVER_5, GLOBAL_KEY_ACCOUNT_MANAGER} 
	
	class OpportunityApprovalException extends Exception {}
	
	interface Approver {
		Id getOpptySalesDirectorApproverId();
		void setOpptySalesDirectorApproverId(fflib_ISObjectUnitOfWork uow);
		
		Id getOpptyVpApprover1Id();
		void setOpptyVpApprover1Id(fflib_ISObjectUnitOfWork uow);
		
		Id getOpptyVpApprover2Id();
		void setOpptyVpApprover2Id(fflib_ISObjectUnitOfWork uow);

		Id getOpptyGlobalKeyAccountManagerId();
       	Id getOpptyGlobalKeyAccountManagerIdDedup();
		void setOpptyGlobalKeyAccountManagerId(fflib_ISObjectUnitOfWork uow);
		
		Map<String, Id> getOpptyVpApproverIds();
		void setOpptyVpApproverIds(fflib_ISObjectUnitOfWork uow);
		
		Map<String, Id> getOpptyMagApproverIdsWithMag();
		Map<String, Id> getOpptyMagApproverIds();
		void setOpptyMagApproverIds(fflib_ISObjectUnitOfWork uow);
		
		Map<String, Id> getOpptyBlApproverIdsWithBl();
		Map<String, Id> getOpptyBlApproverIds();
		void setOpptyBlApproverIds(fflib_ISObjectUnitOfWork uow);
		
		Map<String, String> getOpptyAllApprovers(); 
		void setOpptyAllApprovers(fflib_ISObjectUnitOfWork uow);
	}
	
	abstract class AbstractApprover implements Approver {
		protected Opportunity oppty; 
		
		AbstractApprover(Opportunity oppty) {
			this.oppty = oppty;
		}
		
		abstract Id getOpptySalesDirectorApproverId();
		abstract Id getOpptyVpApprover1Id();
				
		protected abstract List<Approvers_Matrix__c> getMagApprovers(Set<String> mags);
		protected abstract List<Approvers_Matrix__c> getBlApprovers(Set<String> bls);
				
		public virtual Id getOpptyVpApprover2Id() {
			return null;
		}
		
		public virtual Id getOpptyGlobalKeyAccountManagerId() {
			return null;
		}
        
        public virtual Id getOpptyGlobalKeyAccountManagerIdDedup() {
			return null;
		}
		
		public void setOpptySalesDirectorApproverId(fflib_ISObjectUnitOfWork uow) {
			p('setOpptySalesDirectorApproverId');
			this.oppty.Sales_Director_Approver__c = getOpptySalesDirectorApproverId();
			
			if (this.oppty.Sales_Director_Approver__c != null) {
				createOpptyShares(new List<Id>{this.oppty.Sales_Director_Approver__c}, uow);
				updateOppty(uow);
			}
		}
		
		public void setOpptyVpApprover1Id(fflib_ISObjectUnitOfWork uow) {
			p('setOpptyVpApprover1Id');
			this.oppty.Regional_VP_Approver__c = getOpptyVpApprover1Id();
			
			if (this.oppty.Regional_VP_Approver__c != null) {
				createOpptyShares(new List<Id>{this.oppty.Regional_VP_Approver__c}, uow);
				updateOppty(uow);
			}	
		}
		
		public void setOpptyVpApprover2Id(fflib_ISObjectUnitOfWork uow) {
			p('setOpptyVpApprover2Id');
			this.oppty.VP_Approver_2__c = getOpptyVpApprover2Id();
			
			if (this.oppty.VP_Approver_2__c != null) {
				createOpptyShares(new List<Id>{this.oppty.VP_Approver_2__c}, uow);
				updateOppty(uow);
			}
		}
		
		public Map<String, Id> getOpptyVpApproverIds() {
			p('getOpptyVpApproverIds');
			Map<String, Id> result = new Map<String, Id>();
			
			Id vpApprover1Id = getOpptyVpApprover1Id();
			Id vpApprover2Id = getOpptyVpApprover2Id();
			vpApprover2Id = (vpApprover1Id != vpApprover2Id) ? vpApprover2Id : null; // De-duplication	
			
			if (vpApprover1Id != null) {
				result.put(Opportunity.Regional_VP_Approver__c.getDescribe().getName(), vpApprover1Id);	
			}
			
			if (vpApprover2Id != null) {
				result.put(Opportunity.VP_Approver_2__c.getDescribe().getName(), vpApprover2Id);	
			}
			
			return result;
		}
		
		public void setOpptyVpApproverIds(fflib_ISObjectUnitOfWork uow) {
			p('setOpptyVpApproverIds');
			Map<String, Id> vpApproverIds = getOpptyVpApproverIds();
			
			this.oppty.Regional_VP_Approver__c = vpApproverIds.get(Opportunity.Regional_VP_Approver__c.getDescribe().getName());
			this.oppty.VP_Approver_2__c = vpApproverIds.get(Opportunity.VP_Approver_2__c.getDescribe().getName());
			 
			if (vpApproverIds.size() > 0) {
				createOpptyShares(vpApproverIds.values(), uow);
				updateOppty(uow);
			}
		}
		
		public void setOpptyGlobalKeyAccountManagerId(fflib_ISObjectUnitOfWork uow) {
			p('setOpptyGlobalKeyAccountManagerId');
			this.oppty.Global_Key_Account_Manager__c = getOpptyGlobalKeyAccountManagerIdDedup();
			
			if (this.oppty.Global_Key_Account_Manager__c != null) {
				createOpptyShares(new List<Id>{this.oppty.Global_Key_Account_Manager__c}, uow);
				updateOppty(uow);
			}
		}
		
		public Map<String, Id> getOpptyMagApproverIdsWithMag() {
			p('getOpptyMagApproverIdsWithMag');
			Map<String, Id> result = new Map<String, Id>();
			
			Map<String, Double> magLtValues = new Map<String, Double>();
			
			for (OpportunityLineItemsSelector.OpportunityProductValueSummary opvs : opptyProdValMagSummariesByOpptyId.get(this.oppty.Id)) {
				magLtValues.put(opvs.mag, opvs.totalMagLtValue);	
			}
			
			List<Approvers_Matrix__c> amMagApprovers = getMagApprovers(magLtValues.keySet());
			Map<String, Id> magApproverIds = new Map<String, Id>();
			Map<String, Double> magThresholds = new Map<String, Double>();
			
			for (Approvers_Matrix__c am : amMagApprovers) {
				magApproverIds.put(am.Criteria_1__c, am.Approver__c);
				magThresholds.put(am.Criteria_1__c, am.Threshold_1__c);	
			}           	 

			for (String mag : magLtValues.keySet()) {
				if (magApproverIds.containsKey(mag)) {
					if (magLtValues.get(mag) > magThresholds.get(mag)) {
						result.put(mag, magApproverIds.get(mag));	
					}	
				} else {
					result.put(mag, CommonUtils.getDataAdminUserId());
				}
			}
						
			return result;
		}
		
		public Map<String, Id> getOpptyMagApproverIds() {
			p('getOpptyMagApproverIds');
			Map<String, Id> result = new Map<String, Id>();
			
			Map<String, Id> magApproverIds = getOpptyMagApproverIdsWithMag();
			List<Id> approverIds = new List<Id>(new Set<Id>(magApproverIds.values())); // De-duplication
			
			if (approverIds.size() > MAG_APPROVER_FIELDS.size()) {
				throw new OpportunityApprovalException('The approval process allows a maximum of ' + MAG_APPROVER_FIELDS.size() + ' MAG Approvers on the Opportunity. Please contact Global Sales Application Support.');
			}
			
			for (Integer i = 0; i < approverIds.size(); i++) {
				String fieldName = MAG_APPROVER_FIELDS.get(i);
				Id approverId = approverIds.get(i);  
				
				this.oppty.put(fieldName, approverId);
				result.put(fieldName, approverId);	
			}
			
			return result;	
		}
		
		public void setOpptyMagApproverIds(fflib_ISObjectUnitOfWork uow) {
			p('setOpptyMagApproverIds');
			Map<String, Id> magApproverIds = getOpptyMagApproverIds();
			
			if (magApproverIds.size() > 0) {
				createOpptyShares(magApproverIds.values(), uow);
				updateOppty(uow);
			}
		}
		
		public Map<String, Id> getOpptyBlApproverIdsWithBl() {
			p('getOpptyBlApproverIdsWithBl');
			Map<String, Id> result = new Map<String, Id>();
			
			Map<String, Double> blLtValues = new Map<String, Double>();
			
			for (OpportunityLineItemsSelector.OpportunityProductValueSummary opvs : opptyProdValBlSummariesByOpptyId.get(this.oppty.Id)) {
				blLtValues.put(opvs.bl, opvs.totalBlLtValue);	
			}
			
			List<Approvers_Matrix__c> amBlApprovers = getBlApprovers(blLtValues.keySet());
			Map<String, Id> blApproverIds = new Map<String, Id>();
			Map<String, Double> blThresholds = new Map<String, Double>();
			
			for (Approvers_Matrix__c am : amBlApprovers) {
				blApproverIds.put(am.Criteria_1__c, am.Approver__c);
				blThresholds.put(am.Criteria_1__c, am.Threshold_1__c);	
			}           	 

			for (String bl : blLtValues.keySet()) {
				if (blApproverIds.containsKey(bl)) {
					if (blLtValues.get(bl) > blThresholds.get(bl)) {
						result.put(bl, blApproverIds.get(bl));	
					}	
				} else {
					result.put(bl, CommonUtils.getDataAdminUserId());
				}
			}           	 
			
			return result;
		}
		
		public Map<String, Id> getOpptyBlApproverIds() {
			p('getOpptyBlApproverIds');
			Map<String, Id> result = new Map<String, Id>();
			
			Map<String, Id> blApproverIds = getOpptyBlApproverIdsWithBl();
			List<Id> approverIds = new List<Id>(new Set<Id>(blApproverIds.values())); // De-duplication  
			
			if (approverIds.size() > BL_APPROVER_FIELDS.size()) {
				throw new OpportunityApprovalException('The approval process allows a maximum of ' + BL_APPROVER_FIELDS.size() + ' BL Approvers on the Opportunity. Please contact Global Sales Application Support.');
			}
			
			for (Integer i = 0; i < approverIds.size(); i++) {
				String fieldName = BL_APPROVER_FIELDS.get(i);
				Id approverId = approverIds.get(i);  
				
				this.oppty.put(fieldName, approverId);
				result.put(fieldName, approverId);	
			}
			
			return result;	
		}
		
		public void setOpptyBlApproverIds(fflib_ISObjectUnitOfWork uow) {
			p('setOpptyBlApproverIds');
			Map<String, Id> blApproverIds = getOpptyBlApproverIds();
			
			if (blApproverIds.size() > 0) {
				createOpptyShares(blApproverIds.values(), uow);
				updateOppty(uow);
			}
		}
		
		public Map<String, String> getOpptyAllApprovers() {
			p('getOpptyAllApprovers');
			Map<String, String> result = new Map<String, String>();
			
			Map<ApproverLabel, Id> approverIdsByLabel = getOpptyAllApproverIds();
			
			Map<Id, User> approvers = new Map<Id, User>();
			
			for (Id approverId : approverIdsByLabel.values()) {
				if (users.containsKey(approverId)) {
					approvers.put(approverId, users.get(approverId));
				}
			}
			
			for (ApproverLabel al : approverIdsByLabel.keySet()) {
				result.put(APPROVER_LABELS.get(al), (approvers.get(approverIdsByLabel.get(al)) != null) ? approvers.get(approverIdsByLabel.get(al)).Name : null);
				string approverId = (approvers.get(approverIdsByLabel.get(al)) != null) ? approvers.get(approverIdsByLabel.get(al)).Name : null ;
			}
			
			return result;	
		}
		
		public void setOpptyAllApprovers(fflib_ISObjectUnitOfWork uow) {
			p('setOpptyAllApprovers');
			resetOpptyAllApprovers();
			
			isUpdatable = true;
			
			setOpptySalesDirectorApproverId(uow);
			setOpptyVpApproverIds(uow);
			setOpptyGlobalKeyAccountManagerId(uow);
			setOpptyMagApproverIds(uow);
			setOpptyBlApproverIds(uow);
		}
		
		protected Double getOpptyLtValueUSD() {
			p('getOpptyLtValueUSD');
			return this.oppty.LT_Value_USD__c; 
		}
		
		protected Id getOpptyOwnerMT1() {
			p('getOpptyOwnerMT1');
			return this.oppty.Owner.MT_1__c; 
		}
		
		protected Id getOpptyOwnerMT2() {
			p('getOpptyOwnerMT2');
			return this.oppty.Owner.MT_2__c; 
		}
		
		protected void p(String msg) {
			CommonUtils.p(this, '//-c', msg);
		}
		
		private void resetOpptyAllApprovers() {
			p('resetOpptyAllApprovers');
			for (String fieldName : ALL_APPROVER_FIELDS) {
				this.oppty.put(fieldName, null);	
			}		
		}
		
		private Map<ApproverLabel, Id> getOpptyAllApproverIds() {
			p('getOpptyAllApproverIds');
			isUpdatable = false;
			
			Map<ApproverLabel, Id> result = new Map<ApproverLabel, Id>();
			
			result.put(ApproverLabel.SALES_DIRECTOR_APPROVER, getOpptySalesDirectorApproverId());
			
			Map<String, Id> approverIds = new Map<String, Id>();
			
			Map<ApproverLabel, Id> resultDeduped = new Map<ApproverLabel, Id>();
			
			approverIds.putAll(getOpptyVpApproverIds());
			
			//approverIds.putAll(getOpptyMagApproverIds());
			//approverIds.putAll(getOpptyBlApproverIds());
						
			for (String fieldName : approverIds.keySet()) {
				for (ApproverLabel al : ApproverLabel.values()) {
					if (fieldName.containsIgnoreCase(al.name())) {
						result.put(al, approverIds.get(fieldName));
						system.debug('***[Scarlett] Before de duplication' + result);
						break;
					}
				}	
			}
			
			result.put(ApproverLabel.GLOBAL_KEY_ACCOUNT_MANAGER, getOpptyGlobalKeyAccountManagerId());
            
			//de-duplication: Sales Director, VP1, VP2, GKAM
			resultDeduped = deDupApprovers(result);
			
			approverIds.putAll(getOpptyMagApproverIds());
			approverIds.putAll(getOpptyBlApproverIds());
			
			for (String fieldName : approverIds.keySet()) {
				for (ApproverLabel al : ApproverLabel.values()) {
					if (fieldName.containsIgnoreCase(al.name())) {
						resultDeduped.put(al, approverIds.get(fieldName));
						break;
					}
				}	
			}
					
			return resultDeduped;
		}
        
        private Map<ApproverLabel, Id> deDupApprovers(Map<ApproverLabel, Id> apporverIdsByLabel) {
            Map<Id, ApproverLabel> tempMap = new Map<Id, ApproverLabel>();
            Map<ApproverLabel, Id> result = new Map<ApproverLabel, Id>();

            for (ApproverLabel key : apporverIdsByLabel.keySet()) {
                Id approverId = apporverIdsByLabel.get(key);
                
                if (tempMap.containsKey(approverId) == false) {
                    tempMap.put(approverId, key);
                    result.put(key, approverId);
                }
            }
            
            return result;
        } 
	
		
		private void updateOppty(fflib_ISObjectUnitOfWork uow) {
			p('updateOppty');
			if (!isUpdatable) return;
			
			uow.registerDirty(this.oppty);	
		}
		
		private void createOpptyShares(List<Id> userIds, fflib_ISObjectUnitOfWork uow) {
			p('createOpptyShares');
			if (!isUpdatable) return;
			
			List<OpportunityShare> opptyShares = new List<OpportunityShare>();
			
			for (Id uid : userIds) {
				if (uid != null) {
					opptyShares.add(new OpportunityShare(OpportunityId = this.oppty.Id, OpportunityAccessLevel = 'Read', UserOrGroupId = uid));	
				}
			} 
			
			if (opptyShares.size() > 0) {
				uow.registerNew(opptyShares);	
			}
		}
	}
	
	abstract class MajorAccountApprover extends AbstractApprover {
		MajorAccountApprover(Opportunity oppty) {
			super(oppty);
		}
		
		protected Id getApproverId(Approvers_Matrix__c approverMatrix) {
			p('getApproverId');
			return (getOpptyLtValueUSD() > approverMatrix.Threshold_1__c) ? approverMatrix.Approver__c : null;	
		}	
	}
	
	class StarApprover extends MajorAccountApprover {
		StarApprover(Opportunity oppty) {
			super(oppty);
		}
		
		public override Id getOpptySalesDirectorApproverId() {
			p('getOpptySalesDirectorApproverId');
			return getApproverId(ApproverMatrixHelper.getDirectOpptyGamSTAR());
		}
		
		public override Id getOpptyVpApprover1Id() {
			p('getOpptyVpApprover1Id');
			return getApproverId(ApproverMatrixHelper.getDirectOpptyEvpSTAR());
		}
		
		protected override List<Approvers_Matrix__c> getMagApprovers(Set<String> mags) {
			p('getMagApprovers');
			return ApproverMatrixHelper.getDirectOpptyMagApproversSTAR(mags);
		}
		
		protected override List<Approvers_Matrix__c> getBlApprovers(Set<String> bls) {
			p('getBlApprovers');
			return ApproverMatrixHelper.getDirectOpptyBlApproversSTAR(bls);
		}
	}
	
	class SamsungApprover extends MajorAccountApprover {
		SamsungApprover(Opportunity oppty) {
			super(oppty);
		}
		
		public override Id getOpptySalesDirectorApproverId() {
			p('getOpptySalesDirectorApproverId');
			return getApproverId(ApproverMatrixHelper.getDirectOpptyGamSamsung());
		}
		
		public override Id getOpptyVpApprover1Id() {
			p('getOpptyVpApprover1Id');
			return getApproverId(ApproverMatrixHelper.getDirectOpptyEvpSamsung());
		}
		
		protected override List<Approvers_Matrix__c> getMagApprovers(Set<String> mags) {
			p('getMagApprovers');
			return ApproverMatrixHelper.getDirectOpptyMagApprovers(mags);
		}
		
		protected override List<Approvers_Matrix__c> getBlApprovers(Set<String> bls) {
			p('getBlApprovers');
			return ApproverMatrixHelper.getDirectOpptyBlApprovers(bls);
		}
	}
	
	class GeneralApprover extends AbstractApprover {
		GeneralApprover(Opportunity oppty) {
			super(oppty);
		}
		
		public override Id getOpptySalesDirectorApproverId() {
			p('getOpptySalesDirectorApproverId');
			return (getOpptyLtValueUSD() > ApproverMatrixHelper.getDirectOpptyGsmSalesDirector().Threshold_1__c) ? getOpptyOwnerMT2() : null;
		}
		
		public override Id getOpptyVpApprover1Id() {
			p('getOpptyVpApprover1Id');
			Id result;
			
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
		
		public override Id getOpptyVpApprover2Id() {
			p('getOpptyVpApprover2Id');
			Id result;
			
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

		public override Id getOpptyGlobalKeyAccountManagerId() {
			p('getOpptyGlobalKeyAccountManagerId');
			Id result;
			
			Approvers_Matrix__c gam = ApproverMatrixHelper.getDirectOpptyGamGeneral(this.oppty.Account.ParentId); 	
			
            if (gam != null && gam.Approver__c != this.oppty.OwnerId) {
            	result = gam.Approver__c;
            } else {
                result = null;
            }
            
			return result;
		}
        
        public override Id getOpptyGlobalKeyAccountManagerIdDedup(){
            p('getOpptyGlobalKeyAccountManagerIdDedup');
            Map<String, Id> vpApproverIds = getOpptyVpApproverIds();
            Id globalKeyAccountMangerId = getOpptyGlobalKeyAccountManagerId();
                
            this.oppty.Sales_Director_Approver__c = getOpptySalesDirectorApproverId();
            this.oppty.Regional_VP_Approver__c = vpApproverIds.get(Opportunity.Regional_VP_Approver__c.getDescribe().getName());
			this.oppty.VP_Approver_2__c = vpApproverIds.get(Opportunity.VP_Approver_2__c.getDescribe().getName());
            
            if(globalKeyAccountMangerId == this.oppty.Sales_Director_Approver__c || globalKeyAccountMangerId == this.oppty.Regional_VP_Approver__c || globalKeyAccountMangerId == this.oppty.VP_Approver_2__c) {
                return null;
            } 
            else {
                return globalKeyAccountMangerId;
            }
        }
		
		protected override List<Approvers_Matrix__c> getMagApprovers(Set<String> mags) {
			p('getMagApprovers');
			return ApproverMatrixHelper.getDirectOpptyMagApprovers(mags);	
		}
		
		protected override List<Approvers_Matrix__c> getBlApprovers(Set<String> bls) {
			p('getBlApprovers');
			return ApproverMatrixHelper.getDirectOpptyBlApprovers(bls);
		}
	} 
	
	public static Map<Id, Map<String, String>> getAllApprovers(List<Opportunity> oppties) {
		p2('getAllApprovers');
		init(oppties);
		
		Map<Id, Map<String, String>> result = new Map<Id, Map<String, String>>();
		
		for (Opportunity oppty : oppties) {
			result.put(oppty.Id, getApprover(oppty).getOpptyAllApprovers());
		}
		
		return result;	
	}
	
	public static void setAllApprovers(List<Opportunity> oppties, fflib_ISObjectUnitOfWork uow) {
		p2('setAllApprovers');
		init(oppties);
		
		for (Opportunity oppty : oppties) {
			getApprover(oppty).setOpptyAllApprovers(uow);	
		}
	}
	
	@TestVisible
	private static Id getSalesDirectorApproverId(Opportunity oppty) {
		init(new List<Opportunity>{oppty});
		
		return getApprover(oppty).getOpptySalesDirectorApproverId();
	} 
	
	@TestVisible
	private static void setSalesDirectorApproverId(Opportunity oppty, fflib_ISObjectUnitOfWork uow) {
		init(new List<Opportunity>{oppty});
		
		getApprover(oppty).setOpptySalesDirectorApproverId(uow);	
	}
	
	@TestVisible
	private static void setGlobalKeyAccountManagerApproverId(Opportunity oppty, fflib_ISObjectUnitOfWork uow) {
		init(new List<Opportunity>{oppty});
		
		getApprover(oppty).setOpptyGlobalKeyAccountManagerId(uow);	
	}
	
	@TestVisible
	private static Id getVpApprover1Id(Opportunity oppty) {
		init(new List<Opportunity>{oppty});
		
		return getApprover(oppty).getOpptyVpApprover1Id();
	}
	
	@TestVisible
	private static void setVpApprover1Id(Opportunity oppty, fflib_ISObjectUnitOfWork uow) {
		init(new List<Opportunity>{oppty});
		
		getApprover(oppty).setOpptyVpApprover1Id(uow);	
	}
	
	@TestVisible
	private static Id getVpApprover2Id(Opportunity oppty) {
		init(new List<Opportunity>{oppty});
		
		return getApprover(oppty).getOpptyVpApprover2Id();
	}
	
	@TestVisible
	private static void setVpApprover2Id(Opportunity oppty, fflib_ISObjectUnitOfWork uow) {
		init(new List<Opportunity>{oppty});
		
		getApprover(oppty).setOpptyVpApprover2Id(uow);	
	}
	
	@TestVisible
	private static void setVpApproverIds(Opportunity oppty, fflib_ISObjectUnitOfWork uow) {
		init(new List<Opportunity>{oppty});
		
		getApprover(oppty).setOpptyVpApproverIds(uow);	
	}
	
	@TestVisible
	private static Map<String, Id> getMagApproverIdsWithMag(Opportunity oppty) {
		init(new List<Opportunity>{oppty});
		
		return getApprover(oppty).getOpptyMagApproverIdsWithMag();
	}
	
	@TestVisible
	private static void setMagApproverIds(Opportunity oppty, fflib_ISObjectUnitOfWork uow) {
		init(new List<Opportunity>{oppty});
		
		getApprover(oppty).setOpptyMagApproverIds(uow);
	}
	
	@TestVisible
	private static Map<String, Id> getBlApproverIdsWithBl(Opportunity oppty) {
		init(new List<Opportunity>{oppty});
		
		return getApprover(oppty).getOpptyBlApproverIdsWithBl();
	}
	
	@TestVisible
	private static void setBlApproverIds(Opportunity oppty, fflib_ISObjectUnitOfWork uow) {
		init(new List<Opportunity>{oppty});
		
		getApprover(oppty).setOpptyBlApproverIds(uow);
	}
	
	private static void init(List<Opportunity> oppties) {
		if (users == null) {
    		setUsers();
    	}
		
		if (opptyProdValMagSummariesByOpptyId == null) {
    		setOpptyProdValMagSummariesByOpptyId(oppties);
    	}
    	
    	if (opptyProdValBlSummariesByOpptyId == null) {
    		setOpptyProdValBlSummariesByOpptyId(oppties);
    	}	
	}
	
	private static void setUsers() {
		p2('setUsers');
		users = new Map<Id, User>((List<User>)new UsersSelector().selectWhere('User_License__c not in (\'Customer Community Login\', \'Chatter Free\')'));	
	}
	
	private static void setOpptyProdValMagSummariesByOpptyId(List<Opportunity> oppties) {
		p2('setOpptyProdValMagSummariesByOpptyId');
    	opptyProdValMagSummariesByOpptyId = new OpportunityLineItemsSelector().selectLifetimeValueByOpptyIdGroupByOpptyIdAndMag(new Map<Id, Opportunity>(oppties).keySet());
	}
    
    private static void setOpptyProdValBlSummariesByOpptyId(List<Opportunity> oppties) {
    	p2('setOpptyProdValBlSummariesByOpptyId');
    	opptyProdValBlSummariesByOpptyId = new OpportunityLineItemsSelector().selectLifetimeValueByOpptyIdGroupByOpptyIdAndBl(new Map<Id, Opportunity>(oppties).keySet());  
    }
	
	private static Approver getApprover(Opportunity oppty) {
		String parentAccountName = oppty.Account.Parent.Name;
		
		if (parentAccountName == PARENT_ACCOUNT_STAR) {
			p2('StarApprover');
			return new StarApprover(oppty);
		} else if (parentAccountName == PARENT_ACCOUNT_SAMSUNG) {
			p2('SamsungApprover');
			return new SamsungApprover(oppty);
		} else {
			p2('GeneralApprover');
			return new GeneralApprover(oppty);	
		}	
	}
	
	private static void p2(String msg) {
		CommonUtils.p(OpportunityApproval.class, '//-c', msg);
	}
	
}