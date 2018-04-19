({
	doInit : function(component, event, helper) {
        component.set("v.isPreview", false);
        component.set("v.isProcessing", false);
        component.set("v.isError", false);
        var func = component.get("v.func");
        //function code check
        if (func == "clone" || func == "spin off" || func == "reopen") {
        	helper.getOpptyProds(component);
            component.set("v.funcString", func.toUpperCase());
        } else {
            component.set("v.errorMessage", "Do not support current function type. Please press back and try again.");
            component.set("v.isError", true);
        }
	},

    onChecked : function(component, event) {
        component.set("v.errorMessage", null);
        component.set("v.isError", false);
        //var checkCmp = component.find("spinoff");
        //var source = event.getSource();
        //alert(source.get("v.value"));
    },
    
    doFinish : function(component, event, helper) {
        var func = component.get("v.func");
        component.set("v.isProcessing", true);
        if (func == "clone" || func == "spin off" || func == "reopen") {
        	helper.doCloneAndSpinOff(component);
        }
    },
    
    doPreview : function(component, event, helper) {
        var func = component.get("v.func");
        var tag = "";
        var checkResult = true;
        if (func == "clone") {
            tag = "(clone)";
        } else if (func == "spin off") {
            checkResult = helper.doSpinOffCheck(component) && helper.doApprovalStatusCheck(component);
            component.set("v.isError", !checkResult);
            tag = "(spinoff)";
        } else if ("reopen") {
            tag = ""
        } else {
            return;
        }
        component.set("v.isPreview", checkResult);
        var opptyName = component.get("v.wrapper.oppty.Name") + tag;
        component.set("v.wrapper.newOpptyName", opptyName);
        //var recordId = component.get("v.selectedLookUpRecord").Id;
    },
    
    doBack : function(component, event, helper) {
        component.set("v.isPreview", false);
        component.set("v.errorMessage", null);
        component.set("v.isError", false);
    },
    
    gotoURL : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var recordId = component.get("v.opptyId");
        urlEvent.setParams({
          "url" : "/" + recordId
    	});
    	urlEvent.fire();
	}
})