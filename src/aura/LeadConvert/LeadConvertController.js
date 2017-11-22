({
	doInit : function(component, event, helper) {        
        helper.leadActivityList(component);
        helper.fetchPicklistValues(component, 'Industry_Segment__c','Sub_Segment__c');        
    },
    
    // function call on change the controller field  
   onControllerFieldChange: function(component, event, helper) {
      //alert(event.getSource().get("v.value"));
      // get the selected value 
         
      var controllerValueKey = event.getSource().get("v.value"); 
      // get the map values   
      var Map = component.get("v.depnedentFieldMap"); 
      // check if selected value is not equal to None then call the helper function.
      // if controller field value is none then make dependent field value is none and disable field
      if (controllerValueKey != '--- None ---') { 
         // get dependent values for controller field by using map[key].  
         // for i.e "India" is controllerValueKey so in the map give key Name for get map values like 
         // map['India'] = its return all dependent picklist values.
         var ListOfDependentFields = Map[controllerValueKey];
         helper.fetchDepValues(component, ListOfDependentFields); 
      } else {
         var defaultVal = [{
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         }];
         component.find('slave').set("v.options", defaultVal);
         component.set("v.isDependentDisable", true);
      }
      var opptySeg=component.find("master").get("v.value");
      component.set("v.OpportunitySeg",opptySeg); 
       var opptySubSeg=component.find("slave").get("v.value");
        component.set("v.OpportunitySubSeg",opptySubSeg);
   },
    onDepFieldChange:function(component, event, helper){
        var opptySubSeg=component.find("slave").get("v.value");
        component.set("v.OpportunitySubSeg",opptySubSeg);
    },
    fetchAccVal:function(component, event, helper){
        var accVal=component.find("text-input-acc").get("v.value");
        component.set("v.accName",accVal);
    },
            
    handleClickIsTag:function(component, event, helper){
     component.set("v.IsTag", true);  
     component.set("v.IsCreate", false);       
        var oppNameVal =component.get("v.OpportunityName");
        var clsDateVal = component.get("v.closeDate");
		var opDescVal=component.get("v.OpportunityDesc");
		var opSegVal =component.get("v.OpportunitySubSeg");
        var opsubSegVal =component.set("v.OpportunitySubSeg");        
        if(oppNameVal !=null){
            var opName=component.find("text-input-id-1").set("v.value", "");
        	component.set("v.OpportunityName",opName);
        }
        if(clsDateVal!=null){
            var clsDate=component.find("expclosedate1").set("v.value", "");
        	component.set("v.closeDate",clsDate);
        }
        if(opDescVal != null){
            var opDesc=component.find("text-input-id-2").set("v.value", "");
        	component.set("v.OpportunityDesc",opDesc);
        }
        if(opSegVal !=null){
            var opSeg=component.find("master").set("v.value", "");
        	component.set("v.OpportunitySeg",opSeg);
        }
        if(opsubSegVal !=null){
            var opsubSeg=component.find("slave").set("v.value", "");
        	component.set("v.OpportunitySubSeg",opsubSeg);
        }                                
        component.set("v.isDependentDisable", true);
    },
    
    SetOpptyName:function(component, event, helper){
        var opptyName=component.find('text-input-id-1').get("v.value");      
        component.set("v.OpportunityName",opptyName);
       
    },
    SetOpptyDesc:function(component, event, helper){
    	var opptyDesc=component.find("text-input-id-2").get("v.value");
        component.set("v.OpportunityDesc",opptyDesc);
	},
    
    closeDateChange: function(component, event, helper){
        var closeDateField = component.find("expclosedate1");
        var oppCloseDate = closeDateField.get("v.value");       
        component.set("v.closeDate", oppCloseDate);
	},    
    handleClickCreate:function(component, event, helper){        
     component.set("v.IsCreate", true);
     component.set("v.IsTag", false);       
        var opIdExistVal =component.get("v.selectedRecord.Id");
        if(opIdExistVal !=null){
            var opIdClear=component.find("oppLookupField").set("v.value", "");
        	component.set("v.selectedRecord",opIdClear);
        }        
    },
    keyPressController : function(component, event, helper) {
      // get the search Input keyword   
		var getInputkeyWord = component.get("v.SearchKeyWord");
      // check if getInputKeyWord size id more then 0 then open the lookup result List and 
      // call the helper 
      // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }         
	},
    
    keyPressAccController : function(component, event, helper) {
      // get the search Input keyword   
		var getInputkeyWord = component.get("v.SearchAccKeyWord");
      // check if getInputKeyWord size id more then 0 then open the lookup result List and 
      // call the helper 
      // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("AccsearchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchAccHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchAccRecords", null ); 
             var forclose = component.find("AccsearchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }         
	},     
    
    displaylist:function(component, event, helper){
        var forOpen = component.find("searchRes");        
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        
        var forcloseAcc = component.find("AccsearchRes");
           	$A.util.addClass(forcloseAcc, 'slds-is-close');
           	$A.util.removeClass(forcloseAcc, 'slds-is-open');
        // call the apex class method         
     	var action = component.get("c.fetchOppList");
        var LdId= component.get("v.recordId");
        var ldoldAccId=component.get("v.Leads.Account_Id__c");        
		var ldNewAccId=component.get("v.selectedAccRecord.Id");        
        // set param to method
        
        if(ldNewAccId !=null){
            
        	action.setParams({            
            LeadId :LdId,
            leadAccId:ldNewAccId
          	});  
    	} 
        else{
            
            action.setParams({            
            LeadId :LdId,
            leadAccId:ldoldAccId
          	}); 
        }
              
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();              
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
                
            }
            if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                }                	
	 			else {
	                    component.set("v.Message", 'Search Result...');
	                }
            
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    },
    
//function to ruturn the list of accounts    
    displayAcclist:function(component, event, helper){ 
       var forclose = component.find("searchRes");
           	$A.util.addClass(forclose, 'slds-is-close');
           	$A.util.removeClass(forclose, 'slds-is-open');
        
        var forOpen = component.find("AccsearchRes");        
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        
        // call the apex class method 
     var action = component.get("c.listLeadAccount");
        var LdId= component.get("v.recordId");
        var LdOwnerId= component.get("v.Leads.Owner.Id"); 
        
        // set param to method  
        action.setParams({            
            LeadId :LdId,
            LeadOwnerId :LdOwnerId 
          });
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();              
                // set searchResult list with return value from server.
                component.set("v.listOfSearchAccRecords", storeResponse);
                
            } 
            if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                }                	
	 			else {
	                    component.set("v.Message", 'Search Result...');
	                }
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    },
    
     
    
