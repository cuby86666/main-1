global class RulingUpdateBatchJob implements Database.Batchable<sObject>,Database.Stateful,Schedulable
{
    global List<Ruling_Table__c> listrule;
    global static boolean recursive = false;
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Query__c,Object_Name__c,Field_Name__c,Field_Value__c,Active__c from Ruling_Table__c';
        
        return Database.getQueryLocator(query);
    }
  
    global void execute(SchedulableContext sc){
            Database.executeBatch(this);
        }
     
    
    global void execute(Database.BatchableContext BC, List<Ruling_Table__c> scope)
    {
        listrule = scope;  
        system.debug('test' + listrule);

            }
    global void finish(Database.BatchableContext BC) {
        //system.debug('rule12334' + listrule);
         if(!recursive) {
        recursive = true;
       
        for(Ruling_Table__c r : listrule ){
            if(r.Active__c){
            Updateobject upd = new Updateobject(r.Query__c,r.Object_Name__c,r.Field_Name__c,r.Field_Value__c);
            Database.executeBatch(upd,50);
            }
        }
         }
        
    }
}