/*********************************************************************************************************
Name            :    NewUserRegistrationController
Author          :    
Date            :    1 Jun, 2011
Description     :    This controller is used to Register New user. All fields are required in this controller.                        

Modified By     :    Nisha Agrawal
Modified Date   :    26 Sep 2012
Description     :    To remove Application Selection Step, include more applications as checkboxes and optimize the code. 

Modified By     :    Shridevi Badiger
Modified Date   :    23 June 2016
Description     :    SIR-848-For separating new User registration page for Box, Brainshark, GotoMeeting and Training App.

Modified By     :    Shridevi Badiger
Modified Date   :    17 sep 2016
Description     :    SIR-1172-Validation For BU,BL.

Modified By     :    Shridevi Badiger
Modified Date   :    6-Oct-2016
Description     :    SIR-1172-changing BL field from free text to picklist.

Modified By     :    Naveen Nayak
Modified Date   :    12 July 2018
Description     :    Story#-1553-change the spelling error " New User Registeration " TO " New User Registration"

*********************************************************************************************************/


public class NewUserRegistrationController

{
   public String userRequest { get; set; }
    public static final string NO_APP_SELECTED_ERROR = 'Please Select atleast one application to register.'; 
    public New_User_Registration__c user { get; set; }
    
    public boolean Step1 { get;set; }
    public boolean Step2{ get;set; }
    public boolean success{ get;set; }
    public boolean BLVisibility{get;set;}
    public pageReference pg {get;set;}
    Public String helpTextBL{get;set;}
    public List<SelectOption> BLOptions{get;set;}
    //public list<String> selectedApps { get; set; }
    //public Schema.DescribeFieldResult fieldResult{get;set;}
  //   public Schema.DescribeFieldResult fieldResult=New_User_Registration__c.BL__c.getDescribe();
   // public List<Schema.PicklistEntry> ple{get;set;}
    public boolean validBL{get;set;}
    //Constructor
    public NewUserRegistrationController()
    {    
    
         validBL=false;
         helpTextBL='Please enter BL code (number) or BL description.';
         BLVisibility=false;
         user = new New_User_Registration__c();
         user.First_Name__c=ApexPages.CurrentPage().getParameters().get('firstName');
         user.Last_Name__c=ApexPages.CurrentPage().getParameters().get('lastName');
         user.Email_Address__c=ApexPages.CurrentPage().getParameters().get('email'); 
         user.RequestforAccountin__c=  ApexPages.CurrentPage().getParameters().get('userRequestparam');
         //selectedApps = new String[]{};
         //initialize application list
         //Schema.DescribeFieldResult fieldResult =  New_User_Registration__c.RequestforAccountin__c.getDescribe();
         //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         //lstApplications = new List<SelectOption>();
         //selectedApps = new list<String>();
         //for(Schema.PicklistEntry f : ple)
         //  lstApplications.add(new SelectOption(f.getValue(), f.getLabel()));
         
         Step1 = true;
         Step2 = false;
         success = false;
         System.debug('BU::'+user.BU__c);
    }
    
   public void selectApps() { }
  //added by shridevi as Part of SIR 848- to make BU and BL fields visible and invisible depending on the role
   public void getdisplayFields()
    {
        if(user.Role__c == 'NXP BU/BL')
        {
            BLVisibility=true;
        }
        else
        BLVisibility=false;
    }
   
