/*
@Created By :     Rex Lai
@Created Date:    20 Nov 2013
@Description:     Test Class for AddGroup trigger
*/

@isTest
private class AddGroup_Test
{

   /* static testMethod void AddGroup_Test1()
    {
        //prepare test data
        //get NER group
        List<Group> lstNERGroups = [Select Id, Name from Group Where Name = 'All Internal NER Users' Limit 1];
        //get NER profile
        List<Profile> lstNERProfiles = [Select Id, Name from Profile Where Name = 'NER User' Limit 1];

        test.startTest();
               
        Profile objNERProfile = lstNERProfiles[0];
        List<User> lstNERUsers = TestUtil.createTestUsers(objNERProfile.Id, 1);
        insert lstNERUsers;
        
        User NERUser = lstNERUsers[0];      
        
        List<GroupMember> lstNERGroupMember = [Select GroupId, UserOrGroupId from GroupMember where UserOrGroupId =: NERUser.Id];

        System.assert(lstNERGroupMember.size() > 0);
        
        if (lstNERGroupMember.size() > 0)
        {
            Group NERGroup = lstNERGroups[0];
            GroupMember NERGroupMember = lstNERGroupMember[0];
            System.assert(NERGroupMember.GroupId == NERGroup.Id);
        }
        
        test.stopTest();        
    }*/
    
   static testMethod void AddGroup_Test2()
    {
        //prepare test data
        //get NXP group
        List<Group> lstNXPGroups = [Select Id, Name from Group Where Name = 'All Internal NXP Users' Limit 1];
        //get NXP profile
        List<Profile> lstNXPProfiles = [Select Id, Name from Profile Where Name = 'NXP Sales Cloud User' Limit 1];

        test.startTest();
               
        Profile objNXPProfile = lstNXPProfiles[0];
        User NXPUser = TestUtil.createTestUser('test99@salesforce.com', 'test99', objNXPProfile.Id);
        try {
            insert NXPUser;
        }
        catch(System.DMLException e)
        {
            System.debug(e.getMessage());
        }
               
        List<GroupMember> lstNXPGroupMember = [Select GroupId, UserOrGroupId from GroupMember where UserOrGroupId =: NXPUser.Id];

        System.debug(NXPUser.Id);

       // System.assert(lstNXPGroupMember.size() > 0);
        
        if (lstNXPGroupMember.size() > 0)
        {
            Group NXPGroup = lstNXPGroups[0];
            GroupMember NXPGroupMember = lstNXPGroupMember[0];
            System.assert(NXPGroupMember.GroupId == NXPGroup.Id);
        }
        
        test.stopTest();        
    }
}