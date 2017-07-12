global class CommunityApexEmailHandler implements Messaging.InboundEmailHandler {
    List<Entitlement_Contact__c> contactList= new List<Entitlement_Contact__c>();
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
          List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          EmailMessage objEmailMessage = new EmailMessage();
          String[] strSendTo =new String[]{email.fromAddress};
          
          mail.setToAddresses(strSendTo );
          OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where displayname='nxp technical support'];
          if( owea.size() > 0 ) 
                    {
                     mail.setOrgWideEmailAddressId(owea.get(0).Id);
                     }
          
          
          Case objCase = new Case();
          string strUniqueIdentifier;
          string strUniquePattern;
          string ContactNotFoundTemplate='Context_case_creation_Contact_not_found';
          string ContextNotFoundTemplate='Context_case_creation_Context_not_found';
          string ContextNotActiveTemplate='Context_case_creation_Context_not_active';
          id ContactNotFoundTemplateID;
          id ContextNotFoundTemplateID;
          id ContextNotActiveTemplateID;
          
          List<EmailTemplate>lstEmailTemplate=[Select Id, Name,DeveloperName From EmailTemplate 
                          Where (DeveloperName =:ContactNotFoundTemplate OR DeveloperName =:ContextNotFoundTemplate OR DeveloperName =:ContextNotActiveTemplate)];
        
         For(EmailTemplate em: lstEmailTemplate)                
     {
         if(em.DeveloperName == ContactNotFoundTemplate ) 
            {
               ContactNotFoundTemplateID= em.id;  
            }
         else if(em.DeveloperName == ContextNotFoundTemplate)
            {
               ContextNotFoundTemplateID= em.id;  
            }
          else if(em.DeveloperName == ContextNotActiveTemplate)
            {
               ContextNotActiveTemplateID= em.id;  
            }
         
     }
     mail.setTargetObjectId(UserInfo.getUserId());
     mail.setSaveAsActivity(false);
     mail.setTreatTargetObjectAsRecipient(False);
         
          RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
          if(email.subject != null)
          {
          objCase.Subject = email.subject;
              system.debug('email subject: '+email.subject);
          }
          else
          {
          objCase.Subject = 'No Subject Found In Email';
          }
          if(email.plainTextBody!= null)
          {
          objCase.Description = email.plainTextBody;
          }
          else
          {
          objCase.Description= 'No Description Found In Email';
          }
          
          objCase.RecordTypeId = tsRecordType.Id;
         
          
          List<User> lstUser = new List<User>();
          List<group> lstgroup = new List<group>();
          List<Contact> lstContact = new List<Contact>();
          
          
          String emailBody= objCase.Description;
          lstContact = [SELECT Id, Name, Email ,FirstName ,LastName,Phone,Company__c,Job_Title__c,Facebook__c,
                      Linkedin__c,Twitter__c,State_Province__c,Community_web_country__c,Web_Region__c
                            FROM Contact
                       WHERE Email = :email.fromAddress order By createddate DESC Limit 1];
           // send notification to email sender if sender is not in contact list                           
          If(lstContact.size() <= 0)
          {
           mail.setTemplateId(ContactNotFoundTemplateID);
           
           mails.add(mail);
           Messaging.sendEmail(mails);
           result.success = true;
           return result;
          }   
          
          if(lstContact.size() >= 0)
          {
          objCase.Community_Web_Country__c=lstContact[0].Community_web_country__c;
          objCase.Company__c=lstContact[0].Company__c;
          objCase.contactID=lstContact[0].id;
          objCase.Email__c= lstContact[0].Email;
          objCase.First_Name__c= lstContact[0].FirstName;
          objCase.Last_Name__c= lstContact[0].LastName;
          objCase.Phone_Number__c=lstContact[0].Phone;
          objCase.JobTitle__c= lstContact[0].Job_Title__c;
          objCase.Facebook__c=lstContact[0].Facebook__c;
          objCase.Linkedin__c=lstContact[0].Linkedin__c;
          objCase.Twitter__c=lstContact[0].Twitter__c;
          objCase.State_Province__c=lstContact[0].State_Province__c;
          objCase.Web_Region__c=lstContact[0].Web_Region__c;
          objCase.origin='Email';
              objCase.suppliedemail=email.fromAddress;
          
          objCase.Product_application__c='unknown';
          objCase.Project_Stage__c='Not Applicable';
          objCase.Expected_annual_unit_volume__c='Not Applicable';
           }                      
          Pattern objPattern1= Pattern.compile('(?i)'+label.Community_unique_pattern_for_email_service+'[a-z|A-Z|0-9]{1,8}[0-9]{6}');
          Matcher objMatcher1= objPattern1.matcher(emailBody);
         
          
          // send notification to email sender if sender sends wrong syntax for unique indentifier
          if(!objMatcher1.find())
            {
            mail.setTemplateId(ContextNotFoundTemplateID);
          
            mails.add(mail);
            Messaging.sendEmail(mails);
            result.success = true;
            return result;
            }
            
            else
            {
            strUniqueIdentifier=objMatcher1.group();
            }
          
          Pattern objPattern2= Pattern.compile('[a-z|A-Z|0-9]{1,8}[0-9]{6}');

          Matcher objMatcher2= objPattern2.matcher(strUniqueIdentifier);
          if(objMatcher2.find(1))
          {
          strUniquePattern=objMatcher2.group();
          system.debug('strUniquePattern'+strUniquePattern);
          }
          
          
          List<Entitlement> lstEntitlement = [select id,status,priority__c from entitlement where Entitlement_Pattern__c =: strUniquePattern];
          
          // send notification to email sender if context unique ID is not found in entitlement
          if(lstEntitlement.size() <= 0)
          {
          mail.setTemplateId(ContextNotFoundTemplateID);
          
           mails.add(mail);
           Messaging.sendEmail(mails);
           result.success = true;
           return result;
          }
          if(lstEntitlement.size() > 0)
          { 
              system.debug('listentSize'+lstEntitlement[0].id);
              objCase.Entitlementid=lstEntitlement[0].id;
              // send notification to email sender if entitlement is inactive
              if(lstEntitlement[0].status !='active')
              {
              mail.setTemplateId(ContextNotActiveTemplateID);
              
              mails.add(mail);
              Messaging.sendEmail(mails);
              result.success = true;
              return result;
              }
              objCase.Priority= lstEntitlement[0].priority__c;        
             // lstUser = [Select id from user where name =: lstEntitlement[0].Case_Owner_Auto_Routing__c]; 
          }
          
       /*   if(lstUser.size() > 0)
          {
              objcase.OwnerID = lstUser[0].id;
          }
          
          else
          {
              lstgroup = [select Id from Group where Name = : lstEntitlement[0].Case_Owner_Auto_Routing__c and Type = 'Queue'];
          }
          
          if(lstgroup.size() > 0)
          {
              objcase.OwnerID = lstgroup[0].id;
          }
          
          if(lstUser.size() == 0 && lstgroup.size() == 0)
          {
              lstgroup = [select Id from Group where name= 'TS L1 Inbox' and Type = 'Queue'];
              if(lstgroup.size() > 0)
              {
                  objcase.OwnerID = lstgroup[0].id;
              }
          }
          */
          boolean sendResult = false;
           try{
           insert objCase; 
           
           objEmailMessage.FromAddress=email.fromAddress;
           objEmailMessage.Incoming=true;
           objEmailMessage.Subject=email.subject;
           objEmailMessage.parentId=objCase.id;
           objEmailMessage.TextBody=email.plainTextBody;
           objEmailMessage.HtmlBody=email.htmlBody;
           objEmailMessage.ToAddress='FAEApexEmailService';
           objEmailMessage.status='0';
           insert objEmailMessage;
           
          /* Case objCaseUpdate = [select status from case where id=:objCase.id];
           objCaseUpdate.status='new';
           update objCaseUpdate;*/
           if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) 
           {
            for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) 
            {
            Attachment attachment = new Attachment();
           // attach to the newly created contact record
           attachment.ParentId = objEmailMessage.Id;
           attachment.Name = email.binaryAttachments[i].filename;
           attachment.Body = email.binaryAttachments[i].body;
           insert attachment;  
                
           }   
           }
           
           if (email.textAttachments!= null && email.textAttachments.size() > 0) 
           {
            for (integer i = 0 ; i < email.textAttachments.size() ; i++) 
            {
            Attachment attachment = new Attachment();
           // attach to the newly created contact record
           attachment.ParentId = objEmailMessage.Id;
           attachment.Name = email.textAttachments[i].filename;
           attachment.Body = Blob.ValueOf(email.textAttachments[i].body);
           insert attachment; 
                
           }  
           }
           system.debug('case inserted successfully '+objCase.id);
               
           }
           
            catch(System.DMLException e)
            {
            ApexPages.addMessages(e);
          system.debug(e);

            } 
          sendResult = sendCaseCreateNotification([select Id, Subject, Body from EmailTemplate where DeveloperName = 'NXPCommunityCaseCreateNotification'], objCase);    
          result.success = sendResult;
          return result;
      }
    
    /*
    * @name         : sendCaseCreateNotification
    * @description  : to send the email notification to active participants and observers.
    * @ Input param : EmailTemplate, Case
    * @ return type : boolean
    */ 
    boolean sendCaseCreateNotification(EmailTemplate emailTemplate, Case objCase){
    boolean result = true;
    Id entitlementId = objCase.Entitlementid;
    String threadId;
        system.debug('ent id: '+entitlementId);
    Case caseDataRecord = new Case();
        if(objCase.id != null){
        caseDataRecord = [SELECT id, caseNumber, CreatedBy.Email, Email__c, EntitlementId, Subject, Description, Entitlement.Name, Entitlement.CreatedBy.Name from Case where id =:objCase.id];
        threadId = getThreadId(caseDataRecord.id);
        }
    if(String.isBlank(entitlementId))
    entitlementId  = caseDataRecord.entitlementID;
    // process the merge fields
    String subject = emailTemplate.Subject;
    String plainBody = emailTemplate.Body;  
     //Query the org wide email address
   
    List<OrgWideEmailAddress> defaultOrgAddress = [select id, Address, DisplayName from OrgWideEmailAddress WHERE displayName=:Label.CommunityDefaultOrgName];
    List<Messaging.Singleemailmessage> emailLst = new List<Messaging.Singleemailmessage>();
    contactList = [select Contact__c, Contact__r.Email, Contact__r.Name, Status__c, Type__c, Unique_Email_Address__c, Entitlement__c, Name from Entitlement_Contact__c where Entitlement__r.Id=:caseDataRecord.EntitlementId];

        system.debug('292: contactList: '+contactList);
        //Entitlement__c in (select EntitlementId from Case where id=:caseDataRecord.Id)];
        
        if( contactList.size()>0 ){
        system.debug('296: contactList size: '+contactList.size());
    for(Entitlement_Contact__c con: contactList){    
    //initializing plainBody everytime so that correct name is replaced
   
    plainBody = emailTemplate.Body;
    if((con.status__c == null || con.Status__c.equalsIgnoreCase(CommunityConstantsUtility.ACCEPTED_STATUS)) && caseDataRecord.Email__c !=  con.Contact__r.Email) 
    
    
     {
     plainBody = plainBody.replace('{!Contact.FirstName} {!Contact.LastName}', con.Contact__r.Name);
    
    plainBody = plainBody.replace('{!$Label.CommunityURL}', Label.CommunityURL);
    if(caseDataRecord.CaseNumber!= null){
    plainBody = plainBody.replace('{!Case.CaseNumber}', caseDataRecord.CaseNumber);
    plainBody = plainBody.replace('{!Case.Subject}', caseDataRecord.Subject);
    plainBody = plainBody.replace('{!Case.Description}', caseDataRecord.Description);
    subject= subject.replace('{!Case.Subject}', caseDataRecord.Subject);
    subject =   subject.replace('{!Case.CaseNumber}', caseDataRecord.CaseNumber);
    subject =   subject.replace('{!Case.Thread_Id}', threadId);
    plainBody =   plainBody.replace('{!Case.Thread_Id}', threadId);
    plainBody = plainBody.replace('{!Entitlement.Name}', caseDataRecord.Entitlement.Name);
        result = true;
    }
    else{
    if(!defaultOrgAddress.isEmpty())
    plainBody = plainBody.replace('{!Organization.Name}', defaultOrgAddress[0].displayName);
    }
    //build the email message
    Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
    if(!defaultOrgAddress.isEmpty())
    email.setOrgWideEmailAddressId(defaultOrgAddress.get(0).Id);

    email.setToaddresses(new List<String>{con.Contact__r.Email});
    email.setWhatId(caseDataRecord.id);
    email.setSubject(subject);
    email.setPlainTextBody(plainBody);
    emailLst.add(email);
    }
    }
            result = true;
    }
        else
        {
            
            system.debug('Contact list is empty');
        }
        
    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailLst);
        //results.get(0).success
        return result;
    }
/*
    * @name         : getThreadId
    * @description  : to generate the thread ID
    * @ Input param : void
    * @ return type : void
    */ 
    private String getThreadId(Id caseId) {
        return 
            'ref:_' + shortenId(UserInfo.getOrganizationId()) +
            '._'    + shortenId(caseId) +  ':ref';
    }

/*
    * @name         : shortenID
    * @description  : to generate the reference ID
    * @ Input param : void
    * @ return type : void
    */ 
    private static String shortenID(String idValue) {
        String[] keys = idValue.left(15).split('');
        while(keys.size() > 5 && keys[5] == '0') {
            keys.remove(5);
        }
        return String.join(keys,'');
    }
}