    public pageReference goToStep2()
    {
    
  
        if((user.RequestforAccountin__c != null) && (user.RequestforAccountin__c != ''))
        {
                if(String.valueOf(user.RequestforAccountin__c).toLowerCase().contains('salesforce'))
                {
                    validateFieldsForSalesforce();
                }
                else
                {
                        validateFields();
                }
        }
        else
        {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, NO_APP_SELECTED_ERROR ));
        }        
        return null;
        } 

    private void validateFields()
    { 
   
        if( user.First_Name__c != null && user.Last_Name__c != null && user.Email_Address__c != null && user.Region__c != null && user.Country__c != null && user.Job_Title__c != null && user.Phone_Number__c != null && user.Manager_Name__c != null && user.Manager_s_email__c != null && user.Role__c != null)
        {
                if(user.Role__c == 'NXP BU/BL')
            {
                if(user.BU__c != null && user.BL__c != null && user.BL__c !='' )
                {               
                    Step1 = false;
                    Step2 = true;
                }
                else
                {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'BU, BL : Can not be Empty. !!'));            
                }
           }
           else
           {
           
               user.BL__c=null;
               user.BU__c=null;    
               Step1 = false;
               Step2 = true;
           }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required Fields Can not be Empty. All Fields Are Required !!'));
        }
       }
       
        
    private void validateFieldsForSalesforce()
    {
        if(user.First_Name__c != null && user.Last_Name__c != null && user.Email_Address__c != null && user.Region__c != null && user.Country__c != null && user.Job_Title__c != null && user.Phone_Number__c != null && user.Manager_Name__c != null && user.Manager_s_email__c != null && user.Role__c != null && user.Available_Date_for_Training__c != null)
        {
            if(user.Role__c == 'NXP BU/BL')
                {
                        if(user.BU__c != null && user.BL__c != null && user.Are_you_a_DW_Approver__c != null )
                        {
                        if(user.Are_you_a_DW_Approver__c == 'No')
                        {
                                Step1 = false;
                                Step2 = true;
                        }
                        else if(user.Specify_Mags__c!=null)
                        { 
                                Step1 = false;
                                Step2 = true;
                        }
                        else
                        {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'BU, BL, Are you a DW Approver & Select MAGS fields are required : Can not be Empty. !!'));            
                        }
                                }
                        else
                                {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'BU, BL & Are you a DW Approver are required : Can not be Empty. !!'));            
                                }
                        }
                        else 
                        {
                                Step1 = false;
                                Step2 = true;
            }
        }
        else
        {
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
    public void save()
    {
//      if(user.First_Name__c != null && user.Last_Name__c != null && user.Email_Address__c != null && user.Region__c != null 
 //           && user.Country__c != null && user.Job_Title__c != null && user.Phone_Number__c != null && user.Manager_Name__c != null && user.Manager_s_email__c != null && user.Role__c != null && user.Available_Date_for_Training__c != null){

            user.Status__c= 'Submitted';           
            
            if(! String.valueOf(user.RequestforAccountin__c).toLowerCase().contains('salesforce'))
            {
                user.Are_you_a_DW_Approver__c = null;
                user.Specify_Mags__c = null;
                user.Available_Date_for_Training__c=null;
                user.Special_Requirements_in_Salesforce__c =null;
            }
            
            try
            {
            System.debug('Owner::'+user.ownerId);
                upsert user;
                Step1 = false;
                    Step2 = false;
                    success = true;
            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your application has been successfully submitted and a response to your request will arrive shortly. You will not be able to logon to the system until the registration has been approved. If you do not receive a response, Please contact Global Sales Application Support at globalsales.appsupport@nxp.com for any assistance.'));     
            }
            catch(DMLException ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
        //}else{
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required Fields Can not be Empty. All Fields Are Required !!'));
            
        //}   
    }
     //Moves to User registration page.   
     public pageReference register()
     {
     
        pageReference pg;
        if(user.RequestforAccountin__c=='Box')
           pg= new pageReference('/newuser/NewUserRegisteration?userRequestparam=Box');
       
        if(user.RequestforAccountin__c=='Brainshark')
           pg= new pageReference('/newuser/NewUserRegisteration?userRequestparam=Brainshark');
       
        if(user.RequestforAccountin__c=='GoToMeeting')
           pg= new pageReference('/newuser/NewUserRegisteration?userRequestparam=GoToMeeting');
        
        if(user.RequestforAccountin__c=='Training App')
           pg= new pageReference('/newuser/NewUserRegisteration?userRequestparam=Training%20App');
        
        System.debug('page reference::'+pg);
        return pg;
     } 
   
}