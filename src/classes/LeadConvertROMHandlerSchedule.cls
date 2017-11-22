global with sharing class LeadConvertROMHandlerSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        LeadConvertROMBatch leadConvert=new LeadConvertROMBatch();
        database.executeBatch(leadConvert);
    }

}