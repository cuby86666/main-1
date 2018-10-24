public with sharing class OpportunityScheduleMasterController {
	
	public class OpportunityWrapper {
		@AuraEnabled public String id { get; set; }
		@AuraEnabled public String name { get; set; }
		@AuraEnabled public String acctName { get; set; }
		@AuraEnabled public String stage { get; set; }
		@AuraEnabled public Datetime createdDate { get; set; }
		@AuraEnabled public Date closeDate { get; set; }
		@AuraEnabled public Date prodDate { get; set; }
		@AuraEnabled public Double ltValue { get; set; }
		@AuraEnabled public String blConcat { get; set; }	
	} 

	@AuraEnabled
    public static List<OpportunityScheduleMasterController.OpportunityWrapper> getOpportunities(Id progId) {
    	p('getOpportunities');
    	List<OpportunityScheduleMasterController.OpportunityWrapper> result = new List<OpportunityWrapper>();
    	
    	List<Opportunity> oppties = new OpportunitiesSelector().selectByProgramIdAndOwnerIdWithAccountAndOwner(new Set<Id> {progId}, new Set<Id> {UserInfo.getUserId()});
    	
    	for (Opportunity o : oppties) {
    		OpportunityWrapper ow = new OpportunityWrapper();
    		ow.id = o.Id;
    		ow.name = o.Name;
    		ow.acctName = o.Account.Name;
    		ow.stage = o.StageName;
    		ow.createdDate = o.CreatedDate;
    		ow.closeDate = o.CloseDate;
    		ow.prodDate = o.Production_Date__c;
    		ow.ltValue = o.LT_Value_USD__c;
    		ow.blConcat = o.BL__c;
    		result.add(ow);	
    	}
    	
    	return result;	
    }
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    /*******OpptySchedule Component Init Method Call: To check if Oppty Scheduled and return the Oppty Record Value******/	
  @AuraEnabled	
    public static OpportunitySchedulingWrapper.OpportunityScheduleExists getOpptyScheduleInfoClass (Id opportunityId){	
        OpportunitySchedulingWrapper.OpportunityScheduleExists opptyAlExists = new OpportunitySchedulingWrapper.OpportunityScheduleExists();	
        List<OpportunitySchedule__c> lstExistingOpptySchld = new  List<OpportunitySchedule__c>();	
        lstExistingOpptySchld= [Select Id, Name, Comment__c, Frozen_Oppty_Sched_Qty__c, Opportunity__c, Oppty_Sched_Qty__c, 	
                                       Sched_Date__c From OpportunitySchedule__c where Opportunity__c=:opportunityId Order By Sched_Date__c];	
        	
        if(lstExistingOpptySchld.size() != 0){	
           opptyAlExists.isOpptySchedule = true;	
        }	
        Opportunity oppty= [SELECT Id, Name,StageName,CloseDate, Production_Date__c,LT_Value_USD__c, Claim_Value_USD__c,AccountId, Account.Customer_Category__c,TMMA_Override__c,RecordType.DeveloperName,Design_Win_Approval_Process__c,CreatedDate, Program__c FROM Opportunity WHERE Id =:opportunityId];	
        
        opptyAlExists.oppValues = oppty;	
        String theme = UserInfo.getUiThemeDisplayed();	
        opptyAlExists.userTheme = theme;	
        return opptyAlExists;	
    }	
	
   /*******************Oppty Schedule Edit : To display the Oppty Schedule display values on Init Call, On Change ProdQuarter*******/ 	
   	
    @AuraEnabled	
    public static List<OpportunitySchedulingWrapper.OpportunityScheduleView> getOpportunityScheduleDisplayValues(Id opportunityId, Integer qtr, Integer qty, String ProdDate,String ExpClsDate, string opptyschldWrapRec, Boolean flagDirect) {        	
        List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstWrapperOpptySchedule = new List<OpportunitySchedulingWrapper.OpportunityScheduleView>();	
        
        if (opptyschldWrapRec != null) {	
        	List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstWrapperOpptyScheduleDeserailise = (List<OpportunitySchedulingWrapper.OpportunityScheduleView>)System.JSON.deserialize(opptyschldWrapRec,List<OpportunitySchedulingWrapper.OpportunityScheduleView>.class);	
         	lstWrapperOpptySchedule = lstWrapperOpptyScheduleDeserailise;	
        }
        	
        Date tempProdDate;	
        Date tempcloseDate;	
        List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstOpptySchedDisplayValues = new List<OpportunitySchedulingWrapper.OpportunityScheduleView>();        	
        List<OpportunitySchedule__c> lstExistingOpptySchld = new List<OpportunitySchedule__c>();	
        
        lstExistingOpptySchld= [select Id, Name, Comment__c, Frozen_Oppty_Sched_Qty__c, Opportunity__c, Oppty_Sched_Qty__c, Sched_Date__c 
                                  from OpportunitySchedule__c 
                                 where Opportunity__c = :opportunityId 
                                order by Sched_Date__c];	
        
        Opportunity oppty= [select Id, Name,CloseDate, Production_Date__c, LT_Value_USD__c, Claim_Value_USD__c, StageName,Design_Win_Approval_Process__c, AccountId, Account.Customer_Category__c, TMMA_Override__c, RecordType.DeveloperName, CreatedDate, Program__c 
        					  from Opportunity 
        					 where Id = :opportunityId];
        					 
		// Execute if No Oppty Schedules already exist: Directing from step1:Create to step2:Edit	
        if ((lstWrapperOpptySchedule == null || lstWrapperOpptySchedule.isEmpty()) && flagDirect == true) {	
        	tempProdDate= Date.valueOf(ProdDate);	
        	tempcloseDate= Date.valueOf(ExpClsDate);	
        	oppty.CloseDate =tempcloseDate;	
        	oppty.Production_Date__c = tempProdDate;	
        	Integer year= tempProdDate.year();	
        	Integer month= tempProdDate.month();	
        	Integer qttr = quarterReturn(month); // Call to return Quarter for the month	
        	Integer quatr = integer.valueof(qtr);	
	
        	if (integer.valueof(qtr) != 0) {	
           		for (Integer i = 1; i <= integer.valueof(qtr); i++) {                	
            		OpportunitySchedulingWrapper.OpportunityScheduleView positionRecord = new OpportunitySchedulingWrapper.OpportunityScheduleView();	
            		positionRecord.quantities = qty;	
            		positionRecord.comment ='';	
            		positionRecord.oppValues = oppty;   	
            		
            		if (qttr > 4) {	
             			year++;	
             			qttr = 1;	
            		}	
            
            		positionRecord.quarterdate = string.valueOf(year) + 'Q'+ string.valueOf(qttr);	
            		qttr++;	
            		lstOpptySchedDisplayValues.add(positionRecord);	
          		}            	
       		}	
            	
      		/***Default Save Oppty Schedule Records while Navigating from step1:Create to Step2: Edit***/	
       		String opptySchedWrapper = JSON.serialize(lstOpptySchedDisplayValues);	
       		OpportunitySchedulingWrapper.OpportunityScheduleExists opptyExitsSaved = new OpportunitySchedulingWrapper.OpportunityScheduleExists();	
       		opptyExitsSaved = saveOpptySchedule(opportunityId,opptySchedWrapper,oppty);	
       
       		for (OpportunitySchedulingWrapper.OpportunityScheduleView opptyScheviewRec : lstOpptySchedDisplayValues) {	
           		opptyScheviewRec.oppValues = opptyExitsSaved.oppValues;	
       		}	
      	}	
        	
        // Execute if Already Oppty Schedules Exist: Directing to Oppty Sched Edit	
        if (flagDirect == false && (lstWrapperOpptySchedule == null || lstWrapperOpptySchedule.isEmpty())) {	
            for (OpportunitySchedule__c oppSch : lstExistingOpptySchld) {	
            	OpportunitySchedulingWrapper.OpportunityScheduleView existingOpptySchld = new OpportunitySchedulingWrapper.OpportunityScheduleView();	
                existingOpptySchld.oppValues =  oppty;	
                existingOpptySchld.comment = oppSch.Comment__c;	
                
                if (oppSch.Comment__c == null) {	
                	existingOpptySchld.comment='';   	
                }	
                
                existingOpptySchld.quantities = Integer.valueOf(oppSch.Oppty_Sched_Qty__c);        	
                Date tempQtrSchldDate= oppSch.Sched_Date__c;	
                Integer year= tempQtrSchldDate.year();	
                Integer month= tempQtrSchldDate.month();	
                Integer quartr=quarterReturn(month);// Call to return Quarter for the month	
                existingOpptySchld.quarterdate = string.valueOf(year)+'Q'+ string.valueOf(quartr) ;	
                lstOpptySchedDisplayValues.add(existingOpptySchld);	
            }    	
        }	
        	
        // Execute if there is a Production Date change then display the shifted Quater in Oppty Sched Display	
        if (lstWrapperOpptySchedule != null && lstWrapperOpptySchedule.size() != 0) {	
        	if (ProdDate == null) {	
           		tempProdDate = oppty.Production_Date__c;	
           	} else {	
            	tempProdDate= Date.valueOf(ProdDate);  	
           	}
           		
            Integer year= tempProdDate.year();	
            Integer month= tempProdDate.month();	
            Integer qttr= quarterReturn(month); // Call to return Quarter for the month;	
       	
        	for (OpportunitySchedulingWrapper.OpportunityScheduleView dispTab: lstWrapperOpptySchedule) {	
            	OpportunitySchedulingWrapper.OpportunityScheduleView positionRecord = new OpportunitySchedulingWrapper.OpportunityScheduleView();	
            	positionRecord.quantities = dispTab.quantities;	
            	positionRecord.comment = dispTab.comment; //J Copy comment too	
            	positionRecord.oppValues =  oppty;   	
            
            	if (qttr > 4) {	
             		year++;	
             		qttr =1;	
            	}	
            
            	positionRecord.quarterdate = string.valueOf(year)+'Q'+ string.valueOf(qttr) ;	
            	qttr++;	
            	lstOpptySchedDisplayValues.add(positionRecord);                       	
           	}	
        }	
        
        return lstOpptySchedDisplayValues;	
    }    	
	
    /********************************************Logic for Editing / Creating Oppty Schedule records along with Oppty Update********************/	
    @AuraEnabled	
       public static OpportunitySchedulingWrapper.OpportunityScheduleExists saveOpptySchedule(Id opportunityId, string opptyschldWrapRec, Opportunity oppPassed) {	
        OpportunitySchedulingWrapper.OpportunityScheduleExists opptyDisplay = new  OpportunitySchedulingWrapper.OpportunityScheduleExists();	
        Integer sumQty =0;	
        List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstWrapperOpptySchedule = (List<OpportunitySchedulingWrapper.OpportunityScheduleView>)System.JSON.deserialize(opptyschldWrapRec,List<OpportunitySchedulingWrapper.OpportunityScheduleView>.class);	
        Opportunity oppsave = new Opportunity();	
        List<OpportunitySchedule__c> lstOpptySchld = new  List<OpportunitySchedule__c>(); //New Oppty Sched Insert List	
        List<OpportunitySchedule__c> lstUpdateOpptySchld = new  List<OpportunitySchedule__c>(); //Update Existing Oppty Sched List	
        List<OpportunitySchedule__c> lstdelOpptySchld = new  List<OpportunitySchedule__c>(); // Delete Existing Oppty Sched List	
        	
        List<OpportunitySchedule__c> lstExistingOpptySchld = new  List<OpportunitySchedule__c>();	
        lstExistingOpptySchld= [Select Id, Name, Comment__c, Frozen_Oppty_Sched_Qty__c, Opportunity__c, Oppty_Sched_Qty__c, Sched_Date__c From OpportunitySchedule__c where Opportunity__c = :opportunityId Order By Sched_Date__c];	
	
        Map<Date,OpportunitySchedule__c> mapExistSchld = new Map<Date,OpportunitySchedule__c>();	
        Map<Date,OpportunitySchedulingWrapper.OpportunityScheduleView> mapWrapSchld = new Map<Date,OpportunitySchedulingWrapper.OpportunityScheduleView>();	
        
        for (OpportunitySchedule__c oppSch: lstExistingOpptySchld){	
            mapExistSchld.put(oppSch.Sched_Date__c, oppSch);    	
        }	
           	
        Date OpptySchldDateCheckMap;  	
        String schldDate;	
	
        if (lstWrapperOpptySchedule != null && lstWrapperOpptySchedule.size() > 0) {	
            for (Integer i = 0; i < lstWrapperOpptySchedule.size(); i++) {
                if (Integer.valueOf(lstWrapperOpptySchedule[i].quantities) != null) {
                	sumQty += Integer.valueOf(lstWrapperOpptySchedule[i].quantities);
                }
                
                String quarterdate = lstWrapperOpptySchedule[i].quarterdate;                	
                schldDate = getScheduledate(quarterdate);	
                OpptySchldDateCheckMap = Date.valueOf(schldDate);	
                
                if (i == 0) {	
                	OpptySchldDateCheckMap = oppPassed.Production_Date__c;	
                }
                                	
                mapWrapSchld.put(OpptySchldDateCheckMap, lstWrapperOpptySchedule[i]);	
                	
                //Logic to Update Existing Oppty Sched 	
                if (mapExistSchld.containsKey(OpptySchldDateCheckMap)) {	
                	OpportunitySchedule__c oppSchldFrmMap = mapExistSchld.get(OpptySchldDateCheckMap);                    	
                   
                	if (oppSchldFrmMap.Comment__c == lstWrapperOpptySchedule[i].comment && oppSchldFrmMap.Oppty_Sched_Qty__c == lstWrapperOpptySchedule[i].quantities) {	
                    	System.debug('Skip to Next iteration if no Change is there in the display'); 	
                    	continue;                          	
                	}	
                    	
                	if (oppSchldFrmMap.Comment__c != lstWrapperOpptySchedule[i].comment || oppSchldFrmMap.Oppty_Sched_Qty__c != lstWrapperOpptySchedule[i].quantities) {                       	
                    	oppSchldFrmMap.Comment__c = lstWrapperOpptySchedule[i].comment;	
                    	oppSchldFrmMap.Oppty_Sched_Qty__c = lstWrapperOpptySchedule[i].quantities;	
                    	lstUpdateOpptySchld.add(oppSchldFrmMap);	
                    	System.debug('Skip to Next iteration if Change is there in the display after upadting it'); 	
                    	continue;                          	
                	}	
                }  	
                    	
                //Logic if Schedules not contain in Existing then its is New Oppty Sched Insert	
                if (!mapExistSchld.containsKey(OpptySchldDateCheckMap)) {               	
                	OpportunitySchedule__c oppSchld = new OpportunitySchedule__c();	
                	oppSchld.Opportunity__c = opportunityId;	
                	oppSchld.Comment__c = lstWrapperOpptySchedule[i].comment;	
                	oppSchld.Oppty_Sched_Qty__c = lstWrapperOpptySchedule[i].quantities;                	
                	oppSchld.Sched_Date__c = Date.valueOf(schldDate); 	
                 
                	if (i == 0) {	
                		oppSchld.Sched_Date__c = oppPassed.Production_Date__c;	
                	}                	
                 
                	lstOpptySchld.add(oppSchld);                   	
                }                                	
            }	
            
            lstOpptySchld.addAll(lstUpdateOpptySchld);	
            	
            //Logic to Delete Existing Oppty Sched if not in the dispaly	
            List<Id> lstDelOpptySchedId = new List<Id>();	
            
            for (OpportunitySchedule__c opptySchedExistRec : lstExistingOpptySchld) {	
            	if (!mapWrapSchld.containsKey(opptySchedExistRec.Sched_Date__c)) {	
                	lstdelOpptySchld.add(opptySchedExistRec);	
                	lstDelOpptySchedId.add(opptySchedExistRec.Id);	
            	}	
            }
            
            Boolean opptyUpdated = false;
            
            if (sumOpptySchedQtyCheck(opptyschldWrapRec) != true) {  
            	Savepoint sp = Database.setSavepoint();
            	    
            	try {                	
            		opptyUpdated = updateOpptyValue(opportunityId, oppPassed.CloseDate, oppPassed.Production_Date__c); //call for updating the Opportunity record with newly modified Expected Closed Dtae and Production date.	
            		upsert lstOpptySchld;
            		delete lstdelOpptySchld;
            		
            		oppsave= [SELECT Id, Name, CloseDate, Production_Date__c, LT_Value_USD__c, Claim_Value_USD__c ,StageName,AccountId, Account.Customer_Category__c, TMMA_Override__c, RecordType.DeveloperName, Design_Win_Approval_Process__c, CreatedDate, Program__c FROM Opportunity WHERE Id = :opportunityId]; 	
	            	oppsave.CloseDate = oppPassed.CloseDate;	
	            	oppsave.Production_Date__c = oppPassed.Production_Date__c;	
	            	opptyDisplay.oppValues = oppsave;	
	            	opptyDisplay.isOpptySchedule = true;
	            	
	            	if (opptyUpdated) {
	            		oppsave.Bypass_Validation_Sched_Start_Date__c = false;
	            		update oppsave;	
	            	}
            		
            		updateOpptiesScheds(oppPassed);
            	} catch (Exception e) {	
            		Database.rollback(sp);
            		throw e;	
            	} 
            }	
        }           	
        
        return opptyDisplay;	
    }  	
        	
 /************************************************  Display a row with the content values on Click of Add Quarter Button****************/   	
   @AuraEnabled	
    public static List<OpportunitySchedulingWrapper.OpportunityScheduleView> getQuarterAddedToOpptySched(string opptyschldWrapRec, String ProdDate){	
     List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstWrapperOpptySchedule = (List<OpportunitySchedulingWrapper.OpportunityScheduleView>)System.JSON.deserialize(opptyschldWrapRec,List<OpportunitySchedulingWrapper.OpportunityScheduleView>.class);	
     List<OpportunitySchedulingWrapper.OpportunityScheduleView> newLstWrapperOpptySchedule = new List<OpportunitySchedulingWrapper.OpportunityScheduleView>();	
     OpportunitySchedulingWrapper.OpportunityScheduleView newQuarterDisplayRec= new OpportunitySchedulingWrapper.OpportunityScheduleView();	
	
     if(lstWrapperOpptySchedule.size()!=0 && lstWrapperOpptySchedule != null){	
        newLstWrapperOpptySchedule.addAll(lstWrapperOpptySchedule); 	
        Integer sizeOfExistingOpptyScheduleRec = lstWrapperOpptySchedule.size();	
        OpportunitySchedulingWrapper.OpportunityScheduleView prevQuatrDisplayRec= new OpportunitySchedulingWrapper.OpportunityScheduleView();	
        prevQuatrDisplayRec= lstWrapperOpptySchedule[sizeOfExistingOpptyScheduleRec-1];  	
        newQuarterDisplayRec.quantities = prevQuatrDisplayRec.quantities;	
        newQuarterDisplayRec.comment ='';
        newQuarterDisplayRec.oppValues =  prevQuatrDisplayRec.oppValues;
    // quarter date setting	
        String quarterdate = prevQuatrDisplayRec.quarterdate;	
        String subStrYr= quarterdate.Substring(0,4);	
        String subStrqtr= string.valueOf(quarterdate.right(1));	
        Integer Schldyear = Integer.valueOf(subStrYr);	
        Integer Schldqtr = Integer.valueOf(subStrqtr);	
        if(Schldqtr == 4){	
           Schldyear++;	
           Schldqtr =1;	
        }	
        else{	
             Schldqtr ++;	
        }	
        newQuarterDisplayRec.quarterdate = string.valueOf(Schldyear)+'Q'+ string.valueOf(Schldqtr) ;	
     }	
        	
     if(!(lstWrapperOpptySchedule.size()!=0 && lstWrapperOpptySchedule != null)){	
        Date tempProdDate= Date.valueOf(ProdDate);	
        Integer year= tempProdDate.year();	
        Integer month= tempProdDate.month();	
        Integer qttr = quarterReturn(month);	
        newQuarterDisplayRec.quarterdate = string.valueOf(year)+'Q'+ string.valueOf(qttr) ;	
        newQuarterDisplayRec.quantities = 0;	
        newQuarterDisplayRec.comment ='';
      }        	
    newLstWrapperOpptySchedule.add(newQuarterDisplayRec);       	
    return newLstWrapperOpptySchedule;	
  }  	
	
   	
    /******************************* Validation quantity check***********************************/	
     @AuraEnabled	
    public static Boolean sumOpptySchedQtyCheck(string opptyschldWrapRec){	
     Boolean isSumQtyZero = false;	
     List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstWrapperOpptySchedule = (List<OpportunitySchedulingWrapper.OpportunityScheduleView>)System.JSON.deserialize(opptyschldWrapRec,List<OpportunitySchedulingWrapper.OpportunityScheduleView>.class);	
     if(lstWrapperOpptySchedule.size() !=0 && lstWrapperOpptySchedule != null){	
        Integer sumQty =0;	
        for(OpportunitySchedulingWrapper.OpportunityScheduleView dispTab :lstWrapperOpptySchedule){
            if(Integer.valueOf(dispTab.quantities)!= null){
              sumQty+= Integer.valueOf(dispTab.quantities);
            }
        }
         system.debug('StageName'+lstWrapperOpptySchedule[0].oppValues.StageName);
         system.debug('sumQty'+sumQty);
        
        if((sumQty ==0 || sumQty== null) && lstWrapperOpptySchedule[0].oppValues.StageName != 'Commitment'){	
            isSumQtyZero = true;            
        }	
     }
        system.debug('isSumQtyZero'+isSumQtyZero);
     return isSumQtyZero;	
    }	
    	
    /********************************************Hide The alert if the prod date change is in same quarter****************/	
    @AuraEnabled	
    public static boolean checkIfSameQuarterProdDateChange(String NewProdDate, String OldProdDate){	
     boolean isSameQuarter = true;
        system.debug('NewProdDate'+NewProdDate);
        system.debug('OldProdDate'+OldProdDate);
     if(NewProdDate!= null && OldProdDate != null){	
        Date NewProdDateValue= Date.valueOf(NewProdDate);	
        Integer NewProdMonth= NewProdDateValue.month();	
        Integer NewProdYear= NewProdDateValue.year();	
        Date OldProdDateValue= Date.valueOf(OldProdDate);	
        Integer OldProdMonth= OldProdDateValue.month();	
        Integer OldProdYear= OldProdDateValue.year();	
        Integer newProdDateQuarter;	
        Integer oldProdDateQuarter;	
        newProdDateQuarter =  quarterReturn(NewProdMonth);	
        oldProdDateQuarter =  quarterReturn(OldProdMonth);	
        if(newProdDateQuarter == oldProdDateQuarter && NewProdYear == OldProdYear){            	
          isSameQuarter = true;  	
        }	
        else{	
           isSameQuarter = false;  	
        }	
      }	
      return isSameQuarter;	
    }	
    	
    	
    /********** General Method to return the Quarter of the production date********************/	
    @AuraEnabled	
    public static Integer quarterReturn(Integer ProdMonth){        	
        Integer qttr;	
        qttr= ((ProdMonth - 1) / 3) + 1;
        return qttr;	
    }	
    	
    /********** General Method to return the Scheduled date********************/	
    @AuraEnabled	
    public static string getScheduledate(String quarterdate){	
       String subStrYr= quarterdate.Substring(0,4);	
       String subStrqtr= string.valueOf(quarterdate.right(1));	
       Integer Schldyear = Integer.valueOf(subStrYr);	
       Integer Schldqtr = Integer.valueOf(subStrqtr);	
       String qtrMon;	
        If(Schldqtr == 1)	
         qtrMon = '01';	
        If(Schldqtr == 2)	
         qtrMon = '04';	
        If(Schldqtr == 3)	
          qtrMon = '07';	
        If(Schldqtr == 4)	
          qtrMon = '10';	
        String schldDate = subStrYr+'-'+qtrMon+'-01';	
        return schldDate;	
    }	
 	
    /******Method Called for Updating the Opportunity Records with the new Expected Closed Date and Production Date*******/	
    public static Boolean updateOpptyValue(Id opportunityId, Date ExpClsDate, Date NewProdDate) { 
    	system.debug('opportunityId called' + opportunityId);
    	Boolean flagIsChanged = false;
    	
    	Opportunity oppsave= [SELECT Id, Name, CloseDate, Production_Date__c, LT_Value_USD__c, Claim_Value_USD__c ,StageName, AccountId, Account.Customer_Category__c, TMMA_Override__c, RecordType.DeveloperName, Design_Win_Approval_Process__c, CreatedDate FROM Opportunity WHERE Id = :opportunityId]; 	
        oppsave.Bypass_Validation_Sched_Start_Date__c = false;
        	
    	if (((oppsave.CloseDate != ExpClsDate && ExpClsDate != null) || (oppsave.Production_Date__c != NewProdDate && NewProdDate != null)) && oppsave.StageName != 'Commitment') {
        	oppsave.CloseDate = ExpClsDate;	
        	oppsave.Production_Date__c = NewProdDate;
        	oppsave.Bypass_Validation_Sched_Start_Date__c = true;
        	flagIsChanged = true;   
    	}
      	
    	if (oppsave.RecordType.DeveloperName == 'Model_N_Oppty' && oppsave.Account.Customer_Category__c == 'Tier 4 - TMMA') {	
			oppsave.TMMA_Override__c = true;
        	flagIsChanged = true;
      	}  
      
    	if (flagIsChanged) {
        	update oppsave;	
    	}
    	
    	return flagIsChanged;
    }
    
    @TestVisible
    private static void updateOpptiesScheds(Opportunity opptyMaster) {
    	p('updateOpptiesScheds');
    	Map<Id, Opportunity> oppties = new Map<Id, Opportunity>(new OpportunitiesSelector().selectByProgramIdAndOwnerIdWithAccountAndOwner(new Set<Id> {opptyMaster.Program__c}, new Set<Id> {UserInfo.getUserId()})); 
    	Map<Id, Opportunity> opptiesUpdated = new Map<Id, Opportunity>(oppties);
    	
    	opptiesUpdated.remove(opptyMaster.Id);
    	
    	for (Opportunity o : opptiesUpdated.values()) {
    		o.CloseDate = opptyMaster.CloseDate;
    		o.Production_Date__c = opptyMaster.Production_Date__c; 
    		o.Bypass_Validation_Sched_Start_Date__c = true;  
    		
    		if (OpportunityService.isMnRecordType(o)) {
    			o.TMMA_Override__c = true;	
    		}
    	}
    	
    	Map<Id, List<OpportunitySchedule__c>> opptySchedsByOpptyId = new OpportunitySchedulesSelector().selectByOpptyIdGroupByOpptyId(oppties.keySet());
    	Map<Id, List<OpportunitySchedule__c>> opptySchedsByOpptyIdUpdated = new Map<Id, List<OpportunitySchedule__c>>(opptySchedsByOpptyId);
    	
    	List<OpportunitySchedule__c> opptyMasterScheds = opptySchedsByOpptyId.get(opptyMaster.Id);
    	
    	opptySchedsByOpptyIdUpdated.remove(opptyMaster.Id); 
    	
    	List<OpportunitySchedule__c> opptySchedsDeleted = new List<OpportunitySchedule__c>();
    	List<OpportunitySchedule__c> opptySchedsCreated = new List<OpportunitySchedule__c>();
    	
    	for (Id oid : opptySchedsByOpptyIdUpdated.keySet()) {
    		opptySchedsDeleted.addAll(opptySchedsByOpptyIdUpdated.get(oid));
    		
    		for (OpportunitySchedule__c os : opptyMasterScheds) {
    			OpportunitySchedule__c opptySched = new OpportunitySchedule__c();
    			
    			opptySched.Opportunity__c = oid;
    			opptySched.Sched_Date__c = os.Sched_Date__c;
    			opptySched.Oppty_Sched_Qty__c = os.Oppty_Sched_Qty__c;
    			opptySched.Frozen_Oppty_Sched_Qty__c = os.Frozen_Oppty_Sched_Qty__c;
    			opptySched.Comment__c = os.Comment__c;
    			opptySched.CurrencyIsoCode = opptiesUpdated.get(oid).CurrencyIsoCode;
    			
    			opptySchedsCreated.add(opptySched);	
    		}
    	}

		
    	try {
    		update opptiesUpdated.values();
    		delete opptySchedsDeleted;
    		insert opptySchedsCreated;
    	} catch (Exception e) {
    		throw e;	
    	} 
    	
    	for (Opportunity o : opptiesUpdated.values()) {
			o.Bypass_Validation_Sched_Start_Date__c = false;
		}
		
		update opptiesUpdated.values(); 	
    }
    
    private static void p(String msg) {
		CommonUtils.p(OpportunityScheduleMasterController.class, '//-c', msg);
	}	
    	
}