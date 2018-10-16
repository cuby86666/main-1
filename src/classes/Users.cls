public class Users
{
//Chatter Auto-follow
    Public static string GROUP_USER_HELP_SUPPORT = 'User Help & Support';
    Public static string GROUP_BEST_PRACTICES = 'Best Practices';
    
    
@future
     Public static void addToGroups(Set<Id> userIds)
      {

             List<User> users=[select id, Username from User where id in :userIds];
 
  
            // set up the groups that the user should be added to
            //  List<String> groups=new List<String>{'0F9D00000004DMQKA2','0F9D00000004y9KKAQ'};
  
             List<CollaborationGroup> chatterGroups=[select id, Name from CollaborationGroup 
                                                     where Name=:GROUP_USER_HELP_SUPPORT OR Name=:GROUP_BEST_PRACTICES limit 2];
 
            List<CollaborationGroupMember> chatterGroupMembers=new List<CollaborationGroupMember>();
            if(chatterGroups != null){
             // loop the users that have been created
             for (User user : users)
              {
               // loop the groups
                  for (CollaborationGroup chatterGroup : chatterGroups)
                   {
                   // add the user to the group
                       CollaborationGroupMember colGrpMem =  new CollaborationGroupMember(CollaborationGroupId=chatterGroup.id,
                                                                                     MemberId = user.Id);
                       chatterGroupMembers.add(colGrpMem);
                      
                   }
               }
            }
          insert chatterGroupMembers;
  
     }
 
 //Group Auto-Follow
 
   public static string GROUP_NAME = 'All Internal NXP Users'; //added by Nisha Agrawal on Aug 21, 2017 to expose it in test class
   Public static void EnrollNXPUser(Set<Id> userIds)
     {
           List<User> userList =[Select Id from User where Id in :userIds] ;
           string groupId; 
            //checking the focus group exists or not. if doesn't create the group and attach the user
           //List<Group> groupList =[Select Id from Group where name ='All Internal NXP Users']; //commented by Nisha Agrawal on Aug 21,2017
           List<Group> groupList =[Select Id from Group where name =: GROUP_NAME]; //added by Nisha Agrawal on Aug 21,2017
            if(!groupList.isEmpty())
            {
                groupId = groupList[0].Id;
            }
            else
            {
                //Group g = new Group(Name='All Internal NXP Users'); //commented by Nisha Agrawal on Aug 21,2017
                  Group g = new Group(Name = GROUP_NAME); //added by Nisha Agrawal on Aug 21,2017
                  insert g;
                  groupId = g.Id; 
            }

            List<GroupMember> gMemberList = new List<GroupMember>();
        
            for(User u :userList)
            {
               GroupMember gMember = new GroupMember();
               gMember.UserOrGroupId = u.Id;
               gMember.GroupId = groupId;
               gMemberList.add(gMember);
            }

            if(!gMemberList.isEmpty()) 
          //  insert gMemberList;
                MixedDMLOps.ins( gMemberList );
        
    }
    
     @Future(callout=true)
        Public static void updateStatus(Set<String> ids){
        
        List<New_User_Registration__c> newUserList = [Select id,name,status__c from New_User_Registration__c where id in: ids];
        if(newUserList.size()>0){
            for(New_User_Registration__c newUsr: newUserList){
                newUsr.status__c = 'User A/c Created';
            }
            update newUserList;
        } 
  }

}