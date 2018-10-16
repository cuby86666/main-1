/*****************************************************************************
* Created By   : Harish Gowda N
* Created Date : 28 Mar 2018
* Description  : To test the functionality of Brainshark New User Registration Class
********************************************************************************************/
@isTest
public class BrainsharkNewUserRegistrationTest{
    
    @isTest
    public static void testBrainsharkNewUserRegistrationNoRequiredFields(){
        BrainsharkNewUserRegisterationController bnsk = new BrainsharkNewUserRegisterationController();
        System.assert(bnsk.Step1==true);
        System.assert(bnsk.Step2==false);
        bnsk.save();
        System.assert(bnsk.Step1==true);
        System.assert(bnsk.Step2==false);
    }
    
    @isTest
    public static void testBrainsharkNewUserRegistrationAllRequiredFields(){
        BrainsharkNewUserRegisterationController bnsk = new BrainsharkNewUserRegisterationController();
        System.assert(bnsk.Step1==true);
        System.assert(bnsk.Step2==false);
        
       
        //add values for new user registration
        bnsk.user =  new New_User_Registration__c();
        
        bnsk.user.First_Name__c='Test';
        bnsk.user.Last_Name__c='Brainshark';
        bnsk.user.Email_Address__c='test@brainshark.com';
        bnsk.user.Region__c='South Asia Pacific';
        bnsk.user.Country__c='India (IN)';
        bnsk.user.Job_Title__c='Support engineer';
        bnsk.user.Phone_Number__c='(991) 654-9230';
        bnsk.user.Manager_Name__c='baji';
        bnsk.user.Manager_s_email__c='baji@nxp.com';
        bnsk.user.Related_Groups__c='All GSM';
        bnsk.user.Main_Function_Area__c='Brainshark';
        bnsk.user.NXP_Role__c='Non-Sales/Non GSM';
        bnsk.user.Are_You_A_Manager__c='No';
        bnsk.user.Anticipate_Creating_Content__c='No';
        bnsk.user.Are_You_On_Sales_Incentive_Plan__c='No';
        bnsk.user.Reason_for_Request__c='test@brainshark.com';
        bnsk.user.Are_You_A_New_Hire__c='Yes';
        
        bnsk.save();
        System.assert(bnsk.Step2==true);
        System.assert(bnsk.Step1==false);
    }
    
    @isTest
    public static void testBrainsharkNewUserRegistrationStepBack(){
        BrainsharkNewUserRegisterationController bnsk = new BrainsharkNewUserRegisterationController();
        System.assert(bnsk.Step1==true);
        System.assert(bnsk.Step2==false);
        //add values for new user registration
        bnsk.user =  new New_User_Registration__c();
        
        bnsk.user.First_Name__c='Test';
        bnsk.user.Last_Name__c='Brainshark';
        bnsk.user.Email_Address__c='test@brainshark.com';
        bnsk.user.Region__c='South Asia Pacific';
        bnsk.user.Country__c='India (IN)';
        bnsk.user.Job_Title__c='Support engineer';
        bnsk.user.Phone_Number__c='(991) 654-9230';
        bnsk.user.Manager_Name__c='baji';
        bnsk.user.Manager_s_email__c='baji@nxp.com';
        bnsk.user.Related_Groups__c='All GSM';
        bnsk.user.Main_Function_Area__c='Brainshark';
        bnsk.user.NXP_Role__c='Non-Sales/Non GSM';
        bnsk.user.Are_You_A_Manager__c='No';
        bnsk.user.Anticipate_Creating_Content__c='No';
        bnsk.user.Are_You_On_Sales_Incentive_Plan__c='No';
        bnsk.user.Reason_for_Request__c='test@brainshark.com';
        bnsk.user.Are_You_A_New_Hire__c='Yes';
        
        bnsk.save();
        bnsk.backToStep1();
        System.assert(bnsk.Step1==true);
        System.assert(bnsk.Step2==false);
    }
    @isTest
    public static void testBrainsharkNewUserRegistrationFinalSubmit(){
        BrainsharkNewUserRegisterationController bnsk = new BrainsharkNewUserRegisterationController();
        System.assert(bnsk.Step1==true);
        System.assert(bnsk.Step2==false);

       
        //add values for new user registration
        bnsk.user =  new New_User_Registration__c();
        
        bnsk.user.First_Name__c='Test';
        bnsk.user.Last_Name__c='Brainshark';
        bnsk.user.Email_Address__c='test@brainshark.com';
        bnsk.user.Region__c='South Asia Pacific';
        bnsk.user.Country__c='India (IN)';
        bnsk.user.Job_Title__c='Support engineer';
        bnsk.user.Phone_Number__c='(991) 654-9230';
        bnsk.user.Manager_Name__c='baji';
        bnsk.user.Manager_s_email__c='baji@nxp.com';
        bnsk.user.Related_Groups__c='All GSM';
        bnsk.user.Main_Function_Area__c='Brainshark';
        bnsk.user.NXP_Role__c='Non-Sales/Non GSM';
        bnsk.user.Are_You_A_Manager__c='No';
        bnsk.user.Anticipate_Creating_Content__c='No';
        bnsk.user.Are_You_On_Sales_Incentive_Plan__c='No';
        bnsk.user.Reason_for_Request__c='test@brainshark.com';
        bnsk.user.Are_You_A_New_Hire__c='Yes';

        bnsk.save();
        System.assert(bnsk.Step2==true);
        System.assert(bnsk.Step1==false);
        
        //call save again        
        bnsk.save();
        bnsk.register();
        System.assert(bnsk.Step1==false);
        System.assert(bnsk.Step2==false);
        System.assert(bnsk.success==true);
        
    }    
}