/* Why: 15.03 CRM Million Dollar Approval 
 * What: Apex Class for OpportunityLineItem Apex Trigger
 * Who: Stan Hsu
 * When: Feb 27, 2015
 */
 
 /******************************************************************************
 * Modified By: Jewelslyn
 * Modified Date : Jan 05,2016
 * Description : Modified the class as part of optimization.(Added last modified By and last UpdatedBy, SetUp Thrust Indicator features)
*******************************************************************************/

//Optimized features for Feb Release starts 
public class OpportunityLineItemTrigger 
{
    /******BEFORE TRIGGER(INSERT AND UPDATE) METHOD****************************************************************
       
       Method Name: OppLineItem_OnBeforeInsertUpdate
       The features Implemented are : 
       1.Update Thrust Indicator
   *********************************************************************************************************************/
     public static void onBeforeInsertUpdate(List<OpportunityLineItem> opptyLineItemList) 
     {
         //Feature to update Thrust Indicator 
        Set<ID> productIds = new Set<ID>();                 
        for(OpportunityLineItem oppLiItem:opptyLineItemList)
        {
            productIds.add(oppLiItem.Product2Id);                      
        }        
        Map<Id,Product2> productMap= new map<id,product2>([Select Id, Thrust_Indicator__c from Product2 where Id IN:productIds]);
        for(OpportunityLineitem oppLiItem:opptyLineItemList)
        {
            if(productmap.containsKey(oppLiItem.Product2Id))
            {
                oppLiItem.Thrust_Indicator__c= productMap.get(oppLiItem.Product2Id).Thrust_Indicator__c;
                system.debug('thrust' + oppLiItem.Thrust_Indicator__c);
            }
        }
       //End of feature to update thrust Indicator
     
     }
     
     /******BEFORE TRIGGER(INSERT) METHOD****************************************************************
       
       Method Name: OppLineItem_OnBeforeInsert
       The features Implemented are : 
       1.LastupdateById/Date : Populating LastUpdatedById/Date on insert of opportunitylineitems
       
   *********************************************************************************************************************/  
   public static void onBeforeInsert( List<OpportunityLineItem> listOpportunityProducts )
    {
    	/* Modified by Scarlett on Jan 03, 2017 */
    	/*
      for( OpportunityLineItem theOpportunityProduct : listOpportunityProducts )
        {
            theOpportunityProduct.LastUpdatedById__c = UserInfo.getUserId();
            theOpportunityProduct.LastUpdatedDate__c = Datetime.now();
        }
       */
        
    }
    
    /******BEFORE TRIGGER(UPDATE) METHOD****************************************************************
       
       Method Name: OppLineItem_OnBeforeUpdate
       The features Implemented are : 
       1.LastupdateById/Date : Updating LastUpdatedById/Date on update of opportunitylineitems
       
   ****************************************************************************************************/
    
    public static void onBeforeUpdate( List<OpportunityLineItem> listOpptyProds )
    {
      OpportunityTrigger.fetchUserNameProfiles();     
      /* Modified by Scarlett on Jan 03, 2017 */
      /* 
      for( OpportunityLineItem theOpportunityProduct : listOpptyProds )
        {
            if( UserInfo.getUserId() != OpportunityTrigger.integUser_Id && UserInfo.getProfileId() != OpportunityTrigger.adminUserProfile_Id)
            {
                theOpportunityProduct.LastUpdatedById__c = UserInfo.getUserId();
                theOpportunityProduct.LastUpdatedDate__c = Datetime.now();
            }
        }
       */
    }
    
    /******BEFORE,AFTER TRIGGER(INSERT,UPDATE,DELETE) METHOD****************************************************************
       
       Method Name: OppLineItem_OnBeforeUpdate
       The features Implemented are : 
       1.Summarize MAG Feature
       2.ROLL UP BU BL MAG
       
   ****************************************************************************************************/
    
