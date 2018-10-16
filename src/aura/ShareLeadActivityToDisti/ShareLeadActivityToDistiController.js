({
	 doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
        helper.onLoad(component, event);
        helper.leadData(component, event, helper);
	},
    
    handleCancel : function(component, event, helper) {
		helper.handleCancel(component, event, helper);
	},
    
        SetNotestoDisti:function(component, event, helper){
var notes = component.find("Notes-to-Disti").get("v.value");
        component.set("v.notestodisti",notes);
	},
    

	    sendMail: function(component, event, helper) {
            var cnt = component.get("v.selectedCount");
            
            if(cnt==0){
                 var errorsOnForm=[]; 
                errorsOnForm.push("No categories");
                component.set("v.error",errorsOnForm);
                
            }
            else{
                
           
        var Ids = [];
        // get all checkboxes 
  
            
        var getAllId = component.find("boxPack");

        // If the local ID is unique[in single record case], find() returns the component. not array
        if(! Array.isArray(getAllId)){
            if (getAllId.get("v.value") == true) {
                Ids.push(getAllId.get("v.text"));
            }
        }else{
            // play a for loop and check every checkbox values 
            // if value is checked(true) then add those Id (store in Text attribute on checkbox) in Ids var.
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    Ids.push(getAllId[i].get("v.text"));
                }
            }
        }
                 }
                

            var category = component.get("v.rating");
            var status = component.get("v.status");
       
  
     if(category == '5' && (status == 'Open' || status == 'Contacted' || status == 'Rejected' || status == 'NXP Expired' || status == 'Activity shared')){
                 helper.handleSendToDisti(component,event,Ids);
            }
            else if(category != '5'){
                var errorsOnForm=[]; 
                errorsOnForm.push("Lead category should be 5");
                component.set("v.error",errorsOnForm);
            }
            
             else if(status != 'Open' || status != 'Contacted' || status != 'Rejected' || status != 'NXP Expired' || status != 'Activity shared'){
                 var errorsOnForm=[]; 
                 console.log('status'+ status);
                errorsOnForm.push("Lead has already been sent to a distributor");
                component.set("v.error",errorsOnForm); 
                }
       
    },
    
    closeModel: function(component, event, helper) {
      //for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
      
       var LeadId = component.get("v.recordId");
      component.set("v.isCreated", false);
        
   },
    
     selectAll: function(component, event, helper) {
  //get the header checkbox value  
  var selectedHeaderCheck = event.getSource().get("v.value");
  // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
  // return the List of all checkboxs element 
  var getAllId = component.find("boxPack");
  // If the local ID is unique[in single record case], find() returns the component. not array  
   if(getAllId != null){ 
     if(! Array.isArray(getAllId)){
       if(selectedHeaderCheck == true){ 
          component.find("boxPack").set("v.value", true);
          component.set("v.selectedCount", 1);
       }else{
           component.find("boxPack").set("v.value", false);
           component.set("v.selectedCount", 0);
       }
     }else{
       // check if select all (header checkbox) is true then true all checkboxes on table in a for loop  
       // and set the all selected checkbox length in selectedCount attribute.
       // if value is false then make all checkboxes false in else part with play for loop 
       // and select count as 0 
        if (selectedHeaderCheck == true) {
        for (var i = 0; i < getAllId.length; i++) {
  		  component.find("boxPack")[i].set("v.value", true);
   		 component.set("v.selectedCount", getAllId.length);
        }
        } else {
          for (var i = 0; i < getAllId.length; i++) {
    		component.find("boxPack")[i].set("v.value", false);
   			 component.set("v.selectedCount", 0);
  	    }
       } 
     }  
   }
 
 },

     checkboxSelect: function(component, event, helper) {
   // get the selected checkbox value  
  var selectedRec = event.getSource().get("v.value");
   // get the selectedCount attrbute value(default is 0) for add/less numbers. 
  var getSelectedNumber = component.get("v.selectedCount");
   // check, if selected checkbox value is true then increment getSelectedNumber with 1 
   // else Decrement the getSelectedNumber with 1     
     if (selectedRec == true) {
         getSelectedNumber++;
     } else {
         getSelectedNumber--;
     }
  // set the actual value on selectedCount attribute to show on header part. 
  component.set("v.selectedCount", getSelectedNumber);
          var getAllId = component.find("boxPack").length;
          var count1 = component.get("v.select1");
            // if(getSelectedNumber == 1){
             //component.find("box3").set("v.value", true);
                     //}
                   
                 if(count1 == 1 && getSelectedNumber==1){
            component.find("box3").set("v.value", true); 
         }
         else{
             component.find("box3").set("v.value", false); 
         }
         
         

                     
         if(getSelectedNumber == getAllId){
             component.find("box3").set("v.value", true);
             
         }
         if(getSelectedNumber == 0){
             component.find("box3").set("v.value", false);
             
         }
 },
})