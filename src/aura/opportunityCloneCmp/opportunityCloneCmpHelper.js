({
	getOpptyProds : function(component) {
		var action = component.get("c.getOpptyProdsByOpptyId");
		action.setParams({
			opptyId: component.get("v.opptyId"),
            func: component.get("v.func")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state == "SUCCESS") {
				component.set("v.wrapper", response.getReturnValue());
                var message = component.get("v.wrapper.message");
                if (message != null) {
                    component.set("v.warningMessage", message);
                }
            } else if (state == "ERROR") {
                console.log(response.getError());
                var errors = response.getError();
                var errorMessage = "";
                for (var i=0; i < errors.length; i++) {
                    var error = errors[i];
                    if (error.fieldErrors) {
                        for (var fieldName in error.fieldErrors) {
                            //each field could have multiple errors
                            error.fieldErrors[fieldName].forEach( function (errorList){	
                                errorMessage += ("Field Error on " + fieldName + "; " + errorList.message);
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
                component.set("v.errorMessage", errorMessage);
                component.set("v.isError", true);
                component.set("v.isProcessing", false);
            }
		});
        $A.enqueueAction(action);
	},
    
    doApprovalStatusCheck : function(component) {
	    var oppty = component.get("v.wrapper.oppty");
        if (oppty.Design_Win_Approval_Process__c == "Open")
            return true;
        else {
            component.set("v.errorMessage", "Only open opportunity can be spun off.");
        }
        return false;
    },
    
    doSpinOffCheck : function(component) {
        var spinOffCount = 0;
        var nonSpinOffCount = 0;
        var inActiveProds = 0;
        var lstWrappers = component.get("v.wrapper.lstWrappers");
        for(var i = 0; i < lstWrappers.length; i++) {
            //alert(lstWrappers[i].isSelected);
            if (lstWrappers[i].isSelected) {
                spinOffCount++;
                if (lstWrappers[i].opptyLineItem.Product2.IsActive == false) {
                	inActiveProds++;
            	} 
            } else {
                nonSpinOffCount++;
            }
                      
        }
        if (nonSpinOffCount == 0) {
            component.set("v.errorMessage", "Current opportunity requires at least one product.");
            return false;
        } else if (spinOffCount == 0) {
            component.set("v.errorMessage", "Please select spin-off product(s).")
            return false;
        } else if (inActiveProds > 0) {
            component.set("v.errorMessage", "Cannot spin off inactive product. Please select other active products.")
            return false;            
        }
        return true;
    },

    doCloneAndSpinOff : function(component) {
        var wrapper = component.get("v.wrapper");
        var action = component.get("c.doCloneAndSpinOff");
        action.setParams({
            opptyWrapper: JSON.stringify(wrapper),
            func: component.get("v.func")
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state == "SUCCESS") {
                //redirect to maintain oppty sched page of new oppty
                var newOpptyId = response.getReturnValue();
                var envType = component.get("v.envType");
                window.location.href = "/apex/opportunitySchedule?isdtp=" + envType + "&id=" + newOpptyId;
            } else if (state == "ERROR") {
                console.log(response.getError());
                var errors = response.getError();
                var errorMessage = "";
                for (var i=0; i < errors.length; i++) {
                    var error = errors[i];
                    if (error.fieldErrors) {
                        for (var fieldName in error.fieldErrors) {
                            //each field could have multiple errors
                            error.fieldErrors[fieldName].forEach( function (errorList){	
                                errorMessage += ("Field Error on " + fieldName + "; " + errorList.message);
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
                component.set("v.errorMessage", errorMessage);
                component.set("v.isError", true);
                component.set("v.isProcessing", false);
            }
        });
        $A.enqueueAction(action);
    }    
})