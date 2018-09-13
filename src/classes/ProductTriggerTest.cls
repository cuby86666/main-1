/*
* Created By :  Stan Hsu
* For Release : 15.10 Hotfix
* For SIR :     #520
*/
@isTest     
private class ProductTriggerTest  
{
    @isTest
    static void testProductTrigger()
    {
        List<Product2> listProduct2ToBeInserted = new List<Product2>();
        
        Product2 testNewActiveProduct = new Product2
            (
                isActive = true,
                Name = 'APEX TEST NEW PRODUCT ACTIVE'
            );
        listProduct2ToBeInserted.add( testNewActiveProduct );

        Product2 testNewInactiveProduct = new Product2
            (
                isActive = false,
                Name = 'APEX TEST NEW PRODUCT INACTIVE'
            );
        listProduct2ToBeInserted.add( testNewInactiveProduct );
        
        test.startTest();
        insert listProduct2ToBeInserted;
        test.stopTest();

        List<PricebookEntry> listTestPricebookEntries = 
            [
                SELECT Id, 
                    isActive, 
                    CurrencyIsoCode, 
                    Product2.Name, 
                    Product2.isActive
                FROM PricebookEntry
                WHERE Pricebook2Id = :Test.getStandardPricebookId()
                AND Product2.Name LIKE 'APEX TEST NEW PRODUCT%'
            ];

		System.assert(listTestPricebookEntries.size() > 0);
        
        update listProduct2ToBeInserted;
    }
}