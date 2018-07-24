/******************************************************************************
 * Created By: Jewelslyn
 * Created Date : May 18,2017
 * Description : Created this class to handle Owner Assignment for Leads.
*******************************************************************************/

public class LeadOwnerAssignmentHandler { 
    public static String AA_LEAD_RECORD_TYPE;
    public static String TMMA_LEAD_RECORD_TYPE;
    public static String ROM_LEAD_RECORD_TYPE;
    public static string UNCATEGORIZED_RECORD_TYPE;
    public static string CHILD_RECORD_TYPE;
    public static string PARENT_RECORD_TYPE;
    
    public static Set<string> strLeadEmail;
    public static Set<string> strLeadGIDs;
    public static Set<string> strLeadCountry;
    public static Set<string> strLeadState;
    public static Set<string> strLeadCity;
    public static set<string> strAccountName;
    public static set<string> strLeadCompany;
    public static set<string> strLeadPostalCode;
   
    
    public static map<string,Account> mapEmailToAccount;
    public static map<string,Account> mapGIdsToAccount;
    public static map<string,Account> mapGIdsToParentAccount;
    public static map<string,list<Account>> mapParentIdsToAccountList;
    public static map<string,list<Account>> mapGIdsToAccountList;
    public static map<string,set<string>> mapGIdsToRecordTypes;
    public static map<string,map<string,map<string,Account>>> mapAccntNameToAddressAccnt;
            
    static{
        init();
    }
    public static void init(){
        List<RecordType> recordTypes = [Select Id,name,developername From RecordType where sobjecttype = 'Lead' OR sobjecttype = 'Account'];        
        for(RecordType rt : recordTypes){
            if(rt.DeveloperName == 'Assigned_Account_Leads'){
                AA_LEAD_RECORD_TYPE = rt.Id;    
            }else if(rt.DeveloperName == 'TMMA_Leads'){
                TMMA_LEAD_RECORD_TYPE=rt.Id;
            }else if(rt.DeveloperName == 'ROM_Leads'){
                ROM_LEAD_RECORD_TYPE=rt.id;
            }else if(rt.DeveloperName == 'Uncategorized_Leads'){
                UNCATEGORIZED_RECORD_TYPE=rt.id;
            }
            else if(rt.DeveloperName == 'Child_Account'){
                CHILD_RECORD_TYPE=rt.id;
            }
            else if(rt.DeveloperName == 'Parent_Account'){
                PARENT_RECORD_TYPE=rt.id;
            }
        }
    }
    
    public static void fieldValueMapping(list<lead> listUnCategorizedLead){
        strLeadEmail=new Set<string>();
        strLeadGIDs=new Set<string>();
        strLeadCountry=new set<string>();
        strLeadState=new set<string>();
        strLeadCity=new set<string>();
        strLeadCompany=new set<string>();
        strLeadPostalCode=new set<string>();
                
        for(lead leadRec:listUnCategorizedLead){
            if(leadRec.email != null){
                strLeadEmail.add(leadRec.Email);                                                
            }
            if(leadRec.company!=null){
                strLeadCompany.add(leadRec.company);               
            }
            system.debug('comp::'+strLeadCompany);            
            if(leadRec.NXP_Global_Customer_Master_ID__c != null){
                strLeadGIDs.add(leadRec.NXP_Global_Customer_Master_ID__c);               
            }                       
            if( leadRec.Country!=null){
                strLeadCountry.add(leadRec.Country);
            } 
            If(leadRec.state!=null){                 
                strLeadState.add(leadRec.State);
            }
            if(leadRec.city!=null){
                strLeadCity.add(leadRec.city);
            }
            if(leadRec.PostalCode!=null){
                strLeadPostalCode.add(leadRec.PostalCode);
            }            
        }                          
    }
    
