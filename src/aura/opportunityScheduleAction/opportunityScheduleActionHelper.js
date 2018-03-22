({
    backOppty : function(component) {        
        var urlEvent = $A.get("e.force:navigateToURL");
        var recordId = component.get("v.recordId");
        urlEvent.setParams({
          "url" : "/" + recordId
        });
        urlEvent.fire();
    },

    checkNonIosAndBlurEvent : function(event) {
    //filter out blur event on non-iOS environment (for ui:inputDate component)
    //https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/aura_compref_ui_inputDate.htm
        var isIOS = !!navigator.userAgent.match(/iPhone|iPod|iPad/);
        var eventType = event.getType();
        if (!isIOS && eventType == "ui:blur") 
          return(true); //non-iOS and blur event: skip blur event
        else
          return(false);//iOS and blur event: process blur event
    },

    getOpptyValues: function(component) {					
    var action = component.get("c.getOpptyScheduleInfoClass");  //Onload dispatching					
    action.setParams({					
        opportunityId: component.get("v.recordId") 					
        });					
    					
    action.setCallback(this, function(response) {					
    if (response.getState() === "SUCCESS") {					
     var result = response.getReturnValue();
     //alert('User Experience'+result.userTheme);
     component.set("v.UserTheme", result.userTheme);   
     var opptyStage= component.get("v.opp");
     component.set("v.OldCloseDate", result.oppValues.CloseDate);   
     component.set("v.opp", result.oppValues);  //step1 Oppty Val Init					
     component.set("v.opp1", result.oppValues);  //Step2 Oppty Val Init					
     var opptFrStage = result.oppValues;					
     if(result.isOpptySchedule == true){					
       component.set("v.flagDirect", false);  					       					
      }					
    else{					
          component.set("v.flagDirect", true);					
          component.set("v.toggleCompDisplayCreate", true); 					
          if(opptFrStage.StageName == 'Commitment' || opptFrStage.Design_Win_Approval_Process__c =='Lost')					
          {					
           var expClsDt = component.find("expclosedate1");					
           expClsDt.set("v.disabled",true);					
           var prodDt = component.find("proddate1");					
           prodDt.set("v.disabled",true);   					
          }    					
    }					
    component.set("v.toggleCompPMDisplay", false);   					
    component.set("v.toggleCompDisplay", result.isOpptySchedule);					
    					
   } 					
    else if (response.getState() === "ERROR") {					
            $A.log("Errors", response.getError());					
        }					
});					
$A.enqueueAction(action);					
},					
    					
validateOpportunityScheduleForm: function(component){					
    var validForm = true;        					
 // Quarter and Quantity are mandatory fields					
    var quarterField = component.find("noQtr");					
    var qtrValue = quarterField.get("v.value");					
    if($A.util.isEmpty(quarterField.get("v.value")) || qtrValue === 0 || qtrValue<0 || (qtrValue % 1 != 0)) {					
       validForm = false;					
       quarterField.set("v.errors", [{message:"Quarter Value can't be negative,decimal, blank or zero"}]);					
     }     					
    else {					
          quarterField.set("v.errors", null);					
         }					
        					
        var quantityField = component.find("noQty");					
        var qtyValue = quantityField.get("v.value");					
        if($A.util.isEmpty(quantityField.get("v.value")) || qtyValue === 0 || qtyValue<0 || (qtyValue % 1 != 0)) {					
            validForm = false;					
            quantityField.set("v.errors", [{message:"Quantity Value can't be negative, decimal, blank or zero"}]);					
        }					
       					
        else {					
            quantityField.set("v.errors", null);					
        }					
        					
        var opptyStage= component.get("v.opp");					
        if(opptyStage.StageName != 'Commitment'){					
        var expCloseDate = component.find("expclosedate1");					
        var expCloseDateValue = expCloseDate.get("v.value");					
        var todayDate = new Date();					
        var todayDateOnly = new Date(todayDate.getUTCFullYear(),todayDate.getUTCMonth(),todayDate.getUTCDate()); //This will write a Date with time set to 00:00:00 so you kind of have date only        					
        var expdate = new Date(expCloseDateValue);					
        var expClsDateOnly = new Date(expdate.getUTCFullYear(),expdate.getUTCMonth(),expdate.getUTCDate());					
        if (expClsDateOnly <todayDateOnly || $A.util.isEmpty(expCloseDate.get("v.value"))) {					
             validForm = false;					
            expCloseDate.set("v.errors", [{message:"Close date can not be prior to today: " + todayDate}]);					
        } 					
        else {					
            expCloseDate.set("v.errors", null);					
        }					
					
        var prodDate = component.find("proddate1");					
        var prodDateValue = prodDate.get("v.value");        					
        var proDate = new Date(prodDateValue);					
        var prodDateOnly = new Date(proDate.getUTCFullYear(),proDate.getUTCMonth(),proDate.getUTCDate());					
        if (prodDateOnly <expClsDateOnly || $A.util.isEmpty(prodDate.get("v.value"))) {					
             validForm = false;					
            prodDate.set("v.errors", [{message:"Production Date should be greater than or equal to Expected Close Date: " + expCloseDateValue}]);					
        }					
           					
        else {					
            prodDate.set("v.errors", null);					
        }              					
        }					
        return(validForm);    					
},					
    					
    ///////////////////////////////////////Component 2//////////////////////////////////////////					
getOpptyScheduleValues: function(component) {					
    component.set("v.ErrorMessage", null);					
    component.set("v.isSpinner", true);					
    this.disableButton(component);
   					
    var opptyStage= component.get("v.opp1");					
    if(opptyStage.Account !=null){					
    if(opptyStage.StageName == 'Commitment' || opptyStage.Design_Win_Approval_Process__c =='Lost'||(opptyStage.Design_Win_Approval_Process__c =='Pending' && opptyStage.StageName == 'Decision')||(opptyStage.RecordType.DeveloperName =='Model_N_Oppty' && (opptyStage.Account.Customer_Category__c !='Tier 4 - TMMA'|| opptyStage.StageName == 'Cancelled'))){					
    var reEstblishBtn = component.find("reEstablish");					
    reEstblishBtn.set("v.disabled",true);					
    }					
    if(opptyStage.Design_Win_Approval_Process__c =='Lost'||(opptyStage.Design_Win_Approval_Process__c =='Pending' && opptyStage.StageName == 'Decision')||(opptyStage.RecordType.DeveloperName =='Model_N_Oppty' && (opptyStage.Account.Customer_Category__c !='Tier 4 - TMMA' || opptyStage.StageName == 'Cancelled'))){					
    var addQtrBtn = component.find("addQtr");					
    addQtrBtn.set("v.disabled",true);					
    component.set("v.flagNonTmmaDisabling", true);     					
    }					
    if(opptyStage.Design_Win_Approval_Process__c !='Pending'&& opptyStage.Design_Win_Approval_Process__c !='Lost'&&((opptyStage.RecordType.DeveloperName =='Model_N_Oppty' && opptyStage.Account.Customer_Category__c =='Tier 4 - TMMA'&& opptyStage.StageName != 'Cancelled')||opptyStage.RecordType.DeveloperName !='Model_N_Oppty')){					
    component.set("v.flagNonTmmaDisabling", false);					
        if(opptyStage.StageName != 'Commitment'){					
        component.set("v.flagNonTmmaDelDisabling", true);    					
        }					
    }					
    var flg = component.get("v.flagDirect");					
    if(flg == true){					
    var productionDate = component.find("proddate1").get("v.value");					
    var expCloseDate = component.find("expclosedate1").get("v.value");					
    }					
    else{					
    var productionDate = component.find("proddate").get("v.value");					
    var expCloseDate = component.find("expclosedate").get("v.value");					
    component.set("v.flagSaveSuccess", false);					
					
    }					
    					
    var toggle = component.get("v.toggleCompDisplay");					
    if(toggle == true){					
       var lstPositions = null; 					
    }					
    else{					
    var lstPositions = component.get("v.lstPositions");					
    }					
    var opptyschldWrapRec = JSON.stringify(lstPositions);					
    var action = component.get("c.getOpportunityScheduleDisplayValues");					
    action.setParams({					
    opportunityId: component.get("v.recordId"),					
    qtr:  component.get("v.qtr"),					
    qty:  component.get("v.qty"),					
    ProdDate: productionDate,					
    ExpClsDate: expCloseDate,					
    opptyschldWrapRec : opptyschldWrapRec,					
    flagDirect: component.get("v.flagDirect")					
        });					
    					
    action.setCallback(this, function(response) {					
     if (response.getState() === "SUCCESS") {					
           var result = response.getReturnValue();					
    if(result != null){					
            component.set("v.lstPositions", response.getReturnValue());					
            component.set("v.opp1",result[0].oppValues);	
            component.set("v.OldCloseDate", result[0].oppValues.CloseDate);
            component.set("v.opp1.LT_Value_USD__c",result[0].oppValues.LT_Value_USD__c);					
            component.set("v.opp1.Claim_Value_USD__c",result[0].oppValues.Claim_Value_USD__c);					
            component.set("v.OldProdDate",result[0].oppValues.Production_Date__c); // added   					
    }       					
               component.set("v.flagSaveSuccess", false);					
               if(flg == true){					
               component.set("v.flagSaveSuccess", true);					
               }					
               var count = response.getReturnValue().length;					
               component.set("v.OpptySchldCount",count);					
               component.set("v.OpptySchldCountInit",count);					
               if(result[0].oppValues.StageName == 'Commitment'||(result[0].oppValues.StageName == 'Decision' && result[0].oppValues.Design_Win_Approval_Process__c =='Pending') || result[0].oppValues.Design_Win_Approval_Process__c =='Lost' || (opptyStage.RecordType.DeveloperName =='Model_N_Oppty' && (opptyStage.Account.Customer_Category__c !='Tier 4 - TMMA' || opptyStage.StageName == 'Cancelled')))					
               {					
                var expClsDt = component.find("expclosedate");					
                expClsDt.set("v.disabled",true);					
                expClsDt.set("v.displayDatePicker",false); //added to fix issue #297					
                var prodDt = component.find("proddate");					
                prodDt.set("v.disabled",true); 					
                prodDt.set("v.displayDatePicker",false);// added to fix issue #297					
                component.set("v.flagDelCmitmntButton",false);					
             }					
                   component.set("v.isSpinner", false);					
        } else if (response.getState() === "ERROR") {					
                    console.log(response.getError());					
                    var errors = response.getError();					
                    if(errors[0] && errors[0].pageErrors) // To show DML exceptions					
                    {					
                    component.set("v.toggleCompDisplayCreate", true);					
                    component.set("v.toggleCompDisplay", false);					
                    component.set("v.ErrorMessage", errors[0].pageErrors[0].message); 					
                    component.set("v.isExceptionFlag", true);					
                    }					
                    component.set("v.isSpinner", false);					            					
          }					
      });					
      $A.enqueueAction(action);					
  }					
    else{					
        component.set("v.isExceptionFlag", true);					
        component.set("v.ErrorMessage", 'Please add Account to the Opportunity');					
        component.set("v.isSpinner", false);					
    }					
					
},					
    					
// add rows to the Oppty schedule list     					
addQuarter:function(component){					
    component.set("v.flagSaveSuccess", false);
    var oppValues = component.get("v.opp1");
    var action = component.get("c.getQuarterAddedToOpptySched");        					
    var countOpptySchldb4=component.get('v.OpptySchldCount');        					
    var lstOpptySched=component.get('v.lstPositions');					
    var opptyschldWrapRec = JSON.stringify(lstOpptySched);					
    action.setParams({					
        opptyschldWrapRec : opptyschldWrapRec,					
        ProdDate: component.find("proddate").get("v.value")					
    });					
					
    action.setCallback(this,function(response){					
       var responses = response.getReturnValue();					
        var lstOpptySched=new Array();					
        if(component.isValid()){					
            var lstOpptySched=new Array(); 					
            for (var idx=0; idx<responses.length; idx++) {					
                var OpptySched = { 'quarterdate' : responses[idx].quarterdate,					
                               'quantities' : responses[idx].quantities,					
                               'comment' : responses[idx].comment,
                               'oppValues' : oppValues   
                              }; 					
                lstOpptySched.push(OpptySched);					
					
            }					
            var countOpptySchld = lstOpptySched.length;            					
            component.set("v.lstPositions",lstOpptySched );					
            component.set("v.OpptySchldCount",countOpptySchld);					
            this.enableButton(component);
            component.set("v.flagDelCmitmntButton",true);					
        }					
    });					
    $A.enqueueAction(action);					
},   					
    //Delete rows from the Opportunity Schedule display list					
        delQuarter : function(component, index) {					
        component.set("v.flagSaveSuccess", false);					
        var opttySchld = component.get("v.lstPositions");					
        var opptySchldCount = component.get("v.OpptySchldCount");          					
        opttySchld.splice(index, 1);            					
        var newOpptySchedCount = opptySchldCount-1;					
        component.set("v.lstPositions", opttySchld);					
        component.set("v.OpptySchldCount", newOpptySchedCount);					
        this.enableButton(component);            					
        var opptySchldCountInit = component.get("v.OpptySchldCountInit");					
            if((opptySchldCount-1) == opptySchldCountInit){					
              component.set("v.flagDelCmitmntButton",false);					
            }                                           					
        },					
    					
// Validate Save  Oppty Schedule 					
 validateOpportunityScheduleSaveForm: function(component){					
        var validForm = true;					
     	var lstDisplayOpptySched = component.get("v.lstPositions");				
        var opptyStage= component.get("v.opp1");					
        if(opptyStage.StageName != 'Commitment'){     					
        var expCloseDate = component.find("expclosedate");					
        var expCloseDateValue = expCloseDate.get("v.value");					
        var todayDate = new Date();					
        var todayDateOnly = new Date(todayDate.getUTCFullYear(),todayDate.getUTCMonth(),todayDate.getUTCDate()); //This will write a Date with time set to 00:00:00 so you kind of have date only					
        var expdate = new Date(expCloseDateValue);					
        var expClsDateOnly = new Date(expdate.getUTCFullYear(),expdate.getUTCMonth(),expdate.getUTCDate());					
					
        if (expClsDateOnly <todayDateOnly || $A.util.isEmpty(expCloseDate.get("v.value"))) {					
             validForm = false;					
            expCloseDate.set("v.errors", [{message:"Close date can not be prior to today: " + todayDate}]);					
        } 					
        else {					
            expCloseDate.set("v.errors", null);					
        }					
					
        var prodDate = component.find("proddate");					
        var prodDateValue = prodDate.get("v.value");					
        var proDate = new Date(prodDateValue);					
        var prodDateOnly = new Date(proDate.getUTCFullYear(),proDate.getUTCMonth(),proDate.getUTCDate());					
       	var prodYear = proDate.getUTCFullYear();
        var firstSchedQuarter;
        firstSchedQuarter = "Q"+(parseInt(((proDate.getUTCMonth()) / 3))+1);
        var prodDateqtr = prodYear+firstSchedQuarter;	
            
        if (prodDateOnly <expClsDateOnly || $A.util.isEmpty(prodDate.get("v.value"))) {					
             validForm = false;					
            prodDate.set("v.errors", [{message:"Production Date should be greater than or equal to Expected Close Date: " + expCloseDateValue}]);					
        }
        else if(prodDateqtr != lstDisplayOpptySched[0].quarterdate){
        validForm = false;					
        prodDate.set("v.errors", [{message:"Production Date is not aligned with the Opportunity Schedules"}]);
        }     
        else {					
            prodDate.set("v.errors", null);					
        } 					
        }					
      
       
       var i;					
       for(i=0; i<lstDisplayOpptySched.length; i++){					
           var opptySchedRecQuantity=lstDisplayOpptySched[i].quantities;					
           if(opptySchedRecQuantity<0 || (opptySchedRecQuantity % 1 != 0)|| opptySchedRecQuantity ==null){					
             component.set("v.isQuantityDecimalOrNegative", true);
             component.set("v.isExceptionFlag", false);  
             validForm = false;					
           }					
       }					
     					
       if($A.util.isEmpty(lstDisplayOpptySched) || $A.util.isUndefined(lstDisplayOpptySched)){					
            component.set("v.isEmptyOpptySched", true);
            component.set("v.isExceptionFlag", false);
            validForm = false;					
       }					
     					
      var opptyschldWrapRec = JSON.stringify(lstDisplayOpptySched);					
      var action = component.get("c.sumOpptySchedQtyCheck");					
      action.setParams({					
        opptyschldWrapRec : opptyschldWrapRec					
    });					
       action.setCallback(this,function(response){					
       var responses = response.getReturnValue();			 		
        if(component.isValid()){					
            if(responses == true){					
               validForm = false;               					
               component.set("v.isEmptyOpptySched", true);
               component.set("v.isExceptionFlag", false);
               component.set("v.hasErrors1", true);
               component.set("v.isError", true);
            }					
          }					
    }); 					
     					
    $A.enqueueAction(action);    					
    return(validForm);				
 },					
    					
    					
    //On Change of the production date					
   OnChangeProdDate: function(component) {					
    component.set("v.isSpinner", true); 					
    var lstPositions = component.get("v.lstPositions");					
    var opptyschldWrapRec = JSON.stringify(lstPositions);					    					
    var OldProdDate = component.get("v.opp1.Production_Date__c"); // added					    					
    var action = component.get("c.getOpportunityScheduleDisplayValues");					
    action.setParams({					
    opportunityId: component.get("v.recordId"),					
    ProdDate: component.find("proddate").get("v.value"),					
    opptyschldWrapRec : opptyschldWrapRec,					
        });					
    action.setCallback(this, function(response) {					
    if (response.getState() === "SUCCESS") {					
     var result = response.getReturnValue();					
     component.set("v.opp1.LT_Value_USD__c",result[0].oppValues.LT_Value_USD__c);					
     component.set("v.opp1.Claim_Value_USD__c",result[0].oppValues.Claim_Value_USD__c);					
     component.set("v.lstPositions", response.getReturnValue());					
     var count = response.getReturnValue().length;					
     component.set("v.OpptySchldCount",count);       					
     component.set("v.OldProdDate", OldProdDate); 					
     this.enableButton(component);
     component.set("v.checkChange", true);					
     component.set("v.isSpinner", false); 					
     } 					
     else if (response.getState() === "ERROR") {					
      $A.log("Errors", response.getError());					
      component.set("v.isSpinner", false); 					
     }					
});					
       					
$A.enqueueAction(action);					
},					
					
  // Opportunity Product Schedule initial loading method    					
  getOpptyLineItemValues: function(component) {					
  component.set("v.isSpinner", true);    					
  var action = component.get("c.getOpptyLineItemValuesClass");					
  action.setParams({					
    opportunityId: component.get("v.recordId") 					
        });					
    action.setCallback(this, function(response) {					
					
    if (response.getState() === "SUCCESS") { 					
         var opptyPMValue = response.getReturnValue();					
         var opptyValue = opptyPMValue.oppValues;        					
         component.set("v.OpptyInitProdDisp", response.getReturnValue());					
         var count = response.getReturnValue().length;					
         component.set("v.OpptyProdSchldCount",count);  					
         component.set("v.flagSaveSuccessPM", false);
         //SFDC Oppty
         if (opptyValue.RecordType.DeveloperName == 'SFDC_Oppty') {
           if (opptyValue.Design_Win_Approval_Process__c == 'Approved') {
             component.set("v.flagNonTmmaPMDisabling", false);
           } else {
             component.set("v.flagNonTmmaPMDisabling", true);
           }
         } else if (opptyValue.RecordType.DeveloperName == 'Model_N_Oppty') {
           if (opptyValue.Account.Customer_Category__c == 'Tier 4 - TMMA' && opptyValue.StageName == 'Commitment') {
             component.set("v.flagNonTmmaPMDisabling", false);
           } else {
             component.set("v.flagNonTmmaPMDisabling", true);
           }
         }
         //Model N Oppty
         //if(opptyValue.StageName != 'Commitment' || opptyValue.Design_Win_Approval_Process__c !='Approved'|| (opptyValue.RecordType.DeveloperName =='Model_N_Oppty' && (opptyValue.Account.Customer_Category__c !='Tier 4 - TMMA' || opptyValue.StageName == 'Cancelled'))){          
         //  component.set("v.flagNonTmmaPMDisabling",true);          
         //}          
            component.set("v.isSpinner", false);					
        }					
    });					
  $A.enqueueAction(action);					
 },					
    					
    //Updated ForeCast 					
    getForeCastValue:function(component) {					
        var dynamicCmp = component.find("InputSelectDynamic");					
        var lstOpptyProdSched = component.get("v.OpptyInitProdDisp.lstopptyProdSchedDispTable");					
        if(!$A.util.isEmpty(lstOpptyProdSched) && !$A.util.isUndefined(lstOpptyProdSched)){ 					
         var action = component.get("c.getUpdatedForeCastValue");					
         var opptyProdSchldWrapRec = JSON.stringify(lstOpptyProdSched);					
         action.setParams({					
          opportunityId: component.get("v.recordId"),					
          OpptyLineItemName:  dynamicCmp.get("v.value")					
         });					
                					
         action.setCallback(this, function(response) {					
          if (response.getState() === "SUCCESS") {  					
           component.set("v.OpptyInitProdDisp.lstopptyProdSchedDispTable", response.getReturnValue());					
          }					
          else if (response.getState() === "ERROR") {					
           $A.log("Errors", response.getError());					
          }					
         });					
         $A.enqueueAction(action);					
        }					
      },	
    
    //Enabling Oppty Schedule save buttons
     enableButton : function(component, event, helper)
     {
     var saveSchBtn = component.find("saveSch");				
     saveSchBtn.set("v.disabled",false);//enable the button           				
     var saveAndClsSchBtn = component.find("saveclose");				
     saveAndClsSchBtn.set("v.disabled",false);
     },
    //Disabling Oppty Schedule save buttons
     disableButton : function(component, event, helper)
     {
     var saveSchBtn = component.find("saveSch");				
     saveSchBtn.set("v.disabled",true);//disable the button           				
     var saveAndClsSchBtn = component.find("saveclose");				
     saveAndClsSchBtn.set("v.disabled",true);
     },
    //Enabling Prod Mgmt save buttons
     enableProdMgmtButton : function(component, event, helper)
     {
       var savePMBtn = component.find("savePM");				
       savePMBtn.set("v.disabled",false);//enable the button				
       var saveAndClsPMBtn = component.find("saveclosePM");				
       saveAndClsPMBtn.set("v.disabled",false);
     },
    //Disabling Prod Mgmt save buttons
     disableProdMgmtButton : function(component, event, helper)
     {
       var savePMBtn = component.find("savePM");				
       savePMBtn.set("v.disabled",true);//disable the button				
       var saveAndClsPMBtn = component.find("saveclosePM");				
       saveAndClsPMBtn.set("v.disabled",true);
     },
})