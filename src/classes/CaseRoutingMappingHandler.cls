/*
Class Name	  : CaseRoutingMappingHandler
Description   : Class updates Owner_Name__c field of Case_Routing_Mapping__c based on entered CaseOwner__c [Group/Queue].
*/
public class CaseRoutingMappingHandler {
    
    public void onBeforeInsert(List<Case_Routing_Mapping__c> lstCaseRouteMappingNew){
        
        updateCaseOwner(lstCaseRouteMappingNew, NULL);
    }
    
     public void onBeforeUpdate(List<Case_Routing_Mapping__c> lstCaseRouteMappingNew, Map<Id,Case_Routing_Mapping__c> mapOldCaseRouteMapping){
         
        List<Case_Routing_Mapping__c> lstNewCaseRouteMapping = new List<Case_Routing_Mapping__c>();
        
        //checking if caseOwner is updated or not
        for(Case_Routing_Mapping__c objCSM : lstCaseRouteMappingNew){
            
            if(objCSM.CaseOwner__c!= NULL && objCSM.CaseOwner__c != mapOldCaseRouteMapping.get(objCSM.Id).CaseOwner__c){
                
                lstNewCaseRouteMapping.add(objCSM);
            }
            else if(objCSM.CaseOwner__c == NULL && objCSM.Owner_Name__c!=NULL){
                
                objCSM.Owner_Name__c = '';
            }
        }
        if(!lstNewCaseRouteMapping.isEmpty()){
            
            updateCaseOwner(lstCaseRouteMappingNew, mapOldCaseRouteMapping);     
        }
        
    }
    
    /*Method to update Owner_Name__c field of CaseRoutingMapping based on related CaseOwner__c*/
    private void updateCaseOwner(List<Case_Routing_Mapping__c> lstCaseRouteMappingNew, Map<Id,Case_Routing_Mapping__c> mapOldCaseRouteMapping){
        
        Map<Id,List<Case_Routing_Mapping__c>> mapOfOwnerToCRM = new Map<Id,List<Case_Routing_Mapping__c>>();
        Map<Id, List<Case_Routing_Mapping__c> > mapOfQueueToCRM = new Map<Id, List<Case_Routing_Mapping__c>>();
        
        for(Case_Routing_Mapping__c objCSM : lstCaseRouteMappingNew){
            
            //checking if entered CaseOwner__c is user or not
            if(objCSM.CaseOwner__c != NULL && String.valueOf(objCSM.CaseOwner__c).startsWith('005')){
                
                if(mapOfOwnerToCRM.containskey(objCSM.CaseOwner__c)){
                    
                     mapOfOwnerToCRM.get(objCSM.CaseOwner__c).add(objCSM); 
                }
                else{
                    
                     mapOfOwnerToCRM.put(objCSM.CaseOwner__c, new List<Case_Routing_Mapping__c> { objCSM });
                }
            }
            //checking if entered CaseOwner__c is Queue or not
            else if(objCSM.CaseOwner__c != NULL && String.valueOf(objCSM.CaseOwner__c).startsWith('00G')){
                
                if(mapOfQueueToCRM.containskey(objCSM.CaseOwner__c)){
                    
                     mapOfQueueToCRM.get(objCSM.CaseOwner__c).add(objCSM); 
                }
                else{
                    
                     mapOfQueueToCRM.put(objCSM.CaseOwner__c, new List<Case_Routing_Mapping__c> { objCSM });
                }
            }
            
        }
        
        if(!mapOfOwnerToCRM.isEmpty()){
            //fetching the User Name if user entered UserId in CaseOwner__c field and updating Owner_Name__c.
            for(User objuser : [SELECT Id, Name FROM User WHERE Id IN : mapOfOwnerToCRM.keyset()]){
                
                for(Case_Routing_Mapping__c objCRM : mapOfOwnerToCRM.get(objuser.Id)){
                    
                    objCRM.Owner_Name__c = objuser.Name;
                }
                
            }
            
        }
        
        if(!mapOfQueueToCRM.isEmpty()){
            
            //fetching the Queue Name if user entered QueueId in CaseOwner__c field and updating Owner_Name__c.
            for(Group objGroup : [SELECT Id, Name, Type FROM Group WHERE Id IN : mapOfQueueToCRM.keyset() AND Type = 'Queue']){
                
                for(Case_Routing_Mapping__c objCRM : mapOfQueueToCRM.get(objGroup.Id)){
                    
                    objCRM.Owner_Name__c = objGroup.Name;
                }
            }
        }
    }
}