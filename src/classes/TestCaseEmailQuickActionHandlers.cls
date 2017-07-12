@isTest
public class TestCaseEmailQuickActionHandlers {
    private final static String CASE_TSCOMMUNITY = 'TS_COMMUNITY'; 
    private final static String PARENT_ACCOUNT = 'Parent_Account';


    private Static RecordType tsCommunity;
    private static RecordType parentAccount;
    
    //To fetch the record type
    private static void fetchRecordTypes()
    {        
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType Where IsActive=true and  
                              ((SobjectType = 'Case' and (DeveloperName =: CASE_TSCOMMUNITY)) or
                               (SobjectType = 'Account' and (DeveloperName =: Parent_Account))                              
                              ) Limit 3])
            
        if(rt.DeveloperName == CASE_TSCOMMUNITY)
        {
            tsCommunity = rt;
        }

        else if(rt.DeveloperName == PARENT_ACCOUNT)
        {
            parentAccount = rt;
        } 
    }    
    
    
    public Case caseRecord{get;set;}

    @isTest
    public static void testEntitlementEmailQuickAction(){
       fetchRecordTypes(); 
       TestCaseEmailQuickActionHandlers te = new TestCaseEmailQuickActionHandlers(); 
       te.setupData();
       Test.startTest();
       CaseEmailQuickActionHandler ce = new CaseEmailQuickActionHandler();
       ce.onInitDefaults(new QuickAction.QuickActionDefaults[]{Test.newSendEmailQuickActionDefaults(te.caseRecord.id, null)}); 
	   System.assert(ce.ccInviteEmailAddresses.contains('observer.contact@customer.com'));
       System.assert(ce.bccSilentObservers.contains('silent.contact@customer.com')); 
       System.assert(ce.ccInviteEmailAddresses.contains('observer.notacc.contact@customer.com')==false); 
       Test.stopTest(); 
    }
    
    private void setupData(){
    	Account nxpAccount = createNxpCommunityAccountRecord();	
        Contact caseContact = createContactsForAccount('Case','Contact','case.contact@customer.com',nxpAccount);
        Contact obscontact = createContactsForAccount('Observer','Contact','observer.contact@customer.com',nxpAccount);
        Contact obscontactnotacc = createContactsForAccount('Observer','Contact','observer.notacc.contact@customer.com',nxpAccount);
        Contact silentObs = createContactsForAccount('Silent','Contact','silent.contact@customer.com',nxpAccount);
        Entitlement ent = createEntitlement(nxpAccount);
        createEntitlementContact(ent,obscontact,'Participant','Accepted');
        createEntitlementContact(ent,obscontact,'Participant','Pending');
        createEntitlementContact(ent,silentObs,'Silent Observer','Accepted');
        caseRecord = createCaseForEntitlement(ent,caseContact);
    }
    
    private Account createNxpCommunityAccountRecord(){
        Account nxpAccount = new Account(RecordTypeID= parentAccount.ID,Name = 'Test Account', Customer_Category__c= 'Longtail');
        Database.SaveResult result =  Database.insert(nxpAccount);
        nxpAccount.id = result.getId();
        return nxpAccount;
   }  
    private Contact createContactsForAccount(String fstName,String lstName,String emailId,Account relatedAccount){
       Contact conRec = new Contact(FirstName=fstName,LastName=lstName,Email=emailId,Account=relatedAccount);
       Database.SaveResult result =  Database.insert(conRec);
       conRec.id =  result.getId();
       return conRec; 
    }
    
    private Entitlement createEntitlement(Account acc){
 		Entitlement objEntitlement = new Entitlement(AccountId=acc.id, Name='entitlement');
       	Database.SaveResult result =  Database.insert(objEntitlement);
       	objEntitlement.id =  result.getId();        
        return objEntitlement;         
    }
    
    private void createEntitlementContact(Entitlement ent,Contact c,String partType,String accStat){
    	Entitlement_Contact__c ec = new Entitlement_Contact__c(Entitlement__c=ent.id,Contact__c=c.id,Type__c=partType,Status__c=accStat);     
		insert ec;        
    }
    
    private Case createCaseForEntitlement(Entitlement ent,Contact cont){
        Case c = new Case(RecordTypeID = tsCommunity.Id,contactId=cont.id, Status= 'New', Priority = 'Medium', 
                          Product_Type_Number__c = 'test',Subject = 'test_subject', My_Question_is_Related__c = 'test', 
                          Description = 'test_subject',Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                          Project_Stage__c = 'Development',EntitlementId = ent.id);
        Database.SaveResult result =  Database.insert(c);
        c.id =  result.getId();
        return c;
    }
}