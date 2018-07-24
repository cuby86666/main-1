/******************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      04 Jan 2013
@Description:       Test Class for Trigger AfterTrigger_RebateProduct
-------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date :    20 Mar 2013
@Description :      test method added to test BU updates on Rebate from Rebate Products
---------------------------------------------------------------------------------------
@Modified By :       Balaji Gunasekaran
@Modified Date:      21 May 2015
@Description:       As Part of CACC code impact analysis LineItem#22 
                    - Replaced CACC code object with Consolidated Account Code object and replaced field Consolidate_Code_Description__c with Consolidated_Account_Code_Description__c
-------------------------------------------------------------------------------
@Modified By :      Scarlett Kang
@Modified Date :    13 Aug 2015
@Description :      test method revised for data structure adjustment               
-------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date :    May 10, 2018
@Description :      test method updated as per change in approval flow for Regional Channel Controller
					and remove seeAllData = true annotation
****************************************************************************************/

@isTest
private class AfterTrigger_RebateProductTest
{
    //1508 Release - Modified by Scarlett on 2015.08.13
    private static final String TYPE_OEM_EMS = 'OEM_EMS'; // Object: Rebate
    private static final String TYPE_OEM_EMS_Rebate_Product = 'OEM_EMS_Rebate_Product'; // Object: Rebate Product
    
    private static RecordType OEM_EMS;
    private static RecordType OEM_EMS_Rebate_Product;
    
