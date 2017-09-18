/**********************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      21 Aug 2017
@Description:       Test Class for the class GroupAutoFollow
**********************************************************************************/
@isTest
private class GroupAutoFollowTest 
{
    //Single User record
    static testMethod void GroupAutoFollowTest1()
    {
    	//prepare test data
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        system.assert(lstProfiles.size() == 1);
        Profile objProfile = lstProfiles[0];
        
        User testUser = testUtil.createTestUser('test.user@nxp.com', 'test', objProfile.Id);
        
        Test.startTest();
        
        insert testUser;
        system.assert(testUser.Id != null);
        
        //assert the results
        List<Group> lstGroups = [Select Id, (Select Id, UserOrGroupId From GroupMembers Where UserOrGroupId = :testUser.Id) From Group where Name =: GroupAutoFollow.GROUP_NAME];
        system.assert(lstGroups.size() == 1);
        
        Group objGroup = lstGroups[0];
        List<GroupMember> lstMembers = objGroup.GroupMembers;
        system.assert(lstMembers.size() == 1);
        system.assert(lstMembers[0].UserOrGroupId == testUser.Id);
        
        Test.stopTest();
    }
    
    //Bulk users
    static testMethod void GroupAutoFollowTest2()
    {
    	//prepare test data
        List<Profile> lstProfiles =[Select Id, Name From Profile Where Name = 'Standard User' Limit 1 ];
        system.assert(lstProfiles.size() == 1);
        Profile objProfile = lstProfiles[0];
        
        List<User> lstUsers = testUtil.createTestUsers(objProfile.Id, 200);
        
        Test.startTest();
        
        insert lstUsers;
        
        Set<Id> userIds = new Set<Id>();
        for(User testUser : lstUsers)
        {
        	system.assert(testUser.Id != null);
            userIds.add(testUser.Id);
        }
        
        //assert the results
        List<Group> lstGroups = [Select Id, (Select Id, UserOrGroupId From GroupMembers Where UserOrGroupId = :userIds) From Group where Name =: GroupAutoFollow.GROUP_NAME];
        system.assert(lstGroups.size() == 1);
        
        Group objGroup = lstGroups[0];
        List<GroupMember> lstMembers = objGroup.GroupMembers;
        system.assert(lstMembers.size() == userIds.size());
        
        for(GroupMember objMember : lstMembers)
        {
            system.assert(userIds.contains(objMember.UserOrGroupId));
        }
        
        Test.stopTest();
    }
}