    public static void conEmailBasedAsgmnt(list<lead> listUnCategorizedLeadToUpdate){       
        fieldValueMapping(listUnCategorizedLeadToUpdate);        
        List<Contact> listContact=new list<contact>([Select id,AccountId,Account.RecordTypeId,Account.Name,Account.NXP_GID__c,
                                                     Email,Account.OwnerId,Account.IsInactive__c,Account.customer_category__c from contact where email IN:strLeadEmail]);
                                                            
        mapEmailToAccount=new map<string,Account>();
        if(listContact.size()!=0){
            for(contact con:listContact){
                if(con.AccountId!= null ){                    
                     mapEmailToAccount.put(con.Email,con.account);                                                        
                }                 
            }
        }                  
        for(lead ldToUpdate:listUnCategorizedLeadToUpdate){
            if(mapEmailToAccount.containsKey(ldToUpdate.Email)&&
              mapEmailToAccount.get(ldToUpdate.Email).RecordTypeId==CHILD_RECORD_TYPE &&
              mapEmailToAccount.get(ldToUpdate.Email).IsInactive__c==False){
                  if(mapEmailToAccount.get(ldToUpdate.Email).customer_category__c!='Tier 4 - ROM'){
                      ldToUpdate.OwnerId=mapEmailToAccount.get(ldToUpdate.Email).OwnerId;
                  }                
                  string AccountId=mapEmailToAccount.get(ldToUpdate.Email).Id;
                    ldToUpdate.Lead_Owner_Assignment__c='Owner is Assigned based on Contact Match of Account Id:' +AccountId;
                  ldToUpdate.Account_Id__c=AccountId;
                if(mapEmailToAccount.get(ldToUpdate.Email).customer_category__c=='Tier 4 - TMMA' ){                     
                            ldToUpdate.RecordTypeId=TMMA_LEAD_RECORD_TYPE;                     
                } 
                else if(mapEmailToAccount.get(ldToUpdate.Email).customer_category__c=='Tier 4 - ROM'){
                    ldToUpdate.RecordTypeId=ROM_LEAD_RECORD_TYPE;                    
                }  
                else if((mapEmailToAccount.get(ldToUpdate.Email).customer_category__c=='Tier 1' ||
                        mapEmailToAccount.get(ldToUpdate.Email).customer_category__c=='Tier 2' ||
                        mapEmailToAccount.get(ldToUpdate.Email).customer_category__c=='Tier 3')){
                    ldToUpdate.RecordTypeId=AA_LEAD_RECORD_TYPE;                    
                }  
            }                             
        }
        update listUnCategorizedLeadToUpdate;        
        list<lead> listLeadToNextMethod=new list<lead>();
        for(lead ld:listUnCategorizedLeadToUpdate){
            if(ld.RecordTypeId==UNCATEGORIZED_RECORD_TYPE){
                listLeadToNextMethod.add(ld);
            }
        }         
        leadGIdBasedAssgnmt(listLeadToNextMethod);
    }
    public static void leadGIdBasedAssgnmt(list<lead> listUnCategorizedLeads){
        fieldValueMapping(listUnCategorizedLeads);
       
        mapGIdsToAccountList=new map<string,list<Account>>();
        mapGIdsToRecordTypes=new map<string,set<string>>();
        mapGIdsToAccount=new map<string,Account>();
        mapGIdsToParentAccount=new map<string,account>();
        mapParentIdsToAccountList=new map<string,list<Account>>();
        Set<Id> parentAccountIds=new set<Id>();
        list<Account> listAccount=[SELECT Id,Name,NXP_GID__c,RecordTypeId,IsInactive__c ,Customer_Category__c,OwnerId from Account 
                                   where NXP_GID__c in :strLeadGIDs];        
        if(listAccount.size()!=0){
            for(account acc:listAccount){
                if(!mapGIdsToAccountList.containskey(acc.NXP_GID__c)){                  
                    mapGIdsToAccountList.put(acc.NXP_GID__c,new list<Account>{acc});                    
                }
                else if(mapGIdsToAccountList.containskey(acc.NXP_GID__c)){
                    mapGIdsToAccountList.get(acc.NXP_GID__c).add(acc);                    
                }                
            }   
        }
        for(lead ld:listUnCategorizedLeads){
            if(ld.NXP_Global_Customer_Master_ID__c !=null && mapGIdsToAccountList.containskey(ld.NXP_Global_Customer_Master_ID__c)){
                for(Account acc:mapGIdsToAccountList.get(ld.NXP_Global_Customer_Master_ID__c)){
                    if(!mapGIdsToRecordTypes.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                        mapGIdsToRecordTypes.put(ld.NXP_Global_Customer_Master_ID__c,new set<string>{acc.RecordTypeId});
                    }
                    else if(mapGIdsToRecordTypes.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                        mapGIdsToRecordTypes.get(ld.NXP_Global_Customer_Master_ID__c).add(acc.RecordTypeId);
                    }                    
                    if(acc.RecordTypeId==CHILD_RECORD_TYPE){
                        if(!mapGIdsToAccount.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                        mapGIdsToAccount.put(ld.NXP_Global_Customer_Master_ID__c,acc); 
                        }
                    }
                    if(acc.RecordTypeId==PARENT_RECORD_TYPE){
                        if(!mapGIdsToParentAccount.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                        mapGIdsToParentAccount.put(ld.NXP_Global_Customer_Master_ID__c,acc); 
                        }
                    }                    
                }
                if(mapGIdsToRecordTypes.get(ld.NXP_Global_Customer_Master_ID__c).contains(CHILD_RECORD_TYPE) &&
                  mapGIdsToRecordTypes.get(ld.NXP_Global_Customer_Master_ID__c).size()==1 &&
                  mapGIdsToAccount.containsKey(ld.NXP_Global_Customer_Master_ID__c)){                      
                      if(mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).IsInactive__c == False &&
                         mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).RecordTypeId==CHILD_RECORD_TYPE){
                             if(mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).customer_category__c!='Tier 4 - ROM'){
                                 ld.OwnerId=mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).OwnerId;
                             }                           
                             string AccountId=mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).Id;                           
                             ld.Lead_Owner_Assignment__c='Owner is Assigned based on Global Id  Match of Account Id:' +AccountId;
                            ld.Account_Id__c=AccountId;
                             if(mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).customer_category__c=='Tier 4 - TMMA'){                    
                                ld.RecordTypeId=TMMA_LEAD_RECORD_TYPE;                    
                            } 
                            else if(mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).customer_category__c=='Tier 4 - ROM'){
                                ld.RecordTypeId=ROM_LEAD_RECORD_TYPE;                    
                            }  
                            else if((mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).customer_category__c=='Tier 1' ||
                            mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).customer_category__c=='Tier 2' ||
                            mapGIdsToAccount.get(ld.NXP_Global_Customer_Master_ID__c).customer_category__c=='Tier 3')){
                                ld.RecordTypeId=AA_LEAD_RECORD_TYPE;                    
                            } 
                        }
                      
                }
                if(mapGIdsToRecordTypes.get(ld.NXP_Global_Customer_Master_ID__c).contains(PARENT_RECORD_TYPE) &&
                    mapGIdsToParentAccount.containsKey(ld.NXP_Global_Customer_Master_ID__c)){
                          if(mapGIdsToParentAccount.get(ld.NXP_Global_Customer_Master_ID__c).recordTypeID==PARENT_RECORD_TYPE){
                              parentAccountIds.add(mapGIdsToParentAccount.get(ld.NXP_Global_Customer_Master_ID__c).Id); 
                          }                                        
                    }                
                }
        } 
        
        list<Account> listChildAccounts=[Select id,Name,Parent.Id,country__c,OwnerId,IsInactive__c,state_province__c,city__c,NXP_GID__c,
                                         RecordTypeId,parent.NXP_GID__c,Customer_Category__c from Account where Parent.Id IN:parentAccountIds
                                         AND RecordTypeId=:CHILD_RECORD_TYPE and IsInactive__c=False];
        for(Account acc:listChildAccounts){
            if(!mapParentIdsToAccountList.containsKey(acc.Parent.NXP_GID__c)){
                mapParentIdsToAccountList.put(acc.Parent.NXP_GID__c,new list<account>{acc});
            }
            else if(mapParentIdsToAccountList.containsKey(acc.Parent.NXP_GID__c)){
                 mapParentIdsToAccountList.get(acc.Parent.NXP_GID__c).add(acc);
            }            
        }
        
        for(lead ld:listUnCategorizedLeads){
            map<string,map<string,Account>> mapAddressAccount=new map<string,map<string,Account>>();
            map<string,map<string,Account>> mapAddressCityAccount=new map<string,map<string,Account>>();
            map<string,account> mapCountryToAccount=new map<string,Account>();
            if(mapParentIdsToAccountList.containsKey(ld.NXP_Global_Customer_Master_ID__c) ) {                
                for(account acc:mapParentIdsToAccountList.get(ld.NXP_Global_Customer_Master_ID__c)){
                    if(acc.country__c !=null && acc.state_province__c!=null) {
                        if(!mapAddressAccount.containsKey(acc.country__c.toUpperCase())){
                        mapAddressAccount.put(acc.country__c.toUpperCase(),new map<string,Account>{acc.state_province__c.toUpperCase()=>acc});
                        }
                        else if(mapAddressAccount.containsKey(acc.country__c.toUpperCase())){
                        mapAddressAccount.get(acc.country__c.toUpperCase()).put(acc.state_province__c.toUpperCase(),acc);
                        }                                
                    }
                    if(acc.country__c !=null && acc.city__c!=null ){
                        if(!mapAddressCityAccount.containsKey(acc.country__c.toUpperCase())){
                        mapAddressCityAccount.put(acc.country__c.toUpperCase(),new map<string,Account>{acc.city__c.toUpperCase()=>acc});
                        }
                        else if(mapAddressCityAccount.containsKey(acc.country__c.toUpperCase())){
                        mapAddressCityAccount.get(acc.country__c.toUpperCase()).put(acc.city__c.toUpperCase(),acc);
                        } 
                    }
                    if(acc.country__c !=null){
                        if(!mapCountryToAccount.containskey(acc.country__c.toUpperCase())){
                         mapCountryToAccount.put(acc.country__c.toUpperCase(),acc);                            
                        }   
                    }                                                                                               
                }
             string ldCountry;  
             string ldState;
             string ldCity;
            if(ld.country!=null){
                ldCountry=ld.country.toUpperCase();
            }
            if(ld.state!=null){ 
                ldState=ld.state.toUpperCase();
                system.debug('state:'+ld.state);
            }
            if(ld.city!=null){
                ldCity=ld.city.toUpperCase();
                system.debug('city::'+ld.city);
            }
            
            if(mapAddressAccount.containsKey(ldCountry)){
                 system.debug('listtest23::'+ mapAddressAccount);
                if(mapAddressAccount.get(ldCountry).containskey(ldState)){
                   
                    if(mapAddressAccount.get(ldCountry).get(ldState).RecordTypeId==CHILD_RECORD_TYPE &&
                      mapAddressAccount.get(ldCountry).get(ldState).IsInactive__c==False){
                          if(mapAddressAccount.get(ldCountry).get(ldState).customer_category__c!='Tier 4 - ROM'){
                             ld.OwnerId=mapAddressAccount.get(ldCountry).get(ldState).OwnerId; 
                          }                        
                        string AccountId=mapAddressAccount.get(ldCountry).get(ldState).Id;
                      ld.Lead_Owner_Assignment__c='Owner is Assigned based on Address Match of Account Id:' +AccountId;
                        ld.Account_Id__c=AccountId;                                
                        if(mapAddressAccount.get(ldCountry).get(ldState).customer_category__c=='Tier 4 - TMMA'){
                            ld.RecordTypeId=TMMA_LEAD_RECORD_TYPE; 
                        }
                        else if(mapAddressAccount.get(ldCountry).get(ldState).customer_category__c=='Tier 4 - ROM'){
                            ld.RecordTypeId=ROM_LEAD_RECORD_TYPE; 
                        }
                        else if(mapAddressAccount.get(ldCountry).get(ldState).customer_category__c=='Tier 1' ||
                              mapAddressAccount.get(ldCountry).get(ldState).customer_category__c=='Tier 2' ||
                              mapAddressAccount.get(ldCountry).get(ldState).customer_category__c=='Tier 3'){
                            ld.RecordTypeId=AA_LEAD_RECORD_TYPE; 
                        }
                    } 
                }
            }
            if(mapAddressCityAccount.containskey(ldCountry)){   
                if(mapAddressCityAccount.get(ldCountry).containskey(ldCity)){                     
                    if(mapAddressCityAccount.get(ldCountry).get(ldCity).RecordTypeId==CHILD_RECORD_TYPE &&
                      mapAddressCityAccount.get(ldCountry).get(ldCity).IsInactive__c==False){
                          if(mapAddressCityAccount.get(ldCountry).get(ldCity).customer_category__c!='Tier 4 - ROM'){
                              ld.OwnerId=mapAddressCityAccount.get(ldCountry).get(ldCity).OwnerId;  
                          }                                              
                        string AccountId=mapAddressCityAccount.get(ldCountry).get(ldCity).Id;
                      ld.Lead_Owner_Assignment__c='Owner is Assigned based on Address Match of Account Id:' +AccountId;
                          ld.Account_Id__c=AccountId;
                        if(mapAddressCityAccount.get(ldCountry).get(ldCity).customer_category__c=='Tier 4 - TMMA'){
                            ld.RecordTypeId=TMMA_LEAD_RECORD_TYPE;                             
                        }
                        else if(mapAddressCityAccount.get(ldCountry).get(ldCity).customer_category__c=='Tier 4 - ROM'){
                            ld.RecordTypeId=ROM_LEAD_RECORD_TYPE; 
                        }
                        else if(mapAddressCityAccount.get(ldCountry).get(ldCity).customer_category__c=='Tier 1' ||
                              mapAddressCityAccount.get(ldCountry).get(ldCity).customer_category__c=='Tier 2' ||
                              mapAddressCityAccount.get(ldCountry).get(ldCity).customer_category__c=='Tier 3'){
                            ld.RecordTypeId=AA_LEAD_RECORD_TYPE; 
                        }
                    } 
                }
            }
            if(mapCountryToAccount.containskey(ldCountry) && mapAddressCityAccount.containskey(ldCountry)){
                if(!mapAddressCityAccount.get(ldCountry).containskey(ldCity) ){
                       if(mapCountryToAccount.get(ldCountry).RecordTypeId==CHILD_RECORD_TYPE){
                           if(mapCountryToAccount.get(ldCountry).customer_category__c!='Tier 4 - ROM'){
                               ld.OwnerId=mapCountryToAccount.get(ldCountry).OwnerId;                               
                           }
                           string AccountId=mapCountryToAccount.get(ldCountry).Id;
                        ld.Lead_Owner_Assignment__c='Owner is Assigned based on Address Match of Account Id:' +AccountId;
                           ld.Account_Id__c=AccountId;
                           if(mapCountryToAccount.get(ldCountry).customer_category__c=='Tier 4 - TMMA'){
                            ld.RecordTypeId=TMMA_LEAD_RECORD_TYPE; 
                            system.debug('listtest121::'+ld.RecordType.Name);
                        }
                        else if(mapCountryToAccount.get(ldCountry).customer_category__c=='Tier 4 - ROM'){
                            ld.RecordTypeId=ROM_LEAD_RECORD_TYPE; 
                        }
                        else if(mapCountryToAccount.get(ldCountry).customer_category__c=='Tier 1' ||
                              mapCountryToAccount.get(ldCountry).customer_category__c=='Tier 2' ||
                                mapCountryToAccount.get(ldCountry).customer_category__c=='Tier 3')
                            ld.RecordTypeId=AA_LEAD_RECORD_TYPE; 
                        }
                       }
                   }
                   
                }
               
            }
                                
        update listUnCategorizedLeads;
        list<lead> listLeadToNextMethod=new list<lead>();
        for(lead ld:listUnCategorizedLeads){
            if(ld.RecordTypeId==UNCATEGORIZED_RECORD_TYPE){
                ld.RecordTypeId=ROM_LEAD_RECORD_TYPE;
                 ld.Lead_Owner_Assignment__c='Lead Marked as ROM Leads as no match is found';
                listLeadToNextMethod.add(ld);
            }
        }
        update listLeadToNextMethod;
    }                                                                                       
                                                                                
    public static void restOfMarketAssignment(list<lead> listRomLeads){
        fieldValueMapping(listRomLeads);
        set<Id> leadIds=new Set<Id>();
        //set<Id> leadOwnerIds=new Set<Id>();
        map<string,map<string,LeadOwnerAssignment__c>> mapCountryToStateOwner=new map<string,map<string,LeadOwnerAssignment__c>>();
        map<string,map<string,LeadOwnerAssignment__c>> mapCountryToCityOwner=new map<string,map<string,LeadOwnerAssignment__c>>();
        map<string,list<LeadOwnerAssignment__c>> mapCountryToLeadOwner=new map<string,list<LeadOwnerAssignment__c>>();
        map<string,map<string,list<LeadOwnerAssignment__c>>> mapCountryToStateLeadOwner=new map<string,map<string,list<LeadOwnerAssignment__c>>>();
        map<string,map<string,set<Id>>> mapCountryToStateSet=new map<string,map<string,set<Id>>>();
                
        list<LeadOwnerAssignment__c> listLeadOwnerAssignmt=[Select id,Country__c,city__c,End_ZIP_Code__c,Lead_Owner__c,
                                                           Start_ZIP_Code__c,State__c,CBG__c from LeadOwnerAssignment__c];
        
        if(listLeadOwnerAssignmt.size() !=0){
            for(LeadOwnerAssignment__c ldOwner:listLeadOwnerAssignmt){                               
                if(ldOwner.Country__c !=null ){
                    if(!mapCountryToLeadOwner.containskey(ldOwner.Country__c.toUpperCase())){
                        list<LeadOwnerAssignment__c> lst = new list<LeadOwnerAssignment__c>();
                        lst.add(ldOwner);
                        mapCountryToLeadOwner.put(ldOwner.Country__c.toUpperCase(),lst);
                    }
                    else if(mapCountryToLeadOwner.containskey(ldOwner.Country__c.toUpperCase())){
                        mapCountryToLeadOwner.get(ldOwner.Country__c.toUpperCase()).add(ldOwner); 
                    }                    
                }
                if(ldOwner.Country__c !=null && ldOwner.State__c != null && ldOwner.CBG__c!=null){
                    list<LeadOwnerAssignment__c> lst = new list<LeadOwnerAssignment__c>();
                        lst.add(ldOwner); 
                    //leadOwnerIds.add(ldOwner.Lead_Owner__c);
                    if(!mapCountryToStateLeadOwner.containsKey(ldOwner.Country__c.toUpperCase())){
                       mapCountryToStateLeadOwner.put(ldOwner.Country__c.toUpperCase(),
                        new map<string,list<LeadOwnerAssignment__c>>{ldOwner.State__c.toUpperCase()=>lst}); 
                    }
                    else if(mapCountryToStateLeadOwner.containsKey(ldOwner.Country__c.toUpperCase())){
                        if(!mapCountryToStateLeadOwner.get(ldOwner.Country__c.toUpperCase()).containskey(ldOwner.State__c.toUpperCase())){
                            mapCountryToStateLeadOwner.get(ldOwner.Country__c.toUpperCase()).put(ldOwner.State__c.toUpperCase(),
                                                                                            lst);
                        }
                        else if(mapCountryToStateLeadOwner.get(ldOwner.Country__c.toUpperCase()).containskey(ldOwner.State__c.toUpperCase())){
                            mapCountryToStateLeadOwner.get(ldOwner.Country__c.toUpperCase()).get(ldOwner.State__c.toUpperCase()).add(ldOwner);
                        }                        
                    }
                    if(!mapCountryToStateSet.containsKey(ldOwner.Country__c.toUpperCase())){
                       mapCountryToStateSet.put(ldOwner.Country__c.toUpperCase(),
                                                new map<string,set<Id>>{ldOwner.State__c.toUpperCase()=>new set<Id>{ldOwner.Lead_Owner__c}}); 
                    }
                    else if(mapCountryToStateSet.containsKey(ldOwner.Country__c.toUpperCase())){
                        if(!mapCountryToStateSet.get(ldOwner.Country__c.toUpperCase()).containskey(ldOwner.State__c.toUpperCase())){
                            mapCountryToStateSet.get(ldOwner.Country__c.toUpperCase()).put(ldOwner.State__c.toUpperCase(),
                                                                                            new set<Id>{ldOwner.Lead_Owner__c});
                        }
                        else if(mapCountryToStateSet.get(ldOwner.Country__c.toUpperCase()).containskey(ldOwner.State__c.toUpperCase())){
                            mapCountryToStateSet.get(ldOwner.Country__c.toUpperCase()).get(ldOwner.State__c.toUpperCase()).add(ldOwner.Lead_Owner__c);
                        }                        
                    }
                }
           }            
        }
        for(lead ld:listRomLeads){
            string ldCountry;   
             string ldState;
             string ldCity;
            if(ld.country!=null){
                ldCountry=ld.country.toUpperCase();
            }
            if(ld.state!=null){ 
                ldState=ld.state.toUpperCase();
                system.debug('state:'+ld.state);
            }
            if(ld.city!=null){
                ldCity=ld.city.toUpperCase();
                system.debug('city::'+ld.city);
            }            
            if(mapCountryToStateLeadOwner.containsKey(ldCountry)){
                if(mapCountryToStateLeadOwner.get(ldCountry).containsKey(ldState)){
                    for(LeadOwnerAssignment__c ldOwner:mapCountryToStateLeadOwner.get(ldCountry).get(ldState)){
                        if(ldOwner.CBG__c !=null && ld.Industry!=null && ldCity!=null && ldOwner.city__c!=null){
                            if(ldOwner.CBG__c.toUpperCase() ==  ld.Industry.toUpperCase() 
                               && ldOwner.city__c.toUpperCase()==ldCity ){                                   
                                   if(ldOwner.Lead_Owner__c !=null){
                                       ld.ownerId=ldOwner.Lead_Owner__c;
                                       leadIds.add(ld.Id);
                                   }
                            } 
                            if(ldOwner.CBG__c.toUpperCase() ==  ld.Industry.toUpperCase() 
                               && ldOwner.city__c.toUpperCase()== 'OTHER' && (!leadIds.contains(ld.Id))){                                   
                                   if(ldOwner.Lead_Owner__c !=null){
                                       ld.ownerId=ldOwner.Lead_Owner__c;
                                       leadIds.add(ld.Id);
                                   }
                            }
                        }                    
                    }
                                       
                } 
            }
            if(mapCountryToLeadOwner.containsKey(ldCountry)){                
                for(LeadOwnerAssignment__c ldOwner:mapCountryToLeadOwner.get(ldCountry)){                     
                    if(ldOwner.CBG__c !=null && ld.Industry!=null && !leadIds.contains(ld.Id) && ldCity!=null 
                       && ldOwner.city__c!=null){
                       if(ldOwner.CBG__c.toUpperCase() ==  ld.Industry.toUpperCase() 
                         && ldOwner.city__c.toUpperCase()==ldCity){
                              if(ldOwner.Lead_Owner__c !=null){                                  
                                    ld.ownerId=ldOwner.Lead_Owner__c;
                                    leadIds.add(ld.Id);
                               }
                          } 
                    }
                }                
                for(LeadOwnerAssignment__c ldOwner:mapCountryToLeadOwner.get(ldCountry)){                    
                    if(ldOwner.CBG__c !=null && ld.Industry!=null && !leadIds.contains(ld.Id) &&
                      ldOwner.CBG__c.toUpperCase() ==  ld.Industry.toUpperCase() && ldOwner.state__c==null &&
                      ldOwner.city__c== null){                          
                        if(ldOwner.Lead_Owner__c !=null){
                             ld.ownerId=ldOwner.Lead_Owner__c;
                             leadIds.add(ld.Id);
                             system.debug('leadZip345:::'+leadIds);
                        }
                    }
                }
            }
            if(mapCountryToStateLeadOwner.containsKey(ldCountry) && mapCountryToStateSet.containsKey(ldCountry)){
                if(mapCountryToStateLeadOwner.get(ldCountry).containsKey(ldState) &&
                  mapCountryToStateSet.get(ldCountry).containsKey(ldState)){
                    system.debug('check::'+mapCountryToStateSet) ;  
                      system.debug('check1::'+mapCountryToStateSet.size()) ;  
                    for(LeadOwnerAssignment__c ldOwner:mapCountryToStateLeadOwner.get(ldCountry).get(ldState)){
                        if(ldOwner.CBG__c !=null && ld.Industry!=null && 
                           mapCountryToStateSet.get(ldCountry).get(ldState).size() == 1 &&
                           ldOwner.CBG__c.toUpperCase() ==  ld.Industry.toUpperCase() && !leadIds.contains(ld.Id)){                               
                               for(Id ldOwnerId:mapCountryToStateSet.get(ldCountry).get(ldState)){
                                   ld.ownerId=ldOwnerId;
                               }                               
                           }
                    }
                }
            }
            if(mapCountryToLeadOwner.containskey(ldCountry)){
                ld.RecordTypeId=ROM_LEAD_RECORD_TYPE;                                 
                for(LeadOwnerAssignment__c ldOwner:mapCountryToLeadOwner.get(ldCountry)){
                    if(!leadIds.contains(ld.Id) && ld.PostalCode !=null && ldOwner.CBG__c ==null){
                        string ldPostalCode=ld.PostalCode;
                        string splittedPostalCode;
                        list<string> splitLdPostalCode= new list<string> ();                        
                        splitLdPostalCode=ldPostalCode.split('-');
                        if(splitLdPostalCode.size( )>0){
                            splittedPostalCode=splitLdPostalCode[0];
                        }                                
                        system.debug('leadZip1:::'+splittedPostalCode);  
                        if(ldOwner.Start_ZIP_Code__c !=null && ldOwner.End_ZIP_Code__c!=null &&
                        splittedPostalCode !=null && ldOwner.Start_ZIP_Code__c.isNumeric() && ldOwner.End_ZIP_Code__c.isNumeric()
                        && splittedPostalCode.isNumeric()){                                    
                            if(integer.ValueOf(ldOwner.Start_ZIP_Code__c)<=integer.ValueOf(splittedPostalCode) && 
                            integer.ValueOf(ldOwner.End_ZIP_Code__c)>=integer.ValueOf(splittedPostalCode) ){                                              
                                if(ldOwner.Lead_Owner__c !=null){
                                    ld.ownerId=ldOwner.Lead_Owner__c;
                                    leadIds.add(ld.Id);
                                    system.debug('leadZip'+ld.Id);                            
                                }                            
                            }
                        }                        
                    }                    
                }
                    for(LeadOwnerAssignment__c ldOwner:mapCountryToLeadOwner.get(ldCountry)){
                        if(!leadIds.contains(ld.Id) && ldOwner.CBG__c ==null){
                            if(ld.State!=null && ldOwner.State__c!=null && ldOwner.State__c.toUpperCase()==ldState){
                                if(ldOwner.Lead_Owner__c !=null){
                                    ld.ownerId=ldOwner.Lead_Owner__c;
                                    leadIds.add(ld.Id);
                                    system.debug('leadZip1::'+ld.Id);
                                }
                            }
                        }
                    }
                    for(LeadOwnerAssignment__c ldOwner:mapCountryToLeadOwner.get(ldCountry)){
                        if(!leadIds.contains(ld.Id) && ldOwner.CBG__c ==null){
                            if(ld.city!=null && ldOwner.city__c!=null && ldOwner.city__c.toUpperCase()==ldCity){
                                if(ldOwner.Lead_Owner__c !=null){
                                    ld.ownerId=ldOwner.Lead_Owner__c;
                                    leadIds.add(ld.Id);
                                    system.debug('leadZip2::'+ld.Id);
                                }
                            }
                        }
                    }
                    for(LeadOwnerAssignment__c ldOwner:mapCountryToLeadOwner.get(ldCountry)){
                        if(!leadIds.contains(ld.Id) && ldOwner.CBG__c ==null){
                            if(ld.Country!=null && ldOwner.Country__c!=null && ldOwner.Country__c.toUpperCase()==ldCountry){
                                if(ldOwner.Lead_Owner__c !=null){
                                    ld.ownerId=ldOwner.Lead_Owner__c;
                                    leadIds.add(ld.Id);
                                    system.debug('leadZip1::'+ld.Id);
                                }
                            }
                        }
                    }                                    
            }                       
        }
        update listRomLeads;        
    }
}