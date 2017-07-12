/**
 * This class will update the Opportunity object for 
 * Business Unit, Business Line, and MAG fields.
 * It will be invoked by the OpportunityLineItem trigger.
 ------------------------------------------------------------------------------------
 * Modified By   : Baji
 * Modified Date : APR 17,2015
 * Description   : Removed the code related to Opportunity Record type as BU/BL/MAG can be populated for Model N Opportunities as well.
------------------------------------------------------------------------------------              

*/
public class OpportuniLineItemTrigger {

    private static final String OPPORTUNITY_OBJ = 'Opportunity';
    
    //
    // To add additional criteria:
    // 1. Add the following API field name into the opportunityFieldsMap Object Mapping below.
    //    This is a mapping between Opportunity and OpportunityLineItem field Map.
    //    Example Field Mapping:
    //    OpportunityAPIFieldName__c => OpportunityLineItemAPIFieldName__c
    //
    // 2. Add the field API field name in the SOQL query for OpportunityLineItem
    //    See IMPORTANT NOTES below.
    //
    public static final Map<String,String> opportunityFieldsMap = new Map<String,String> {
        'MAG__c' => 'MAG__c',
        'BU__c' => 'BU__c', 
        'BL__c' => 'BL__c'      
    };
    
   

    /**
     * This method will perform an Opportunity update for the following fields:
     *  - Business Unit
     *  - Business Line
     *  - MAG
     **/
    public static void updateOpportunity(List<OpportunityLineItem> opportunityLineItemList) {       
        if(opportunityLineItemList != null && !opportunityLineItemList.isEmpty()) {

            //Retrieve Opportunity Id as a string and set.
            Integer counter = 0;
            String soIds = '';
            Set<Id> opportunityIdSet = new Set<Id>();
            for(OpportunityLineItem oli : opportunityLineItemList) {
                opportunityIdSet.add(oli.OpportunityId);
                soIds = soIds + '\'' + oli.OpportunityId + '\'' + (counter < (opportunityLineItemList.size()- 1) ? ',' : '');
                counter++;
            }

            //Get Opportunity Records in Map Objects.
            Map<Id,Opportunity> opportunityMapTemp = new Map<Id,Opportunity>(); 
            Map<Id,Opportunity> opportunityMap = getOpportunityRecords(soIds);
            
            // IMPORTANT NOTES:
            // If you add a new criteria, you need to add the API field name
            // to the following SOQL query.
            for(List<OpportunityLineItem> oliList : [ Select Id, OpportunityId,
                                                             BU__c,
                                                             BL__c,
                                                             MAG__c
                                                       From OpportunityLineItem
                                                      Where OpportunityId in :opportunityIdSet
                                                    ]) {
                for(OpportunityLineItem oli : oliList) {
                    Opportunity o = null;
                    
                    if(opportunityMapTemp.containsKey(oli.OpportunityId))
                        o = opportunityMapTemp.get(oli.OpportunityId);
                    else
                        o = opportunityMap.get(oli.OpportunityId);
                    
                    if(o!=null) {
                        SObject soOpp = (SObject) o;
                        SObject soOppLineItem = (SObject) oli;
                        for(String sfieldKey : opportunityFieldsMap.keySet()) { 
                            String sfieldValue = opportunityFieldsMap.get(sfieldKey);
                            Object oppValue = soOpp.get(sfieldKey);
                            Object oppLineItemValue = soOppLineItem.get(sfieldKey);
                            String s = compareValue((String) oppValue, (String) oppLineItemValue);
                            soOpp.put(sfieldKey, s);
                        }
                        opportunityMapTemp.put(o.Id, (Opportunity) soOpp);
                    }
                }
            }           

            //Prepare to update the opportunity record.
            List<Opportunity> opportunityList = opportunityMapTemp.values();
            
            if(opportunityList != null && opportunityList.size() > 0) 
            {
                  
                                 upsert opportunityList;
                        
            }
            
            
                
        }
    }   
    
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
            updateOpportunity(opportunityLineItemList);                                 
        }
    }
    
    /**
     * Compare the Opportunity values with OpportunityLineItem value
     * Return a string value for the result.
     **/    
    private static String compareValue(String oppValue, String oppLineItemValue) {
        String result = oppValue;
        if((oppValue == null || oppValue.length() == 0) && oppLineItemValue != null) {
            result = oppLineItemValue;
        } else if(oppValue != null && oppLineItemValue != null
        && !oppValue.toLowerCase().contains(oppLineItemValue.toLowerCase())) {
            result = oppValue + ' | ' + oppLineItemValue;
        }
        return result;
    }
    
    /**
     * Get the Opportunity records based on the OpportunityLineItem
     * Set the record to Map object.
     **/
    private static Map<Id,Opportunity> getOpportunityRecords(String opportunityIds) {
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        Map<String, Schema.SObjectField> fieldsMap = Schema.SobjectType.Opportunity.fields.getMap();
        String sfields = Utility.getObjectFields(fieldsMap);
        String criteria = ' where id in (' + opportunityIds + ')';
        String sql = Utility.buildSQLStatement(sfields, OPPORTUNITY_OBJ, criteria);
        List<SObject> opportunityList = Utility.retrieveObjectRecord(sql);
        for(SObject so : opportunityList) {
            for(String sfieldKey : opportunityFieldsMap.keySet()) 
                so.put(sfieldKey, null);
            Opportunity o = (Opportunity) so;
            opportunityMap.put(o.Id, o);
        }
        return opportunityMap;
    }
}