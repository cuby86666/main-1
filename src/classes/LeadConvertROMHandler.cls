/*************************************************************************
@Created By:     Jewelslyn
@Description:    class for Lead Conversion using Feedback loop Logic
**************************************************************************/

/*************************************************************************
@Modified By:     Jewelslyn
@Modified Date:   22 Sep 2017
@Description:    Modified class to include Updating the contact to Disti account 
if a contact is identified based on Lead's Email and associated to a different Account
**************************************************************************/
/*************************************************************************
@Modified By:    Harish Gowda
@Modified Date:   16 JUN 2017
@Description:    Modified class to allow conversion of Leads for Currency ISO diferrence(SFDC-1620)
**************************************************************************/
public class LeadConvertROMHandler {    
    public static set<string> strLeadEmail;
    public static set<string> strLeadDistiNum;
    public static set<string> strLeadIds;
    public static set<string> strLeadIdsToSeperate;
    
    public static map<string,contact> mapEmailToContact;    
    public static map<string,Opportunity> mapDistiNumToOppty;
    public static map<string,Opportunity> mapLeadIdToOppty;
    public static List<OpportunityContactRole> listNewContactRole;    
        
    public static void insertContactRole(list<Lead> listLeadToConvert){        
        strLeadEmail=new set<string>();
        strLeadDistiNum=new Set<string>();
        strLeadIds=new set<string>();
        strLeadIdsToSeperate=new set<string>();
        mapEmailToContact=new map<string,contact>();
        mapDistiNumToOppty=new map<string,Opportunity>();
        mapLeadIdToOppty=new map<string,Opportunity>();
        listNewContactRole = new List<OpportunityContactRole>();
        list<contact> listNewContact=new list<contact>();
        list<contact> listContactIdsToUpdate=new list<contact>();
        list<lead> listNewLead=new list<lead>();                
        for(lead ld:listLeadToConvert){
            strLeadIds.add(ld.Id);
            if(ld.email!=null){
                strLeadEmail.add(ld.email);
            }            
            if(ld.Distributor_Tracking_Number__c != null){
                strLeadDistiNum.add(ld.Distributor_Tracking_Number__c);
            }
        }        
        list<contact> listContact=[select id, email,AccountId from contact where email In:strLeadEmail];
        list<Opportunity> listOpp=[Select id, Distributor_Tracking_Number__c,Lead_Id__c,AccountId,CreatedDate,CurrencyIsoCode from Opportunity where 
                                   (Distributor_Tracking_Number__c IN:strLeadDistiNum OR Lead_Id__c IN:strLeadIds)
                                   AND RecordType.Name='Model N Oppty' AND 
                                   (CreatedDate = LAST_N_DAYS:365 OR CreatedDate = TODAY)];
        for(opportunity opp:listOpp){
            if(opp.Distributor_Tracking_Number__c!=null){
                if(!mapDistiNumToOppty.containskey(opp.Distributor_Tracking_Number__c)){
                mapDistiNumToOppty.put(opp.Distributor_Tracking_Number__c,opp);
                }
            }
            if(opp.Lead_Id__c != null){
                if(!mapLeadIdToOppty.containskey(opp.Lead_Id__c)){
                   mapLeadIdToOppty.put(opp.Lead_Id__c,opp); 
                }
            }
        }                                           
        for(contact con:listContact){
            if(!mapEmailToContact.containskey(con.email) && con.email!=null){
                mapEmailToContact.put(con.email,con);                
            }
        }
        List<Lead> leadsWithUpdatedCurr= new List<Lead>();
        for(lead ld:listLeadToConvert){
            if(mapEmailToContact.containskey(ld.email) && ld.email!=null){ 
               If(mapDistiNumToOppty.containskey(ld.Distributor_Tracking_Number__c)){
                   if(mapEmailToContact.get(ld.email).accountId !=
                      mapDistiNumToOppty.get(ld.Distributor_Tracking_Number__c).accountId){
                          mapEmailToContact.get(ld.email).accountId=mapDistiNumToOppty.get
                              (ld.Distributor_Tracking_Number__c).accountId; 
                            listContactIdsToUpdate.add(mapEmailToContact.get(ld.email));
                      }
                      // added to allow conversion of Leads for Currency ISO diferrence(SFDC-1620)
                      if(ld.CurrencyIsoCode !=  mapDistiNumToOppty.get(ld.Distributor_Tracking_Number__c).CurrencyIsoCode){
                         ld.CurrencyIsoCode =  mapDistiNumToOppty.get(ld.Distributor_Tracking_Number__c).CurrencyIsoCode;
                         leadsWithUpdatedCurr.add(ld);       
                      }   
               }
                   
                   if(mapLeadIdToOppty.containsKey(ld.Id)){
                       if(mapEmailToContact.get(ld.email).accountId != mapLeadIdToOppty.get(ld.Id).accountId){
                        mapEmailToContact.get(ld.email).accountId=mapLeadIdToOppty.get(ld.Id).accountId;
                            listContactIdsToUpdate.add(mapEmailToContact.get(ld.email));
                        }
            // added to allow conversion of Leads for Currency ISO diferrence(SFDC-1620)            
      if(ld.CurrencyIsoCode !=  mapLeadIdToOppty.get(ld.Id).CurrencyIsoCode){
                         ld.CurrencyIsoCode =  mapLeadIdToOppty.get(ld.Id).CurrencyIsoCode;
                         leadsWithUpdatedCurr.add(ld);  
          
                      }
                   }                                  
            }
        }
        // added to allow conversion of Leads for Currency ISO diferrence(SFDC-1620)
        if(!leadsWithUpdatedCurr.isEmpty()){
            update leadsWithUpdatedCurr ;
        }
        update listContactIdsToUpdate;
        for(lead ld:listLeadToConvert){            
             if(!mapEmailToContact.containskey(ld.email)){ 
                if(mapDistiNumToOppty.containskey(ld.Distributor_Tracking_Number__c)){
                    listNewContact.add(new contact(FirstName=ld.FirstName,LastName=ld.LastName,email = ld.email,
                                              accountId=mapDistiNumToOppty.get(ld.Distributor_Tracking_Number__c).accountId));
                    strLeadIdsToSeperate.add(ld.Id);
                }
                if(mapLeadIdToOppty.containsKey(ld.Id) && (!strLeadIdsToSeperate.contains(ld.Id))){
                    listNewContact.add(new contact(FirstName=ld.FirstName,LastName=ld.LastName,email = ld.email,
                                              accountId=mapLeadIdToOppty.get(ld.Id).accountId));
                }                    
                listNewLead.add(ld);                        
            }                                                                  
        }        
        Database.SaveResult[] srList = Database.insert(listNewContact, false);
        system.debug('contact::'+srList);
        Set<Id> contactId=new Set<Id>();
        for(Database.SaveResult sr : srList){
            if (sr.isSuccess()){
                contactId.add(sr.getId());
            }
        }
        if(srList.size()!=0){
            list<contact> listContactNew=[select id,AccountId, email from contact where Id In:contactId];
            for(contact con:listContactNew){
                if(!mapEmailToContact.containskey(con.email) && con.email!=null){
                    mapEmailToContact.put(con.email,con);
                }
            }                              
        }                      
    }        
    public static void convertLead(list<Lead> listLeadToConvert){   
        insertContactRole(listLeadToConvert);        
        list<Database.LeadConvert> leadConverts=new list<Database.LeadConvert>();
        //Database.LeadConvert[] converts = new Database.LeadConvert[0];
        String convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;                
            for(lead ld:listLeadToConvert){
            Database.LeadConvert lc = new Database.LeadConvert();               
            lc.setLeadId(ld.Id);            
            //lc.setDoNotCreateOpportunity(true);            
            if(mapDistiNumToOppty.containskey(ld.Distributor_Tracking_Number__c) ){
                if(mapDistiNumToOppty.get(ld.Distributor_Tracking_Number__c).accountId != null &&
                  mapDistiNumToOppty.get(ld.Distributor_Tracking_Number__c).Id != null){                    
                        lc.setAccountId(mapDistiNumToOppty.get(ld.Distributor_Tracking_Number__c).accountId);
                          lc.setContactId(mapEmailToContact.get(ld.email).Id);
                          system.debug('oppId'+mapDistiNumToOppty.get(ld.Distributor_Tracking_Number__c).Id);
                        lc.setOpportunityId(mapDistiNumToOppty.get(ld.Distributor_Tracking_Number__c).Id);                    
                      lc.setConvertedStatus(convertedStatus);
                      leadConverts.add(lc);
                }                
            }
            if(mapLeadIdToOppty.containsKey(ld.Id) && (!strLeadIdsToSeperate.contains(ld.Id))){
                if(mapLeadIdToOppty.get(ld.Id).AccountId !=null){
                    lc.setAccountId(mapLeadIdToOppty.get(ld.Id).accountId);
                    lc.setContactId(mapEmailToContact.get(ld.email).Id);
                    system.debug('ConId1::'+mapEmailToContact.get(ld.email).Id);
                    lc.setOpportunityId(mapLeadIdToOppty.get(ld.Id).Id);
                    lc.setConvertedStatus(convertedStatus);
                    leadConverts.add(lc);
                }                
            }                               
        }        
        if(!leadConverts.isEmpty()){
            try{
                List<Database.LeadConvertResult> lcr= Database.convertLead(leadConverts,false);                                
            }
           catch (Exception e){
           System.debug('error --'+ e.getStackTraceString());
               system.debug('message::'+e.getTypeName() + ': ' + e.getMessage()
                    + ' -- ' + e.getCause());
            }            
        }                
    }
}