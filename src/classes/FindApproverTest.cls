@isTest
private class FindApproverTest{
    private static final String TEST_USER_PROFILE = 'Standard User';
    private static integer USER_NUM = 10;
    private static String CRM_CMD_APPROVER_GROUP = 'Test CRM CMD Approver';
    private static String SAP_CMD_APPROVER_GROUP = 'Test SAP CMD Approver';
    
	@testSetup
    static void setup(){
        List<User> testUsers = new List<User>();
        List<Approvers_Matrix__c> approverMatrixes = new List<Approvers_Matrix__c>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name =: TEST_USER_PROFILE];
        
        // Inser Users
        for (Integer i = 0; i < USER_NUM ; i++) {
            User u = new User(
                Alias = 'test' + (i+1),
                Email = 'test.user' + (i+1) + '@testorg.com.test',
                EmailEncodingKey = 'UTF-8', 
                LastName = 'Testing', 
                LanguageLocaleKey = 'en_US', 
                LocaleSidKey = 'en_US', 
                TimeZoneSidKey = 'America/Los_Angeles',
                ProfileId = p.Id, 
                UserName = 'test.user' + (i+1) + '@testorg.com.test',
                IsActive = True
            );
            testUsers.add(u);
        }
        insert testUsers;
        
        // Insert Approver Matrxi
        Approvers_Matrix__c salesDirector = new Approvers_Matrix__c(
            Approver__c = testUsers[0].Id,
            Type__c = 'Sales Director Approver',
            Criteria_2__c = 'Greater China',
            Threshold_1__c = 0
        );
        insert salesDirector;
        
        Approvers_Matrix__c RVP = new Approvers_Matrix__c(
            Approver__c = testUsers[1].Id,
            Type__c = 'Regional VP Approver',
            Criteria_2__c = 'Greater China',
            Threshold_1__c = 0
        );
        insert RVP;
        
        // Insert Apttus Approver Table
        Apttus_Approver_Table__c apptusApproverTable = new Apttus_Approver_Table__c(
            User__c = testUsers[2].Id,
            Role__c = 'Management Team'
        );
        insert apptusApproverTable;
        
        // Insert Rebate Approver Table
        Rebate_Approver_Matrix__c rebateApproverMatrix = new Rebate_Approver_Matrix__c(
            Approver__c = testUsers[3].Id,
            Role__c = 'BL Marketing Manager',
            MAG__c = 'R01',
            Region__c = 'AMEC'
        );
        insert rebateApproverMatrix;
        
        // Insert Approver Group
        Group groupSAPCMDApprover = new Group(
            Name = SAP_CMD_APPROVER_GROUP,
            Type = 'Queue'
        );
        insert groupSAPCMDApprover;
        
        Group groupCRMCMDApprover = new Group(
            Name = CRM_CMD_APPROVER_GROUP,
            Type = 'Queue'
        );
        insert groupCRMCMDApprover;
    }
    
    @isTest
    static void testFindApprover(){        
        List<QueuesObject> queues = new List<QueuesObject>();
        List<GroupMember> members = new List<GroupMember>();
        List<Group> approverGroups = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND (Name = :CRM_CMD_APPROVER_GROUP OR Name = :SAP_CMD_APPROVER_GROUP)];
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :TEST_USER_PROFILE LIMIT 1];
        
        for (Group g : approverGroups) {
            QueuesObject q = new QueuesObject(
                Queueid = g.Id, 
                SobjectType='CMD_Request__c'
            );
            queues.add(q);
            
            GroupMember gm = new GroupMember( 
                GroupId = g.Id, UserOrGroupId = testUser.Id
            ); 
            members.add(gm);
        }
        insert queues;
        insert members;
        
        Test.startTest();
        FindApprover testApprover = new FindApprover();
        testApprover.query = testApprover.query + ' AND Profile.Name = \'Standard User\' LIMIT 800';
        Database.executeBatch(testApprover, 800); 
        Test.stopTest();
    }
}