// function to clear display Account result list    
  	hideDisplayList: function(component,event,helper){       
       var forcloseAcc = component.find("AccsearchRes");
           	$A.util.addClass(forcloseAcc, 'slds-is-close');
           	$A.util.removeClass(forcloseAcc, 'slds-is-open');
       var lookUpTargetAcc = component.find("AcclookupFieldTag");
       		$A.util.addClass(lookUpTargetAcc, 'slds-show');
         	$A.util.removeClass(lookUpTargetAcc, 'slds-hide');
    },
            
// function to clear display opportunity result list     
    hidelist :function(component,event,helper){
        var lookUpTarget = component.find("lookupField");
         	$A.util.addClass(lookUpTarget, 'slds-show');
         	$A.util.removeClass(lookUpTarget, 'slds-hide');
        var forclose = component.find("searchRes");
           	$A.util.addClass(forclose, 'slds-is-close');
           	$A.util.removeClass(forclose, 'slds-is-open'); 
    },
    
  // function for clear the Record Selaction 
    clear :function(component,event,helper){      
         var pillTarget = component.find("lookup-pill");                           
         	$A.util.addClass(pillTarget, 'slds-hide');
         	$A.util.removeClass(pillTarget, 'slds-show'); 
  		 var lookUpTarget = component.find("lookupField");
         	$A.util.addClass(lookUpTarget, 'slds-show');
         	$A.util.removeClass(lookUpTarget, 'slds-hide');                       
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null ); 
        var opIdClear=component.find("oppLookupField").set("v.value", "");
        component.set("v.selectedRecord",opIdClear);
    },
    
    clearAcc: function(component,event,helper){
        var pillTargetAcc = component.find("lookup-pill-1");        
         	$A.util.addClass(pillTargetAcc, 'slds-hide');
         	$A.util.removeClass(pillTargetAcc, 'slds-show');
    	var lookUpTargetAcc = component.find("AcclookupFieldTag");
         	$A.util.addClass(lookUpTargetAcc, 'slds-show');
         	$A.util.removeClass(lookUpTargetAcc, 'slds-hide');        
         var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        component.set("v.SearchAccKeyWord",null);
        component.set("v.listOfSearchAccRecords", null );
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedAccRecord.Id",null);
    },    
    
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
     
    // get the selected Opportunity record from the COMPONETN event 	 
       var selectedOpportunityGetFromEvent = event.getParam("recordByEvent");
	   
	   component.set("v.selectedRecord" , selectedOpportunityGetFromEvent); 
                 
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
      
        
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');                      
	},

     handleComponentAccEvent : function(component, event, helper) {     
    // get the selected Opportunity record from the COMPONETN event 	        
        var selectedAccountGetFromEvent=event.getParam("accRecordByEvent");	   
        component.set("v.selectedAccRecord" , selectedAccountGetFromEvent);
         var createSec=component.get("v.IsCreate");
         var tagSec=component.get("v.IsTag");
        var acc=component.get("v.selectedAccRecord");
        var accId=component.get("v.selectedAccRecord.Id");
        
         
             var forcloseAcc = component.find("lookup-pill-1");
           		$A.util.addClass(forcloseAcc, 'slds-show');
           		$A.util.removeClass(forcloseAcc, 'slds-hide');              
        	var forcloseAcc = component.find("AccsearchRes");
           		$A.util.addClass(forcloseAcc, 'slds-is-close');
           		$A.util.removeClass(forcloseAcc, 'slds-is-open');        
        	var lookUpTargetAcc = component.find("AcclookupFieldTag");
            	$A.util.addClass(lookUpTargetAcc, 'slds-hide');
            	$A.util.removeClass(lookUpTargetAcc, 'slds-show');
         
            
         
         
	},
        
  // automatically call when the component is done waiting for a response to a server request.  
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
    
 // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    
    cancelLead : function(component, event, helper) {
        component.set("v.isSpinner", true);
         var recordId = component.get("v.recordId");                                        
         window.location.href = '/'+recordId;                                       
    },   

