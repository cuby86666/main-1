/*
* Created By :  Stan Hsu
* For Release : 15.10 Hotfix
* For SIR :     #520
*/
@isTest(SeeAllData=true)     
public class ProductTriggerTest  
{
    public static void testProductTrigger()
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

        Id theStandardPricebookId = 
            [
                SELECT Id 
                From Pricebook2 
                WHERE IsStandard = true
            ].Id ;

        List<PricebookEntry> listTestPricebookEntries = 
            [
                SELECT Id, 
                    isActive, 
                    CurrencyIsoCode, 
                    Product2.Name, 
                    Product2.isActive
                FROM PricebookEntry
                WHERE Pricebook2Id = :theStandardPricebookId
                AND Product2.Name LIKE 'APEX TEST NEW PRODUCT%'
            ];

        System.assert( listTestPricebookEntries.size() >= 6 );

        if( listTestPricebookEntries.size() > 0 )
        {
            for( PricebookEntry loopPricebookEntry : listTestPricebookEntries )
            {
                if( loopPricebookEntry.Product2.isActive )
                {
                    System.assert( loopPricebookEntry.isActive == true );
                }
                else
                {
                    System.assert( loopPricebookEntry.isActive == false );
                }
            }
        }
        update listProduct2ToBeInserted;
    }
}