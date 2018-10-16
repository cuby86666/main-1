({
	itemSelected : function(component, event, helper) {
        var target = event.target;
        var selIndex = helper.getIndexFrmParent(target,helper,"data-selectedIndex");  
        console.log("selIndex"+selIndex);
        if(selIndex){
            var serverResult = component.get("v.searchResult");
            
            var selItem = serverResult[selIndex];
            console.log("selected item"+selItem.itemText);
            if(selItem.itemText){
               component.set("v.selContact",selItem);
               component.set("v.prevSearchResult",serverResult);
            } 
            component.set("v.searchResult",null);
        } 		
	},
    searchContacts :  function(component, event, helper) {
        var target = event.target;  
        var searchText = target.value; 
		var prevSearchText = component.get("v.prevSearchText");
        if (event.keyCode == 27 || !searchText.trim()) { 
            helper.clearSelection(component, event, helper);
        }else if(searchText.trim() != prevSearchText  && searchText.trim().length >3 ){
            var limit = component.get("v.limit");
            var action = component.get("c.searchContactsInSF");
            //action.setStorable();
            action.setParams({
                searchText : searchText,
                numOfResults : limit
            });
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);    
            });
            component.set("v.prevSearchText",searchText.trim());
            console.log("search contacts called");
            $A.enqueueAction(action);
        }else if(searchText && prevSearchText && searchText.trim() == prevSearchText.trim()){
            component.set("v.searchResult",component.get("v.prevSearchText"));
            console.log("search result saved");
        }        
    },
    handleResponse : function (res,component,helper){
        console.log("search return -- "+res.getState());
        if(res.getState()=='SUCCESS'){
            var retObj = JSON.parse(res.getReturnValue());
            console.log("results of search -- "+res.getReturnValue());
            if(retObj.length <= 0){
            	var noResult = JSON.parse('[{"itemText":"No Results Found"}]');
                component.set("v.searchResult",noResult);
                component.set("v.prevSearchResult",noResult);
            }else{
                component.set("v.searchResult",retObj);
                component.set("v.prevSearchResult",retObj);                
            }
        }else if(res.getState() === 'ERROR'){
 			var errors = res.getError();
            if(errors){
                if (errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                    var errorResult = JSON.parse('[{"itemText":"'+errors[0].message+'"}]');
                    component.set("v.searchResult",retObj);
                }                
            }            
        }    
    },
    getIndexFrmParent : function(target,helper,attributeToFind){
        //User can click on any child element, so traverse till intended parent found
        var SelIndex = target.getAttribute(attributeToFind);
        while(!SelIndex){
            target = target.parentNode ;
			SelIndex = helper.getIndexFrmParent(target,helper,attributeToFind);           
        }
        return SelIndex;
    },    
    clearSelection: function(component, event, helper){
        component.set("v.selContact",null);
        component.set("v.searchResult",null);
    } 
})