/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     13 September 2016
Description :      controller class for CommunityContextIndividualController to show one context at a time 
****************************************************************************************************/
/*********************************************************************************************
@Created By :      Shridevi Badiegr
@CreatedDate :     04 Aug 2017
Description :      As part of SIR 750,removed the usage of the pages which are being deleted.
****************************************************************************************************/
public without sharing class CommunityContextIndividualController{

    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setCon {set;get;}
    public Map<Id, List<Entitlement_Contact__c>> participantEntitlementContacts                    {set;get;}   // to display participants
    public Map<Id, List<Entitlement_Contact__c>> observerEntitlementContacts                       {set;get;}   // to display observers
    public Map<Id, List<Entitlement_Contact__c>> entitlementContacts                               {set;get;}   // to display entitlemet contacts 
    public Map<Id, boolean> participantInviteSizeEmptyMap                                          {set;get;}   // to display message if there are no participants
    public Map<Id, boolean> observerinviteSizeEmptyMap                                             {set;get;}   // to display message if there are no observers
    public Entitlement_Contact__c ent                                                              {set;get;}
    public String RedirectionToLoginPage{get;set;}
    public Contact objCont                                                                         {set;get;}  // to capture contact information
    public User userRecord                                                                         {set;get;}   //to get the user's information
    
    public boolean showOthersSection                                                               {set;get;}    // to display Others section only where there are cases associated with it
    
    Entitlement otherEntitlement = new Entitlement();
    
    String contactId;
    Set<ID> entitlementIds = new Set<ID>();
    
    private String currentEntitlementId;
   

   public PageReference getPageReference1()
    {
        if (UserInfo.getUserType()=='Guest') 
        {
            return new PageReference(RedirectionToLoginPage);
            
        }
        return null;
       
       
    }
    
    public CommunityContextIndividualController(){
     //below line is added by shridevi for redirecting to login page instead of communityLogin page since the page has been deleted.
        RedirectionToLoginPage=(Site.getPathPrefix()+Label.Community_Login_URL);
   
           if (UserInfo.getUserType()!='Guest')
    {
       
       currentEntitlementId = ApexPages.currentPage().getParameters().get('entitlementId');
       entitlementIds.add(currentEntitlementID);
       
       showOthersSection = true;
       
       objCont = new Contact();
        
        //to get logged in user's information
        userRecord = [SELECT firstName,contactId,Contact.Company__c, Contact_ID__c, Contact.Community_web_country__c, Email, accountId from User where id = :UserInfo.getUserId()];

        contactId = userRecord.ContactId;
        
        if(String.isBlank(contactId)){
            
            contactId = userRecord.Contact_Id__c;
        }
        getEntitlementRecords();

        getEntitlementCaseRecords();

        getEntitlementContactRecords();

        
        
       
       }

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

       
        for(Entitlement_Contact__c eContact: [SELECT Entitlement__r.Name,Entitlement__r.Additional_Description__c,Entitlement__r.Status, type__c,  Status__c, Entitlement__r.Total_Number_of_Hours__c, Entitlement__r.Type, Entitlement__r.Used_number_of_Hours__c from Entitlement_Contact__c 
        WHERE Status__c != :CommunityConstantsUtility.REJECTED_STATUS 
       AND contact__c = :contactId AND Entitlement__c IN :entitlementIds ORDER BY CreatedDate DESC LIMIT 1
        ]){
          
            ent = eContact;
        }
        
        
      
        
        otherEntitlement  = new Entitlement (name=Label.CommunityOthersname, id=CommunityConstantsUtility.DUMMY_ENTITLEMENTID, type =CommunityConstantsUtility.ENTITLEMENT_FREETYPE);
         
        if(currentEntitlementId ==CommunityConstantsUtility.DUMMY_ENTITLEMENTID)
        ent = new Entitlement_Contact__c(Entitlement__r = otherEntitlement, entitlement__c = otherEntitlement.id);
       
        
        
    }
    
     
    public List<Case> getCases(){
        List<Case> cases = new List<Case>();
        
        if(setCon != null)
        cases = (List<Case>)setCon.getRecords();
        
        return cases;
        
    }
    /*
    * @name         : getEntitlementCaseRecords
    * @description  : to get the exisitng cases against the entitlement records
    * @ Input param : Null
    * @ return type : PageReference
    */
    private void getEntitlementCaseRecords(){
        
        //Get the record type Ids with the help of custom label which will be used in the recordType Id filter
        Set<ID> recordTypeIds = new Set<ID>();
        
        if(Label.CommunityCaseRecordType.contains(';')){
            for(String st: Label.CommunityCaseRecordType.split(';'))
                recordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(st).getRecordTypeId());
        }
        else{
            
            recordTypeIds.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CommunityCaseRecordType).getRecordTypeId());
        }
        
        String dquery ='SELECT     status, subject, createdDate,EntitlementId, Entitlement.Name, ClosedDate,caseNumber, Product__c, Product_Category__c, Product_Sub__c,community_Web_Country__c,Hours_spent_by_Support_person__c,State_Province__c,Web_Region__c,Nature_of_Question__c,                                  company__c,jobtitle__c,Product_Type_Number__c,My_Question_is_Related__c from Case';
        
        dquery = dquery + ' where RecordTypeId IN :recordTypeIds AND ';
        
        if(currentEntitlementID != CommunityConstantsUtility.DUMMY_ENTITLEMENTID)
        dquery = dquery+ '(EntitlementId =\''+currentEntitlementID+'\')';
                     
        if(currentEntitlementId == CommunityConstantsUtility.DUMMY_ENTITLEMENTID){
           dquery = dquery+  ' ( EntitlementID = null AND ( createdById = \''+userRecord.id+'\'' ;
           
           if(contactId != null)
           dquery = dquery + ' OR  ContactId = \''+contactId+'\') )';
           else
           dquery = dquery +' OR  ContactId = null ) )';
        } 
        
        dquery = dquery + '  ORDER BY CreatedDate DESC LIMIT 2000';
        System.debug('^^^^'+dquery);
        size = Integer.valueOf(Label.CommunityContextPageSize);
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(dquery ));
        setCon.setPageSize(size);     
        noOfRecords = setCon.getResultSize();
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
        
      //  for(Id entId: entitlementCases.keyset()){
            entitlementContacts.put(ent.Entitlement__c,new List<Entitlement_Contact__c>());   
            participantentitlementContacts.put(ent.Entitlement__c,new List<Entitlement_Contact__c>());   

            observerentitlementContacts.put(ent.Entitlement__c,new List<Entitlement_Contact__c>());   

            // inviteSizeEmptyMap.put(entId.id, true);
            participantInviteSizeEmptyMap.put(ent.Entitlement__c, true);
            observerInviteSizeEmptyMap.put(ent.Entitlement__c, true);
     //   }

        List<Entitlement_Contact__c> contactRecords = new List<Entitlement_Contact__c>();
        List<Entitlement_Contact__c> allcontactRecords = new List<Entitlement_Contact__c>();
        
        for(Entitlement_Contact__c cont : [SELECT  Contact__r.Name, Contact__r.Email,Type__c,Status__c, entitlement__c from Entitlement_Contact__c
        where Entitlement__c=:ent.Entitlement__c ORDER BY createdDate, Type__c DESC
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
    
    
    
         
}