({
	doInit : function(component, event, helper) {
        component.set("v.IndMandatory", false);
        component.set("v.stateMandatory", false);
        component.set("v.ZipValmandatory", false);
        component.set("v.preDistiMandatory", false);                
        helper.ContactDetails(component);
        helper.fetchIndPickListVal(component, 'Industry','Ind-Inp');
        helper.pickListVal(component);        
		helper.fetchPickListVal(component, 'Project_Timeline__c','Timeline-Inp');
		helper.fetchVolPickListVal(component, 'Project_Annual_Volume__c','Vol-Inp');        
        helper.fetchPicklistValues(component, 'Country__c', 'State_Province__c');
        
	},
    countryPickValue:function(component, event, helper){
    	helper.fetchPicklistValues(component, 'Country__c', 'State_Province__c');
	},
    SetProjDesc:function(component, event, helper){
    	var projectDesc=component.find("Pro-Desc-Inp").get("v.value");        
        component.set("v.ProjDesc",projectDesc);
	},
    SetRepNotes:function(component, event, helper){
    	var repNotes=component.find("rep-Inp").get("v.value");        
        component.set("v.NXPRep",repNotes);
        
	},
    PerFieldChange:function(component, event, helper){
    	var shareDisti=component.find("per-Inp").get("v.value");        
        component.set("v.perToDisti",shareDisti);
	},
    SetVol:function(component, event, helper){
    	var vol=component.find("Vol-Inp").get("v.value");        
        component.set("v.volume",vol);
	},
    SetCompet:function(component, event, helper){
    	var competitr=component.find("compet-Inp").get("v.value");        
        component.set("v.competitors",competitr);
	},
    IndFieldChange:function(component, event, helper){
    	var indVal=component.find("Ind-Inp").get("v.value");        
        component.set("v.Industry",indVal);
	},
    SetTimeline: function(component, event, helper){
        var timelineVal = component.find("Timeline-Inp").get("v.value");         
        component.set("v.timeLine", timelineVal);
	},
    SetZipCode: function(component, event, helper){
        var zipVal = component.find("Zip-Inp").get("v.value");         
        component.set("v.zipCodeValue", zipVal);
	},
    SetMobPhone: function(component, event, helper){
        var mobPhVal = component.find("Mob-Inp").get("v.value");         
        component.set("v.mobPhoneValue", mobPhVal);
	},
    SetPhone: function(component, event, helper){
        var phVal = component.find("Ph-Inp").get("v.value");         
        component.set("v.phoneValue", phVal);
	},
    SetFirstNameChange: function(component, event, helper){
        var firstNamVal = component.find("first-Name-Inp").get("v.value"); 		      
        component.set("v.firstNameVal", firstNamVal);                
	},
    SetLastNameChange: function(component, event, helper){
        var lstNameVal = component.find("last-Name-Inp").get("v.value");         
        component.set("v.lastNameVal", lstNameVal);        
	},
    
    //Restict user entering date value and request to use Date picker  
    keyPressController : function(component, event, helper) {
      // get the search Input keyword   
		var getInputkeyWord = component.get("v.SearchKeyWord");
      // check if getInputKeyWord size id more then 0 then open the lookup result List and 
      // call the helper 
      // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }         
	},
    
    hidelist :function(component,event,helper){
        var lookUpTarget = component.find("lookupField");
         	$A.util.addClass(lookUpTarget, 'slds-show');
         	$A.util.removeClass(lookUpTarget, 'slds-hide');
        var forclose = component.find("searchRes");
           	$A.util.addClass(forclose, 'slds-is-close');
           	$A.util.removeClass(forclose, 'slds-is-open'); 
    },
    
    displaylist:function(component, event, helper){
        var forOpen = component.find("searchRes");        
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');               
        // call the apex class method         
     	var action = component.get("c.fetchDistiAccounts");              
                                     
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();              
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
                
            }
            if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                }                	
	 			else {
	                    component.set("v.Message", 'Search Result...');
	                }
            
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    clear :function(component,event,helper){      
         var pillTarget = component.find("lookup-pill");                           
         	$A.util.addClass(pillTarget, 'slds-hide');
         	$A.util.removeClass(pillTarget, 'slds-show'); 
  		 var lookUpTarget = component.find("lookupField");
         	$A.util.addClass(lookUpTarget, 'slds-show');
         	$A.util.removeClass(lookUpTarget, 'slds-hide');                       
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null ); 
        var accIdClear=component.find("pre-disti-Inp").set("v.value", "");
        component.set("v.selectedRecord",accIdClear);
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
     
    // get the selected Opportunity record from the COMPONETN event 	 
       var selectedAccGetFromEvent = event.getParam("accRecordByEvent");
	   
	   component.set("v.selectedRecord" , selectedAccGetFromEvent); 
                 
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
      
        
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');                      
	},
    
     cancelLead : function(component, event, helper) {
        component.set("v.isSpinner", true);
         var recordId = component.get("v.recordId");                                        
         window.location.href = '/'+recordId;                                       
    },
     closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
       var casId = component.get("v.recordId"); 
      component.set("v.isCreated", false);
         window.location.href = '/'+casId;
   },
    onControllerFieldChange: function(component, event, helper) {
      //alert(event.getSource().get("v.value"));
      // get the selected value
      var controllerValueKey = event.getSource().get("v.value"); 		
      // get the map values   
      var Map = component.get("v.depnedentFieldMap");
        if(controllerValueKey =='USA' || controllerValueKey =='Canada' || controllerValueKey=='China'){
            component.set("v.stateMandatory", true);
        }
        else{
           component.set("v.stateMandatory", false); 
        }
        if(controllerValueKey =='USA' || controllerValueKey=='Germany'){
            component.set("v.ZipValmandatory", true);
        }
        else{
           component.set("v.ZipValmandatory", false); 
        }
        if(controllerValueKey =='China' || controllerValueKey=='Taiwan'){
           component.set("v.IndMandatory", true); 
        }
        else{
           component.set("v.IndMandatory", false); 
        }
      // check if selected value is not equal to None then call the helper function.
      // if controller field value is none then make dependent field value is none and disable field
      if (controllerValueKey != '--- None ---') {
 
         // get dependent values for controller field by using map[key].  
         // for i.e "India" is controllerValueKey so in the map give key Name for get map values like 
         // map['India'] = its return all dependent picklist values.
         var ListOfDependentFields = Map[controllerValueKey];          
         helper.fetchDepValues(component, ListOfDependentFields);
         helper.fetchRegVales(component,event,controllerValueKey);
 
      } else {          
         var defaultVal = [{
            class: "optionClass",
            label: '--- None ---',
            value: '--- None ---'
         }];
         component.find('state-Inp').set("v.options", defaultVal);
         component.set("v.isDependentDisable", true);
      }
      var country=component.find("country-Inp").get("v.value");      
        component.set("v.countryVal",country);
        
      var state=component.find("state-Inp").get("v.value");        
        component.set("v.stateVal",state);
   },
    
    onDepFieldChange:function(component, event, helper){
        var state=component.find("state-Inp").get("v.value");        
        component.set("v.stateVal",state);
    },
    createLeadButton : function(component, event, helper) {                
        var conName=component.get("v.contact.Name");
        var conFirstNameExist=component.get("v.contact.FirstName");        
        var conLastNameExist=component.get("v.contact.LastName");  
        var conPhoneExist=component.get("v.contact.Phone");  
        var casId = component.get("v.recordId");        
        var casProd=component.get("v.cases.Product_Name__r.Name");
        var casProdType=component.get("v.cases.Product_Type_Number__c");
        var casProdLV1=component.get("v.cases.Product__c");
        var casProdLV2=component.get("v.cases.Product_Category__c");
        var casProdLV3=component.get("v.cases.Product_Sub__c");
        var casNum=component.get("v.cases.CaseNumber");
        var cusCategory=component.get("v.cases.Account.Customer_Category__c");
        //var caseOwner=component.get("v.users.Name");   
        var conEmail=component.get("v.contact.Email");
        var conPh=component.get("v.phoneValue");
        var conMobPh=component.get("v.mobPhoneValue");
        var conComp=component.get("v.contact.Company__c");
        var projectDesc=component.get("v.ProjDesc");
        var volume=component.get("v.volume");
        var competitor=component.get("v.competitors");
        var industryVal=component.get("v.Industry");
        var timeLineValue=component.get("v.timeLine");
        var shareToDisti=component.get("v.perToDisti");
        var represetNotes=component.get("v.NXPRep");
        var expCompletionDate = component.find("Timeline-Inp");
        
        var stateValue=component.get("v.stateVal");
        var zipCodeVal=component.get("v.zipCodeValue");
        var firstNameVal=component.get("v.firstNameVal");
        var lastNameVal=component.get("v.lastNameVal");
        var distiName=component.get("v.selectedRecord.Name");
        var regionName=component.get("v.regVal");
        var indFinalValue=component.get("v.IndMandatory");
       /* var CountryValueCase=component.get("v.cases.Community_Web_Country__c");
        if(CountryValueCase != null){
            
        }*/
        var contryValue=component.get("v.countryVal");
        
       	// value declaration
        if(cusCategory =='Tier 4 - Long Tail' || cusCategory =='Tier 4 - ROM'){
        	var distiMandatory = true;
    	}
        if(contryValue =='China' || contryValue =='USA' || contryValue =='Canada'){
            var stateValMandatory = true;            
        }
        if(contryValue =='China' || contryValue =='Taiwan'){
            var IndustryMandatory = true;
        }
        if(contryValue =='USA' ||  contryValue =='Germany'){
            var zipCodeMandatory = true;
        }
        // variable declaration for null check 
            
        var indNull=component.find("Ind-Inp");
        var emailNull=component.find("con-Name-Inp");
        var countryNull=component.find("country-Inp");
        var stateNull=component.find("state-Inp");
        var phoneNull=component.find("Ph-Inp");
        var compNull=component.find("company-Inp");
        var proLV3Null=component.find("Pro-lv3-Inp");
        var projDescNull=component.find("Pro-Desc-Inp");
        var volNull=component.find("Vol-Inp");
        var competitorsNull=component.find("compet-Inp");
        var prefDistiNull=component.find("pre-disti-Inp");
        var shareWithDistiNull=component.find("per-Inp");
        var NXPRepNull=component.find("rep-Inp");
        var frstNameNull=component.find("first-Name-Inp");
        var lastNameNull=component.find("last-Name-Inp");
        var zipNull=component.find("Zip-Inp");
         
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        //var phoneFormat=/[\+]\d{2}[\(]\d{2}[\)]\d{4}[\-]\d{4}/;
        //Null check
        /*if((conMobPh ==null && conPhoneExist == null) || (conMobPh =='' && conPhoneExist == '')){
           phoneNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            phoneNull.set("v.errors", null);
        }*/
 		
        /*if((distiMandatory ==true && distiName == null) || (distiName == '')){
           component.set("v.isLookUpResult", true);
        }
        else{
            component.set("v.isLookUpResult", false);
        } */
        if((regionName !=null && shareToDisti ==null && regionName =='EMEA') || 
             (shareToDisti =='--- None ---' && regionName =='EMEA' && regionName !='')){
           shareWithDistiNull.set("v.errors", [{message:"Please enter a value"}]);            
        }
        else{
            shareWithDistiNull.set("v.errors", null);
        }                                      
        if((industryVal == null && (indFinalValue ==true)) || (industryVal =='--- None ---' &&
          indFinalValue == true)){
            indNull.set("v.errors", [{message:"Please enter a value"}]);
        }
        else{
            indNull.set("v.errors", null);
        }
        if(conEmail ==null || conEmail ==''){
           emailNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            emailNull.set("v.errors", null);
        }
        if(conEmail !=null && conEmail.match(regExpEmailformat)){
            emailNull.set("v.errors", null);                                         
        }
        else{
        	emailNull.set("v.errors", [{message:"Please enter valid Email Address"}]);
            
        }
        if(conComp ==null || conComp ==''){
           compNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            compNull.set("v.errors", null);
        }
        /*if(casProdLV3 ==null || casProdLV3 ==''){
           proLV3Null.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            proLV3Null.set("v.errors", null);
        }*/
        if(projectDesc ==null || projectDesc ==''){
           projDescNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            projDescNull.set("v.errors", null);
        }
        
        if(represetNotes ==null || represetNotes ==''){
           NXPRepNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            NXPRepNull.set("v.errors", null);
        }
        
        if((conFirstNameExist ==null || conFirstNameExist =='') ){
           frstNameNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            frstNameNull.set("v.errors", null);
        }
        if((conLastNameExist == null || conLastNameExist =='' )){
           lastNameNull.set("v.errors", [{message:"Please enter a value"}]);            
        }
        else{
            lastNameNull.set("v.errors", null);
        }
        if(contryValue == null || contryValue =='--- None ---'){
           countryNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            countryNull.set("v.errors", null);
        }
        if((stateValue == '--- None ---' && (stateValMandatory ==true)) || stateValue ==''){            
           stateNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            stateNull.set("v.errors", null);
        }
        if((zipCodeVal == null && (zipCodeMandatory ==true)) || zipCodeVal ==''){            
           zipNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            zipNull.set("v.errors", null);
        }
        
        
        
        
        //Create Lead 
        if( conEmail !=null && conComp != null && /*casProdLV3 !=null &&*/ ((regionName !=null &&
          shareToDisti !=null ) || regionName ==null || regionName=='') &&  projectDesc !=null  &&  represetNotes !=null && 
           /*((distiMandatory ==true && distiName != null) || distiMandatory !=true)  &&                                                                
          (conMobPh !=null || conPhoneExist != null) &&*/ conFirstNameExist !=null && conLastNameExist != null &&
           contryValue !=null && contryValue !='--- None ---' && ((stateValMandatory ==true && stateValue!=null) || 
           (stateValMandatory !=true)) && ((indFinalValue ==true && industryVal !=null) ||
            (indFinalValue !=true)) && ((zipCodeMandatory ==true && zipCodeVal !=null) ||
            (zipCodeMandatory !=true))){
            if((conEmail !='' && conComp != '' /*&& casProdLV3 !=''*/ &&
             shareToDisti !='' &&  projectDesc !=''  &&  represetNotes !='' /*&& distiName != '' &&
              (conPhoneExist != '' || conMobPh !='')*/ && conFirstNameExist !='' && conLastNameExist != '' &&
           contryValue !='' &&  stateValue!='' && industryVal !='' && zipCodeVal !='' )){
            
            var action = component.get("c.createLead");            
        	action.setParams({ caseId : component.get("v.recordId"),
                              contactfirstName : conFirstNameExist, contactLastName : conLastNameExist,
                              caseproduct : casProd, caseType : casProdType,
                              contactEmail : conEmail, contactComp : conComp,
                              projctDesc : projectDesc, timeLineValueCas : timeLineValue,
                              volme : volume, competitor : competitor, industryValue : industryVal,
                               conPhone : conPhoneExist, conMobPhone : conMobPh,
                              caseNumber : casNum, shareWithDisti : shareToDisti, 
                              NXPNotes : represetNotes, countryValu : contryValue, 
                              stateValu : stateValue, proLV3 : casProdLV3, postalCode : zipCodeVal,
                              accDistiName : distiName, proLv1 : casProdLV1, proLv2 : casProdLV2});            
            action.setCallback(this, function(response){
                var state = response.getState();
            	if (state === "SUCCESS"){                     
                	//window.location.href = '/'+casId;
					component.set("v.isCreated", true);                    
            	}                
            });
           $A.enqueueAction(action); 
            }
        }
    },
})