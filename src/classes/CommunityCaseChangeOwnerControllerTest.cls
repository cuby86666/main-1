/*********************************************************************************************
@Created By :      Amit Rajan
@CreatedDate :     29 April 2016
Description :      Test Class for Case Change Owner controller
****************************************************************************************************/
// 3rdJan2017 Balaji - Repositioned StartTest() and StopTest() methods in caseTest and caseTest1 methods to fix the test failure
@isTest(seeAllData = false)
Public class CommunityCaseChangeOwnerControllerTest{
    
    static Case caseRecord;
    static Group testGroup;
    static User userRecord;
    
    /*
    * @name         : saveRecord
    * @description  : saves the Case record with updated owner
    * @ Input param : Null
    * @ return type : Null
    */
    public static testmethod void caseTest(){
    
//        Test.startTest();   
        loadData();
        System.runAs(new User (Id = UserInfo.getUserId())){
        
            CommunityCaseChangeOwnerController controller = new CommunityCaseChangeOwnerController(new ApexPages.standardController(caseRecord));
            System.assertEquals(userRecord.id, [SELECT ownerId from Case where id =:caseRecord.id].ownerId);
            
            controller.caseRecord.ownerId = null;
            controller.saveRecord();
            System.assertEquals(userRecord.id, [SELECT ownerId from Case where id =:caseRecord.id].ownerId);
            
            controller.caseRecord.ownerId = testGroup.id;
            controller.reasssignmentReason ='New';
            controller.saveRecord();
            
            System.assertEquals(testGroup.id, [SELECT ownerId from Case where id =:caseRecord.id].ownerId);
            
            
            
        }
//        Test.stopTest();
        
        
    } 
    public static testmethod void caseTest1(){
//        Test.startTest();
        loadData();
        System.runAs(new User (Id = UserInfo.getUserId())){
        
            CommunityCaseChangeOwnerController controller = new CommunityCaseChangeOwnerController(new ApexPages.standardController(caseRecord));
            System.assertEquals(userRecord.id, [SELECT ownerId from Case where id =:caseRecord.id].ownerId);
            
            controller.caseRecord.ownerId = null;
            controller.saveRecord();
            System.assertEquals(userRecord.id, [SELECT ownerId from Case where id =:caseRecord.id].ownerId);
            
            
            
            controller = new CommunityCaseChangeOwnerController(new ApexPages.standardController(caseRecord));
            controller.caseRecord.assigned_to__c = userRecord.id;
            controller.reasssignmentReason ='New';
            controller.saveRecord();
            
        }
//        Test.stopTest();
        
        
    } 
    
    static void loadData(){
        
        
        testGroup = new Group(Name='test group', type='Queue');
        insert testGroup;
        
        QueueSObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
        insert testQueue;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        userRecord = new User(Alias = 'standt', Email='systemadmin@tsicleanup.com',
        userName =  'systemadmin@tsicleanup.com',firstName='New',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles');
        
        insert userRecord;
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            caseRecord = new Case();
            caseRecord.Subject = 'Test';
            caseRecord.Type = 'Problem';
            caseRecord.ownerId = userRecord.id;
            
            insert caseRecord;
        }
        Test.stopTest();
        
         // Build a simple feed item
        ConnectApi.FeedItemPage testPage = new ConnectApi.FeedItemPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        
    }

    
}