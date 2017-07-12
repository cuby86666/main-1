/*************************************************************************************************** 
@Created By :      Balaji G
@Created Date:     08 July 2016
@Description:      Batch class to populate Funnel Tracker Snapshot Object for Top 30 accounts except STAR - SIR960
****************************************************************************************************/
/*
*  Modified by: Balaji G
*  For: Release 2016.9 SIR# 1208 
*  Description: 1. Remove dependency on OpportunityTrigger for SFDC Record Type Fetch
                2. Added limit to SOQL in execute method to overcome governor limit exception thrown runtime
*/
global class FunnelTrackerSnapshotPopulateBatch implements Database.batchable<sObject>
{
  global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String SFDC_RECORD_TYPE = 'SFDC_Oppty';
         //2016.9 SIR# 1208 removed dependency on OpportunityTrigger for SFDC Record Type Fetch
        List<Top_Accounts__c> TopAccounts = Top_Accounts__c.getall().values();
        List<String> TopAccountNames = new List<String>();
        List<String> FunnelStages= new String[]{'Initial Engagement','Decision','Discovery','Recommendation','Assessment','Commitment'};
        for (Top_Accounts__c topAct :TopAccounts)
          {
                TopAccountNames.add(topAct.Account_Name__c);
          }
        return Database.getQueryLocator([SELECT
            X9NC__c,
            Opportunity.Account.Account_ID_Full__c,
            Account_Name__c,
            BL__c,
            BU__c,
            Opportunity.CloseDate,
            Component_Multiplier__c,
            Opportunity.Percentage_to_DW_Completion__c,MAG__c,
            Opportunity.Claim_Value_USD__c,
            Opportunity.Opportunity_ID_Full__c,
            Opportunity_Name__c, 
            OpportunityLineItem_Id_Full__c,
            Opportunity.Account.ParentId,
            Opportunity.Parent_Account__c,
            Prod_Lost__c,
            Claim_Value_USD__c,
            Product2.Product_ID_Full__c,
            Opportunity.Production_Date__c,
            Product_Thrust_Non_Thrust_DW_Value_USD__c,
            Product_Thrust_DW_Value__c,
            Opportunity.StageName, 
            Thrust_Indicator__c 
            FROM OpportunityLineItem
            WHERE  
            Opportunity.Account.Parent.Name in :TopAccountNames
            AND
            Opportunity.StageName in :funnelstages
            AND
            Opportunity.Recordtype.DeveloperName = :SFDC_RECORD_TYPE 
            ]);
    }

  global void execute(Database.BatchableContext BC, List<sObject> lstScope)
    {
        List<Funnel_Tracker_Snapshot__c> FunnelList = new List<Funnel_Tracker_Snapshot__c>();
        if(lstScope.size()!=0)
            {
                for(sObject objScope :lstScope)
                  {
                      OpportunityLineITem objOppLin= (OpportunityLineITem)objScope;
                      Funnel_Tracker_Snapshot__c funnel = new Funnel_Tracker_Snapshot__c(
                        X9NC__c=objOppLin.X9NC__c,
                        Account_Id__c=objOppLin.Opportunity.Account.Account_ID_Full__c,
                        Account_Name__c=objOppLin.Account_Name__c,
                        BL__c=objOppLin.BL__c,
                        BU__c=objOppLin.BU__c,
                        CloseDate__c=objOppLin.Opportunity.CloseDate,
                        Component_Multiplier__c=objOppLin.Component_Multiplier__c,
                        Percentage_to_DW_Completion__c=objOppLin.Opportunity.Percentage_to_DW_Completion__c,
                        MAG__c=objOppLin.MAG__c,
                        Oppty_Claim_Value_USD__c=objOppLin.Opportunity.Claim_Value_USD__c,
                        Opportunity_Id__c=objOppLin.Opportunity.Opportunity_ID_Full__c,
                        Opportunity_Name__c=objOppLin.Opportunity_Name__c, 
                        OpportunityLineItemId__c=objOppLin.OpportunityLineItem_Id_Full__c,
                        Parent_Account_Id__c=objOppLin.Opportunity.Account.ParentId,
                        Parent_Account_Name__c=objOppLin.Opportunity.Parent_Account__c,
                        Prod_Lost__c=objOppLin.Prod_Lost__c,
                        Prod_Claim_Value_USD__c=objOppLin.Claim_Value_USD__c,
                        Products_Id__c=objOppLin.Product2.Product_ID_Full__c,
                        Production_Date__c=objOppLin.Opportunity.Production_Date__c,
                        Product_Thrust_Non_Thrust_DW_Value_USD__c=objOppLin.Product_Thrust_Non_Thrust_DW_Value_USD__c,
                        Product_Thrust_DW_Value__c=objOppLin.Product_Thrust_DW_Value__c,
                        StageName__c=objOppLin.Opportunity.StageName, 
                        Thrust_Indicator__c=objOppLin.Thrust_Indicator__c
                        );
                      FunnelList.add(funnel);
                  }
                try
                  {    
                      if(FunnelList.size()!=0)
                          {
                           insert FunnelList;
                          }
                  }
                catch(System.DMLException ex)
                  {
                      system.debug('+++Error'+ex);     
                  }
            }
    }
    
  global void finish(Database.BatchableContext BC)
    {  
       Integer n=Integer.valueOf(System.Label.Days_Delete_Funnel);
       Date d= System.Today().addDays(n);
       List<Funnel_Tracker_Snapshot__c> FunnelDelList = [SELECT id FROM Funnel_Tracker_Snapshot__c WHERE CreatedDate< :d LIMIT 9999];
       //2016.9 SIR# 1208 added limit 9999 to avoid limit exception thrown runtime
       Database.delete(FunnelDelList);
    } 
}