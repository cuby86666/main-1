/*
@Created By : 		Nisha Agrawal
@Created Date: 		03 Oct 2012
@Description: 		1. Trigger to Update Opportynity fields based on Products
					2. Trigger to update Opp Line Item Status based on Product					
*/

trigger AfterUpdate_Product on Product2 (after update) 
{
	if (ProductTrigger.IsFirstRun_AfterUpdate)
    {   
        ProductTrigger.updateOpportunityFields(Trigger.new, Trigger.old);
        
        //ProductTrigger.updateOpptyLineItemProductStatus(Trigger.newMap);
        
        ProductTrigger.IsFirstRun_AfterUpdate = false;
    }
}