public with sharing class CreateLeadController {
    
    @AuraEnabled    
    public static CreateLeadWrapper.caseInitialReturns getContactDetails(Id CaseId){
        CreateLeadWrapper.caseInitialReturns initialReturns= new CreateLeadWrapper.caseInitialReturns();
        case casCurrent;
        contact conCurrent;
        user casOwner;
        casCurrent=[Select Id,ContactEmail,Product_Name__r.Name,Product_Sub__c,AccountId,Account.Customer_Category__c,
                    OwnerId,CaseNumber,Owner.Type,Community_Web_Country__c,Product_Type_Number__c, 
                   State_Province__c, Project_Annual_Volume__c,MAG__c,Product__c,Product_Category__c
                    from case where Id =:CaseId];
       /* system.debug('caseowner::'+casCurrent.OwnerId);
        if(casCurrent.OwnerId !=null && casCurrent.Owner.Type !='Queue'){
            casOwner=[select id, name from User where id=:casCurrent.OwnerId];
            initialReturns.caseOwner=casOwner;
        }*/
        
        //system.debug('caseowner::'+casOwner.Name);
        if(casCurrent.ContactEmail !=null){
             conCurrent=[select id, email,Name,company__c,phone,MobilePhone,firstName,LastName from contact 
                                where email=:casCurrent.ContactEmail];
        }        
        
        initialReturns.contactCurrent=conCurrent;
        initialReturns.caseCurrent=casCurrent;
        
        
        return initialReturns;
    }
    
    @AuraEnabled
    public static List < sObject > fetchDistiAccSearch(String searchKeyWord){
        list<Account> returnAccounts= new list<account>();
        String searchKey = searchKeyWord + '%'; 
        returnAccounts=[select id, Name,Role__c from Account where Role__c='Distributor' AND Name LIKE: searchKey
                       AND IsInactive__c=False AND RecordType.Name='Parent Account'];
                       
        return returnAccounts;
    }
    
    @AuraEnabled
    public static List < sObject > fetchDistiAccounts(){
        list<Account> returnAccounts= new list<account>();        
        returnAccounts=[select id, Name,Role__c from Account where Role__c='Distributor' AND IsInactive__c=False
                       AND RecordType.Name='Parent Account'];
        return returnAccounts;
    }
            
 	@AuraEnabled
 	public static List < String > getselectOptions(sObject objObject, string fld) {
  	system.debug('objObject --->' + objObject);
  	system.debug('fld --->' + fld);
  	List < String > allOpts = new list < String > ();
  	// Get the object type of the SObject.
  	Schema.sObjectType objType = objObject.getSObjectType();
    //Schema.SObjectType objType = Schema.getGlobalDescribe().get(objObject);
 
  	// Describe the SObject using its object type.
  	Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
 
  	// Get a map of fields for the SObject
  	map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
 
  	// Get the list of picklist values for this field.
  	list < Schema.PicklistEntry > values =
   	fieldMap.get(fld).getDescribe().getPickListValues();
 
  	// Add these values to the selectoption list.
  	for (Schema.PicklistEntry a: values) {
   	allOpts.add(a.getValue());
  	}
  	system.debug('allOpts ---->' + allOpts);
  	allOpts.sort();
  	return allOpts;
 	}
    
   @AuraEnabled  
    public static Map<String, List<String>> getDependentOptionsImpl(String objApiName, String contrfieldApiName, String depfieldApiName)
	{
    Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
 
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
    Schema.DescribeSObjectResult describeResult = objType.getDescribe();
    Schema.DescribeFieldResult contrfieldApiNameInfo = describeResult.fields.getMap().get(contrfieldApiName).getDescribe();
    Schema.DescribeFieldResult depfieldApiNameInfo = describeResult.fields.getMap().get(depfieldApiName).getDescribe();
 
    List<Schema.PicklistEntry> controllingValues = contrfieldApiNameInfo.getPicklistValues();
    List<Schema.PicklistEntry> dependentValues = depfieldApiNameInfo.getPicklistValues();
 
    for(Schema.PicklistEntry currControllingValue : controllingValues)
    {
        controllingInfo.put(currControllingValue.getLabel(), new List<String>());
    }
 
    for(Schema.PicklistEntry currDependentValue : dependentValues)
    {
        String jsonString = JSON.serialize(currDependentValue);
         //PicklistEntryWrapper info = new PicklistEntryWrapper();
 
         PicklistEntryWrapper info = (PicklistEntryWrapper ) JSON.deserialize(jsonString, PicklistEntryWrapper .class);
 
        String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
 
        Integer baseCount = 0;
 
        for(Integer curr : hexString.getChars())
        {
            Integer val = 0;
 
            if(curr >= 65)
            {
                val = curr - 65 + 10;
            }
            else
            {
                val = curr - 48;
            }
 
            if((val & 8) == 8)
            {                
                controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
            }
            if((val & 4) == 4)
            {               
                controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
            }
            if((val & 2) == 2)
            {               
                controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
            }
            if((val & 1) == 1)
            {               
                controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
            }
 
            baseCount += 4;
        }            
    } 
 
    System.debug('ControllingInfo: ' + JSON.serializePretty(controllingInfo));
    return controllingInfo;
}
	@AuraEnabled
    public static string fetchRegion(string countryVal){
        map<string,string> mapCountryToRegion=new map<string,string>();
        string regionValue;
        
        list<LeadCountrySettings__c> lstLeadCountrySettings=[select id,Country__c,country_Code__c,State__c,Region__c,State_Code__c 
                                                             from LeadCountrySettings__c];
        for(LeadCountrySettings__c settings:lstLeadCountrySettings){
            if(settings.Region__c!=null && settings.Country__c !=null){
                if(!mapCountryToRegion.containskey(settings.Country__c.toUpperCase())){
                    mapCountryToRegion.put(settings.Country__c.toUpperCase(),settings.Region__c);
                    
                }
            }
        }
        if(countryVal !=null){
            if(mapCountryToRegion.containsKey(countryVal.toUpperCase())){
                    system.debug('settRe1:'+mapCountryToRegion);
                    if(mapCountryToRegion.get(countryVal.toUpperCase()) !=null){
                        regionValue=mapCountryToRegion.get(countryVal.toUpperCase());                    
                    }
                } 
        }
        
        return regionValue;
    }
    
	
    @AuraEnabled
    public static void createLead(id caseId, string contactfirstName, string contactLastName,
                                  string caseproduct, string contactEmail, string contactComp, 
                                 string projctDesc, string timeLineValueCas, string volme, string competitor,
                                 string industryValue,  string conPhone, string conMobPhone, string caseNumber,
                                 string shareWithDisti, string NXPNotes, string countryValu, string stateValu, string proLV3,
                                 string postalCode, string accDistiName, string caseType, string proLv1, string proLv2){
        system.debug('enteringmode::'+ caseId);
        if(proLV3==null){
           proLV3='';
		}                             
        if(shareWithDisti == null){
           shareWithDisti='';                              
        }
        if(accDistiName == null){
           accDistiName='';                              
        }                                                          
		if(competitor == null){
           competitor='';                              
        }
		if(caseproduct == null){
           caseproduct='';                              
        }
		if(volme == null){
           volme='';                              
        }
		if(timeLineValueCas == null){
           timeLineValueCas='';                              
        }
		if(conMobPhone == null){
           conMobPhone='';                              
        }
		if(stateValu == null){
           stateValu='';                              
        }
		if(postalCode == null){
           postalCode='';                              
        }
		if(industryValue == null){
           industryValue='';                              
        }
		
		if(conPhone == null){
            conPhone='';                              
        } 
         if(caseType == null){
             caseType='';
    	 }                           
   		string countryCode;
        string stateCode;
        string loggedInUser;
        string mag;
     	map<string,string> mapCountryCodeToName;
     	map<string,string> mapStateCodeToState;
     	map<string,string> mapCountryToRegion;
        string[] novaSilvaEmail = New String[]{};
        
        list<LeadCountrySettings__c> lstLeadCountrySettings=[select id,Country__c,country_Code__c,State__c,Region__c,State_Code__c 
                                                             from LeadCountrySettings__c];
        Case caseCurrent=[Select Id,MAG__c from Case where Id=:caseId];
                                     if(caseCurrent !=null && caseCurrent.MAG__c !=null){
                                         mag=caseCurrent.MAG__c;
                                     }
                                     if(mag == null){
                                         mag='';
                                     }
        mapCountryCodeToName=new map<string,string>();
        mapStateCodeToState=new map<string,string>(); 
        
        for(LeadCountrySettings__c settings:lstLeadCountrySettings){            
            if(settings.Country__c !=null && settings.country_Code__c!=null){
                if(!mapCountryCodeToName.containskey(settings.Country__c.toUpperCase())){
                    mapCountryCodeToName.put(settings.Country__c.toUpperCase(),settings.country_Code__c);
                }
            }
            if(settings.State__c !=null && settings.state_Code__c!=null){
                if(!mapStateCodeToState.containskey(settings.State__c.toUpperCase())){
                    mapStateCodeToState.put(settings.State__c.toUpperCase(),settings.state_Code__c);
                }
            }            
                
        }
         if(mapCountryCodeToName.containsKey(countryValu.toUpperCase())){   
             if(mapCountryCodeToName.get(countryValu.toUpperCase()) !=null){
                    countryCode=mapCountryCodeToName.get(countryValu.toUpperCase());
             }                    
         }
        else{
           	countryCode=''; 
        }                                     
        if(mapStateCodeToState.containskey(stateValu.toUpperCase()) && 
           mapStateCodeToState.get(stateValu.toUpperCase()) !=null){                    
                   stateCode=mapStateCodeToState.get(stateValu.toUpperCase());                
        }
        if(stateValu != null && !mapStateCodeToState.containskey(stateValu.toUpperCase()) && stateValu !='--- None ---'){
            stateCode=stateValu;                             
        }
                                     if(stateCode == null){
                                         stateCode='';
                                     }
                                    
        //contact conEmail=[select id, Email from contact where Email =:contactEmail];
        User u = [select Id,Name, username from User where Id = :UserInfo.getUserId()];
                                     if(u !=null){
                                         loggedInUser=u.Name;
                                     }    

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
        //LeadCountrySettings__c leadSettings = LeadCountrySettings__c.getValues('NovaSilva');
        string novaSilvaLabel=string.valueOf(System.Label.NovaSilva_Email);
                                     if(novaSilvaLabel !=null){
                                         novaSilvaEmail.add(novasilvaLabel); 
                                     }
                                                                                         
        sendEmail.setToAddresses(novaSilvaEmail);        
        sendEmail.setSubject('NXP / New lead from NXP Technical Support');        
        sendEmail.setHtmlBody('Hello,</br></br>'+
                             'Please find below the details of the Lead to be created</br></br>'+
                             'Lead Deatils:<b></b></br></br>'+
                             '<table border="1" width="50%" empty-cells: hide;>'+
                              '<tr><td width="50"><b>Case#</b></td>'+'<td width="50">'+caseNumber+'</td></tr>'+
                              '<tr><td width="50"><b>First Name</b></td>'+'<td width="50">'+contactfirstName+'</td></tr>'+
							  '<tr><td width="50"><b>Last Name</b></td>'+'<td width="50">'+contactLastName+'</td></tr>'+                              
                              '<tr ><td width="50"><b>Email</b></td>'+'<td width="50">'+contactEmail+'</td></tr>'+ 
                               '<tr><td width="50"><b>Company</b></td>'+'<td width="50">'+contactComp+'</td></tr>'+
							'<tr><td width="50"><b>Mobile Phone #</b></td>'+'<td width="50">'+conMobPhone+'</td></tr>'+
                              '<tr><td width="50"><b>Phone #</b></td>'+'<td width="50">'+conPhone+'</td></tr>'+                              
                              '<tr><td width="50"><b>Country</b></td>'+'<td width="50">'+countryCode+'</td></tr>'+                              
                              '<tr><td width="50"><b>State/Province</b></td>'+'<td width="50">'+stateCode+'</td></tr>'+
							    '<tr><td width="50"><b>Zip/PostalCode</b></td>'+'<td width="50">'+postalCode+'</td></tr>'+
                              '<tr><td width="50"><b>Industry</b></td>'+'<td width="50">'+industryValue+'</td></tr>'+
                              '<tr><td width="50"><b>Volume</b></td>'+'<td width="50">'+volme+'</td></tr>'+
                              '<tr><td width="50"><b>Competitor</b></td>'+'<td width="50">'+competitor+'</td></tr>'+
                              '<tr><td width="50"><b>Expected Completion date</b></td>'+'<td width="50">'+timeLineValueCas+'</td></tr>'+
                              '<tr><td width="50"><b>Product Lvl 1</b></td>'+'<td width="50">'+proLv1+'</td></tr>'+
                              '<tr><td width="50"><b>Product Lvl 2</b></td>'+'<td width="50">'+proLv2+'</td></tr>'+
                              '<tr><td width="50"><b>Product Lvl 3</b></td>'+'<td width="50">'+proLV3+'</td></tr>'+
                              '<tr><td width="50"><b>Product Name</b></td>'+'<td width="50">'+caseproduct+'</td></tr>'+
                              '<tr><td width="50"><b>Product Type Number</b></td>'+'<td width="50">'+caseType+'</td></tr>'+
                              '<tr><td width="50"><b>MAG</b></td>'+'<td width="50">'+mag+'</td></tr>'+
                              '<tr><td width="50"><b>Project Description</b></td>'+'<td width="50">'+projctDesc+'</td></tr>'+                              
                            '<tr><td width="50"><b>Preferred Distributor</b></td>'+'<td width="50">'+accDistiName+'</td></tr>'+
                              '<tr><td width="50"><b>Permission to Share with Distributor</b></td>'+'<td width="50">'+shareWithDisti+'</td></tr>'+
                              '<tr><td width="50"><b>NXP Representative Notes</b></td>'+'<td width="50">'+NXPNotes+'</td></tr>'+
                             '</table></br></br></br></br>' +
                             'Regards,</br>'+
                             +loggedInUser+'</br>');
        sendEmail.setSaveAsActivity(false);
        emails.add(sendEmail);
       	if (emails != NULL && emails.size() > 0)
        {
            try{
               Messaging.sendEmail(emails);
                if(caseCurrent !=null){
                    FeedItem post = new FeedItem();
					post.ParentId = caseCurrent.Id; 
					post.Body = 'Shared the case details  for Lead creation';
					insert post;
                }               
            }
            catch(exception e){
                                
            }            
        }
        
    }

}