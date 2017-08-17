public class OpportunityProductHelper { 
	public static final String PROD_LOST = 'Lost';
    public static final String PROD_CANCELLED = 'Cancelled';
    
    private static final String OPPTY_LOST = 'Lost';
    private static final String OPPTY_CANCELLED = 'Cancelled';
    private static final Integer PRICE_EROSION_QUARTERS = 4;
    private static final String STAGE_COMMITMENT = 'Commitment';
    private static final String TYPE_SFDC = 'SFDC_OPPTY'; 
    private static final String TYPE_MN = 'Model_N_Oppty';
    private static final Set<String> OPPTY_PROD_LOST_CANCELLED = new Set<String>{PROD_LOST, PROD_CANCELLED};
    private static final Set<String> OPPTY_LOST_CANCELLED = new Set<String>{OpportunityHelper.OPPTY_STAGE_LOST, OpportunityHelper.OPPTY_STAGE_CANCELLED};
 
    private static List<OpportunityProductSchedule__c> opptyProdSchedUpdateList;
    private static List<OpportunityProductSchedule__c> opptyProdScheds;
    private static Set<ID> allOpptyProdSchedIDs;
    private static Set<ID> opptyProdSchedIDs;
    
    private static ID sfdcRecordTypeID;
    private static ID mnRecordTypeID;
   	private static ID integrationUserProfileID;
	private static ID systemAdminProfileID;
    
    static{
        sfdcRecordTypeID = OpportunityHelper.getSfdcRecordTypeID();
        mnRecordTypeID = OpportunityHelper.getMnRecordTypeID();
        systemAdminProfileID = CommonUtils.getSystemAdminProfileID();
        integrationUserProfileID = CommonUtils.getIntegrationUserProfileID();
    }
    /*J
    public static void checkOpportunitySchedule(List<OpportunityLineItem> opptyLineItems) {
        Set<ID> opptyIDs = getOpptyIDs(opptyLineItems);   
        
        List<AggregateResult> opptySchedCounts = 
            [select Opportunity__c, count(Id) total
               from OpportunitySchedule__c 
              where Opportunity__c in :opptyIDs 
             group by Opportunity__c];
             
        Map<Id, Integer> opptyScheds = new Map<Id, Integer>();
        
        for (AggregateResult ar : opptySchedCounts) {
            opptyScheds.put((ID)ar.get('Opportunity__c'), (Integer)ar.get('total'));    
        }  
        
        for (OpportunityLineItem oli : opptyLineItems) {
            if (!opptyScheds.containsKey(oli.OpportunityId)) {
                oli.addError('Please create opportunity schedules before creating an opportunity product.');
            }
        }
    }
    */
    /*J
    public static void setOpportunityProductQuantity(List<OpportunityLineItem> opptyLineItems) {   
        Set<Id> opptyIds = getOpptyIDs(opptyLineItems);
        
        List<OpportunitySchedulesSelector.OpportunityScheduleValueSummary> schedValues = new OpportunitySchedulesSelector().selectSchedValueByOpptyIdGroupByOpptyId(opptyIds);
             
        for (OpportunityLineItem oli : opptyLineItems) {
        	for (OpportunitySchedulesSelector.OpportunityScheduleValueSummary osvs : schedValues) {
                if (oli.OpportunityId == osvs.opptyId) {
                    oli.Quantity = osvs.totalFrozenSchedQty;
                    oli.UnitPrice = oli.UnitPrice;  // SFDC constraint. Need to update UnitPrice and Quantity at the same time.
                    break;
                }
            }
        }               
    } 
    */
    /**
     * @param schedDateIndex: 0-based list index of the schedule date
     */
    public static Decimal calcOpportunityProductSchedulePrice(Decimal unitPrice, Decimal priceErosionRate, Integer schedDateIndex) {
        // Apply price erosion rate every PRICE_EROSION_QUARTERS quarters. Use previous quarter price as base price.
        return (unitPrice * Math.pow(Double.valueOf(1 - (priceErosionRate / 100)), schedDateIndex / PRICE_EROSION_QUARTERS)).setScale(6);
    }
/*J
    public static List<OpportunityProductSchedule__c> createOpportunityProductSchedules(List<OpportunityLineItem> opptyLineItems) {
        Set<ID> opptyIDs = getOpptyIDs(opptyLineItems);
                     
        ID opptyID = null;
        List<OpportunitySchedule__c> opptyScheds = null;
        Map<ID, List<OpportunitySchedule__c>> opptySchedsMap = new Map<ID, List<OpportunitySchedule__c>>();
        
        for (OpportunitySchedule__c os : [select Opportunity__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c
                                            from OpportunitySchedule__c
                                           where Opportunity__c in :opptyIDs
                                          order by Opportunity__c, Sched_Date__c]) {
            if (opptyID != os.Opportunity__c) {
                opptyID = os.Opportunity__c;
                opptyScheds = new List<OpportunitySchedule__c>();     
            }                                   
            
            opptyScheds.add(os);
            opptySchedsMap.put(opptyID, opptyScheds);           
        }            
        
        List<OpportunityProductSchedule__c> result = new List<OpportunityProductSchedule__c>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
        	if (isOpptyProdLostCancelled(oli)) continue;
        	
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
                opptyProdSched.CurrencyIsoCode = oli.CurrencyIsoCode; //J 
                    
                result.add(opptyProdSched);
                schedDateIndex++;
            }
        }
        
        return result;
    }
*/
/*J
    public static List<OpportunityProductSchedule__c> updateOpportunityProducySchedules(List<OpportunityLineItem> opptyProdsOld, List<OpportunityLineItem> opptyProdsNew){
        Set<ID> oliIDs = new Set<ID>();
        Set<ID> opptyIDs = new Set<ID>();
        //Map<ID, Map<ID, OpportunityProductSchedule__c>> opptyProdToOpptyProdSched = new Map<Id, Map<Id, OpportunityProductSchedule__c>>();
        Map<ID, List<OpportunityProductSchedule__c>> opptyProdAndOpptyProdSchedList = new Map<ID, List<OpportunityProductSchedule__c>>();
        List<OpportunityProductSchedule__c> opptyProdSchedList;
        OpportunityProductSchedule__c opptyProdSchedUpdated;
        Map<ID, Opportunity> opptys = new Map<ID, Opportunity>();
        Decimal unitPrice;
        Decimal priceErosionRate;
        Integer schedDateIndex;
        Date productionDate;
        Date schedDate;
        Integer numberDaysBetween;
        
        opptyProdSchedUpdateList = new List<OpportunityProductSchedule__c>();
        
        for (OpportunityLineItem opptyProdNew : opptyProdsNew) {
            oliIDs.add(opptyProdNew.Id);
            opptyIDs.add(opptyProdNew.OpportunityId);
        }
        
        opptys = getOpptys(opptyIDs);
        opptyProdAndOpptyProdSchedList = getOpptyProdAndOpptyProdSchedList(opptyIDs, oliIDs);
        
        if (opptyProdAndOpptyProdSchedList != null) {
        	for (OpportunityLineItem opptyProdOld : opptyProdsOld) {
        		for (OpportunityLineItem opptyProdNew : opptyProdsNew) {
        			if (opptyProdOld.Id == opptyProdNew.Id) {
						if (opptyProdAndOpptyProdSchedList.containsKey(opptyProdNew.Id)) { // has Opportunity Product Schedule(s)
							opptyProdSchedList = new List<OpportunityProductSchedule__c>();
							opptyProdSchedList = opptyProdAndOpptyProdSchedList.get(opptyProdNew.Id);
							
							unitPrice = opptyProdNew.UnitPrice;
                            priceErosionRate = opptyProdNew.Price_Erosion_Rate__c;
                            
							if (opptyProdSchedList.size() > 0) {
								for (Integer i = 0 ; i < opptyProdSchedList.size() ; i++) {
                            		opptyProdSchedUpdated = new OpportunityProductSchedule__c(Id = opptyProdSchedList[i].Id);
                            		
                            		// Update Prod  Sched Price & Frozen Prod Sched Price of Opportunity Product Schedule
                            		if (opptyProdOld.UnitPrice != opptyProdNew.UnitPrice || opptyProdOld.Price_Erosion_Rate__c != opptyProdNew.Price_Erosion_Rate__c) {
		                                // Before DW
		                                if (opptys.get(opptyProdNew.OpportunityId).StageName != STAGE_COMMITMENT) {
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
							        if(updateOpptyProdSchedFrozenShare(opptyProdOld, opptyProdNew)) {
			                            opptyProdSchedUpdated.Frozen_Share__c = opptyProdNew.Share__c;
			                        }
			                        
			        				// update Qty per Sys of Opportunity Product Schedule
							        if(updateOpptyProdSchedQtyPerSystem(opptyProdOld, opptyProdNew)) {
			                            opptyProdSchedUpdated.Qty_Per_Sys__c = opptyProdNew.Component_Multiplier__c;
			                        } 
			        				
			        				opptyProdSchedUpdateList.add(opptyProdSchedUpdated);
								}
							}
						} // has Opportunity Product Schedule(s)
        				
        				break;
        			}
        		}
        	}
        }
        
        return opptyProdSchedUpdateList;
    }
    */
    /*J
    public static List<OpportunityProductSchedule__c> deleteOpportunityProductScheds(List<OpportunityLineItem> opptyProds){
        Set<ID> oilIDs = new Set<ID>();
        Map<Id, Map<Id, OpportunityProductSchedule__c>> opptyProdAndOpptyProdSched; // Opporunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        List<OpportunityProductSchedule__c> opptyProdSchedsDelete;
        
        for (OpportunityLineItem opptyProd : opptyProds) {
            oilIDs.add(opptyProd.Id);
        }
        
        opptyProdAndOpptyProdSched = getOpptyProdAndOpptyProdSched(opptyProds, oilIDs);
        
        opptyProdSchedsDelete = new List<OpportunityProductSchedule__c>();
        
        for (OpportunityLineItem opptyProd : opptyProds) {
            for (ID opptyProdSchedID : opptyProdSchedIDs) {
                if (opptyProdAndOpptyProdSched.get(opptyProd.Id).ContainsKey(opptyProdSchedID)) {
                    opptyProdSchedsDelete.add(opptyProdAndOpptyProdSched.get(opptyProd.Id).get(opptyProdSchedID));

                }
            }
        }
        
        return opptyProdSchedsDelete;
    }
    */
    /*J
    public static void updateOpportunityProductLostCancelledInformation(List<OpportunityLineItem> opptyProdsOld, List<OpportunityLineItem> opptyProdsNew){
    	for (OpportunityLineItem opptyProdOld : opptyProdsOld) {
    		for (OpportunityLineItem opptyProdNew : opptyProdsNew) {
    			if (opptyProdOld.Id == opptyProdNew.Id) {
    				// From Open to Lost/Cancelled
    				if (!OPPTY_PROD_LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && OPPTY_PROD_LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
    					opptyProdNew.Prod_Lost_Cancelled_Date__c = date.today();
    					opptyProdNew.Prod_Lost__c = true;// Prod_Lost__c will be obsoleted in the near future
    				}
    				
    				// From Lost/Cancelled to Open
    				if (OPPTY_PROD_LOST_CANCELLED.contains(opptyProdOld.Prod_Lost_Cancelled__c) && !OPPTY_PROD_LOST_CANCELLED.contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
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
    */
    /*J
    public static void setOpportunityProductLastBusinessModifiedInfo(List<OpportunityLineItem> opptyProdsNew){
		for (OpportunityLineItem opptyProdNew : opptyProdsNew) { 
			if (Trigger.isInsert) {
	            opptyProdNew.LastUpdatedById__c = UserInfo.getUserId();
				opptyProdNew.LastUpdatedDate__c = Datetime.now();
            }
            if (Trigger.isUpdate) {
                if (UserInfo.getProfileId() != integrationUserProfileID && UserInfo.getProfileId() != systemAdminProfileID) {
                    opptyProdNew.LastUpdatedById__c = UserInfo.getUserId();
                    opptyProdNew.LastUpdatedDate__c = Datetime.now();
                }
            }    		
		}
    }
    */
    /*J
    public static List<OpportunityProductSchedule__c> deleteLostCancelledOpportunityProductSchedules(List<OpportunityLineItem> opptyProdsOld, List<OpportunityLineItem> opptyProdsNew){
    	List<OpportunityProductSchedule__c> opptyProdSchedsDelete;      
    	Set<ID> oilIDs = new Set<ID>();
        Map<Id, Map<Id, OpportunityProductSchedule__c>> opptyProdAndOpptyProdSched; // Opporunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)

		List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>(); 

    	for (OpportunityLineItem opptyProdOld : opptyProdsOld) {
    		for (OpportunityLineItem opptyProdNew : opptyProdsNew) {
                if(opptyProdOld.Id == opptyProdNew.Id) {
                    if (!OPPTY_PROD_LOST_CANCELLED.Contains(opptyProdOld.Prod_Lost_Cancelled__c) && OPPTY_PROD_LOST_CANCELLED.Contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        oilIDs.add(opptyProdNew.Id);
                        opptyProds.add(opptyProdNew);
                        system.debug('=====[Scarlett] Oppty Prod is changed from Open to Lost/Cancelled...');
                    }
                    
                    break;
                }
    		}
    	}    	
    	
    	opptyProdAndOpptyProdSched = getOpptyProdAndOpptyProdSched(opptyProds, oilIDs);
        opptyProdSchedsDelete = new List<OpportunityProductSchedule__c>();

    	for (OpportunityLineItem opptyProdOld : opptyProdsOld) {
    		for (OpportunityLineItem opptyProdNew : opptyProdsNew) {
                if(opptyProdOld.Id == opptyProdNew.Id) {
                    if (!OPPTY_PROD_LOST_CANCELLED.Contains(opptyProdOld.Prod_Lost_Cancelled__c) && OPPTY_PROD_LOST_CANCELLED.Contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        for (ID opptyProdSchedID : opptyProdSchedIDs) {
                            if (opptyProdAndOpptyProdSched.get(opptyProdNew.Id).ContainsKey(opptyProdSchedID)) {
                                opptyProdSchedsDelete.add(opptyProdAndOpptyProdSched.get(opptyProdNew.Id).get(opptyProdSchedID));
                                system.debug('=====[Scarlett] delete oppty prod scheds when product is changed to Lost...');
                            }
                        }
                    }
                    
                    break;
                }
            }
        }

    	return opptyProdSchedsDelete;
    }
    */
    /*J
    public static List<OpportunityProductSchedule__c> createReOpenOpportunityProductSchedules(List<OpportunityLineItem> opptyProdsOld, List<OpportunityLineItem> opptyProdsNew){
    	Set<ID> opptyIDs = new Set<ID>();
    	Set<ID> oilIDs = new Set<ID>();
        OpportunityProductSchedule__c opptyProdSchedNew;
    	List<OpportunityProductSchedule__c> opptyProdSchedsInsert;
    	List<OpportunitySchedule__c> opptyScheds;
		Map<ID, List<OpportunitySchedule__c>> opptyAndOpptySchedList = new Map<ID, List<OpportunitySchedule__c>>();
    	
    	for (OpportunityLineItem opptyProdOld : opptyProdsOld) {
    		for (OpportunityLineItem opptyProdNew : opptyProdsNew) {
                if (opptyProdOld.Id == opptyProdNew.Id) {
                    if (OPPTY_PROD_LOST_CANCELLED.Contains(opptyProdOld.Prod_Lost_Cancelled__c) && !OPPTY_PROD_LOST_CANCELLED.Contains(opptyProdNew.Prod_Lost_Cancelled__c)) {
                        oilIDs.add(opptyProdNew.Id);
                        opptyIDs.add(opptyProdNew.OpportunityId);
                        system.debug('=====[Scarlett] create oppty prod scheds for re open oppty products...');
                    }
                    
                    break;
                }
    		}
    	} 
    	
    	opptyProdSchedsInsert = new List<OpportunityProductSchedule__c>();
    	opptyAndOpptySchedList = getOpptyAndOpptySchedList(opptyIDs);

        for (OpportunityLineItem opptyProdNew : opptyProdsNew) {
            if (oilIDs.contains(opptyProdNew.Id)) { // re-open products
                Integer schedIndex = 0;
    
                if (opptyAndOpptySchedList.containsKey(opptyProdNew.OpportunityId)) { // has Oppty Sched
                    opptyScheds = opptyAndOpptySchedList.get(opptyProdNew.OpportunityId);
                    
                    if (opptyScheds.size() > 0) {
                        for (OpportunitySchedule__c opptySched : opptyScheds) {
                            opptyProdSchedNew = new OpportunityProductSchedule__c();
                            
                            opptyProdSchedNew.Opportunity__c = opptyProdNew.OpportunityId;
                            
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
                            
                            opptyProdSchedsInsert.add(opptyProdSchedNew);
                            
                            system.debug('====[Scarlett] created oppty prod scheds for re open products...');
                        }
                    }
                }
            } // re-open products
        }
    	
    	return opptyProdSchedsInsert;

    }
    */
    /*J
    public static void setOpportunityProductLostCancelledInfo(List<OpportunityLineItem> opptyProdsNew){
    	Map<ID, Opportunity> opptyLostCancelledInfo;
    	
    	opptyLostCancelledInfo = getOpptyLostCancelledInfo(opptyProdsNew);
    	
    	for (OpportunityLineItem opptyProd : opptyProdsNew) {
    		if (opptyLostCancelledInfo.get(opptyProd.OpportunityId).RecordTypeId == OpportunityHelper.getMnRecordTypeID() && 
    			OPPTY_LOST_CANCELLED.contains(opptyLostCancelledInfo.get(opptyProd.OpportunityId).StageName)) {
    			opptyProd.Prod_Lost__c = true;
    			opptyProd.Prod_Lost_Cancelled__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).StageName;
    			opptyProd.Prod_Lost_Cancelled_Date__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).Expiration_Date__c;
    			opptyProd.Prod_Lost_Reason__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).Lost_Description__c;
    			opptyProd.Prod_Lost_Cancelled_Reason__c = opptyLostCancelledInfo.get(opptyProd.OpportunityId).Lost_Reason__c;
    		}
    	}
    }
    */
    public static Set<ID> getOpptyIDs(List<OpportunityLineItem> opptyLineItems) {
        Set<ID> result = new Set<ID>();
        
        for (OpportunityLineItem oli : opptyLineItems) {
            result.add(oli.OpportunityId);
        }
        
        return result;
    }
 
    public static Map<Id, Opportunity> getOpptys(Set<ID> opptyIDs){        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id, RecordTypeId, StageName, Production_Date__c
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    } 
    /*J
    public static Map<ID, List<OpportunityProductSchedule__c>> getOpptyProdAndOpptyProdSchedList(Set<ID> opptyIDs, Set<ID> opptyProdIDs){
    	// Opportunity Product Id -> (Opportunity Product Schedule)
    	Map<ID, List<OpportunityProductSchedule__c>> result = new Map<ID, List<OpportunityProductSchedule__c>>();
    	
    	 opptyProdScheds = [
    	 	SELECT 	Id, Oppty_Prod_ID_Full__c, Sched_Date__c 
    	 	FROM 	OpportunityProductSchedule__c 
    	 	WHERE 	Opportunity__c in :opptyIDs
    	 	AND 	Oppty_Prod_ID_Full__c in :opptyProdIDs
    	 	ORDER BY Sched_Date__c
    	 ];
    	 
    	 for (OpportunityProductSchedule__c ops : opptyProdScheds) {
            if (result.containsKey(ops.Oppty_Prod_ID_Full__c)) {
    	 		result.get(ops.Oppty_Prod_ID_Full__c).add(ops);
    	 	}
    	 	else {
    	 		result.put(ops.Oppty_Prod_ID_Full__c, new List<OpportunityProductSchedule__c>{ops});
    	 	}
    	 }
    	 
    	 return result;
    }
    */
    public static Boolean isOpptyProdLostCancelled(OpportunityLineItem opptyLineItem) {
    	return OPPTY_PROD_LOST_CANCELLED.contains(opptyLineItem.Prod_Lost_Cancelled__c);	
    }
    
    private static Map<ID, Map<ID, OpportunityProductSchedule__c>> getOpptyProdScheds(Set<ID> opptyIDs, Set<ID> opptyProdIDs){
        // Opportunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        Map<ID, Map<ID, OpportunityProductSchedule__c>> result = new Map<Id, Map<ID, OpportunityProductSchedule__c>>();
        
        opptyProdScheds = [SELECT Id, Oppty_Prod_ID_Full__c, Share__c, Frozen_Share__c, Sched_Date__c FROM OpportunityProductSchedule__c WHERE Opportunity__c in :opptyIDs and Oppty_Prod_ID_Full__c in :opptyProdIDs];
        
        allOpptyProdSchedIDs = new Set<ID>();
        
        for(OpportunityProductSchedule__c ops : opptyProdScheds){
            allOpptyProdSchedIDs.add(ops.Id);
            
            if(result.containsKey(ops.Oppty_Prod_ID_Full__c)) {
                result.get(ops.Oppty_Prod_ID_Full__c).put(ops.Id, ops);
            }
            else {
                result.put(ops.Oppty_Prod_ID_Full__c, new Map<Id, OpportunityProductSchedule__c> {ops.Id => ops});
            }                
        }
        
        return result;
    }
     /*J   
    private static Boolean updateOpptyProdSchedShare(String stageName, 
                                                     OpportunityLineItem opptyProdOld, OpportunityLineItem opptyProdNew){
        Boolean result = false;
        
        if(stageName != STAGE_COMMITMENT) {
            if (opptyProdOld.Share__c != opptyProdNew.Share__c) {
                result = true;
            }
        }
        
        return result;
    }
    */
    /*J
    private static Boolean updateOpptyProdSchedFrozenShare(OpportunityLineItem opptyProdOld, OpportunityLineItem opptyProdNew){
        Boolean result = false;
        
        if(opptyProdOld.Share__c != opptyProdNew.Share__c) {
            result = True;
        }
                
        return result;
    }
    */
    /*J
    private static Boolean updateOpptyProdSchedQtyPerSystem(OpportunityLineItem opptyProdOld, OpportunityLineItem opptyProdNew){
        Boolean result = false;
        
        if(opptyProdOld.Component_Multiplier__c != opptyProdNew.Component_Multiplier__c) {
            result = True;
        }
        
        return result;
    }
    */
    /*J
    private static Map<Id, Map<Id, OpportunityProductSchedule__c>> getOpptyProdAndOpptyProdSched(List<OpportunityLineItem> opptyProds, Set<ID> oliIDs){
        // Opporunity Product Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        Map<Id, Map<Id, OpportunityProductSchedule__c>> result = new Map<Id, Map<Id, OpportunityProductSchedule__c>>();
        
        opptyProdSchedIDs = new Set<ID>();
        
        Set<ID> opptyIDs = getOpptyIDs(opptyProds);

        for (OpportunityProductSchedule__c opptyProdSched : [SELECT Id, Oppty_Prod_ID_Full__c, Sched_Date__c, Prod_Sched_Price__c, Frozen_Prod_Sched_Price__c 
                                                             FROM OpportunityProductSchedule__c WHERE Opportunity__c in :opptyIDs and Oppty_Prod_ID_Full__c in : oliIDs ORDER BY Sched_Date__c]) {
            opptyProdSchedIDs.add(opptyProdSched.Id);                                                     
                                                                 
            if (result.containsKey(opptyProdSched.Oppty_Prod_ID_Full__c)) {
                result.get(opptyProdSched.Oppty_Prod_ID_Full__c).put(opptyProdSched.Id, opptyProdSched);
            }
            else {
                result.put(opptyProdSched.Oppty_Prod_ID_Full__c, new Map<ID, OpportunityProductSchedule__c> {opptyProdSched.Id => opptyProdSched});
            }
        }
        
        return result;
    }
*/
/*J
    private static Map<ID, List<OpportunitySchedule__c>> getOpptyAndOpptySchedList(Set<ID> opptyIDs){
        Map<ID, List<OpportunitySchedule__c>> result = new Map<ID, List<OpportunitySchedule__c>>(); // Oppty Id -> Oppty Sched List
        List<OpportunitySchedule__c> allOpptyScheds;

        allOpptyScheds = [
            SELECT 	Id, Opportunity__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c
            FROM 	OpportunitySchedule__c 
            WHERE 	Opportunity__c in :opptyIDs
            ORDER BY Sched_Date__c
        ];
        
        for (OpportunitySchedule__c opptySched : allOpptyScheds) {
            if (result.containsKey(opptySched.Opportunity__c)) {
                result.get(opptySched.Opportunity__c).add(opptySched);
            }
            else {
                result.put(opptySched.Opportunity__c, new List<OpportunitySchedule__c>{opptySched});
            }
        }
        
        return result;
    }
   */ 
   /*J
    private static Map<ID, Opportunity> getOpptyLostCancelledInfo(List<OpportunityLineItem> opptyProds){
    	Set<ID> opptyIDs = new Set<ID>();
    	
    	for (OpportunityLineItem opptyProd : opptyProds) {
    		opptyIDs.add(opptyProd.OpportunityId);
    	}
    	
    	Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id,
            		RecordTypeId,
             		StageName,
             		Expiration_Date__c,
             		Lost_Description__c,
             		Lost_Reason__c
             FROM	Opportunity
             WHERE	Id in :opptyIDs]
        );
        
        return result;
    }
    */
}