public class Opportunities extends ApplicationDomain {
	
	public enum Stage {INITIAL_ENGAGEMENT, DISCOVERY, DECISION, COMMITMENT, LOST, CANCELLED}
	
	public enum ApprovalStatus {OPEN, APPROVED, LOST}
	
	public static final Map<Stage, String> STAGES = new Map<Stage, String> {
		Stage.INITIAL_ENGAGEMENT => 'Initial Engagement',
		Stage.DISCOVERY => 'Discovery',
		Stage.DECISION => 'Decision',
		Stage.COMMITMENT => 'Commitment',
		Stage.LOST => 'Lost',
		Stage.CANCELLED => 'Cancelled'
	};
	
	public static final String STAGE_INITIAL_ENGAGEMENT = STAGES.get(Stage.INITIAL_ENGAGEMENT);
	public static final String STAGE_DISCOVERY = STAGES.get(Stage.DISCOVERY);
	public static final String STAGE_DECISION = STAGES.get(Stage.DECISION);
	public static final String STAGE_COMMITMENT = STAGES.get(Stage.COMMITMENT);
	public static final String STAGE_LOST = STAGES.get(Stage.LOST);
	public static final String STAGE_CANCELLED = STAGES.get(Stage.CANCELLED);
	
	public static final Set<String> OPEN_STAGES = new Set<String> {
		STAGE_INITIAL_ENGAGEMENT,
		STAGE_DISCOVERY,
		STAGE_DECISION		
	};
	
	public static final Set<String> LOST_STAGES = new Set<String> {
		STAGE_LOST,
		STAGE_CANCELLED		
	}; 
	
	public static final Map<ApprovalStatus, String> APPROVAL_STATUSES = new Map<ApprovalStatus, String> {
		ApprovalStatus.OPEN => 'Open',
		ApprovalStatus.APPROVED => 'Approved',
		ApprovalStatus.LOST => 'Lost'	
	};
	
	public static final String MN_LOST_REASON = 'Expired';
		
	private static Set<Id> beforeUpdateProcessedIds = new Set<Id>();
	private static Set<Id> afterUpdateProcessedIds = new Set<Id>();
	
	public static void resetUpdateEventEntry() {
		beforeUpdateProcessedIds = new Set<Id>();
    	afterUpdateProcessedIds = new Set<Id>();
    }
	
