public with sharing class LeadConvertController {
   
    @AuraEnabled
    Public static LeadConvertWrapper.LeadInitialReturns getLeadActivities(Id LeadId) { 	
     	LeadConvertWrapper.LeadInitialReturns ldCurrentReturns= new  LeadConvertWrapper.LeadInitialReturns();
     	 lead ldCurrent;
         list<Lead_Activity__c> ldActCurrent;
         Account ldAccountCurrent;
        list<Opportunity> listldOppty;
        ldCurrent=[Select Id,Name,Company,Email,Owner.Id,Account_Id__c,Title,Job_Description__c,Normalized_Title__c,
                   Project_Description__c,Manual_Update_Check__c from Lead where Id=:LeadId];         
     	ldActCurrent=[Select id,Response_Date_Created__c,Action__c,Object__c,Specific_Interest__c,
              Specific_Interest_Description__c,Order_Status__c from Lead_Activity__c 
                      where Related_to_Lead__c =:LeadId];
              
        if(ldCurrent.Account_Id__c!=null){
            ldAccountCurrent=[Select Id, Name,IsInactive__c from Account where id=:ldCurrent.Account_Id__c AND 
                              IsInactive__c=false];
        	listldOppty=[select Id,Name,AccountId from Opportunity where accountId=:ldCurrent.Account_Id__c];
        }        
        ldCurrentReturns.leadCurrent=ldCurrent;
        ldCurrentReturns.leadAccountCurrent=ldAccountCurrent;
        ldCurrentReturns.listLdActivityCurrent=ldActCurrent;
        ldCurrentReturns.listOppty=listldOppty;
        return ldCurrentReturns;
    }
    
    @AuraEnabled
    public static List < sObject > fetchOpportunity(String searchKeyWord, Id LeadId,string leadAccId) {
        //system.debug('ObjectName-->' + Opportunity);
        Lead ldCurrent;
        list<opportunity> listOpp;
        String searchKey = searchKeyWord + '%';        
        List < Opportunity > returnList = new List < Opportunity > ();
        ldCurrent=[select id, email,Account_Id__c,status,firstName,LastName from Lead where Id=:LeadId];
        listOpp=[select id,AccountId, Name from Opportunity where Name LIKE: searchKey 
                 AND  AccountId=:leadAccId AND RecordType.Name='SFDC Oppty' ORDER BY Name ASC ];         
        if(listOpp.size() !=0){
            for (Opportunity opp: listOpp) {
            returnList.add(opp);
        	}
        }        
        return returnList;
    }
    
      @AuraEnabled
    public static List < sObject > fetchOppList(Id LeadId, string leadAccId) {
        //system.debug('ObjectName-->' + Opportunity);
        Lead ldCurrent;
        list<opportunity> listOpp;              
        List < Opportunity > returnList = new List < Opportunity > ();
        ldCurrent=[select id, email,Account_Id__c,status,firstName,LastName from Lead where Id=:LeadId];                 
        listOpp=[select id,AccountId, Name from Opportunity where 
                AccountId=:leadAccId AND RecordType.Name='SFDC Oppty' ORDER BY Name ASC];         
        if(listOpp.size() !=0){
            for (Opportunity opp: listOpp) {
            returnList.add(opp);
        	}
        }        
        return returnList;
    }
    
    @AuraEnabled
    public static list<Account> listLeadAccount(Id LeadId, string LeadOwnerId){
        list<account> listAccount;
        list<account> returListAccount=new list<Account>();
        listAccount=[Select id,Name,IsInactive__c,country__c,city__c from account where OwnerId =:LeadOwnerId AND 
                     IsInactive__c=False AND RecordType.Name='Child Account' ORDER BY Name ASC ];                                         
        if(listAccount.size()!=0){
            for(account acc:listAccount){
                returListAccount.add(acc);
            }
        }
        return returListAccount;
    }
    
    
    
    @AuraEnabled  
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName){
        system.debug(objApiName + '##' + contrfieldApiName + '###' + depfieldApiName);
           
        String objectName = objApiName.toLowerCase();
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
            //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
         
        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
         }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){
            return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;     
        }
       	
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();        
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
         objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getLabel();
            objResults.put(label,new List<String>());
            controllingIndexes.add(contrIndex);
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
               Schema.PicklistEntry depentry = depEntries[dependentIndex];
               objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
            }
        }
        objEntries = null;
        objJsonEntries = null;
        system.debug('objResults--->' + objResults);
        return objResults;
    }
    
    
    
    @AuraEnabled
    public static list<Account> listOfSearchAccRecords(String searchKeyWord,Id LeadId, string LeadOwnerId){
        list<account> listAccount;
        String searchKey = searchKeyWord + '%';
        list<account> returListAccount=new list<Account>();
        listAccount=[Select id,Name,country__c,city__c from account where OwnerId =:LeadOwnerId AND
                    Name LIKE: searchKey AND IsInactive__c=False AND RecordType.Name='Child Account'
                     ORDER BY Name ASC ];
        if(listAccount.size()!=0){
            for(account acc:listAccount){
                returListAccount.add(acc);
            }
        }
        return returListAccount;
    }
          
    @AuraEnabled
    public static void convertLead( boolean IsCreateOpp, boolean IsTagOpp, string oppttyName,
                                   string oppttyDesc,Id existingOppId, Id LeadId, string oppCloseDate,string leadAccountId,
                                  string oppttySeg,string oppttySubseg){
      system.debug('enteringmode::'+ LeadId);
        string strLeadEmail;
        List<OpportunityContactRole> listNewContactRole = new List<OpportunityContactRole>();
        list<contact> existingContact=new list<contact>();
        list<contact> listContactsToUpdate=new list<contact>();
        contact existingContact1;
        list<lead> listLead=new list<lead>();
        Lead ldToConvert;
        map<string,contact> mapEmailToContact=new map<string,contact>();
   		map<string,contact> mapLeadIdToContact=new map<string,contact>();
        map<string,Opportunity> mapLeadIdToOppty=new map<string,opportunity>();
        opportunity newOpp=new Opportunity();
        opportunity existingOppty;
        
        
        ldToConvert=[select id, email,Manual_Update_Check__c,Account_Id__c,status,firstName,LastName from Lead where Id=:LeadId];        
            
            system.debug('manualcheck::'+ldToConvert.Manual_Update_Check__c);
            if(ldToConvert.Email != null){
                strLeadEmail=ldToConvert.Email;
            }
        
        existingContact=[select id, email,AccountId from contact where email =:strLeadEmail];
      	if(existingContact.size() !=null){
            for(contact con:existingContact){
                if(!mapEmailToContact.containskey(con.email)){
                	mapEmailToContact.put(con.email,con);                
            	}  
            }                                       
        }                                                                                     
        if(IsCreateOpp==True &&(oppttyName !=null || oppttyDesc !=null)){
			date closeDate=date.valueOf(oppCloseDate);            
            newOpp.Name=oppttyName;newOpp.AccountId=leadAccountId;newOpp.CloseDate=closeDate;
            newOpp.Production_Date__c=closeDate+30;newOpp.StageName='Initial Engagement';newOpp.Description=oppttyDesc;
            newOpp.Channel__c='Direct';newOpp.Industry_Segment__c=oppttySeg;newOpp.Sub_Segment__c=oppttySubseg;
            newOpp.Executive_Summary__c=oppttyDesc;
            
            insert newOpp;
            Opportunity newOppToConvert=[select id,AccountId from Opportunity where Id=:newOpp.Id];
            if(!mapLeadIdToOppty.containskey(ldToConvert.Id) && IsCreateOpp==True){                                
            	mapLeadIdToOppty.put(ldToConvert.Id,newOppToConvert);                               
        	} 
       }                                      
        else if(IsTagOpp == True ){
           existingOppty=[Select Id,AccountId, name from opportunity where Id=:existingOppId];
           if(!mapLeadIdToOppty.containskey(ldToConvert.Id) && IsTagOpp==True){                                
           		 mapLeadIdToOppty.put(ldToConvert.Id,existingOppty);                               
        	} 
        }
        if(mapEmailToContact.containskey(ldToConvert.email) && 
          mapLeadIdToOppty.containskey(ldToConvert.Id)){
            if(mapEmailToContact.get(ldToConvert.email).accountId !=
               mapLeadIdToOppty.get(ldToConvert.Id).AccountId){
                   mapEmailToContact.get(ldToConvert.email).accountId=mapLeadIdToOppty.get(ldToConvert.Id).AccountId;
                   listContactsToUpdate.add(mapEmailToContact.get(ldToConvert.email));
               }                                           
         }
         update listContactsToUpdate;
          if(!mapEmailToContact.containskey(ldToConvert.email)){
           system.debug('check::'+ existingContact.size());
            contact newCon=new Contact();
            newCon.FirstName=ldToConvert.FirstName;newCon.LastName=ldToConvert.LastName;
            newCon.Email=ldToConvert.email;newCon.AccountId=mapLeadIdToOppty.get(ldToConvert.Id).AccountId;
            insert newCon;
            Contact newConToConvert=[select id,email from Contact where Id=:newCon.Id];
            if(!mapEmailToContact.containskey(newConToConvert.email)){
                mapEmailToContact.put(newConToConvert.email,newConToConvert);                
            } 
        }
       
      	/*if(mapLeadIdToContact.containskey(ldToConvert.Id) && mapLeadIdToOppty.containskey(ldToConvert.Id)){
              listNewContactRole.add(new OpportunityContactRole(contactId=mapLeadIdToContact.get(ldToConvert.Id).Id,
                                    OpportunityId=mapLeadIdToOppty.get(ldToConvert.Id).Id,Role='Consultant')); 
              insert listNewContactRole;
      	}*/
        try{
            Database.LeadConvert lc = new Database.LeadConvert();			            
        	String convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;        
        	lc.setLeadId(ldToConvert.Id);
        	lc.setContactId(mapEmailToContact.get(ldToConvert.email).Id);
        	lc.setAccountId(mapLeadIdToOppty.get(ldToConvert.Id).accountId);
        	lc.setOpportunityId(mapLeadIdToOppty.get(ldToConvert.Id).Id);            
        	lc.setConvertedStatus(convertedStatus);            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
         	System.assert(lcr.isSuccess());
			system.debug('error::'+lcr.getErrors()); 
        }                             
        catch (Exception ex){
    		throw new AuraHandledException(ex.getMessage());
            System.debug('error --'+ ex.getStackTraceString());
               system.debug('message::'+ex.getTypeName() + ': ' + ex.getMessage()
                    + ' -- ' + ex.getCause());
   		}
                                       
   		        	        
    }
}