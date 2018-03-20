({
	 selectDistiAcc : function(component, event, helper){      
    // get the selected Opportunity from list  
      var getDistiAcc = component.get("v.oAccount");      
    // call the event   
      var compEvent = component.getEvent("oAccsObjectRecordEvent");         
    // set the Selected Opportunity to the event attribute.  
         compEvent.setParams({"accRecordByEvent" : getDistiAcc});                                                                  
    // fire the event  
         compEvent.fire();
    },
})