global class contactServiceLevelCriteriaScheduler implements Schedulable {
    
global void execute(SchedulableContext SC) {
   
 //CasePrioritisationBatch objBatch = new CasePrioritisationBatch();
  contactServiceLevelCriteriaBatch objBatch =new contactServiceLevelCriteriaBatch();
  Database.executeBatch(objBatch);
    }

}