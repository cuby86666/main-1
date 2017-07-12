global class LeadOwnerAssignmentROMBatch implements Database.Batchable<Lead> {
    global Iterable<Lead> start(Database.BatchableContext bc) {
        if(label.Lead_Default_Owner=='All' || test.isRunningTest()){
            return new List<Lead>([SELECT id,name,owner.name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,RecordTypeId,Description,street,
                               city,country,state,company,PostalCode from Lead where RecordType.Name='ROM Leads' and Status='Open']);                              
        }
        else{
            return new List<Lead>([SELECT id,name,owner.name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,RecordTypeId,Description,street,
                               city,country,state,company,PostalCode from Lead where RecordType.Name='ROM Leads' and Status='Open'
                                  and Owner.Name=:label.Lead_Default_Owner]);
        }
        
                              
    }
    global void execute(Database.BatchableContext BC, list<Lead> scope){
        list<Lead> listRomLeads= (list<Lead>)scope; 
        LeadOwnerAssignmentHandler leadOwnerAssgnmt = new LeadOwnerAssignmentHandler();
        LeadOwnerAssignmentHandler.restOfMarketAssignment(listRomLeads);
    }
    global void finish(Database.BatchableContext BC){
        
    }
}