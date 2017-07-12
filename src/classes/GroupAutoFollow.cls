public class GroupAutoFollow
{

    public static void EnrollNXPUser(Set<Id> userIds)
    {
       List<User> userList =[Select Id from User where Id in :userIds] ;
       string groupId; 
        //checking the focus group exists or not. if doesn't create the group and attach the user
       List<Group> groupList =[Select Id from Group where name ='All Internal NXP Users'];
        if(!groupList.isEmpty())
        {
            groupId = groupList[0].Id;
        }
        else
        {
            Group g = new Group(Name='All Internal NXP Users');
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
//            insert gMemberList;
            MixedDMLOps.ins( gMemberList );
    }
/////////////////////////////////////////////////////

 /*   public static void EnrollNERUser(Set<Id> userIds)
    {
       List<User> userList =[Select Id from User where Id in :userIds] ;
       string groupId; 
        //checking the focus group exists or not. if doesn't create the group and attach the user
       List<Group> groupList =[Select Id from Group where name ='All Internal NER Users'];
        if(!groupList.isEmpty())
        {
            groupId = groupList[0].Id;
        }
        else
        {
            Group g = new Group(Name='All Internal NER Users');
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
//            insert gMemberList;
            MixedDMLOps.ins( gMemberList ) ;
    }*/

}