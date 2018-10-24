({
	init: function(cmp, event, helper) {
        cmp.set("v.columns", [
            {label: "Opportunity Name", fieldName: "name", type: "text"},
            {label: "Account Name", fieldName: "acctName", type: "text"},
            {label: "Stage", fieldName: "stage", type: "text"},
            {label: "Created Date", fieldName: "createdDate", type: "date-local", typeAttributes: {month: "2-digit", day: "2-digit"}},
            {label: "Expected Close Date", fieldName: "closeDate", type: "date-local", typeAttributes: {month: "2-digit", day: "2-digit"}},
            {label: "Production Date", fieldName: "prodDate", type: "date-local", typeAttributes: {month: "2-digit", day: "2-digit"}},
            {label: "Oppty LT Value (USD)", fieldName: "ltValue", type: "number"},
            {label: "BL Concat", fieldName: "blConcat", type: "text"}
        ]);
        
        helper.getOpportunities(cmp);
    },
    
    handleClick: function(cmp, event, helper) {
    	switch (event.getSource().get("v.name")) {
            case "cancel":
                var urlEvent = $A.get("e.force:navigateToURL");
                var recordId = cmp.get("v.recordId");
                
                urlEvent.setParams({
                    "url": "/" + recordId 
                });
                
                urlEvent.fire();
                break;
            case "next":
                var selectedRows = cmp.find("datatable").getSelectedRows();
                
                if (selectedRows.length > 0) {
                    var opptyId;
                    
                    for (var i = 0; i < selectedRows.length; i++) {
                        opptyId = selectedRows[i].id; 
            			break;
        			}
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    
                    urlEvent.setParams({
                        "url": "/apex/opportunityScheduleMaster?opptyId=" + opptyId  
                    });
                    
                    urlEvent.fire();
                } else {
                    alert("Please select an opportunity.");
                }
                
                break;
        }
    },
})