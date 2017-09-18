/**********************************************************************************
@Modified By :      Nisha Agrawal
@Modified Date:     21 Aug 2017
@Description:       Modified to expose public group name for test class
**********************************************************************************/

public class GroupAutoFollow
{
    public static string GROUP_NAME = 'All Internal NXP Users'; //added by Nisha Agrawal on Aug 21, 2017 to expose it in test class
	public static void EnrollNXPUser(Set<Id> userIds)
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
            //insert gMemberList;
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
}{
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