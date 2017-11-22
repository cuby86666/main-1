/*************************************************************************
@Created By:     Jewelslyn
@Description:    Trigger for updates in Lead
**************************************************************************/

/*************************************************************************
@Modified By:     Jewelslyn
@Modified Date:   22 Sep 2017
@Description:    Modified trigger to include random Token generation and to update the Disti contact
if disti contact is not same as Disti feedback email provided Disti feedback email exists in sfdc.
**************************************************************************/

trigger LeadTrigger on Lead (before insert,before update,after insert,after update) {
    if(Trigger.isbefore && Trigger.isInsert){
        LeadTriggerHandler.assignCountryNames(Trigger.new);    
    }else if(trigger.isbefore && Trigger.isUpdate){
        List<Lead> changedLeads = new List<Lead>();
        List<Lead> randomNumberLds = new List<Lead>();
        List<Lead> distiContactUpdateLds = new List<Lead>();
        for(Lead newld:Trigger.new){
            Lead oldLd = Trigger.oldMap.get(newld.Id);
            if(oldLd !=null &&((oldLd.Country != newLd.Country) || (oldLd.State != newLd.State))){
                changedLeads.add(newld);
            }
            if(oldLd !=null &&((oldLd.distributor_contact__c != newLd.distributor_contact__c) || 
            (oldLd.Note_To_Disti__c != newLd.Note_To_Disti__c))){
                randomNumberLds.add(newld);
            }
            /*if(oldLd !=null&&((newLd.distributor_contact__r.Email != newLd.Disti_Feedback_Email_Address__c)) &&
               (newld.Status =='Accepted by Disti' || newld.Status =='Rejected by Disti') &&
               newLd.Disti_Feedback_Email_Address__c !=null) {
                   distiContactUpdateLds.add(newLd);
               }*/
        }
        if(changedLeads !=null && (!changedLeads.isEmpty())){
            LeadTriggerHandler.assignCountryNames(changedLeads);    
        }
        if(randomNumberLds!=null &&(!randomNumberLds.isEmpty())){
            LeadTriggerHandler.assignRandomString(randomNumberLds);
        }
        /*if(distiContactUpdateLds !=null &&(!distiContactUpdateLds.isEmpty())){
            LeadTriggerHandler.distContactUpdate(distiContactUpdateLds);
        }*/
    }
    if(trigger.isAfter && trigger.isInsert){
        
    }
    if(trigger.isAfter && trigger.isUpdate){
        list<Lead> listConvertedLeads=new list<lead>();
        for(lead newld:trigger.new){
            Lead oldLd = Trigger.oldMap.get(newld.Id);
            if(newld.IsConverted && !oldLd.IsConverted){
                listConvertedLeads.add(newld);
            }
        }
        if(listConvertedLeads!=null && (!listConvertedLeads.isEmpty())){
            LeadTriggerHandler.insertContactRoles(listConvertedLeads);
        }
        
    }
    
}