({
	doInit : function(component, event, helper) {
		  var action = component.get("c.getDistiContactsForLead");
        var compleadId = component.get("v.recordId");
        action.setParams({leadId : compleadId});
        action.setCallback(this,function(response){
        	var state = response.getState();
            component.set("v.toggleSpinner", false); 
            
                 if(state === "SUCCESS" && response.getReturnValue() && response.getReturnValue().length >0) {
				//console.log("disti contact details -- "+response.getReturnValue()); 
                var retObj =JSON.parse(response.getReturnValue());
                if(retObj.primaryDistiContact !=null)
                    component.set("v.primaryDetailsPresent",true);
                else
                    component.set("v.primaryDetailsPresent",false);
                            
	}
            else if(!response.getReturnValue() || response.getReturnValue().length==0){
                component.set("v.distiContactDetails",null);
            }
            
          
            
});
        $A.enqueueAction(action);
        component.set("v.toggleSpinner", true); 
      
    },
    
   onLoad: function(component, event) {
      
        var action = component.get('c.fetchLeadact');
         var compleadId = component.get("v.recordId");
        action.setParams({leadId : compleadId});
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfContact attribute on component.
                component.set('v.ListOfLeads', response.getReturnValue());
                // set deafult count and select all checkbox value to false on load 
                component.set("v.selectedCount", 0);
                component.find("box3").set("v.value", false);
                 if(response.getReturnValue().length == 1){
                    component.set("v.select1" , 1);
                }
            }
        });
        $A.enqueueAction(action);
    },    
  
    leadData : function(component, event, helper) {

      var action = component.get("c.getleads");
 		var compleadId = component.get("v.recordId");
        action.setParams({leadId : compleadId});
    
      action.setCallback(this, function(response) {
     
        var state = response.getState();

        if (state === "SUCCESS") {
          
            component.set('v.Lead', response.getReturnValue());
            component.set('v.Name', response.getReturnValue().Name);
            component.set('v.Company', response.getReturnValue().Company);
            component.set('v.JobDescription', response.getReturnValue().Job_Description__c);
            component.set('v.NormalizedTitle', response.getReturnValue().Normalized_Title__c);
            component.set('v.Street', response.getReturnValue().Street);
            component.set('v.city', response.getReturnValue().City);
            component.set('v.State', response.getReturnValue().State);
            component.set('v.Zip', response.getReturnValue().PostalCode);
            component.set('v.Country', response.getReturnValue().Country);
            component.set('v.Industry', response.getReturnValue().Industry);
            component.set('v.Email', response.getReturnValue().Email);
            component.set('v.Phone', response.getReturnValue().Phone);
            component.set('v.HasOptedOutOfEmail', response.getReturnValue().HasOptedOutOfEmail);
            component.set('v.DoNotCall', response.getReturnValue().DoNotCall);
            component.set('v.rating', response.getReturnValue().Rating);
            component.set('v.status', response.getReturnValue().Status);
            component.set('v.owneremail', response.getReturnValue().Owner.Email);
          
        }
      });
      $A.enqueueAction(action);
    },

    handleSendToDisti : function(component, event, Ids) {
        var obj =component.get("v.Lead");
        var nam = component.get("v.Name");
        var comp = component.get("v.Company");
        var job = component.get("v.JobDescription");
        var title = component.get("v.NormalizedTitle");
       var street = component.get("v.Street");
        var City = component.get("v.city");
        var State = component.get("v.State");
        var Zip = component.get("v.Zip");
        var Country = component.get("v.Country");
       // var add = component.get("v.Address");
        var Ind = component.get("v.Industry");
        var emai = component.get("v.Email");
        var phn = component.get("v.Phone");
        var optemail = component.get("v.HasOptedOutOfEmail");
        var dntcall = component.get("v.DoNotCall");
        var owneremail = component.get("v.owneremail");
        //alert(owneremail);
     
        var primaryDistributorContact = component.get("v.primaryDistiContact");
        var AdditionalContact = component.get("v.primaryAdditionalContact");
        var primaryDetailsEntered = component.get("v.primaryDetailsPresent");
        var notestodisti = component.get("v.notestodisti");
       
        var primaryDistributorContactId;
        if(primaryDistributorContact){
            primaryDistributorContactId = primaryDistributorContact.contactId;
        }
        
        if(primaryDistributorContactId != null && Ids != null){
          
         
        var action = component.get("c.shareLead");
 		var compleadId = component.get("v.recordId");
        action.setParams({leadid : compleadId,Name : nam,
                          company : comp,jobdesc : job,
                          tit : title,Industry : Ind,
                          Emaill : emai,Phnn : phn,
                          opemail : optemail,dncall : dntcall,
                          idss : Ids,strt : street,
                          Cty : City,Stat : State,
                          Cntry : Country,Zp : Zip,
                          contactId : primaryDistributorContactId,addnlcontact : AdditionalContact,ownremail : owneremail,notes : notestodisti });
        
         action.setCallback(this, function(response) {
                 component.set("v.toggleSpinner", false);      
             var state = response.getState();
             
             
            if (state === "SUCCESS"){                     
                
					component.set("v.isCreated", true); 
            }

                        
        });
         $A.enqueueAction(action);
        component.set("v.error",null);
      component.set("v.toggleSpinner", true); 
        }
        else if ((primaryDistributorContactId == null)){
             	var errorsOnForm=[];
                errorsOnForm.push("Enter Distiributor Contact");
                component.set("v.error",errorsOnForm);
        }
    else if(Ids == null){
                 var errorsOnForm=[];
                errorsOnForm.push("No Lead Activities to share");
                component.set("v.error",errorsOnForm);
    
}
             
       
    },
    
 
    
     handleCancel : function(component, event, helper) {
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
        if(dismissActionPanel){
        	dismissActionPanel.fire();    
        }else{
			var recordId = component.get("v.recordId");                                        
         	var myEvent = $A.get("e.c:CancelAndClose");
			myEvent.fire();             
        }
	},
 
    })