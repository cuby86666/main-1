/*************************************************************************
@Created By:     Jewelslyn
@Description:    class for Lead Trigger to update the country ,state, region based on Lead country Settings.
**************************************************************************/

/*************************************************************************
@Modified By:     Jewelslyn
@Modified Date:   22 Sep 2017
@Description:    Modified class to include random Token generation and to update the Disti contact
if disti contact is not same as Disti feedback email provided Disti feedback email exists in sfdc.
**************************************************************************/

public class LeadTriggerHandler {
    public static map<string,string> mapCountryCodeToName;
    public static map<string,string> mapStateCodeToState;
    public static map<string,string> mapCountryToRegion;
    public static void assignCountryNames(List<Lead> listNewLeads){
        list<LeadCountrySettings__c> lstLeadCountrySettings=[select id,Country__c,country_Code__c,State__c,Region__c,State_Code__c 
                                                             from LeadCountrySettings__c];
        mapCountryCodeToName=new map<string,string>();
        mapStateCodeToState=new map<string,string>(); 
        mapCountryToRegion=new map<string,string>();
        for(LeadCountrySettings__c settings:lstLeadCountrySettings){            
            if(settings.Country__c !=null && settings.country_Code__c!=null){
                if(!mapCountryCodeToName.containskey(settings.country_Code__c.toUpperCase())){
                	mapCountryCodeToName.put(settings.country_Code__c.toUpperCase(),settings.Country__c);
            	}
            }
            if(settings.State__c !=null && settings.state_Code__c!=null){
                if(!mapStateCodeToState.containskey(settings.state_Code__c.toUpperCase())){
                	mapStateCodeToState.put(settings.state_Code__c.toUpperCase(),settings.State__c);
            	}
            }
            if(settings.Region__c!=null && settings.country_Code__c !=null){
                if(!mapCountryToRegion.containskey(settings.country_Code__c.toUpperCase())){
                    mapCountryToRegion.put(settings.country_Code__c.toUpperCase(),settings.Region__c);
                }
            }
                system.debug('settRe:'+mapCountryToRegion);
        }
        for(lead ld:listNewLeads){
			 ld.Region__c=null;           
            if(ld.country!=null){
				if(mapCountryToRegion.containsKey(ld.country.toUpperCase())){
                    system.debug('settRe1:'+mapCountryToRegion);
                    if(mapCountryToRegion.get(ld.country.toUpperCase()) !=null){
                        ld.Region__c=mapCountryToRegion.get(ld.country.toUpperCase());                    
                    }
                }   
                if(mapCountryCodeToName.containsKey(ld.country.toUpperCase())){   
                	if(mapCountryCodeToName.get(ld.country.toUpperCase()) !=null){
                        ld.country=mapCountryCodeToName.get(ld.country.toUpperCase());
                    }                    
            	}                                                                
            }
            if(ld.State!=null){
               if(mapStateCodeToState.containskey(ld.State.toUpperCase()) && mapStateCodeToState.get(ld.State.toUpperCase()) !=null){                    
                   ld.State=mapCountryCodeToName.get(ld.State.toUpperCase()); 
                } 
            }
            
        }        
    }
    public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    	while (randStr.length() < len) {
       		Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       		randStr += chars.substring(idx, idx+1);
    	}
   		 return randStr; 
	}
    
    public static void assignRandomString(list<Lead> listLeads){
        for(lead ld:listLeads){
            ld.Token_Id__c=generateRandomString(8);
            system.debug('token::'+ld.Token_Id__c);
        }        
    }
    
   /* public static void distContactUpdate(list<lead> listDistiContactUpdateLds){
        set<string> strDistiFeedEmail=new set<string>();
        list<contact> listContact;
        map<id,string> mapLeadIdToDistiEmail=new map<id,string>();
        map<id,string> mapLeadIdToDistiFeedEmail=new map<id,string>();
        map<string,contact> mapConEmailToContact=new map<string,contact>();
        for(lead ld:listDistiContactUpdateLds){
            if(ld.Disti_Feedback_Email_Address__c!=null){
                strDistiFeedEmail.add(ld.Disti_Feedback_Email_Address__c);
            }
            if(!mapLeadIdToDistiEmail.containskey(ld.Id)){
               mapLeadIdToDistiEmail.put(ld.Id,ld.Distributor_Contact__r.email); 
            }
            if(!mapLeadIdToDistiFeedEmail.containskey(ld.Id)){
               mapLeadIdToDistiFeedEmail.put(ld.Id,ld.Disti_Feedback_Email_Address__c); 
            }
        }
        listContact=[Select Id, email,accountId from Contact where email In:strDistiFeedEmail];
        for(contact con:listContact){
            if(!mapConEmailToContact.containskey(con.Email)){
                mapConEmailToContact.put(con.Email,con);
                system.debug('Contactnew::'+mapConEmailToContact);
            }
        }
        for(lead ld:listDistiContactUpdateLds){
            if(mapLeadIdToDistiEmail.containskey(ld.Id) && mapLeadIdToDistiFeedEmail.containskey(ld.Id)){
                if(mapLeadIdToDistiEmail.get(ld.Id) != mapLeadIdToDistiFeedEmail.get(ld.Id) &&
                  mapConEmailToContact.containskey(mapLeadIdToDistiFeedEmail.get(ld.Id))){
                    ld.Distributor_Contact__c=mapConEmailToContact.get(mapLeadIdToDistiFeedEmail.get(ld.Id)).Id;
                }
            }
              
        }
    }*/
    public static void insertContactRoles(list<lead> listConvertedLeads){        
        set<string> setOppConIdExists=new set<string>();
        set<string> setOppIds=new Set<string>();
        map<string, opportunityContactRole> mapOppConRole=new map<string, opportunityContactRole>();
        string oppConId;
        for(lead ld:listConvertedLeads){            
            oppConId=ld.ConvertedOpportunityId +'*'+ ld.ConvertedContactId;			
            if(!mapOppConRole.containskey(oppConId)){
                mapOppConRole.put(oppConId,new OpportunityContactRole(opportunityId=ld.ConvertedOpportunityId,ContactId=
                                                                 ld.ConvertedContactId));
            }            
            setOppIds.add(ld.ConvertedOpportunityId);
        }
        list<opportunityContactRole> listOppConRole=[select id,opportunityId, ContactId from OpportunityContactRole
                                                    where OpportunityId IN:setOppIds];
        for(opportunityContactRole oppcon:listOppConRole){
            string oppConIdExists=oppcon.opportunityId +'*'+ oppcon.ContactId;            
            if(mapOppConRole.containskey(oppConIdExists)){
                mapOppConRole.remove(oppConIdExists);                
            }                        
        }
        if(!mapOppConRole.isEmpty()){
          Database.insert(mapOppConRole.values());	     
        }               
    }
}