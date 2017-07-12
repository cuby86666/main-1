/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     26 June 2016
Description :      Class for creating Context
****************************************************************************************************/
public without sharing class CommunityCreateContextController{

    public Entitlement developmentEntitlement  {set;get;}
    public Entitlement supportEntitlement  {set;get;}
    public Entitlement contractEntitlement  {set;get;}
    public Entitlement nonTechnicalEntitlement  {set;get;} 
    private Id currentEntitlementId;
    public boolean noContextVar   {set;get;}
    public Id caseId              {set;get;}       
    User userRecord;
    Id accountId; 
    public CommunityCreateContextController(){
        
        //caseId = ApexPages.currentPage().getParameters().get('caseId');
        //To get the logged in user's accountId and contactId
        userRecord = [SELECT accountId, contactId,FirstName, LastName,Email, Contact_Id__c from User where id = :UserInfo.getUserID()];
        accountId = userRecord.accountId;
        
        //if logged in user is not a customer community user
        if(userRecord.accountId == null){
            
            CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
            
            if(!String.isBlank(cs.CommunityUserAccountId__c))
            accountId = cs.CommunityUserAccountId__c;
        }
        
        //initialize the four entitlement types
        developmentEntitlement = initializeEntitlement(developmentEntitlement);
        supportEntitlement = initializeEntitlement(supportEntitlement);
        contractEntitlement = initializeEntitlement(contractEntitlement);
        nonTechnicalEntitlement = initializeEntitlement(nonTechnicalEntitlement);
        
    }
    
     /*
    * @name         : initializeEntitlement
    * @description  : initailizes the entitlement
    * @ Input param : Entitlement currentEntitlement
    * @ return type : void
    */
    private Entitlement initializeEntitlement(Entitlement currentEntitlement) {
        
        currentEntitlement = new Entitlement();
        currentEntitlement.accountId = accountId ;
        currentEntitlement.Type = CommunityConstantsUtility.ENTITLEMENT_FREETYPE;
        currentEntitlement.StartDate = Date.Today();
        return currentEntitlement;
        
    }
    
    /*
    * @name         : saveDevelopmentEntitlement
    * @description  : saves the Development Entitlement record
    * @ Input param : Null
    * @ return type : PageReference
    */
    public PageReference saveDevelopmentEntitlement(){
        String redirect = ApexPages.currentPage().getParameters().get('redirect');
        
        developmentEntitlement.Entitlement_Sub_Type__c = CommunityConstantsUtility.ENTITLEMENT_DEVELOPMENT;
    
        insert developmentEntitlement ;
    
        createEntitlementContact(developmentEntitlement.id);
    
        
        PageReference pg;
         if(String.isBlank(caseID)  || redirect=='true'){
         pg = Page.CommunityContextPage;
       
        }        
        else{
         pg = Page.CommunityNXPCreateInviteWizard;
         pg.getParameters().put('entitlementId',currentEntitlementId);
        }
         pg.setRedirect(true);
        return pg;
    
    }
    
    /*
    * @name         : saveSupportEntitlement
    * @description  : saves the Support Entitlement record
    * @ Input param : Null
    * @ return type : PageReference
    */
    public PageReference saveSupportEntitlement(){
        String redirect = ApexPages.currentPage().getParameters().get('redirect');
        
        supportEntitlement.Entitlement_Sub_Type__c = CommunityConstantsUtility.ENTITLEMENT_SUPPORT;
    
        insert supportEntitlement ;
    
        createEntitlementContact(supportEntitlement.id);
    
        PageReference pg;
       
         if(String.isBlank(caseID) || redirect =='true'){
       pg = Page.CommunityContextPage;
        }           
         else{
         pg = Page.CommunityNXPCreateInviteWizard;
         pg.getParameters().put('entitlementId',currentEntitlementId);
        }
         pg.setRedirect(true);
        return pg;
    
    }

    /*
    * @name         : saveContractEntitlement
    * @description  : saves the Contract Entitlement record
    * @ Input param : Null
    * @ return type : PageReference
    */
    
    public PageReference saveContractEntitlement(){
    
        contractEntitlement.Entitlement_Sub_Type__c = CommunityConstantsUtility.ENTITLEMENT_CONTRACT;
    
        insert contractEntitlement ;
        
        createEntitlementContact(contractEntitlement.id);
    
        PageReference pg ;
       
         if(String.isBlank(caseID)){
       pg=  Page.CommunityContextPage;
        }            
         else{
         pg = Page.CommunityNXPCreateInviteWizard;
         pg.getParameters().put('entitlementId',currentEntitlementId);
        }
         pg.setRedirect(true);
        return pg;
    }
    
    
    
    /*
    * @name         : savenonTechnicalEntitlement
    * @description  : saves the Non Technical Entitlement record
    * @ Input param : Null
    * @ return type : PageReference
    */
    
    public PageReference savenonTechnicalEntitlement(){
    
        String redirect = ApexPages.currentPage().getParameters().get('redirect');
        nonTechnicalEntitlement.Entitlement_Sub_Type__c = CommunityConstantsUtility.ENTITLEMENT_NONTECHNICAL;
    
        insert nonTechnicalEntitlement  ;
    
        createEntitlementContact(nonTechnicalEntitlement.id);
        
        PageReference pg;
         if(String.isBlank(caseID) || redirect == 'true'){
         pg = Page.CommunityContextPage;
       
        }        
        else{
         pg = Page.CommunityNXPCreateInviteWizard;
         pg.getParameters().put('entitlementId',currentEntitlementId);
        }
         pg.setRedirect(true);
        return pg;
    }
    
    /*
    * @name         : createEntitlementContact
    * @description  : create the entitlement contact record
    * @ Input param : Null
    * @ return type : PageReference
    */  

    private void createEntitlementContact(Id entitlementId){
        
       currentEntitlementId = entitlementId;
        Entitlement_Contact__c entContact = new Entitlement_Contact__c();
       
        entContact.Entitlement__c = entitlementId;
       
        entContact.Type__c = CommunityConstantsUtility.ENTITLEMENTCONTACT_OWNER;
       
        if( userRecord.contactId != null){
       
            entContact.Contact__c = userRecord.contactId;
       
        }
        else{
            
            if(!String.isBlank(userRecord.Contact_Id__c))
            {
                entContact.Contact__c = userRecord.Contact_Id__c;
            }
            else{
            
                //query if there is any existing contact with the user's Email
                List<Contact> contactRecords = [SELECT id from contact where Email=:userRecord.Email limit 1];
                if( !contactRecords.isEmpty() ){
                    
                    //update the User and Contact records
                    entContact.Contact__c = contactRecords[0].id;
                    userRecord.Contact_Id__c = contactRecords[0].id;
                    
                }
                else{
                    Contact userContact = new Contact( FirstName = userRecord.FirstName,
                                                       LastName = userRecord.LastName,
                                                       Email = userRecord.Email,
                                                       accountId = accountId
                                                     );
                   insert userContact ;
                   entContact.Contact__c = userContact.id;
                   userRecord.Contact_Id__c = userContact.id;
                                                     
                    
                }
                update userRecord;
            }
        }
        insert entContact;
        
         if(!String.isBlank(caseID)){
            Case caseRec = new Case(Id = caseID);
            caseRec.EntitlementId = entitlementId;
            
            if(String.isBlank(userRecord.contactID))
            caseRec.ContactId = userRecord.Contact_Id__c;
            else
             caseRec.ContactId =userRecord.contactId;
            update caseRec;
           // mController.currentContext = new Entitlement();
           // mController.currentContext.id= entitlementId;
        }
    }
}