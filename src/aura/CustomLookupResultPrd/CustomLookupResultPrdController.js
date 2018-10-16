({
	 selectDistiPrd : function(component, event, helper){      
    // get the selected Opportunity from list  
      var getDistiPrd = component.get("v.oProduct"); 
         
    // call the event   
      var compEvent = component.getEvent("oPrdsObjectRecordEvent");         
    // set the Selected Opportunity to the event attribute.  
         compEvent.setParams({"prdRecordByEvent" : getDistiPrd});                                                                  
    // fire the event  
         compEvent.fire();
    },
})