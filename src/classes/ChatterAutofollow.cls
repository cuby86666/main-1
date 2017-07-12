public class ChatterAutofollow
{
@future
public static void AddToGroups(Set<Id> userIds)
{
 List<User> users=[select id, Username from User where id in :userIds];
  System.Debug('$$User Id are '+ userIds);
 // set up the groups that the user should be added to
 List<String> groups=new List<String>{'0F9D00000004DMQKA2','0F9D00000004y9KKAQ'};
  
    List<CollaborationGroup> chatterGroups=[select id, Name from CollaborationGroup where id in :groups];
 
 List<CollaborationGroupMember> chatterGroupMembers=new List<CollaborationGroupMember>();
 //List<FeedPost> feedPosts=new List<FeedPost>();
       
     // loop the users that have been created
     for (User user : users)
     {
                // loop the groups
      for (CollaborationGroup chatterGroup : chatterGroups)
      {
                        // add the user to the group
   CollaborationGroupMember cand = 
       new CollaborationGroupMember(
                      CollaborationGroupId=chatterGroup.id,
                            MemberId = user.Id);
       chatterGroupMembers.add(cand);
                        // announce this!
          /*FeedPost fpost = new FeedPost(ParentId=chatterGroup.id,
                Body = user.username + ' added to group via trigger');
                    feedPosts.add(fpost);
          fpost = new FeedPost(ParentId=user.id,
                    Body = 'You have been added to the ' + chatterGroup.name + ' group via trigger');
                  feedPosts.add(fpost);*/
  }
 }
     
 insert chatterGroupMembers;
// insert feedPosts;
}
}