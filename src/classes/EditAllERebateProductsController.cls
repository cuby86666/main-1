/*
@Created By :       Nisha Agrawal
@Created Date:      01 Nov 2012
@Description:       Controller class for VF page EditAllERebateProducts
*/

public with sharing class EditAllERebateProductsController 
{
	public eRebate__c  objERebate {get; set;}
	public List<eRebate_Product__c> lsteRebateLines {get; set;}
	 
	public EditAllERebateProductsController(ApexPages.StandardSetController controller) 
    {
    	if(ApexPages.currentPage().getParameters()!=null && ApexPages.currentPage().getParameters().get('id')!=null) 
        {
			objERebate = [Select Id , Name , CurrencyIsoCode From eRebate__c Where Id=:ApexPages.currentPage().getParameters().get('id') Limit 1];
			
			lsteRebateLines = [Select Id , Product__c,  Product__r.Name , Price_Gap__c , Real_Cost_in_Rebate_Currency__c , Line_Description__c , Quantity__c 
								From eRebate_Product__c
								Where eRebate__c =: objERebate.Id
								Limit 50];
        }    
    }
    
    public PageReference saveProducts()
    {
    	PageReference pgRef;
    	try
    	{
    		if(lsteRebateLines.size() > 0)
    		{
    			update lsteRebateLines;
    		} 
    		pgRef = new PageReference('/' + objERebate.Id);    		
    	}
    	catch(System.DMLException ex )
    	{
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
    	}
    	
    	return pgRef;    	
    }

}