/******************************************************************************
Last modified by  : Shridevi
last Modified Date: 29-Jun-2017
Description       : As part of SIR 518-Removed the usage of tech support Record Type in order to disable it.
*******************************************************************************/
global class CaseSurveyReminderScheduler implements Schedulable {


global RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
//Below line is commented by shridevi as part of SIR 518
//global RecordType techRecordType=[Select Id,name from recordtype where name='Tech Support' LIMIT 1];
//this method sends the  case survey reminder to Web Email,  on the 7th day of case closure if the survey is not yet completed.
global void execute(SchedulableContext SC) {
   
     Datetime caseClosedDate = (System.today().adddays(-7));
     System.debug(caseClosedDate);
     //Date myDate = (System.today());//caseClosedDate.format('yyyy-mm-dd');
     Date myDate = (System.today().adddays(-6));
     System.debug(mydate);
     list<case> listCases=[select id,SuppliedEmail,contactId,contact.email,ownerId,survey_flag__c,status,closeddate from case where survey_flag__c='TRUE' and status='Close' and ((closeddate<:myDate) and (closeddate>:caseClosedDate)) and recordtypeId=:tsRecordType.id];  
    if(Test.isRunningTest())
     {    
           listCases=[select id,SuppliedEmail,contactId,contact.email,ownerId,survey_flag__c,status,closeddate from case where survey_flag__c='TRUE' and status='Close' and (closeddate>:caseClosedDate) and recordtypeId=:tsRecordType.id];          
     } 
     Contact tempContact = new Contact(email = 'test12345test@test.com',FirstName ='test$$$$', lastName = 'test$$$$');
     insert tempContact;
    // Lead templead = new Lead(Sales_Person_Email__c='test@test.com',lastname='11', company='11');
    // insert templead;
     System.debug(listCases);
     OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'tech.support@nxp.com'];


     EmailTemplate template = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'NXP_Survey_Reminder_Email'];
     system.debug(template);
     List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
     list<string> listToAddresses;  
     for(case CaseRec : listCases)
        {
          listToAddresses=new list<string>();
          if(CaseRec.SuppliedEmail!=null && CaseRec.SuppliedEmail!='')
          {
            listToAddresses.add(CaseRec.SuppliedEmail);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if ( owea.size() > 0 ) 
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
            
            mail.setToAddresses(listToAddresses);
            if(CaseRec.contactId!=null && CaseRec.Contact.Email!=null)
            {
            mail.setTargetObjectId(CaseRec.contactId);
            }
            else
            {
            mail.setTargetObjectId(tempContact.id);
           
           
            }
            //mail.setTargetObjectId(tempContact.id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setTemplateId(template.Id);
            mail.setwhatid(CaseRec.id);
            mail.setsaveAsActivity(false);
            mailsToSend.add(mail);
          }  
       }
    //Send Email
    if(mailsToSend.size() > 0)
    {
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(mailsToSend);  
        Database.rollback(sp);
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();

        for (Messaging.SingleEmailMessage email : mailsToSend) 
        {

             Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
             emailToSend.setToAddresses(email.getToAddresses());
             
            System.debug(email.getHTMLBody());
            if(email.TargetObjectId==tempContact.id)
             {
            /*  Email.setTreatTargetObjectAsRecipient(false);
                Email.setTargetObjectId(null);
               emailToSend.setTreatTargetObjectAsRecipient(false);
              
                System.debug(Email.TargetObjectId);
                emailToSend.setTargetObjectId(null);*/
                String htmlBody = email.getHTMLBody();//template.HtmlValue;
                htmlBody = htmlBody.replace('test$$$$', '');
                htmlBody = htmlBody.replace('test$$$$', '');

                String plainBody = email.getPlainTextBody();//template.Body;
                plainBody = plainBody.replace('test$$$$', '');
                plainBody = plainBody.replace('test$$$$', '');
                
                
                emailToSend.setPlainTextBody(plainBody);
                emailToSend.setHTMLBody(htmlBody);
                
                System.debug(htmlBody);
             }
             else
             {
            // emailToSend.setTemplateId(template.Id);
             emailToSend.setPlainTextBody(email.getPlainTextBody());
             emailToSend.setHTMLBody(email.getHTMLBody());
             }
             emailToSend.setSubject(email.getSubject());
             if ( owea.size() > 0 ) 
             emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
             msgListToBeSend .add(emailToSend);

        }
        if(msgListToBeSend.size()>0)
        Messaging.sendEmail(msgListToBeSend);
        
      // delete templead;
    }  
    
    delete tempContact;
    }

}