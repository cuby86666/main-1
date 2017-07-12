/**	
 * This  class will have the functionality written for the Opportunity Scheduling 	
   and Production Management related operations.	
 * It will be invoked by the action happening on the 'opportunityScheduleAction' lightning component.	
------------------------------------------------------------------------------------	
 * Created By   : Venkateshwar G	
 * Created Date : MAR 09,2017	
 * Description  : This class will have the functionality written for the Opportunity Scheduling 	
                  and Production Management related operations.	
------------------------------------------------------------------------------------              	
------------------------------------------------------------------------------------	
 * Edited By    : Venkateshwar G	
 * Created Date : MAY 24,2017	
 * Description  : Modified the Controller to set TMMA Override flag to true if the Quantity or Share values have been updated for the Model N Oppty.
                  Also to bypass the Oppty Sched Quantity and Share % validations in
                  Oppty Schedule Page and Production Management respectively.	
------------------------------------------------------------------------------------ 
------------------------------------------------------------------------------------	
 * Edited By    : Venkateshwar G	
 * Created Date : MAY 31,2017	
 * Description  : Modified the Controller to set the handel the exceptions and capture the message and display in front end.	
------------------------------------------------------------------------------------ 	
------------------------------------------------------------------------------------	
 * Edited By    : Venkateshwar G	
 * Created Date : JUN 28,2017	
 * Description  : Modified the Controller to throw the exceptions and to avoid saving of abnormal Oppty Sched.	
------------------------------------------------------------------------------------ 
*/		
public with sharing class OpportunityScheduleController {	
	
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
        Opportunity oppty= [SELECT Id, Name,StageName,CloseDate, Production_Date__c,LT_Value_USD__c, Claim_Value_USD__c,AccountId, Account.Customer_Category__c,TMMA_Override__c,RecordType.DeveloperName,Design_Win_Approval_Process__c,CreatedDate FROM Opportunity WHERE Id =:opportunityId];	
        opptyAlExists.oppValues = oppty;	
        return opptyAlExists;	
    }	
	
   /*******************Oppty Schedule Edit : To display the Oppty Schedule display values on Init Call, On Change ProdQuarter*******/ 	
   	
    @AuraEnabled	
    public static List<OpportunitySchedulingWrapper.OpportunityScheduleView> getOpportunityScheduleDisplayValues(Id opportunityId, Integer qtr, Integer qty, String ProdDate,String ExpClsDate, string opptyschldWrapRec, Boolean flagDirect) {        	
        List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstWrapperOpptySchedule = new  List<OpportunitySchedulingWrapper.OpportunityScheduleView>();	
        if(opptyschldWrapRec != null){	
         List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstWrapperOpptyScheduleDeserailise = (List<OpportunitySchedulingWrapper.OpportunityScheduleView>)System.JSON.deserialize(opptyschldWrapRec,List<OpportunitySchedulingWrapper.OpportunityScheduleView>.class);	
         lstWrapperOpptySchedule = lstWrapperOpptyScheduleDeserailise;	
        }	
        Date tempProdDate;	
        Date tempcloseDate;	
        List<OpportunitySchedulingWrapper.OpportunityScheduleView> lstOpptySchedDisplayValues = new List<OpportunitySchedulingWrapper.OpportunityScheduleView>();        	
        List<OpportunitySchedule__c> lstExistingOpptySchld = new  List<OpportunitySchedule__c>();	
        lstExistingOpptySchld= [Select Id, Name, Comment__c, Frozen_Oppty_Sched_Qty__c, Opportunity__c, Oppty_Sched_Qty__c, 	
                                       Sched_Date__c From OpportunitySchedule__c where Opportunity__c=:opportunityId Order By Sched_Date__c];	
        Opportunity oppty= [SELECT Id, Name,CloseDate, Production_Date__c, LT_Value_USD__c, Claim_Value_USD__c, StageName,Design_Win_Approval_Process__c,AccountId,Account.Customer_Category__c, TMMA_Override__c,RecordType.DeveloperName, CreatedDate FROM Opportunity WHERE Id =:opportunityId];        	
	
        // Execute if No Oppty Schedules already exist: Directing from step1:Create to step2:Edit	
        if((lstWrapperOpptySchedule == null || lstWrapperOpptySchedule.isEmpty()) && flagDirect==true){	
        tempProdDate= Date.valueOf(ProdDate);	
        tempcloseDate= Date.valueOf(ExpClsDate);	
        oppty.CloseDate =tempcloseDate;	
        oppty.Production_Date__c = tempProdDate;	
        Integer year= tempProdDate.year();	
        Integer month= tempProdDate.month();	
        Integer qttr = quarterReturn(month); // Call to return Quarter for the month	
        Integer quatr = integer.valueof(qtr);	
	
        if(integer.valueof(qtr) != 0){	
           for(Integer i=1; i<=integer.valueof(qtr);i++){                	
            OpportunitySchedulingWrapper.OpportunityScheduleView positionRecord = new OpportunitySchedulingWrapper.OpportunityScheduleView();	
            positionRecord.quantities = qty;	
            positionRecord.comment ='';	
            positionRecord.oppValues =  oppty;   	
            IF(qttr >4){	
             year++;	
             qttr =1;	
            }	
            positionRecord.quarterdate = string.valueOf(year)+'Q'+ string.valueOf(qttr) ;	
            qttr++;	
            lstOpptySchedDisplayValues.add(positionRecord);	
          }            	
       }	
            	
      /***Default Save Oppty Schedule Records while Navigating from step1:Create to Step2: Edit***/	
       String opptySchedWrapper = JSON.serialize(lstOpptySchedDisplayValues);	
       OpportunitySchedulingWrapper.OpportunityScheduleExists opptyExitsSaved = new OpportunitySchedulingWrapper.OpportunityScheduleExists();	
       opptyExitsSaved = saveOpptySchedule(opportunityId,opptySchedWrapper,oppty);	
       for(OpportunitySchedulingWrapper.OpportunityScheduleView opptyScheviewRec: lstOpptySchedDisplayValues){	
           opptyScheviewRec.oppValues = opptyExitsSaved.oppValues;	
       }	
      }	
        	
        // Execute if Already Oppty Schedules Exist: Directing to Oppty Sched Edit	
        if(flagDirect==false && (lstWrapperOpptySchedule == null || lstWrapperOpptySchedule.isEmpty())){	
            for (OpportunitySchedule__c oppSch :lstExistingOpptySchld){	
                 OpportunitySchedulingWrapper.OpportunityScheduleView existingOpptySchld = new OpportunitySchedulingWrapper.OpportunityScheduleView();	
                 existingOpptySchld.oppValues =  oppty;	
                 existingOpptySchld.comment = oppSch.Comment__c;	
                 if(oppSch.Comment__c == null){	
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
        if(lstWrapperOpptySchedule != null && lstWrapperOpptySchedule.size() != 0){	
           if(ProdDate ==null){	
             tempProdDate = oppty.Production_Date__c;	
           }	
           else{	
            tempProdDate= Date.valueOf(ProdDate);  	
           }	
            Integer year= tempProdDate.year();	
            Integer month= tempProdDate.month();	
            Integer qttr= quarterReturn(month); // Call to return Quarter for the month;	
       	
         for(OpportunitySchedulingWrapper.OpportunityScheduleView dispTab: lstWrapperOpptySchedule){	
            OpportunitySchedulingWrapper.OpportunityScheduleView positionRecord = new OpportunitySchedulingWrapper.OpportunityScheduleView();	
            positionRecord.quantities = dispTab.quantities;	
            positionRecord.comment ='';	
            positionRecord.oppValues =  oppty;   	
            if(qttr >4){	
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
        lstExistingOpptySchld= [Select Id, Name, Comment__c, Frozen_Oppty_Sched_Qty__c, Opportunity__c, Oppty_Sched_Qty__c, 	
                                       Sched_Date__c From OpportunitySchedule__c where Opportunity__c=:opportunityId Order By Sched_Date__c];	
	
        Map<Date,OpportunitySchedule__c> mapExistSchld = new Map<Date,OpportunitySchedule__c>();	
        Map<Date,OpportunitySchedulingWrapper.OpportunityScheduleView> mapWrapSchld = new Map<Date,OpportunitySchedulingWrapper.OpportunityScheduleView>();	
        for(OpportunitySchedule__c oppSch: lstExistingOpptySchld){	
            mapExistSchld.put(oppSch.Sched_Date__c, oppSch);    	
        }	
           	
        Date OpptySchldDateCheckMap;  	
        String schldDate;	
	
        if(lstWrapperOpptySchedule != null && lstWrapperOpptySchedule.size()>0){	
            for(Integer i=0; i<lstWrapperOpptySchedule.size();i++){
                if(Integer.valueOf(lstWrapperOpptySchedule[i].quantities) !=null){
                sumQty+= Integer.valueOf(lstWrapperOpptySchedule[i].quantities);
                }
                String quarterdate = lstWrapperOpptySchedule[i].quarterdate;                	
                schldDate = getScheduledate(quarterdate);	
                OpptySchldDateCheckMap = Date.valueOf(schldDate);	
                if(i==0){	
                 OpptySchldDateCheckMap = oppPassed.Production_Date__c;	
                }                	
                mapWrapSchld.put(OpptySchldDateCheckMap,lstWrapperOpptySchedule[i]);	
                	
                //Logic to Update Existing Oppty Sched 	
                if(mapExistSchld.containsKey(OpptySchldDateCheckMap))	
                {	
                   OpportunitySchedule__c oppSchldFrmMap =  mapExistSchld.get(OpptySchldDateCheckMap) ;                    	
                   if(oppSchldFrmMap.Comment__c == lstWrapperOpptySchedule[i].comment && oppSchldFrmMap.Oppty_Sched_Qty__c == lstWrapperOpptySchedule[i].quantities){	
                      System.debug('Skip to Next iteration if no Change is there in the display'); 	
                      continue;                          	
                   }	
                    	
                   if(oppSchldFrmMap.Comment__c != lstWrapperOpptySchedule[i].comment || oppSchldFrmMap.Oppty_Sched_Qty__c != lstWrapperOpptySchedule[i].quantities){                       	
                      oppSchldFrmMap.Comment__c = lstWrapperOpptySchedule[i].comment;	
                      oppSchldFrmMap.Oppty_Sched_Qty__c = lstWrapperOpptySchedule[i].quantities;	
                      lstUpdateOpptySchld.add(oppSchldFrmMap);	
                      System.debug('Skip to Next iteration if Change is there in the display after upadting it'); 	
                      continue;                          	
                   }	
                   	
                }  	
                    	
                //Logic if Schedules not contain in Existing then its is New Oppty Sched Insert	
                if(!mapExistSchld.containsKey(OpptySchldDateCheckMap))	
                {               	
                 OpportunitySchedule__c oppSchld = new OpportunitySchedule__c();	
                 oppSchld.Opportunity__c = opportunityId;	
                 oppSchld.Comment__c = lstWrapperOpptySchedule[i].comment;	
                 oppSchld.Oppty_Sched_Qty__c = lstWrapperOpptySchedule[i].quantities;                	
                 oppSchld.Sched_Date__c = Date.valueOf(schldDate); 	
                 if(i==0){	
                   oppSchld.Sched_Date__c = oppPassed.Production_Date__c;	
                 }                	
                 lstOpptySchld.add(oppSchld);                   	
                }                                	
            }	
            lstOpptySchld.addAll(lstUpdateOpptySchld);	
            	
            //Logic to Delete Existing Oppty Sched if not in the dispaly	
            List<Id> lstDelOpptySchedId = new List<Id>();	
            for(OpportunitySchedule__c opptySchedExistRec : lstExistingOpptySchld){	
                 if(!mapWrapSchld.containsKey(opptySchedExistRec.Sched_Date__c)){	
                     lstdelOpptySchld.add(opptySchedExistRec);	
                     lstDelOpptySchedId.add(opptySchedExistRec.Id);	
                 }	
            }	
            if(sumOpptySchedQtyCheck(opptyschldWrapRec)!= true)	
            {   
              // DML operations executed in try catch block  
              try{                	
                  updateOpptyValue(opportunityId,oppPassed.CloseDate,oppPassed.Production_Date__c); //call for updating the Opportunity record with newly modified Expected Closed Dtae and Production date.	
                  upsert lstOpptySchld;
                  delete lstdelOpptySchld;
              }	
              // If Exception found throw the Error to Front End user  
              catch(Exception e)	
              {	
               throw e;	
              }	          		
            oppsave= [SELECT Id, Name,CloseDate, Production_Date__c,LT_Value_USD__c, Claim_Value_USD__c ,StageName,AccountId, Account.Customer_Category__c,TMMA_Override__c,RecordType.DeveloperName,Design_Win_Approval_Process__c,CreatedDate FROM Opportunity WHERE Id =:opportunityId]; 	
            oppsave.CloseDate = oppPassed.CloseDate;	
            oppsave.Production_Date__c = oppPassed.Production_Date__c;	
            opptyDisplay.oppValues =oppsave;	
            opptyDisplay.isOpptySchedule = true;	
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
    	
    /********************************************** Reestablish Function in Opportunity Schedule Edit Display: Deletes the entrire Oppty Scheduled records upon confirmation except the 1st Records Quantity is set to 1 to have qty>0 **********************************/	
    @AuraEnabled	
    public static void reEstablishOpptySchedules(Id opportunityId){	
        List<OpportunitySchedule__c> lstExistingOpptySchld = new  List<OpportunitySchedule__c>();	
        List<OpportunitySchedule__c> lstDelExistingOpptySchld = new  List<OpportunitySchedule__c>();	
        if(opportunityId != null){	
          lstExistingOpptySchld= [Select Id, Name, Comment__c, Frozen_Oppty_Sched_Qty__c, Opportunity__c, Oppty_Sched_Qty__c, 	
                                       Sched_Date__c From OpportunitySchedule__c where Opportunity__c=:opportunityId Order By Sched_Date__c]; 	
          for(Integer i=1;i<lstExistingOpptySchld.size();i++ ){	
                lstDelExistingOpptySchld.add(lstExistingOpptySchld[i]);                	
          }	
        }	
        	
        lstExistingOpptySchld[0].Oppty_Sched_Qty__c =1;	
        update lstExistingOpptySchld[0];	
        delete lstDelExistingOpptySchld;   	
        updateOpptyValue(opportunityId,null,null); //call for updating the Opportunity TMMA Override record if TMMA Oppty	
    }	
    	
    /********************************************Hide The alert if the prod date change is in same quarter****************/	
    @AuraEnabled	
    public static boolean checkIfSameQuarterProdDateChange(String NewProdDate, String OldProdDate){	
     boolean isSameQuarter = true;
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
 	
    /*****Oppty Prod Sched:Init Call*****/	
    @AuraEnabled	
    public static OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView getOpptyLineItemValuesClass (Id opportunityId) {    	
    OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView oppInitdta = new OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView();	
          	
          Opportunity oppDisp= [SELECT Id, Name,StageName, CloseDate, Production_Date__c,LT_Value_USD__c, Claim_Value_USD__c,AccountId, Account.Customer_Category__c,TMMA_Override__c,RecordType.DeveloperName,Design_Win_Approval_Process__c,CreatedDate FROM Opportunity WHERE Id =:opportunityId];	
          List<OpportunityLineItem> oppLineItm= [SELECT Id, Name, Price_Erosion_Rate__c, Product2.Name,Product2Id, Share__c, Component_Multiplier__c, Prod_Lost_Cancelled__c, CreatedDate FROM OpportunityLineItem WHERE OpportunityId =:opportunityId And (Prod_Lost_Cancelled__c !='Lost' And Prod_Lost_Cancelled__c !='Cancelled')];	
          List<String> lstOpptyProdName = new List<String>();	
          List<OpportunitySchedulingWrapper.OpptyProdIdName> lstOpptyProdIdNameClass = new List<OpportunitySchedulingWrapper.OpptyProdIdName>();	
          List<Id> lstIdOpptyProdName = new List<String>();	
          for(OpportunityLineItem oppProd : oppLineItm){	
             lstOpptyProdName.add(oppProd.Product2.Name); 	
             lstIdOpptyProdName.add(oppProd.Product2Id);	
             OpportunitySchedulingWrapper.OpptyProdIdName opptyProdIdRec = new OpportunitySchedulingWrapper.OpptyProdIdName();	
             opptyProdIdRec.opptyProdId = oppProd.Product2Id;	
             opptyProdIdRec.opptyProdName = oppProd.Product2.Name;	
             lstOpptyProdIdNameClass.add(opptyProdIdRec); 	
          }	
        	
        List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> lstDispInitDta = new List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>();	
        lstDispInitDta= getOpptyProdSchedDisplayClass(opportunityId,lstOpptyProdIdNameClass[0].opptyProdId); 	
        oppInitdta.lstOpptyLineItemName = lstOpptyProdName;	
        oppInitdta.lstOpptyProdIdName = lstOpptyProdIdNameClass;	
        oppInitdta.lstopptyProdSchedDispTable = lstDispInitDta;	
        oppInitdta.oppValues = oppDisp;	
        return oppInitdta;	
    }	
    	
    /***** Call to fetch the Oppty Prod Sched Display value*****/	
    @AuraEnabled	
       public static List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> getOpptyProdSchedDisplayClass(Id opportunityId, String OpptyLineItemName) {            	
        Opportunity oppDisp= [SELECT Id, Name,StageName, CloseDate, Production_Date__c,LT_Value_USD__c, Claim_Value_USD__c,AccountId, Account.Customer_Category__c,	
                                        TMMA_Override__c,RecordType.DeveloperName,Design_Win_Approval_Process__c,CreatedDate FROM Opportunity WHERE Id =:opportunityId];	
        List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> lstOpptyProdSched = new List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>();	
  	
        OpportunityLineItem oppLineItm= [SELECT Id, Name, UnitPrice, Price_Erosion_Rate__c, Product2.Name, Share__c, Component_Multiplier__c, CreatedDate,OpportunityID, LT_Value_USD__c, Claim_Value_USD__c FROM OpportunityLineItem WHERE Product2Id =:OpptyLineItemName AND OpportunityID =: opportunityId]; // added due to PM issue	
        List<OpportunitySchedule__c> lstExistingOpptySchld = new  List<OpportunitySchedule__c>();	
        lstExistingOpptySchld= [Select Id, Name, Comment__c, Frozen_Oppty_Sched_Qty__c, Opportunity__c, Oppty_Sched_Qty__c, 	
                                       Sched_Date__c From OpportunitySchedule__c where Opportunity__c=:opportunityId Order By Sched_Date__c];	
        	
        List<OpportunityProductSchedule__c> lsTExistingOpptyProdSchld = new  List<OpportunityProductSchedule__c>();	
        lsTExistingOpptyProdSchld = [SELECT Frozen_Oppty_Sched_Qty__c,Frozen_Prod_Qty__c,Frozen_Prod_Sched_Price__c,	
                                     Frozen_Prod_Value__c,Frozen_Share__c,Id,Name,Opportunity__c,Oppty_Prod_ID_Full__c,	
                                     Oppty_Sched_Qty__c,Product__c,Prod_Qty__c,Prod_Sched_Price__c,	
                                     Forecast_Value__c,Qty_Per_Sys__c,Sched_Date__c,Share__c, Forecast_Value_USD__c FROM OpportunityProductSchedule__c 	
                                     where Oppty_Prod_ID_Full__c =:oppLineItm.Id AND Opportunity__c =:opportunityId Order By Sched_Date__c];	
        Decimal sumForeCastValue= 0;  	
        for(OpportunityProductSchedule__c oppProdSched: lsTExistingOpptyProdSchld ){	
            sumForeCastValue =sumForeCastValue+oppProdSched.Forecast_Value_USD__c;	
        }	
           	
        if(integer.valueof(lsTExistingOpptyProdSchld.size()) != 0)	
        {	
           for(OpportunityProductSchedule__c oppProdSched: lsTExistingOpptyProdSchld ){	
            Decimal price = oppProdSched.Prod_Sched_Price__c;	
            Integer share = Integer.valueOf(oppProdSched.Share__c);	
            OpportunitySchedulingWrapper.OppotunityProductScheduleView opptyProdSched= new OpportunitySchedulingWrapper.OppotunityProductScheduleView();	
            opptyProdSched.oliRecord = oppLineItm;	
            opptyProdSched.opptyProdSchedWrap = oppProdSched;	
            opptyProdSched.opptyProdSchedWrap.Share__c = oppProdSched.Share__c;	
            opptyProdSched.opptyProdSchedWrap.Prod_Sched_Price__c = oppProdSched.Prod_Sched_Price__c;                        	
            if(oppDisp.StageName =='Commitment'){	
               opptyProdSched.prodPrice = price;	
               opptyProdSched.prodShare = share; 	
            } 	
            Date tempQtrSchldDate= oppProdSched.Sched_Date__c;	
            Integer year= tempQtrSchldDate.year();	
            Integer month= tempQtrSchldDate.month();	
            Integer quartr;	
            quartr= ((month - 1) / 3) + 1;	
            opptyProdSched.quarterdate = string.valueOf(year)+'Q'+ string.valueOf(quartr) ; 	
            opptyProdSched.sumForecastProdValue = sumForeCastValue; 
            opptyProdSched.oppValues = oppDisp;  
            lstOpptyProdSched.add(opptyProdSched);	
          }	
            	
       }    	
      return lstOpptyProdSched;	
    } 	
  	
        /***** Oppty Prod Sched Display Update value call *****/	
	
  @AuraEnabled	
    public static OpportunitySchedulingWrapper.OpptyProdSchedSave updateDWOpptyProdSchedule(Id opportunityId, string opptyProdSchldWrapRec, string OpptyLineItemName) {	
        OpportunitySchedulingWrapper.OpptyProdSchedSave opptyProdSchedSaveRet = new  OpportunitySchedulingWrapper.OpptyProdSchedSave();
        Boolean flgUpdateError = false;	
        List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> lstWrapperOpptyProdSchedule = (List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>)System.JSON.deserialize(opptyProdSchldWrapRec,List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>.class);	
        Integer countlstWrapperOpptyProdSchedule = 1;	
        OpportunityLineItem oppLineItm = new OpportunityLineItem();	
        if(OpptyLineItemName == null){	
         oppLineItm= [SELECT Id, Name, UnitPrice, Price_Erosion_Rate__c, Product2.Name, Share__c, Component_Multiplier__c, CreatedDate, OpportunityID FROM OpportunityLineItem WHERE OpportunityID =: opportunityId][0];  	
        }	
        if(OpptyLineItemName != null){	
         oppLineItm= [SELECT Id, Name, UnitPrice, Price_Erosion_Rate__c, Product2.Name, Share__c, Component_Multiplier__c, CreatedDate, OpportunityID FROM OpportunityLineItem WHERE Product2Id =:OpptyLineItemName AND OpportunityID =: opportunityId];                     	
        }	
        List<OpportunityProductSchedule__c> lstExistingOpptyProdSched = new  List<OpportunityProductSchedule__c>();	
        List<OpportunityProductSchedule__c> lstUpdateOpptyProdSched = new  List<OpportunityProductSchedule__c>();	
        	
        lstExistingOpptyProdSched = [Select Id, Name, Opportunity__c, Oppty_Prod_ID_Full__c, Sched_Date__c, Oppty_Sched_Qty__c, Share__c, Qty_Per_Sys__c, Prod_Sched_Price__c, Frozen_Prod_Sched_Price__c From OpportunityProductSchedule__c Where Oppty_Prod_ID_Full__c =:oppLineItm.Id AND Opportunity__c =:opportunityId Order By Sched_Date__c];	
       	
        if(lstWrapperOpptyProdSchedule != null && lstWrapperOpptyProdSchedule.size()>0){	
            // Adding existing Oppty Prod Sched to Map	
           Map<Date,OpportunityProductSchedule__c> mapWrapOpptyProdSched = new Map<Date,OpportunityProductSchedule__c>();	
           for(OpportunityProductSchedule__c oppProdSch: lstExistingOpptyProdSched){	
                mapWrapOpptyProdSched.put(oppProdSch.Sched_Date__c, oppProdSch);    	
           }	
           System.debug('mapWrapOpptyProdSched  ******************'+ mapWrapOpptyProdSched);	
            	
           for(OpportunitySchedulingWrapper.OppotunityProductScheduleView opptyProdSchedRec: lstWrapperOpptyProdSchedule){                	
                String quarterdate = opptyProdSchedRec.quarterdate;	
                String schldDate = getScheduledate(quarterdate);	
                Date OpptyProdScheldDateCheckMap = Date.valueOf(schldDate);	
                //Logic as the 1st Quarter date is same as the production date	
                if(countlstWrapperOpptyProdSchedule ==1){	
                    OpptyProdScheldDateCheckMap = lstExistingOpptyProdSched[0].Sched_Date__c;	
                    countlstWrapperOpptyProdSchedule ++;	
                }	
                if(mapWrapOpptyProdSched.containsKey(OpptyProdScheldDateCheckMap)){	
                   OpportunityProductSchedule__c oppProdSchldFrmMap =  mapWrapOpptyProdSched.get(OpptyProdScheldDateCheckMap) ;	
                   if(oppProdSchldFrmMap.Prod_Sched_Price__c == opptyProdSchedRec.prodPrice && oppProdSchldFrmMap.Share__c == opptyProdSchedRec.prodShare){	
                      flgUpdateError = true;	
                      System.debug('Skip to Next iteration if no Change is there in the display'); 	
                      continue;                          	
                   }	
                   if(oppProdSchldFrmMap.Prod_Sched_Price__c != opptyProdSchedRec.prodPrice || oppProdSchldFrmMap.Share__c != opptyProdSchedRec.prodShare){	
                      if(((opptyProdSchedRec.prodPrice <=0) || opptyProdSchedRec.prodPrice == null) 
                         || ((opptyProdSchedRec.prodShare <0 ||opptyProdSchedRec.prodShare >100) || opptyProdSchedRec.prodShare == null) 
                         || (opptyProdSchedRec.prodShare ==0 && opptyProdSchedRec.oppValues.StageName !='Commitment')){	
                         flgUpdateError = false; 
                         break;	
                        }	
                      oppProdSchldFrmMap.Prod_Sched_Price__c = opptyProdSchedRec.prodPrice;	
                      oppProdSchldFrmMap.Share__c = opptyProdSchedRec.prodShare;	
                      lstUpdateOpptyProdSched.add(oppProdSchldFrmMap);	
                      flgUpdateError = true;	
                      System.debug('Skip to Next iteration if Change is there in the display after upadting it'); 	
                      continue;                          	
                   }                      	
                }	
            }
            opptyProdSchedSaveRet.isOpptyProdSchedSave = flgUpdateError;
            // DML operations executed in try catch block
            try{  
                  updateOpptyValue(opportunityId,null,null);
                  Update lstUpdateOpptyProdSched; 
               }
            // If Exception found throw the Error to Front End user
            catch(Exception e)	
              {	
               throw e;	
              }	     
                                            
        }	
        system.debug('flgUpdateError'+flgUpdateError);
        
        return opptyProdSchedSaveRet;          	
    }  	
    	
	
    /******Method Called for Updating the Opportunity Records with the new Expected Closed Date and Production Date*******/	
    public static void updateOpptyValue(Id opportunityId, Date ExpClsDate, Date NewProdDate){ 
      system.debug('opportunityId called'+opportunityId);
      Opportunity oppsave = new Opportunity();
      Boolean flagIsChanged = false;
      oppsave= [SELECT Id, Name,CloseDate, Production_Date__c,LT_Value_USD__c, Claim_Value_USD__c ,StageName, AccountId, Account.Customer_Category__c,TMMA_Override__c,RecordType.DeveloperName,Design_Win_Approval_Process__c,CreatedDate FROM Opportunity WHERE Id =:opportunityId]; 	
        	
      if(((oppsave.CloseDate != ExpClsDate && ExpClsDate != null) || 	
         (oppsave.Production_Date__c !=NewProdDate && NewProdDate !=null)) && oppsave.StageName !='Commitment'){	
          oppsave.CloseDate =ExpClsDate;	
          oppsave.Production_Date__c=NewProdDate;
          flagIsChanged = true;   
      }	
      if(oppsave.RecordType.DeveloperName =='Model_N_Oppty' && oppsave.Account.Customer_Category__c =='Tier 4 - TMMA'){	
         oppsave.TMMA_Override__c = true;
         flagIsChanged = true;
      }  
      if(flagIsChanged){
         Update oppsave;	
      }	
    }	
    	
    /******Method for displaying the Updated ForecastValue in Production Management view for the particular Product*******/	
     @AuraEnabled	
     public static List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> getUpdatedForeCastValue(Id opportunityId, String OpptyLineItemName) { 	
      List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> lstOpptyProdSchedRet = new List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>();	
      lstOpptyProdSchedRet = getOpptyProdSchedDisplayClass(opportunityId,OpptyLineItemName);	
      return lstOpptyProdSchedRet;	
     }	
}