({
	getOpportunityProducts: function(cmp) {
		var action = cmp.get("c.getOpportunityProducts");
        
        action.setParams({ 
            progId: cmp.get("v.recordId") 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.set("v.data", response.getReturnValue());
            } else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);	
	},
	
	updateOpportunityProducts: function(cmp, event) {
		var action = cmp.get("c.updateOpportunityProducts");
		
		action.setParams({ 
            changedValues: JSON.stringify(event.getParam("draftValues"))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
            	this.reload(cmp);
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = JSON.parse(errors[0]["message"]);
                /*
                cmp.set("v.errors", 
                        {
                            rows: {
                                "00k1l0000031ppcAAA": {
                                    title: 'We found 2 errors.',
                                    messages: [
                                        'Enter a valid amount.',
                                        'Verify the email address and try again.'
                                    ],
                                    fieldNames: ['price', 'priceErosionRate']
                                }
                            }
                        }
                       );
				*/
                cmp.set("v.errors", message);
                //alert(errors[0]["message"]);
            }
        });
        
        $A.enqueueAction(action);	
	},
	
	reload: function(cmp) {
		var urlEvent = $A.get("e.force:navigateToURL");
        var progId = cmp.get("v.recordId");
        var progName = cmp.get("v.progName");
                
        urlEvent.setParams({
        	"url": "/apex/opportunityProduct?progId=" + progId + "&progName=" + progName  
        });
                
        urlEvent.fire();
	}
})