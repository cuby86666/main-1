trigger MappingCaseRouting on Case (after insert, before insert) {
    
    MappingCaseRouting objMCR = new MappingCaseRouting();
   
    if(Trigger.isAfter && Trigger.isInsert) {

         objMCR.onAfterInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isInsert) {

         objMCR.onBeforeInsert(Trigger.new);  
    }
}