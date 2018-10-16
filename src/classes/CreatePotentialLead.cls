public with sharing class CreatePotentialLead {
    
    @AuraEnabled   

Public static Contact getContactDetails(id contactid){
        
Contact conCurrent;

conCurrent = [select ID,firstname,lastname,email,phone,MailingPostalCode from contact where id =:contactid];
    
return conCurrent;

}
    
       

       @AuraEnabled   

Public static void  getupdChckDetails(id transcriptid){
        
LiveChatTranscript lt = new LiveChatTranscript();
lt.id = transcriptid;
lt.Lead_Created__c =true;
update lt;
}


    
     @AuraEnabled   

Public static LiveChatTranscript gettranscriptDetails(id transid){
        
LiveChatTranscript transCurrent;
    
transCurrent = [SELECT id,Name,contactId,First_Name__c,Last_Name__c,email__c,Country__c,Distributor_Permission__c,Marketing_Permission__c,Body,Company__c FROM LiveChatTranscript where id =:transid];
    
return transCurrent;

}
    

        @AuraEnabled
    
Public static Product2  getPrdDetails(String Prodnum){
        
Product2 prod;

prod = [select Id,name,Product_Type__c from Product2 where name =:Prodnum];

return prod;

}
    
        @AuraEnabled
     public static Map<String, List<String>> getprdDependentOptionsImpl(String objApiName, String contrfieldApiName, String depfieldApiName)
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
     public static Map<String, List<String>> getprddDependentOptionsImpl(String objApiName, String contrfieldApiName, String depfieldApiName)
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
       public static List < sObject >  fetchproducts(){
        list<Product2> returnProducts= new list<Product2>();        
        returnProducts=[select id,name from Product2 limit 100];
        return returnProducts;
    }
    
         @AuraEnabled
    public static List < sObject >  fetchprdSearch(String searchKeyWord){
        list<Product2> returnProducts1 = new list<Product2>();
        String searchKey = searchKeyWord + '%'; 
        returnProducts1 =[select id, name from Product2 where Name LIKE: searchKey ];
                 
        return returnProducts1;
    }
    
    @AuraEnabled
    public static void createLead(id contactid, string contactfirstName, string contactLastName,
                                  string contactEmail, 
                                 string projctDesc,
                                 string industryValue,  string conPhone,
                                 
string shareWithDisti, string shareWithMark, string NXPNotes, string countryValu, string stateValu,
                                 string postalCode,string prodlv1,string prodlv2,string prodlv3,string prodnum,String prodId,string transname,string company){
        
                                  
        if(shareWithDisti == null){
           shareWithDisti='';                              
        }
        
        if(shareWithMark == null){
           shareWithMark='';                              
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
                                 
        string countryCode;
        string stateCode;
        string loggedInUser;
        //string mag;
		 String conMobPhone = '';
		String volme ='';
		String competitor ='';
		String timeLineValueCas ='';
		String mag ='';
		String accDistiName = '';
        map<string,string> mapCountryCodeToName;
        map<string,string> mapStateCodeToState;
        map<string,string> mapCountryToRegion;
        string[] novaSilvaEmail = New String[]{};
        
        list<LeadCountrySettings__c> lstLeadCountrySettings=[select id,Country__c,country_Code__c,State__c,Region__c,State_Code__c 
                                                             from LeadCountrySettings__c];
                                    
                                     
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
            sendEmail.setSubject('NXP / New lead from NXP Technical Chat Support');        
        	sendEmail.setHtmlBody('Hello,</br></br>'+
                             'Please find below the details of the Lead to be created</br></br>'+
                             'Lead Deatils:<b></b></br></br>'+
                             '<table border="1" width="50%" empty-cells: hide;>'+
                              
'<tr><td width="50"><b>Transcript Id</b></td>'+'<td width="50">'+transname+'</td></tr>'+
                              '<tr><td width="50"><b>First Name</b></td>'+'<td width="50">'+contactfirstName+'</td></tr>'+
							  '<tr><td width="50"><b>Last Name</b></td>'+'<td width="50">'+contactLastName+'</td></tr>'+                              
                              '<tr ><td width="50"><b>Email</b></td>'+'<td width="50">'+contactEmail+'</td></tr>'+ 
                              
                              '<tr><td width="50"><b>Company</b></td>'+'<td width="50">'+company+'</td></tr>'+
                              '<tr><td width="50"><b>Mobile Phone #</b></td>'+'<td width="50">'+conMobPhone+'</td></tr>'+
                              '<tr><td width="50"><b>Phone #</b></td>'+'<td width="50">'+conPhone+'</td></tr>'+
                              '<tr><td width="50"><b>Country</b></td>'+'<td width="50">'+countryCode+'</td></tr>'+                              
                              '<tr><td width="50"><b>State/Province</b></td>'+'<td width="50">'+stateCode+'</td></tr>'+
							  '<tr><td width="50"><b>Zip/PostalCode</b></td>'+'<td width="50">'+postalCode+'</td></tr>'+
                              '<tr><td width="50"><b>Industry</b></td>'+'<td width="50">'+industryValue+'</td></tr>'+
                               '<tr><td width="50"><b>Volume</b></td>'+'<td width="50">'+volme+'</td></tr>'+
                              '<tr><td width="50"><b>Competitor</b></td>'+'<td width="50">'+competitor+'</td></tr>'+
                              '<tr><td width="50"><b>Expected Completion date</b></td>'+'<td width="50">'+timeLineValueCas+'</td></tr>'+
							 '<tr><td width="50"><b>Product Lv1</b></td>'+'<td width="50">'+prodlv1+'</td></tr>'+
                              '<tr><td width="50"><b>Product Lv2</b></td>'+'<td width="50">'+prodlv2+'</td></tr>'+
                              '<tr><td width="50"><b>Product Lv3</b></td>'+'<td width="50">'+prodlv3+'</td></tr>'+
								'<tr><td width="50"><b>Product Name</b></td>'+'<td width="50">'+prodnum+'</td></tr>'+
                              '<tr><td width="50"><b>Product Type Number</b></td>'+'<td width="50">'+prodId+'</td></tr>'+
                              '<tr><td width="50"><b>MAG</b></td>'+'<td width="50">'+mag+'</td></tr>'+
                              '<tr><td width="50"><b>Project Description</b></td>'+'<td width="50">'+projctDesc+'</td></tr>'+ 
                              '<tr><td width="50"><b>Preferred Distributor</b></td>'+'<td width="50">'+accDistiName+'</td></tr>'+
                              '<tr><td width="50"><b>Permission to Share with Distributor</b></td>'+'<td width="50">'+shareWithDisti+'</td></tr>'+
                              '<tr><td width="50"><b>NXP Representative Notes</b></td>'+'<td width="50">'+NXPNotes+'</td></tr>'+
							  '<tr><td width="50"><b>Permission for use with marketing purposes</b></td>'+'<td width="50">'+shareWithMark+'</td></tr>'+
                             '</table></br></br></br></br>' +
                             'Regards,</br>'+
                             +loggedInUser+'</br>');
        sendEmail.setSaveAsActivity(false);
        emails.add(sendEmail);
                                  
        if (emails != NULL && emails.size() > 0)
        {
            try{
               Messaging.sendEmail(emails);
                           
            }
            catch(exception e){
                                
            }            
        }
        
    }

        
    
        
    
}