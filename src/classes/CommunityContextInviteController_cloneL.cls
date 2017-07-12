/*

CLONE OF CommunityContentInviteController for use in the NXP Lightning community while the original file is still being used in the legacy NXP Community.
Modifications have been made to load a template without a header and footer, as well as link to other cloned files that have the header and footer removed. No other
business logic changes should be made in this file.

PRIOR TO FINAL PRODUCTION GO LAUNCH, COMPARE TO PRODUCTION VERSION OF ORIGINAL FILE TO DETERMINE IF CHANGES TO BUSINESS LOGIC HAVE BEEN MADE THAT WILL NEED TO BE
INCORPORATED BACK INTO THIS FILE.

*/

/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     18 July 2016
Description :      controller class for inviting participants/observers to Context
****************************************************************************************************/
public without sharing class CommunityContextInviteController_cloneL{

    public List<Wrapper> participantsList   {set;get;}
    public List<Wrapper> observersList   {set;get;}

    public String currentEntitlementId  {set;get;}

    public String participantErrorMessage {Set;get;}
    public String observerErrorMessage {set;get;}

    User userRecord;

    public integer existingParticipants {set;get;}
    public integer existingObservers {Set;get;}

    List<Contact> participantContacts   = new List<Contact>();
    List<Contact> observerContacts                            = new List<Contact>();

    public List<String> headers {set;get;}
    CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
    String accountId= cs.CommunityUserAccountId__c;
    Map<String,Entitlement_Contact__c> entitlementContactMap = new Map<String,Entitlement_Contact__c>();

    public CommunityContextInviteController_cloneL(){
        participantsList = new List<Wrapper>();
        observersList = new List<Wrapper>();
        userRecord = [SELECT Email from User where Id = :UserInfo.getUserID() LIMIT 1];
        headers = new List<String>();
        headers.add('#');
        headers.add('First Name');
        headers.add('Last Name');
        headers.add('Company Name');
        headers.add('Email Address');
        headers.add('Status');
        headers.add('Action');

        for(integer i=1; i<=3; i++){

            Wrapper wrap = new Wrapper(i, new Contact(), 'p'+i,'');
            participantsList.add(wrap);

        }

        for(integer i=1; i<=10; i++){

            Wrapper wrap = new Wrapper(i, new Contact(), 'o'+i,'');
            observersList.add(wrap);

        }

        if(String.isBlank(currentEntitlementId))
            currentEntitlementId= ApexPages.currentPage().getParameters().get('entitlementId');

        existingParticipants =0;
        existingObservers = 0;

        for(Entitlement_Contact__c con: [SELECT id, Contact__r.FirstName, Status__c, Contact__r.LastName, Contact__r.Email, Contact__r.Company__c, Type__c from Entitlement_Contact__c where Entitlement__c = :currentEntitlementId]){

            entitlementContactMap.put(con.Type__c+'-'+con.Contact__c, con);

            if(con.Type__c.equalsIgnoreCase(CommunityConstantsUtility.PARTICIPANT) && !con.Status__c.equalsIgnoreCase(CommunityConstantsUtility.REJECTED_STATUS )){
                existingParticipants++;
                participantsList[existingParticipants-1] = new Wrapper( existingParticipants,new Contact(Id= con.contact__c,FirstName= con.Contact__r.FirstName, lastName= con.Contact__r.LastName, email= con.contact__r.email,
                        company__c = con.Contact__r.company__c), 'p'+existingParticipants, con.Status__c
                );

            }
            else

                    if(con.Type__c.equalsIgnoreCase(CommunityConstantsUtility.OBSERVER) &&  !con.Status__c.equalsIgnoreCase(CommunityConstantsUtility.REJECTED_STATUS )){
                        existingObservers++;
                        observersList[existingObservers-1] = new Wrapper( existingObservers,new Contact(Id= con.contact__c,FirstName= con.Contact__r.FirstName, lastName= con.Contact__r.LastName, email= con.contact__r.email,
                                company__c = con.Contact__r.company__c), 'o'+existingObservers, con.Status__c
                        );

                    }



        }

    }

    public pageReference removeInvitee(){

        integer counter = Integer.valueOf(ApexPages.currentPage().getParameters().get('counter'));
        String type = ApexPages.currentPage().getParameters().get('type');

        if(type.equalsIgnoreCase('Observer')){

            if(observersList.get(counter-1).contactRecord.id != null){


                Database.delete(entitlementContactMap.get('Observer-'+observersList.get(counter-1).contactRecord.id));
                existingObservers--;
            }
            observersList[counter-1] = new Wrapper(counter, new Contact(), 'o'+counter,'');

        }
        else{

            System.debug('djfkjf'+counter);
            if(participantsList.get(counter-1).contactRecord.id != null){

                Database.delete(entitlementContactMap.get('Participant-'+participantsList.get(counter-1).contactRecord.id));
                existingParticipants--;

            }
            participantsList[counter-1] = new Wrapper(counter, new Contact(), 'p'+counter,'');
            System.debug('djfkjf'+participantsList);

        }
        return null;

    }
    /*
    * @name         : createParticipants
    * @description  : to create participant records
    * @ Input param : void
    * @ return type : PageReference
    */

    public pageReference createInviteRecords(){
        System.debug('Community Settings: '+cs);
        System.debug('Account ID: '+accountId);
        participantErrorMessage ='';


        Map<String,Contact> emailAddressSetPa = new  Map<String,Contact>();
        for(Wrapper participant : participantsList){

            //System.debug('%%%'+participant.Email+'***'+userREcord.email);
            if( participant.contactRecord.id== null && !String.isBlank( participant.contactRecord.lastName ) &&  !participant.contactRecord.Email.equalsIgnoreCase(userRecord.Email))
                emailAddressSetPa.put( participant.contactRecord.Email,participant.contactRecord);
        }

        if(!emailAddressSetPa.isEmpty()){
            createInvitees(emailAddressSetpa, CommunityConstantsUtility.PARTICIPANT);


        }



        //create observer
        Map<String,Contact> emailAddressSetOb = new  Map<String,Contact>();

        Set<String> existingParticipants = new Set<String>();

        for(Entitlement_Contact__c eContact: [SELECT unique_email_Address__c from Entitlement_Contact__c where Entitlement__c = :currententitlementId and Type__c = :CommunityConstantsUtility.PARTICIPANT]){

            if(eContact.Unique_Email_Address__c.contains('-'))
                existingParticipants.add(eContact.Unique_Email_Address__c.split('-')[1]);

        }
        for(Wrapper participant : observersList){
            if( participant.contactRecord.id== null && !String.isBlank( participant.contactRecord.lastName ) && !participant.contactRecord.Email.equalsIgnoreCase(userRecord.Email) && !existingParticipants.contains(participant.contactRecord.Email) )
                emailAddressSetOb.put( participant.contactRecord.Email,participant.contactRecord);
        }

        System.debug('****'+emailAddressSetOb);
        if( !emailAddressSetOb.isEmpty()){
            createInvitees(emailAddressSetOb, CommunityConstantsUtility.OBSERVER);

        }

        if(emailAddressSetOb.isEmpty() && emailAddressSetPa.isEmpty() ){
            observerErrorMessage = Label.CommunityObserverInviteError;
            participantErrorMessage = Label.CommunityInvitePeopleError;
            return  null;
        }


        PageReference pg = Page.CommunityContextPage_cloneL;
        pg.setRedirect(true);
        return pg;

    }
    /*
    * @name         : createInvitees
    * @description  : to create invitee records
    * @ Input param :  Map<String,Contact> emailAddressSet, String type
    * @ return type : void
    */
    private void createInvitees(  Map<String,Contact> emailAddressSet, String type ){

        Set<String> newContactIds = new Set<String>();
        List<Contact> newContacts = new List<Contact>();

        System.debug('&&&&&&&&Email'+emailAddressSet);
        if(!emailAddressSet.isEmpty())

            newContactIds.addAll(emailAddressSet.keyset());

        Map<Id,Contact> contactRecords = new Map<Id, Contact>([SELECT id, Email, firstName, lastName, MobilePhone, Department from Contact WHERE  EMAIL  IN :emailAddressSet.keyset()  ]);
        Map<String,Contact> uniqueContactRecords = new Map<String,Contact>();

        for(Contact con: contactRecords.values() ){

            uniqueContactRecords.put(con.Email, Con);


        }
        for(Contact con: uniqueContactRecords.values()){

            if(emailAddressSet.containsKey(con.Email) ){

                // emailAddressSet.remove(con.Email);
                newContactIds.remove(con.Email);

            }
        }



        for(String newContact: newContactIds){

            //  if(emailAddressSet.get(newContact).id == null)
            if(!String.isBlank(accountId))
                emailAddressSet.get(newContact).accountId = accountId;
            newContacts.add(emailAddressSet.get(newContact));
        }
        //System.debug('&&&'+newContacts);
        if(!newContacts.isEmpty())
            insert newContacts;

        for(Contact con: newContacts){

            uniqueContactRecords.put(con.Email, Con);
        }
        List<EntitlementContact> newentitlementContacts= new List<EntitlementContact>();
        List<Entitlement_Contact__c> newentitlements= new List<Entitlement_Contact__c>();

        Set<Id> existingEntitlementContacts = new Set<ID>();

        for(EntitlementContact eContact : [SELECT contactId from EntitlementContact where entitlementId = :currentEntitlementID]){

            existingEntitlementContacts.add(eContact.contactId);

        }


        for(Contact con: uniqueContactRecords.values()){
            Entitlement_contact__c ent = new Entitlement_Contact__c ();
            ent.entitlement__c = currententitlementId;
            ent.Contact__c = con.id;
            ent.status__c = CommunityConstantsUtility.PENDING_STATUS;
            ent.Unique_Email_Address__c = currentEntitlementId+'-'+con.Email;


            ent.type__c  = type;

            newentitlements.add(ent);


            if(!existingEntitlementContacts.contains(con.id)){
                EntitlementContact eContact = new EntitlementContact();
                eContact.EntitlementId = currententitlementId;
                econtact.ContactId = con.id;
                newentitlementContacts.add(eContact);
            }
        }

        try{



            if(!newentitlementContacts.isEmpty())
                insert newentitlementContacts;

            System.debug('&&&&^^^^^'+newentitlements );
            if(!newentitlements.isEmpty())

                upsert newentitlements Unique_Email_Address__c;
        }
        catch(Exception e){

            if(type.equalsIgnoreCase(CommunityConstantsUtility.OBSERVER)){
                observerErrorMessage = Label.CommunityErrorInviteMessage;
            }
            else{

                participantErrorMessage = Label.CommunityErrorInviteMessage;
            }

        }
    }

    Public class Wrapper{

        public Contact contactRecord  {set;get;}
        public integer counter {set;get;}
        public String status    {set;get;}
        public String mandatoryStyle {set;get;}
        public Wrapper(integer cnt, contact cont, String style, String stat){
            counter=cnt;
            contactRecord = cont;
            mandatoryStyle = style;
            status = stat;
        }
    }



}