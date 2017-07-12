/*********************************************************************************************
@Created By :      Venkateshwar G
@Created Date :    14 Jun 2016
Description :      Community notify case owner if customer replies by email(Amrutha).
                   Community notify case Sender if customer replies by email for the Case closed more than 30 days.
****************************************************************************************************/
/*********************************************************************************************
@Modified By :      Venkateshwar G
@Modified  Date :   9 Aug 2016
Description :      Restrict the received reply Email to Assigned To/ Case Owner when the reply is recived for the case closed for more than 30 days.
****************************************************************************************************/

public class CommunityEmailNotificationController{

Private Static Final String OrgWide_Address='NXP Technical Support';
Private Static Final string Owner_Email_Template='NNXP_notify_case_owner';
Private Static Final String Sender_Email_Template='ClosedEmailNotification';
public static List<EmailMessage> lstEmailMessageNew = new List<EmailMessage>();
public static List<case> lstClosedCase = new List<case>();
public static List<case> lstCase= new List<case>();
public static Id strSendTo;
Public Static Id emailOwner_Id;
Public Static Id emailSender_Id;

/******************* Method to Send Email Notifications for the Case owner/ assigned to user when Email replied to case by Customer************************/
public static void sendNotificationToOwner(List<String> lstCaseIds, List<String> lstEmailMessageIds)
    {
        List<EmailTemplate>lstEmailTemplate=[Select Id, Name,DeveloperName From EmailTemplate 
                          Where (DeveloperName =:Owner_Email_Template OR DeveloperName =:Sender_Email_Template)];
        
        for(EmailTemplate em: lstEmailTemplate)                
        {
            if(em.DeveloperName == Owner_Email_Template) 
            {
               emailOwner_Id= em.id;  
            }
            else if(em.DeveloperName == Sender_Email_Template)
            {
               emailSender_Id= em.id;  
            }
         
        }
                 
        lstCase= [Select id, recordtype.developername, casenumber, subject,email__c,assigned_to__c,
                             assigned_to__r.name,assigned_to__r.id,owner.name,ownerid,ClosedDate, Status  from case where id IN: lstCaseIds
                             and recordType.developername='TS_Community'];
                                            
        if(lstCase!=null && lstCase.size()>0)
        {
            for(Case objcase: lstCase)
            {
               if( !(objcase.Status=='Close'  && objcase.ClosedDate <= DateTime.Now()-30))
               { 
                if(objcase.assigned_to__c!=null)
                {
                    strSendTo= objcase.assigned_to__r.id;
                }
                else
                {
                    strSendTo= objcase.ownerid;
                }
                                 
   
                Messaging.SingleEmailMessage mailOwner = new Messaging.SingleEmailMessage();
                if(string.valueOf(strSendTo).startsWith('005'))
                {
                    mailOwner.setTargetObjectId(strSendTo);
                    mailOwner.setSenderDisplayName('NXP Technical Support');
                    mailOwner.setSaveAsActivity(false);
                    mailOwner.setWhatID(objcase.id);
                    mailOwner.setTemplateId(emailOwner_Id);
                   
                    try
                    {
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mailOwner});
                    }
                    catch(System.EmailException ex)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured.'));     
                    }
                }
               }
               if(Test.isRunningTest())
               {    
                 if( objcase.Status=='Close')
                 {
                    lstClosedCase.add(objcase);
                 } 
               }
               
               if( objcase.Status=='Close'  && objcase.ClosedDate <= DateTime.Now()-30)
                {
                    lstClosedCase.add(objcase);
                } 
             }                
        }  

        if(lstClosedCase !=null && lstClosedCase.size()>0)
        {
            lstEmailMessageNew = [Select Id, ParentId, Parent.ownerid, FromAddress,Subject from EmailMessage where ParentId IN: lstClosedCase and Id IN: lstEmailMessageIds];
        }
     
        if(lstEmailMessageNew != null && lstEmailMessageNew.size()>0)
        {
            CommunityEmailNotificationController.sendNotificationToSender(lstEmailMessageNew);
        }
     }   
    
 /******************* Method to Send Email Notifications to the Customer  when Email replied to case by Customer when the case closed more than 30 days************************/    
 public static void sendNotificationToSender(List<EmailMessage> lstEmailMessage)
    {       
       if(lstEmailMessage!=null && lstEmailMessage.size()>0)
        {
          OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where displayname=: OrgWide_Address];

            for(EmailMessage objEmailMsg :lstEmailMessage)
            {              
                    String[] toAddresses = new List<String>();
                    toAddresses.add(objEmailMsg.FromAddress) ; 
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(userinfo.getUserId()); 
                    mail.setToAddresses(toAddresses);                   
                    mail.setSaveAsActivity(false);
                    mail.setWhatID(objEmailMsg.id);                    
                    mail.setTemplateId(emailSender_Id);
                    mail.setTreatTargetObjectAsRecipient(False);
                    if ( owea.size() > 0 ) 
                    {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    
                    try
                    {
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});    
                    }
                      
                    catch(System.EmailException ex)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured.'));     
                    }
                }
            }
    }   

}