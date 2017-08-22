public class OpportunityScheduleHelper {
    private static final String STAGE_COMMITMENT = 'Commitment';
    private static final String TYPE_SFDC = 'SFDC_OPPTY'; 
    private static final String TYPE_MN = 'Model_N_Oppty';
    private static final Set<String> OPPTY_PROD_LOST_CANCELLED = new Set<String>{'Lost', 'Cancelled'}; 

    private static List<OpportunityProductSchedule__c> opptyProdSchedInsertList;
    private static List<OpportunityProductSchedule__c> opptyProdSchedUpdateList;
    private static List<OpportunityProductSchedule__c> opptyProdScheds;
    private static Set<ID> opptyProdIDs;
    private static Set<ID> opptyProdSchedIDs;
    
    private static ID sfdcRecordTypeID;
    private static ID mnRecordTypeID;
    
    static{
        sfdcRecordTypeID = OpportunitiesSelector.getSfdcRecordTypeId();
        mnRecordTypeID = OpportunitiesSelector.getMnRecordTypeId();
    }   
    /*J
    public static List<OpportunityLineItem> updateOpportunityProductQuantity(List<OpportunitySchedule__c> opptyScheds) {
        Set<ID> opptyIDs = new Set<ID>();
        
        for (OpportunitySchedule__c os : opptyScheds) {
            opptyIDs.add(os.Opportunity__c);
        }
        
        Map<ID, Opportunity> opptys = getOpptys(opptyIDs);
        
        for (Opportunity o : opptys.values()) {
        	if (o.StageName == STAGE_COMMITMENT) {
        		opptyIDs.remove(o.ID);	
        	}
        }
        
        if (opptyIDs.size() == 0) return new List<OpportunityLineItem>();
        
        List<AggregateResult> opptySchedQtys = getOpportunityScheduleQuantity(opptyIDs); 
             
        List<OpportunityLineItem> result = [select Id, OpportunityId, Quantity, UnitPrice from OpportunityLineItem where OpportunityId in :opptyIDs];   
        
        for (OpportunityLineItem oli : result) {
            for (AggregateResult ar : opptySchedQtys) {
                if (oli.OpportunityId == ar.get('Opportunity__c')) {
                    oli.Quantity = (Double)ar.get('totalQty');
                    oli.UnitPrice = oli.UnitPrice;  // SFDC constraint. Need to update UnitPrice and Quantity at the same time. 
                    break;
                }
            }
        }          
        
        return result;  
    }
    */
    /*J
    public static List<AggregateResult> getOpportunityScheduleQuantity(Set<ID> opptyIDs) {
    	List<AggregateResult> result = 
            [select Opportunity__c, sum(Frozen_Oppty_Sched_Qty__c) totalQty
               from OpportunitySchedule__c 
              where Opportunity__c in :opptyIDs 
             group by Opportunity__c];
             
    	return result;	
    }  
     */
    /*J
    public static void updateOpportunitySchedules(List<OpportunitySchedule__c> opptySchedsOld, List<OpportunitySchedule__c> opptySchedsNew){
        if (!(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))) return;
        
        Set<ID> opptyIDs = new Set<ID>();
        Map<ID, Opportunity> opptys = new Map<ID, Opportunity>();
        
        for (OpportunitySchedule__c opptySchedNew : opptySchedsNew) {
            opptyIDs.add(opptySchedNew.Opportunity__c);
        }
        
        opptys = getOpptys(opptyIDs);
        
        for (OpportunitySchedule__c opptySchedNew : opptySchedsNew){
        	if (Trigger.isInsert) {
                if (opptys.get(opptySchedNew.Opportunity__c).StageName != STAGE_COMMITMENT) {
        			opptySchedNew.Frozen_Oppty_Sched_Qty__c = opptySchedNew.Oppty_Sched_Qty__c;
                }
        		opptySchedNew.CurrencyIsoCode = opptys.get(opptySchedNew.Opportunity__c).CurrencyIsoCode;	
        	}
        	
        	if (Trigger.isUpdate) {
        		for (OpportunitySchedule__c opptySchedOld : opptySchedsOld){
                	if (opptySchedOld.Id == opptySchedNew.Id) {
                		if (opptys.get(opptySchedNew.Opportunity__c).StageName != STAGE_COMMITMENT) {
                        	opptySchedNew.Frozen_Oppty_Sched_Qty__c = opptySchedNew.Oppty_Sched_Qty__c;
                    	}
                	}
            	}	
        	}
            
        }
    }  
    */  
/*J
    public static void deleteOpportunityProductSchedules(List<OpportunitySchedule__c> opptyScheds){
        //Oppty Sched Id -> (Oppty Prod Sched Id -> Oppty Prod Sched)
        Map<Id, Map<Id, OpportunityProductSchedule__c>> oppySchedAndOpptyProdSched = new Map<Id, Map<Id, OpportunityProductSchedule__c>>();
        List<OpportunityProductSchedule__c> opptyProdSchedsDelete = new List<OpportunityProductSchedule__c>();
        Set<ID> opptyIDs = new Set<ID>();

        oppySchedAndOpptyProdSched = getOpptySchedAndOpptyProdSched(opptyScheds);
        
        for (OpportunitySchedule__c opptySched : opptyScheds) {
            for (ID opptyProdSchedID : opptyProdSchedIDs) {
                if (oppySchedAndOpptyProdSched.containsKey(opptySched.Id) && oppySchedAndOpptyProdSched.get(opptySched.Id).ContainsKey(opptyProdSchedID)) {
                    opptyProdSchedsDelete.add(oppySchedAndOpptyProdSched.get(opptySched.Id).get(opptyProdSchedID));
                    opptyIDs.add(oppySchedAndOpptyProdSched.get(opptySched.Id).get(opptyProdSchedID).Opportunity__c); // Add - May 3, 2017
                }
            }
        }
        
		delete opptyProdSchedsDelete;
		
		updateAllOpportunityProductSchedulesPriceAndFrozenPrice(opptyIDs);
    }
   */ 
   /*J
    public static void updateAllOpportunityProductSchedulesPriceAndFrozenPrice(Set<ID> opptyIDs){
        Map<ID, List<OpportunityLineItem>> opptyAndOpptyProd = new Map<ID, List<OpportunityLineItem>>();
        Map<ID, List<OpportunityProductSchedule__c>> opptyProdAndOpptyProdSched = new Map<ID, List<OpportunityProductSchedule__c>>();
    	List<OpportunityLineItem> opptyProdList;
    	List<OpportunityProductSchedule__c> opptyProdSchedList;
    	List<OpportunityProductSchedule__c> opptyProdSchedUpdate = new List<OpportunityProductSchedule__c>();
    	Integer schedIndex = 0;
    	
		opptyAndOpptyProd = getOpptyAndOpptyProdList(opptyIDs);
		opptyProdAndOpptyProdSched = getOpptyProdAndOpptyProdSchedList(opptyIDs, opptyAndOpptyProd);
		
		for (ID opptyID : opptyIDs) {
			if (opptyAndOpptyProd.containsKey(opptyID)) {
				opptyProdList = opptyAndOpptyProd.get(opptyID);
                
				for (OpportunityLineItem opptyProd : opptyProdList) {
					if(opptyProdAndOpptyProdSched.containsKey(opptyProd.Id)){
						opptyProdSchedList = opptyProdAndOpptyProdSched.get(opptyProd.Id);
                        
						schedIndex = 0;
						
						for (OpportunityProductSchedule__c opptyProdSched : opptyProdSchedList) {
							opptyProdSched.Prod_Sched_Price__c = OpportunityProductHelper.calcOpportunityProductSchedulePrice(opptyProd.UnitPrice, opptyProd.Price_Erosion_Rate__c, schedIndex);
							if (opptyProd.Opportunity.StageName != STAGE_COMMITMENT) {
								opptyProdSched.Frozen_Prod_Sched_Price__c = OpportunityProductHelper.calcOpportunityProductSchedulePrice(opptyProd.UnitPrice, opptyProd.Price_Erosion_Rate__c, schedIndex);
							}
							
							opptyProdSchedUpdate.add(opptyProdSched);
	
							system.debug('*****[Scarlett] Sched Index: ' + schedIndex);
							system.debug('*****[Scarlett] Opportunity Schedule: ' + opptyProdSched);
							
							schedIndex++;
						}
					}
				}
			}
		}
		
		update opptyProdSchedUpdate;
    }
    */
    /*J
    public static List<OpportunityProductSchedule__c> createOpportunityProductSchedules(List<OpportunitySchedule__c> opptySchedsNew){
        Set<ID> opptyIDs = new Set<ID>();
        Map<ID, Opportunity> opptys = new Map<ID, Opportunity>();
        Map<ID, List<OpportunitySchedule__c>> opptyAndOpptySchedList = new Map<ID, List<OpportunitySchedule__c>>();
        Map<ID, List<OpportunityLineItem>> opptyAndOpptyProdList = new Map<ID, List<OpportunityLineItem>>();
        OpportunityProductSchedule__c opptyProdSchedNew;
        List<OpportunitySchedule__c> opptySchedList;
        List<OpportunityLineItem> opptyProdList;
        List<OpportunityProductSchedule__c> result = new List<OpportunityProductSchedule__c>();
        Integer schedIndex;
        
        for(OpportunitySchedule__c opptySchedNew : opptySchedsNew){
            opptyIDs.add(opptySchedNew.Opportunity__c);
        }
    
    	opptys = getOpptys(opptyIDs);
		opptyAndOpptySchedList = getOpptyAndOpptySchedList(opptyIDs);
        opptyAndOpptyProdList = getOpptyAndOpptyProdList(opptyIDs);
        

        for (OpportunitySchedule__c opptySchedNew : opptySchedsNew) {
            if (opptyAndOpptyProdList.containsKey(opptySchedNew.Opportunity__c)) { // has Opportunity Product
                opptyProdList = opptyAndOpptyProdList.get(opptySchedNew.Opportunity__c);
                

                if (opptyAndOpptySchedList.containsKey(opptySchedNew.Opportunity__c)) { // get all scheds
                    opptySchedList = opptyAndOpptySchedList.get(opptySchedNew.Opportunity__c);

                    if (opptySchedList.size() > 0 && opptyProdList.size() > 0) {
                        for (OpportunityLineItem opptyProd : opptyProdList) {
                            if (!OPPTY_PROD_LOST_CANCELLED.contains(opptyProd.Prod_Lost_Cancelled__c)) {
                                opptyProdSchedNew = new OpportunityProductSchedule__c();
                                
                                opptyProdSchedNew.Opportunity__c = opptySchedNew.Opportunity__c;
                                opptyProdSchedNew.Sched_Date__c = opptySchedNew.Sched_Date__c;
                                opptyProdSchedNew.Oppty_Sched_Qty__c = opptySchedNew.Oppty_Sched_Qty__c;
    
                                opptyProdSchedNew.Product__c = opptyProd.Product2Id;
                                opptyProdSchedNew.Oppty_Prod_ID_Full__c = opptyProd.Id;
                                opptyProdSchedNew.Qty_Per_Sys__c = opptyProd.Component_Multiplier__c;
                                opptyProdSchedNew.Share__c = opptyProd.Share__c;
                                
                                for (Integer i = 0 ; i < opptySchedList.size() ; i++) {
                                    if (opptySchedNew.Sched_Date__c == opptySchedList[i].Sched_Date__c) {
                                        schedIndex = i;  
                                        
                                        break;
                                    }
                                }
                                
                                opptyProdSchedNew.Prod_Sched_Price__c = OpportunityProductHelper.calcOpportunityProductSchedulePrice(opptyProd.UnitPrice, opptyProd.Price_Erosion_Rate__c, schedIndex);
                                
                                opptyProdSchedNew.CurrencyIsoCode = opptys.get(opptyProd.OpportunityId).CurrencyIsoCode;
                                
                                if (opptys.get(opptySchedNew.Opportunity__c).StageName != STAGE_COMMITMENT) {
                                    opptyProdSchedNew.Frozen_Oppty_Sched_Qty__c = opptySchedNew.Oppty_Sched_Qty__c;
                                    opptyProdSchedNew.Frozen_Share__c = opptyProd.Share__c;
                                    opptyProdSchedNew.Frozen_Prod_Sched_Price__c = OpportunityProductHelper.calcOpportunityProductSchedulePrice(opptyProd.UnitPrice, opptyProd.Price_Erosion_Rate__c, schedIndex);
                                }
                                
                                result.add(opptyProdSchedNew);

                        	}
                    	}	
                	} 
            	} // get all scheds
        	}// has Opportunity Product
        }
        
        return result;
    }
    
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
    private static Map<ID, List<OpportunityLineItem>> getOpptyAndOpptyProdList(Set<ID> opptyIDs){
        Map<ID, List<OpportunityLineItem>> result = new Map<ID, List<OpportunityLineItem>>(); // Oppty Id -> Oppty Prod List
        List<OpportunityLineItem> allOpptyProds;

        allOpptyProds = [
            SELECT 	Id, Product2Id, OpportunityId, Opportunity.StageName, UnitPrice, Price_Erosion_Rate__c, Component_Multiplier__c, Share__c, Prod_Lost_Cancelled__c 
            FROM 	OpportunityLineItem 
            WHERE 	Prod_Lost_Cancelled__c not in :OPPTY_PROD_LOST_CANCELLED AND OpportunityId = :opptyIDs
        ];
        
        for (OpportunityLineItem opptyProd : allOpptyProds) {
            if (result.containsKey(opptyProd.OpportunityId)) {
                result.get(opptyProd.OpportunityId).add(opptyProd);
            }
            else {
                result.put(opptyProd.OpportunityId, new List<OpportunityLineItem>{opptyProd});
            }
        }
        
        return result;
    }
*/
//new  
/*J  
    private static Map<ID, List<OpportunityProductSchedule__c>> getOpptyProdAndOpptyProdSchedList(Set<ID> opptyIDs, Map<ID, List<OpportunityLineItem>> opptyAndOpptyProdList){
    	Set<ID> oliIDs = new Set<ID>();
    	List<OpportunityLineItem> opptyProdList;
    	List<OpportunityProductSchedule__c> opptyProdSchedList;
    	Map<ID, List<OpportunityProductSchedule__c>> result = new Map<ID, List<OpportunityProductSchedule__c>>();
    	
    	for (ID opptyID : opptyIDs) {
    		if (opptyAndOpptyProdList.containsKey(opptyID)) {
    			opptyProdList = opptyAndOpptyProdList.get(opptyID);
    			
    			for(OpportunityLineItem opptyProd : opptyProdList) {
    				oliIDs.add(opptyProd.Id);
    			}
    		}
    	}
    	
    	opptyProdSchedList = [
    		SELECT 	Id, Sched_Date__c, Oppty_Prod_ID_Full__c, Prod_Sched_Price__c, Frozen_Prod_Sched_Price__c 
    		FROM 	OpportunityProductSchedule__c 
    		WHERE 	Oppty_Prod_ID_Full__c in :oliIDs AND Opportunity__c in :opptyIDs
    		ORDER BY Sched_Date__c
    	];
    	
    	for (OpportunityProductSchedule__c opptyProdSched : opptyProdSchedList) {
    		 if(result.containsKey(opptyProdSched.Oppty_Prod_ID_Full__c)) {
    		 	result.get(opptyProdSched.Oppty_Prod_ID_Full__c).add(opptyProdSched);
    		 }
    		 else {
    		 	result.put(opptyProdSched.Oppty_Prod_ID_Full__c, new List<OpportunityProductSchedule__c>{opptyProdSched});
    		 }
    	}
    	
    	return result;
    }
    */
    /*J
    public static List<OpportunityProductSchedule__c> updateOpportunityProductSchedules(List<OpportunitySchedule__c> opptySchedsOld, List<OpportunitySchedule__c> opptySchedsNew){
    	Set<ID> opptyIDs = new Set<ID>();
        Map<ID, Opportunity> opptys = new Map<ID, Opportunity>();
        Map<Id, Map<Id, OpportunityProductSchedule__c>> oppySchedAndOpptyProdSched = new Map<Id, Map<Id, OpportunityProductSchedule__c>>();// Opporunity Schedule Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
    	OpportunityProductSchedule__c opptyProdSchedUpdated;
    	List<OpportunityProductSchedule__c> result = new List<OpportunityProductSchedule__c>();
        
        for(OpportunitySchedule__c opptySchedNew : opptySchedsNew){
            opptyIDs.add(opptySchedNew.Opportunity__c);
        }
    
    	opptys = getOpptys(opptyIDs);
    	oppySchedAndOpptyProdSched = getOpptySchedAndOpptyProdSched(opptySchedsOld);
    	
    	for (OpportunitySchedule__c opptySchedOld : opptySchedsOld) {
	    	for (OpportunitySchedule__c opptySchedNew : opptySchedsNew) {
	    		if (opptySchedOld.Id == opptySchedNew.Id) {
	    			for (ID opptyProdSchedID : opptyProdSchedIDs) {
	    				if (oppySchedAndOpptyProdSched.get(opptySchedOld.Id).containsKey(opptyProdSchedID)) {
	    					if (opptySchedOld.Oppty_Sched_Qty__c != opptySchedNew.Oppty_Sched_Qty__c || opptySchedOld.Frozen_Oppty_Sched_Qty__c != opptySchedNew.Frozen_Oppty_Sched_Qty__c || opptySchedOld.Sched_Date__c != opptySchedNew.Sched_Date__c) {
	    						opptyProdSchedUpdated = new OpportunityProductSchedule__c();
	                            opptyProdSchedUpdated.Id = opptyProdSchedID;
	                            
	                            //Before DW
	                            if(opptys.get(opptySchedNew.Opportunity__c).StageName != STAGE_COMMITMENT) {
	                                if(opptySchedOld.Oppty_Sched_Qty__c != opptySchedNew.Oppty_Sched_Qty__c) {
	                                    opptyProdSchedUpdated.Oppty_Sched_Qty__c = opptySchedNew.Oppty_Sched_Qty__c;
	                                    opptyProdSchedUpdated.Frozen_Oppty_Sched_Qty__c = opptySchedNew.Oppty_Sched_Qty__c;
	                                }
	                            }
	                            
	                            //After DW
	                            if(opptys.get(opptySchedNew.Opportunity__c).StageName == STAGE_COMMITMENT) {
	                                if(opptySchedOld.Oppty_Sched_Qty__c != opptySchedNew.Oppty_Sched_Qty__c) {
	                                    opptyProdSchedUpdated.Oppty_Sched_Qty__c = opptySchedNew.Oppty_Sched_Qty__c;
	                                }
	                                
	                                if(opptySchedOld.Frozen_Oppty_Sched_Qty__c != opptySchedNew.Frozen_Oppty_Sched_Qty__c) {
	                                    opptyProdSchedUpdated.Frozen_Oppty_Sched_Qty__c = opptySchedNew.Frozen_Oppty_Sched_Qty__c;
	                                }
	                            }
	                            
	                            if (opptySchedOld.Sched_Date__c != opptySchedNew.Sched_Date__c) {
	                            	opptyProdSchedUpdated.Sched_Date__c = opptySchedNew.Sched_Date__c;
	                            }
	                            
	                            result.add(opptyProdSchedUpdated);
	    					}
	    				}
	    			}
	    			
	    			break;
	    		}
	    	}
	    }
	    
	    return result;
    }
    */
    /*J
    private static Map<Id, Opportunity> getOpptys(Set<ID> opptyIDs){        
        Map<Id, Opportunity> result = new Map<Id, Opportunity>(
            [SELECT Id, RecordTypeId, StageName, Production_Date__c, CurrencyIsoCode
             FROM   Opportunity
             WHERE  Id in :opptyIDs]
        );
        
        return result;
    } 
    */
    /*J
    private static Map<Id, Map<Id, OpportunityProductSchedule__c>> getOpptySchedAndOpptyProdSched(List<OpportunitySchedule__c> opptyScheds){
        Set<ID> opptyIDs = new Set<ID>();
        // Opporunity Schedule Id -> (Opportunity Product Schedule Id -> Opportunity Product Schedule)
        Map<Id, Map<Id, OpportunityProductSchedule__c>> result = new Map<Id, Map<Id, OpportunityProductSchedule__c>>();
        opptyProdSchedIDs = new Set<ID>();
        
        for(OpportunitySchedule__c opptySched : opptyScheds) {
            opptyIDs.add(opptySched.Opportunity__c);
        }
        
        opptyProdScheds = [
            SELECT  Id, Opportunity__c, Oppty_Prod_ID_Full__c, Sched_Date__c
            FROM    OpportunityProductSchedule__c 
            WHERE   Opportunity__c in :opptyIDs
        ];
        
        for(OpportunitySchedule__c opptySched : opptyScheds) {
            for (OpportunityProductSchedule__c opptyProdSched : opptyProdScheds) {
                opptyProdSchedIDs.add(opptyProdSched.Id);     
                
                if(opptySched.Opportunity__c == opptyProdSched.Opportunity__c && opptySched.Sched_Date__c == opptyProdSched.Sched_Date__c){
                    if (result.containsKey(opptySched.Id)) {
                        result.get(opptySched.Id).put(opptyProdSched.Id, opptyProdSched);
                    }
                    else {
                        result.put(opptySched.Id, new Map<ID, OpportunityProductSchedule__c> {opptyProdSched.Id => opptyProdSched});
                    }
                }
            }
        }
        
        return result;
    }
    */
}