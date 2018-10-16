/*************************************************************************
@Created By:     Jewelslyn
@Description:    Trigger for updates in Lead
-----------------------------------------------------------------
@Modified By:     Jewelslyn
@Modified Date:   22 Sep 2017
@Description:    Modified trigger to include random Token generation and to update the Disti contact
if disti contact is not same as Disti feedback email provided Disti feedback email exists in sfdc.
--------------------------------------------------------------------
@Modified By:     Jewelslyn
@Modified Date:   4 Dec 2017
@Description:    Modified trigger to include Sending emails to multiple distis
----------------------------------------------------------------------------
@Modified By:     Nisha Agrawal
@Modified Date:   Jun 20, 2018
@Description:     Modified trigger to include Lead record sharing with Disti Users
**************************************************************************/

trigger LeadTrigger on Lead (before insert,before update,after insert,after update) {
    Private Static Final string SENT_TO_DISTI='Sent to Distributor';
    if(Trigger.isbefore && Trigger.isInsert){
        LeadTriggerHandler.assignCountryNames(Trigger.new);    
    }else if(trigger.isbefore && Trigger.isUpdate){
        List<Lead> changedLeads = new List<Lead>();
        List<Lead> randomNumberLds = new List<Lead>();
        List<Lead> distiContactUpdateLds = new List<Lead>();
        //List<Lead> listEmailToDistiLds = new List<Lead>();
        for(Lead newld:Trigger.new){
            Lead oldLd = Trigger.oldMap.get(newld.Id);
            if(oldLd !=null &&((oldLd.Country != newLd.Country) || (oldLd.State != newLd.State))){
                changedLeads.add(newld);
            }
            if(oldLd !=null &&((oldLd.distributor_contact__c != newLd.distributor_contact__c) || 
            (oldLd.Note_To_Disti__c != newLd.Note_To_Disti__c))){
                randomNumberLds.add(newld);
            }
            /*if(newLd.Status==SENT_TO_DISTI || oldLd.Note_To_Disti__c != newLd.Note_To_Disti__c){
                listEmailToDistiLds.add(newLd);
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
        /*if(listEmailToDistiLds!=null &&(!listEmailToDistiLds.isEmpty()) && LeadTriggerHandler.recursionCheck ==True){            
               LeadTriggerHandler.emailToMultipleDistis(listEmailToDistiLds);                         
        }
        /*if(distiContactUpdateLds !=null &&(!distiContactUpdateLds.isEmpty())){
            LeadTriggerHandler.distContactUpdate(distiContactUpdateLds);
        }*/
    }
    if(trigger.isAfter && trigger.isInsert){
        
    }
    if(trigger.isAfter && trigger.isUpdate){
        list<Lead> listConvertedLeads=new list<lead>();
        List<Id> listEmailToDistiLds = new List<Id>();
        
                
         //Added by Ranganath --(SFDC-1708) 
        //rejected lead
        List<Lead> distiExpiredLeads = new List<Lead>();
        List<Lead> rejectedLeads = new List<Lead>();
        
        for(lead newld:trigger.new){
            Lead oldLd = Trigger.oldMap.get(newld.Id);
            if(newld.IsConverted && !oldLd.IsConverted){
                listConvertedLeads.add(newld);
            }
            if((oldLd.status !=SENT_TO_DISTI && newLd.Status==SENT_TO_DISTI)){
                listEmailToDistiLds.add(newLd.id);
           }
             //Added by Ranganath --(SFDC-1708) 
            //check if new value is rejected
            if(oldLd.status !='Disti Expired' && newLd.Status=='Disti Expired'&& 
               (newLd.Disti_Feedback_Email_Address__c==null || 
                newLd.Disti_Feedback_Email_Address__c.trim().length()==0)){
                distiExpiredLeads.add(newLd);
            }

            if(oldLd.status !='Rejected' && newLd.Status=='Rejected'){
                rejectedLeads.add(newLd);
            }           
            
        }
        if(listConvertedLeads!=null && (!listConvertedLeads.isEmpty())){
            LeadTriggerHandler.insertContactRoles(listConvertedLeads);
        }
        if(listEmailToDistiLds!=null &&(!listEmailToDistiLds.isEmpty()) && LeadTriggerHandler.recursionCheck ==True){            
               LeadTriggerHandler.emailToMultipleDistis(listEmailToDistiLds); 
                LeadTriggerHandler.recursionCheck=false;                        
        }
        
       if(distiExpiredLeads!=null && (!distiExpiredLeads.isEmpty())){
            LeadTriggerHandler.assignNewDistiFromQueue(distiExpiredLeads);    
        } 
        
        if(rejectedLeads!=null &&(!rejectedLeads.isEmpty()) ){            
               LeadTriggerHandler.rejectedleadswithreason(rejectedLeads);                         
        } 
        
        //code added by Nisha Agrawal on Jun 20, 2018
        LeadTriggerHandler.shareLeadRecordsToLPUsers(trigger.new, trigger.oldmap);
    }
    
}