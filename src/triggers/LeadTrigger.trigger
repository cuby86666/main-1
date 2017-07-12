trigger LeadTrigger on Lead (before insert,before update) {
    if(Trigger.isInsert){
    	LeadTriggerHandler.assignCountryNames(Trigger.new);    
    }else if(Trigger.isUpdate){
        List<Lead> changedLeads = new List<Lead>();
        for(Lead newld:Trigger.new){
            Lead oldLd = Trigger.oldMap.get(newld.Id);
            if(oldLd !=null &&((oldLd.Country != newLd.Country) || (oldLd.State != newLd.State))){
                changedLeads.add(newld);
            }
        }
        if(changedLeads !=null && (!changedLeads.isEmpty())){
        	LeadTriggerHandler.assignCountryNames(changedLeads);    
        }        
    }
	
}