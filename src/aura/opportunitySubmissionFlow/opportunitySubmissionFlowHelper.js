({					
    getOpptyApprovalSubmission: function(component) {
     var OpptyId = component.get("v.recordId"); 
     var action = component.get("c.getOpptyScheduleInfoClass");  //Onload dispatching
     action.setParams({					
         opportunityId: component.get("v.recordId") 					
     });					
        
     action.setCallback(this, function(response) {					
     if (response.getState() === "SUCCESS") 
     {
      var result = response.getReturnValue();
      if(result.oppValues.Design_Win_Approval_Process__c == 'Open')
      {					
       var urlEvent = $A.get("e.force:navigateToURL");
       urlEvent.setParams({
        "url": "/flow/OpptySubmissionFlow?OpptyId="+OpptyId+"&retURL="+OpptyId
       });
       urlEvent.fire(); 					       					
      }
      else
      {
        //alert("Only Open Opportunity can Submit for Approval!");
        var showToast = $A.get('e.force:showToast');

        //set the title and message params
        showToast.setParams(
            {
                'title': 'Note: ',
                'type': 'Error',
                'message': "Only Open Opportunity can Submit for Approval!"
            }
        );
        showToast.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();  
      }   
     } 					
     else if (response.getState() === "ERROR") {					
       $A.log("Errors", response.getError());					
     }					
   });					
   $A.enqueueAction(action);					
  },				
})