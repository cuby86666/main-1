({
    getLeadHistoryChanges: function(component, page, recordToDisplay, leadId) {
        var action = component.get("c.queryLeadHistoryRecords");

        action.setParams({
            "pageNumber": page,
            "recordToDisplay": recordToDisplay,
            "leadId": leadId
        });
 
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            console.log('result ---->' + JSON.stringify(result)); 
            component.set("v.leadHistoryChanges", result.leadHistoryChanges);
            component.set("v.page", result.page);
            component.set("v.total", result.total);
            component.set("v.pages", Math.ceil(result.total / recordToDisplay));
        });
        $A.enqueueAction(action);
    }
})