/********************************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      03 Jan 2012
@Description:       Test Class for Trigger BeforeInsert_Rebate
-----------------------------------------------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date :    06 Aug 2013
@Description :      Change in test class due to change in Approval flow changed for Disti Rebates 
                    (Seek Regional Controller's approval instead of GSM Controller without any value restriction)
-------------------------------------------------------------------------------------------------------------------
@Modified By :       Balaji Gunasekaran
@Modified Date:      21 May 2015
@Description:       As Part of CACC code impact analysis LineItem#23 
                    - Replaced CACC code object with Consolidated Account Code object and replaced field Consolidate_Code_Description__c with Consolidated_Account_Code_Description__c
-------------------------------------------------------------------------------------------------------------------
@Modified By :       Scarlett Kang
@Modified Date:      19 Aug 2015
@Description:       Test data revision for validation rule
---------------------------------------------------------------------------------------------------------------------
@Modified By :      Nisha Agrawal
@Modified Date :    May 10, 2018
@Description :      Test methods revised as per change in approval flow for Regional Channel Controller
**********************************************************************************************************************/

@isTest
private class BeforeInsert_RebateTest 
{
    /**************************************************
        CASE - With apttus aggrement    
    ***************************************************/
    static testMethod void BeforeInsert_RebateTest1() 
    {
        //prepare test data
        //insert approver users
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            List<User> lstApprovers = TestUtil.createTestUsers(objProfile.Id, 10);
            insert lstApprovers;
            
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
            
            insert lstRebateApprovers;
            
            for(Rebate_Approver_Matrix__c objApprover : lstRebateApprovers)
            {
                system.assert(objApprover.Id != null);
            }
            
            //insert FX_Rates       
            FX_Rates__c rebateCurrency = new FX_Rates__c(Name = 'USD' , Currency_Code__c = 'USD');
            insert rebateCurrency;          
            system.assert(rebateCurrency.Id != null);
           
            //insert Consolidated Account code
            Consolidated_Account_Code__c objCACC = new Consolidated_Account_Code__c();
            objCACC.Code_Description__c='123';
            insert objCACC;
            system.assert(objCACC.Id != null);
            
            Test.startTest();
            
            //insert eRebate
            eRebate__c objRebate = new eRebate__c(Rebate_Program_Name__c = 'ut_program' , End_Customer__c ='ut_endcustomer', 
                Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , 
                Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD', Apttus_Agreement__c = true, 
                Apttus_Agreement_Number__c ='1234', Consolidated_Account_Code_Description__c = objCACC.Id, Industry_Segment__c = 'Computing',Programe_Type__c = 'OEM / EMS');
            insert objRebate;
            system.assert(objRebate.Id != null);
            
            //assert the result            
            objRebate = [Select Id , Apttus_Rebate_Checker__c,  Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
            
            //apttus agreement checker - not null
            system.assert(objRebate.Apttus_Rebate_Checker__c != null);
            system.assert(objRebate.Apttus_Rebate_Checker__c == objApttusChecker.Id);
            
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
            Test.stopTest();
        
        }
    }
    
    
    /*******************************************************************
        CASE - Without apttus aggrement - Channel - Distribution
    ********************************************************************/
    static testMethod void BeforeInsert_RebateTest2() 
    {
        //prepare test data
        //insert approver users
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            List<User> lstApprovers = TestUtil.createTestUsers(objProfile.Id, 10);
            insert lstApprovers;
            
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
            
            insert lstRebateApprovers;
            
            for(Rebate_Approver_Matrix__c objApprover : lstRebateApprovers)
            {
                system.assert(objApprover.Id != null);
            }
            
            //insert FX_Rates       
            FX_Rates__c rebateCurrency = new FX_Rates__c(Name = 'USD' , Currency_Code__c = 'USD');
            insert rebateCurrency;          
            system.assert(rebateCurrency.Id != null);
           
            //insert Consolidated Account code
            Consolidated_Account_Code__c objCACC = new Consolidated_Account_Code__c();
            objCACC.Code_Description__c='123';
            insert objCACC;
            system.assert(objCACC.Id != null);
            
            Test.startTest();
            
            //insert eRebate
            eRebate__c objRebate = new eRebate__c(Rebate_Program_Name__c = 'ut_program' , Sales_Channel__c = 'Distribution', End_Customer__c ='ut_endcustomer', Rebate_End_Date__c = date.today().addDays(30) , 
                Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD', 
                Red_Flag__c = 'YES', Material_Limitations_to_do_Business__c = true, Consolidated_Account_Code_Description__c = objCACC.Id, 
                Capped_Payout_USD__c = 110000, Industry_Segment__c = 'Computing', Programe_Type__c = 'OEM / EMS');
            insert objRebate;
            system.assert(objRebate.Id != null);
            
            //assert the result
            
            objRebate = [Select Id , Apttus_Rebate_Checker__c,  Legal__c , Corporate_Controller__c , Global_Sales_OPS_Manager__c , Regional_Controller__c ,  Regional_Channel_Controller__c ,  Global_Channel_Controller__c , Regional_Disti_Manager__c,
                            Regional_Sales_Manager__c , GSM_Controller__c , BL_Marketing_Mgr_1__c , BL_Marketing_Mgr_2__c , BL_Marketing_Mgr_3__c , BL_Marketing_Mgr_4__c , BL_Marketing_Mgr_5__c , BL_Marketing_Mgr_6__c ,
                            BL_Marketing_Mgr_7__c , BL_Marketing_Mgr_8__c
                        From eRebate__c
                        Where Id =: objRebate.Id limit 1];
            
            //apttus agreement checker - null
            system.assert(objRebate.Apttus_Rebate_Checker__c == null);
            
            //other approver should be not null based on some conditions
            system.assert(objRebate.Legal__c != null);
            system.assert(objRebate.Legal__c == objLegal.Id);           
            system.assert(objRebate.Corporate_Controller__c == null);
            system.assert(objRebate.Global_Sales_OPS_Manager__c != null);
            system.assert(objRebate.Global_Sales_OPS_Manager__c == objGlobalSalesOPS.Id);
            system.assert(objRebate.Regional_Channel_Controller__c != null);
            system.assert(objRebate.Regional_Channel_Controller__c == objRegionalChannelController.Id);         
            system.assert(objRebate.Global_Channel_Controller__c != null);
            system.assert(objRebate.Global_Channel_Controller__c == objGlobalChannelController.Id);
            system.assert(objRebate.Regional_Disti_Manager__c != null);
            system.assert(objRebate.Regional_Disti_Manager__c == objRegionalDistiManager.Id);
            system.assert(objRebate.Regional_Sales_Manager__c == null);
            system.assert(objRebate.GSM_Controller__c == null);
            system.assert(objRebate.Regional_Controller__c != null);
            system.assert(objRebate.Regional_Controller__c == objRegionalController.Id);
            system.assert(objRebate.BL_Marketing_Mgr_1__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c == null);
            
            Test.stopTest(); 
        }      
    }
    
    /*******************************************************************
        CASE - Without apttus aggrement - Channel - EMS/OEM
    ********************************************************************/
    static testMethod void BeforeInsert_RebateTest3() 
    {
        //prepare test data
        //insert approver users
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            List<User> lstApprovers = TestUtil.createTestUsers(objProfile.Id, 10);
            insert lstApprovers;
            
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
            
            insert lstRebateApprovers;
            
            for(Rebate_Approver_Matrix__c objApprover : lstRebateApprovers)
            {
                system.assert(objApprover.Id != null);
            }
            
            //insert FX_Rates       
            FX_Rates__c rebateCurrency = new FX_Rates__c(Name = 'USD' , Currency_Code__c = 'USD');
            insert rebateCurrency;          
            system.assert(rebateCurrency.Id != null);
           
            //insert Consolidated Account code
            Consolidated_Account_Code__c objCACC = new Consolidated_Account_Code__c();
            objCACC.Code_Description__c='123';
            insert objCACC;
            system.assert(objCACC.Id != null);
            
            Test.startTest();
            
            //insert eRebate
            eRebate__c objRebate = new eRebate__c(Rebate_Program_Name__c = 'ut_program' , Sales_Channel__c = 'OEM', End_Customer__c ='ut_endcustomer', 
                Rebate_End_Date__c = date.today().addDays(30) , Rebate_Effective_Date__c = date.today() , Sales_Region__c = 'EMEA' , 
                Rebate_Currency__c = rebateCurrency.Id,  CurrencyIsoCode = 'USD', Red_Flag__c = 'YES', Material_Limitations_to_do_Business__c = true, 
                Consolidated_Account_Code_Description__c = objCACC.Id, Capped_Payout_USD__c = 110000, Industry_Segment__c = 'Computing',Programe_Type__c = 'OEM / EMS');
            insert objRebate;
            system.assert(objRebate.Id != null);
            
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
            system.assert(objRebate.Legal__c == objLegal.Id);
            system.assert(objRebate.Corporate_Controller__c == null);
            system.assert(objRebate.Global_Sales_OPS_Manager__c == null);
            system.assert(objRebate.Regional_Controller__c != null);
            system.assert(objRebate.Regional_Controller__c == objRegionalController.Id);
            system.assert(objRebate.Regional_Channel_Controller__c != null);
            system.assert(objRebate.Regional_Channel_Controller__c == objRegionalChannelController.Id);
            system.assert(objRebate.Global_Channel_Controller__c != null);
            system.assert(objRebate.Global_Channel_Controller__c == objGlobalChannelController.Id);
            system.assert(objRebate.Regional_Disti_Manager__c == null);
            system.assert(objRebate.Regional_Sales_Manager__c != null);
            system.assert(objRebate.Regional_Sales_Manager__c == objRegionalSalesManager.Id);
            system.assert(objRebate.GSM_Controller__c != null);
            system.assert(objRebate.GSM_Controller__c == objGSMController.Id);
            system.assert(objRebate.BL_Marketing_Mgr_1__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_2__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_3__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_4__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_5__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_6__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_7__c == null);
            system.assert(objRebate.BL_Marketing_Mgr_8__c == null);
            
            Test.stopTest(); 
        }      
    }
}