global class Updateobject implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Entity;
    global final String Field;
    global final String Value;
    
    global Updateobject(String q, String e, String f, String v){
        
        Query=q; Entity=e; Field=f;Value=v;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
       String query1 = 'select id from ' + Entity +  ' '  +  Query + ' ' + 'and SystemModstamp >= LAST_N_DAYS:1' ;
        
        //system.debug('mani' + query1);
        return Database.getQueryLocator(query1);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sobject s : scope){
            s.put(Field,Value); 
        }
        update scope;
    }
    global void finish(Database.BatchableContext BC){
    }
}