/*
@Created By :       Nisha Agrawal
@Created Date:      03 Jan 2012
@Description:       Test Class for Controller class EditAllERebateProductsControllerTest
*/
/*
@Modified By :       Balaji Gunasekaran
@Modified Date:      21 May 2015
@Description:       As Part of CACC code impact analysis LineItem#25 
                    - Replaced CACC code object with Consolidated Account Code object and replaced field Consolidate_Code_Description__c with Consolidated_Account_Code_Description__c
*/
@isTest
private class EditAllERebateProductsControllerTest 
{
    @isTest(SeeAllData=true)
    static void EditAllERebateProductsControllerTest1() 
    {
        //prepare test data
        //fetch the Rebate Currency
        List<FX_Rates__c> lstRates = [Select Id , Name From FX_Rates__c Where Name = 'USD' Limit 1];
        FX_Rates__c rebateCurrency;
        
        if(lstRates.size() > 0)
        {
            rebateCurrency = lstRates[0];           
        }
        else
        {
            rebateCurrency = new FX_Rates__c(Name = 'USD' , Currency_Code__c = 'USD');
            insert rebateCurrency;
            
            system.assert(rebateCurrency.Id != null);
        }
        
        //insert Consolidated Account code
        Consolidated_Account_Code__c objCACC = new Consolidated_Account_Code__c();
        objCACC.Code_Description__c='123';
        insert objCACC;
        system.assert(objCACC.Id != null);
                
        eRebate__c objeRebate = new eRebate__c(Rebate_Program_Name__c = 'unittest_program' , End_Customer__c ='unittest_endcustomer', Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD', Consolidated_Account_Code_Description__c= objCACC.Id);
        
        insert objeRebate;
        system.assert(objeRebate.Id != null);
        
        integer numOfERebateLines = 10;
        integer i;
        
        //insert products
        List<Product2> lstProducts = new List<Product2>();
        Product2 objProduct;
        
        for(i =0; i < numOfERebateLines ;  i++)
        {
            objProduct = new Product2(Name = 'unittest_product' + i);
            lstProducts.add(objProduct);
        }
        insert lstProducts;
        
        //assert products
        
        for(Product2 p : lstProducts)
        {
            system.assert(p.Id != null);
        }
                
        List<eRebate_Product__c> eRebateLines = new List<eRebate_Product__c>();
        eRebate_Product__c objRebateLine;
        
        for(i =0; i < numOfERebateLines ;  i++)
        {
            objRebateLine = new eRebate_Product__c( eRebate__c = objeRebate.Id , Price_Gap__c = (i * 10.0) , Quantity__c = 5, Product__c = lstProducts[i].Id);
            eRebateLines.add(objRebateLine);
        }
        
        insert eRebateLines;
        
        //assert eRebate products
        
        for(eRebate_Product__c rebateProduct : eRebateLines)
        {
            system.assert(rebateProduct.Id != null);
        }
        
        //start the test
        Test.startTest();
        
        PageReference pgRef = Page.EditAllERebateProducts;
        pgRef.getParameters().put('Id', objeRebate.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController controller = new Apexpages.StandardSetController(eRebateLines);
        EditAllERebateProductsController extension = new EditAllERebateProductsController(controller);
        
        system.assert(extension.objERebate.Id == objeRebate.Id);
        system.assert(extension.lsteRebateLines.size() > 0);
        system.assert(extension.lsteRebateLines.size() == numOfERebateLines);
        
        for(eRebate_Product__c rebateProduct : extension.lsteRebateLines)
        {
            rebateProduct.Line_Description__c = 'test';
            rebateProduct.Quantity__c = 2;
            rebateProduct.Price_Gap__c = 200;
        }
        
        //invoke saveProducts method        
        
        PageReference pgRedirect = extension.saveProducts();
        
        //assert the results
        system.assert(pgRedirect != null);
        system.assert(pgRedirect.getUrl() == '/' + objeRebate.Id);
        
        eRebateLines = [Select Id , Product__c, Price_Gap__c, Line_Description__c , Quantity__c
                        From eRebate_Product__c
                        Where eRebate__c =: objERebate.Id];
        
        system.assert(eRebateLines.size() > 0);
        system.assert(eRebateLines.size() == numOfERebateLines);
                
        for(eRebate_Product__c rebateProduct : eRebateLines)
        {
            system.assert(rebateProduct.Line_Description__c == 'test');
            system.assert(rebateProduct.Quantity__c == 2);
            system.assert(rebateProduct.Price_Gap__c == 200);
        }
        
        //stop the test
        Test.stopTest();        
    }
}