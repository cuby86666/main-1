/*
@Created By :       Nisha Agrawal
@Created Date:      02 Jan 2013
@Description:       Test Class for Controller class AddERebateProductController
*/

/*
@Modified By :       Balaji Gunasekaran
@Modified Date:      20 May 2015
@Description:       As Part of CACC code impact analysis LineItem#21 
                    - Replaced CACC code object with Consolidated Account Code object and replaced field Consolidate_Code_Description__c with Consolidated_Account_Code_Description__c
*/

/*
@Created By :       Nisha Agrawal
@Created Date:      02 Jan 2013
@Description:       Test Class for Controller class AddERebateProductController
*/

/*
@Modified By :       Balaji Gunasekaran
@Modified Date:      20 May 2015
@Description:       As Part of CACC code impact analysis LineItem#21 
                    - Replaced CACC code object with Consolidated Account Code object and replaced field Consolidate_Code_Description__c with Consolidated_Account_Code_Description__c
*/

/*
@Modified By :       Scarlett Kang
@Modified Date:      16 Nov 2015
@Description:       Modified for changing Sales item, Sales Item must be unique
*/

@isTest(SeeAllData=true)
private class AddERebateProductControllerTest 
{

    static testMethod void AddERebateProductControllerTest1() 
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
                
        eRebate__c objeRebate = new eRebate__c(Rebate_Program_Name__c = 'unittest_program' , End_Customer__c ='unittest_endcustomer', Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD',  Consolidated_Account_Code_Description__c = objCACC.Id);
        insert objeRebate;
        system.assert(objeRebate.Id != null);
        
        integer numOfProducts = 100;
        integer i;
        
        //insert products
        List<Product2> lstProducts = new List<Product2>();
        Product2 objProduct;
        
        for(i =0; i < numOfProducts ;  i++)
        {
            objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut_mag' + i, isActive = true);
            lstProducts.add(objProduct);
        }
        insert lstProducts;
        
        //assert products       
        for(Product2 p : lstProducts)
        {
            system.assert(p.Id != null);
        }
        
        List<eRebate_Product__c> eRebateLines = new List<eRebate_Product__c>();
        
        //start the Test
        Test.startTest();
        
        PageReference pgRef = Page.AddERebateProduct;
        pgRef.getParameters().put('Id', objeRebate.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController controller = new Apexpages.StandardSetController(eRebateLines);
        AddERebateProductController extension = new AddERebateProductController(controller);
        
        system.assert(extension.objERebate.Id == objeRebate.Id);
        system.assert(extension.lstResults != null);
        system.assert(extension.lstResults.size() > 0);
        system.assert(extension.total_size >= numOfProducts); //due to See All Data true        
        system.assert(!extension.isStep2);
        
        //stop the Test
        Test.stopTest();
    }
    
    /*************************************************************************
                    CASE - SEARCH PRODUCTS - Filter without Price
    **************************************************************************/
    
    static testmethod void AddERebateProductControllerTest2() 
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
                
        eRebate__c objeRebate = new eRebate__c(Rebate_Program_Name__c = 'unittest_program' , End_Customer__c ='unittest_endcustomer', Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD',  Consolidated_Account_Code_Description__c = objCACC.Id);
        insert objeRebate;
        system.assert(objeRebate.Id != null);
        
        integer numOfProducts = 50;
        integer i;
        
        //insert products
        List<Product2> lstProducts = new List<Product2>();
        Product2 objProduct;
        
        for(i =0; i < numOfProducts ;  i++)
        {
            /***Modified by Scarlett on Nov 16***/
            objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut_mag' + i, Sales_Item__c = 'ut_SI' + i , isActive = true);
			/***Modified by Scarlett on Nov 16 - END***/
            lstProducts.add(objProduct);
        }
        insert lstProducts;
        
        //assert products       
        for(Product2 p : lstProducts)
        {
            system.assert(p.Id != null);
        }
        
        List<eRebate_Product__c> eRebateLines = new List<eRebate_Product__c>();
        
        //start the Test
        Test.startTest();
        
        PageReference pgRef = Page.AddERebateProduct;
        pgRef.getParameters().put('Id', objeRebate.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController controller = new Apexpages.StandardSetController(eRebateLines);
        AddERebateProductController extension = new AddERebateProductController(controller);
                        
        //invoke searchProducts
        extension.searchProducts();
        
        List<AddERebateProductController.SearchResult> lstActualResult = extension.lstResults;
        
        System.assert(Apexpages.hasMessages(ApexPages.severity.Error));
        List<Apexpages.Message> lstMessages = ApexPages.getMessages();
        System.assert(lstMessages[0].getSummary() == AddERebateProductController.NO_SEARCH_CRITERIA_ERROR);
        
        //Set some filter 
        extension.ProductName = 'ut';
        extension.ProductCode = 'ut';
        extension.SalesItem = 'ut';
        extension.MAG = 'ut';
        
        //invoke searchProducts
        extension.searchProducts();
        
        lstActualResult = extension.lstResults;
        system.assert(extension.foundResult);
        
        //invoke clearResults method
        extension.clearResults();
        system.assert(extension.ProductName == '');
        system.assert(extension.ProductCode == '');
        system.assert(extension.SalesItem == '');
        system.assert(extension.MAG == '');
        system.assert(extension.filterId == '0');
               
        //stop the Test
        Test.stopTest();
    }
    
    /*************************************************************************
                    CASE - SEARCH PRODUCTS - Unit Price Filter
    **************************************************************************/
    static testmethod void AddERebateProductControllerTest3() 
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
               
        eRebate__c objeRebate = new eRebate__c(Rebate_Program_Name__c = 'unittest_program' , End_Customer__c ='unittest_endcustomer', Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD' ,  Consolidated_Account_Code_Description__c = objCACC.Id);
        insert objeRebate;
        system.assert(objeRebate.Id != null);
        
        integer numOfProducts = 50;
        integer i;
        
        //insert products
        List<Product2> lstProducts = new List<Product2>();
        Product2 objProduct;
        
        for(i =0; i < numOfProducts ;  i++)
        {
            objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut_mag' + i, isActive = true);
            lstProducts.add(objProduct);
        }
        insert lstProducts;
        
        //assert products       
        for(Product2 p : lstProducts)
        {
            system.assert(p.Id != null);
        }
        
        List<eRebate_Product__c> eRebateLines = new List<eRebate_Product__c>();
        
        //start the Test
        Test.startTest();
        
        PageReference pgRef = Page.AddERebateProduct;
        pgRef.getParameters().put('Id', objeRebate.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController controller = new Apexpages.StandardSetController(eRebateLines);
        AddERebateProductController extension = new AddERebateProductController(controller);
        
        //Set Price Filter
        extension.filterId = '1';
        extension.filterPrice = '5';
        
        //invoke searchProducts
        extension.searchProducts();
        
        List<AddERebateProductController.SearchResult> lstActualResult = extension.lstResults;
        
        extension.filterId = '2';
        extension.searchProducts();
        
        extension.filterId = '3';
        extension.filterPrice = '0';
        extension.searchProducts();
        
        extension.filterId = '4';
        extension.filterPrice = '5';
        extension.searchProducts();
              
        extension.filterId = '5';
        extension.filterPrice = '-1';
        extension.searchProducts();
        
        extension.filterId = '6';
        extension.filterPrice = '5';
        extension.searchProducts();
           
        //stop the Test
        Test.stopTest();
    }
    
    /*************************************************************************
                    CASE - SEARCH PRODUCTS - SAVE LINE ITEMS
    **************************************************************************/
    
    static testmethod void AddERebateProductControllerTest4() 
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
                
        eRebate__c objeRebate = new eRebate__c(Rebate_Program_Name__c = 'unittest_program' , End_Customer__c ='unittest_endcustomer', Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD',  Consolidated_Account_Code_Description__c = objCACC.Id);
        insert objeRebate;
        system.assert(objeRebate.Id != null);
        
        integer numOfProducts = 50;
        integer i;
        
        //insert products
        List<Product2> lstProducts = new List<Product2>();
        Product2 objProduct;
        
        for(i =0; i < numOfProducts ;  i++)
        {
            /***Modified by Scarlett on Nov 16***/
            objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut_mag' + i, Sales_Item__c = 'ut_SI' + i, isActive = true);
            /***Modified by Scarlett on Nov 16 - END***/
            lstProducts.add(objProduct);
        }
        insert lstProducts;
        
        //assert products       
        for(Product2 p : lstProducts)
        {
            system.assert(p.Id != null);
        }
        
        List<eRebate_Product__c> eRebateLines = new List<eRebate_Product__c>();
        
        //start the Test
        Test.startTest();
        
        PageReference pgRef = Page.AddERebateProduct;
        pgRef.getParameters().put('Id', objeRebate.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController controller = new Apexpages.StandardSetController(eRebateLines);
        AddERebateProductController extension = new AddERebateProductController(controller);
                        
        //Set some filter 
        extension.ProductName = 'ut';
        extension.ProductCode = 'ut';
        extension.SalesItem = 'ut';
        extension.MAG = 'ut';
        
        //invoke searchProducts
        extension.searchProducts();
        
        List<AddERebateProductController.SearchResult> lstActualResult = extension.lstResults;
        system.assert(extension.foundResult);
                
        //invoke processSelectedProducts
        extension.processSelectedProducts();
        System.assert(Apexpages.hasMessages(ApexPages.severity.Error));
        List<Apexpages.Message> lstMessages = ApexPages.getMessages();
        system.assert(lstMessages[0].getSummary() == AddERebateProductController.SELECT_PRODUCT_TO_ADD_ERROR);
         
        //select some products
        for(i=0; i < lstActualResult.size(); i=i+5)
        {
            lstActualResult[i].IsSelected = true;
        }
        
        //invoke processSelectedProducts
        extension.processSelectedProducts();
        
        system.assert(extension.isStep2);
        system.assert(extension.lsteRebateLines != null);
        system.assert(extension.lsteRebateLines.size() > 0);
        
        //invoke saveProducts method
        PageReference resultPage = extension.saveProducts();
        system.assert(resultPage != null);
        system.assert(resultPage.getUrl().contains(objeRebate.Id));
        
        //stop the Test
        Test.stopTest();
    }
    
    /*************************************************************************
                    CASE - SEARCH PRODUCTS - SAVE MORE PRODUCTS
    **************************************************************************/
    
    static testmethod void AddERebateProductControllerTest5() 
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
                
        eRebate__c objeRebate = new eRebate__c(Rebate_Program_Name__c = 'unittest_program' , End_Customer__c ='unittest_endcustomer', Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD',  Consolidated_Account_Code_Description__c = objCACC.Id);
        insert objeRebate;
        system.assert(objeRebate.Id != null);
        
        integer numOfProducts = 30;
        integer i;
        
        //insert products
        List<Product2> lstProducts = new List<Product2>();
        Product2 objProduct;
        
        for(i =0; i < numOfProducts ;  i++)
        {
            /***Modified by Scarlett on Nov 16***/
            objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut_mag' + i, Sales_Item__c = 'ut_SI' + i, isActive = true);
            /***Modified by Scarlett on Nov 16 - END***/
            lstProducts.add(objProduct);
        }
        insert lstProducts;
        
        //assert products       
        for(Product2 p : lstProducts)
        {
            system.assert(p.Id != null);
        }
        
        List<eRebate_Product__c> eRebateLines = new List<eRebate_Product__c>();
        
        //start the Test
        Test.startTest();
        
        PageReference pgRef = Page.AddERebateProduct;
        pgRef.getParameters().put('Id', objeRebate.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController controller = new Apexpages.StandardSetController(eRebateLines);
        AddERebateProductController extension = new AddERebateProductController(controller);
                        
        //Set some filter 
        extension.ProductName = 'ut';
        extension.ProductCode = 'ut';
        extension.SalesItem = 'ut';
        extension.MAG = 'ut';
        
        //invoke searchProducts
        extension.searchProducts();
        
        List<AddERebateProductController.SearchResult> lstActualResult = extension.lstResults;
		system.assert(extension.foundResult);
                
        //select some products
        for(i=0; i < lstActualResult.size(); i=i+5)
        {
            lstActualResult[i].IsSelected = true;
        }
        
        //invoke processSelectedProducts
        extension.processSelectedProducts();
        
        system.assert(extension.isStep2);
        system.assert(extension.lsteRebateLines != null);
        system.assert(extension.lsteRebateLines.size() > 0);
        
        //invoke saveProducts method
        extension.saveMoreProducts();
        system.assert(!extension.isStep2);
        system.assert(extension.lsteRebateLines == null);
        
        //stop the Test
        Test.stopTest();
    }
    
    /*************************************************************************
                    CASE - PAGER & ALPHABETICAL FILTERS
    **************************************************************************/
    
    static testmethod void AddERebateProductControllerTest6() 
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
               
        eRebate__c objeRebate = new eRebate__c(Rebate_Program_Name__c = 'unittest_program' , End_Customer__c ='unittest_endcustomer', Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD' ,  Consolidated_Account_Code_Description__c = objCACC.Id);
        insert objeRebate;
        system.assert(objeRebate.Id != null);
        
        integer numOfProducts = 100;
        integer i;
        
        //insert products
        List<Product2> lstProducts = new List<Product2>();
        Product2 objProduct;
        
        for(i =0; i < numOfProducts ;  i++)
        {
            objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut_mag' + i, isActive = true);
            lstProducts.add(objProduct);
        }
        insert lstProducts;
        
        //assert products       
        for(Product2 p : lstProducts)
        {
            system.assert(p.Id != null);
        }
        
        List<eRebate_Product__c> eRebateLines = new List<eRebate_Product__c>();
        
        //start the Test
        Test.startTest();
        
        PageReference pgRef = Page.AddERebateProduct;
        pgRef.getParameters().put('Id', objeRebate.Id);
        
        Test.setCurrentPageReference(pgRef);
        
        ApexPages.StandardSetController controller = new Apexpages.StandardSetController(eRebateLines);
        AddERebateProductController extension = new AddERebateProductController(controller);
        
        List<AddERebateProductController.SearchResult> lstActualResult = extension.lstResults;
        
        system.assert(extension.objERebate.Id == objeRebate.Id);
        system.assert(lstActualResult != null);
        system.assert(lstActualResult.size() > 0);
        system.assert(extension.foundResult);
        
        Boolean disablePrevious = extension.getDisablePrevious();
        system.assert(disablePrevious == true);
        
        Boolean disableNext = extension.getDisableNext();
        system.assert(disableNext == false);
        
        integer pageNo = extension.getPageNumber();
        system.assert(pageNo == 1);
        
        integer totalSize = extension.getTotal_size();
        system.assert(extension.total_size >= numOfProducts); //due to See All Data true
        
        integer totalPages = extension.getTotalPages();
         
        Boolean disableLast = extension.getDisableLast();
        system.assert(disableLast == (totalPages * 10 > 2000 ? true : false));
        
        extension.next();
        
        disablePrevious = extension.getDisablePrevious();
        system.assert(disablePrevious == false);
        
        //select some products
        for(i=0; i < lstActualResult.size(); i=i+5)
        {
            lstActualResult[i].IsSelected = true;
        }
        
        extension.first();
        
        if(!disableLast)
        {
            extension.last();
            disableNext = extension.getDisableNext();
            system.assert(disableNext == true);
        }
        
        for(i=0; i < lstActualResult.size(); i = i+10)
        {
            lstActualResult[i].IsSelected = false;
        }
            
        extension.alphaFilter = 't';
        extension.filterByAlphabets();
                
        extension.alphaFilter = 'u';
        extension.filterByAlphabets();
        
        totalPages = extension.getTotalPages();
        
        if(extension.lstResults.size() > 0)
        {
            disableLast = extension.getDisableLast();
            system.assert(disableLast == (totalPages * 10 > 2000 ? true : false));
            
            if(!disableLast)
            {
                extension.last();
                disableNext = extension.getDisableNext();
                system.assert(disableNext == true);
                
                extension.previous();
            }   
        }   
        //stop the Test
        Test.stopTest();    
    }    
}