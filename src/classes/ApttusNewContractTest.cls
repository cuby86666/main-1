@istest
public class ApttusNewContractTest
{

   
     static testmethod void Brandlicenseout()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Brand License Out');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         
         approver =[Select Approver_2_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_2_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     
     static testmethod void CooperationAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Cooperation Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     
     static testmethod void CustPaymentAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Customer Payment Security');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_2_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_2_Role__c,'GSM Credit Control Manager');
        
     }


     static testmethod void DesignInAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Design In / Development Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }

     static testmethod void DistributorAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Distributor Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }


     static testmethod void DistP4PAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Distributor P4P / Rebate / T&C Allowance Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     
     static testmethod void IDHAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('IDH/PDH/VAR');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     static testmethod void CustLogicAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Customer Logistics / Inventory Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
    
      static testmethod void OEMAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('OEM /EMS P4P / Rebate / T&C Allowance Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     static testmethod void MasterSalesAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Master Sales Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     static testmethod void OtherSalesAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Other (SALES)');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     
     static testmethod void ProductLongetivityAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Product Longevity Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     static testmethod void PreProductionAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Pre-Production Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     static testmethod void PricingAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Pricing Agreement (actual price load is done via Model N)');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     static testmethod void CustomerQualityAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Customer Quality Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }


     static testmethod void SettlementAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Settlement Agreement over $250,000');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }
     
     
     static testmethod void SalesRepAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Sales Representative Contract');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_5_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_5_Role__c,'Regional Sales Director');
        
     }


     static testmethod void SustainablityAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Sustainability Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_5_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_5_Role__c,'Regional Sales Director');
        
     }


     static testmethod void SoftofTechAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Software or Technology License In / Out');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }

     static testmethod void TenderAgentAgreement()
     {
     
        //Variable 
         List<Apttus__APTS_Agreement__c> testagmt = new List<Apttus__APTS_Agreement__c>();
         Apttus__APTS_Agreement__c approver;
         ID ReturnedId;
         
         Test.starttest();
         //Calling the data factory
         ApttusNewContracttestfactory testrec = new ApttusNewContracttestfactory();
         testagmt=testrec.testfactory('Tender Agent / Consultant Agreement');
         ReturnedId = testagmt[0].Id;
         
         //Assertion
         approver =[Select Approver_4_Role__c from Apttus__APTS_Agreement__c where id=:ReturnedId];
         Test.stoptest();
         System.assertEquals(approver.Approver_4_Role__c,'BL Marketing Manager / Stakeholder');
        
     }








}