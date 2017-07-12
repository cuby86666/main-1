/*********************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     06 Feb 2015
Description :      Class for NXP community users to edit profile
****************************************************************************************************/
/*********************************************************************************************
@Modified By :      Amrutha R
@ModifiedDate :     02 Aug 2015
Description :      New UI
****************************************************************************************************/
/***************************************************************************************************************************************************************************************************************************************************** 
@Modified By :       Avichal Kumar 
@Modified Date:      14th Sept 2015
@Description:       added upload photo feature
******************************************************************************************************************************************************************************************************************************************************/

public class EditUserProfileController 
{
    public Contact objCont {get;set;}
    public User objUser {get; set;}
    public Boolean isInputCompany{ get;set;}
    public Boolean isOutputCompany{get; set;}
    public static string strFileName{get;set;}
    public static Blob blobValue{get;set;}
    public String contentType {get; set;} 
    public Integer fileSize  {get;set;}
    public Id userId { get; set; }  
    
    //controller to fetch contact information
    public EditUserProfileController(ApexPages.StandardController stdController) 
    {
        this.objCont = (Contact)stdController.getRecord();
        isOutputCompany=true;
        isInputCompany=false;
        objUser = [Select id,contactId,CommunityNickname from user where id=:userinfo.getuserid()];
        objCont = [Select id,name,email,Phone,Facebook__c,Linkedin__c,
                   Twitter__c,State_Province__c,Job_Title__c,Company__c,Community_web_country__c,Web_Region__c 
                   from Contact where id=: objUser.ContactId];
        if(objCont.Company__c==null)
        {
            isInputCompany=true;
            isOutputCompany=false;
        }
            
    }
    
    public String getLargePhotoUrl() {
        userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    
    //method to update contact information
    public PageReference editContact()
    {
        userid = UserInfo.getUserId();
        
        //Since for this we dont have any way of testing this we skip using isTesting Flag
        //Refer: http://salesforce.stackexchange.com/questions/60017/how-to-get-the-photo-using-connect-api
        if(!Test.isRunningTest())
        {
            if(blobValue!=null)
            {
                ConnectApi.BinaryInput photoFileInput =
            	new ConnectApi.BinaryInput(blobValue, contentType, strFileName);   
            
            	ConnectApi.ChatterUsers.setPhoto(
            	Network.getNetworkId(), userId,photoFileInput);
            }
            
        }
        
        if(objCont.Job_Title__c == '--None--'|| objCont.Job_Title__c == '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Job Title'));     
        }
        if(objCont.Community_web_country__c == '--None--'|| objCont.Community_web_country__c == '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Country'));
        }
        else
        {
            update objCont;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'Your profile is updated successfully'));   
        }
        return null;
        
    }
    
}