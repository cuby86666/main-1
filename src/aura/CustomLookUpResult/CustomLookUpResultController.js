({
	 selectOpportunity : function(component, event, helper){      
    // get the selected Opportunity from list  
      var getSelectOpportunity = component.get("v.oOpportunity");      
    // call the event   
      var compEvent = component.getEvent("oselectedsObjectRecordEvent");         
    // set the Selected Opportunity to the event attribute.  
         compEvent.setParams({"recordByEvent" : getSelectOpportunity});                                                                  
    // fire the event  
         compEvent.fire();
    },
    
    selectAccount : function(component, event, helper){
        var getSelectAccount = component.get("v.accountList");         
        var compEvent = component.getEvent("oselectedAccRecordEvent");
        compEvent.setParams({"accRecordByEvent" : getSelectAccount });
        compEvent.fire();
    }
})