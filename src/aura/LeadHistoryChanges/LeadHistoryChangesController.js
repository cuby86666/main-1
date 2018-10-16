({
    doInit: function(component, event, helper) {
        var leadId = component.get("v.recordId");
        var page = component.get("v.page") || 1;
        var recordToDisplay = component.find("recordSize").get("v.value");
        
        component.set('v.columnsToDisplay', [
            {label: 'Field', fieldName: 'Field', type: 'Name'},                   
            {label: 'Old Value', fieldName: 'OldValue'},
            {label: 'New Value', fieldName: 'NewValue'},
            {label: 'Created Date', fieldName: 'CreatedDate'},
            {label: 'User', fieldName: 'User'}
        ]);

        helper.getLeadHistoryChanges(component, page, recordToDisplay, leadId);
    },
    
    navigate: function(component, event, helper) {
        var leadId = component.get("v.recordId");
        var page = component.get("v.page") || 1; 
        var direction = event.getSource().get("v.label");
        var recordToDisplay = component.find("recordSize").get("v.value");
        page = direction === "Previous Page" ? (page - 1) : (page + 1);

        helper.getLeadHistoryChanges(component, page, recordToDisplay, leadId);
    },
    
    onSelectChange: function(component, event, helper) {
        var leadId = component.get("v.recordId");
        var page = 1
        var recordToDisplay = component.find("recordSize").get("v.value");
        helper.getLeadHistoryChanges(component, page, recordToDisplay, leadId);
    },
})