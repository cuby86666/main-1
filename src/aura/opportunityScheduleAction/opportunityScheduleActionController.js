({				
    //Function to initailize the dispaly contents for the Opportunity Schedule 				
   doInit : function(component, event, helper) {				
    helper.getOpptyValues(component);
   },				
				
    // Create the Opportunity Schedule at initail phase and also post reestablish				
    createOpptyScheld : function(component, event, helper) {				
    
     if(helper.validateOpportunityScheduleForm(component)) {				
         				
         var qttr = component.find("noQtr").get("v.value");				
         var quantity = component.find("noQty").get("v.value");				
         var oppty = component.get("v.opp");				
         component.set("v.qtr", qttr); 				
         component.set("v.qty", quantity);   				
         component.set("v.opp1", oppty);   				
         component.set("v.flagDirect", true);				
         component.set("v.toggleCompDisplay", true);   				
         component.set("v.toggleCompDisplayCreate", false);				
         component.set("v.toggleCompPMDisplay", false);				
         component.set("v.hasErrors", false);				
     }				
     else {				
           component.set("v.hasErrors", true);				
          }				
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
    
    //Function to reestablish the Oppty Schedules.				
    reEstablish : function(component, event, helper) {				
     component.set("v.ErrorMessage", null);				
     component.set("v.flagSaveSuccess", false);				
     component.set("v.flagReEstablishAlert", false);				
     component.set("v.isSpinner", true);   				
     var action = component.get("c.reEstablishOpptySchedules");        				
     action.setParams({				
                opportunityId: component.get("v.recordId")				
            });				
     action.setCallback(this,function(a){				
       var state = a.getState();				
       if(state == "SUCCESS"){          				
          var opport = component.get("v.opp1");				
          component.set("v.toggleCompDisplay", false);				
          component.set("v.toggleCompDisplayCreate", true);				
          var opptyStage= component.get("v.opp");				
       if(opptyStage.StageName == 'Commitment'){				
          var expClsDt = component.find("expclosedate1");				
          expClsDt.set("v.disabled",true);				
          var prodDt = component.find("proddate1");				
          prodDt.set("v.disabled",true);				
        }  				
        component.set("v.isSpinner", false);				
      } 				
       else if(state == "ERROR"){				
               console.log(a.getError());				
               var errors = a.getError();                				
               if(errors[0] && errors[0].pageErrors) // To show DML exceptions				
               {				
                component.set("v.ErrorMessage", errors[0].pageErrors[0].message); 				
                component.set("v.isExceptionFlag", true);				
               }				
                component.set("v.isSpinner", false);				
             }				
       });				
       $A.enqueueAction(action);				
   },				
    				
    //Function to navigate back to the Oppty Detail page				
    backOpptySch : function (component, event, helper) {				
       component.set("v.flagSaveSuccess", false);				
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
    },				
    				
    //Close the cancel alert				
    cancelAlertClose:function(component, event, helper) {				
         component.set("v.flagCancelAlert", false);				
    },				
    				
    //Function to save and close the changes done for the Oppty Schedules.				
    saveClose : function(component, event, helper) {				
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
save : function(component, event, helper) {				                                        				
    var lstPositions = component.get("v.lstPositions");	
    component.set("v.isExceptionFlag", false);
    component.set("v.hasErrors1", false);				
    component.set("v.isEmptyOpptySched", false);				
    component.set("v.isQuantityDecimalOrNegative", false);
    
    if(helper.validateOpportunityScheduleSaveForm(component)) {				
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
                    var errors = a.getError();                				
                    if(errors[0] && errors[0].pageErrors) // To show DML exceptions				
                    {				
                    component.set("v.ErrorMessage", errors[0].pageErrors[0].message); 				
                    component.set("v.isExceptionFlag", true);				                         				
                    }				                 				
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
        var oppty = component.get("v.opp");
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
			
   // Re Establish events				
    reEstablishAlert : function(component, event, helper) {				
       component.set("v.flagReEstablishAlert", true);				
    },				
     reEstablishCancel : function(component, event, helper) {				
       component.set("v.flagReEstablishAlert", false);				
    },				
    				
    //Redirect to PM from Oppty Sched display				
    setRedirectToPM : function(component, event, helper) {				
        				
            component.set("v.hasErrors1", false);				
            component.set("v.isEmptyOpptySched", false);				
            component.set("v.isQuantityDecimalOrNegative", false);				
        				
            component.set("v.isExceptionFlag", false);				
            component.set("v.flagSaveSuccess", false);				
            helper.getOpptyLineItemValues(component);				
            component.set("v.toggleCompPMDisplay", true);				
            component.set("v.toggleCompDisplay", false);   				
            component.set("v.toggleCompDisplayCreate", false);        				
            var opptyStage= component.get("v.opp1");				
     },				
    				
  //Function to set a button enable or disable if there is value change				
        alertIsChanged : function (component, event, helper) {				
           component.set("v.checkChange", true);				
           component.set("v.flagSaveSuccess", false);				
           helper.enableButton(component); 
        },				
    				
    				
// PM dispaly if the Product changed from the drop down   				
    onChange: function(component, event, helper) {				
       component.set("v.flagSaveSuccessPM", false);				
       var dynamicCmp = component.find("InputSelectDynamic");				
       var OpptyLineItemName =  dynamicCmp.get("v.value");				
       var action = component.get("c.getOpptyProdSchedDisplayClass");				
       action.setParams({				
              opportunityId: component.get("v.recordId"),				
              OpptyLineItemName:  dynamicCmp.get("v.value")				
            });				
				
       action.setCallback(this,function(response){				
              var responses = response.getReturnValue();				
              if (response.getState() === "SUCCESS") {
                 component.set("v.OpptyInitProdDisp.lstopptyProdSchedDispTable", response.getReturnValue());				
                } 				
              else if (response.getState() === "ERROR") {				
                $A.log("Errors", response.getError());				
              }    				
       });				
    $A.enqueueAction(action);	        			
  },				
    				
  //Redirect back to Oppty Schedule window if Oppty stage = Commitment and there are no cahnges made				
    backOpptySched: function(component, event, helper) {				
        				
       var savePMBtn = component.find("savePM");				
       var flgException = component.get("v.isExceptionFlag");	        			
       var flgSavebtnDisable = savePMBtn.get("v.disabled");				
       if(flgSavebtnDisable == true || flgException == true){				
        component.set("v.isExceptionFlag", false);				
        component.set("v.flagSaveSuccessPM", false);				
        component.set("v.toggleCompPMDisplay", false);				
        component.set("v.toggleCompDisplay", true);   				
        component.set("v.toggleCompDisplayCreate", false); 				
       }				
        else{				
              component.set("v.flagBackSaveAlertPM", true);  				
        }				
    },				
    				
    //Redirect back to Oppty Schedule window if Oppty stage != Commitment				
        backOpptySchedDirect: function(component, event, helper) {				
        component.set("v.flagPM", false);  				
        component.set("v.flagDirect", false);				
        component.set("v.toggleCompPMDisplay", false);				
        component.set("v.toggleCompDisplay", true);   				
        component.set("v.toggleCompDisplayCreate", false);				
        component.set("v.isExceptionFlag", false);				
        },				
    				
    //Redirect back to Oppty Schedule window if Oppty in Commitment Alert				
    backOpptySchedAlert : function(component, event, helper) {				
        component.set("v.toggleCompPMDisplay", false);				
        component.set("v.toggleCompDisplay", true);   				
        component.set("v.toggleCompDisplayCreate", false);				
        component.set("v.flagBackSaveAlertPM", false);				
        component.set("v.hasErrors2", false);				
        component.set("v.flagSaveSuccessPM", false);				
        component.set("v.isExceptionFlag", false);				
    },				
    				
    //Close the cancel alert				
    backAlertClose:function(component, event, helper) {				
         component.set("v.flagBackSaveAlertPM", false);				
    },				
    				
    //Save the PM changes and redirect to Oppty detail				
    saveClosePM:function(component, event, helper) {				
         component.set("v.isSpinner", true);				
         var recordId = component.get("v.recordId");
         component.set("v.hasErrors2", false);
         component.set("v.isExceptionFlag", false);
         var dynamicCmp = component.find("InputSelectDynamic");				
         var OpptyLineItemName =  dynamicCmp.get("v.value");         				
         var lstOpptyProdSched = component.get("v.OpptyInitProdDisp.lstopptyProdSchedDispTable");				
         helper.disableProdMgmtButton(component);
         var i;					
         for(i=0; i<lstOpptyProdSched.length; i++){					
           var OpptyProdSchedShare=lstOpptyProdSched[i].prodShare;	
           var roundOffShare = (OpptyProdSchedShare - (OpptyProdSchedShare % 1))
           if(OpptyProdSchedShare % 1 != 0){
               lstOpptyProdSched[i].prodShare = roundOffShare;
           }					
         }	
        				
         if(!$A.util.isEmpty(lstOpptyProdSched) && !$A.util.isUndefined(lstOpptyProdSched)){				
            var action = component.get("c.updateDWOpptyProdSchedule");				
            var opptyProdSchldWrapRec = JSON.stringify(lstOpptyProdSched);				
            action.setParams({				
                opportunityId: component.get("v.recordId"),				
                opptyProdSchldWrapRec : opptyProdSchldWrapRec,				
                OpptyLineItemName : dynamicCmp.get("v.value")				
            });				
             				
            action.setCallback(this,function(a){				
                var state = a.getState();
                var responses = a.getReturnValue();
                if(state == "SUCCESS"){				
                    if(responses.isOpptyProdSchedSave != true){				
                     component.set("v.hasErrors2", true);				
                     component.set("v.flagSave", false);				
                     helper.enableProdMgmtButton(component);
                     component.set("v.isSpinner", false);
                    }
                    
                    else{				
                        component.set("v.flagSave", true); 				
                        component.set("v.hasErrors2", false);				
                        helper.disableProdMgmtButton(component);
                        component.set("v.isSpinner", false);
                          //window.location.href = '/'+recordId;
                          helper.backOppty(component);
                       } 				
                }                 				
                else if(state == "ERROR"){				
                    helper.enableProdMgmtButton(component);
                    console.log(a.getError());				
                    var errors = a.getError();                				
                    if(errors[0] && errors[0].pageErrors) // To show DML exceptions				
                    {				
                    component.set("v.ErrorMessage", errors[0].pageErrors[0].message); 				
                    component.set("v.isExceptionFlag", true);				                         				
                    }					
                }	
                component.set("v.isSpinner", false);
            });				
            //adds the server-side action to the queue        				
            $A.enqueueAction(action);	            			
        }	    			
    },				
    				
    //Save the PM contents that has been changed				
    savePM:function(component, event, helper) {				
         component.set("v.isSpinner", true);
         component.set("v.hasErrors2", false);
         component.set("v.isExceptionFlag", false);
         var dynamicCmp = component.find("InputSelectDynamic");				
         var OpptyLineItemName =  dynamicCmp.get("v.value");         				
         var lstOpptyProdSched = component.get("v.OpptyInitProdDisp.lstopptyProdSchedDispTable");				
         helper.disableProdMgmtButton(component);			
         var i;					
         for(i=0; i<lstOpptyProdSched.length; i++){					
           var OpptyProdSchedShare=lstOpptyProdSched[i].prodShare;	
           var roundOffShare = (OpptyProdSchedShare - (OpptyProdSchedShare % 1))
           if(OpptyProdSchedShare % 1 != 0){
               lstOpptyProdSched[i].prodShare = roundOffShare;
           }					
         }					
         if(!$A.util.isEmpty(lstOpptyProdSched) && !$A.util.isUndefined(lstOpptyProdSched)){ 				
            var action = component.get("c.updateDWOpptyProdSchedule");				
            var opptyProdSchldWrapRec = JSON.stringify(lstOpptyProdSched);				
            action.setParams({				
                opportunityId: component.get("v.recordId"),				
                opptyProdSchldWrapRec : opptyProdSchldWrapRec,				
                OpptyLineItemName : dynamicCmp.get("v.value")				
            });				
				
            action.setCallback(this,function(a){				
                var state = a.getState();
                var responses = a.getReturnValue();
                if(state == "SUCCESS"){				
                    if(responses.isOpptyProdSchedSave != true){				
                     component.set("v.hasErrors2", true);				
                     component.set("v.flagSave", false);				
                     helper.enableProdMgmtButton(component);				
                    }
                    
                    else{				
                        helper.getForeCastValue(component);				
                        component.set("v.flagSave", true); 				
                        component.set("v.hasErrors2", false);				
                        helper.disableProdMgmtButton(component);				
                        component.set("v.flagSaveSuccessPM", true);				
                       }				
                }                 				
                else if(state == "ERROR"){
                    console.log(a.getError());				
                    var errors = a.getError();                				
                    if(errors[0] && errors[0].pageErrors) // To show DML exceptions				
                    {				
                    component.set("v.ErrorMessage", errors[0].pageErrors[0].message); 				
                    component.set("v.isExceptionFlag", true);				                         				
                    }							
                    helper.enableProdMgmtButton(component);			                     				
                }				
               component.set("v.isSpinner", false);  				
            });	            			
            //adds the server-side action to the queue        				
            $A.enqueueAction(action);	            			
        }	    			
    },				
           				
    // Alert if Production Management content is changed				
    alertIsChangedPM : function (component, event, helper) {				
       helper.enableProdMgmtButton(component);   				
       component.set("v.flagSaveSuccessPM", false);				
     },
    
   //Restict user entering date value and request to use Date picker  
   restrictManualEntryOfProdDate : function(component, event, helper)
   {    
    var isCreateSched = component.get("v.toggleCompDisplayCreate");
    var isEditSched = component.get("v.toggleCompDisplay");
    var prodDate; var oldProdDate;       
     if(isEditSched){   
     prodDate = component.find("proddate");
     oldProdDate = component.get("v.opp1.Production_Date__c");
     }
     if(isCreateSched){   
     prodDate = component.find("proddate1");
     oldProdDate = component.get("v.opp.Production_Date__c");
     } 
    prodDate.set('v.value',oldProdDate);
    prodDate.set("v.errors", [{message:"Please select the date via Calendar icon"}]);
   
    var checkChange =  component.get("v.checkChange");
    if(checkChange == true && isEditSched == true){
     helper.enableButton(component);   
    } 
   },

   restrictManualEntryOfCloseDate : function(component, event, helper)
   { 
     var isCreateSched = component.get("v.toggleCompDisplayCreate");
     var isEditSched = component.get("v.toggleCompDisplay");
     var expClsDate;  var oldexpClsDate ;
     if(isEditSched){    
     expClsDate = component.find("expclosedate");
     oldexpClsDate = component.get("v.opp1.CloseDate");
     }
     if(isCreateSched){    
     expClsDate = component.find("expclosedate1");
     oldexpClsDate = component.get("v.opp.CloseDate");
     }   
    expClsDate.set('v.value',oldexpClsDate);
    expClsDate.set("v.errors", [{message:"Please select the date via Calendar icon"}]);
       
    var checkChange =  component.get("v.checkChange");
    if(checkChange == true && isEditSched == true){				
     helper.enableButton(component);   
    }
   },
    
     changeCreateCloseDate : function(component, event, helper)
     {
        var expClsDate = component.find("expclosedate1"); 
        expClsDate.set("v.errors",null);	 
     },
     changeCreateProdDate : function(component, event, helper)
     {
       var prodDate = component.find("proddate1");
       prodDate.set("v.errors",null);  
     },
})