/*********************************************************************************************
@Created By :      Shridevi
@CreatedDate :     18 July 2017
Description :      Test Class for ForgotPasswordController
****************************************************************************************************/
@isTest(seeAllData = false)
Public class ForgotPasswordControllerTest{
    
    public static testMethod void testForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';            
    
        System.assertEquals(controller.forgotPassword(),null); 
    }
    
}