/**
 * This Wrapper class will have the attributes realted for the Opportunity Scheduling 
   and Production Management related operations.
 * It will be invoked by the action happening on the 'opportunityScheduleAction' lightning component.
------------------------------------------------------------------------------------
 * Created By   : Venkateshwar G
 * Created Date : MAR 09,2017
 * Description  : This Wrapper class will have the attributes realted for the Opportunity Scheduling 
                  and Production Management related operations.
------------------------------------------------------------------------------------ 
------------------------------------------------------------------------------------
 * Edited By   : Venkateshwar G
 * Edited Date : MAY 31,2017
 * Description : Added Exception handling wrapper methods for Production Management.
------------------------------------------------------------------------------------ 

*/
public class OpportunitySchedulingWrapper {

    public class OpportunityScheduleExists{
       @AuraEnabled public boolean isOpptySchedule;
       @AuraEnabled public Opportunity oppValues;
       @AuraEnabled public String messageException; //added for Exception handling
        public OpportunityScheduleExists(){
            isOpptySchedule = false;
            messageException='';
        }
    }
    public class OpportunityScheduleView {
        
        @AuraEnabled public Integer quantities;
        @AuraEnabled public string comment;
        @AuraEnabled public string quarterdate;
        @AuraEnabled public Opportunity oppValues;
        public OpportunityScheduleView(){
            quantities = 0;
            comment = '';
            quarterdate = '';
        }
    }
 
    public class OppotunityProductScheduleView{
       @AuraEnabled public Decimal prodPrice;
       @AuraEnabled public Integer prodShare;
       @AuraEnabled public string quarterdate;
       @AuraEnabled public Opportunity oppValues;    
       @AuraEnabled public OpportunityProductSchedule__c opptyProdSchedWrap;
       @AuraEnabled public OpportunityLineItem oliRecord;
       @AuraEnabled public Decimal sumForecastProdValue; //added
        public OppotunityProductScheduleView(){
            opptyProdSchedWrap = new OpportunityProductSchedule__c();
        }
    }
    
    public class OpportunityProductScheduleInitialDataView{
        @AuraEnabled public List<OppotunityProductScheduleView> lstopptyProdSchedDispTable;
        @AuraEnabled public List<String> lstOpptyLineItemName;
        @AuraEnabled public List<OpptyProdIdName> lstOpptyProdIdName;
        @AuraEnabled public Opportunity oppValues;
        public OpportunityProductScheduleInitialDataView(){
        }
    }
    
    public class OpptyProdIdName{    
         @AuraEnabled public string opptyProdName;
         @AuraEnabled public string opptyProdId;    
    }
    
    public class OpptyProdSchedSave{    
         @AuraEnabled public boolean isOpptyProdSchedSave;
         @AuraEnabled public string messageException;    
    }
}