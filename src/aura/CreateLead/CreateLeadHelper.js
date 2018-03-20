({
	ContactDetails : function(cmp) {
        var action = cmp.get("c.getContactDetails");
        var CaseId;
        action.setParams({            
        CaseId: cmp.get("v.recordId")
        });        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result=response.getReturnValue();
                cmp.set("v.contact", result.contactCurrent); 
                cmp.set("v.cases", result.caseCurrent);
                cmp.set("v.users", result.caseOwner);
				var cusCategory=cmp.get("v.cases.Account.Customer_Category__c");
        		/*if(cusCategory =='Tier 4 - Long Tail' || cusCategory =='Tier 4 - ROM'){
            		cmp.set("v.preferredDistiMandatory", true);
    			}
                else{
                   cmp.set("v.preferredDistiMandatory", false); 
                }*/
				              
            }
        });
		       
        $A.enqueueAction(action);		
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
                //component.find(elementId).set("v.options", opts);
                component.set("v.IndustryList",opts);
            }
        });
        $A.enqueueAction(action);
    },
    fetchPickListVal: function(component, fieldName, elementId) {
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
               // component.set("v.IndustryList",opts);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchVolPickListVal: function(component, fieldName, elementId) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            "objObject": component.get("v.enObjInfo"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
 				var volumeVal=component.get("v.cases.Project_Annual_Volume__c");
                //var volumeUpper=volumeVal.toUpperCase();
                if(volumeVal != null){
                    opts.push({
                        class: "optionClass",
                        label: volumeVal,
                        value: volumeVal
                    });
                    component.set("v.volume",volumeVal);
                }
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    if(allValues[i] != volumeVal){
                        opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    	});
                    }                                                              
                }
                component.find(elementId).set("v.options", opts);                 
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchPicklistValues: function(component, controllerField, dependentField) {
        
      // call the server side function  
      var action = component.get("c.getDependentOptionsImpl");
        
      // pass paramerters [object name , contrller field name ,dependent field name] -
      // to server side function 
      var objInfo=component.get("v.accObjInfo");
        
 
      action.setParams({
         'objApiName': component.get("v.accObjInfo"),
         'contrfieldApiName': controllerField,
         'depfieldApiName': dependentField
      });
      //set callback   
      action.setCallback(this, function(response) {
         if (response.getState() == "SUCCESS") {
            //store the return response from server (map<string,List<string>>)  
            var StoreResponse = response.getReturnValue();
 			var countryCurrent=component.get("v.cases.Community_Web_Country__c");
       		// alert('check'+countryCurrent);
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
              var caseCountry=component.get("v.cases.Community_Web_Country__c");
              var stateValue=component.get("v.cases.State_Province__c");
             
             if(caseCountry !=null){
                 var caseCountryUpper=caseCountry.toUpperCase();
             }
              if(stateValue != null){
                    var stateValueUpper=stateValue.toUpperCase();
                    }			             
              if(caseCountry =='USA' || caseCountry =='Canada' || caseCountry=='China'){
            component.set("v.stateMandatory", true);
        }
        else{
           component.set("v.stateMandatory", false); 
        }
        if(caseCountry =='USA' || caseCountry=='Germany'){
            component.set("v.ZipValmandatory", true);
        }
        else{
           component.set("v.ZipValmandatory", false); 
        }
        if(caseCountry =='China' || caseCountry=='Taiwan'){
           component.set("v.IndMandatory", true); 
        }
        else{
           component.set("v.IndMandatory", false); 
        }
             
             if(caseCountry != null){                 
                 ControllerField.push({
                  class: "optionClass",
                  label: caseCountry,
                  value: caseCountry
               });
                      
        		component.set("v.countryVal",caseCountry);
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
               component.find('state-Inp').set("v.options", defaultVal);
            }
 
            for (var i = 0; i < listOfkeys.length; i++) {                
                
                if(listOfkeys[i].toUpperCase() != caseCountryUpper){
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
           if(caseCountry !=null){
                var Map = component.get("v.depnedentFieldMap");
             		var ListOfDependentFields = Map[caseCountry];
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
                }
                else{
                    component.set("v.preDistiMandatory", false);
                }
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchDistiAccSearch");          
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
})