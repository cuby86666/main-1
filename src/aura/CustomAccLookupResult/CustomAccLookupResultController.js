({
	selectAccount : function(component, event, helper){
        var getSelectAccount = component.get("v.accountList");         
        var compEvent = component.getEvent("oselectedAccRecordEvent");
        compEvent.setParams({"accRecordByEvent" : getSelectAccount });
        compEvent.fire();
    }
})