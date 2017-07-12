/*********************************************************************************************
@Created By :      Amrutha R
@Created Date :    06 Feb 2015
Description :       Test Class for ChangePasswordController
**************************************************************************************************/

@isTest
public class ChangePasswordControllerTest 
{
    public static testMethod void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
       
        controller.changePassword();                           
    }    

}