({	            
    leadActivityList: function(cmp) {
        //load Lead Activity data 
        var action = cmp.get("c.getLeadActivities");
        action.setParams({
        LeadId: cmp.get("v.recordId") 
   		});        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result=response.getReturnValue();
                cmp.set("v.Leads", result.leadCurrent);
                cmp.set("v.LeadActivities", result.listLdActivityCurrent);
                cmp.set("v.LeadAccount",result.leadAccountCurrent);
                cmp.set("v.LeadOppty",result.listOppty);
            }
        });        
        $A.enqueueAction(action);        
	},
    
    fetchPicklistValues: function(component, controllerField, dependentField) {
      // call the server side function  
      var action = component.get("c.getDependentOptionsImpl");
      // pass paramerters [object name , contrller field name ,dependent field name] -
      // to server side function 
 
      action.setParams({
         'objApiName': component.get("v.objInfo"),
         'contrfieldApiName': controllerField,
         'depfieldApiName': dependentField
      });
      //set callback   
      action.setCallback(this, function(response) {
         if (response.getState() == "SUCCESS") {
            //store the return response from server (map<string,List<string>>)  
            var StoreResponse = response.getReturnValue();
 
            // once set #StoreResponse to depnedentFieldMap attribute 
            component.set("v.depnedentFieldMap", StoreResponse);
 
            // create a empty array for store map keys(@@--->which is controller picklist values) 
 
            var listOfkeys = []; // for store all map keys (controller picklist values)
            var ControllerFields = []; // for store controller picklist value to set on ui field. 
 
            // play a for loop on Return map 
            // and fill the all map key on listOfkeys variable.
            for (var singlekey in StoreResponse) {             
               listOfkeys.push(singlekey);                
            }
             if (listOfkeys != undefined && listOfkeys.length > 0) {
         	ControllerFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
 
      }
      for (var i = 0; i < listOfkeys.length; i++) {
         ControllerFields.push({
            class: "optionClass",
            label: listOfkeys[i],
            value: listOfkeys[i]
         });
      }
 		                       
            // set the ControllerField variable values to country(controller picklist field)
            component.set("v.listOfIndSeg",ControllerFields);
             //component.find("master").set("v.options", listOfkeys);           
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
      for (var i = 0; i < ListOfDependentFields.length; i++) {
         dependentFields.push({
            class: "optionClass",
            label: ListOfDependentFields[i],
            value: ListOfDependentFields[i]
         });
      }
      // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
      component.find("slave").set("v.options", dependentFields);
      // make disable false for ui:inputselect field 
      component.set("v.isDependentDisable", false);
   },
            
    searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchOpportunity");
        var LdId= component.get("v.recordId");
        var ldoldAccId=component.get("v.Leads.Account_Id__c");        
		var ldNewAccId=component.get("v.selectedAccRecord.Id");  
      // set param to method
        if(ldNewAccId!=null){
            action.setParams({
            'searchKeyWord': getInputkeyWord,
            LeadId :LdId,
            leadAccId:ldNewAccId
          });
        } 
        else{
            action.setParams({
            'searchKeyWord': getInputkeyWord,
            LeadId :LdId,
            leadAccId:ldoldAccId
          });
        }
        
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
    
    searchAccHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.listOfSearchAccRecords");
        var LdId= component.get("v.recordId");
        var LdOwnerId= component.get("v.Leads.Owner.Id");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            LeadId :LdId,
            LeadOwnerId :LdOwnerId
          });
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                    component.set("v.listOfSearchAccRecords", null );
                }                	
	 			else {
	                    component.set("v.Message", 'Search Result...');
	                }                
                // set searchResult list with return value from server.
                component.set("v.listOfSearchAccRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);    
	},
})