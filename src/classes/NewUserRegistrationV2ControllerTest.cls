/*
  Last Modified By: Baji
  Last Modified Date: 22 Dec, 2015
  Description: Commented BU 513 related code as part of year end changes.
  
  Last Modified By : Baji
  Last Modified Date : 19 Dec 2016
  Description : Modified BU 511 description as part of YE activities
    
  Last Modified By     : Baji
  Last Modified Date   : 16 Feb, 2017
  Description : Obsoleted BU 511 related test data
  
  Last Modified By     : Naveen Nayak 
  Last Modified Date   : 13 July, 2018
  Description : Changing Custom Object name New_User_Registration__C
        
  
*/

@isTest
private class NewUserRegistrationV2ControllerTest 
{ 
    static void setupCustomSettings() {
        List<New_User_Reg_Settings__c> lstNewUserRegSettings = new List<New_User_Reg_Settings__c>();
        lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='Americas',Type__c='Reg',Code__c='AM'));
        lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='EMEA',Type__c='Reg',Code__c='EU'));
        lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='Greater China',Type__c='Reg',Code__c='GC'));
        lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='Japan',Type__c='Reg',Code__c='JP'));
        lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='Korea',Type__c='Reg',Code__c='KR'));
        lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='South Asia Pacific',Type__c='Reg',Code__c='SAP'));
        
        lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='Security & Connectivity',Type__c='BU',Code__c='510 SnC'));
        lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='Automotive',Type__c='BU',Code__c='525 AUT'));
    //  lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='Standard Products',Type__c='BU',Code__c='511 NB'));
    //  Commented as part of YE changes   
    //  lstNewUserRegSettings.add(new New_User_Reg_Settings__c(Name='Logic & Smart Analog',Type__c='BU',Code__c='513 LOG'));
        insert lstNewUserRegSettings;
    }
    
    static testMethod void initTest() {
        setupCustomSettings();
         New_User_Registration__c user = new New_User_Registration__c();
       
        ApexPages.StandardController stdController = new ApexPages.StandardController(user);
        
        NewUserRegistrationV2Controller controller = new NewUserRegistrationV2Controller(stdController);
        controller.init();
        
    }
    
    /*
    String test1 = 'EU;JP;';
    String test2 = '525 AUT;510 SnC;';
    String test3 = 'EU;JP;525 AUT - KR;510 SnC - KR;525 AUT - GC;';
    String test4 = '525 AUT;510 SnC;511 NB - EU;513 LOG - EU;';
    */
    static testMethod void regionTest() {
        setupCustomSettings();
         
        New_User_Registration__c user = new New_User_Registration__c();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(user);
        
        
        NewUserRegistrationV2Controller controller = new NewUserRegistrationV2Controller(stdController);
        controller.init();
        String test1 = 'EU;JP;';
        controller.LoadUserGroup(test1);
        controller.Save();
        
    }

    static testMethod void BUTest() {
        setupCustomSettings();
         
        New_User_Registration__c user = new New_User_Registration__c();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(user);
        
       
        NewUserRegistrationV2Controller controller = new NewUserRegistrationV2Controller(stdController);
        controller.init();
        String test2 = '525 AUT;510 SnC;';
        controller.LoadUserGroup(test2);
        controller.Save();
         
    }

    static testMethod void groupTest() {
        setupCustomSettings();
        New_User_Registration__c user = new New_User_Registration__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(user);
        NewUserRegistrationV2Controller controller = new NewUserRegistrationV2Controller(stdController);
        controller.init();
        String test3 = '525 AUT - KR;510 SnC - KR;525 AUT - GC;';
        controller.LoadUserGroup(test3);
        controller.Save();
         
    }

    static testMethod void globalTest() {
        setupCustomSettings();
        New_User_Registration__c user = new New_User_Registration__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(user);
        NewUserRegistrationV2Controller controller = new NewUserRegistrationV2Controller(stdController);
        controller.init();
        String test1 = 'Global;';
        controller.LoadUserGroup(test1);
        controller.Save();
        
    }

    static testMethod void saveErrorTest() {
        setupCustomSettings();
        New_User_Registration__c user = new New_User_Registration__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(user);
        NewUserRegistrationV2Controller controller = new NewUserRegistrationV2Controller(stdController);
        controller.init();
        controller.Save();
         
    }
    
    static testMethod void getKeyTest() {
        setupCustomSettings();
        
        New_User_Registration__c user = new New_User_Registration__c();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(user);
        
       
        NewUserRegistrationV2Controller controller = new NewUserRegistrationV2Controller(stdController);
        controller.init();
        

        List<NewUserRegistrationV2Controller.RegionSettings> lstRegionSettings = controller.lstRegionSettings;
        lstRegionSettings.get(0).getKey();
        List<NewUserRegistrationV2Controller.BUSettings> lstBUSettings = controller.lstBUSettings;
        lstBUSettings.get(0).getKey();
        lstBUSettings.get(0).lstGroups.get(0).getIdKey();
                 
    }
    
    static testMethod void checkBoxDisabledTest() {
        setupCustomSettings();
        
        New_User_Registration__c user = new New_User_Registration__c();
        user.First_Name__c = 'Test999';
        user.Last_Name__c = 'Test999';
        user.Email_Address__c = 'test999999999@nxp.com';
        user.Region__c = 'EMEA';
        user.Country__c = 'Taiwan (TW)';
        user.Manager_Name__c = 'Test888 Test888';
        user.Manager_s_email__c = 'test88888888@nxp.com';
        insert user;
        
       
        ApexPages.StandardController stdController = new ApexPages.StandardController(user);
        
        
        NewUserRegistrationV2Controller controller = new NewUserRegistrationV2Controller(stdController);
        controller.init();
        
    } 
}