/*****************************************************************************
* Created By   : Shridevi badiger
* Created Date : 16 May 2016
* Description  : Trigger handler for New User Registration object, which contains the method 
                 to send an eMail notification when the request gets Rejected.
--------------------------------------------------------------------------------------------                 
Modified By     :    Harish Gowda N
Modified Date   : 30 Mar2018
Description     : SFDC-1171-Brainshark New User Registration form- adding Rejection Mail for Brainshark New user Registration form.
********************************************************************************************/
public class NewUserRegistrationTriggerHandler implements Itrigger 
{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
    private static Final string TYPE_New_User_Reg='New_User_Registeration';
    private static Final String TYPE_Apttus_New_User_Reg='Apttus_New_User_Registeration';
    private static Final string TYPE_Brainshark_New_User_Reg='Brainshark_New_User_Registration';
    public static Id newUserReg_Id;
    public static Id apptusNewUserReg_Id;
    public static Id BrainsharkNewUserReg_Id;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        /*if (TriggerSettings__c.AccountTriggerDisabled__c = true)
            return true;
        else*/
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) 
    {
        
    }
 
    public void beforeUpdate(map<Id, SObject> newItems, map<Id, SObject> oldItems) {}
 
    public void beforeDelete(map<Id, SObject> oldItems) {}
 
    public void afterInsert(map<Id, SObject> newItems) {}
 
    public void afterUpdate(map<Id, SObject> newItems, map<Id, SObject> oldItems) 
    {
        SendRejectionEmail(newItems,oldItems);
    }
    
    public void SendRejectionEmail(map<Id, SObject> newItems, map<Id, SObject> oldItems) 
    {
        map<Id, New_User_Registeration__c> newRegUsermap = new map<Id, New_User_Registeration__c>();
        map<Id, New_User_Registeration__c> oldRegUserMap= new map<Id, New_User_Registeration__c>();
        newRegUserMap = (map<Id, New_User_Registeration__c>)newItems;
        oldRegUserMap = (map<Id, New_User_Registeration__c>)oldItems;
        list<id> listRequestId=new list<id>();
        set<String> setUserEmail= new set<String>();
        list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();
        list<id> listuserId=new list<id>();
         map<id,User> mapUser= new map<id,User>();
        list<New_User_Registeration__c> newUserRegList= new list<New_User_Registeration__c>();
        map<id,ProcessInstancestep>  mapStep=new  map<id,ProcessInstancestep>();
     
        for(Id id: newRegUserMap.keySet())
        {
           newUserRegList.add(newRegUserMap.get(id));
        }
     
        for(recordType rt:[Select Id, Name,DeveloperName From RecordType 
                        Where IsActive=true AND (SobjectType = 'New_User_Registeration__c' and 
                        (DeveloperName =:TYPE_New_User_Reg OR DeveloperName =:TYPE_Apttus_New_User_Reg OR DeveloperName =:TYPE_Brainshark_New_User_Reg ))])
        {
         if(rt.DeveloperName == TYPE_New_User_Reg ) 
            {
               newUserReg_Id= rt.id;  
            }
         else if(rt.DeveloperName == TYPE_Apttus_New_User_Reg)
            {
               apptusNewUserReg_Id= rt.id;  
            }
            else if(rt.DeveloperName == TYPE_Brainshark_New_User_Reg)
            {
               BrainsharkNewUserReg_Id= rt.id;  
            }
        } 
    
     
        for (New_User_Registeration__c request : newUserRegList)
        {
        New_User_Registeration__c oldNewUserRegRec = oldRegUserMap.get(request.Id);
       if(request.status__c=='Rejected' && oldNewUserRegRec.status__c!='Rejected')
       {
       if(request.RecordTypeId == apptusNewUserReg_Id)
       {
         listuserId.add(request.ownerId);
      // listuserId.add(request.createdbyId);
       }
       if(request.RecordTypeId == BrainsharkNewUserReg_Id)
       {
         listuserId.add(request.ownerId);
      // listuserId.add(request.createdbyId);
       }
       
       listRequestId.add(request.Id);
       }
       
     }
    ProcessInstancestep instancesteps=new ProcessInstancestep();
    if(listRequestId.size()!=0)
     {
      list<ProcessInstance> listProcessInstance=[SELECT Id, targetObjectId,(SELECT Id, StepStatus, Comments FROM Steps where StepStatus=:'Rejected'OR StepStatus=:'Approved')FROM ProcessInstance where targetObjectId in:listRequestId];
     
      if(listProcessInstance.size()!=0)
      {
         
         for(ProcessInstance instance :listProcessInstance)
          {
                for(ProcessInstanceStep step: instance.Steps)
                {
            
                    if(step.StepStatus=='Rejected')
                    {
                       mapStep.put(instance.targetObjectId,step);
                    }
                }
               
          }
      }
    } 
      System.debug('mapStep::'+mapStep);
      if(listuserId!=null && listuserId.size()!=0)
      mapUser=new map<id,user>([Select id, email,name from user where id in:listuserId]);
      string Url;
      for(New_User_Registeration__c request : newUserRegList) 
        {
            list<String> strSendTo =new list<String>();
            if(mapStep.size()!=0)
            {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           
                     
            if(request.RecordTypeId == newUserReg_Id )
            { 
             strSendTo.add(request.Email_Address__c);                     
             mail.setToAddresses(strSendTo);
             system.debug('strSendTo:'+strSendTo);
             mail.setSubject( request.RequestforAccountin__c +' New user registration request has been rejected.' );
             Url='<html lang="ja"><body>'
                                +'Dear '+request.First_Name__c+' '+request.Last_Name__c+ ' ,<br><br>'
                                +'Your new user registration request has been rejected, due to the following reason.<br>'
                                +'<br>Comments:'+mapStep.get(request.id).comments+'<br><br>'
                                +'In case of any issue please contact Support&Help : https://nxpsemiconductors.secure.force.com/welcome/Landing_Page?success=1  -> HELP -> fill the required info.  and SUBMIT <br><br>'
                                + 'Best regards,<br>'
                                +'<a href="https://nxpsemiconductors.secure.force.com/welcome/Landing_Page?success=1"> Data Admin </a></body></html>';
                       
             mail.setHtmlBody(url);
            }
           
            if(request.RecordTypeId == apptusNewUserReg_Id && mapUser.size()!=0)
            {
            strSendTo.add(mapUser.get(request.ownerId).Email);
            // strSendTo.add(mapUser.get(request.createdbyId).Email);
            mail.setToAddresses(strSendTo);         
            mail.setSubject( 'Apttus New user registration request has been rejected.' );
            Url='<html lang="ja"><body>'
                                +'Dear '+mapUser.get(request.ownerId).name+' ,<br><br>'
                                +'Your Apttus new user registration request has been rejected, due to the following reason.<br>'
                                +'<br>Comments:'+mapStep.get(request.id).comments+'<br><br>'
                                +'In case of any issue please contact Support&Help : https://nxpsemiconductors.secure.force.com/welcome/Landing_Page?success=1  -> HELP -> fill the required info.  and SUBMIT <br><br>'
                                + 'Best regards,<br>'
                                +'<a href="https://nxpsemiconductors.secure.force.com/welcome/Landing_Page?success=1"> Data Admin </a></body></html>';
             mail.setHtmlBody(url);     
            }
            //Rejection Email For Brainshark New User Form
            if(request.RecordTypeId == BrainsharkNewUserReg_Id && mapUser.size()!=0)
            {
            strSendTo.add(mapUser.get(request.ownerId).Email);
            // strSendTo.add(mapUser.get(request.createdbyId).Email);
            mail.setToAddresses(strSendTo);         
            mail.setSubject( 'Brainshark New user registration request has been rejected.' );
            Url='<html lang="ja"><body>'
                                +'Dear '+mapUser.get(request.ownerId).name+' ,<br><br>'
                                +'Your Brainshark new user registration request has been rejected, due to the following reason.<br>'
                                +'<br>Comments:'+mapStep.get(request.id).comments+'<br><br>'
                                +'In case of any issue please contact Support&Help : https://nxpsemiconductors.secure.force.com/welcome/Landing_Page?success=1  -> HELP -> fill the required info.  and SUBMIT <br><br>'
                                + 'Best regards,<br>'
                                +'<a href="https://nxpsemiconductors.secure.force.com/welcome/Landing_Page?success=1"> Data Admin </a></body></html>';
             mail.setHtmlBody(url);     
            }
            
            mails.add(mail);
           }
         }
         if(mails.size()!=0)
         {
           Messaging.sendEmail(mails);
         }
    }
 
    public void AfterDelete(map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(map<Id, SObject> oldItems) {}
}