 Public Static Void onAfterInsert_Update_Delete(List<OpportunityLineItem> listOpptyProds)
{
  //Summarize Mag Feature and Roll Up BU BL MAG feature                        
    List<Opportunity> oppList=new List<Opportunity>();
    Set<ID> olioppIds = new Set<ID>();
    Set<String> magSet=new Set<string>();
    Set<String> buSet=new Set<string>();
    Set<String> blSet=new Set<string>();
        
    map<Id,set<string>> oppMagMapSet=new map<Id,set<string>>();
    map<Id,set<string>> oppBuMapSet=new map<Id,set<string>>();
    map<Id,set<string>> oppBlMapSet=new map<Id,set<string>>(); 
                                                           
    for(OpportunityLineItem oli:listOpptyProds)
    {
        olioppIds.add(oli.OpportunityId); 
    }
    oppList=[SELECT Id,MAG__c,Bu__c,BL__C from Opportunity where Id IN:olioppIds];
        
                                                                                                                                                                                                                                                                        
    List<opportunityLineItem> oliList=new list<opportunityLineItem>([Select Id, opportunityId,Mag__c,BU__c,BL__c from OpportunityLineitem
                                                                    where OpportunityId IN:olioppIds ORDER BY OpportunityId ASC,MAG__c ASC 
                                                                    ]);
    for(OpportunityLineItem oli:oliList)
    {
        if(oppMagMapSet.containsKey(oli.OpportunityId)) 
        {
          oppMagMapSet.get(oli.OpportunityId).add(oli.Mag__c);
        }
        else
        {
           oppMagMapSet.put(oli.OpportunityId,new Set<String>{oli.Mag__c});  
        }
        if(oppBuMapSet.containsKey(oli.OpportunityId))
        {
           oppBuMapSet.get(oli.OpportunityId).add(oli.BU__c);
        }
        else
        {
            oppBuMapSet.put(oli.OpportunityId,new Set<String>{oli.BU__c});  
        }
            
        if(oppBlMapSet.containsKey(oli.OpportunityId))
        {
            oppBlMapSet.get(oli.OpportunityId).add(oli.BL__c);
        }
        else
        {
            oppBlMapSet.put(oli.OpportunityId,new Set<String>{oli.BL__c});  
        } 
    }
        
    for(Opportunity opp:oppList)
    {       
        opp.Mag__c=null;
        opp.BU__c=null;
        opp.BL__c=null;
                                              
        magSet=oppMagMapSet.get(opp.Id);
        buSet=oppBuMapSet.get(opp.Id);
        blSet=oppBlMapSet.get(opp.Id);
                         
        string strMag='';
        string strBu='';
        string strBl='';
        if(magset !=null)  
        {
            for(string s:magset)
            {                
                strMag+=S+'|';                       
            }
            opp.Mag__c=strMag.substringBeforeLast('|');
        }
        if(buSet !=null)
        {
            for(string s:buset)
            {                
                strBu+=S+'|';                       
            }
            opp.BU__c=strBu.substringBeforeLast('|');
        }
        if(blSet !=null)
        {
            for(string s:blset)
            {                
                strBl+=S+'|';                       
            } 
            opp.Bl__c=strBl.substringBeforeLast('|');
        }                                                                
      }
    try
    {
       Update oppList; 
    }
    catch(Exception e)    
    {
        
  }
                                   
 } 
//END of Summarize Mag Feature and Roll Up BU BL MAG feature 

  /**
     * This is a future handler method.
     * It will update the opportunity object based on the product trigger update.
     */ 
    @future
    public static void executeProductUpdate(Set<Id> productIdSet) {         
        for(List<OpportunityLineItem> opportunityLineItemList : [ 
                                                 Select Id,
                                                        OpportunityId, 
                                                        PricebookEntryId,
                                                        PricebookEntry.Product2Id 
                                                   From OpportunityLineItem
                                                  Where PricebookEntry.Product2Id  in :productIdSet
                                                ]) {                                                
            onAfterInsert_Update_Delete(opportunityLineItemList);                                 
        }
    }
    /*
   Public Static Void validateNumOfMags(List<OpportunityLineItem> opptyLineItemList)
   {
    list<Opportunity> opptyList=new list<Opportunity>();
    OpportunityTrigger.mapOppToMagApprover=new map<id,List<string>>();
    OpportunityTrigger.mapOppToBlApprover=new map<id,List<string>>();
    Integer magSize;
    Integer blSize;
    list<Id> oppIds= new list<Id>();
       
    for(opportunitylineItem oli:opptyLineItemList) 
    {
       oppIds.add(oli.OpportunityId);             
    }
    opptyList=[Select id,AccountId from Opportunity where id IN:oppIds]; 
    OpportunityTrigger.calculateClaimValues(opptyList); 
       
    Opportunity_Approval_Settings__c opptyApprovalSettings = Opportunity_Approval_Settings__c.getValues('Settings');
    String sNumMaxBlError = opptyApprovalSettings.BL_Max_Number_Error_Message__c;
    String sNumMaxError = opptyApprovalSettings.Max_Number_Error_Message__c;
       
   for(Opportunitylineitem oli:opptyLineItemList )
   {      
       if(OpportunityTrigger.mapOppToMagApprover.containskey(oli.OpportunityId))
        {            
            magSize=OpportunityTrigger.mapOppToMagApprover.get(oli.OpportunityId).size();
        }
        if(OpportunityTrigger.mapOpptoBlApprover.containskey(oli.OpportunityId))
        {            
            blSize=OpportunityTrigger.mapOpptoBlApprover.get(oli.OpportunityId).size();
        }
        if(magSize >=11)
        {            
            oli.adderror(sNumMaxError);
        }
        if(blSize >=6)
        {
            oli.adderror(sNumMaxBlError);
        }
    }
       
  } 
   */
}