/*
@Created By : 		Nisha Agrawal
@Created Date: 		03 Oct 2012
@Description: 		Trigger to insert entry into Standard PriceBook for new Products
					
*/

trigger AfterInsert_Product on Product2 (after insert) 
{
	if (ProductTrigger.IsFirstRun_AfterInsert)
    {   
    	//insert Pricebook Entry for new Products
        ProductTrigger.insertProductIntoStandardPB(Trigger.New);
        
        ProductTrigger.IsFirstRun_AfterInsert = false;
    }
	
}