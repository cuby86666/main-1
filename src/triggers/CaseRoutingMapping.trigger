trigger CaseRoutingMapping on Case_Routing_Mapping__c (before insert, before update) {
    
    CaseRoutingMappingHandler objhandler = new CaseRoutingMappingHandler();
    
    if(Trigger.isInsert && Trigger.isBefore){
        
        objhandler.onBeforeInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        
        objhandler.onBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }

}