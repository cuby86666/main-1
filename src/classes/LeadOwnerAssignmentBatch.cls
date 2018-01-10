global class LeadOwnerAssignmentBatch implements Database.Batchable<Lead> {
    global Iterable<Lead> start(Database.BatchableContext bc) {
    	DateTime dt = System.now().addHours(-2);
        List<Lead> lds = new List<Lead>([select id,name,NXP_Global_Customer_Master_ID__c,Email,Status,OwnerId,Industry,
                                         RecordTypeId,Account_Id__c,Description,street,city,country,state,company,PostalCode
                                         from lead where recordtype.name ='Uncategorized Leads' and status='Open' 
                                         and createddate <= :dt ]);
                                         
    	return lds;
                                             
    }
    
	global void execute(Database.BatchableContext BC, list<Lead> scope){
        list<Lead> listUnCategorizedLeads= (list<Lead>)scope;                                
		LeadOwnerAssignmentHandler leadOwnerAssgnmt = new LeadOwnerAssignmentHandler();
        LeadOwnerAssignmentHandler.conEmailBasedAsgmnt(listUnCategorizedLeads);       
    }
    
   	global void finish(Database.BatchableContext BC){
        database.executebatch(new LeadOwnerAssignmentROMBatch());
   	}

}