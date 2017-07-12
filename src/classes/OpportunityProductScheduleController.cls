public with sharing class OpportunityProductScheduleController {
    
    /*********************************Step 3 Re Written Logic Starts*********************************************/
    /*****Opprt Prod Sched: Step3 Init Call*****/
    @AuraEnabled
    public static OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView getOpptyLineItemValuesClass (Id opportunityId) {    
    OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView oppInitdta = new OpportunitySchedulingWrapper.OpportunityProductScheduleInitialDataView();
          
          Opportunity oppDisp= [SELECT Id, Name,StageName, CloseDate, Production_Date__c,LT_Value_USD__c, Claim_Value_USD__c, CreatedDate FROM Opportunity WHERE Id =:opportunityId];
          List<OpportunityLineItem> oppLineItm= [SELECT Id, Name, Price_Erosion_Rate__c, Product2.Name, Share__c, Component_Multiplier__c, CreatedDate FROM OpportunityLineItem WHERE OpportunityId =:opportunityId];
          List<String> lstOpptyProdName = new List<String>();
           for(OpportunityLineItem oppProd : oppLineItm){
             lstOpptyProdName.add(oppProd.Product2.Name);  
           }
           System.debug('lstOpptyProdName******************');
        
        List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> lstDispInitDta = new List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>();
             lstDispInitDta= getOpptyProdSchedDisplayClass(opportunityId,lstOpptyProdName[0]);
        
        oppInitdta.lstOpptyLineItemName = lstOpptyProdName;
        oppInitdta.lstopptyProdSchedDispTable = lstDispInitDta;
        oppInitdta.oppValues = oppDisp;
           return oppInitdta;
    }
    
    @AuraEnabled
       public static List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> getOpptyProdSchedDisplayClass(Id opportunityId, String OpptyLineItemName) { 
           
           Opportunity oppDisp= [SELECT Id, Name,StageName, CloseDate, Production_Date__c,LT_Value_USD__c, Claim_Value_USD__c, CreatedDate FROM Opportunity WHERE Id =:opportunityId];

           List<OpportunityLineItem> oppLineItm1= [SELECT Id, Name, Price_Erosion_Rate__c, Product2.Name, Share__c, Component_Multiplier__c, CreatedDate FROM OpportunityLineItem WHERE OpportunityId =:opportunityId];
           
 List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> lstOpptyProdSched = new List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>();
  
        OpportunityLineItem oppLineItm= [SELECT Id, Name, UnitPrice, Price_Erosion_Rate__c, Product2.Name, Share__c, Component_Multiplier__c, CreatedDate,OpportunityID FROM OpportunityLineItem WHERE Product2.Name =:OpptyLineItemName AND OpportunityID =: opportunityId];
        
        List<OpportunitySchedule__c> lsTExistingOpptySchld = new  List<OpportunitySchedule__c>();
        lsTExistingOpptySchld= [Select Id, Name, Comment__c, Frozen_Oppty_Sched_Qty__c, Opportunity__c, Oppty_Sched_Qty__c, 
                                         Sched_Date__c From OpportunitySchedule__c where Opportunity__c=:opportunityId];
        
        List<OpportunityProductSchedule__c> lsTExistingOpptyProdSchld = new  List<OpportunityProductSchedule__c>();
        lsTExistingOpptyProdSchld = [SELECT Frozen_Oppty_Sched_Qty__c,Frozen_Prod_Qty__c,Frozen_Prod_Sched_Price__c,
                                     Frozen_Prod_Value__c,Frozen_Share__c,Id,Name,Opportunity__c,Oppty_Prod_ID_Full__c,
                                     Oppty_Sched_Qty__c,Product__c,Prod_Qty__c,Prod_Sched_Price__c,
                                     Qty_Per_Sys__c,Sched_Date__c,Share__c FROM OpportunityProductSchedule__c 
                                     where Oppty_Prod_ID_Full__c =:oppLineItm.Id AND Opportunity__c =:opportunityId];
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
               lstOpptyProdSched.add(opptyProdSched);
           }
            
        }
     
      return lstOpptyProdSched;
    } 
    
  @AuraEnabled
    public static boolean updateDWOpptyProdSchedule(Id opportunityId, string opptyProdSchldWrapRec, string OpptyLineItemName) {
        Boolean flgUpdateError = false;
        List<OpportunitySchedulingWrapper.OppotunityProductScheduleView> lstWrapperOpptyProdSchedule = (List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>)System.JSON.deserialize(opptyProdSchldWrapRec,List<OpportunitySchedulingWrapper.OppotunityProductScheduleView>.class);
        system.debug('Debug for Dsiplaying all the records: lstWrapperOpptyProdSchedule'+lstWrapperOpptyProdSchedule);
        System.debug('Inside for saveOpptySchedule OpptyLineItemName ******************'+ OpptyLineItemName);
        Integer countlstWrapperOpptyProdSchedule = 1;
        OpportunityLineItem oppLineItm = new OpportunityLineItem();
         if(OpptyLineItemName == null){
         oppLineItm= [SELECT Id, Name, UnitPrice, Price_Erosion_Rate__c, Product2.Name, Share__c, Component_Multiplier__c, CreatedDate, OpportunityID FROM OpportunityLineItem WHERE OpportunityID =: opportunityId][0];  
         }
         if(OpptyLineItemName != null){
         oppLineItm= [SELECT Id, Name, UnitPrice, Price_Erosion_Rate__c, Product2.Name, Share__c, Component_Multiplier__c, CreatedDate, OpportunityID FROM OpportunityLineItem WHERE Product2.Name =:OpptyLineItemName AND OpportunityID =: opportunityId];
        }
        List<OpportunityProductSchedule__c> lstExistingOpptyProdSched = new  List<OpportunityProductSchedule__c>();
        List<OpportunityProductSchedule__c> lstUpdateOpptyProdSched = new  List<OpportunityProductSchedule__c>();
        
        lstExistingOpptyProdSched = [Select Id, Name, Opportunity__c, Oppty_Prod_ID_Full__c, Sched_Date__c, Oppty_Sched_Qty__c, Share__c, Qty_Per_Sys__c, Prod_Sched_Price__c, Frozen_Prod_Sched_Price__c From OpportunityProductSchedule__c Where Oppty_Prod_ID_Full__c =:oppLineItm.Id AND Opportunity__c =:opportunityId];
        System.debug('lstExistingOpptyProdSched  ******************'+ lstExistingOpptyProdSched);

       
        if(lstWrapperOpptyProdSchedule != null && lstWrapperOpptyProdSchedule.size()>0){
            System.debug('Inside for updateOpptyprodSchedule  ******************'+ lstWrapperOpptyProdSchedule.size());
            
            // Adding existing Oppty Prod Sched to Map
           Map<Date,OpportunityProductSchedule__c> mapWrapOpptyProdSched = new Map<Date,OpportunityProductSchedule__c>();
            for(OpportunityProductSchedule__c oppProdSch: lstExistingOpptyProdSched){
                mapWrapOpptyProdSched.put(oppProdSch.Sched_Date__c, oppProdSch);    
            }
            System.debug('mapWrapOpptyProdSched  ******************'+ mapWrapOpptyProdSched);
            
            
            for(OpportunitySchedulingWrapper.OppotunityProductScheduleView opptyProdSchedRec: lstWrapperOpptyProdSchedule){
                
                String quarterdate = opptyProdSchedRec.quarterdate;
                System.debug('quarterdate'+ quarterdate.length());
                String subStrYr= quarterdate.Substring(0,4);
                String subStrqtr= string.valueOf(quarterdate.right(1));
                System.debug('mONTH eXTRACT'+ subStrqtr);
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
                System.debug('Str Date  ******************'+ schldDate);
                Date OpptyProdScheldDateCheckMap = Date.valueOf(schldDate);
                //Logic as the 1st Quarter date is same as the production date
                if(countlstWrapperOpptyProdSchedule ==1){
                    OpptyProdScheldDateCheckMap = lstExistingOpptyProdSched[0].Sched_Date__c;
                    countlstWrapperOpptyProdSchedule ++;
                }
                //Added to Update Chech with Quarter date.
                if(mapWrapOpptyProdSched.containsKey(OpptyProdScheldDateCheckMap))
                {
                   System.debug('Map Contains Values of same quarter date');  
                   OpportunityProductSchedule__c oppProdSchldFrmMap =  mapWrapOpptyProdSched.get(OpptyProdScheldDateCheckMap) ;
                    if(oppProdSchldFrmMap.Prod_Sched_Price__c == opptyProdSchedRec.prodPrice && oppProdSchldFrmMap.Share__c == opptyProdSchedRec.prodShare){
                        flgUpdateError = true;
                        system.debug('If No Change'); 
                        System.debug('Skip to Next iteration if no Change is there in the display'); 
                        continue;                          
                    }
                    
                    if(oppProdSchldFrmMap.Prod_Sched_Price__c != opptyProdSchedRec.prodPrice || oppProdSchldFrmMap.Share__c != opptyProdSchedRec.prodShare){
                        if(((opptyProdSchedRec.prodPrice <=0) || opptyProdSchedRec.prodPrice == null) || ((opptyProdSchedRec.prodShare <=0 ||opptyProdSchedRec.prodShare >100) || opptyProdSchedRec.prodShare == null)){
                          flgUpdateError = false; 
                          break;
                        }
                        System.debug('oppProdSchldFrmMap B4 uPADTE'+oppProdSchldFrmMap);
                        oppProdSchldFrmMap.Prod_Sched_Price__c = opptyProdSchedRec.prodPrice;
                        oppProdSchldFrmMap.Share__c = opptyProdSchedRec.prodShare;
                        lstUpdateOpptyProdSched.add(oppProdSchldFrmMap);
                        flgUpdateError = true;
                        System.debug('oppProdSchldFrmMap Aftr uPADTE'+oppProdSchldFrmMap);
                        System.debug('Skip to Next iteration if Change is there in the display after upadting it'); 
                        continue;                          
                      }
                      
                }
                //Ended to Update Chech with Quarter date.                               
            }
            Update lstUpdateOpptyProdSched;

            System.debug('Update for lstOpptySchld  ******************'+ lstUpdateOpptyProdSched);
           
        }
          return flgUpdateError;          
    }  
    
        /*************************************Step Re Written Logic Ends************************************************/

}