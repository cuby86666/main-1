/*********************************************************************************************************
Name            :    TestNewUserRegisterationController
Author          :    
Date            :    1 Jun, 2011
Description     :    This test class covers the code coverage of Class "NewUserRegisterationController".

Modified By     :   Nisha Agrawal
Modified Date   :   27 Sep 2012
Description     :   To accomodate the changes made in controller class and to improve the code coverage. 

  
*    Last Modified By     : Manoj 
*    Last Modified Date   : 09 Mar, 2015 
*    Description : Added @isTest annotation at class level. 
   
 *   Last Modified By : Baji
 *   Last Modified Date : 19 Dec 2016
 *   Description : Modified BU 511 description as part of YE activities
 
 *   Last Modified By     : Baji
 *   Last Modified Date   : 16 Feb, 2017
 *   Description : Obsoleted BU 511 related test data

*********************************************************************************************************/
@isTest
Public class TestNewUserRegisterationController
{  
   @isTest
    public static void testClass()
    {
        NewUserRegistrationController nurc = new NewUserRegistrationController();
        nurc.user.First_Name__c = 'test';
        nurc.user.Last_Name__c = 'test';
        nurc.user.Email_Address__c = 'test@test.com';
        nurc.user.Region__c = 'EMEA';
        nurc.user.Job_Title__c = 'test';
        nurc.user.Phone_Number__c = '123456789';
        nurc.user.Manager_Name__c = 'test';
        nurc.user.Manager_s_email__c = 'test@test.com';
        nurc.user.Role__c = 'NXP Sales';
        nurc.user.Are_you_a_DW_Approver__c = 'Yes';
        nurc.user.Request_STAR_access__c = true;
        nurc.user.BU__c = '510 - BU SECURITY & CONNECTIVITY';
        nurc.user.BL__c = 'BL01 - BL SECURE INTERFACE & POWER';
        
        nurc.goToStep2();        
        System.assert(Apexpages.hasMessages(ApexPages.severity.Error));
        List<Apexpages.Message> lstMessages = ApexPages.getMessages();
        System.assert(lstMessages[0].getSummary() == NewUserRegistrationController.NO_APP_SELECTED_ERROR);
        
        nurc.user.RequestforAccountin__c = 'Box.Net';
        nurc.selectApps();        
        system.assert(nurc.user.RequestforAccountin__c == 'Box.Net'); 
        
        nurc.getdisplayFields();
        nurc.goToStep2();
        System.assert(Apexpages.hasMessages(ApexPages.severity.Error));
                
        nurc.user.Country__c = 'Netherlands';
        nurc.validBL=true;
        nurc.goToStep2();
        system.assert(nurc.Step1 == false);
        system.assert(nurc.Step2 == true);
        
        nurc.backToStep1();
        system.assert(nurc.Step1 == true);
        system.assert(nurc.Step2 == false);
        
        nurc.user.Role__c = 'NXP BU/BL';
        nurc.getdisplayFields();
        nurc.goToStep2();        
        System.assert(Apexpages.hasMessages(ApexPages.severity.Error));
        system.assert(nurc.Step1 == true);
        system.assert(nurc.Step2 == false);
        
        nurc.user.Role__c = 'NXP BU/BL';
        nurc.user.BU__c = '525 - BU AUTOMOTIVE';
        nurc.user.BL__c = 'BL04 - BL CATENA'; 
        nurc.getdisplayFields();
        nurc.goToStep2();        
       /* nurc.user.BU__c = 'test';
        nurc.user.BL__c = 'BL69 BL CAR ENTERTAINMENT';
        nurc.goToStep2();
        system.assert(nurc.Step1 == false);
        system.assert(nurc.Step2 == true);*/
        
        nurc.save();
       
        nurc.backToStep1();         
        
        //Salesforce Case           
        nurc.user.RequestforAccountin__c = 'Salesforce';
        nurc.selectApps();
        system.assert(nurc.user.RequestforAccountin__c == 'Salesforce');        
        
        nurc.goToStep2();
        
        system.assert(Apexpages.hasMessages(ApexPages.severity.Error));
        system.assert(nurc.Step1 == true);
        system.assert(nurc.Step2 == false);
        
        nurc.user.Role__c = 'NXP Sales';
        nurc.user.Available_Date_for_Training__c = date.today();
        nurc.goToStep2();
        system.assert(nurc.Step1 == false);
        system.assert(nurc.Step2 == true);
        
        nurc.backToStep1();
        system.assert(nurc.Step1 == true);
        system.assert(nurc.Step2 == false);
        
        nurc.user.Role__c = 'NXP BU/BL';
        nurc.user.BU__c = null; 
        nurc.user.BL__c = null;
        nurc.user.Are_you_a_DW_Approver__c = null;
        
        nurc.goToStep2();           
        System.assert(Apexpages.hasMessages(ApexPages.severity.Error));
        system.assert(nurc.Step1 == true);
        system.assert(nurc.Step2 == false);
        
        
        nurc.user.BU__c = '525 - BU AUTOMOTIVE';
      //nurc.user.BU__c = 'test';
        nurc.user.BL__c = 'BL04 - BL CATENA';
        nurc.user.Are_you_a_DW_Approver__c = 'Yes';
        nurc.goToStep2();           
        System.assert(Apexpages.hasMessages(ApexPages.severity.Error));
        system.assert(nurc.Step1 == true);
        system.assert(nurc.Step2 == false);
        
        
        nurc.user.Specify_Mags__c = 'R20';
        nurc.goToStep2();
        system.assert(nurc.Step1 == false);
        system.assert(nurc.Step2 == true);
     
        nurc.backToStep1();
        system.assert(nurc.Step1 == true);
        system.assert(nurc.Step2 == false);
         
        nurc.user.Are_you_a_DW_Approver__c = 'No';
        nurc.goToStep2();
        system.assert(nurc.Step1 == false);
        system.assert(nurc.Step2 == true);
                    
        /*
        nurc.user.Available_Date_for_Training__c = system.today();
        nurc.user.Special_Requirements_in_Salesforce__c = 'test';
        nurc.user.Specify_Mags__c = 'test';
         */
       
        
        /*      
        nurc.save();
        
        nurc.user.Role__c = 'NXP Sales';
        nurc.goToStep2();
        nurc.save();
        
        nurc.user.First_Name__c = 'test';
        nurc.user.Last_Name__c = 'test';
        nurc.user.Email_Address__c = 'test@test.com';
        nurc.user.Region__c = 'EMEA';
        nurc.user.Job_Title__c = 'test';
        nurc.user.Phone_Number__c = '123456789';
        nurc.user.Manager_Name__c = 'test';
        nurc.user.Manager_s_email__c = 'test@test.com';
        nurc.user.Role__c = 'NXP BU/BL';
        nurc.user.Available_Date_for_Training__c = system.today();
        nurc.user.Special_Requirements_in_Salesforce__c = 'test';
        nurc.user.Role__c = 'NXP BU/BL';
        nurc.user.Specify_Mags__c = 'test';
        nurc.user.BU__c ='Standard Product';
        nurc.user.Are_you_a_DW_Approver__c = 'yes';
        nurc.user.BU__c = 'BU Automotive';
        nurc.user.BL__c = 'BL69 BL CAR ENTERTAINMENT';
        //nurc.termCondition=true;
        nurc.user.Are_you_a_DW_Approver__c='Yes';
        nurc.user.RequestforAccountin__c='Salesforce,Box.net,Xactly';
        //nurc.termCondition=true;
        nurc.user.Request_for_Account_in__c='Salesforce.com & Box.net';
        nurc.gotoStep2();
        nurc.save();
       
        */
        
      nurc.register();  
        //nurc.boxCondition();
        //nurc.SFAndBoxCondition(); 
        //nurc.accountTypeBack();

        //nurc.accountTypeNext();
        
        //Checking wheather record is inserted or not?
        //system.assert(nurc.user.Id != null, 'Could not insert the records!');
             
   }
  
}