public class SendLeadDetailsToDistiController {

    @AuraEnabled 
    public static String sendLeadToDisti(String leadId,String primaryContactId, String primaryAdditionalEmail,
                                         String secondaryContactId, String secondaryAdditionalEmail,
                                         boolean expiresWithPrimary,boolean rejectedByPrimary,
                                         String notesToDisti){
                                             List<String> operationsDone= new List<String>();
                                             List<Distributor_Lead_Tracker__c> dlts= new  List<Distributor_Lead_Tracker__c>(); 
                                             
                                             if(primaryContactId != null && primaryContactId.trim().length()>0){
                                                 Distributor_Lead_Tracker__c primaryDisti = new Distributor_Lead_Tracker__c(
                                                     Lead_Id__c=leadId,
                                                     Distributor_Contact__c=primaryContactId,
                                                     Additional_Email__c=primaryAdditionalEmail,
                                                     Status__c='Assigned'
                                                 );
                                                 dlts.add(primaryDisti); 
                                                 operationsDone.add('Primary distributor assigned.');
                                                 operationsDone.add('Email has been sent successfully to primary distributor,please refresh the web page to see updated information.');
                                             }
                                             if(secondaryContactId != null && secondaryContactId.trim().length()>0){
                                                 Distributor_Lead_Tracker__c secondaryDisti = new Distributor_Lead_Tracker__c(
                                                     Lead_Id__c=leadId,
                                                     Distributor_Contact__c=secondaryContactId,
                                                     Additional_Email__c=secondaryAdditionalEmail,
                                                     Status__c='Queued'
                                                 );
                                                 dlts.add(secondaryDisti);
                                                 operationsDone.add('Secondary distributor assigned.');                                                 
                                             }
 
                                             Lead relatedLead = new Lead(Id=leadId,Note_to_Disti__c=notesToDisti);
                                             if(primaryContactId!=null &&primaryContactId.trim().length()>0){
                                                relatedLead.Distributor_Contact__c =primaryContactId;    
                                             }
                                             operationsDone.add('Notes to Disti updated'); 
                                             update relatedLead;   
                                             if(!dlts.isEmpty()){
                                                 insert dlts;                                                 
                                             }                                              
                                             return getDistiContactsForLead(leadId,operationsDone);
                                    }
    
    @AuraEnabled
    public static String getDistiContactsForLead(String leadId,List<String> messages){
        List<Distributor_Lead_Tracker__c> dlcds = [SELECT Id,Name,Distributor_Contact__r.Name,Distributor_Contact__r.Email,
                                                   Additional_Email__c,Status__c from Distributor_Lead_Tracker__c 
                                                   where Lead_Id__c=:leadId];
        System.debug('results '+dlcds+' for lead Id '+leadId);
        Lead ld = [SELECT Id,Note_To_Disti__c from Lead where Id=:leadId];
        if(dlcds!=null && (!dlcds.isEmpty())){
            
            //String notesToDisti = ld.Note_To_Disti__c;
            LeadDistiContactDetails ldc = new LeadDistiContactDetails();
            for(Distributor_Lead_Tracker__c dlc:dlcds){
                if(dlc.Status__c == 'Assigned'){
                    ldc.primaryDistiContact=new DistiContact(dlc.id,dlc.Distributor_Contact__r.Name+'('+dlc.Distributor_Contact__r.Email+')',dlc.Additional_Email__c,'Assigned');
                }else if(dlc.Status__c == 'Queued'){
                    ldc.secondaryDistiContact=new DistiContact(dlc.id,dlc.Distributor_Contact__r.Name+'('+dlc.Distributor_Contact__r.Email+')',dlc.Additional_Email__c,'Queued');
                }           
            }
            ldc.notesToDisti=ld.Note_To_Disti__c;
            //ldc.rejectedByPrimary=ld.Gets_rejected_by_Primary_Distributor__c;
            //ldc.expiresWithPrimary=ld.Expires_with_Primary_Distributor__c;
            if(messages !=null && (!messages.isEmpty())){
                ldc.messages=messages;
            }
            System.debug('final results '+ldc+' for lead Id '+leadId);
            return Json.serialize(ldc);                    
        }else{
            LeadDistiContactDetails ldc = new LeadDistiContactDetails();
            ldc.notesToDisti= ld.Note_To_Disti__c;
            //ldc.expiresWithPrimary=ld.Expires_with_Primary_Distributor__c;
            return  Json.serialize( ldc);
        }        

    }
    
    @AuraEnabled
    public static String deleteSecondary(String idToDelete,String leadId){
        Distributor_Lead_Tracker__c dlt = [SELECT Id from Distributor_Lead_Tracker__c where Id = :idToDelete];
        System.debug('dlt '+dlt);
        delete dlt;
        /*Lead relatedLead = new Lead(Id=leadId,Expires_with_Primary_Distributor__c=false);
        update relatedLead;*/
        List<String> msg = new List<String>();
        msg.add('Secondary queued contact deleted');
        return getDistiContactsForLead(leadId,msg);
    }
    
    public class LeadDistiContactDetails{
        public DistiContact primaryDistiContact{get;set;}
        public DistiContact secondaryDistiContact{get;set;}
        public String notesToDisti{get;set;}
        public boolean expiresWithPrimary{get;set;}
        public boolean rejectedByPrimary{get;set;}
        public List<String> messages{get;set;}
    }
    
    public class DistiContact{

        public DistiContact(String currrecordId,String contactDetails,String additionalEmail,String assignedLeadStatus){
            recordId=currrecordId;
            distiContact = contactDetails;
            distiAdditionalEmail=additionalEmail;
            assignedLeadStatus=assignedLeadStatus;
        }
        public String recordId{get;set;}
        public String distiContact{get;set;}
        public String distiAdditionalEmail{get;set;}
        public String assignedLeadStatus{get;set;}
    }
    
}