public class OpportunityLineItems extends ApplicationDomain {
	
	public static final Set<String> LOST_CANCELLED = new Set<String> {'Lost', 'Cancelled'};
	
	private static final Integer PRICE_EROSION_QUARTERS = 4;
    
    private static final String PROBABILITY_TO_WIN_80_100 = '80% - 100%';
	
	private static Set<Id> opptyProdSchedIds;
	
	public OpportunityLineItems(List<OpportunityLineItem> opptyProds) {
		super(opptyProds);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new OpportunityLineItems(sObjectList);
		}
	}
	
	public override void onBeforeInsert() {
		p('onBeforeInsert');
		checkOpptyScheds();
		
		OpportunityLineItemTrigger.onBeforeInsert((List<OpportunityLineItem>)this.records);
		
		updateOpptyProdLastBusinessModifiedInfo();
		
		updateOpptyProdQty();
		
		updateOpptyProdLostCancelledInfo();
		
		OpportunityProductClaimValue.setOpportunityProductClaimValues((List<OpportunityLineItem>)this.records);
		
		updatePrograms();
	}
	
	public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
		p('onBeforeUpdate');
		OpportunityProductClaimValue.bypassOpportunityProductMnUpdateForTmmaOverride((Map<Id, OpportunityLineItem>)existingRecords, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)this.records));
		
		OpportunityProductClaimValue.setOpportunityProductClaimValues((List<OpportunityLineItem>)this.records);	
		
		updateOpptyProdLastBusinessModifiedInfo();

		updateOpptyProdLostCancelledInfo((List<OpportunityLineItem>)existingRecords.values());
		
		OpportunityLineItemTrigger.onBeforeUpdate((List<OpportunityLineItem>)this.records);
		
		updateOpptyProdHelpNeededHistory((List<OpportunityLineItem>)existingRecords.values());
	}
	
	public override void onAfterInsert() {
		p('onAfterInsert');	
		OpportunityLineItemTrigger.onAfterInsert_Update_Delete((List<OpportunityLineItem>)this.records);
		
		createOpptyProdScheds();
	}
	
	public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
		p('onAfterUpdate');
		OpportunityProductClaimValue.updateTmmaOverrideIfOpportunityProductMnUpdatedByTmma((Map<Id, OpportunityLineItem>)existingRecords, new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>)this.records));
		
		OpportunityLineItemTrigger.onAfterInsert_Update_Delete((List<OpportunityLineItem>)this.records);
		
		createReOpenOpptyProdScheds((List<OpportunityLineItem>)existingRecords.values());
		
		updateOpptyProdScheds((List<OpportunityLineItem>)existingRecords.values());
		
		deleteLostCancelledOpptyProdScheds((List<OpportunityLineItem>)existingRecords.values());
	}
	
	public override void onAfterDelete() {
		p('onAfterDelete');
		OpportunityLineItemTrigger.onAfterInsert_Update_Delete((List<OpportunityLineItem>)this.records);
		
		deleteOpptyProdScheds();
	}
	
	/**
     * @param schedDateIndex: 0-based list index of the schedule date
     */
    public static Decimal calcOpportunityProductSchedulePrice(Decimal unitPrice, Decimal priceErosionRate, Integer schedDateIndex) {
        // Apply price erosion rate every PRICE_EROSION_QUARTERS quarters. Use previous quarter price as base price.
        return (unitPrice * Math.pow(Double.valueOf(1 - (priceErosionRate / 100)), schedDateIndex / PRICE_EROSION_QUARTERS)).setScale(6);
    }
	 
	public void updateOpptyProdPrograms() {
		p('updateOpptyProdPrograms');
		for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
			opptyProd.Program__c = opptyProd.Opportunity.Program__c;
		}
		
		update this.records;
	}
	
	//SFDC-1154
    public void updateOpptyProdProbabilityToWin(fflib_ISObjectUnitOfWork uow) {
        p('updateProbabilityToWin');
        List<OpportunityLineItem> opptyProdsUpdated = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            if (!(LOST_CANCELLED.contains(opptyProd.Prod_Lost_Cancelled__c))) {
                opptyProdsUpdated.add(new OpportunityLineItem(Id = opptyProd.Id, Probability_to_Win__c = PROBABILITY_TO_WIN_80_100));
            }
        }
        
        uow.registerDirty(opptyProdsUpdated);
    }

	private void updatePrograms() {
		p('updatePrograms');
		Set<Id> opptyIds = new Set<Id>();
		
		for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
			opptyIds.add(opptyProd.OpportunityId);
		}
		
		Map<Id, Opportunity> oppties = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
		
		for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
			opptyProd.Program__c = oppties.get(opptyProd.OpportunityId).Program__c;	
		}	
	}
	
    private void deleteOpptyProdScheds(){
    	p('deleteOpptyProdScheds');
        Set<Id> opptyProdIds = new Set<Id>();
        List<OpportunityProductSchedule__c> opptyProdSchedsDeleted;
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            opptyProdIds.add(opptyProd.Id);
        }
        
        // Opporunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        Map<Id, Map<Id, OpportunityProductSchedule__c>> opptyProdSchedsByOpptyProdId = getOpptyProdSchedsByOpptyProdId((List<OpportunityLineItem>)this.records, opptyProdIds);
        
        opptyProdSchedsDeleted = new List<OpportunityProductSchedule__c>();
        
        for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
            for (Id opptyProdSchedId : opptyProdSchedIds) {
                if (opptyProdSchedsByOpptyProdId.containsKey(opptyProd.Id) && opptyProdSchedsByOpptyProdId.get(opptyProd.Id).containsKey(opptyProdSchedId)) {
                    opptyProdSchedsDeleted.add(opptyProdSchedsByOpptyProdId.get(opptyProd.Id).get(opptyProdSchedId));

                }
            }
        }
        
        delete opptyProdSchedsDeleted;
    }
    
    private Map<Id, Map<Id, OpportunityProductSchedule__c>> getOpptyProdSchedsByOpptyProdId(List<OpportunityLineItem> opptyProds, Set<Id> opptyProdIds){
    	p('getOpptyProdSchedsByOpptyProdId');
        // Opporunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        Map<Id, Map<Id, OpportunityProductSchedule__c>> result = new Map<Id, Map<Id, OpportunityProductSchedule__c>>();
        
        opptyProdSchedIds = new Set<Id>();
        
        Set<Id> opptyIds = getOpptyIds(opptyProds);

        for (OpportunityProductSchedule__c opptyProdSched : new OpportunityProductSchedulesSelector().selectByOpptyIdAndOpptyProdId(opptyIds, opptyProdIds)) {
            opptyProdSchedIds.add(opptyProdSched.Id);                                                     
                                                                 
            if (result.containsKey(opptyProdSched.Oppty_Prod_ID_Full__c)) {
                result.get(opptyProdSched.Oppty_Prod_ID_Full__c).put(opptyProdSched.Id, opptyProdSched);
            }
            else {
                result.put(opptyProdSched.Oppty_Prod_ID_Full__c, new Map<Id, OpportunityProductSchedule__c> {opptyProdSched.Id => opptyProdSched});
            }
        }
        
        return result;
    }
    
	private void createOpptyProdScheds() {
		p('createOpptyProdScheds');
        Set<Id> opptyIds = getOpptyIds((List<OpportunityLineItem>)this.records);
                     
        Id opptyId = null;
        List<OpportunitySchedule__c> opptyScheds = null;
        Map<Id, List<OpportunitySchedule__c>> opptySchedsMap = new Map<Id, List<OpportunitySchedule__c>>();
        
        for (OpportunitySchedule__c os : new OpportunitySchedulesSelector().selectByOpptyId(opptyIds)) {
            if (opptyId != os.Opportunity__c) {
                opptyId = os.Opportunity__c;
                opptyScheds = new List<OpportunitySchedule__c>();     
            }                                   
            
            opptyScheds.add(os);
            opptySchedsMap.put(opptyId, opptyScheds);           
        }            
        
        List<OpportunityProductSchedule__c> opptyProdSchedsCreated = new List<OpportunityProductSchedule__c>();
        
        for (OpportunityLineItem oli : (List<OpportunityLineItem>)this.records) {
        	if (LOST_CANCELLED.contains(oli.Prod_Lost_Cancelled__c)) continue;
        	
            Integer schedDateIndex = 0;
            
            for (OpportunitySchedule__c os : opptySchedsMap.get(oli.OpportunityId)) {
                Decimal price = calcOpportunityProductSchedulePrice(oli.UnitPrice, oli.Price_Erosion_Rate__c, schedDateIndex);
                OpportunityProductSchedule__c opptyProdSched = new OpportunityProductSchedule__c();
                    
                opptyProdSched.Sched_Date__c = os.Sched_Date__c;
                opptyProdSched.Oppty_Sched_Qty__c = os.Oppty_Sched_Qty__c;
                opptyProdSched.Frozen_Oppty_Sched_Qty__c = os.Frozen_Oppty_Sched_Qty__c;
                opptyProdSched.Opportunity__c = oli.OpportunityId;
                opptyProdSched.Oppty_Prod_ID_Full__c = oli.Id;
                opptyProdSched.Product__c = oli.Product2Id;
                opptyProdSched.Prod_Sched_Price__c = price;
                opptyProdSched.Frozen_Prod_Sched_Price__c = price;
                opptyProdSched.Share__c = oli.Share__c;
                opptyProdSched.Frozen_Share__c = oli.Share__c;
                opptyProdSched.Qty_Per_Sys__c = oli.Component_Multiplier__c;
                opptyProdSched.CurrencyIsoCode = oli.CurrencyIsoCode;  
                    
                opptyProdSchedsCreated.add(opptyProdSched);
                schedDateIndex++;
            }
        }
        
        insert opptyProdSchedsCreated;
    }
    
    private void deleteLostCancelledOpptyProdScheds(List<OpportunityLineItem> existingRecords) {
    	p('deleteLostCancelledOpptyProdScheds');
    	Set<Id> opptyProdIds = new Set<Id>();
        
		List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>(); 

    	for (OpportunityLineItem opptyProdOld : existingRecords) {
    		for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
                if(opptyProdOld.Id == opptyProdNew.Id) {
                    if (!LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        opptyProdIds.add(opptyProdNew.Id);
                        opptyProds.add(opptyProdNew);
                        system.debug('=====[Scarlett] Oppty Prod is changed from Open to Lost/Cancelled...');
                    }
                    
                    break;
                }
    		}
    	}    	
    	
    	// Opporunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
    	Map<Id, Map<Id, OpportunityProductSchedule__c>> opptyProdSchedsByOpptyProdId = getOpptyProdSchedsByOpptyProdId(opptyProds, opptyProdIds);
        
        List<OpportunityProductSchedule__c> opptyProdSchedsDeleted = new List<OpportunityProductSchedule__c>();

    	for (OpportunityLineItem opptyProdOld : existingRecords) {
    		for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
                if(opptyProdOld.Id == opptyProdNew.Id) {
                    if (!LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        for (Id opptyProdSchedId : opptyProdSchedIds) {
                            if (opptyProdSchedsByOpptyProdId.containsKey(opptyProdNew.Id) && opptyProdSchedsByOpptyProdId.get(opptyProdNew.Id).containsKey(opptyProdSchedId)) { //updated by Scarlett on Jan 19
                                opptyProdSchedsDeleted.add(opptyProdSchedsByOpptyProdId.get(opptyProdNew.Id).get(opptyProdSchedId));
                                system.debug('=====[Scarlett] delete oppty prod scheds when product is changed to Lost...');
                            }
                        }
                    }
                    
                    break;
                }
            }
        }

    	delete opptyProdSchedsDeleted; 
    }
    
    private void createReOpenOpptyProdScheds(List<OpportunityLineItem> existingRecords) {
    	p('createReOpenOpptyProdScheds');
    	Set<Id> opptyIds = new Set<Id>();
    	Set<Id> opptyProdIds = new Set<Id>();
            	
    	for (OpportunityLineItem opptyProdOld : existingRecords) {
    		for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
                if (opptyProdOld.Id == opptyProdNew.Id) {
                    if (LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && !LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        opptyProdIds.add(opptyProdNew.Id);
                        opptyIds.add(opptyProdNew.OpportunityId);
                        system.debug('=====[Scarlett] create oppty prod scheds for re open oppty products...');
                    }
                    
                    break;
                }
    		}
    	} 
    	
    	List<OpportunityProductSchedule__c> opptyProdSchedsCreated = new List<OpportunityProductSchedule__c>();
    	Map<Id, List<OpportunitySchedule__c>> opptySchedsByOpptyId = getOpptySchedsByOpptyId(opptyIds);

		List<OpportunitySchedule__c> opptyScheds;
		OpportunityProductSchedule__c opptyProdSchedNew;

        for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
            if (opptyProdIds.contains(opptyProdNew.Id)) { // re-open products
                Integer schedIndex = 0;
    
                if (opptySchedsByOpptyId.containsKey(opptyProdNew.OpportunityId)) { // has Oppty Sched
                    opptyScheds = opptySchedsByOpptyId.get(opptyProdNew.OpportunityId);
                    
                    if (opptyScheds.size() > 0) {
                        for (OpportunitySchedule__c opptySched : opptyScheds) {
                            opptyProdSchedNew = new OpportunityProductSchedule__c();
                            
                            opptyProdSchedNew.Opportunity__c = opptyProdNew.OpportunityId;
                            opptyProdSchedNew.CurrencyIsoCode = opptyProdNew.CurrencyIsoCode; //J
                            
                            opptyProdSchedNew.Sched_Date__c = opptySched.Sched_Date__c;
                            opptyProdSchedNew.Oppty_Sched_Qty__c = opptySched.Oppty_Sched_Qty__c;
                            opptyProdSchedNew.Frozen_Oppty_Sched_Qty__c = opptySched.Oppty_Sched_Qty__c;
                            
                            opptyProdSchedNew.Product__c = opptyProdNew.Product2Id;
                            opptyProdSchedNew.Oppty_Prod_ID_Full__c = opptyProdNew.Id;
                            opptyProdSchedNew.Qty_Per_Sys__c = opptyProdNew.Component_Multiplier__c;
                            opptyProdSchedNew.Share__c = opptyProdNew.Share__c;
                            opptyProdSchedNew.Frozen_Share__c = opptyProdNew.Share__c;
                            
                            opptyProdSchedNew.Prod_Sched_Price__c = calcOpportunityProductSchedulePrice(opptyProdNew.UnitPrice, opptyProdNew.Price_Erosion_Rate__c, schedIndex);
                            opptyProdSchedNew.Frozen_Prod_Sched_Price__c = calcOpportunityProductSchedulePrice(opptyProdNew.UnitPrice, opptyProdNew.Price_Erosion_Rate__c, schedIndex);
                            schedIndex++;
                            
                            opptyProdSchedsCreated.add(opptyProdSchedNew);
                            
                            system.debug('====[Scarlett] created oppty prod scheds for re open products...');
                        }
                    }
                }
            } // re-open products
        }
    	
    	insert opptyProdSchedsCreated; 
	}
	
	private Map<Id, List<OpportunitySchedule__c>> getOpptySchedsByOpptyId(Set<Id> opptyIds){
		p('getOpptySchedsByOpptyId');
        Map<Id, List<OpportunitySchedule__c>> result = new Map<Id, List<OpportunitySchedule__c>>(); // Oppty Id -> Oppty Sched List
        
        for (OpportunitySchedule__c opptySched : new OpportunitySchedulesSelector().selectByOpptyId(opptyIds)) {
            if (result.containsKey(opptySched.Opportunity__c)) {
                result.get(opptySched.Opportunity__c).add(opptySched);
            }
            else {
                result.put(opptySched.Opportunity__c, new List<OpportunitySchedule__c>{opptySched});
            }
        }
        
        return result;
    }
    
    private void updateOpptyProdScheds(List<OpportunityLineItem> existingRecords) {
    	p('updateOpptyProdScheds');
        Set<Id> opptyProdIds = new Set<Id>();
        Set<Id> opptyIds = new Set<Id>();
        List<OpportunityProductSchedule__c> opptyProdSchedList;
        OpportunityProductSchedule__c opptyProdSchedUpdated;
        
        Decimal unitPrice;
        Decimal priceErosionRate;
        Integer schedDateIndex;
        Date productionDate;
        Date schedDate;
        Integer numberDaysBetween;
        
        List<OpportunityProductSchedule__c> opptyProdSchedsUpdated = new List<OpportunityProductSchedule__c>();
        
        for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
            opptyProdIds.add(opptyProdNew.Id);
            opptyIds.add(opptyProdNew.OpportunityId);
        }
        
        Map<Id, Opportunity> opptys = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
        Map<Id, List<OpportunityProductSchedule__c>> opptyProdSchedsByOpptyProdId = getOpptyProdSchedsByOpptyProdId(opptyIds, opptyProdIds);
        
        if (opptyProdSchedsByOpptyProdId != null) {
        	for (OpportunityLineItem opptyProdOld : existingRecords) {
        		for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
        			if (opptyProdOld.Id == opptyProdNew.Id) {
						if (opptyProdSchedsByOpptyProdId.containsKey(opptyProdNew.Id)) { // has Opportunity Product Schedule(s)
							opptyProdSchedList = new List<OpportunityProductSchedule__c>();
							opptyProdSchedList = opptyProdSchedsByOpptyProdId.get(opptyProdNew.Id);
							
							unitPrice = opptyProdNew.UnitPrice;
                            priceErosionRate = opptyProdNew.Price_Erosion_Rate__c;
                            
							if (opptyProdSchedList.size() > 0) {
								for (Integer i = 0 ; i < opptyProdSchedList.size() ; i++) {
                            		opptyProdSchedUpdated = new OpportunityProductSchedule__c(Id = opptyProdSchedList[i].Id);
                            		
                            		// Update Prod  Sched Price & Frozen Prod Sched Price of Opportunity Product Schedule
                            		if (opptyProdOld.UnitPrice != opptyProdNew.UnitPrice || opptyProdOld.Price_Erosion_Rate__c != opptyProdNew.Price_Erosion_Rate__c) {
		                                // Before DW
		                                if (opptys.get(opptyProdNew.OpportunityId).StageName != Opportunities.STAGES.get(Opportunities.Stage.COMMITMENT)) {
		                                    opptyProdSchedUpdated.Prod_Sched_Price__c = calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, i);
		                                    opptyProdSchedUpdated.Frozen_Prod_Sched_Price__c = calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, i);
		                                }
		                                else { // After DW
		                                	opptyProdSchedUpdated.Frozen_Prod_Sched_Price__c = calcOpportunityProductSchedulePrice(unitPrice, priceErosionRate, i);
		                                }
                            		}
	                                
					                // Update Share of Opportunity Product Schedule
			        				if (updateOpptyProdSchedShare(opptys.get(opptyProdNew.OpportunityId).StageName, opptyProdOld, opptyProdNew)) {
			        					opptyProdSchedUpdated.Share__c = opptyProdNew.Share__c;
			        				}
			        				
			        				// Update Frozen Share of Opportunity Product Schedule
							        if (updateOpptyProdSchedFrozenShare(opptyProdOld, opptyProdNew)) {
			                            opptyProdSchedUpdated.Frozen_Share__c = opptyProdNew.Share__c;
			                        }
			                        
			        				// update Qty per Sys of Opportunity Product Schedule
							        if (updateOpptyProdSchedQtyPerSystem(opptyProdOld, opptyProdNew)) {
			                            opptyProdSchedUpdated.Qty_Per_Sys__c = opptyProdNew.Component_Multiplier__c;
			                        } 
			        				
			        				opptyProdSchedsUpdated.add(opptyProdSchedUpdated);
								}
							}
						} // has Opportunity Product Schedule(s)
        				
        				break;
        			}
        		}
        	}
        }
        
        update opptyProdSchedsUpdated;
    }
    
    private Map<Id, List<OpportunityProductSchedule__c>> getOpptyProdSchedsByOpptyProdId(Set<Id> opptyIds, Set<Id> opptyProdIds) {
    	p('getOpptyProdSchedsByOpptyProdId');
    	// Opportunity Product Id -> (Opportunity Product Schedule)
    	Map<Id, List<OpportunityProductSchedule__c>> result = new Map<Id, List<OpportunityProductSchedule__c>>();
    	
		for (OpportunityProductSchedule__c ops : new OpportunityProductSchedulesSelector().selectByOpptyIdAndOpptyProdId(opptyIds, opptyProdIds)) {
	    	if (result.containsKey(ops.Oppty_Prod_ID_Full__c)) {
				result.get(ops.Oppty_Prod_ID_Full__c).add(ops);
		 	}
		 	else {
		 		result.put(ops.Oppty_Prod_ID_Full__c, new List<OpportunityProductSchedule__c>{ops});
		 	}
		 }
		 
		 return result;
    }
    
    private Boolean updateOpptyProdSchedShare(String stageName, OpportunityLineItem opptyProdOld, OpportunityLineItem opptyProdNew) {
    	p('updateOpptyProdSchedShare');
        Boolean result = false;
        
        if (stageName != Opportunities.STAGES.get(Opportunities.Stage.COMMITMENT)) {
            if (opptyProdOld.Share__c != opptyProdNew.Share__c) {
                result = true;
            }
        }
        
        return result;
    }
    
    private Boolean updateOpptyProdSchedFrozenShare(OpportunityLineItem opptyProdOld, OpportunityLineItem opptyProdNew) {
    	p('updateOpptyProdSchedFrozenShare');
        Boolean result = false;
        
        if (opptyProdOld.Share__c != opptyProdNew.Share__c) {
            result = true;
        }
                
        return result;
    }
    
    private Boolean updateOpptyProdSchedQtyPerSystem(OpportunityLineItem opptyProdOld, OpportunityLineItem opptyProdNew) {
    	p('updateOpptyProdSchedQtyPerSystem');
        Boolean result = false;
        
        if (opptyProdOld.Component_Multiplier__c != opptyProdNew.Component_Multiplier__c) {
            result = True;
        }
        
        return result;
    }
    
    private void checkOpptyScheds() {
    	p('checkOpptyScheds');
        Set<Id> opptyIds = getOpptyIds((List<OpportunityLineItem>)this.records);   
        
        Map<Id, Integer> opptyScheds = new Map<Id, Integer>();
        
        for (OpportunitySchedulesSelector.OpportunityScheduleValueSummary osvs : new OpportunitySchedulesSelector().selectSchedValueByOpptyIdGroupByOpptyId(opptyIds)) {
            opptyScheds.put(osvs.opptyId, osvs.totalCount);
        }  
        
        for (OpportunityLineItem oli : (List<OpportunityLineItem>)this.records) {
            if (!opptyScheds.containsKey(oli.OpportunityId)) {
                oli.addError('Please create opportunity schedules before creating an opportunity product.');
            }
        }
    }
    
    private void updateOpptyProdLastBusinessModifiedInfo() {
    	p('updateOpptyProdLastBusinessModifiedInfo');
		for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) { 
			if (Trigger.isInsert) {
	            opptyProdNew.LastUpdatedById__c = UserInfo.getUserId();
				opptyProdNew.LastUpdatedDate__c = Datetime.now();
            }
            if (Trigger.isUpdate) {
                if (!CommonUtils.isAdminOrIntegrationUser()) {
                    opptyProdNew.LastUpdatedById__c = UserInfo.getUserId();
                    opptyProdNew.LastUpdatedDate__c = Datetime.now();
                }
            }    		
		}
    }
    
    private void updateOpptyProdQty() {  
    	p('updateOpptyProdQty'); 
        Set<Id> opptyIds = getOpptyIds((List<OpportunityLineItem>)this.records);
        
        List<OpportunitySchedulesSelector.OpportunityScheduleValueSummary> schedValues = new OpportunitySchedulesSelector().selectSchedValueByOpptyIdGroupByOpptyId(opptyIds);
             
        for (OpportunityLineItem oli : (List<OpportunityLineItem>)this.records) {
        	for (OpportunitySchedulesSelector.OpportunityScheduleValueSummary osvs : schedValues) {
                if (oli.OpportunityId == osvs.opptyId) {
                    oli.Quantity = osvs.totalFrozenSchedQty;
                    oli.UnitPrice = oli.UnitPrice;  // SFDC constraint. Need to update UnitPrice and Quantity at the same time.
                    break;
                }
            }
        }               
    }
    
    private void updateOpptyProdLostCancelledInfo() {
    	p('updateOpptyProdLostCancelledInfo');
    	Map<Id, Opportunity> opptyLostCancelledInfo;
    	
    	opptyLostCancelledInfo = getOpptyLostCancelledInfo();
    	
    	for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
    		if (opptyLostCancelledInfo.get(opptyProd.OpportunityId).RecordTypeId == OpportunitiesSelector.getMnRecordTypeId() && 
    			Opportunities.LOST_STAGES.contains(opptyLostCancelledInfo.get(opptyProd.OpportunityId).StageName)) {
    			opptyProd.Prod_Lost__c = true;
    			opptyProd.Prod_Lost_Cancelled__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).StageName;
    			opptyProd.Prod_Lost_Cancelled_Date__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).Lost_Date__c;
    			opptyProd.Prod_Lost_Cancelled_Reason__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).Lost_Reason__c;
    			opptyProd.Prod_Lost_Reason__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).Lost_Description__c;
    		}
    	}
    } 
 
    private Map<Id, Opportunity> getOpptyLostCancelledInfo() {
    	p('getOpptyLostCancelledInfo');
    	Set<Id> opptyIds = new Set<Id>();
    	
    	for (OpportunityLineItem opptyProd : (List<OpportunityLineItem>)this.records) {
    		opptyIds.add(opptyProd.OpportunityId);
    	}
    	
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(new OpportunitiesSelector().selectById(opptyIds));
        
        return result;
    }
    
    private void updateOpptyProdLostCancelledInfo(List<OpportunityLineItem> existingRecords) {
    	p('updateOpptyProdLostCancelledInfo(existingRecords)');
    	for (OpportunityLineItem opptyProdOld : existingRecords) {
    		for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
    			if (opptyProdOld.Id == opptyProdNew.Id && opptyProdNew.Opportunity_Record_Type_Id__c == OpportunitiesSelector.getSfdcRecordTypeId()) {
    				// From Open to Lost/Cancelled
    				if (!LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
    					opptyProdNew.Prod_Lost_Cancelled_Date__c = date.today();
    					opptyProdNew.Prod_Lost__c = true;// Prod_Lost__c will be obsoleted in the near future
    				}
    				
    				// From Lost/Cancelled to Open
    				if (LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && !LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
    					opptyProdNew.Prod_Lost_Cancelled__c = null;
    					opptyProdNew.Prod_Lost_Cancelled_Date__c = null;
    					opptyProdNew.Prod_Lost_Reason__c = null;
    					opptyProdNew.Prod_Lost__c = false;// Prod_Lost__c will be obsoleted in the near future
    				}
    				
    				break;
    			}
    		}
    	}
    }
    
    private Set<Id> getOpptyIds(List<OpportunityLineItem> opptyLineItems) {
    	p('getOpptyIds');
        Set<Id> result = new Set<Id>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
            result.add(oli.OpportunityId);
        }
        
        return result;
    }
    
    private Boolean isOpptyProdLostCancelled(OpportunityLineItem opptyLineItem) {
    	return LOST_CANCELLED.contains(opptyLineItem.Prod_Lost_Cancelled__c);	
    }
    
    // SFDC-588
    private void updateOpptyProdHelpNeededHistory(List<OpportunityLineItem> existingRecords) {
    	p('updateOpptyProdHelpNeededHistory');
    	for (OpportunityLineItem opptyProdOld : existingRecords) {
    		for (OpportunityLineItem opptyProdNew : (List<OpportunityLineItem>)this.records) {
    			if (opptyProdOld.Id == opptyProdNew.Id) {
    				if(opptyProdOld.Help_Needed__c != opptyProdNew.Help_Needed__c && opptyProdOld.Help_Needed__c != '') {
    					opptyProdNew.Help_Needed_History__c = opptyProdOld.Help_Needed__c;
    				}
                    
                    break;
    			}
    		}
    	}
    }
}