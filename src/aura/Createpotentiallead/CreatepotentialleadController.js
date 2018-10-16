({
	doInits : function(component, event, helper) {

	 	component.set("v.stateMandatory", false);
        component.set("v.ZipValmandatory", false);
        component.set("v.preDistiMandatory", false);
        
		helper.fetchIndPickListVal(component, 'Industry','Ind-Inp');
        //helper.ContactDetails(component);
		helper.TranscriptDetails(component);
        //helper.ContactDetails(component);
        helper.pickListVall(component);
        helper.pickListVal(component); 
        //helper.ChckDetails(component); 
        helper.fetchprdPicklistValues(component, 'Product__c', 'Product_Category__c');
       	helper.fetchprddPicklistValues(component, 'Product_Category__c','Product_Sub__c');
        helper.fetchPicklistValues(component, 'Country__c', 'State_Province__c');
        
      	
	},	
		SetFirstNameChange : function(component, event, helper){
         var firstNamVal = component.find("first-Name-Inp").get("v.value"); 		      
        component.set("v.firstNameVal", firstNamVal);  
		},
    SetconFirstNameChange : function(component, event, helper){
         var firstNamVal = component.find("first-Name-Inp-c").get("v.value"); 		      
        component.set("v.firstNameValC", firstNamVal);  
		},
        SetCompanyChange : function(component, event, helper){
         var CompanyNamVal = component.find("comp-id").get("v.value"); 		      
        component.set("v.CompVal", CompanyNamVal);  
		},
    
    	PerFieldChange:function(component, event, helper){
    	var shareDisti=component.find("per-Inp").get("v.value");        
        component.set("v.perToDisti",shareDisti);
	},
    
    PerMarkFieldChange:function(component, event, helper){
    	var shareDisti=component.find("per-Mark").get("v.value");        
        component.set("v.perToMark",shareDisti);
	},
		
      SetLastNameChange: function(component, event, helper){
        var lstNameVal = component.find("last-Name-Inp").get("v.value");         
        component.set("v.lastNameVal", lstNameVal);        
	},
       SetconLastNameChange: function(component, event, helper){
        var lstNameVal = component.find("last-Name-Inp-c").get("v.value");         
        component.set("v.lastNameValC", lstNameVal);        
	},
    
       IndFieldChange:function(component, event, helper){
    	var indVal=component.find("Ind-Inp").get("v.value");        
        component.set("v.Industry",indVal);
	},
    
    onControllerprdddFieldChange:function(component, event, helper){
    	var prodval2=component.find("Prod-lv3").get("v.value");        
        component.set("v.ProductVal2",prodval2);
	},
   
	SetZipCode: function(component, event, helper){
        var zipVal = component.find("Zip-Inp").get("v.value");         
        component.set("v.zipCodeValue", zipVal);
	},
	
	onDepFieldChange:function(component, event, helper){
        var state=component.find("state-Inp").get("v.value");        
        component.set("v.stateVal",state);
    },
    
    SetRepNotes:function(component, event, helper){
    	var repNotes=component.find("rep-Inp").get("v.value");        
        component.set("v.NXPRep",repNotes);
        
        
	}, 
 
    SetPhone: function(component, event, helper){
        var phVal = component.find("Ph-Inp").get("v.value");         
        component.set("v.phoneValue", phVal);
	},
    
    closeModel: function(component, event, helper) {
      //for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
      
         var transId = component.get("v.recordId");
      component.set("v.isCreated", false);
         window.location.href = '/'+transId;
   },
    
    cancelLead : function(component, event, helper) {
        component.set("v.isSpinner", true);
         var recordId = component.get("v.recordId");                                        
         window.location.href = '/'+recordId;                                       
    },
    
    SetProjDesc:function(component, event, helper){
var projectDesc = component.find("Pro-Desc-Inp").get("v.value");
        component.set("v.ProjDesc",projectDesc);
	},
    
    
    
    //--------------Start----------------//
    //
      //Restict user entering date value and request to use Date picker  
    keyPressController : function(component, event, helper) {
      // get the search Input keyword   
		var getInputkeyWord = component.get("v.SearchKeyWord");
        console.log(getInputkeyWord);
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
     	var action = component.get("c.fetchproducts");              
                                    
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
         component.find('Prod-Id').set("v.value","");
    },
    
        // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
     
    // get the selected Opportunity record from the COMPONETN event 	 
       var selectedPrdGetFromEvent = event.getParam("prdRecordByEvent");
	   
	   component.set("v.selectedRecord" , selectedPrdGetFromEvent);
                 
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
    

	getProdId:function(component, event, helper) {
    
var prodnum=component.get("v.selectedRecord.Name");
    
 var action = component.get("c.getPrdDetails");            
        	action.setParams({ Prodnum : prodnum });
action.setCallback(this, function(response){
  var state = response.getState();
    
if (response.getState() == "SUCCESS") {
 var StoreResponse = response.getReturnValue();
    
var sales = StoreResponse.Product_Type__c;
    component.find('Prod-Id').set("v.value",sales);
                           
            	}               
            });
           $A.enqueueAction(action); 
},
    
    
    //--------End-----------
    
    createLeadButton : function(component, event, helper) {                
        //var conName=component.get("v.contact.Id");
        //alert('checkcon'+conName);
       var conId=component.get("v.LiveChatTranscript.ContactId"); 
        if(conId != null) {
            var conFirstNameExist=component.get("v.contact.FirstName");
             var conLastNameExist=component.get("v.contact.LastName");
             var conEmail=component.get("v.contact.Email");
             //var zipCodeVal=component.get("v.contact.MailingPostalCode");
        }
       	
        else {
             var conFirstNameExist=component.get("v.LiveChatTranscript.First_Name__c"); 
            var conLastNameExist=component.get("v.LiveChatTranscript.Last_Name__c");
            var conEmail=component.get("v.LiveChatTranscript.Email__c");
           // var zipCodeVal=component.get("v.zipCodeValue");
            
        }
        
        //var conFirstNameExist=component.get("v.firstNameVal");
        //var conFirstNameExist=component.find("first-Name-Inp").get("v.value");
      
        var conPhoneExist=component.get("v.contact.Phone");  
        var contactId = component.get("v.recordId");
		var company=component.get("v.LiveChatTranscript.Company__c");        
        
        //var caseOwner=component.get("v.users.Name");   
        
        var conPh=component.get("v.phoneValue");
        var conMobPh=component.get("v.mobPhoneValue");
        
        var projectDesc=component.get("v.ProjDesc");
        var industryVal=component.get("v.Industry");
        
        //var shareToDisti=component.get("v.perToDisti");
		//var shareToMark=component.get("v.perToMark");
        var shareToDisti=component.get("v.LiveChatTranscript.Distributor_Permission__c");
		var shareToMark=component.get("v.LiveChatTranscript.Marketing_Permission__c");
        var represetNotes=component.get("v.NXPRep");
       
        
        var stateValue=component.get("v.stateVal");
        var zipCodeVal=component.get("v.zipCodeValue");
        var firstNameVal=component.get("v.firstNameVal");
        var lastNameVal=component.get("v.lastNameVal");
        
        var regionName=component.get("v.regVal");
        var indFinalValue=component.get("v.IndMandatory");
        var contryValue=component.get("v.countryVal");
        var prodlv1=component.get("v.ProductVal");
        var prodlv2=component.get("v.ProductVal1");
        var prodlv3=component.get("v.ProductVal2");
        var prodnum=component.get("v.selectedRecord.Name");
        var prodId=component.get("v.ProdId");
        //var Transname=component.get("v.Transcriptname");
        var Transname=component.get("v.LiveChatTranscript.Name");
        
        
        
       	// value declaration
        
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
        // 
        if(conId != null) {
         var frstNameNull=component.find("first-Name-Inp-c");
        var lastNameNull=component.find("last-Name-Inp-c");
         var emailNull=component.find("con-Name-Inp-c");
    }
    else{
       var frstNameNull=component.find("first-Name-Inp");
        var lastNameNull=component.find("last-Name-Inp");
         var emailNull=component.find("con-Name-Inp");
}
         var companyNull=component.find("comp-id");     
        var indNull=component.find("Ind-Inp");
       
        var countryNull=component.find("country-Inp");
        var stateNull=component.find("state-Inp");
        var phoneNull=component.find("Ph-Inp");
        var projDescNull=component.find("Pro-Desc-Inp");
        var prefDistiNull=component.find("pre-disti-Inp");
        var shareWithDistiNull=component.find("per-Inp");
        var shareWithMarkNull=component.find("per-Mark");
        var NXPRepNull=component.find("rep-Inp");
       
        var zipNull=component.find("Zip-Inp");
        var prodlv1Null=component.find("Prod-lv1");
        var prodlv2Null=component.find("Prod-lv2");
         
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        
		if((regionName !=null && shareToDisti ==null && regionName =='EMEA') || 
             (shareToDisti =='--- None ---' && regionName =='EMEA' && regionName !='')){
           shareWithDistiNull.set("v.errors", [{message:"Please enter a value"}]);  
            var share ='correct disti';
        }
        else{
            shareWithDistiNull.set("v.errors", null);
        }  


			if((regionName !=null && shareToMark ==null && regionName =='EMEA') || 
             (shareToMark =='--- None ---' && regionName =='EMEA' && regionName !='')){
           shareWithMarkNull.set("v.errors", [{message:"Please enter a value"}]);    
                var share1 ='correct Mark';
        }
        else{
            shareWithMarkNull.set("v.errors", null);
        }                                      
        if((industryVal == null && (indFinalValue ==true)) || (industryVal =='--- None ---' &&
          indFinalValue == true)){
            indNull.set("v.errors", [{message:"Please enter a value"}]);
        }
        else{
            indNull.set("v.errors", null);
        }
        
         if((company ==null || company =='') ){
           companyNull.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            companyNull.set("v.errors", null);
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
            var statepass = 'true';
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
        
          if(prodlv1 == null || prodlv1 =='--- None ---'){
           prodlv1Null.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            prodlv1Null.set("v.errors", null);
        }
        
              if(prodlv2 == null || prodlv2 =='--- None ---'){
           prodlv2Null.set("v.errors", [{message:"Please enter a value"}]); 
        }
        else{
            prodlv2Null.set("v.errors", null);
        }
            
        //Create Lead 
        if( conEmail !=null  &&  company !='' && ((
          share != 'correct disti' && share1 != 'correct Mark' )) &&  projectDesc !=null  &&  represetNotes !=null && 
			conFirstNameExist !=null && conLastNameExist != null &&
           contryValue !=null && contryValue !='--- None ---' && (statepass != 'true') && ((indFinalValue ==true && industryVal !=null) ||
            (indFinalValue !=true)) && ((zipCodeMandatory ==true && zipCodeVal !=null) ||
            (zipCodeMandatory !=true)) && (prodlv1 !=null && prodlv1 !='---None---') && (prodlv2 !=null && prodlv2 !='---None---')){
            
            if((conEmail !='' &&
             shareToDisti !='' && shareToMark !=''  &&  projectDesc !='' &&  represetNotes !='' && conFirstNameExist !='' && conLastNameExist != '' &&
           contryValue !='' &&  stateValue!='' && industryVal !='' && zipCodeVal !='' )){
                       
            var action = component.get("c.createLead");            
        	action.setParams({ contactid : component.get("v.recordId"),
                              contactfirstName : conFirstNameExist, contactLastName : conLastNameExist,
                              contactEmail : conEmail, 
                              projctDesc : projectDesc,
                               industryValue : industryVal,
                               conPhone : conPhoneExist,
                               shareWithDisti : shareToDisti,shareWithMark : shareToMark,
                              NXPNotes : represetNotes, countryValu : contryValue, 
                              stateValu : stateValue, postalCode : zipCodeVal, prodlv1 : prodlv1, prodlv2: prodlv2 , prodlv3: prodlv3,prodnum: prodnum,prodId: prodId,transname: Transname,company: company
                              });            
            action.setCallback(this, function(response){
                var state = response.getState();
                
            	if (state === "SUCCESS"){                     
                	
					component.set("v.isCreated", true); 
                    
                     //start   
                var actiontrs = component.get("c.getupdChckDetails");
                    
        actiontrs.setParams({
	   
	  transcriptid: component.get("v.recordId")
	  });
      
                    actiontrs.setCallback(this, function(response){
            var state = response.getState();
             
            if (state === "SUCCESS"){
                
                
                 
            }
				 });
	  $A.enqueueAction(actiontrs);
//End 
     
            	}
                
                
                
                
                
                                   
             
            });
           $A.enqueueAction(action); 
            }
        }
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
    
    onControllerprdFieldChange: function(component, event, helper) {
     
      // get the selected value
      var controllerValueKey = event.getSource().get("v.value"); 		
      // get the map values   
      var Map = component.get("v.prddepnedentFieldMap");
       
                       
      // check if selected value is not equal to None then call the helper function.
      // if controller field value is none then make dependent field value is none and disable field
      if (controllerValueKey != '--- None ---') {
 
         // get dependent values for controller field by using map[key].  
         // for i.e "India" is controllerValueKey so in the map give key Name for get map values like 
         // map['India'] = its return all dependent picklist values.
         var ListOfDependentFields = Map[controllerValueKey];          
         helper.fetchprdDepValues(component, ListOfDependentFields);
         
 
      } else {          
         var defaultVal = [{
            class: "optionClass",
            label: '--- None ---',
            value: '--- None ---'
         }];
         component.find('Prod-lv2').set("v.options", defaultVal);
          component.find('Prod-lv3').set("v.options", defaultVal);
         component.set("v.isprdDependentDisable", true);
          component.set("v.isprddDependentDisable", true);
          
      }
      var prd=component.find("Prod-lv1").get("v.value");      
        component.set("v.ProductVal",prd);
        
      
   },
    
     onControllerprddFieldChange: function(component, event, helper) {
     
      // get the selected value
      var controllerValueKey = event.getSource().get("v.value"); 		
      // get the map values   
      var Map = component.get("v.prdddepnedentFieldMap");
       
                       
      // check if selected value is not equal to None then call the helper function.
      // if controller field value is none then make dependent field value is none and disable field
      if (controllerValueKey != '--- None ---') {
 
         // get dependent values for controller field by using map[key].  
         // for i.e "India" is controllerValueKey so in the map give key Name for get map values like 
         // map['India'] = its return all dependent picklist values.
         var ListOfDependentFields = Map[controllerValueKey];          
         helper.fetchprddDepValues(component, ListOfDependentFields);
         
 
      } else {          
         var defaultVal = [{
            class: "optionClass",
            label: '--- None ---',
            value: '--- None ---'
         }];
         component.find('Prod-lv3').set("v.options", defaultVal);
         component.set("v.isprddDependentDisable", true);
      }
      var prd=component.find("Prod-lv2").get("v.value");      
        component.set("v.ProductVal1",prd);
        
      var prd1=component.find("Prod-lv3").get("v.value");        
        component.set("v.Prdd1val",prd1);
   }
     		
     		
		
		
})