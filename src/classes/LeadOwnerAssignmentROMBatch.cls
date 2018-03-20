global class LeadOwnerAssignmentROMBatch implements Database.Batchable<Lead> {
    global Iterable<Lead> start(Database.BatchableContext bc) {
        user u=[Select id, name from User where name=:label.Lead_Default_Owner];
        
            return new List<Lead>([SELECT id,name,owner.name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,RecordTypeId,Description,street,
                               city,country,state,company,PostalCode,Industry from Lead where RecordType.Name='ROM Leads' and Status='Open'
                                  and OwnerId=:u.Id]);                                              
    }
    global void execute(Database.BatchableContext BC, list<Lead> scope){
        list<Lead> listRomLeads= (list<Lead>)scope; 
        LeadOwnerAssignmentHandler leadOwnerAssgnmt = new LeadOwnerAssignmentHandler();
        LeadOwnerAssignmentHandler.restOfMarketAssignment(listRomLeads);
    }
    global void finish(Database.BatchableContext BC){
        
    }
}