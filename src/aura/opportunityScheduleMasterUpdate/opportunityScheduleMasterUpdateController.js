({				
    //Function to initailize the dispaly contents for the Opportunity Schedule 				
    doInit : function(component, event, helper) {				
        helper.getOpptyValues(component);
    },				
					
    //Redirect back to record detail page				
    backOppty : function(component, event, helper) {				
        var recordId = component.get("v.recordId");				
        //window.location.href = '/'+recordId;
        helper.backOppty(component);
    },				
    				
    // Function to load the Opportunity Schedule display window 				
    doInitact : function(component, event, helper) {
        var flgPM = component.get("v.flagPM");				
        var toggle = component.get("v.toggleCompDisplay");				
        if(flgPM != true && toggle != false){
            helper.getOpptyScheduleValues(component);				
        }				
    },	
    				
    //Function to navigate back to the Oppty Detail page				
    backOpptySch : function (component, event, helper) {				
        component.set("v.flagSaveSuccess", false);
        helper.backOppty(component);
        /*
        var flgException = component.get("v.isExceptionFlag");	        			
        var saveSchBtn = component.find("saveSch");				
        var recordId = component.get("v.recordId");				
        var flgbtnDisable = saveSchBtn.get("v.disabled");				
        
        if(flgbtnDisable == true || flgException == true){
            //window.location.href = '/'+recordId;
            helper.backOppty(component);	
        }				
        else{
            component.set("v.flagCancelAlert", true);  				
        } 
        */
    },				
    				
    //Close the cancel alert				
    cancelAlertClose:function(component, event, helper) {				
         component.set("v.flagCancelAlert", false);				
    },				
    				
    //Function to save and close the changes done for the Oppty Schedules.				
    saveClose: function(component, event, helper) {				
        var recordId = component.get("v.recordId");
        component.set("v.isExceptionFlag", false);
        component.set("v.hasErrors1", false);				
        component.set("v.isEmptyOpptySched", false);				
        component.set("v.isQuantityDecimalOrNegative", false); 
        
        var lstPositions = component.get("v.lstPositions");				
        if(helper.validateOpportunityScheduleSaveForm(component)) {
            helper.disableButton(component);
            component.set("v.isSpinner", true);
            //Calling the Apex Function				
            var action = component.get("c.saveOpptySchedule");				
            var opptyschldWrapRec = JSON.stringify(lstPositions);				
            action.setParams({				
                opportunityId: component.get("v.recordId"),				
                opptyschldWrapRec : opptyschldWrapRec,				
                oppPassed: component.get("v.opp1")				
            });				
            action.setCallback(this,function(a){				
                var state = a.getState();				
                var responses = a.getReturnValue();				
                if(state == "SUCCESS"){				
                    if(responses.isOpptySchedule){				
                        component.set("v.opp1", a.getReturnValue().oppValues);				
                        component.set("v.hasErrors1", false);				
                        component.set("v.isEmptyOpptySched", false);				
                        component.set("v.isQuantityDecimalOrNegative", false);				
                        component.set("v.isChanged",false);				
                        component.set("v.checkChange",false);
                        component.set("v.isSpinner", false);    
                        //window.location.href = '/'+recordId;
                        helper.backOppty(component);
                    } 				
                    
                    else{				
                        component.set("v.hasErrors1", true);				
                        component.set("v.isEmptyOpptySched", true);				
                        component.set("v.isExceptionFlag", false);						
                        helper.enableButton(component);
                    }				
                } 				
                else if(state == "ERROR"){				
                    console.log(a.getError());				
                    var errors = a.getError();                				
                    if(errors[0] && errors[0].pageErrors) // To show DML exceptions				
                    {				
                        component.set("v.ErrorMessage", errors[0].pageErrors[0].message); 				
                        component.set("v.isExceptionFlag", true);				
                        helper.enableButton(component);    						
                    }                   				
                }
                component.set("v.isSpinner", false);
            });				
            $A.enqueueAction(action);				
        }  				
        else {				
            component.set("v.hasErrors1", true);				
        } 				
    },				
    				
    //Function to save the changes done for the Oppty Schedules.				
    save: function(component, event, helper) {				                                        				
        var lstPositions = component.get("v.lstPositions");	
        component.set("v.isExceptionFlag", false);
        component.set("v.hasErrors1", false);				
        component.set("v.isEmptyOpptySched", false);				
        component.set("v.isQuantityDecimalOrNegative", false);
        
        if (helper.validateOpportunityScheduleSaveForm(component)) {				
            helper.disableButton(component);
            component.set("v.isSpinner", true);				
            var action = component.get("c.saveOpptySchedule");				
            var opptyschldWrapRec = JSON.stringify(lstPositions);				
            action.setParams({				
                opportunityId: component.get("v.recordId"),				
                opptyschldWrapRec : opptyschldWrapRec,				
                oppPassed: component.get("v.opp1"),				
            });				
            action.setCallback(this,function(a){				
                var state = a.getState();				
                var responses = a.getReturnValue();				
                var result = responses;				
                if(state == "SUCCESS"){				
                    if(result != null){				
                        if(responses.isOpptySchedule){
                            component.set("v.opp1", a.getReturnValue().oppValues);
                            component.set("v.OldCloseDate", a.getReturnValue().oppValues.CloseDate);
                            component.set("v.opp1.LT_Value_USD__c",a.getReturnValue().oppValues.LT_Value_USD__c);				
                            component.set("v.opp1.Claim_Value_USD__c",a.getReturnValue().oppValues.Claim_Value_USD__c);				
                            component.set("v.opp", a.getReturnValue().oppValues);				                    				
                            component.set("v.isChanged",false);				
                            component.set("v.checkChange",false);				
                            helper.disableButton(component);    
                            component.set("v.flagSaveSuccess", true);				
                            component.set("v.isExceptionFlag", false);    				
                        } 				
                        
                        else{	
                            component.set("v.hasErrors1", true);				
                            component.set("v.isEmptyOpptySched", true);				
                            component.set("v.isExceptionFlag", false);	
                            helper.enableButton(component);
                        }				
                    }				
                    else{
                        console.log(a.getError());				
                        var errors = a.getError();                				
                        if(errors[0] && errors[0].pageErrors) // To show DML exceptions				
                            component.set("v.ErrorMessage", errors[0].pageErrors[0].message);				
                        component.set("v.isExceptionFlag", true);				
                    }				
                    
                }  				
                
                else if(state == "ERROR"){
                    console.log(a.getError());
                    var errorMessage = "";
                    var errors = a.getError();
                    for (var i=0; i < errors.length; i++) {
                        var error = errors[i];
                        if (error.fieldErrors) {
                            for (var fieldName in error.fieldErrors) {
                                //each field could have multiple errors
                                error.fieldErrors[fieldName].forEach( function (errorList){ 
                                    errorMessage += ("Field Error on " + fieldName + ": \n" + errorList.message);
                                });                                
                            };  //end of field errors forLoop
                        } 
                        if(error.message) {
                            errorMessage += error.message;
                        } 
                        if(error.pageErrors) {
                            for (var j=0; j < error.pageErrors.length; j++) {
                                var pageError = error.pageErrors[j];
                                errorMessage += pageError.message;
                            }
                        }
                    }
                    component.set("v.ErrorMessage", errorMessage);
                    component.set("v.isExceptionFlag", true);
                    helper.enableButton(component);
                }				
                component.set("v.isSpinner", false);				
            });				
            
            //adds the server-side action to the queue        				
            $A.enqueueAction(action);				
        } 				
        else {		
            component.set("v.hasErrors1", true);				
        } 				
        
    },				
    				
    //add rows dynamically				
    addQuater : function(component, event, helper) {				
      helper.addQuarter(component);				
      component.set("v.checkChange", true);				
   },				
    				
    //delete rows dynamically				
    deleteOpptySched : function(component, event, helper) {				
        var index = component.get("v.OpptySchldCount");				
        index = index-1;				
        helper.delQuarter(component, index); 				
        component.set("v.checkChange", true);				
    },				

    // Close Date Change events
    changeCloseDate : function(component, event, helper) {
        if (helper.checkNonIosAndBlurEvent(event)) return;

        var expClsDate = component.find("expclosedate");
        var OldCloseDate =  component.get("v.OldCloseDate");
        var checkChange =  component.get("v.checkChange");        
        helper.disableButton(component);
        component.set("v.flagSaveSuccess", false);        
        var NewCloseDateValue= component.find("expclosedate").get("v.value");
        
        if(NewCloseDateValue != OldCloseDate || checkChange == true){
          helper.enableButton(component);  
          component.set("v.checkChange", true);
        }
        expClsDate.set("v.errors",null); 	//added SFDC 605			
    },		

    // Production Date Change events				
    changeProdDateAlert : function(component, event, helper) {
       if (helper.checkNonIosAndBlurEvent(event)) return;

       var checkChange =  component.get("v.checkChange");
       var prodDate = component.find("proddate"); 
       helper.disableButton(component); 
       component.set("v.flagSaveSuccess", false);				
       var NewProdDateValue= component.find("proddate").get("v.value");
       var NewProdDateValueStg = String(NewProdDateValue);
       var OldProdDateValue = component.get("v.OldProdDate");	
       var OldProdDateValueStg = String(OldProdDateValue);
       
       if(NewProdDateValue != OldProdDateValue && NewProdDateValue!= null && OldProdDateValue !=null){
       var lstPositions = component.get("v.lstPositions");				
       if(!$A.util.isEmpty(lstPositions) && !$A.util.isUndefined(lstPositions)){
       var action = component.get("c.checkIfSameQuarterProdDateChange");				
       action.setParams({				
                NewProdDate: NewProdDateValue,				
                OldProdDate: OldProdDateValue				
            }); 				
       action.setCallback(this,function(response){				
                var state = response.getState();				
                if(state == "SUCCESS"){				
                 var result = response.getReturnValue();				
                 component.set("v.flagAlert", true);								
                } 
                else if(state == "ERROR"){
                }				
            });				
            $A.enqueueAction(action);
          
       }	
      }   				
       else if(checkChange == true){
             helper.enableButton(component);
            }
        prodDate.set("v.errors",null); //added SFDC 605
    },			
	
     changeProdDateAlertClose : function(component, event, helper) {				
       component.set("v.flagAlert", false);				
       var OldProdDate = component.get("v.OldProdDate");				
       component.set("v.opp1.Production_Date__c", OldProdDate);	         			
       component.set("v.OldProdDate", "v.opp1.Production_Date__c");  //Added				
       var checkChangeBtn =  component.get("v.checkChange");				
       if(checkChangeBtn == true){	
          helper.enableButton(component);				
       }				
         				
    },				
    				
    changeProdDate : function(component, event, helper) {				
        helper.OnChangeProdDate(component);				
        component.set("v.flagAlert", false);				
    },				
    				
    // If the Production Date is not changed post the confirmation then retain the old production date.				
    handleValueChange : function (component, event, helper) {				
        component.set("v.OldProdDate", event.getParam("oldValue"));
    },
			
   				
    				
    				
    				
  //Function to set a button enable or disable if there is value change				
        alertIsChanged : function (component, event, helper) {				
           component.set("v.checkChange", true);				
           component.set("v.flagSaveSuccess", false);				
           helper.enableButton(component); 
        },				
    
   //Restict user entering date value and request to use Date picker  
   restrictManualEntryOfProdDate : function(component, event, helper)
   {    
    var isEditSched = component.get("v.toggleCompDisplay");
    var prodDate; var oldProdDate;       
     if(isEditSched){   
     prodDate = component.find("proddate");
     oldProdDate = component.get("v.opp1.Production_Date__c");
     }
       /*
     if(isCreateSched){   
     prodDate = component.find("proddate1");
     oldProdDate = component.get("v.opp.Production_Date__c");
     } 
     */
    prodDate.set('v.value',oldProdDate);
    prodDate.set("v.errors", [{message:"Please select the date via Calendar icon"}]);
   
    var checkChange =  component.get("v.checkChange");
    if(checkChange == true && isEditSched == true){
     helper.enableButton(component);   
    } 
   },

   restrictManualEntryOfCloseDate : function(component, event, helper)
   { 
     var isEditSched = component.get("v.toggleCompDisplay");
     var expClsDate;  var oldexpClsDate ;
     if(isEditSched){    
     expClsDate = component.find("expclosedate");
     oldexpClsDate = component.get("v.opp1.CloseDate");
     }
       /*
     if(isCreateSched){    
     expClsDate = component.find("expclosedate1");
     oldexpClsDate = component.get("v.opp.CloseDate");
     }   
     */
    expClsDate.set('v.value',oldexpClsDate);
    expClsDate.set("v.errors", [{message:"Please select the date via Calendar icon"}]);
       
    var checkChange =  component.get("v.checkChange");
    if(checkChange == true && isEditSched == true){				
     helper.enableButton(component);   
    }
   },
    
   prev: function(cmp, event, helper) {
       var urlEvent = $A.get("e.force:navigateToURL");
       var progId = cmp.get("v.opp1.Program__c");
       var progName = cmp.get("v.progName");
       
       urlEvent.setParams({
           "url": "/apex/opportunityScheduleMaster?progId=" + progId + "&progName=" + progName  
       });
       
       urlEvent.fire();
    },  
})