//function for convert Lead    
    convertLeadButton : function(component, event, helper) {        
        // call the apex class method 
         var forcloseAcc = component.find("AccsearchRes");
           	$A.util.addClass(forcloseAcc, 'slds-is-close');
           	$A.util.removeClass(forcloseAcc, 'slds-is-open');
       
        var accNameRan=component.find("text-input-acc").set("v.value", "");
        component.set("v.accName",accNameRan);        
        var oppName=component.get("v.OpportunityName");        
        var oppdesc=component.get("v.OpportunityDesc");                
        var oppSeg=component.get("v.OpportunitySeg");        
        var oppSubSeg=component.get("v.OpportunitySubSeg");        
        var oppExisId=component.get("v.selectedRecord.Id");        
        var LdId = component.get("v.recordId");
		var ldoldAccId=component.get("v.Leads.Account_Id__c");
		var ldNewAccId=component.get("v.selectedAccRecord.Id");        
        var recordId = component.get("v.recordId");                                               
        var closeDate=component.get("v.closeDate"); 
        var ldAccountId=component.get("v.Leads.Account_Id__c");
        var createSec=component.get("v.IsCreate");
        var tagSec=component.get("v.IsTag");        
        var expCloseDate = component.find("expclosedate1");
        var todayDate = new Date();
        var todayDateOnly = new Date(todayDate.getUTCFullYear(),todayDate.getUTCMonth(),todayDate.getUTCDate());
        var expdate = new Date(closeDate);
        var expClsDateOnly = new Date(expdate.getUTCFullYear(),expdate.getUTCMonth(),expdate.getUTCDate());
        if(closeDate != null){
            if (expClsDateOnly <todayDateOnly){
            expCloseDate.set("v.errors", [{message:"Please select a Date in the future"}]);            
        } 
        	else {					
            	expCloseDate.set("v.errors", null);					
        	}	
        }                 
        if((ldoldAccId != null || ldNewAccId !=null) &&
        ((createSec && oppName !=null && oppdesc !=null && closeDate !=null && oppSeg!=null &&
          oppSubSeg !=null && oppSeg!='--- None ---' && oppSubSeg !='--- None ---'
           && expClsDateOnly >todayDateOnly) ||
        (tagSec && oppExisId !=null))){                        
            component.set("v.isSpinner", true); 
             var action = component.get("c.convertLead");                
             	if(ldNewAccId !=null){                                                            
            		action.setParams({
        			IsCreateOpp : createSec,
        			IsTagOpp : tagSec,
            		oppttyName : oppName,
            		oppttyDesc : oppdesc,
                    oppttySeg : oppSeg,
                    oppttySubseg : oppSubSeg,    
            		existingOppId : oppExisId,  
             		LeadId : LdId,
             		oppCloseDate:closeDate,
                    leadAccountId:ldNewAccId
   					});
                }
                else{                    
            		action.setParams({
        			IsCreateOpp : createSec,
        			IsTagOpp : tagSec,
            		oppttyName : oppName,
            		oppttyDesc : oppdesc,
                    oppttySeg : oppSeg,
                    oppttySubseg : oppSubSeg,
            		existingOppId : oppExisId,  
             		LeadId : LdId,
             		oppCloseDate:closeDate,
                    leadAccountId:ldoldAccId
   					});
                }                                
            	
        		action.setCallback(this, function(response){
            	var state = response.getState();
            	if (state === "SUCCESS"){                     
                	window.location.href = '/'+recordId;
                	                
            	}
                    else if(state === "ERROR"){
                       	console.log(response.getError());					
                    	var errors = response.getError();
                        component.set("v.custMessage", errors[0].message); 
                        if(errors[0] && errors[0].pageErrors) // To show DML exceptions
                    	component.set("v.custMessage", errors[0].pageErrors[0].message);
                    }
                    component.set("v.isSpinner", false);
                    component.set("v.isRequiredFlag", false);                	
        		});        
        		$A.enqueueAction(action);
            }                  
            else{                
                var OpptyName=component.find("text-input-id-1");
                var opptyDes=component.find("text-input-id-2");
                var opptyClsDate=component.find("expclosedate1");                
                var oppSegVal=component.find("master");
                var oppSubSegVal=component.find("slave");
                if(ldoldAccId == null && ldNewAccId ==null){            
    				component.set("v.isWarningFlag", true);
            		component.set("v.isSpinner", false);
				}
   				else{
            		component.set("v.isWarningFlag", false);
        		}
                if(!createSec && !tagSec){                    
    				component.set("v.isRequiredFlag", true);
                    component.set("v.isSpinner", false);
				}
                else{
                    component.set("v.isRequiredFlag", false);
                }
                if(createSec){ 
					component.set("v.isLookUpResult", false);                    
                    if(oppName==null){                        
                        OpptyName.set("v.errors", [{message:"You must enter a value"}]);
                    }
                    else {					
            			OpptyName.set("v.errors", null);					
        			}
                    if(oppdesc==null){
                        opptyDes.set("v.errors", [{message:"You must enter a value"}]);
                    }
                    else {					
            			opptyDes.set("v.errors", null);					
        			}
                    if(oppSeg==null || oppSeg=='--- None ---' ){
                        oppSegVal.set("v.errors", [{message:"You must Select a value"}]);
                    }
                    else {					
            			oppSegVal.set("v.errors", null);					
        			}
                    if(oppSubSeg==null || oppSubSeg =='--- None ---'){
                        oppSubSegVal.set("v.errors", [{message:"You must Select a value"}]);
                    }
                    else {					
            			oppSubSegVal.set("v.errors", null);					
        			}
                    if(closeDate==null){
                        opptyClsDate.set("v.errors", [{message:"You must enter a value"}]);
                    }                    
                }
                if(tagSec) {                    
                    if(oppExisId ==null){                       
                        component.set("v.isLookUpResult", true);
                    }
                    else{
                        component.set("v.isLookUpResult", false);	
                    }
                }
                
               component.set("v.isSpinner", false);                
            }                                                        
    },
    
//Restict user entering date value and request to use Date picker  
    restrictManualEntryOfCloseDate : function(component, event, helper){        
        var isCreateOpp=component.get("v.IsCreate");
        
        var closeDate;
        if(isCreateOpp){            
            closeDate=component.find("expclosedate1");                        
        }
        closeDate.set("v.errors", [{message:"Please select the date via Calendar icon"}]);
    },
    
    toggleVisibility : function(component, event, helper){	
		var ddDiv = component.find('AccsearchRes');
		$A.util.toggleClass(ddDiv,'slds-is-close');
	}
})