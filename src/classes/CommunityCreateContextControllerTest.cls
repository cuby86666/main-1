/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     28 June 2016
Description :      Test Class for CommunityCreateContextController
=================================================================================
@Modified By    Nisha Agrawal
@Modified Date  Sep 01, 2016
@Description    Updated test class for Email mandatory SIR 1181 
****************************************************************************************************/
@isTest(seeAllData = false)
Public class CommunityCreateContextControllerTest{
    
    static Account accRecord;
    static User userRecord;
    static User adminUser;
    /*
    * @name         : saveRecord
    * @description  : saves the Case record with updated owner
    * @ Input param : Null
    * @ return type : Null
    */
    public static testmethod void caseTest(){
        Test.startTest();
        loadData();
        System.runAs(userRecord){
            
            CommunityCreateContextController controller = new CommunityCreateContextController( );
            
            controller.developmentEntitlement.accountId = accRecord.id;
            controller.supportEntitlement.accountId = accRecord.id;
            controller.contractEntitlement.accountId = accRecord.id;
            controller.nonTechnicalEntitlement.accountId = accRecord.id;
                        
            controller.developmentEntitlement.name= 'development';
            controller.supportEntitlement.name = 'support';
            controller.contractEntitlement.name = 'contract';
            controller.nonTechnicalEntitlement.name = 'non-technical';
                        
            controller.saveDevelopmentEntitlement();
            controller.saveSupportEntitlement();
            controller.saveContractEntitlement();
            controller.savenonTechnicalEntitlement();
            
            System.assert( controller.developmentEntitlement.id != null);
            System.assert( controller.supportEntitlement.id != null);
            System.assert( controller.contractEntitlement.id != null);
            System.assert( controller.nonTechnicalEntitlement.id != null);            
        }
        
        System.runAs(adminUser ){
            
             CommunityCreateContextController controller = new CommunityCreateContextController( );
             controller.nonTechnicalEntitlement.accountId = accRecord.id;
             controller.nonTechnicalEntitlement.name = 'non-technical';
              controller.savenonTechnicalEntitlement();
             
            
        }
        Test.stopTest();
        
        
    } 
      /*
    * @name         : saveRecord
    * @description  : saves the Case record with updated owner
    * @ Input param : Null
    * @ return type : Null
    */
   /* public static testmethod void caseWizardTest(){
        
        loadData();
        Test.startTest();
        System.runAs(userRecord){
            
            
            CommunityCreateContextController controller = new CommunityCreateContextController( );
            controller.noContextVar = true;
            controller.caseId = Database.insert(new Case(subject='jj')).id;
            controller.developmentEntitlement.accountId = accRecord.id;
            controller.supportEntitlement.accountId = accRecord.id;
            controller.contractEntitlement.accountId = accRecord.id;
            controller.nonTechnicalEntitlement.accountId = accRecord.id;
                        
            controller.developmentEntitlement.name= 'development';
            controller.supportEntitlement.name = 'support';
            controller.contractEntitlement.name = 'contract';
            controller.nonTechnicalEntitlement.name = 'non-technical';
                        
            controller.saveDevelopmentEntitlement();
            controller.saveSupportEntitlement();
            controller.saveContractEntitlement();
            controller.savenonTechnicalEntitlement();
            
            System.assert( controller.developmentEntitlement.id != null);
            System.assert( controller.supportEntitlement.id != null);
            System.assert( controller.contractEntitlement.id != null);
            System.assert( controller.nonTechnicalEntitlement.id != null);            
        }
        
        System.runAs(adminUser ){
            
             CommunityCreateContextController controller = new CommunityCreateContextController( );
             controller.nonTechnicalEntitlement.accountId = accRecord.id;
             controller.nonTechnicalEntitlement.name = 'non-technical';
              controller.savenonTechnicalEntitlement();
             
            
        }
        Test.stopTest();
        
        
    } 
    */
	
	@isTest    
	public static void developmentEntitlementTest(){
        
        loadData();
        Test.startTest();
        System.runAs(userRecord){
            
            
            CommunityCreateContextController controller = new CommunityCreateContextController( );
            controller.noContextVar = true;
            controller.caseId = Database.insert(new Case(subject='jj')).id;
            controller.developmentEntitlement.accountId = accRecord.id;
                                    
            controller.developmentEntitlement.name= 'development';
            
                        
            controller.saveDevelopmentEntitlement();
            
            
            System.assert( controller.developmentEntitlement.id != null);
                       
        }
        
        System.runAs(adminUser ){
            
             CommunityCreateContextController controller = new CommunityCreateContextController( );
             controller.nonTechnicalEntitlement.accountId = accRecord.id;
             controller.nonTechnicalEntitlement.name = 'non-technical';
              controller.savenonTechnicalEntitlement();
             
            
        }
        Test.stopTest();
        
        
    }
    
    
    @isTest
    public static void supportEntitlementTest(){
        
        loadData();
        Test.startTest();
        System.runAs(userRecord){
            
            
            CommunityCreateContextController controller = new CommunityCreateContextController( );
            controller.noContextVar = true;
            controller.caseId = Database.insert(new Case(subject='jj')).id;
            controller.supportEntitlement.accountId = accRecord.id;
                        
            controller.supportEntitlement.name = 'support';
                        
            controller.saveSupportEntitlement();
            
            System.assert( controller.supportEntitlement.id != null);
        }
        
        System.runAs(adminUser ){
            
             CommunityCreateContextController controller = new CommunityCreateContextController( );
             controller.nonTechnicalEntitlement.accountId = accRecord.id;
             controller.nonTechnicalEntitlement.name = 'non-technical';
              controller.savenonTechnicalEntitlement();
             
            
        }
        Test.stopTest();
        
        
    }

 @isTest
 public static  void contractEntitlementTest(){
        
        loadData();
        Test.startTest();
        System.runAs(userRecord){
            
            
            CommunityCreateContextController controller = new CommunityCreateContextController( );
            controller.noContextVar = true;
            controller.caseId = Database.insert(new Case(subject='jj')).id;
            controller.contractEntitlement.accountId = accRecord.id;
                        
            controller.contractEntitlement.name = 'contract';
                        
            controller.saveContractEntitlement();

            System.assert( controller.contractEntitlement.id != null);
        }
        
        System.runAs(adminUser ){
            
             CommunityCreateContextController controller = new CommunityCreateContextController( );
             controller.nonTechnicalEntitlement.accountId = accRecord.id;
             controller.nonTechnicalEntitlement.name = 'non-technical';
              controller.savenonTechnicalEntitlement();
             
            
        }
        Test.stopTest();
        
    }   

@isTest
public static void nonTechnicalEntitlementTest(){
        
        loadData();
        Test.startTest();
        System.runAs(userRecord){
            
            
            CommunityCreateContextController controller = new CommunityCreateContextController( );
            controller.noContextVar = true;
            controller.caseId = Database.insert(new Case(subject='jj')).id;
            controller.nonTechnicalEntitlement.accountId = accRecord.id;
                        

            controller.nonTechnicalEntitlement.name = 'non-technical';

            controller.savenonTechnicalEntitlement();
            
            System.assert( controller.nonTechnicalEntitlement.id != null);            
        }
        
        System.runAs(adminUser ){
            
             CommunityCreateContextController controller = new CommunityCreateContextController( );
             controller.nonTechnicalEntitlement.accountId = accRecord.id;
             controller.nonTechnicalEntitlement.name = 'non-technical';
              controller.savenonTechnicalEntitlement();
             
            
        }
        Test.stopTest();
        
        
    }     
    
    static void loadData(){
        
        User usr = new User(Id = UserInfo.getUserID());
        usr.USERRoleID = [SELECT id from USerRole Where Name = 'Super User' Limit 1].id;
        update usr;
        
        System.runAs(usr){
            
            accRecord = new Account();
            accRecord.Name = 'test';
            insert accRecord;
            
            CommunitySettings__c setting = new CommunitySettings__c();
            setting.name ='CommunityUrl';
            setting.CommunityUserAccountId__c = accRecord.id;
            
            insert setting;
            
            //Modified by Nisha on Sep 01, 2016 for SIR 1181
            Contact conRecord = new Contact(Email = 'test@test.com');
            conRecord.accountId = accRecord.id;
            conRecord.LastName = 'T';
            insert conRecord;
            
            Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%NXPCommunity Login User%' limit 1]; 

            userRecord = new User(Alias = 'standt', Email='systemadmin@tsicleanup.com',
            userName =  'systemadmin@tsicleanup.com',firstName='New',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles');
            userRecord.contactID = conRecord.id;
          insert userRecord;
            
             adminUser = new User(Alias = 'standt', Email='systemadmin@tsicleanup.com',
            userName =  'dmin@tsicleanup.com',firstName='New',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId =  [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%' limit 1].id, 
            TimeZoneSidKey='America/Los_Angeles');
            insert adminUser;
            
            
        }
    }
}