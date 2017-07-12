/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     19 July 2016
Description :      Test Class for CommunityContextInviteController
****************************************************************************************************/
@isTest(seeAllData = false)
Public class CommunityContextInviteControllerTest{
    
    static Account accRecord;
    static User userRecord;
    
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
            
            
            
            ApexPages.currentPage().getParameters().put('entitlementId',contextController.developmentEntitlement.id);
            CommunityContextInviteController controller = new CommunityContextInviteController();
            
            controller.participantsList[0].contactRecord.lastName = 'test';
            controller.participantsList[0].contactRecord.Email = 'test@test.com';
           
            
           controller.observersList[0].contactRecord.lastName = 'tet';
           controller.observersList[0].contactRecord.Email = 'tet@gty.com';
           
           
            
           controller.createInviteRecords();
            ApexPages.currentPage().getParameters().put('entitlementId',contextController.developmentEntitlement.id);
            controller = new CommunityContextInviteController();
             ApexPages.currentPage().getParameters().put('counter','1');
             ApexPages.currentPage().getParameters().put('type','Observer');
             
             controller.removeInvitee();
             ApexPages.currentPage().getParameters().put('counter','1');
             ApexPages.currentPage().getParameters().put('type','Participant');
             
             controller.removeInvitee();
             
                    
        }
        Test.stopTest();
        
        
    } 
    
    static void loadData(){
        
        
     
        
       User usr = new User(Id = UserInfo.getUserID());
        usr.UserRoleID = [SELECT id from USerRole Where Name = 'Super User' Limit 1].id;
        update usr;
        
        System.runAs(usr){
            
            accRecord = new Account();
            accRecord.Name = 'test';
            insert accRecord;
            
            CommunitySettings__c setting = new CommunitySettings__c();
            setting.name ='CommunityUrl';
            setting.CommunityUserAccountId__c = accRecord.id;
            insert setting;
            
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
            Test.startTest();
            
            
            
            
        }
        
        
    }

    
}