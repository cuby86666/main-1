({
	init: function(cmp, event, helper) {
        cmp.set("v.columns", [
            {label: "Opportunity", fieldName: "opptyUrl", type: "url", typeAttributes: {label: {fieldName: "opptyName"}, tooltip: {fieldName: "opptyName"}, target: "_blank"}},
            {label: "Product", fieldName: "opptyProdUrl", type: "url", typeAttributes: {label: {fieldName: "prodName"}, tooltip: {fieldName: "prodName"}, target: "_blank"}},
            /*{label: "Price", fieldName: "price", type: "currency", typeAttributes: {currencyCode: {fieldName: "ccyCode"}, currencyDisplayAs: "code"}, editable: "true"},*/
            {label: "Currency", fieldName: "ccyCode", type: "text"},
            {label: "Price", fieldName: "price", type: "number", typeAttributes: {maximumFractionDigits: "6"}, editable: "true"},
            {label: "Price Erosion Rate", fieldName: "priceErosionRate", type: "percent", editable: "true"},
            {label: "Qty per Sys", fieldName: "qtyPerSys", type: "number", editable: "true"},
            {label: "Share", fieldName: "share", type: "percent", editable: "true"},
            {label: "Help Needed", fieldName: "helpNeeded", type: "text", editable: "true"}
        ]);
        
        helper.getOpportunityProducts(cmp);
    },
    
    handleSave: function(cmp, event, helper) {
    	helper.updateOpportunityProducts(cmp, event);
    }
})