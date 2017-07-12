/*********************************************************************************************
@Created By :      Amrutha R
@Created Date :    25 Apr 2016
Description :      Community notify case owner if customer replies by email.
****************************************************************************************************/
/*********************************************************************************************
@Modified By :      Venkateshwar G
@Created Date :    14 Jun 2016
Description :      Community notify case owner if customer replies by email.
                   Moving the logic in the "CommunityEmailNotificationController" class.
****************************************************************************************************/

trigger CommunityEmailMessage_AfterTrigger on EmailMessage (After insert) 
{
    Public List<String> lstCaseIds= new List<String>();
    Public List<String> lstEmailMsgIds= new List<String>();
    for(EmailMessage objEmailMsg: trigger.new)
    {   
   
        if(objEmailMsg.Incoming==true)
        {   
            lstCaseIds.add(objEmailMsg.parentid);
            lstEmailMsgIds.add(objEmailMsg.Id);
        }
        
    }
    if(lstCaseIds.size()>0 && lstCaseIds!= null)
    {   
        //method to send email to case owner/assigned when customer replies by email
        CommunityEmailNotificationController.sendNotificationToOwner(lstCaseIds,lstEmailMsgIds);
       
    }
    
    
    
}