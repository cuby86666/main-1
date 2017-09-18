/**
 * An apex page controller that exposes the site forgot password functionality
 */
 /**
 * Last modified by   : Shridevi
 * Last modified date : 18-July-2017
 * Description        :To remove the method ForgotPassword_Community() from this class as the vf page ForgotPassword_Community has been deleted.
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}   
       
    public ForgotPasswordController() {}
        
        public PageReference forgotPassword() {
                boolean success = Site.forgotPassword(username);
                PageReference pr = Page.ForgotPasswordConfirm;
                pr.setRedirect(true);
                
                if (success) {                          
                        return pr;
                }
                return null;
        }
              
     
}