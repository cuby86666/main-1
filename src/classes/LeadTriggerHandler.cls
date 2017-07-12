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
                if(!mapCountryCodeToName.containskey(settings.country_Code__c)){
                	mapCountryCodeToName.put(settings.country_Code__c,settings.Country__c);
            	}
            }
            if(settings.State__c !=null && settings.state_Code__c!=null){
                if(!mapStateCodeToState.containskey(settings.state_Code__c)){
                	mapStateCodeToState.put(settings.state_Code__c,settings.State__c );
            	}
            }
            if(settings.Region__c!=null && settings.country_Code__c !=null){
                if(!mapCountryToRegion.containskey(settings.country_Code__c)){
                    mapCountryToRegion.put(settings.country_Code__c,settings.Region__c);
                }
            }
                system.debug('settRe:'+mapCountryToRegion);
        }
        for(lead ld:listNewLeads){
            if(ld.country!=null){
				if(mapCountryToRegion.containsKey(ld.country)){
                    if(mapCountryToRegion.get(ld.country) !=null){
                        ld.Region__c=mapCountryToRegion.get(ld.country);                    
                    }
                    if(mapCountryCodeToName.get(ld.country) !=null){
                        ld.country=mapCountryCodeToName.get(ld.country);
                    }                    
                }                                                               
            }
            if(ld.State!=null){
               if(mapStateCodeToState.containskey(ld.State) && mapStateCodeToState.get(ld.State) !=null){                    
                   ld.State=mapCountryCodeToName.get(ld.State); 
                } 
            }
            
        }        
    }

}