/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     26 June 2016
Description :      controller class for creating Context (SIR-825)
****************************************************************************************************/
public without sharing class CommunityContextController{

    public Map<Id, List<Case>> entitlementCases                                                    {set;get;}   // to display cases against entitlements
   // public String currentStep {set;get;}
    public CommunityContextController parentController                                           {set;get;}
  //  public Map<ID, case> caseMap                                                                   {set;get;}   // to display case detail 
    public Map<Id, List<Entitlement_Contact__c>> participantEntitlementContacts                    {set;get;}   // to display participants
    public Map<Id, List<Entitlement_Contact__c>> observerEntitlementContacts                       {set;get;}   // to display observers
    public Map<Id, List<Entitlement_Contact__c>> entitlementContacts                               {set;get;}   // to display entitlemet contacts 
    public Map<Id, boolean> participantInviteSizeEmptyMap                                          {set;get;}   // to display message if there are no participants
    public Map<Id, boolean> observerinviteSizeEmptyMap                                             {set;get;}   // to display message if there are no observers
    public Map<Id, Integer> casesPresenceMap {set;get;}
    public List<Attachment> caseAttachments                                                        {get;set;}   // to capture attachment of the case
    public Entitlement  currentContext {Set;get;}
    public List<Entitlement_Contact__c> entitlementContactsList                                    {set;get;}   // to display entitlement contact's list
   // public List<emailMessage> lstEmailMsgs                                                         {set;get;}
  //  public List<Attachment>  lstAttachment                                                         {set;get;}
    public Case caseRecord                                                                         {set;get;}  // to capture case information
    public Contact objCont                                                                         {set;get;}  // to capture contact information
    public User userRecord                                                                         {set;get;}   //to get the user's information
    public integer contextSize {set;get;}
    public boolean showOthersSection                                                               {set;get;}    // to display Others section only where there are cases associated with it
    public boolean noContextVar                                                                    {set;get;}
    Entitlement otherEntitlement = new Entitlement();
    String contactId;
    String userRecordId;
    Set<ID> entitlementIds = new Set<ID>();
    private String currentEntitlementId;
    private boolean isError = false;
    public String errorMessage   {set;get;}
    public boolean isLightningCommunity;
    public Id caseIdToDisplay{get;set;}
    
     public PageReference getPageReference1()
    {
        if (UserInfo.getUserType()=='Guest') 
        {
            //code-as-is-redirects to old login page
            //return new PageReference('/communityLogin?pagename=CommunityContextPage');
            //new -login URLs - based on custom label
            return new PageReference(Site.getPathPrefix()+Label.Community_Login_URL);
            
        }
        //to get logged in user's information
        userRecord = [SELECT firstName,LastName,contactId,Contact.Company__c, Contact_ID__c, Contact.Community_web_country__c, Email, accountId from User where id = :UserInfo.getUserId()];

        contactId = userRecord.ContactId;
        
        if(String.isBlank(contactId)){
            if(!String.isBlank(userRecord.Contact_Id__c))
            {
            contactId = userRecord.Contact_Id__c;
            }
            else{
              List<Contact> contactRecords = [SELECT id from contact where Email=:userRecord.Email limit 1];
                if( !contactRecords.isEmpty() ){
                    
                    //update the User and Contact records
                    
                    userRecord.Contact_Id__c = contactRecords[0].id;
                    system.debug('@@@@@@@@@@@@@ contact check');
                }
                else{
                    Contact userContact = new Contact( FirstName = userRecord.FirstName,
                                                       LastName = userRecord.LastName,
                                                       Email = userRecord.Email,
                                                       accountId = userRecord.accountId
                                                     );
                   insert userContact ;
                   
                  userRecord.Contact_Id__c = userContact.id;
                                   }
                update userRecord;
                contactId = userRecord.Contact_Id__c;
                
            }
        }
        /* getEntitlementRecords();

        getEntitlementCaseRecords();

        getEntitlementContactRecords();*/
        return null;
       
    }
    
    public CommunityContextController(){
        
    system.debug('>>>>>>>>>>apexpage()::'+ApexPages.currentPage().getUrl()); ///apex/CommunityContextPage
    
    if (UserInfo.getUserType()!='Guest')
    {
      // currentStep = 'step1';
      isLightningCommunity = false;
      String pageUrl = ApexPages.currentPage().getUrl();
      
      if(String.isNotBlank(pageUrl) && pageUrl.contains('CommunityContextPage_cloneL')){
          
          isLightningCommunity = true;
      }
      else{
          
          isLightningCommunity = false;
      }
      noContextVar = false;
      parentController= this;
       currentEntitlementId = ApexPages.currentPage().getParameters().get('entitlementId');
       deleteContext = 'no';
        if(!String.isBlank(currentEntitlementId))
        currentcontext = [SELECT name, createdBy.Name from Entitlement where Id =: currentEntitlementId];
        showOthersSection = true;
       
        //initialization of variables
      //  caseMap = new Map<Id, case>();
   
        caseAttachments = new List<Attachment>();

        
        caseAttachments.add(new Attachment());
        caseAttachments.add(new Attachment());
        caseAttachments.add(new Attachment());
        caseAttachments.add(new Attachment());
        caseAttachments.add(new Attachment());
        
        entitlementContactsList  = new List<Entitlement_Contact__c>();

        entitlementCases  = new Map<Id, List<case>>();
        objCont = new Contact();

        caseRecord = new Case();
        
        //to get logged in user's information
        userRecord = [SELECT firstName,contactId,Contact.Company__c, Contact_ID__c, Contact.Community_web_country__c, Email, accountId from User where id = :UserInfo.getUserId()];

        contactId = userRecord.ContactId;
        userRecordId = userRecord.id;
        
        if(String.isBlank(contactId)){
            
            contactId = userRecord.Contact_Id__c;
        }
        getEntitlementRecords();

        getEntitlementCaseRecords();

        getEntitlementContactRecords();

        
        caseRecord.Status = 'New';
        
       // assignCaseRecord();
       
       }

    }
     
    public String deleteContext   {set;get;}
     /*
    * @name         : createCaseRecord
    * @description  : to create the Case and insert attachment
    * @ Input param : Null
    * @ return type : PageReference
    */
   
    public PageReference updateContextName(){
      
       currentEntitlementId= ApexPages.currentPage().getParameters().get('entitlementId');
      
       // currentContext = new Entitlement(Id = currentEntitlementId ); 
       if(deleteContext.equalsIgnoreCase('no')){
           
           update  currentContext;
           sendCaseCreateNotification([select Id, Subject, Body from EmailTemplate where DeveloperName = 'NXPCommunityContextRenameNotification']);
       
       }
       else{
           delete currentContext;
           sendCaseCreateNotification([select Id, Subject, Body from EmailTemplate where DeveloperName = 'NXPCommunityContextDeleteNotification']);
       
       
       }
       PageReference pg = Page.CommunityContextPage;
       pg.setRedirect(true);
       return pg;
    }
  
    public void createCaseRecord(){
        
        System.debug('%%%CASE');
   
        isError = false;        
        errorMessage ='';
        currentEntitlementId= ApexPages.currentPage().getParameters().get('entitlementId');
        caseRecord.entitlementId = currentEntitlementId;

        System.debug('%%%Entitlement'+currentEntitlementId);
        
        caseRecord.contactId = contactId;
      /*  if( !String.isBlank(userRecord.contactID) )
         caseRecord.contactId = userRecord.contactId;
        else
        {
            caseRecord.ContactId = userRecord.Contact_Id__c;
        } */
        
        if( !String.isBlank(userRecord.Contact.Company__c))
        caseRecord.Company__c = userRecord.Contact.Company__c;
        
        if( !String.isBlank(userRecord.Contact.Community_web_country__c)){
            caseRecord.Community_web_country__c = userRecord.Contact.Community_web_country__c;
        }
     //   try{ 
            insert caseRecord;
            
            if(caseRecord!=NULL) {
                 caseIdToDisplay = caseRecord.Id;
            }
            
            sendCaseCreateNotification([select Id, Subject, Body from EmailTemplate where DeveloperName = 'NXPCommunityCaseCreateNotification']);
      /*  }
        catch(Exception e){
                isError = true;
                errorMessage =  Label.CommunityCaseErrorMessage;
        
       }*/
        
        List<Attachment> attachments = new List<Attachment>();
        for(Attachment caseAttachment : caseAttachments){
            if(caseAttachment.body != null){
                caseAttachment.parentId = caseRecord.id;
                attachments.add(caseAttachment);
            
            }
        }
        
        if(!attachments.isEmpty()){
               
            try{
                Database.insert(attachments);
                
               
            }
            catch(Exception e){
                isError = true;
                errorMessage =  Label.CommunityAttachmentInsertError;
        
            }
        }
        
        System.debug('%%%Entitlement'+caseRecord.id);
        
        
    }
    public void addAttachment(){
        
        caseAttachments.add(new Attachment());
        caseAttachments.add(new Attachment());
    }
    /*
    * @name         : saveCaseNewRecord
    * @description  : to create the Case and return case new page
    * @ Input param : Null
    * @ return type : PageReference
    */
   
     public PageReference saveCaseNewRecord(){
        //currentStep  ='step2';
        createCaseRecord();
        
        if( !isError ){
            
            PageReference pg = Page.CommunityNXPCreateContextWizard;
            pg.getParameters().put('caseId',caseRecord.id);
            pg.setRedirect(true);
            return pg;
         }
        
         
      return null;
        
        
    }
    
    /*
    * @name         : saveCaseDetailRecord
    * @description  : to create the Case and return case detail page
    * @ Input param : Null
    * @ return type : PageReference
    */
    public PageReference saveCaseDetailRecord(){ 
        
        createCaseRecord();
       
        if( !isError ){ 
        //PageReference pg = new PageReference('/CommunityNXPCaseDetail?caseId='+caseRecord.id);
        PageReference pg = Page.CommunityNXPCaseDetail;// communityPageToRedirectCaseDetail;
        pg.getParameters().put('caseId',caseRecord.id);
        pg.setRedirect(true);
        return pg; 
        }
     
        return null;
    }
    /*
    * @name         : saveCaseRecord
    * @description  : to create the Case record entitlement
    * @ Input param : Null
    * @ return type : PageReference
    */
    public PageReference saveCaseRecord(){
        
        
        System.debug('*****'+ApexPages.currentPage().getParameters().get('entitlementId'));
        createCaseRecord();
      if( !isError ){
        PageReference pg = Page.CommunityContextPage;
      
        return pg;
        }
         return null;
    }
    
    
    
    /*
    * @name         : removeEntitlementContact
    * @description  : to remove participant/observer records who have accepted the request
    * @ Input param : Null
    * @ return type : void
    */
    public PageReference removeEntitlementContact(){
    
        Entitlement_Contact__c eContact = new Entitlement_Contact__c();
        eContact.id = ApexPages.currentPage().getParameters().get('econtactId');
        delete eContact;
        
        PageReference pg = Page.CommunityContextPage;
        pg.setRedirect(true);
        return pg;
        
        
    }
    /*
    * @name         : getEntitlementRecords
    * @description  : to get the entitlement records
    * @ Input param : Null
    * @ return type : void
    */
    private void getEntitlementRecords(){ 

       
        for(Entitlement_Contact__c eContact: [SELECT Entitlement__r.Name,Entitlement__r.Entitlement_Pattern__c,Entitlement__r.Additional_Description__c,Entitlement__r.Status, type__c,  Status__c, Entitlement__r.Total_Number_of_Hours__c, Entitlement__r.Type, Entitlement__r.Used_number_of_Hours__c from Entitlement_Contact__c 
        WHERE Status__c != :CommunityConstantsUtility.REJECTED_STATUS 
       AND contact__c = :contactId  ORDER BY CreatedDate DESC
        ]){
            entitlementContactsList.add(eContact);
        }

        
        otherEntitlement  = new Entitlement (name=Label.CommunityOthersname, id=CommunityConstantsUtility.DUMMY_ENTITLEMENTID, type =CommunityConstantsUtility.ENTITLEMENT_FREETYPE);
    
        
        entitlementContactsList.add(new Entitlement_Contact__c(Entitlement__r = otherEntitlement, entitlement__c = otherEntitlement.id));
        
        System.debug('****'+entitlementContactsList);
         System.debug('>>>>>>>>>entitlementContactsList::::'+entitlementContactsList);
        
        
        
    }
    
     /*
    * @name         : acceptEntitlement
    * @description  : to accept participant/observer records who have accepted the request
    * @ Input param : Null
    * @ return type : void
    */
    public PageReference acceptEntitlement(){
        
        Entitlement_Contact__c eContact = new Entitlement_Contact__c();
        eContact.id = ApexPages.currentPage().getParameters().get('econtactId');
        eContact.Status__c = CommunityConstantsUtility.ACCEPTED_STATUS;
        update eContact;
        
         PageReference pg = Page.CommunityContextPage;
        pg.setRedirect(true);
        return pg;

    
    }
    private void assignCaseRecord(){
        
       
      // Id caseId = ApexPages.currentPage().getParameters().get('caseId');
      // if(caseId != null && caseMap.containsKey(caseId))
      // caseRecord = caseMap.get(caseId);
       
      // lstEmailMsgs = [Select id,parentid,TextBody,subject,htmlbody,fromaddress,toaddress,createdDate from emailmessage 
       //                 where parentid=:caseRecord.id order by createddate DESC];
                        
       //lstAttachment = [select id,createddate,bodylength,name from Attachment where parentId=:caseRecord.id ];                  
       
    }
    public PageReference rejectEntitlement(){
        
        Entitlement_Contact__c eContact = new Entitlement_Contact__c();
        eContact.id = ApexPages.currentPage().getParameters().get('econtactId');
        eContact.Status__c = CommunityConstantsUtility.REJECTED_STATUS;
        update eContact;
        
        PageReference pg = Page.CommunityContextPage;
        pg.setRedirect(true);
        return pg;
    
    }
    /*
    * @name         : getEntitlementCaseRecords
    * @description  : to get the exisitng cases against the entitlement records
    * @ Input param : Null
    * @ return type : PageReference
    */
    private void getEntitlementCaseRecords(){
        Set<Id> entitlementIds = new Set<Id>();
        casesPresenceMap = new Map<Id, Integer>();
        
        
        for(Entitlement_Contact__c entId: entitlementContactsList ){
            entitlementCases.put(entId.Entitlement__c,new List<Case>());  
            casesPresenceMap.put(entId.Entitlement__c, 0);
              if(entId.type__c != null  && (entId.type__c.equalsIgnoreCase(CommunityConstantsUtility.ENTITLEMENTCONTACT_OWNER) || ( !entId.type__c.equalsIgnoreCase(CommunityConstantsUtility.ENTITLEMENTCONTACT_OWNER) &&  entId.Status__c != null && entId.Status__c.equalsIgnoreCase(CommunityConstantsUtility.ACCEPTED_STATUS))))
              entitlementIds.add(entId.Entitlement__c);
              
           

        }
        
        if(entitlementContactsList.size() > Integer.valueOf(Label.CommunityTotalContextSize)){
            
            contextSize = Integer.valueOf(Label.CommunityHomeContextSecondarySize);
        }
        else{
            contextSize = Integer.valueOf(Label.CommunityHomeContextSize);
        }
        
        
        //Get the record type Ids with the help of custom label which will be used in the recordType Id filter
        Set<ID> recordTypeIds = new Set<ID>();
        
        if(Label.CommunityCaseRecordType.contains(';')){
            for(String st: Label.CommunityCaseRecordType.split(';'))
                recordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(st).getRecordTypeId());
        }
        else{
            
            recordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CommunityCaseRecordType).getRecordTypeId());
        }
        
        integer otherCounter = contextSize;
        transient List<case> cseRecords = new List<Case>();
        system.debug('>>>>>>>>>>>>>isLightningCommunity::::::::'+isLightningCommunity);
        
        String soqlQuery = 'SELECT status, subject, createdById,createdDate,EntitlementId, Entitlement.Name, ClosedDate,caseNumber, Product__c, Product_Category__c, Product_Sub__c,'+
                                  'Product_application__c,Project_Stage__c,Expected_annual_unit_volume__c,Priority ,Sub_Topic__c,description,first_name__c, last_name__c,email__c,phone_number__c,'+
                                  'community_Web_Country__c,Hours_spent_by_Support_person__c,State_Province__c,Web_Region__c,Nature_of_Question__c,'+
                                  'company__c,jobtitle__c,Product_Type_Number__c,My_Question_is_Related__c, FeedItemId from Case '+ 
                                   'where RecordTypeId IN :recordTypeIds ';
        
                                   
        if(isLightningCommunity){
            
           soqlQuery += 'AND ContactId!=NULL ';
        }   
        soqlQuery+= 'AND (EntitlementId IN :entitlementIds OR'+
                                   '( FeedItemId = NULL AND EntitlementID = null AND (createdById =:userRecordId OR  ContactId =:contactId) ) '+
                                   'OR(FeedItemId != NULL AND EntitlementID != null)) ORDER BY CreatedDate DESC ';
        
        system.debug('>>>>>>>>>>>>>soqlQuery::::::::'+soqlQuery);
        
        for(Case cse: Database.Query(soqlQuery)) 
        {
            
            if( !String.isBlank(contactId) || (String.isBlank(contactId) && cse.createdById == userRecord.id )){
            
            cseRecords = new List<Case>();
            
            if(entitlementCases.containsKey(cse.EntitlementId)){
                cseRecords = entitlementCases.get(cse.EntitlementId);                
            }
            if((cse.entitlementId== null && cseRecords.size() < contextSize ) || casesPresenceMap.get(cse.EntitlementId) < contextSize ){
                cseRecords.add(cse);
              //  caseMap.put(cse.id,cse);
                casesPresenceMap.put(cse.EntitlementId, cseRecords.size());
           }
            else{
                
                if(casesPresenceMap.containsKey(cse.EntitlementId))
                casesPresenceMap.put(cse.EntitlementId, casesPresenceMap.get(cse.EntitlementId)+1);
                
                if(cse.entitlementId== null)
                otherCounter++;
            }
            
            entitlementCases.put(cse.EntitlementId, cseRecords);
            }
            

        }

        if(entitlementCases.containsKey(null)){
            entitlementCases.put(otherEntitlement.id, entitlementCases.get(null));
             casesPresenceMap.put(otherEntitlement.id, otherCounter);
             
            
        }
        else{
            
             showOthersSection = false;
        }
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>casesPresenceMap::'+casesPresenceMap);
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>entitlementCases::'+entitlementCases);
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>entitlementCasesValues::'+entitlementCases.values());

    }
    
    /*
    * @name         : getEntitlementContactRecords
    * @description  : to get the entitlemment contact records
    * @ Input param : void
    * @ return type : void
    */ 
    private void getEntitlementContactRecords(){
        entitlementContacts   = new map<Id,List<Entitlement_Contact__c>>();

        participantEntitlementContacts   = new map<Id,List<Entitlement_Contact__c>>();

        observerEntitlementContacts   = new map<Id,List<Entitlement_Contact__c>>();

        participantentitlementContacts.put(CommunityConstantsUtility.DUMMY_ENTITLEMENTID,new List<Entitlement_Contact__c>());   

        observerentitlementContacts.put(CommunityConstantsUtility.DUMMY_ENTITLEMENTID,new List<Entitlement_Contact__c>());   

        participantinviteSizeEmptyMap    = new Map<Id, Boolean>();
        observerinviteSizeEmptyMap    = new Map<Id, Boolean>();
        
        for(Id entId: entitlementCases.keyset()){
            entitlementContacts.put(entId,new List<Entitlement_Contact__c>());   
            participantentitlementContacts.put(entId,new List<Entitlement_Contact__c>());   

            observerentitlementContacts.put(entId,new List<Entitlement_Contact__c>());   

            // inviteSizeEmptyMap.put(entId.id, true);
            participantInviteSizeEmptyMap.put(entId, true);
            observerInviteSizeEmptyMap.put(entId, true);
        }

        List<Entitlement_Contact__c> contactRecords = new List<Entitlement_Contact__c>();
        List<Entitlement_Contact__c> allcontactRecords = new List<Entitlement_Contact__c>();
        
        for(Entitlement_Contact__c cont : [SELECT  Contact__r.Name, Contact__r.Email,Type__c,Status__c, entitlement__c from Entitlement_Contact__c
        where Entitlement__c IN :entitlementCases.keyset() ORDER BY createdDate, Type__c DESC
        ]){
            allcontactRecords  = new List<Entitlement_Contact__c>();
           
            if(cont.type__c != null && cont.Type__c.equalsIgnoreCase(CommunityConstantsUtility.PARTICIPANT)){
                if( participantentitlementContacts.containsKey(cont.Entitlement__c)){
                    contactRecords = participantentitlementContacts.get(cont.Entitlement__c);                
                }
                contactRecords.add(cont);
                participantentitlementContacts.put(cont.Entitlement__c, contactRecords);
                if(! contactRecords.isEmpty()){

                    participantinviteSizeEmptyMap.put(cont.Entitlement__c, false);
                }

            }

            if(cont.type__c !=  null && cont.Type__c.equalsIgnoreCase(CommunityConstantsUtility.OBSERVER)){
                if( participantentitlementContacts.containsKey(cont.Entitlement__c)){
                    contactRecords = observerentitlementContacts.get(cont.Entitlement__c);                
                }
                contactRecords.add(cont);
                observerentitlementContacts.put(cont.Entitlement__c, contactRecords);

                if(! contactRecords.isEmpty()){

                    observerinviteSizeEmptyMap.put(cont.Entitlement__c, false);
                }

            }
            if(entitlementContacts.containsKey(cont.Entitlement__c))
            allcontactRecords = entitlementContacts.get(cont.Entitlement__c);
            
              allcontactRecords.add(cont);
            entitlementContacts.put(cont.Entitlement__c, allcontactRecords);

        }



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
    * @name         : sendCaseCreateNotification
    * @description  : to send the email notification to active participants and observers.
    * @ Input param : void
    * @ return type : void
    */ 
    private void sendCaseCreateNotification(EmailTemplate emailTemplate){
    
    system.debug('>>>>>>>>>>>INN>>>>>>>>>>');
    Id entitlementId = ApexPages.currentPage().getParameters().get('entitlementId');
    String threadId;
    Case caseDataRecord = new Case();
    if(!String.isBlank(caseRecord.id)){
        caseDataRecord = [SELECT caseNumber, CreatedBy.Email, EntitlementId, Subject, Entitlement.Name, Entitlement.CreatedBy.Name from Case where id =:caseRecord.id];
        threadId = getThreadId(caseRecord.id);
    }
         // grab the email template
    //EmailTemplate emailTemplate = [select Id, Subject, Body from EmailTemplate where DeveloperName = 'NXPCommunityCaseCreateNotification'];
    
    if(String.isBlank(entitlementId))
    entitlementId  = caseDataRecord.entitlementID;
  //  else
   // currentcontext = [SELECT name from Entitlement where id =:entitlementID limit  1];
    // process the merge fields
    String subject = emailTemplate.Subject;
    
    String plainBody = emailTemplate.Body;
    
     //Query the org wide email address
    List<OrgWideEmailAddress> defaultOrgAddress = [select id, Address, DisplayName from OrgWideEmailAddress WHERE displayName=:Label.CommunityDefaultOrgName];
    
    
    List<Messaging.Singleemailmessage> emailLst = new List<Messaging.Singleemailmessage>();
    
   
    
    if( entitlementContacts.containsKey(entitlementId ))
    for(Entitlement_Contact__c con: entitlementContacts.get(entitlementId )){
    
    //initializing plainBody everytime so that correct name is replaced
    plainBody = emailTemplate.Body;
    
    if((
    (con.status__c != null && con.Status__c.equalsIgnoreCase(CommunityConstantsUtility.ACCEPTED_STATUS)) || 
    ( con.Type__c != null &&( con.Type__c.equalsIgnoreCase(CommunityConstantsUtility.ENTITLEMENTCONTACT_OWNER)|| 
      con.Type__c.equalsIgnoreCase(CommunityConstantsUtility.ENTITLEMENTCONTACT_SILENT)
     )))
     && caseRecord.createdBY.Email !=  con.Contact__r.Email ){
     plainBody = plainBody.replace('{!Contact.FirstName} {!Contact.LastName}', con.Contact__r.Name);
    
    plainBody = plainBody.replace('{!$Label.CommunityURL}', Label.CommunityURL);
    if(caseDataRecord.CaseNumber!= null){
    plainBody = plainBody.replace('{!Case.CaseNumber}', caseDataRecord.CaseNumber);
    plainBody = plainBody.replace('{!Case.Subject}', caseDataRecord.Subject);
    subject= subject.replace('{!Case.Subject}', caseDataRecord.Subject);
    subject =   subject.replace('{!Case.CaseNumber}', caseDataRecord.CaseNumber);
    subject =   subject.replace('{!Case.Thread_Id}', threadId);
    plainBody =   plainBody.replace('{!Case.Thread_Id}', threadId);
    plainBody = plainBody.replace('{!Entitlement.Name}', caseDataRecord.Entitlement.Name);
    }
    else{
   
    plainBody = plainBody.replace('{!Entitlement.CreatedBy}', currentContext.createdBy.Name);
    plainBody = plainBody.replace('{!Entitlement.Name}', currentcontext.Name); 
    
    if(!defaultOrgAddress.isEmpty())
    plainBody = plainBody.replace('{!Organization.Name}', defaultOrgAddress[0].displayName);
    }
    
   
    //build the email message
    Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
    if(!defaultOrgAddress.isEmpty())
    email.setOrgWideEmailAddressId(defaultOrgAddress.get(0).Id);

    email.setToaddresses(new List<String>{con.Contact__r.Email});
    email.setWhatId(caseRecord.id);
    email.setSubject(subject);
    email.setPlainTextBody(plainBody);
    emailLst.add(email);
    }

    }
    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailLst);
    system.debug('>>>>>>>>>>>>>results::'+results);
    
    }
   
       
}