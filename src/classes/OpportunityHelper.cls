public class OpportunityHelper { 
	public static final String OPPTY_STAGE_INITIAL_ENGAGEMENT = 'Initial Engagement';
	public static final String OPPTY_STAGE_DISCOVERY = 'Discovery';
	public static final String OPPTY_STAGE_DECISION = 'Decision';
	public static final String OPPTY_STAGE_COMMITMENT = 'Commitment';
	public static final String OPPTY_STAGE_LOST = 'Lost';
	public static final String OPPTY_STAGE_CANCELLED = 'Cancelled';
	
	private static final String TYPE_SFDC = 'SFDC_OPPTY'; 
	private static final String TYPE_MN = 'Model_N_Oppty';
	private static final String DW_AP_STATUS_OPEN = 'Open'; //Opportunity Design Win Apporval Status: Open
	private static final String DW_AP_STATUS_APPROVED = 'Approved'; //Opportunity Design Win Apporval Status: Approved
	private static final String DW_AP_STATUS_LOST = 'Lost';//Opportunity Design Win Approval Status: Lost
	private static final Set<String> OPPTY_OPEN_STAGES = new Set<String> {OPPTY_STAGE_INITIAL_ENGAGEMENT, OPPTY_STAGE_DISCOVERY, OPPTY_STAGE_DECISION};
	private static final Set<String> OPPTY_LOST_STAGES = new Set<String> {OPPTY_STAGE_LOST, OPPTY_STAGE_CANCELLED};
	private static final String LOST_STAGE = 'Lost';
	
	private static ID sfdcRecordTypeID;
	private static ID mnRecordTypeID;
	private static Map<String, FX_Rates__c> fxRates;
	private static ID integrationUserProfileID;
	private static ID systemAdminProfileID;
	
	static{
        sfdcRecordTypeID = getSfdcRecordTypeID();
        mnRecordTypeID = getMnRecordTypeID();
        systemAdminProfileID = CommonUtils.getSystemAdminProfileID();
        integrationUserProfileID = CommonUtils.getIntegrationUserProfileID();
    }
    	
	public static ID getSfdcRecordTypeID() {
		/*J
    	if (sfdcRecordTypeID == null) {
    		setOpptyRecordTypeIDs();	
    	}
    	
    	return sfdcRecordTypeID;
    	*/
    	return new OpportunitiesSelector().getRecordTypeId(OpportunitiesSelector.RecordType.SFDC_OPPTY);
    }
    
    public static ID getMnRecordTypeID() {
    	/*J
    	if (mnRecordTypeID == null) {
    		setOpptyRecordTypeIDs();	
    	}
    	
    	return mnRecordTypeID;
    	*/
    	return new OpportunitiesSelector().getRecordTypeId(OpportunitiesSelector.RecordType.MODEL_N_OPPTY);
    }
    /*J    		
	private static void setOpptyRecordTypeIDs() {
		List<RecordType> recordTypes = [SELECT Id, DeveloperName 
		                                  FROM RecordType 
		                                 WHERE IsActive = TRUE 
		                                   AND SobjectType = 'Opportunity' 
		                                   AND (DeveloperName = :TYPE_SFDC OR DeveloperName = :TYPE_MN)];
		
		for (RecordType rt : recordTypes) {
			if (rt.DeveloperName == TYPE_SFDC) {
				sfdcRecordTypeID = rt.Id;
			} else if (rt.DeveloperName == TYPE_MN) {
				mnRecordTypeID = rt.Id;
			}
		}
	}
	*/
    public static Map<String, FX_Rates__c> getFxRates() {
    	if (fxRates == null) {
    		setFxRates();	
    	}
    	
        return fxRates;
    }
    
    private static void setFxRates() {
    	fxRates = new Map<String, FX_Rates__c>();  
        
        for (FX_Rates__c fr : [SELECT Id, Currency_Code__c, Exchange_Rate__c FROM FX_Rates__c]) {
            fxRates.put(fr.Currency_Code__c, fr);
        }
    }
    
    private static Map<ID, Account> getAccountParentIdAndRegion(Set<ID> accountIDs) {
        /*
        for (Account a : [SELECT Id, ParentId, Region__c FROM Account WHERE Id in :accountIDs]) {
            result.put(a.Id, a.ParentId);
        }
        */
        
        Map<ID, Account> result = new Map<ID, Account>(
        	[SELECT Id, ParentId, Region__c 
        	 FROM Account 
        	 WHERE Id in :accountIDs]
        );
        
        return result;
    }
    
    public static void setOpportunityGeneralInfo(List<Opportunity> opptysOld, List<Opportunity> opptysNew){
    	if (!(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))) return;
    	
    	Set<ID> accountIDs = new Set<ID>();
    	Map<ID, ID> parentAccountIDs;
    	Map<ID, Account> accountParentIdAndRegion;
                
        for (Opportunity o : opptysNew) {
			accountIDs.add(o.AccountId);            
        }
        
        //parentAccountIDs = getParentAccountIDs(accountIDs);
        accountParentIdAndRegion = getAccountParentIdAndRegion(accountIDs);
        
        system.debug('===== [Scarlett] set Opportunity General Info...');
        
        if (opptysOld == null) {
        	for(Opportunity opptyNew : opptysNew) {
	        	if (opptyNew.RecordTypeId == getSfdcRecordTypeID()) {
	        		// Set Lost Date, Design Win Approval Status
                    if (OPPTY_LOST_STAGES.Contains(opptyNew.StageName)){       		
                        opptyNew.Lost_Date__c = date.today();
	        			opptyNew.Design_Win_Approval_Process__c = DW_AP_STATUS_LOST;
                    }
	        		
	        		// Set Curreny and update Locked Exchange Rate
	        		if (getFxRates().containsKey(opptyNew.CurrencyIsoCode)) {
	        			opptyNew.Currency__c = getFxRates().get(opptyNew.CurrencyIsoCode).Id;
                        opptyNew.Locked_Exchange_Rate__c = getFxRates().get(opptyNew.CurrencyIsoCode).Exchange_Rate__c;
	        		}
	        	}
	        	
	        	if (opptyNew.RecordTypeId == getMnRecordTypeID()) {
	        		// Set Curreny for MN Oppty
	        		if (getFxRates().containsKey(opptyNew.CurrencyIsoCode)) {
	        			opptyNew.Currency__c = getFxRates().get(opptyNew.CurrencyIsoCode).Id;
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
				/*J Moved to new FW
               	// Set Last Business Modified Date & Last Business Modified by
               	if (Trigger.isInsert) {
		            opptyNew.Last_Business_Modified_By_Id__c = UserInfo.getUserId();
					opptyNew.Last_Business_Modified_Date__c = Datetime.now();
	            }
	            //*/
        	}
        }
        else if (opptysNew != null) {           
	        for (Opportunity opptyNew : opptysNew) {
	        	/*J Moved to new FW 
	            // Set Last Business Modified By Id and Last Business Modified Date
	            if (Trigger.isUpdate) {
	                if (UserInfo.getProfileId() != integrationUserProfileID && UserInfo.getProfileId() != systemAdminProfileID) {
	                    opptyNew.Last_Business_Modified_By_Id__c = UserInfo.getUserId();
	                    opptyNew.Last_Business_Modified_Date__c = Datetime.now();
	                }
	            }
	            //*/
	            if (opptyNew.RecordTypeId == getSfdcRecordTypeID()) {
	            	// Set Probability to Win
					if (opptyNew.Design_Win_Approval_Process__c == DW_AP_STATUS_APPROVED) {
						opptyNew.Probability_to_Win__c = '80% - 100%';
					}
				}
				
				if (opptyNew.RecordTypeId == getMnRecordTypeID()) {
	        		// Set Curreny for MN Oppty
	        		if (getFxRates().containsKey(opptyNew.CurrencyIsoCode)) {
	        			opptyNew.Currency__c = getFxRates().get(opptyNew.CurrencyIsoCode).Id;
	        		}
	        	}
	        }
            
	        for (Opportunity opptyOld : opptysOld) {
	    		for (Opportunity opptyNew : opptysNew) {    			
	    			if (opptyOld.Id == opptyNew.Id) {    				
	    				if (opptyOld.RecordTypeId == getSfdcRecordTypeID()) {
	                        //If Opportunity is changed from Open to Lost/Cancelled
	                        if (OPPTY_OPEN_STAGES.Contains(opptyOld.StageName) && OPPTY_LOST_STAGES.Contains(opptyNew.StageName)) {
	                            //Set Lost/Cancelled Date
	                            opptyNew.Lost_Date__c = date.today();
	                            
	                            //Update Design Win Approval Status
	                            opptyNew.Design_Win_Approval_Process__c = DW_AP_STATUS_LOST;
	                        }             
	                        
	                        //If Opportunity is changed from Lost/Cancelled to Open
	                        if (OPPTY_LOST_STAGES.Contains(opptyOld.StageName) && OPPTY_OPEN_STAGES.Contains(opptyNew.StageName)) {
	                            opptyNew.Lost_Date__c = NULL;
	                            opptyNew.Lost_Description__c = NULL;
	                            opptyNew.Lost_Reason__c = NULL;
	                            
	                            opptyNew.Design_Win_Approval_Process__c = DW_AP_STATUS_OPEN;
	                        }

							// Set Curreny and update Locked Exchange Rate
					        if (getFxRates().containsKey(opptyNew.CurrencyIsoCode)) {
			                    opptyNew.Currency__c = getFxRates().get(opptyNew.CurrencyIsoCode).Id;
			                    
			                    if (opptyNew.Design_Win_Approval_Process__c == DW_AP_STATUS_OPEN) {
			                    	opptyNew.Locked_Exchange_Rate__c = getFxRates().get(opptyNew.CurrencyIsoCode).Exchange_Rate__c;
			                    }
			                }

	                        // Set Probability to Win
	                        if (opptyOld.Design_Win_Approval_Process__c != DW_AP_STATUS_APPROVED && opptyNew.Design_Win_Approval_Process__c == DW_AP_STATUS_APPROVED) {
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
	    			}
	    		}
	    	}
        }
        
        // Set Design Win Approval Status for MN Oppty
        for (Opportunity opptyNew : opptysNew) {
        	if (opptyNew.RecordTypeId == getMnRecordTypeID()) {
        		if (OPPTY_OPEN_STAGES.contains(opptyNew.StageName)) {
        			opptyNew.Design_Win_Approval_Process__c = DW_AP_STATUS_OPEN;
        		}
        		
        		if (opptyNew.StageName == OPPTY_STAGE_COMMITMENT) {
        			opptyNew.Design_Win_Approval_Process__c = DW_AP_STATUS_APPROVED;
        		}
        		
        		if(OPPTY_LOST_STAGES.contains(opptyNew.StageName)) {
        			opptyNew.Design_Win_Approval_Process__c = DW_AP_STATUS_LOST;
        		}
        	}
        }
    }

    public static void setOpportunityStarInfo(List<Opportunity> opptysNew){
    	if (!(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))) return;
        
        system.debug('===== [Scarlett] Update Star info');

    	for (Opportunity opptyNew : opptysNew) {
    		if (opptyNew.RecordTypeId == getSfdcRecordTypeID()) {
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
    			
				if (calculateDwCompletion(opptyNew) != 0) {
					opptyNew.Percentage_to_DW_Completion__c = calculateDwCompletion(opptyNew);
				}
    		}
    	}
    }
    
    public static Double calculateDwCompletion(Opportunity opptyNew){
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
    
	public static List<OpportunitySchedule__c> createOpportunitySchedulesMN(List<Opportunity> opptys) {
		List<OpportunitySchedule__c> result = new List<OpportunitySchedule__c>();
        
        final Integer QUARTERS = 4;
        final Map<Integer, Integer> QTR_MONTHS = new Map<Integer, Integer> {1 => 1, 2 => 4, 3 => 7, 4 => 10};
				 
		for (Opportunity o : opptys) {
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
    			opptySched.Opportunity__c = o.ID;
    			opptySched.Sched_Date__c = schedDate;
    			opptySched.Oppty_Sched_Qty__c = quarterQty;
    			opptySched.Frozen_Oppty_Sched_Qty__c = quarterQty;
    			opptySched.CurrencyIsoCode = o.CurrencyIsoCode;
    			result.add(opptySched);	
            }		
		}
		
		return result;	
	}
	
	public static List<OpportunitySchedule__c> updateOpportunitySchedulesMN(Map<ID, Opportunity> opptysOld, Map<ID, Opportunity> opptysNew) {
		List<OpportunitySchedule__c> result = new List<OpportunitySchedule__c>();
		
		List<OpportunitySchedule__c> opptyScheds = [ 
			select Id, Opportunity__c, Sched_Date__c, Oppty_Sched_Qty__c, Frozen_Oppty_Sched_Qty__c, CurrencyIsoCode
			  from OpportunitySchedule__c
			 where Opportunity__c in :opptysNew.keySet()
		];
		
		for (Opportunity opptyNew : opptysNew.values()) {
			if (opptysOld.get(opptyNew.Id).Production_Date__c != opptyNew.Production_Date__c ||
				opptysOld.get(opptyNew.Id).One_Year_Pieces__c != opptyNew.One_Year_Pieces__c ||
				opptysOld.get(opptyNew.Id).CurrencyIsoCode != opptyNew.CurrencyIsoCode) {
				List<OpportunitySchedule__c> oldOpptyScheds = getOpportunitySchedulesForUpdate(opptyScheds, opptyNew.Id);
				List<OpportunitySchedule__c> newOpptyScheds = createOpportunitySchedulesMN(new List<Opportunity>{opptyNew});
				
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
	
	public static List<OpportunitySchedule__c> updateOpportunitySchedulesSFDC(Map<ID, Opportunity> opptysOld, Map<ID, Opportunity> opptysNew) {
		List<OpportunitySchedule__c> result = new List<OpportunitySchedule__c>();
		
		List<OpportunitySchedule__c> opptyScheds = [ 
			select Id, Opportunity__c, CurrencyIsoCode
			  from OpportunitySchedule__c
			 where Opportunity__c in :opptysNew.keySet()
		];
		
		for (Opportunity opptyNew : opptysNew.values()) {
			if (opptysOld.get(opptyNew.Id).CurrencyIsoCode != opptyNew.CurrencyIsoCode) {
				List<OpportunitySchedule__c> opptySchedsUpdated = getOpportunitySchedulesForUpdate(opptyScheds, opptyNew.Id);
				
				for (OpportunitySchedule__c os : opptySchedsUpdated) {
					os.CurrencyIsoCode = opptyNew.CurrencyIsoCode;
					result.add(os);
				}			
			}	
		}
		
		return result;	
	}
	
	public static List<OpportunityLineItem> updateOpportunityProductLostCancelledInfo(List<Opportunity> opptysOld, List<Opportunity> opptysNew){
		List<OpportunityLineItem> opptyProds;
		List<OpportunityLineItem> result = new List<OpportunityLineItem>();
		Map<Id, List<OpportunityLineItem>> opptyAndOpptyProds = new Map<Id, List<OpportunityLineItem>>();
		
		opptyAndOpptyProds = getOpportunityProducts(opptysNew);
		
		for (Opportunity opptyOld : opptysOld) {
			for (Opportunity opptyNew : opptysNew) {
				if (opptyOld.Id == opptyNew.Id) {
					if (opptyAndOpptyProds.containsKey(opptyNew.Id)) {
						opptyProds = opptyAndOpptyProds.get(opptyNew.Id);
						
						if (opptyProds != null) {
							if (opptyNew.RecordTypeId == getSfdcRecordTypeID()) {
								if ((OPPTY_OPEN_STAGES.contains(opptyOld.StageName) || opptyOld.StageName == OPPTY_STAGE_COMMITMENT) && OPPTY_LOST_STAGES.contains(opptyNew.StageName)) {
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
										
										result.add(opptyProdUpdate);
									}										
								}
							}
							
							if (opptyNew.RecordTypeId == getMnRecordTypeID()) {
								if (OPPTY_OPEN_STAGES.contains(opptyOld.StageName) && OPPTY_LOST_STAGES.contains(opptyNew.StageName)) {
									for (OpportunityLineItem opptyProd : opptyProds) {
										OpportunityLineItem opptyProdUpdate = new OpportunityLineItem(
											Id = opptyProd.Id,
											Prod_Lost__c = true,
											Prod_Lost_Cancelled__c = opptyNew.StageName,
											Prod_Lost_Cancelled_Date__c = opptyNew.Expiration_Date__c,
											Prod_Lost_Reason__c = opptyNew.Lost_Description__c, // text area
											Prod_Lost_Cancelled_Reason__c = opptyNew.Lost_Reason__c // picklist
										);
										
										result.add(opptyProdUpdate);
									}
								}
								
								if (OPPTY_LOST_STAGES.contains(opptyOld.StageName) && OPPTY_OPEN_STAGES.contains(opptyNew.StageName)) {
									for (OpportunityLineItem opptyProd : opptyProds) {
										OpportunityLineItem opptyProdUpdate = new OpportunityLineItem(
											Id = opptyProd.Id,
											Prod_Lost__c = false,
											Prod_Lost_Cancelled__c = null,
											Prod_Lost_Cancelled_Date__c = null,
											Prod_Lost_Reason__c = null, // text area
											Prod_Lost_Cancelled_Reason__c = null // picklist
										);
										
										result.add(opptyProdUpdate);
									}
								}
							}
						}
					}
					
					break;
				}
			}
		}
		
		return result;
	} 
	
	
	public static void modelNExpiredOpportunitiesUpdate(List<SObject> scope) {
		List<Opportunity> updatedOpptys = new List<Opportunity>();
        
        for (SObject so : scope) {
       		Opportunity oppty = (Opportunity)so; 
           	oppty.StageName = 'Cancelled';
            oppty.Lost_Date__c = oppty.Expiration_Date__c;
            oppty.Lost_Reason__c = 'Expired';
            oppty.Design_Win_Approval_Process__c = 'Lost';
            updatedOpptys.add(oppty);
        }
       	       
        update updatedOpptys;
        
        Map<ID, Opportunity> opptys = new Map<ID, Opportunity>(updatedOpptys);
        
        List<OpportunityLineItem> opptyLineItems = [select Prod_Lost_Cancelled__c, Prod_Lost_Cancelled_Date__c, Opportunity.StageName, Opportunity.Expiration_Date__c from OpportunityLineItem where OpportunityId = :opptys.keySet()];
        
        for (OpportunityLineItem oli : opptyLineItems) {
        	oli.Prod_Lost_Cancelled__c = oli.Opportunity.StageName;
        	oli.Prod_Lost_Cancelled_Date__c = oli.Opportunity.Expiration_Date__c; 			
        }
        
        update opptyLineItems;
	}
	
	private static List<OpportunitySchedule__c> getOpportunitySchedulesForUpdate(List<OpportunitySchedule__c> opptyScheds, ID opptyID) {
		List<OpportunitySchedule__c> result = new List<OpportunitySchedule__c>();
		
		for (OpportunitySchedule__c os : opptyScheds) {
			if (os.Opportunity__c == opptyID) {
				result.add(os);
			}			
		} 
		
		return result;	
	}
	
	private static Map<Id, List<OpportunityLineItem>> getOpportunityProducts(List<Opportunity> opptys){
		Set<ID> opptyIDs = new Set<ID>();
		Map<Id, List<OpportunityLineItem>> result = new Map<Id, List<OpportunityLineItem>>();
		List<OpportunityLineItem> opptyProds;
		
		for (Opportunity oppty : opptys) {
			opptyIDs.add(oppty.Id);
		} 
		
		opptyProds = [
			SELECT Id, 
            		OpportunityId,
					Prod_Lost__c, 
					Prod_Lost_Cancelled__c, 
					Prod_Lost_Cancelled_Date__c, 
					Prod_Lost_Reason__c, 
					Prod_Lost_Cancelled_Reason__c 
			FROM 	OpportunityLineItem 
			WHERE 	OpportunityId in :opptyIDs
		];
				
		for (OpportunityLineItem opptyProd : opptyProds) {
			if(result.containsKey(opptyProd.OpportunityId)) {
				result.get(opptyProd.OpportunityId).add(opptyProd);
			}
			else{
				result.put(opptyProd.OpportunityId, new List<OpportunityLineItem>{opptyProd});
			}
		}
        
		return result;
	}
	
	public static Boolean isRecordTypeMN(Opportunity oppty) {
		return oppty.RecordTypeId == getMnRecordTypeID();
    }
    
    public static Boolean isTmmaOverride(Opportunity oppty) {
    	return oppty.TMMA_Override__c;
    }
    
    public static Boolean isTMMA(Opportunity oppty) {
    	return (oppty.Account.Customer_Category__c == 'Tier 4 - TMMA');
    }
    
    private static void setParentAccountIdText(Opportunity oppty, ID parentID) {
    	oppty.Parent_Account_ID_Text__c = (parentID != null) ? String.valueOf(parentID).substring(0, 15) : null;
    }
}