/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
private class CommunityUpdateEntitlementTest 
    {
        private static final String PARENT_ACCOUNT_RECORD_TYPE='Parent_Account';
        private static final String MODEL_N_OPPTY_RECORD_TYPE='Model_N_Oppty';
        private  static ID PARENT_ACCOUNT_RECORD_TYPE_ID;
        private  static ID MODEL_N_OPPTY_RECORD_TYPE_ID;
       
        public static list<Recordtype> listRecordType=new list<Recordtype>();
        /*public static void fetchRecordTypes()
        {
            listRecordType=[Select Id, DeveloperName From RecordType Where IsActive=true AND (SobjectType = 'Account' and (DeveloperName =:PARENT_ACCOUNT_RECORD_TYPE) )];
           for(RecordType rt:listRecordType)
           {
            if(rt.DeveloperName ==PARENT_ACCOUNT_RECORD_TYPE) 
            PARENT_ACCOUNT_RECORD_TYPE_ID=rt.id;
          
            System.debug(rt);
           }
        }*/
    private static void fetchRecordTypes()
    {        
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType Where IsActive=true and  
                              ((SobjectType = 'Opportunity' and (DeveloperName =: MODEL_N_OPPTY_RECORD_TYPE)) or
                               (SobjectType = 'Account' and (DeveloperName =:PARENT_ACCOUNT_RECORD_TYPE))                              
                              ) Limit 2])
            
        if(rt.DeveloperName == MODEL_N_OPPTY_RECORD_TYPE)
        {
            MODEL_N_OPPTY_RECORD_TYPE_ID= rt.id;
        }
        else if(rt.DeveloperName == PARENT_ACCOUNT_RECORD_TYPE)
        {
            PARENT_ACCOUNT_RECORD_TYPE_ID= rt.id; 
        }
        
    }   
        public static opportunity createOpportunity(id testAccountId,string DRNumber,date testclosedate)
        {
            
            opportunity oppty=new opportunity(name='test',recordtypeId=MODEL_N_OPPTY_RECORD_TYPE_ID,accountId=testAccountId,Legacy_Design_Registration_Number__c=DRNumber,StageName='Discovery',closeDate=testclosedate);
            return oppty;
        }
        public static Entitlement createEntitlements(id testAccountId,string DRNumber)
    {
        //Account objParentAccount = createParentAccount();
         // insert objParentAccount;
        Entitlement ObjEntitlement=new Entitlement(AccountId=testAccountId, Name='TestEntitlement', Startdate=system.today(),Type='free',Entitlement_Sub_Type__c='development project',Priority__c='critical',Project_NXP_Design_Registration__c=DRNumber);
        //listEntitlement.add(new Entitlement(AccountId=objParentAccount.id, Name='testingname', Startdate=system.today(),Type='free',Entitlement_Sub_Type__c='development project',Priority__c='medium'));
        //listEntitlement.add(new Entitlement(AccountId=objParentAccount.id, Name='testingname', Startdate=system.today(),Type='free',Entitlement_Sub_Type__c='',Priority__c='low'));
        //listEntitlement.add(new Entitlement(AccountId=objParentAccount.id, Name='testingname', Startdate=system.today(),Type='',Entitlement_Sub_Type__c='',Priority__c='critical'));
       // listEntitlement.add(new Entitlement(AccountId=objParentAccount.id, Name='testingname', Startdate=system.today(),Type='free',Entitlement_Sub_Type__c='',Priority__c='high'));
        //insert listEntitlement;
        return ObjEntitlement;
    
    } 
 
        @isTest
        static void testEntitlementEndCustomerIdentification()
        {
            fetchRecordTypes();
            
            Test.startTest();
            list<Entitlement> listEntitlement=new list<Entitlement>();
           // MODEL_N_OPPTY_RECORD_TYPE_ID= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Model N Oppty').getRecordTypeId();
            date testclosedate=system.today();
            list<opportunity> listOpportunity=new list<Opportunity>();
            Account testAccount = new Account(Name = 'Test Account', Region__c = 'EMEA', RecordTypeId=PARENT_ACCOUNT_RECORD_TYPE_ID);
            insert testAccount;
            Account testChildAccount=new Account(Name = 'Test Child Account', Region__c = 'EMEA', parentid=testAccount.id,customer_category__C='Tier 4 - TMMA');
            insert testChildAccount;
            
            Opportunity oppty = createOpportunity(testChildAccount.id,'12341',testclosedate); // Jason Tsai added on 4/10/2017
            oppty.Production_Date__c= testclosedate + 10;
            oppty.One_Year_Pieces__c= 1000; 
            listOpportunity.add(oppty);
                        
            insert  listOpportunity;
            listEntitlement.add(createEntitlements(testChildAccount.id,'12341'));
            insert listEntitlement; 
            System.assertNotEquals(listEntitlement[0].Entitlement_Sub_Type__c,'Tier 4 - TMMA');
            
            test.stopTest();
        }
    }