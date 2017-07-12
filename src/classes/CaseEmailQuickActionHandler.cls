global class CaseEmailQuickActionHandler implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global CaseEmailQuickActionHandler() {
    }
    public String ccInviteEmailAddresses {get;set;}
    public String bccSilentObservers {get;set;}
    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
    
        // Check if the quick action is the standard Case Feed send email actionare y
        for (Integer j = 0; j < defaults.size(); j++) {
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && 
               defaults.get(j).getTargetSObject().getSObjectType() == 
                   EmailMessage.sObjectType && 
               defaults.get(j).getActionName().equals('Case.Email') && 
               defaults.get(j).getActionType().equals('Email')) {
                   sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                   break;
            }
        }
        System.debug('defaults '+sendEmailDefaults);
        if (sendEmailDefaults != null) {
            Case c = [SELECT Status,subject, Reason,ContactEmail,EntitlementId FROM Case WHERE Id=:sendEmailDefaults.getContextId()];
        
            EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();    
            // Set to address to make sure each email goes for audit
            ccInviteEmailAddresses = '';
            bccSilentObservers = '';
            if(c.EntitlementId != null){
                getInvitees(c.EntitlementId);
            }
            emailMessage.FromAddress = 'tech.support@nxp.com';//UserInfo.getUserEmail();
            emailMessage.ToAddress = c.ContactEmail;
            emailMessage.Subject = c.Subject;
            emailMessage.CcAddress = ccInviteEmailAddresses;
            emailMessage.BccAddress = bccSilentObservers;
            
            /* 
            Set Template related fields 
            When the In Reply To Id field is null we know the interface 
            is called on page load. Here we check if 
            there are any previous emails attached to the case and load 
            the 'New_Case_Created' or 'Automatic_Response' template.
            When the In Reply To Id field is not null we know that 
            the interface is called on click of reply/reply all 
            of an email and we load the 'Default_reply_template' template
            */
            
            if (sendEmailDefaults.getInReplyToId() == null) {
                sendEmailDefaults.setTemplateId(getTemplateIdHelper(Label.CommunityEmailTemplateName));
                sendEmailDefaults.setInsertTemplateBody(true);
                sendEmailDefaults.setIgnoreTemplateSubject(false);
            } else {
                sendEmailDefaults.setInsertTemplateBody(false);
                sendEmailDefaults.setIgnoreTemplateSubject(true);
            }
        }
        System.debug('defaults after '+sendEmailDefaults);
    }
    
    private Id getTemplateIdHelper(String templateApiName) {
        Id templateId = null;
        try {
            templateId = [select id, name from EmailTemplate 
                          where developername = : templateApiName].id;   
        } catch (Exception e) {
            system.debug('Unble to locate EmailTemplate using name: ' + 
                templateApiName + ' refer to Setup | Communications Templates ' 
                    + templateApiName);
        }
        return templateId;
    }

	private void getInvitees(Id entitlementId){
		//Query all entitlement contacts against this entitlement
        for( Entitlement_Contact__c eContact: [SELECT Entitlement__r.CreatedBy.Email,Contact__r.Email from Entitlement_Contact__c where status__c = :CommunityConstantsUtility.ACCEPTED_STATUS and Entitlement__c = :entitlementId and Type__c != :CommunityConstantsUtility.ENTITLEMENTCONTACT_SILENT]){               
               //if it is blank just copy
               if(String.isBlank(ccInviteEmailAddresses) ){
                   ccInviteEmailAddresses = eContact.Contact__r.Email;
                   if(!ccInviteEmailAddresses.contains(eContact.Entitlement__r.CreatedBy.Email)){
                       ccInviteEmailAddresses =ccInviteEmailAddresses +';'+eContact.Entitlement__r.CreatedBy.Email;
                   }
               }else{
                   //otherwise separated by semicolon
                   ccInviteEmailAddresses  = ccInviteEmailAddresses +';'+ eContact.Contact__r.Email;
                }
        }
        for(Entitlement_Contact__c eContact: [SELECT Contact__r.Email from Entitlement_Contact__c where type__c = :CommunityConstantsUtility.ENTITLEMENTCONTACT_SILENT and Entitlement__c = :entitlementId]){
            if(String.isBlank(bccSilentObservers)){
                bccSilentObservers = eContact.Contact__r.Email;
            }
            else{
                bccSilentObservers = bccSilentObservers+';'+eContact.Contact__r.Email;
            }
        }
    }
    
}