    public Opportunities(List<Opportunity> oppties) {
		super(oppties);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new Opportunities(sObjectList);
		}
	}
	 
	public override void onBeforeInsert() {
		p('onBeforeInsert');
		updateOpptyGeneralInfo(null);
		
		updateOpptyStarInfo();
	}
	
	public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
		p('onBeforeUpdate');
		// Each oppty should be processed only once in before update event.
		if (processed()) return;
		
		// Must be the first method call to skip any field updates by the following method calls.
		bypassValidation((Map<Id, Opportunity>)existingRecords); 
		
		updateOpptyGeneralInfo((List<Opportunity>)existingRecords.values());
		
		updateOpptyStarInfo();
		
		updateTmmaOverride((Map<Id, Opportunity>)existingRecords, new Map<Id, Opportunity>((List<Opportunity>)this.records));
		
		resetTmmaOverriddenFields((Map<Id, Opportunity>)existingRecords, new Map<Id, Opportunity>((List<Opportunity>)this.records));
	}
	
	public override void onAfterInsert() {
		p('onAfterInsert');	
		createMnOpptyScheds();
	}
	
	public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
		p('onAfterUpdate');
		// Each oppty should be processed only once in after update event.
		if (processed()) return;
		
		updateOpptyScheds((List<Opportunity>)existingRecords.values());
		
		updateOpptyProdLostCancelledInfo((List<Opportunity>)existingRecords.values());
		
		updateOpptyProdPrograms((Map<Id, Opportunity>)existingRecords);
	}
	
	public void updateDesignWinApprovers(fflib_ISObjectUnitOfWork uow) {
		p('updateDesignWinApprovers');
		OpportunityApproval.setAllApprovers((List<Opportunity>)this.records, uow);
	}
	
	private void bypassValidation(Map<Id, Opportunity> existingRecords) {
		p('bypassValidation');
		Map<String, Schema.SObjectField> opptyFields = fflib_SObjectDescribe.getDescribe(getSObjectType()).getFieldsMap();
		List<Schema.SObjectField> bypassFields = BypassValidationFieldsSelector.selectBySObject(getSObjectType());
		
		for (Opportunity oppty : (List<Opportunity>)this.records) {
			oppty.Bypass_Validation__c = false;
			Boolean bypassFieldsChanged = false;
			Boolean otherFieldsChanged = false;
			
			Opportunity oldOppty = existingRecords.get(oppty.Id);
			
			for (Schema.SObjectField f : bypassFields) {
				bypassFieldsChanged |= (oppty.get(f) != oldOppty.get(f));	
			}
			
			if (bypassFieldsChanged) {
				for (Schema.SObjectField field : opptyFields.values()) {
					if (!bypassFields.contains(field) && field != Opportunity.Bypass_Validation__c && field.getDescribe().isUpdateable()) {
						String fieldName = field.getDescribe().getName();
						
						if (oppty.get(fieldName) != oldOppty.get(fieldName)) {
							otherFieldsChanged = true;
							break;
						}	
					}
				}
				
				if (!otherFieldsChanged) {
					oppty.Bypass_Validation__c = true;	
				}		
			}
		}
	}
	
	private void updateOpptyProdPrograms(Map<Id, Opportunity> existingRecords) {
		p('updateOpptyProdPrograms');
		Set<Id> opptyIds = new Set<Id>();
		
		for (Opportunity oppty : (List<Opportunity>)this.records) {
			Opportunity oldOppty = existingRecords.get(oppty.Id);
			
			if (oppty.Program__c != oldOppty.Program__c) {
				opptyIds.add(oppty.Id);	
			}
		}
		
		if (opptyIds.size() > 0) {
			List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
        
	        for (Opportunity oppty : new OpportunitiesSelector().selectByIdWithProducts(opptyIds)) {
	        	opptyProds.addAll(oppty.OpportunityLineItems);
	        }
	        
	        if (opptyProds.size() > 0) {
	        	new OpportunityLineItems(opptyProds).updateOpptyProdPrograms();
	        }	
		}	
	}
	
	private void createMnOpptyScheds() {
		p('createMnOpptyScheds');
		List<Opportunity> opptiesMn = new List<SObject>();
		
		for (Opportunity o : (List<Opportunity>)this.records) {
			if (o.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId()) {
				opptiesMn.add(o);	
			}
		}
		
		if (opptiesMn.size() > 0) {
			List<OpportunitySchedule__c> opptySchedsCreated = createMnOpptyScheds(opptiesMn);
		    
			insert opptySchedsCreated;
			
			resetOppties(new Map<Id, Opportunity>(opptiesMn).keySet());
		}	
	}
	
	private List<OpportunitySchedule__c> createMnOpptyScheds(List<Opportunity> oppties) {
		p('createMnOpptyScheds(oppties)');
		List<OpportunitySchedule__c> result = new List<OpportunitySchedule__c>();
        
        final Integer QUARTERS = 4;
        final Map<Integer, Integer> QTR_MONTHS = new Map<Integer, Integer> {1 => 1, 2 => 4, 3 => 7, 4 => 10};
				 
		for (Opportunity o : oppties) {
			Date prodDate = o.Production_Date__c;
			Integer yearQty = (Integer)o.One_Year_Pieces__c;
            Integer quarterQty = yearQty / 4;
            List<Integer> quarterQtys = new List<Integer>();
            Date schedDate = prodDate;
            Integer prodYear = prodDate.year();
            Integer prodMonth = prodDate.month();
            
            for (Integer i = 0; i < QUARTERS; i++) {
            	if (i == 3) {
                	quarterQty = yearQty - (quarterQty * 3);   
                }
                
                quarterQtys.add(quarterQty);	
            }
			
			for (Integer i = 0; i < QUARTERS; i++) {
                if (i != 0) {
                    Integer x = (prodMonth + (3 * i) - 1) / 3;
                    Integer year = prodYear + (x / 4);
                    Integer month = QTR_MONTHS.get(Math.mod(x, 4) + 1);
                    schedDate = Date.newInstance(year, month, 1);
                }
                
                quarterQty = quarterQtys.get(QUARTERS - i - 1);
                
                OpportunitySchedule__c opptySched = new OpportunitySchedule__c();
    			opptySched.Opportunity__c = o.Id;
    			opptySched.Sched_Date__c = schedDate;
    			opptySched.Oppty_Sched_Qty__c = quarterQty;
    			opptySched.Frozen_Oppty_Sched_Qty__c = quarterQty;
    			opptySched.CurrencyIsoCode = o.CurrencyIsoCode;
    			result.add(opptySched);	
            }		
		}
		
		return result;	
	} 
	
	private void updateOpptyScheds(List<Opportunity> existingRecords) {
		p('updateOpptyScheds');
		List<Opportunity> opptiesMn = new List<Opportunity>();
		Map<Id, Opportunity> opptiesOldMn = new Map<Id, Opportunity>();
		Map<Id, Opportunity> opptiesNewMn = new Map<Id, Opportunity>();
		Map<Id, Opportunity> opptiesOldSfdc = new Map<Id, Opportunity>();
		Map<Id, Opportunity> opptiesNewSfdc = new Map<Id, Opportunity>();
		
		for (SObject o : existingRecords) {
			if (isMnRecordType((Opportunity)o) && CommonUtils.isDataAdminUser()) {
				opptiesMn.add((Opportunity)o);
			}
			
			if (isMnOpptySchedsUpdatable((Opportunity)o)) {
				opptiesOldMn.put(o.Id, (Opportunity)o);	
			} else {
				opptiesOldSfdc.put(o.Id, (Opportunity)o);
			}
		}
		
		for (SObject o : (List<Opportunity>)this.records) {
			if (isMnOpptySchedsUpdatable((Opportunity)o)) {
				opptiesNewMn.put(o.Id, (Opportunity)o);	
			} else {
				opptiesNewSfdc.put(o.Id, (Opportunity)o);
			}
		}
		
		if (opptiesOldMn.size() > 0 && opptiesNewMn.size() > 0) {
			List<OpportunitySchedule__c> opptySchedsUpdated = updateMnOpptyScheds(opptiesOldMn, opptiesNewMn);
			
			if (opptySchedsUpdated.size() > 0) {
				update opptySchedsUpdated;
			}
		}
		
		if (opptiesMn.size() > 0) {
			resetOppties(new Map<Id, Opportunity>(opptiesMn).keySet());	
		}
		
		if (opptiesOldSfdc.size() > 0 && opptiesNewSfdc.size() > 0) {
			List<OpportunitySchedule__c> opptySchedsUpdated = updateSfdcOpptyScheds(opptiesOldSfdc, opptiesNewSfdc);
			
			if (opptySchedsUpdated.size() > 0) {
				update opptySchedsUpdated;	
			}
		}
	}
	
	private Boolean isMnOpptySchedsUpdatable(Opportunity oppty) {
		p('isMnOpptySchedsUpdatable');
		return isMnRecordType(oppty) && !isTmmaOverride(oppty) && CommonUtils.isDataAdminUser();
	}
	
	private void resetOppties(Set<Id> opptyIds) {
		p('resetOppties');
		List<Opportunity> opptiesUpdated = new List<Opportunity>(); 
				
		for (Opportunity o : new OpportunitiesSelector().selectById(opptyIds)) {
			o.Bypass_Validation_Sched_Start_Date__c = false;
			opptiesUpdated.add(o);
		}
		
		update opptiesUpdated;	
	}
	
	private List<OpportunitySchedule__c> updateMnOpptyScheds(Map<Id, Opportunity> opptiesOld, Map<Id, Opportunity> opptiesNew) {
    	p('updateMnOpptyScheds');
		List<OpportunitySchedule__c> result = new List<OpportunitySchedule__c>();
		
		List<OpportunitySchedule__c> opptyScheds = new OpportunitySchedulesSelector().selectByOpptyId(opptiesNew.keySet()); 
		
		for (Opportunity opptyNew : opptiesNew.values()) {
			if (opptiesOld.get(opptyNew.Id).Production_Date__c != opptyNew.Production_Date__c ||
				opptiesOld.get(opptyNew.Id).One_Year_Pieces__c != opptyNew.One_Year_Pieces__c ||
				opptiesOld.get(opptyNew.Id).CurrencyIsoCode != opptyNew.CurrencyIsoCode) {
				List<OpportunitySchedule__c> oldOpptyScheds = getOpptySchedsForUpdate(opptyScheds, opptyNew.Id);
				List<OpportunitySchedule__c> newOpptyScheds = createMnOpptyScheds(new List<Opportunity>{opptyNew});
				
				for (Integer i = 0; i < oldOpptyScheds.size(); i++) {
					OpportunitySchedule__c osOld = oldOpptyScheds.get(i);
					OpportunitySchedule__c osNew = newOpptyScheds.get(i);
					
					osOld.Sched_Date__c = osNew.Sched_Date__c;
    				osOld.Oppty_Sched_Qty__c = osNew.Oppty_Sched_Qty__c;
    				osOld.Frozen_Oppty_Sched_Qty__c = osNew.Frozen_Oppty_Sched_Qty__c;	
    				osOld.CurrencyIsoCode = opptyNew.CurrencyIsoCode;
    				result.add(osOld);		
				}
			}	
		}	
		
		return result;
	}
	
	private List<OpportunitySchedule__c> updateSfdcOpptyScheds(Map<Id, Opportunity> opptiesOld, Map<Id, Opportunity> opptiesNew) {
		p('updateSfdcOpptyScheds');
		List<OpportunitySchedule__c> result = new List<OpportunitySchedule__c>();
		
		List<OpportunitySchedule__c> opptyScheds = new OpportunitySchedulesSelector().selectByOpptyId(opptiesNew.keySet()); 
		
		for (Opportunity opptyNew : opptiesNew.values()) {
			if (opptiesOld.get(opptyNew.Id).CurrencyIsoCode != opptyNew.CurrencyIsoCode) {
				List<OpportunitySchedule__c> opptySchedsUpdated = getOpptySchedsForUpdate(opptyScheds, opptyNew.Id);
				
				for (OpportunitySchedule__c os : opptySchedsUpdated) {
					os.CurrencyIsoCode = opptyNew.CurrencyIsoCode;
					result.add(os);
				}			
			}	
		}
		
		return result;	
	}
	
	private List<OpportunitySchedule__c> getOpptySchedsForUpdate(List<OpportunitySchedule__c> opptyScheds, Id opptyId) {
		p('getOpptySchedsForUpdate');
		List<OpportunitySchedule__c> result = new List<OpportunitySchedule__c>();
		
		for (OpportunitySchedule__c os : opptyScheds) {
			if (os.Opportunity__c == opptyId) {
				result.add(os);
			}			
		} 
		
		return result;	
	}
	
	private void updateOpptyProdLostCancelledInfo(List<Opportunity> existingRecords){
		p('updateOpptyProdLostCancelledInfo');
		List<OpportunityLineItem> opptyProds;
		List<OpportunityLineItem> opptyProdsUpdated = new List<OpportunityLineItem>();
		Map<Id, List<OpportunityLineItem>> opptyAndOpptyProds = new Map<Id, List<OpportunityLineItem>>();
		
		opptyAndOpptyProds = getOpptyProds((List<Opportunity>)this.records);
		
		for (Opportunity opptyOld : existingRecords) {
			for (Opportunity opptyNew : (List<Opportunity>)this.records) {
				if (opptyOld.Id == opptyNew.Id) {
					if (opptyAndOpptyProds.containsKey(opptyNew.Id)) {
						opptyProds = opptyAndOpptyProds.get(opptyNew.Id);
						
						if (opptyProds != null) {
							if (opptyNew.RecordTypeId == OpportunitiesSelector.getSfdcRecordTypeId()) {
								if ((OPEN_STAGES.contains(opptyOld.StageName) || opptyOld.StageName == STAGE_COMMITMENT) && LOST_STAGES.contains(opptyNew.StageName)) {
									for (OpportunityLineItem opptyProd : opptyProds) {
										OpportunityLineItem opptyProdUpdate = new OpportunityLineItem(
											Id = opptyProd.Id,
											Prod_Lost__c = true,
											Prod_Lost_Cancelled__c = opptyNew.StageName,
											Prod_Lost_Cancelled_Date__c = opptyNew.Lost_Date__c,
											Prod_Lost_Reason__c = opptyNew.Lost_Description__c, // text area
											Prod_Lost_Cancelled_Reason__c = opptyNew.Lost_Reason__c, // picklist
											Competitor__c = opptyNew.Competitors__c
										);
										
										opptyProdsUpdated.add(opptyProdUpdate);
									}										
								}
							}
							
							if (opptyNew.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId()) {
								if ((opptyOld.StageName != STAGE_LOST && opptyNew.StageName == STAGE_LOST) ||
								    (opptyOld.StageName != STAGE_CANCELLED && opptyNew.StageName == STAGE_CANCELLED) ||
								    (LOST_STAGES.contains(opptyNew.StageName) && (opptyOld.Lost_Date__c != opptyNew.Lost_Date__c || opptyOld.Lost_Reason__c != opptyNew.Lost_Reason__c))) {
									for (OpportunityLineItem opptyProd : opptyProds) {
										OpportunityLineItem opptyProdUpdate = new OpportunityLineItem(
											Id = opptyProd.Id,
											Prod_Lost__c = true,
											Prod_Lost_Cancelled__c = opptyNew.StageName,
											Prod_Lost_Cancelled_Date__c = opptyNew.Lost_Date__c,
											Prod_Lost_Cancelled_Reason__c = opptyNew.Lost_Reason__c
										);
										
										opptyProdsUpdated.add(opptyProdUpdate);
									}
								}
								
								if (LOST_STAGES.contains(opptyOld.StageName) && !LOST_STAGES.contains(opptyNew.StageName)) {
									for (OpportunityLineItem opptyProd : opptyProds) {
										OpportunityLineItem opptyProdUpdate = new OpportunityLineItem(
											Id = opptyProd.Id,
											Prod_Lost__c = false,
											Prod_Lost_Cancelled__c = null,
											Prod_Lost_Cancelled_Date__c = opptyNew.Lost_Date__c,
											Prod_Lost_Cancelled_Reason__c = opptyNew.Lost_Reason__c
										);
										
										opptyProdsUpdated.add(opptyProdUpdate);
									}
								}
							}
						}
					}
					
					break;
				}
			}
		}
		
		update opptyProdsUpdated; 
	}
		
	private Map<Id, List<OpportunityLineItem>> getOpptyProds(List<Opportunity> oppties){
		p('getOpptyProds');
		Set<Id> opptyIds = new Set<Id>();
		Map<Id, List<OpportunityLineItem>> result = new Map<Id, List<OpportunityLineItem>>();
		
		for (Opportunity oppty : oppties) {
			opptyIds.add(oppty.Id);
		} 
				
		for (OpportunityLineItem opptyProd : new OpportunityLineItemsSelector().selectByOpptyIdWithOpportunity(opptyIds)) {
			if(result.containsKey(opptyProd.OpportunityId)) {
				result.get(opptyProd.OpportunityId).add(opptyProd);
			}
			else{
				result.put(opptyProd.OpportunityId, new List<OpportunityLineItem>{opptyProd});
			}
		}
        
		return result;
	}
	
	private void updateOpptyGeneralInfo(List<Opportunity> existingRecords){
		p('updateOpptyGeneralInfo');
    	if (!(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))) return;
    	
    	Set<Id> accountIds = new Set<Id>();
    	Map<Id, Id> parentAccountIds;
    	Map<Id, Account> accountParentIdAndRegion;
                
        for (Opportunity o : (List<Opportunity>)this.records) {
			accountIds.add(o.AccountId);            
        }
        
        accountParentIdAndRegion = new Map<Id, Account>(new AccountsSelector().selectById(accountIds));
        
        system.debug('===== [Scarlett] set Opportunity General Info...');
        
        if (existingRecords == null) {
        	for(Opportunity opptyNew : (List<Opportunity>)this.records) {
	        	if (opptyNew.RecordTypeId == OpportunitiesSelector.getSfdcRecordTypeId()) {
	        		// Set Lost Date, Design Win Approval Status
                    if (LOST_STAGES.Contains(opptyNew.StageName)){       		
                        opptyNew.Lost_Date__c = date.today();
	        			opptyNew.Design_Win_Approval_Process__c = APPROVAL_STATUSES.get(ApprovalStatus.LOST);
                    }
	        		
	        		// Set Curreny and update Locked Exchange Rate
	        		if (CommonUtils.getFxRatesByCurIsoCode().containsKey(opptyNew.CurrencyIsoCode)) {
	        			opptyNew.Currency__c = CommonUtils.getFxRatesByCurIsoCode().get(opptyNew.CurrencyIsoCode).Id;
                        opptyNew.Locked_Exchange_Rate__c = CommonUtils.getFxRatesByCurIsoCode().get(opptyNew.CurrencyIsoCode).Exchange_Rate__c;
	        		}
	        	}
	        	
	        	if (opptyNew.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId()) {
	        		// Set Curreny for MN Oppty
	        		if (CommonUtils.getFxRatesByCurIsoCode().containsKey(opptyNew.CurrencyIsoCode)) {
	        			opptyNew.Currency__c = CommonUtils.getFxRatesByCurIsoCode().get(opptyNew.CurrencyIsoCode).Id;
	        		}
	        	}
	        	
                // Set Parent Account Id Text
                if (accountParentIdAndRegion.containsKey(opptyNew.AccountId)) {
                    setParentAccountIdText(opptyNew, accountParentIdAndRegion.get(opptyNew.AccountId).ParentId);                   
                }
                
                // Set Account Region Text (Account_Region_TEXT__c)
                if (opptyNew.AccountId != null && accountParentIdAndRegion.containsKey(opptyNew.AccountId)) {
                	opptyNew.Account_Region_TEXT__c = accountParentIdAndRegion.get(opptyNew.AccountId).Region__c;
                }
				
               	// Set Last Business Modified Date & Last Business Modified by
               	if (Trigger.isInsert) {
		            opptyNew.Last_Business_Modified_By_Id__c = UserInfo.getUserId();
					opptyNew.Last_Business_Modified_Date__c = Datetime.now();
	            }
	            
        		// Set Discovery Date
                if (Trigger.isInsert && opptyNew.StageName == STAGE_DISCOVERY) {
                	opptyNew.Discovery_Date__c = date.today();
                }
	        }
        }
        else if ((List<Opportunity>)this.records != null) {           
	        for (Opportunity opptyNew : (List<Opportunity>)this.records) {
	        	// Set Last Business Modified By Id and Last Business Modified Date
	            if (Trigger.isUpdate) {
	                if (!CommonUtils.isAdminOrIntegrationUser()) {
	                    opptyNew.Last_Business_Modified_By_Id__c = UserInfo.getUserId();
	                    opptyNew.Last_Business_Modified_Date__c = Datetime.now();
	                }
	            }
	            
	            if (opptyNew.RecordTypeId == OpportunitiesSelector.getSfdcRecordTypeId()) {
	            	// Set Probability to Win
					if (opptyNew.Design_Win_Approval_Process__c == APPROVAL_STATUSES.get(ApprovalStatus.APPROVED)) {
						opptyNew.Probability_to_Win__c = '80% - 100%';
					}
				}
				
				if (opptyNew.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId()) {
	        		// Set Curreny for MN Oppty
	        		if (CommonUtils.getFxRatesByCurIsoCode().containsKey(opptyNew.CurrencyIsoCode)) {
	        			opptyNew.Currency__c = CommonUtils.getFxRatesByCurIsoCode().get(opptyNew.CurrencyIsoCode).Id;
	        		}
	        	}
	        }
            
	        for (Opportunity opptyOld : existingRecords) {
	    		for (Opportunity opptyNew : (List<Opportunity>)this.records) {    			
	    			if (opptyOld.Id == opptyNew.Id) {    				
	    				if (opptyOld.RecordTypeId == OpportunitiesSelector.getSfdcRecordTypeId()) {
	                        //If Opportunity is changed from Open to Lost/Cancelled
	                        if (OPEN_STAGES.Contains(opptyOld.StageName) && LOST_STAGES.Contains(opptyNew.StageName)) {
	                            //Set Lost/Cancelled Date
	                            opptyNew.Lost_Date__c = date.today();
	                            
	                            //Update Design Win Approval Status
	                            opptyNew.Design_Win_Approval_Process__c = APPROVAL_STATUSES.get(ApprovalStatus.LOST);
	                        }             
	                        
	                        //If Opportunity is changed from Lost/Cancelled to Open
	                        if (LOST_STAGES.Contains(opptyOld.StageName) && OPEN_STAGES.Contains(opptyNew.StageName)) {
	                            opptyNew.Lost_Date__c = NULL;
	                            opptyNew.Lost_Description__c = NULL;
	                            opptyNew.Lost_Reason__c = NULL;
	                            
	                            opptyNew.Design_Win_Approval_Process__c = APPROVAL_STATUSES.get(ApprovalStatus.OPEN);
	                        }

							// Set Curreny and update Locked Exchange Rate
					        if (CommonUtils.getFxRatesByCurIsoCode().containsKey(opptyNew.CurrencyIsoCode)) {
			                    opptyNew.Currency__c = CommonUtils.getFxRatesByCurIsoCode().get(opptyNew.CurrencyIsoCode).Id;
			                    
			                    if (opptyNew.Design_Win_Approval_Process__c == APPROVAL_STATUSES.get(ApprovalStatus.OPEN)) {
			                    	opptyNew.Locked_Exchange_Rate__c = CommonUtils.getFxRatesByCurIsoCode().get(opptyNew.CurrencyIsoCode).Exchange_Rate__c;
			                    }
			                }

	                        // Set Probability to Win
	                        if (opptyOld.Design_Win_Approval_Process__c != APPROVAL_STATUSES.get(ApprovalStatus.APPROVED) && opptyNew.Design_Win_Approval_Process__c == APPROVAL_STATUSES.get(ApprovalStatus.APPROVED)) {
	    						opptyNew.Probability_to_Win__c = '80% - 100%';
	    					}
	                	}
	                	
	                	//Set History Tracking of Help Needed
	                    if (opptyOld.Help_Needed__c != opptyNew.Help_Needed__c) {
	                        opptyNew.Help_Needed_History__c = opptyOld.Help_Needed__c;
	                    }
	                    
	                    //Set Parent Account Id Text
	                    if (accountParentIdAndRegion.containsKey(opptyNew.AccountId)) {
	                        setParentAccountIdText(opptyNew, accountParentIdAndRegion.get(opptyNew.AccountId).ParentId);
	                    }
	                    
	                    // Set Account Region Text (Account_Region_TEXT__c)
		                if (accountParentIdAndRegion.containsKey(opptyNew.AccountId) && opptyOld.AccountId != opptyNew.AccountId) {
		                	opptyNew.Account_Region_TEXT__c = accountParentIdAndRegion.get(opptyNew.AccountId).Region__c;
		                }
		                
		        		// Set Discovery Date
		                if (opptyOld.StageName != STAGE_DISCOVERY && opptyNew.StageName == STAGE_DISCOVERY) {
		                	opptyNew.Discovery_Date__c = date.today();
		                }
	    			}
	    		}
	    	}
        }
    }
    
	private void setParentAccountIdText(Opportunity oppty, Id parentId) {
		p('setParentAccountIdText');
    	oppty.Parent_Account_ID_Text__c = (parentId != null) ? String.valueOf(parentId).substring(0, 15) : null;
    }
    
    private void updateOpptyStarInfo(){
    	p('updateOpptyStarInfo');
    	if (!(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))) return;
        
        system.debug('===== [Scarlett] Update Star info');

    	for (Opportunity opptyNew : (List<Opportunity>)this.records) {
    		if (opptyNew.RecordTypeId == OpportunitiesSelector.getSfdcRecordTypeId()) {
    			if (opptyNew.ASSE_Qual_plan_requested_by__c != null) {
    				opptyNew.Qual_Plan_requested__c = true;
    			}
    			else {
    				opptyNew.Qual_Plan_requested__c = false;
    			}
    			
    			if (opptyNew.Customer_DRI__c != null) {
    				opptyNew.Star_contact_window_identified__c = true;
    			}
    			else {
    				opptyNew.Star_contact_window_identified__c = false;
    			}
    			
    			if (opptyNew.APN_Rate__c == 100) {
    				opptyNew.APN_assigned__c = true;
    			}
    			else {
    				opptyNew.APN_assigned__c = false;
    			}
    			
				if (opptyNew.BL_DRI_New__c != null && opptyNew.BL_DRI_New__c != '') {
    				opptyNew.Internal_Concept_realized__c = true;
    			}
    			else {
    				opptyNew.Internal_Concept_realized__c = false;
    			}
    			
				if (calcDwCompletion(opptyNew) != 0) {
					opptyNew.Percentage_to_DW_Completion__c = calcDwCompletion(opptyNew);
				}
    		}
    	}
    }
    
    private Double calcDwCompletion(Opportunity opptyNew){
    	p('calcDwCompletion');
    	Double result = 0;

		if(opptyNew.Internal_Concept_realized__c == true || 
    		opptyNew.Star_contact_window_identified__c == true ||
		    opptyNew.Paper_slides_prepped_and_discussion_with__c == true || 
		    opptyNew.Discussion_with_Star_occurred_follow__c == true ||
		    opptyNew.Samples_available__c == true ||
		    opptyNew.Project_Known__c == true ||
		    opptyNew.APN_assigned__c == true ||
		    opptyNew.Sampled_to_Dev_Build__c == true ||
		    opptyNew.Qual_Plan_requested__c == true ||
		    opptyNew.Sampled_to_Proto_Build__c == true ||
		    opptyNew.Show_up_on_MPS_IO_File_12_16_weeks_be__c == true ||
		    opptyNew.Qual_Complete__c == true ||
		    opptyNew.EVT_Done__c == true||
		    opptyNew.DVT_Done__c == true
			){
				if (opptyNew.Internal_Concept_realized__c == true)
		    		result += 15/4;
		    	
		    	if (opptyNew.Star_contact_window_identified__c == true)
		    		result += 15/4;
		    	
		    	if (opptyNew.Paper_slides_prepped_and_discussion_with__c == true) 
		    		result += 15/4;
		    	
		    	if (opptyNew.Discussion_with_Star_occurred_follow__c == true) 
		    		result += 15/4;
		    	
		    	if (opptyNew.Samples_available__c == true)
		    		result += 25/4;
		    	
		    	if (opptyNew.Project_Known__c == true) 
		    		result += 25/4;
		    	
		    	if (opptyNew.APN_assigned__c == true) 
		    		result += 25/4;
		    	
		    	if (opptyNew.Sampled_to_Dev_Build__c == true) 
		    		result += 25/4;
		    	
		    	if (opptyNew.Qual_Plan_requested__c == true) 
		    		result += 35/2;
		    	
		    	if (opptyNew.Sampled_to_Proto_Build__c == true)
		    		result += 35/2;
		    	
		    	if (opptyNew.Show_up_on_MPS_IO_File_12_16_weeks_be__c == true)
		    		result += 25/4;
		    	
		    	if (opptyNew.Qual_Complete__c == true) 
		    		result += 25/4;
		    	
		    	if (opptyNew.EVT_Done__c == true)
		    		result += 25/4;
		    	
		    	if (opptyNew.DVT_Done__c == true)
		    		result += 25/4;
			}
		    
		return result;
    }
    
    private void updateTmmaOverride(Map<Id, Opportunity> opptiesOld, Map<Id, Opportunity> opptiesNew) {
    	p('updateTmmaOverride');
    	Set<String> tmmaOverrideFields = getTmmaOverrideFields();
    	
    	for (Opportunity oNew : opptiesNew.values()) {
        	Opportunity oOld = opptiesOld.get(oNew.Id);
        	
        	if (isMnRecordType(oNew) && !CommonUtils.isDataAdminUser() && CommonUtils.fieldsChanged(oOld, oNew, tmmaOverrideFields)) {
            	oNew.TMMA_Override__c = true;	
            }
    	}	
    }
    
    private void resetTmmaOverriddenFields(Map<Id, Opportunity> opptiesOld, Map<Id, Opportunity> opptiesNew) {
    	p('resetTmmaOverriddenFields');
    	for (Opportunity oNew : opptiesNew.values()) {
        	Opportunity oOld = opptiesOld.get(oNew.Id);    

            if (isMnRecordType(oNew) && isTmmaOverride(oNew) && CommonUtils.isDataAdminUser()) {
            	Date userCloseDate = oOld.CloseDate;
            	Date userProdDate = oOld.Production_Date__c;
        		Date regPartWinDate = oNew.CloseDate;
            	
            	OpportunityService.setMnOpportunityCloseDateAndProdDate(oNew, oOld, userCloseDate, userProdDate, regPartWinDate); 
            }
        }
    }
   
    private Boolean isMnRecordType(Opportunity oppty) {
		p('isMnRecordType');
		return oppty.RecordTypeId == OpportunitiesSelector.getMnRecordTypeId();
    }
    
    private Boolean isTmmaOverride(Opportunity oppty) {
    	p('isTmmaOverride');
    	return oppty.TMMA_Override__c;
    }
    
    private Set<String> getTmmaOverrideFields() {
    	p('getTmmaOverrideFields');
    	return new OpportunityTmmaOverrideSettingsSelector().selectFieldNamesByObjectName(getSObjectName());
    }

    private Boolean processed() {
    	p('processed');
    	Boolean result = true;
		
		if (Trigger.isBefore && Trigger.isUpdate) {
			for (Opportunity oppty : (List<Opportunity>)this.records) {
				if (!beforeUpdateProcessedIds.contains(oppty.Id)) {
					beforeUpdateProcessedIds.add(oppty.Id);
					result = false;	
				}	
			}	
		} else if (Trigger.isAfter && Trigger.isUpdate) {
			for (Opportunity oppty : (List<Opportunity>)this.records) {
				if (!afterUpdateProcessedIds.contains(oppty.Id)) {
					afterUpdateProcessedIds.add(oppty.Id);
					result = false;	
				}	
			}	
		} 
		
		return result;	
    }
    
}