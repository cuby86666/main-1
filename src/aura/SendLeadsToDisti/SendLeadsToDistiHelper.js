({
	handleSendToDisti : function(component, event, helper) {
        var errm;
		var primaryDistributorContact = component.get("v.primaryDistiContact");
        var primaryDistributorContactId;
        if(primaryDistributorContact){
            primaryDistributorContactId = primaryDistributorContact.contactId;
        }
        var primaryAdditionalContact = component.get("v.primaryAdditionalContact");
		var secondaryDistributorContact = component.get("v.secondaryDistiContact");
        var secondaryDistributorContactId;
        if(secondaryDistributorContact){
            secondaryDistributorContactId = secondaryDistributorContact.contactId;
        }
        var secondaryAdditionalContact = component.get("v.secondaryAdditionalContact");
        var distiContactDetails = component.get("v.distiContactDetails");
        var notesToDisti = distiContactDetails.notesToDisti;
        var expiresWithPrimary = distiContactDetails.expiresWithPrimary;
        var rejectedByPrimary = distiContactDetails.rejectedByPrimary;
        console.log("expiresWithPrimary "+expiresWithPrimary);
        console.log("rejectedByPrimary "+rejectedByPrimary);
        var primaryDetailsEntered = component.get("v.primaryDetailsPresent");
        var leadId=component.get("v.recordId");
        if( (primaryDistributorContactId && primaryDistributorContactId.trim().length>0)|| 
          primaryDetailsEntered==true) {
            component.set("v.error",null);
			var action = component.get("c.sendLeadToDisti");
        	action.setParams({
                leadId:leadId,
                primaryContactId : primaryDistributorContactId,
                primaryAdditionalEmail : primaryAdditionalContact,
                secondaryContactId : secondaryDistributorContactId,
                secondaryAdditionalEmail : secondaryAdditionalContact,
                expiresWithPrimary : expiresWithPrimary,
                rejectedByPrimary : rejectedByPrimary,
                notesToDisti : notesToDisti
            });
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);    
            });        
            console.log("send to disti contacts called");
            $A.enqueueAction(action);
			component.set("v.toggleSpinner", true); 
        }else{
			var errorsOnForm=[];
            if((!primaryDistributorContactId) || primaryDistributorContactId.trim().length==0){
                errorsOnForm.push("Enter Primary Contact");
            }
            if(errorsOnForm.length>0){
                component.set("v.error",errorsOnForm);
            }
        }
	},
    handleResponse : function(res, component, helper) {
        console.log("result return -- "+res.getState());
        component.set("v.toggleSpinner", false); 

        if(res.getState()==='SUCCESS'){
            var retObj = JSON.parse(res.getReturnValue());
            console.log("results of send mail  -- "+retObj);
            component.set("v.distiContactDetails",retObj);
            component.set("v.primaryDistiContact",null);
            component.set("v.primaryAdditionalContact",null);
            component.set("v.secondaryDistiContact",null);
            component.set("v.secondaryAdditionalContact",null);
        }else if(res.getState() == 'ERROR'){
 			var errors = res.getError();
            console.log("error "+errors);
            for(var prop in errors[0]){
                console.log(errors[0][prop]);
            }           
        }		
	},
    doInit : function(component, event, helper) {
		console.log("record id" +component.get("v.recordId"));
        var action = component.get("c.getDistiContactsForLead");
        var compleadId = component.get("v.recordId");
        action.setParams({leadId : compleadId});
        action.setCallback(this,function(response){
        	var state = response.getState();
            console.log("results state -- "+response.getState());
            component.set("v.toggleSpinner", false); 

            if(state === "SUCCESS" && response.getReturnValue() && response.getReturnValue().length >0) {
				console.log("disti contact details -- "+response.getReturnValue()); 
                var retObj =JSON.parse(response.getReturnValue());
                if(retObj.primaryDistiContact !=null)
                    component.set("v.primaryDetailsPresent",true);
                else
                    component.set("v.primaryDetailsPresent",false);
                
                if(retObj.secondaryDistiContact !=null)
                    component.set("v.secondaryDetailsPresent",true);
                else
                    component.set("v.secondaryDetailsPresent",false);
                
                component.set("v.distiContactDetails",retObj);
            }else if(!response.getReturnValue() || response.getReturnValue().length==0){
                component.set("v.distiContactDetails",null);
            }
        });
        $A.enqueueAction(action);
        component.set("v.toggleSpinner", true); 
	},
    deleteSecondaryContact : function(component, event, helper) {
		var distiContact = component.get("v.distiContactDetails");
        var secondaryContactId = distiContact.secondaryDistiContact.recordId;
        var action = component.get("c.deleteSecondary");
        var compleadId = component.get("v.recordId");
        action.setParams({
            idToDelete: secondaryContactId,
            leadId: compleadId
        });
        action.setCallback(this,function(response){
        	var state = response.getState();
            component.set("v.toggleSpinner", false); 

            console.log("results state -- "+response.getState());
             console.log("results value -- "+response.getReturnValue());
            if(state === "SUCCESS" && response.getReturnValue() && response.getReturnValue().length >0) {
				console.log("disti contact details -- "+response.getReturnValue()); 
                var retObj =JSON.parse(response.getReturnValue());
                if(retObj.primaryDistiContact !=null)
                    component.set("v.primaryDetailsPresent",true);
                else
                    component.set("v.primaryDetailsPresent",false);
                
                if(retObj.secondaryDistiContact !=null)
                    component.set("v.secondaryDetailsPresent",true);
                else
                    component.set("v.secondaryDetailsPresent",false);
                
                component.set("v.distiContactDetails",retObj);
            }else if(!response.getReturnValue() || response.getReturnValue().length==0){
                component.set("v.distiContactDetails",null);
            }            
        });
        console.log("call delete for -- "+secondaryContactId+" get "+compleadId);
        $A.enqueueAction(action);  
        component.set("v.toggleSpinner", true); 

	},
    handleCancel : function(component, event, helper) {
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
        if(dismissActionPanel){
        	dismissActionPanel.fire();    
        }else{
			var recordId = component.get("v.recordId");                                        
         	var myEvent = $A.get("e.c:CancelAndClose");
			myEvent.fire();             
        }
	},
    handleErrors : function(component,error,helper){
		var description = error.getParams().description;
        component.set("v.error", description);       
    }
})