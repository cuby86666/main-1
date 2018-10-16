/*********************************************************************************************************
Name            :    BrainsharkNewUserRegisterationController
Author          :    Harish Gowda N
Date            :    22 Feb, 2018
Description     :    This controller is used to Register New user For Brainshark. All fields are required in this controller.  

Last Modified By     : Naveen Nayak 
Last Modified Date   : 13 July, 2018
Description : Changing Custom Object name New_User_Registration__C

*********************************************************************************************************/

public class BrainsharkNewUserRegisterationController
{
    public New_User_Registration__c user { get; set; }
    
    public boolean Step1 { get;set; }
    public boolean Step2{ get;set; }
    public boolean success{ get;set; }
    public pageReference pg {get;set;}

    //Constructor
    public BrainsharkNewUserRegisterationController()
    {    
         user = new New_User_Registration__c();
         user.First_Name__c=ApexPages.CurrentPage().getParameters().get('firstName');
         user.Last_Name__c=ApexPages.CurrentPage().getParameters().get('lastName');
         user.Email_Address__c=ApexPages.CurrentPage().getParameters().get('email'); 
         user.RequestforAccountin__c=  ApexPages.CurrentPage().getParameters().get('userRequestparam');
        Id rtId = Schema.SObjectType.New_User_Registration__c.getRecordTypeInfosByName().get('Brainshark New User Registration').getRecordTypeId();
        user.RecordtypeId = rtId ;
        String rtXStr = String.valueOf(rtId);
         Step1 = true;
         Step2 = false;
         
          
    }
      
     private void validateFieldsForBrainshark()
     {
         
            if(user.First_Name__c != null && user.Last_Name__c != null && user.Email_Address__c != null && user.Region__c != null && user.Country__c != null && user.Job_Title__c != null && user.Phone_Number__c != null && user.Manager_Name__c != null && user.Manager_s_email__c != null && user.Related_Groups__c !=null && user.Main_Function_Area__c!= null && user.NXP_Role__c!= null && user.Are_You_A_Manager__c!= null && user.Anticipate_Creating_Content__c!= null&& user.Are_You_On_Sales_Incentive_Plan__c!= null  && user.Reason_for_Request__c!= null && user.Are_You_A_New_Hire__c!= null )
            {
            
                Step1 = false;
                Step2 = true;
               //success = true;                                             
            }      
            else
             {
                Step1 = true;
                Step2 = false;
                success=false; 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required Fields Can not be Empty. All Fields Are Required !!'));
            }
        
       
       }
      
      
    //Moves to previous page and rendered User registration page.
    public void backToStep1()
    {
        Step1 = true;
        Step2 = false;   
    }
       
        
    // save the information
    public void save(){
        if(step1){
            validateFieldsForBrainshark();
        } else if(step2){
            try
            {
             
                
                System.debug('Owner::'+user.ownerId);
                upsert user;
                
               
                
                Step1 = false;
                Step2 = false;
                success = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your application has been successfully submitted and a response to your request will arrive shortly. You will not be able to logon to the system until the registration has been approved. If you do not receive a response, Please contact Global Sales Application Support at globalsales.appsupport@nxp.com for any assistance.'));  
            }catch(DMLException ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
        }
    }

    
    //Moves to User registration page.   
     public pageReference register()
     {
        pg= new pageReference('/apex/newuser/BrainsharkNewUserRegisteration');
        System.debug('page reference::'+pg);
        return pg;
    } 
     
}