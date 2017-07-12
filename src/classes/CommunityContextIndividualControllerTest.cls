/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     12 June 2016
Description :      Test Class for CommunityContextController
****************************************************************************************************/
@isTest(seeAllData = false)
Public class CommunityContextIndividualControllerTest{
    
    static Account accRecord;
    static User userRecord;
    static Contact participantconRecord ;
    static Contact observerconRecord ;
    
    /*
    * @name         : saveRecord
    * @description  : saves the Case record with updated owner
    * @ Input param : Null
    * @ return type : Null
    */
    public static testmethod void caseTest(){
        
        loadData();
         
        System.runAs(userRecord){
            CommunityCreateContextController contextController = new CommunityCreateContextController( );
            
            contextController.developmentEntitlement.accountId = accRecord.id;
            contextController.developmentEntitlement.name= 'development';
            contextController.saveDevelopmentEntitlement();
            
            participantconRecord = new Contact();
            participantconRecord.LastName = 'T';
            participantconRecord.Email = 'r@t.com';
            insert participantconRecord ;
            
            observerconRecord = new Contact();
            observerconRecord.LastName = 'T';
            observerconRecord.Email = 's@t.com';
            insert observerconRecord ;
            
            Entitlement_Contact__c pcont = new Entitlement_Contact__c();
            pcont.Type__c = 'Participant';
            pCont.Entitlement__c = [SELECT id from Entitlement limit 1].id;
            pcont.Contact__c = participantconRecord.id;
            insert pcont;
            
            Entitlement_Contact__c ocont = new Entitlement_Contact__c();
            ocont.Type__c = 'Observer';
            ocont.Entitlement__c = [SELECT id from Entitlement limit 1].id;
            ocont.Contact__c = observerconRecord.id;
            insert ocont ;
            
             ApexPages.currentPage().getParameters().put('entitlementId', ocont.Entitlement__c);
            CommunityContextIndividualController controller = new CommunityContextIndividualController( ); 
        
            Test.startTest();
            controller.getPageReference1();
           
            Test.stopTest();
            
            
            ApexPages.currentPage().getParameters().put('econtactId', [SELECT id from Entitlement_Contact__c limit 1].id);
     
            controller.removeEntitlementContact();
            
        }
       
        
        
    } 
    
    
    static void loadData(){
        
        
     
        
        User usr = new User(Id = UserInfo.getUserID());
        usr.UserRoleID = [SELECT id from USerRole Where Name = 'Super User' Limit 1].id;
        update usr;
        
        System.runAs(usr){
            
            accRecord = new Account();
            accRecord.Name = 'test';
            insert accRecord;
            
            Contact conRecord = new Contact();
            conRecord.accountId = accRecord.id;
            conRecord.LastName = 'T';
            conRecord.Email = 'test@'+system.currentTimeMillis()+'.com';
            insert conRecord;
            
        
            
            
            Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%NXPCommunity Login User%' limit 1]; 

            userRecord = new User(Alias = 'standt', Email='systemadmin@tsicleanup.com',
            userName =  'systemadmin@tsicleanup.com',firstName='New',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles');
            userRecord.contactID = conRecord.id;
            insert userRecord;
            
            
         
            
            
            
        }
        
        
    }

    
}