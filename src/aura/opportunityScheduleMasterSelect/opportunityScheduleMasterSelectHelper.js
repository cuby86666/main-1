({
	getOpportunities: function(cmp) {
		var action = cmp.get("c.getOpportunities");
        
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
	}
})