    private static void fetchRecordType(){
        for(RecordType rt: [SELECT  Id, DeveloperName 
                            FROM    RecordType 
                            WHERE IsActive = TRUE AND (
                            SobjectType = 'eRebate__c' or SobjectType = 'Rebate_Product__c')
                            ])
        {
            if(rt.DeveloperName == TYPE_OEM_EMS)                
                OEM_EMS = rt;
            if(rt.DeveloperName == TYPE_OEM_EMS_Rebate_Product)
                OEM_EMS_Rebate_Product = rt;
        }
    }
    /**************************************************
        CASE - With apttus aggrement    
    ***************************************************/
    static testMethod void AfterTrigger_RebateProductTest1() 
    {
        //prepare test data
        //1508 Release - Modified by Scarlett on 2015.08.13
        fetchRecordType();
        //1508 Release - Modified by Scarlett on 2015.08.13
        
        //insert approver users
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            List<User> lstApprovers = TestUtil.createTestUsers(objProfile.Id, 18);
            insert lstApprovers;
            for(User objUser : lstApprovers)
            {
                system.assert(objUser.Id != null);
            }
            
            User objApttusChecker = lstApprovers[0];            
            User objLegal = lstApprovers[1];
            User objCorpCotrol = lstApprovers[2];
            User objGlobalSalesOPS = lstApprovers[3];
            User objRegionalController = lstApprovers[4];
            User objRegionalChannelController = lstApprovers[5];
            User objGlobalChannelController = lstApprovers[6];
            User objRegionalDistiManager = lstApprovers[7];
            User objRegionalSalesManager  = lstApprovers[8];
            User objGSMController = lstApprovers[9];
                        
            system.assert(objApttusChecker.Id != null);                        
            system.assert(objLegal.Id != null);
            system.assert(objCorpCotrol.Id != null);
            system.assert(objGlobalSalesOPS.Id != null);
            system.assert(objRegionalController.Id != null);
            system.assert(objRegionalChannelController.Id != null);            
            system.assert(objGlobalChannelController.Id != null);
            system.assert(objRegionalDistiManager.Id != null);
            system.assert(objRegionalSalesManager.Id != null);
            system.assert(objGSMController.Id != null);            
     
            integer numOfProducts = 8;
            integer i;
            
            //insert products
            List<Product2> lstProducts = new List<Product2>();
            Product2 objProduct;
            
            for(i =0; i < numOfProducts ;  i++)
            {
                objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut' + i, isActive = true);
                lstProducts.add(objProduct);
            }
            insert lstProducts;
            
            //assert products       
            for(Product2 p : lstProducts)
            {
                system.assert(p.Id != null);
            }
                 
            //insert approver matrix
            List<Rebate_Approver_Matrix__c> lstRebateApprovers = new List<Rebate_Approver_Matrix__c>();
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Apttus Aggrement Checker' , Approver__c = objApttusChecker.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Legal' , Approver__c = objLegal.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Corporate Control' , Approver__c = objCorpCotrol.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Sales & OPS Manager' , Approver__c = objGlobalSalesOPS.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Controller' , Approver__c = objRegionalController.Id));           
            //Modified by Nisha Agrawal on May 10, 2018 for approval flow change
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA', Program_Type__c = 'Distribution ODM Fullfillment' , Role__c = 'Regional Channel Controller' , Approver__c = objRegionalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Channel Controller' , Approver__c = objGlobalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Disti Manager' , Approver__c = objRegionalDistiManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Sales Manager' , Approver__c = objRegionalSalesManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'GSM Controller' , Approver__c = objGSMController.Id));
                
            //insert MAG Approvers              
            for(i =0; i < numOfProducts ;  i++)
            {
                lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'BL Marketing Manager', MAG__c = 'ut' + i , Approver__c = lstApprovers[i + 10].Id));
            }
            insert lstRebateApprovers;
            
            for(Rebate_Approver_Matrix__c objApprover : lstRebateApprovers)
            {
                system.assert(objApprover.Id != null);
            }
            
            //insert FX_Rates       
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
            
            //insert eRebate
            //1508 Release - Modified by Scarlett on 2015.08.13
            eRebate__c objRebate = new eRebate__c(
                Rebate_Program_Name__c = 'ut_program' , 
                Sales_Channel__c = 'OEM',  
                End_Customer__c ='ut_endcustomer', 
                Rebate_End_Date__c = date.today().addDays(30) , 
                Rebate_Effective_Date__c = date.today() , 
                Sales_Region__c = 'EMEA' , 
                Rebate_Currency__c = rebateCurrency.Id,  
                CurrencyIsoCode = 'USD', 
                Red_Flag__c = 'YES', 
                Material_Limitations_to_do_Business__c = true, 
                Consolidated_Account_Code_Description__c = objCACC.Id, 
                Capped_Payout_USD__c = 60000000, 
                Apttus_Agreement__c = true, 
                Apttus_Agreement_Number__c ='1234', 
                Industry_Segment__c = 'Test', 
                Programe_Type__c = 'OEM / EMS',
                RecordType = OEM_EMS
            );
            //1508 Release - Modified by Scarlett on 2015.08.13
            insert objRebate;
            system.assert(objRebate.Id != null);
                        
            //start the Test        
            Test.startTest();
            
            //insert Rebate Products
            List<eRebate_Product__c> lstRebateLines = new List<eRebate_Product__c>();
            
            for(i=0; i < numOfProducts ;  i++)
            {
                //1508 Release - Modified by Scarlett on 2015.08.13
                /****
                New fields created and remodify formula for calculating Total Estimated Rebate Amount
                Estimated Rebate Amount = (Booking Cost- Actual Cost) * Quantity
                ****/
                lstRebateLines.add(
                    new eRebate_Product__c( 
                        eRebate__c = objRebate.Id , 
                        Price_Gap__c = (i * 10.0) , 
                        //Scarlett Quantity__c = 5, 
                        Quantity__c = 1000000,
                        Product__c = lstProducts[i].Id,
                        RecordType = OEM_EMS_Rebate_Product,
                        Booking_Cost__c = 5.25,
                        Actual_Cost__c = 0.25
                    )
                );
                //1508 Release - Modified by Scarlett on 2015.08.13
            }
        
            insert lstRebateLines;
            
            //assert the result
            
            objRebate = [Select Id , Apttus_Rebate_Checker__c, Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
            
            //apttus agreement checker - not null
            system.assert(objRebate.Apttus_Rebate_Checker__c != null);
            //system.assert(objRebate.Apttus_Rebate_Checker__c == objApttusChecker.Id); //- need this assertion
            
            //other approver should be null
            system.assert(objRebate.Legal__c == null);
            system.assert(objRebate.Corporate_Controller__c == null);
            system.assert(objRebate.Global_Sales_OPS_Manager__c == null);
            system.assert(objRebate.Regional_Controller__c == null);
            system.assert(objRebate.Regional_Channel_Controller__c == null);
            system.assert(objRebate.Global_Channel_Controller__c == null);
            system.assert(objRebate.Regional_Disti_Manager__c == null);
            system.assert(objRebate.Regional_Sales_Manager__c == null);
            system.assert(objRebate.GSM_Controller__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_1__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c == null);
            
            //update the Rebate Product         
            for(eRebate_Product__c rebateProduct : lstRebateLines)
            {
                rebateProduct.Line_Description__c = 'test';
                rebateProduct.Quantity__c = 2000;
                rebateProduct.Price_Gap__c = 800;
            }

            update lstRebateLines;

            //assert the result
             objRebate = [Select Id , Apttus_Rebate_Checker__c, Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
                        
            //apttus agreement checker - not null
            system.assert(objRebate.Apttus_Rebate_Checker__c != null);
            //system.assert(objRebate.Apttus_Rebate_Checker__c == objApttusChecker.Id); //- need this assertion
            
            //other approver should be null
            system.assert(objRebate.Legal__c == null);
            system.assert(objRebate.Corporate_Controller__c == null);
            system.assert(objRebate.Global_Sales_OPS_Manager__c == null);
            system.assert(objRebate.Regional_Controller__c == null);
            system.assert(objRebate.Regional_Channel_Controller__c == null);
            system.assert(objRebate.Global_Channel_Controller__c == null);
            system.assert(objRebate.Regional_Disti_Manager__c == null);
            system.assert(objRebate.Regional_Sales_Manager__c == null);
            system.assert(objRebate.GSM_Controller__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_1__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c == null);
            
            //delete the Rebate Product
            delete lstRebateLines;
            
            //assert the result
            
            objRebate = [Select Id , Apttus_Rebate_Checker__c, Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
            
            //apttus agreement checker - not null
            system.assert(objRebate.Apttus_Rebate_Checker__c != null);
            //system.assert(objRebate.Apttus_Rebate_Checker__c == objApttusChecker.Id); //- need this assertion
            
            //other approver should be null
            system.assert(objRebate.Legal__c == null);
            system.assert(objRebate.Corporate_Controller__c == null);
            system.assert(objRebate.Global_Sales_OPS_Manager__c == null);
            system.assert(objRebate.Regional_Controller__c == null);
            system.assert(objRebate.Regional_Channel_Controller__c == null);
            system.assert(objRebate.Global_Channel_Controller__c == null);
            system.assert(objRebate.Regional_Disti_Manager__c == null);
            system.assert(objRebate.Regional_Sales_Manager__c == null);
            system.assert(objRebate.GSM_Controller__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_1__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c == null);
            
            //undelete the Rebate Product
            undelete lstRebateLines;
            
            //assert the result
            objRebate = [Select Id , Apttus_Rebate_Checker__c, Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
            
            //apttus agreement checker - not null
            system.assert(objRebate.Apttus_Rebate_Checker__c != null);
            //system.assert(objRebate.Apttus_Rebate_Checker__c == objApttusChecker.Id); //- need this assertion
            
            //other approver should be null
            system.assert(objRebate.Legal__c == null);
            system.assert(objRebate.Corporate_Controller__c == null);
            system.assert(objRebate.Global_Sales_OPS_Manager__c == null);
            system.assert(objRebate.Regional_Controller__c == null);
            system.assert(objRebate.Regional_Channel_Controller__c == null);
            system.assert(objRebate.Global_Channel_Controller__c == null);
            system.assert(objRebate.Regional_Disti_Manager__c == null);
            system.assert(objRebate.Regional_Sales_Manager__c == null);
            system.assert(objRebate.GSM_Controller__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_1__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c == null);
            
            //stop the Test
            Test.stopTest(); 
        }
    }
        
    /**************************************************
        CASE - Without apttus aggrement 
    ***************************************************/
    
    static testMethod void AfterTrigger_RebateProductTest2() 
    {
        //prepare test data
        //1508 Release - Modified by Scarlett on 2015.08.13
        fetchRecordType();
        //1508 Release - Modified by Scarlett on 2015.08.13
        //insert approver users
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            List<User> lstApprovers = TestUtil.createTestUsers(objProfile.Id, 18);
            insert lstApprovers;
            
            for(User objUser : lstApprovers)
            {
                system.assert(objUser.Id != null);
            }   
            
            User objApttusChecker = lstApprovers[0];            
            User objLegal = lstApprovers[1];
            User objCorpCotrol = lstApprovers[2];
            User objGlobalSalesOPS = lstApprovers[3];
            User objRegionalController = lstApprovers[4];
            User objRegionalChannelController = lstApprovers[5];
            User objGlobalChannelController = lstApprovers[6];
            User objRegionalDistiManager = lstApprovers[7];
            User objRegionalSalesManager  = lstApprovers[8];
            User objGSMController = lstApprovers[9];
            
            system.assert(objApttusChecker.Id != null);                        
            system.assert(objLegal.Id != null);
            system.assert(objCorpCotrol.Id != null);
            system.assert(objGlobalSalesOPS.Id != null);
            system.assert(objRegionalController.Id != null);
            system.assert(objRegionalChannelController.Id != null);            
            system.assert(objGlobalChannelController.Id != null);
            system.assert(objRegionalDistiManager.Id != null);
            system.assert(objRegionalSalesManager.Id != null);
            system.assert(objGSMController.Id != null);
                                  
            integer numOfProducts = 8;
            integer i;
            
            //insert products
            List<Product2> lstProducts = new List<Product2>();
            Product2 objProduct;
            
            for(i =0; i < numOfProducts ;  i++)
            {
                objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut' + i, isActive = true);
                lstProducts.add(objProduct);
            }
            insert lstProducts;
            
            //assert products       
            for(Product2 p : lstProducts)
            {
                system.assert(p.Id != null);
            }
                 
            //insert approver matrix
            List<Rebate_Approver_Matrix__c> lstRebateApprovers = new List<Rebate_Approver_Matrix__c>();
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Apttus Aggrement Checker' , Approver__c = objApttusChecker.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Legal' , Approver__c = objLegal.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Corporate Control' , Approver__c = objCorpCotrol.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Sales & OPS Manager' , Approver__c = objGlobalSalesOPS.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Controller' , Approver__c = objRegionalController.Id));           
            //Modified by Nisha Agrawal on May 10, 2018 for approval flow change
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA', Program_Type__c = 'OEM / EMS' , Role__c = 'Regional Channel Controller' , Approver__c = objRegionalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Channel Controller' , Approver__c = objGlobalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Disti Manager' , Approver__c = objRegionalDistiManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Sales Manager' , Approver__c = objRegionalSalesManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'GSM Controller' , Approver__c = objGSMController.Id));
                
            //insert MAG Approvers              
            for(i =0; i < numOfProducts ;  i++)
            {
                lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'BL Marketing Manager', MAG__c = 'ut' + i , Approver__c = lstApprovers[i + 10].Id));
            }
            insert lstRebateApprovers;
            
            for(Rebate_Approver_Matrix__c objApprover : lstRebateApprovers)
            {
                system.assert(objApprover.Id != null);
            }
            
            //insert FX_Rates       
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
            
            //insert eRebate
            //1508 Release - Modified by Scarlett on 2015.08.13
            //New Recordtype created
            eRebate__c objRebate = new eRebate__c( Rebate_Program_Name__c = 'ut_program' , Sales_Channel__c = 'OEM',  End_Customer__c ='ut_endcustomer', 
                Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , 
                Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD', Red_Flag__c = 'YES', 
                Material_Limitations_to_do_Business__c = true, Consolidated_Account_Code_Description__c = objCACC.Id, 
                //Scarlett Capped_Payout_USD__c = 50000000, 
                Capped_Payout_USD__c = 100000000, Industry_Segment__c = 'Test', Programe_Type__c = 'OEM / EMS',
                RecordType = OEM_EMS, Apttus_Agreement__c = false);
            //1508 Release - Modified by Scarlett on 2015.08.13
            insert objRebate;
            system.assert(objRebate.Id != null);
                        
            //start the Test        
            Test.startTest();
            
            //insert Rebate Products
            List<eRebate_Product__c> lstRebateLines = new List<eRebate_Product__c>();
            
            //1508 Release - Modified by Scarlett on 2015.08.13
            /****
            New fields created and remodify formula for calculating Total Estimated Rebate Amount
            Estimated Rebate Amount = (Booking Cost- Actual Cost) * Quantity
            ****/
            for(i=0; i < numOfProducts ;  i++)
            {
                lstRebateLines.add( new eRebate_Product__c( eRebate__c = objRebate.Id , Price_Gap__c = (i * 10.0) , 
                        //Scarlett Quantity__c = 5, 
                        Quantity__c = 500000, Product__c = lstProducts[i].Id, Booking_Cost__c = 7.25, Actual_Cost__c = 0.25, RecordType = OEM_EMS_Rebate_Product));
            }
            //1508 Release - Modified by Scarlett on 2015.08.13
        
            insert lstRebateLines;
            
            //assert the result            
            objRebate = [Select Id , Apttus_Rebate_Checker__c, Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c, Total_Est_Rebate_Amount_USD__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
            
            system.debug('********Total Rebate Amount: ' + objRebate.Total_Est_Rebate_Amount_USD__c);
            
            //apttus agreement checker - null
            system.assert(objRebate.Apttus_Rebate_Checker__c == null);
            
            //other approver should be not null based on some conditions
            system.assert(objRebate.Legal__c != null);
            //system.assert(objRebate.Legal__c == objLegal.Id); //- need this assertion
            //system.assert(objRebate.Corporate_Controller__c == null);
            system.assert(objRebate.Global_Sales_OPS_Manager__c == null);
            system.assert(objRebate.Regional_Controller__c != null);
            //system.assert(objRebate.Regional_Controller__c == objRegionalController.Id); //- need this assertion
            system.assert(objRebate.Regional_Channel_Controller__c != null);
            system.assert(objRebate.Regional_Channel_Controller__c == objRegionalChannelController.Id);  //- need this assertion
            system.assert(objRebate.Global_Channel_Controller__c != null);
            //system.assert(objRebate.Global_Channel_Controller__c == objGlobalChannelController.Id); //- need this assertion
            system.assert(objRebate.Regional_Disti_Manager__c == null);
            system.assert(objRebate.Regional_Sales_Manager__c != null);
            //system.assert(objRebate.Regional_Sales_Manager__c == objRegionalSalesManager.Id);  //- need this assertion
            system.assert(objRebate.GSM_Controller__c != null);
            //system.assert(objRebate.GSM_Controller__c == objGSMController.Id); //- need this assertion
            system.assert(objRebate.BL_Marketing_Mgr_1__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c != null);
            
            //update the Rebate Product
            for(eRebate_Product__c rebateProduct : lstRebateLines)
            {
                rebateProduct.Line_Description__c = 'test';
//                rebateProduct.Quantity__c = 2000;
                rebateProduct.Price_Gap__c = 800;
            }

            update lstRebateLines;

            //assert the result
             objRebate = [Select Id , Apttus_Rebate_Checker__c, Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
                        
            //apttus agreement checker - null
            system.assert(objRebate.Apttus_Rebate_Checker__c == null);
            
            //other approver should be not null based on some conditions
            system.assert(objRebate.Legal__c != null);
            //system.assert(objRebate.Legal__c == objLegal.Id); //- need this assertion
            //system.assert(objRebate.Corporate_Controller__c != null);
            //system.assert(objRebate.Corporate_Controller__c == objCorpCotrol.Id); //- need this assertion
            system.assert(objRebate.Global_Sales_OPS_Manager__c == null);
            system.assert(objRebate.Regional_Controller__c != null);
            //system.assert(objRebate.Regional_Controller__c == objRegionalController.Id);  //- need this assertion
            system.assert(objRebate.Regional_Channel_Controller__c != null);
            //system.assert(objRebate.Regional_Channel_Controller__c == objRegionalChannelController.Id);  //- need this assertion
            system.assert(objRebate.Global_Channel_Controller__c != null);
            //system.assert(objRebate.Global_Channel_Controller__c == objGlobalChannelController.Id);  //- need this assertion
            system.assert(objRebate.Regional_Disti_Manager__c == null);
            system.assert(objRebate.Regional_Sales_Manager__c != null);
            //system.assert(objRebate.Regional_Sales_Manager__c == objRegionalSalesManager.Id);  //- need this assertion
            system.assert(objRebate.GSM_Controller__c != null);
            //system.assert(objRebate.GSM_Controller__c == objGSMController.Id);  //- need this assertion
           
            system.assert(objRebate.BL_Marketing_Mgr_1__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c != null);
            
            //delete the Rebate Product
            delete lstRebateLines;
            //assert the result
            
            objRebate = [Select Id , Apttus_Rebate_Checker__c, Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
            
            //apttus agreement checker - null
            system.assert(objRebate.Apttus_Rebate_Checker__c == null);
            
            //other approver should be not null based on some conditions
            system.assert(objRebate.Legal__c != null);
            //system.assert(objRebate.Legal__c == objLegal.Id);  //- need this assertion
            system.assert(objRebate.Corporate_Controller__c == null);
            system.assert(objRebate.Global_Sales_OPS_Manager__c == null);
            system.assert(objRebate.Regional_Controller__c != null);
            //system.assert(objRebate.Regional_Controller__c == objRegionalController.Id);  //- need this assertion
            system.assert(objRebate.Regional_Channel_Controller__c != null);
            //system.assert(objRebate.Regional_Channel_Controller__c == objRegionalChannelController.Id);  //- need this assertion
            system.assert(objRebate.Global_Channel_Controller__c != null);
            //system.assert(objRebate.Global_Channel_Controller__c == objGlobalChannelController.Id);  //- need this assertion
            system.assert(objRebate.Regional_Disti_Manager__c == null);
            system.assert(objRebate.Regional_Sales_Manager__c != null);
            //system.assert(objRebate.Regional_Sales_Manager__c == objRegionalSalesManager.Id);  //- need this assertion
            system.assert(objRebate.GSM_Controller__c != null);
            //system.assert(objRebate.GSM_Controller__c == objGSMController.Id);  //- need this assertion
            system.assert(objRebate.BL_Marketing_Mgr_1__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c == null);
            
            //undelete the Rebate Product
            undelete lstRebateLines;
            
            //assert the result
            objRebate = [Select Id , Apttus_Rebate_Checker__c, Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
            
            //apttus agreement checker - null
            system.assert(objRebate.Apttus_Rebate_Checker__c == null);
            
            //other approver should be not null based on some conditions
            system.assert(objRebate.Legal__c != null);
            //system.assert(objRebate.Legal__c == objLegal.Id);  //- need this assertion
            //system.assert(objRebate.Corporate_Controller__c != null);
            //system.assert(objRebate.Corporate_Controller__c == objCorpCotrol.Id);  //- need this assertion
            system.assert(objRebate.Global_Sales_OPS_Manager__c == null);
            system.assert(objRebate.Regional_Controller__c != null);
            //system.assert(objRebate.Regional_Controller__c == objRegionalController.Id);  //- need this assertion
            system.assert(objRebate.Regional_Channel_Controller__c != null);
            //system.assert(objRebate.Regional_Channel_Controller__c == objRegionalChannelController.Id);  //- need this assertion
            system.assert(objRebate.Global_Channel_Controller__c != null);
            //system.assert(objRebate.Global_Channel_Controller__c == objGlobalChannelController.Id);  //- need this assertion
            system.assert(objRebate.Regional_Disti_Manager__c == null);
            system.assert(objRebate.Regional_Sales_Manager__c != null);
            //system.assert(objRebate.Regional_Sales_Manager__c == objRegionalSalesManager.Id);  //- need this assertion
            system.assert(objRebate.GSM_Controller__c != null);
            //system.assert(objRebate.GSM_Controller__c == objGSMController.Id);  //- need this assertion
           
            system.assert(objRebate.BL_Marketing_Mgr_1__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c != null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c != null);
            
            //stop the Test
            Test.stopTest(); 
        }
    }
    
    /**************************************************
        CASE - BU updates   
    ***************************************************/
    static testMethod void AfterTrigger_RebateProductTest3() 
    {
        //prepare test data
        //insert approver users
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            List<User> lstApprovers = TestUtil.createTestUsers(objProfile.Id, 18);
            insert lstApprovers;
            for(User objUser : lstApprovers)
            {
                system.assert(objUser.Id != null);
            }
            
            User objApttusChecker = lstApprovers[0];            
            User objLegal = lstApprovers[1];
            User objCorpCotrol = lstApprovers[2];
            User objGlobalSalesOPS = lstApprovers[3];
            User objRegionalController = lstApprovers[4];
            User objRegionalChannelController = lstApprovers[5];
            User objGlobalChannelController = lstApprovers[6];
            User objRegionalDistiManager = lstApprovers[7];
            User objRegionalSalesManager  = lstApprovers[8];
            User objGSMController = lstApprovers[9];
                        
            system.assert(objApttusChecker.Id != null);                        
            system.assert(objLegal.Id != null);
            system.assert(objCorpCotrol.Id != null);
            system.assert(objGlobalSalesOPS.Id != null);
            system.assert(objRegionalController.Id != null);
            system.assert(objRegionalChannelController.Id != null);            
            system.assert(objGlobalChannelController.Id != null);
            system.assert(objRegionalDistiManager.Id != null);
            system.assert(objRegionalSalesManager.Id != null);
            system.assert(objGSMController.Id != null);            
     
            integer numOfProducts = 8;
            integer i;
            
            //insert products
            List<Product2> lstProducts = new List<Product2>();
            Product2 objProduct;
            
            for(i =0; i < numOfProducts ;  i++)
            {
                objProduct = new Product2(Name = 'ut_product' + i , ProductCode = 'ut_code' + i, MAG__c = 'ut' + i, BU__c = 'ut' + i , isActive = true);
                lstProducts.add(objProduct);
            }
            insert lstProducts;
            
            //assert products       
            for(Product2 p : lstProducts)
            {
                system.assert(p.Id != null);
            }
                 
            //insert approver matrix
            List<Rebate_Approver_Matrix__c> lstRebateApprovers = new List<Rebate_Approver_Matrix__c>();
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Apttus Aggrement Checker' , Approver__c = objApttusChecker.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Legal' , Approver__c = objLegal.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Corporate Control' , Approver__c = objCorpCotrol.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Sales & OPS Manager' , Approver__c = objGlobalSalesOPS.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Controller' , Approver__c = objRegionalController.Id));           
            //Modified by Nisha Agrawal on May 10, 2018 for approval flow change
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA', Program_Type__c = 'Distribution ODM Fullfillment' , Role__c = 'Regional Channel Controller' , Approver__c = objRegionalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Global Channel Controller' , Approver__c = objGlobalChannelController.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Disti Manager' , Approver__c = objRegionalDistiManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'Regional Sales Manager' , Approver__c = objRegionalSalesManager.Id));
            lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'GSM Controller' , Approver__c = objGSMController.Id));
                
            //insert MAG Approvers              
            for(i =0; i < numOfProducts ;  i++)
            {
                lstRebateApprovers.add(new Rebate_Approver_Matrix__c(Region__c = 'EMEA' , Role__c = 'BL Marketing Manager', MAG__c = 'ut' + i , Approver__c = lstApprovers[i + 10].Id));
            }
            insert lstRebateApprovers;
            
            for(Rebate_Approver_Matrix__c objApprover : lstRebateApprovers)
            {
                system.assert(objApprover.Id != null);
            }
            
            //insert FX_Rates       
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
            
            //insert eRebate
            //1508 Release - Modified by Scarlett on 2015.08.13
            eRebate__c objRebate = new eRebate__c(Rebate_Program_Name__c = 'ut_program' , Sales_Channel__c = 'OEM',  End_Customer__c ='ut_endcustomer', Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD', Red_Flag__c = 'YES', Material_Limitations_to_do_Business__c = true, Consolidated_Account_Code_Description__c = objCACC.Id, Capped_Payout_USD__c = 50000000, Apttus_Agreement__c = true, Apttus_Agreement_Number__c ='1234', Industry_Segment__c = 'Test', Programe_Type__c = 'OEM / EMS');
            //1508 Release - Modified by Scarlett on 2015.08.13
            insert objRebate;
            system.assert(objRebate.Id != null);
                        
            //start the Test        
            Test.startTest();
            
            //insert Rebate Products
            List<eRebate_Product__c> lstRebateLines = new List<eRebate_Product__c>();
            
            for(i=0; i < numOfProducts ;  i++)
            {
                lstRebateLines.add(new eRebate_Product__c( eRebate__c = objRebate.Id , Price_Gap__c = (i * 10.0) , Quantity__c = 5, Product__c = lstProducts[i].Id));
            }
        
            insert lstRebateLines;
            
            //assert the result         
            objRebate = [Select Id , BU__c 
                            From eRebate__c
                            Where Id =: objRebate.Id limit 1];          
            
            //BU - not null
            system.assert(objRebate.BU__c != null);
            
            String strBUs = '';
            for(Product2 product :  lstProducts)
            {
                strBUs = strBUs + (strBUs != '' ? '|' : '') + product.BU__c; 
            }
  
  			//J fix the issue that BU__c might not have the same sequence of concatenated string as strBUs
			String[] BUs = objRebate.BU__c.split('\\|');
			BUs.sort();			         
            system.assert(String.join(BUs, '|') == strBUs);
            
            //delete the Rebate Product
            delete lstRebateLines;
            
            //assert the result
            
             objRebate = [Select Id , BU__c 
                            From eRebate__c
                            Where Id =: objRebate.Id limit 1];          
            
            //BU - null
            system.assert(objRebate.BU__c == null);
                        
            //undelete the Rebate Product
            undelete lstRebateLines;
            
            //assert the result
             objRebate = [Select Id , BU__c 
                            From eRebate__c
                            Where Id =: objRebate.Id limit 1];          
            
            //BU - not null
            //J fix the issue that BU__c might not have the same sequence of concatenated string as strBUs
            BUs = objRebate.BU__c.split('\\|');
            BUs.sort();            
            system.assert(objRebate.BU__c != null);
            system.assert(String.join(BUs, '|') == strBUs);
                        
            //stop the Test
            Test.stopTest(); 
        }
    }
        
}