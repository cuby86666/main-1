global class UpdateWrapupCodesForNCRO implements Database.Batchable<SObject>,Database.Stateful,Schedulable {
	    global integer totalNumberOfRecords=0;
    	global integer recordsUpdated=0;
	    global Database.QueryLocator start(Database.BatchableContext bc) {
			return Database.getQueryLocator([SELECT Id,Wrapup_String_1__c, Wrapup_String_2__c, Bridge_UUID__c from Natterbox_Call_Reporting_Object__c where (Wrapup_String_1__c = null OR Wrapup_String_2__c = null) and Bridge_UUID__c <> null]);	    
	    } 
	    
    
    	global void execute(SchedulableContext sc){
            Database.executeBatch(this);
        }
    
	    global void execute(Database.BatchableContext bc, List<Natterbox_Call_Reporting_Object__c> ncros){
			List<String> bridgeUUId = new List<String>();
			Map<String,Natterbox_Call_Reporting_Object__c> uuidToNCRO = new Map<String,Natterbox_Call_Reporting_Object__c>();
			Map<String,Natterbox_Call_Reporting_Object__c> updatedNCROS = new Map<String,Natterbox_Call_Reporting_Object__c>();
			totalNumberOfRecords+=ncros.size();
			for(Natterbox_Call_Reporting_Object__c ncro : ncros){
			    bridgeUUId.add(ncro.Bridge_UUID__c);
			    uuidToNCRO.put(ncro.Bridge_UUID__c,ncro);	
			}
			if(!bridgeUUId.isEmpty()){
                
			    List<Task> allTask = [SELECT Id,UUID__c, Wrapup0__c, Wrapup1__c FROM Task where UUID__C in :bridgeUUId];
			    for(Task t : allTask){
			        Natterbox_Call_Reporting_Object__c ncro = uuidToNCRO.get(t.UUID__c);
			        if(ncro!=null){
			            ncro.Wrapup_String_1__c = t.Wrapup0__c;
			            ncro.Wrapup_String_2__c = t.Wrapup1__c;
			            updatedNCROS.put(ncro.id,ncro);
			        }
			    }
			}
			if(!updatedNCROS.isEmpty()){
			    List<Natterbox_Call_Reporting_Object__c> finalList=new List<Natterbox_Call_Reporting_Object__c>();
			    finalList.addAll(updatedNCROS.values());
			    Database.SaveResult[] srList = Database.update(finalList,false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess())
                        recordsUpdated++;
                }                
			}	    	
	    }
	    
	    global void finish(Database.BatchableContext bc){
                List<User> users= [SELECT Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName ='CTI_Admins')];
                Set<String> emailIds = new Set<String>();
                for(User u:users){
                    emailIds.add(u.email);    
                }
                List<String> finalemailId = new List<String>();
                finalemailId.addAll(emailIds);
            	System.debug('The job completed successfully.There were '+totalNumberOfRecords+' records found and '+recordsUpdated+' records were updated with wrapup codes  ');
                if(!finalemailId.isEmpty()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(finalemailId);
                    mail.setSaveAsActivity(false);
                    mail.setSubject('NCRO Batch Job Status Report');
                    mail.setPlainTextBody('The job completed successfully.There were '+totalNumberOfRecords+' records found and '+recordsUpdated+' records were updated with wrapup codes  ');
                    if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox==false){
                    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }    
                }                
	    }
}