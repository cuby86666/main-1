({
    
    TranscriptDetails : function(cmp) {
       
        var action = cmp.get("c.gettranscriptDetails");
               
	   action.setParams({ 
	   
	  transid: cmp.get("v.recordId")
	  });
        
	  action.setCallback(this, function(response){
            var state = response.getState();
          
          
            if (state === "SUCCESS"){
                
                var result=response.getReturnValue();
                var contactexists = result.ContactId;
            	cmp.set("v.LiveChatTranscript", result); 
                cmp.set("v.coontactId",result.ContactId);
             
                if(contactexists != null){
                    cmp.set("v.Contactexixts", true);
                }
                else {
                    cmp.set("v.Contactexixts", false);
                }
                                
				
                var actioncon = cmp.get("c.getContactDetails");
				actioncon.setParams({ 
	   
	  contactid: result.ContactId
	  });
	  actioncon.setCallback(this, function(response){
          var state = response.getState();
		  if (state === "SUCCESS"){
                console.log(state);
              
                var result=response.getReturnValue();
                console.log(result);
                
            	cmp.set("v.contact", result); 
                 
				}
				 });
				 $A.enqueueAction(actioncon);
            }
				 });
				 $A.enqueueAction(action);
     				
	},
    
       
    
             
       /* 
    
    ChckDetails : function(cmp) {
        
        var action = cmp.get("c.getChckDetails");
               
	   action.setParams({ 
	   
	  contactid: cmp.get("v.recordId")
	  });
        
	  action.setCallback(this, function(response){
            var state = response.getState();
          
            if (state === "SUCCESS"){
                
                var result=response.getReturnValue();
                
                
            		cmp.set("v.LeadchatTranscript", result); 
                cmp.set("v.Transcriptname",result.Name);

            }
				
				 });
				 $A.enqueueAction(action);
				
	},
    */
    
    
    /*
    
    Transcriptdetails : function(cmp) {
       
        var action = cmp.get("c.getChckDetails");
               
	   action.setParams({ 
	   
	  contactid: cmp.get("v.recordId")
	  });
        
	  action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                
                var result=response.getReturnValue();
                
            	cmp.set("v.LeadchatTranscript", result); 
                cmp.set("v.Transcriptname",result.Name);		
                
				}
				
				 });
				 $A.enqueueAction(action);
				
	},
    */
    
    
        
        
    fetchprdPicklistValues: function(component, controllerField, dependentField) {
        
      // call the server side function  
    
      var action = component.get("c.getprdDependentOptionsImpl");
        
      // pass paramerters [object name , contrller field name ,dependent field name] -
      // to server side function 
      var objInfo=component.get("v.caseObjInfo");
        
 
      action.setParams({
         'objApiName': component.get("v.caseObjInfo"),
         'contrfieldApiName': controllerField,
         'depfieldApiName': dependentField
      });
        
        
        action.setCallback(this, function(response) {
         
          var state = response.getState();
          
         if (response.getState() == "SUCCESS") {
             
            //store the return response from server (map<string,List<string>>)  
            var StoreResponse = response.getReturnValue();
             
 			//var countryCurrent=component.get("v.contact.Community_Web_Country__c");
       		// alert('check'+countryCurrent);
            // once set #StoreResponse to depnedentFieldMap attribute 
            component.set("v.prddepnedentFieldMap", StoreResponse); 			
            // create a empty array for store map keys(@@--->which is controller picklist values) 
 
            var listOfkeys = []; // for store all map keys (controller picklist values)
            var ControllerField = []; // for store controller picklist value to set on ui field. 
 
            // play a for loop on Return map 
            // and fill the all map key on listOfkeys variable.
            for (var singlekey in StoreResponse) {
               listOfkeys.push(singlekey);
                
            } 
            //set the controller field value for ui:inputSelect 
              //var contactCountry=component.get("v.contact.Community_Web_Country__c");
          
       var prdvalue=component.get("v.contact.case.Product__c");
// stateValue                                                       
    	 var prd1Value=component.get("v.contact.case.Product_Category__c");
             
             
             
             if(prdvalue != null){                 
                 ControllerField.push({
                  class: "optionClass",
                  label: prdvalue,
                  value: prdvalue
               });
                      
        	 component.set("v.ProductVal",prdvalue);

                 
             }
            if (listOfkeys != undefined && listOfkeys.length > 0) {
               ControllerField.push({
                  class: "optionClass",
                  label: "--- None ---",
                  value: "--- None ---"
               });
                var defaultVal = [{
            class: "optionClass",
            label: '--- None ---',
            value: '--- None ---'
         	}];
               component.find('Prod-lv2').set("v.options", defaultVal);
            }
 
            for (var i = 0; i < listOfkeys.length; i++) {                
                
                if(listOfkeys[i] != prdvalue){
                    ControllerField.push({
                  	class: "optionClass",
                  	label: listOfkeys[i],
                  	value: listOfkeys[i]
               		});
                }
            }
            // set the ControllerField variable values to country(controller picklist field)
            
                component.set("v.prdList",ControllerField); 
                         
            //component.find('country-Inp').set("v.options", ControllerField);
          
         	}
           if(prdvalue !=null){
                var Map = component.get("v.prddepnedentFieldMap");
             		var ListOfDependentFields = Map[prdvalue];
             		var dependentFields = [];
                 if(prd1Value !=null){                     
                 		dependentFields.push({
            					class: "optionClass",
            					label: prd1Value,
            					value: prd1Value
         					});
					component.set("v.Prd1val",prd1Value);                     
                       }               
                     if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
         			 dependentFields.push({
            			class: "optionClass",
            			label: "--- None ---",
            			value: "--- None ---"
         				}); 			
      				}
                    else{
           			dependentFields.push({
            			class: "optionClass",
            			label: "--- None ---",
            			value: "--- None ---"
        		 		});
                        component.find('Prod-lv2').set("v.options", dependentFields);
                    }
             		for (var i = 0; i < ListOfDependentFields.length; i++) {
                         if(ListOfDependentFields[i] != prd1Value){
                             dependentFields.push({
            				class: "optionClass",
            				label: ListOfDependentFields[i],
            				value: ListOfDependentFields[i]
         					});
                         }
             		}
                  component.find('Prod-lv2').set("v.options", dependentFields);
                 // component.set("v.isDependentDisable", false);
      			var prdl2=component.find("Prod-lv2").get("v.value");        
        		component.set("v.Prd1val",prdl2);
             }
            
      });
         $A.enqueueAction(action);
     
   },


 fetchDepValues: function(component, ListOfDependentFields) {
      // create a empty array var for store dependent picklist values for controller field)  
      var dependentFields = [];
 
      if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
         dependentFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
 			
      }
       else{
           dependentFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
         component.find('state-Inp').set("v.options", dependentFields);
         //component.set("v.isDependentDisable", True);
       }
      for (var i = 0; i < ListOfDependentFields.length; i++) {
         dependentFields.push({
            class: "optionClass",
            label: ListOfDependentFields[i],
            value: ListOfDependentFields[i]
         });
      }
      // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
      component.find('state-Inp').set("v.options", dependentFields);
       //component.set("v.stateList",dependentFields);
       //alert('test'+dependentFields);
      // make disable false for ui:inputselect field 
      component.set("v.isDependentDisable", false);
   },
    

    
    

 fetchprdDepValues: function(component, ListOfDependentFields) {
      // create a empty array var for store dependent picklist values for controller field)  
      var dependentFields = [];
 
      if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
         dependentFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
 			
      }
       else{
           dependentFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
         component.find('Prod-lv2').set("v.options", dependentFields);
         component.set("v.isprdDependentDisable", True);
       }
      for (var i = 0; i < ListOfDependentFields.length; i++) {
         dependentFields.push({
            class: "optionClass",
            label: ListOfDependentFields[i],
            value: ListOfDependentFields[i]
         });
      }
      // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
      component.find('Prod-lv2').set("v.options", dependentFields);
       //component.set("v.stateList",dependentFields);
       //alert('test'+dependentFields);
      // make disable false for ui:inputselect field 
     component.set("v.isprdDependentDisable", false);
   },
    
    fetchprddDepValues: function(component, ListOfDependentFields) {
      // create a empty array var for store dependent picklist values for controller field)  
      var dependentFields = [];
 
      if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
         dependentFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
 			
      }
       else{
           dependentFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
         component.find('Prod-lv3').set("v.options", dependentFields);
         //component.set("v.isprddDependentDisable", True);
       }
      for (var i = 0; i < ListOfDependentFields.length; i++) {
         dependentFields.push({
            class: "optionClass",
            label: ListOfDependentFields[i],
            value: ListOfDependentFields[i]
         });
      }
      // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
      component.find('Prod-lv3').set("v.options", dependentFields);
       //component.set("v.stateList",dependentFields);
       //alert('test'+dependentFields);
      // make disable false for ui:inputselect field 
     component.set("v.isprddDependentDisable", false);
   },
     		

    
    
     fetchprddPicklistValues: function(component, controllerField, dependentField) {
        
      // call the server side function  
    
      var action = component.get("c.getprddDependentOptionsImpl");
        
      // pass paramerters [object name , contrller field name ,dependent field name] -
      // to server side function 
      var objInfo=component.get("v.caseObjInfo");
        
 
      action.setParams({
         'objApiName': component.get("v.caseObjInfo"),
         'contrfieldApiName': controllerField,
         'depfieldApiName': dependentField
      });
      //set callback   
      action.setCallback(this, function(response) {
         
         if (response.getState() == "SUCCESS") {
            //store the return response from server (map<string,List<string>>)  
            var StoreResponse = response.getReturnValue();
             
 			//var countryCurrent=component.get("v.contact.Community_Web_Country__c");
       		// alert('check'+countryCurrent);
            // once set #StoreResponse to depnedentFieldMap attribute 
            component.set("v.prdddepnedentFieldMap", StoreResponse); 			
            // create a empty array for store map keys(@@--->which is controller picklist values) 
 
            var listOfkeys = []; // for store all map keys (controller picklist values)
            var ControllerField = []; // for store controller picklist value to set on ui field. 
 
            // play a for loop on Return map 
            // and fill the all map key on listOfkeys variable.
            for (var singlekey in StoreResponse) {
               listOfkeys.push(singlekey);
                
            } 
            //set the controller field value for ui:inputSelect 
              //var contactCountry=component.get("v.contact.Community_Web_Country__c");
               var prddvalue=component.get("v.contact.case.Product_Category__c");
         // var prddvalue=component.find("Prod-lv2").get("v.value"); 
      
// stateValue                                                       
    	 var prdd1Value=component.get("v.contact.case.Product_Sub__c");
                         
           /*  
             if(prddvalue != null){                 
                 ControllerField.push({
                  class: "optionClass",
                  label: prdvalue,
                  value: prdvalue
               });
                      
        	 component.set("v.ProductVal",prdvalue);

                 
             }
			 */
             
            if (listOfkeys != undefined && listOfkeys.length > 0) {
               ControllerField.push({
                  class: "optionClass",
                  label: "--- None ---",
                  value: "--- None ---"
               });
                var defaultVal = [{
            class: "optionClass",
            label: '--- None ---',
            value: '--- None ---'
         	}];
               component.find('Prod-lv3').set("v.options", defaultVal);
            }
            
 
          
         	}
           if(prddvalue !=null){
                var Map = component.get("v.prdddepnedentFieldMap");
             		var ListOfDependentFields = Map[prddvalue];
             		var dependentFields = [];
                 if(prdd1Value !=null){                     
                 		dependentFields.push({
            					class: "optionClass",
            					label: prdd1Value,
            					value: prdd1Value
         					});
					component.set("v.Prdd1val",prdd1Value);                     
                       }               
                     if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0 ) {
         			 dependentFields.push({
            			class: "optionClass",
            			label: "--- None ---",
            			value: "--- None ---"
         				}); 			
      				}
                    else{
           			dependentFields.push({
            			class: "optionClass",
            			label: "--- None ---",
            			value: "--- None ---"
        		 		});
                        component.find('Prod-lv3').set("v.options", dependentFields);
                    }
             		for (var i = 0; i < ListOfDependentFields.length; i++) {
                         if(ListOfDependentFields[i] != prd1Value){
                             dependentFields.push({
            				class: "optionClass",
            				label: ListOfDependentFields[i],
            				value: ListOfDependentFields[i]
         					});
                         }
             		}
                  component.find('Prod-lv3').set("v.options", dependentFields);
                 // component.set("v.isDependentDisable", false);
      			var prdl3=component.find("Prod-lv3").get("v.value");        
        		component.set("v.Prdd1val",prdl3);
             }
      });
      $A.enqueueAction(action);
   },
    
 
	 fetchPicklistValues: function(component, controllerField, dependentField) {
        
      // call the server side function  
    
      var actioncon = component.get("c.getDependentOptionsImpl");
        
      // pass paramerters [object name , contrller field name ,dependent field name] -
      // to server side function 
      var objInfo=component.get("v.accObjInfo");
        
 
      actioncon.setParams({
         'objApiName': component.get("v.accObjInfo"),
         'contrfieldApiName': controllerField,
         'depfieldApiName': dependentField
      });
      //set callback   
      actioncon.setCallback(this, function(response) {
          
          
         if (response.getState() == "SUCCESS") {
            //store the return response from server (map<string,List<string>>)  
            var StoreResponse = response.getReturnValue();
 			//var countryCurrent=component.get("v.contact.Community_Web_Country__c");
             
       		//alert('check'+countryCurrent);
       		
            // once set #StoreResponse to depnedentFieldMap attribute 
            component.set("v.depnedentFieldMap", StoreResponse); 			
            // create a empty array for store map keys(@@--->which is controller picklist values) 
 
            var listOfkeys = []; // for store all map keys (controller picklist values)
            var ControllerField = []; // for store controller picklist value to set on ui field. 
 
            // play a for loop on Return map 
            // and fill the all map key on listOfkeys variable.
            for (var singlekey in StoreResponse) {
               listOfkeys.push(singlekey);
                
            } 
            //set the controller field value for ui:inputSelect 
              //var contactCountry=component.get("v.contact.Community_Web_Country__c");
              //var concntry=component.get("v.LiveChatTranscript.contact.Community_Web_Country__c");
              //var concfrst=component.get("v.LiveChatTranscript.ContactId");
             // var idd = component.get("v.LiveChatTranscript.ContactId");
             //var idds = component.get("v.contact.Id");
            //alert(idds);
            // alert("Test" + concfrst);
                var conctry=component.get("v.LiveChatTranscript.Country__c");
              // Start
             function capital(str) {
   var splitStr = str.toLowerCase().split(' ');
   for (var i = 0; i < splitStr.length; i++) {
       // You do not need to check if i is larger than splitStr length, as your for does that for you
       // Assign it back to the array
       splitStr[i] = splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1);     
   }
   // Directly return the joined string
   return splitStr.join(' '); 
}
             if(conctry !=null && conctry != 'USA'){
        var contactCountry1 =  capital(conctry) ;  
             }
             else {
                var contactCountry1 = conctry;
             }
             // End
             // 
             /*
             if(conctry !=null && conctry != 'USA'){
             	var conctry1 = conctry.toLowerCase();
              	var contactCountry1 = conctry1.charAt(0).toUpperCase() + conctry1.slice(1);
             }
             else {
                var contactCountry1 = conctry;
             }
             */
            
             //alert(idds);
              //
              //var contactCountry1=component.get("v.LiveChatTranscript.Country__c");
              
       
                                                                    
    	 var stateValue=component.get("v.contact.Account.State_Province__c");
             
              if(conctry =null){
 ControllerField.push({
                  class: "optionClass",
                  label: "--- None ---",
                  value: "--- None ---"
               });
              
}             
             
             if(contactCountry1 !=null){
                 var contactCountryUpper=contactCountry1.toUpperCase();
             }
              if(stateValue != null){
                    var stateValueUpper=stateValue.toUpperCase();
                    }			             
              if(contactCountry1 =='USA' || contactCountry1 =='Canada' || contactCountry1=='China'){
            component.set("v.stateMandatory", true);
        }
        else{
           component.set("v.stateMandatory", false); 
        }
        if(contactCountry1 =='USA' || contactCountry1=='Germany'){
            component.set("v.ZipValmandatory", true);
        }
        else{
           component.set("v.ZipValmandatory", false); 
        }
        if(contactCountry1 =='China' || contactCountry1 == 'Taiwan'){
           component.set("v.IndMandatory", true); 
        }
        else{
           component.set("v.IndMandatory", false); 
        }
             
               
                     if(contactCountry1 != null){                 
                 ControllerField.push({
                  class: "optionClass",
                  label: contactCountry1,
                  value: contactCountry1
               });
                      
        	 component.set("v.countryVal",contactCountry1);
                 
             }

            if (listOfkeys != undefined && listOfkeys.length > 0) {
               ControllerField.push({
                  class: "optionClass",
                  label: "--- None ---",
                  value: "--- None ---"
                 
               });
                var defaultVal = [{
            class: "optionClass",
            label: '--- None ---',
            value: '--- None ---'
         	}];
                component.set("v.isDependentDisable", false);
               component.find('state-Inp').set("v.options", defaultVal);
            }
 

            for (var i = 0; i < listOfkeys.length; i++) {                
                
                if(listOfkeys[i].toUpperCase() != contactCountryUpper){
                    ControllerField.push({
                  	class: "optionClass",
                  	label: listOfkeys[i],
                  	value: listOfkeys[i]
               		});
                }
            }
            // set the ControllerField variable values to country(controller picklist field)
            
                component.set("v.countryList",ControllerField); 
                         
            //component.find('country-Inp').set("v.options", ControllerField);
          
         	}
           if(contactCountry1 !=null){
                var Map = component.get("v.depnedentFieldMap");
             		var ListOfDependentFields = Map[contactCountry1];
             		var dependentFields = [];
                 if(stateValue !=null){                     
                 		dependentFields.push({
            					class: "optionClass",
            					label: stateValue,
            					value: stateValue
         					});
					component.set("v.stateVal",stateValue);                     
                       }               
                     if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
         			 dependentFields.push({
            			class: "optionClass",
            			label: "--- None ---",
            			value: "--- None ---"
         				}); 			
      				}
                    else{
           			dependentFields.push({
            			class: "optionClass",
            			label: "--- None ---",
            			value: "--- None ---"
        		 		});
                        component.find('state-Inp').set("v.options", dependentFields);
                    }
             		for (var i = 0; i < ListOfDependentFields.length; i++) {
                         if(ListOfDependentFields[i].toUpperCase() !=stateValueUpper){
                             dependentFields.push({
            				class: "optionClass",
            				label: ListOfDependentFields[i],
            				value: ListOfDependentFields[i]
         					});
                         }
             		}
                  component.find('state-Inp').set("v.options", dependentFields);
                  component.set("v.isDependentDisable", false);
      			var state=component.find("state-Inp").get("v.value");        
        		component.set("v.stateVal",state);
             }
      });
      $A.enqueueAction(actioncon);
   },
    
      fetchIndPickListVal: function(component, fieldName, elementId) {
          
        var action = component.get("c.getselectOptions");
          
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                
                var allValues = response.getReturnValue();
 
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(elementId).set("v.options", opts);
                 //component.set("v.IndustryList",opts);
            }
        });
        $A.enqueueAction(action);
    },
   
      fetchDepValues: function(component, ListOfDependentFields) {
      // create a empty array var for store dependent picklist values for controller field)  
      var dependentFields = [];
 
      if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
         dependentFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
 			
      }
       else{
           dependentFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
         component.find('state-Inp').set("v.options", dependentFields);
         //component.set("v.isDependentDisable", True);
       }
      for (var i = 0; i < ListOfDependentFields.length; i++) {
         dependentFields.push({
            class: "optionClass",
            label: ListOfDependentFields[i],
            value: ListOfDependentFields[i]
         });
      }
      // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
      component.find('state-Inp').set("v.options", dependentFields);
       //component.set("v.stateList",dependentFields);
       //alert('test'+dependentFields);
      // make disable false for ui:inputselect field 
      component.set("v.isDependentDisable", false);
   },
    
    pickListVall : function(cmp){
        
        var optss = [
            {class: "optionClass",
            label: "--- None ---",
             value: "--- None ---"},
            { "class": "optionClass", label: "Yes", value: "Yes" },
            { "class": "optionClass", label: "No", value: "No" }           
        ];
        cmp.find("per-Mark").set("v.options", optss);
        
    },
    
    pickListVal : function(cmp){
        var opts = [
            {class: "optionClass",
            label: "--- None ---",
             value: "--- None ---"},
            { "class": "optionClass", label: "Yes", value: "Yes" },
            { "class": "optionClass", label: "No", value: "No" }           
        ];
        cmp.find("per-Inp").set("v.options", opts);
        
    },
    
     searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchprdSearch"); 

      // set param to method        
            action.setParams({
            'searchKeyWord': getInputkeyWord            
          });                         
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
        
                if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                    
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                }                	
	 			else {
	                    component.set("v.Message", 'Search Result...');
	                }                
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);    
	},
    
    
   
  fetchRegVales : function(component,event,controllerValueKey) {
       
        component.set("v.regVal","");
      
        var action = component.get("c.fetchRegion");
      
       
        action.setParams({
            'countryVal': controllerValueKey            
          });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                          
                if ( storeResponse =='EMEA') {
                    component.set("v.regVal",storeResponse);
                    component.set("v.preDistiMandatory", true);
                    component.set("v.preMarkMandatory", true); 
                }
                else{
                    component.set("v.preDistiMandatory", false);
                    component.set("v.preMarkMandatory", false);
                }
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
        
    }
    
	
})