/*
Modified By: Shridevi
Created Date :25 Aug 2017
Description: As per SIR 828- Removed the method getLargePhotoUrl() since it is not required.
*/
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    //public Id userId { get; set; } 
    
    public void changePassword() 
    {
        
        Site.changePassword(newPassword, verifyNewPassword, oldpassword);
        if(ApexPages.hasMessages()==false)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'Your password is updated successfully'));   

        }

        
    }
    //
    /*public String getLargePhotoUrl() 
    {
        userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }     
    */
    public ChangePasswordController() {}
        
}