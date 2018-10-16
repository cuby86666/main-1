({
	handleForwardToDisti : function(component, event, helper) 
    {
        var leadId = component.get("v.recordId");
        var objContact = component.get("v.Contact");
        
        var contactId;
        if(objContact != null && objContact.contactId != null)
        {
            contactId = objContact.contactId;
            component.set("v.message",null);
			var action = component.get("c.forwardLeadWithinDisti");
        	action.setParams({
                leadId:leadId,
                contactId : contactId
            });
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);    
            });        
            console.log("Method invoked to forward within disti");
            $A.enqueueAction(action);
			component.set("v.IsProcessing", true); 
        }
        else
        {
            component.set("v.messagetype",'error');
            component.set("v.message",['Please select the contact before forwarding.']);
        }		
	},
    handleResponse : function(response, component, helper) 
    {
        console.log("---response received : " + response.getState());
        component.set("v.IsProcessing", false); 
		
        if(response.getState()==='SUCCESS')
        {
			//component.set("v.messagetype", 'success' );
			//component.set("v.message", ['Lead Forwarded Successfully!'] );
            //var retObj = JSON.parse(response.getReturnValue());
            //console.log("results of foward within disti  -- "+ retObj);
			// show success notification
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Lead has been forwarded successfully."
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();

            
        }
        else if(response.getState() == 'ERROR')
        {
 			var errors = response.getError();
            var errMessages = ['Error Occured'];
            component.set("v.messagetype", 'error' );
            
            if(errors)
            {
            	if (errors[0] && errors[0].message)
                {
                	errMessages.push(errors[0].message);
            	}    
            }
            component.set("v.message", errMessages );            
            console.log("error "+errors);                       
        }		
	},
    handleCancel : function(component, event, helper) 
    {
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
        if(dismissActionPanel)
        {
        	dismissActionPanel.fire();    
        }
	}
})