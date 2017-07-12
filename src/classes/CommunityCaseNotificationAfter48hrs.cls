/***************************************************************************************************
@Created By :      Amrutha R
@Created Date:     23 Jun 2016
@Description:      Batch class to notify assigned to if case status is not changed 
				   for 48 hours.
****************************************************************************************************/

global class CommunityCaseNotificationAfter48hrs implements Database.batchable<sObject>
{
    Private Static Final string AssignedTo_Email_Template='NNXP_Case_Escalation_to_Assigned_to';
    Private Static Final string TS_Community ='TS_Community';
	Public Static Id emailAssignedTo_Id;
    Private Static Final String OrgWide_Address='NXP Technical Support';
    Public Static List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([Select Id,status,owner.email,Assigned_to__r.id,Assigned_to__r.email,
                                         notification_hours__c,owner.name,ownerid,CaseNumber,assigned_to__c,
                                         assigned_to__r.name,recordType.developername from case where 
                                         recordType.developername=: TS_Community and assigned_to__c!=null
                                         and status NOT IN ('Answered Back','Close') and notification_hours__c=48]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> lstScope)
    {
        emailAssignedTo_Id=[Select Id, Name,DeveloperName From EmailTemplate 
                          	Where (DeveloperName =:AssignedTo_Email_Template)].id;
        OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where displayname=: OrgWide_Address];

        if(lstScope.size()!=0)
        {
            for(sObject objScope :lstScope)
        	{
            	Case objCase= (Case)objScope;
            	String[] toAddresses;
            	Messaging.SingleEmailMessage mailOwner = new Messaging.SingleEmailMessage();
            	mailOwner.settargetObjectid(objcase.Assigned_to__c);
            	mailOwner.setSaveAsActivity(false);
            	mailOwner.setWhatID(objcase.id);
            	mailOwner.setTemplateId(emailAssignedTo_Id);
                if (owea.size() > 0) 
                {
                   mailOwner.setOrgWideEmailAddressId(owea.get(0).Id);
                }
            	mails.add(mailOwner);
        	}
        	try
        	{
            	if(mails.size()!=0)
            	{
            		Messaging.sendEmail(mails);
            	}
        	}
        	catch(System.EmailException ex)
        	{
            	system.debug('+++Error'+ex);     
        	}
        }
        
    }
    
    
    global void finish(Database.BatchableContext BC)
    {     
       
    } 
}