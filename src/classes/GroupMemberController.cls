/**
    @Name : GroupMemberController
    @Date : 11 Nov 2011
    @Created By : Syed Jameel
    @Description : Show Group and Related User to GroupMember Report.
*/

public class GroupMemberController{
    public list<Group> groupList {get;set;}
    public Map<Id,User> mapUser{get;set;}
    public List<ModelGroupUser> modelgulist{get;set;}
    private set<Id> userIds;
    List<String> sgNames;
    Map<ID,List<String>> groupSubMap = new Map<ID,List<String>>();
    public GroupMemberController(){
        modelgulist = new List<ModelGroupUser>();  
        userIds = new Set<Id>();
        groupList = [Select g.id,RelatedId, g.Name,Type, (Select Id, GroupId, 
                            UserOrGroupId, SystemModstamp From GroupMembers )
                         From Group g 
                         where g.Name != null 
                         And Type != 'Queue' 
                         Order By g.name Asc limit 1000];
        for(Group g : groupList){
            
            System.Debug('####Name is '+ g.Name);
            System.Debug('####User List Size  '+ g.GroupMembers.size());
            if(g.name!=null && g.name.trim().length()>0){
                
                for(GroupMember gm : g.GroupMembers){
                    userIds.add(gm.UserOrGroupId);
                    /*if(gm.GroupId != null){
                        if(groupSubMap.containsKey(gm.GroupId)== false){
                            sgNames = new List<String>();
                            sgNames.add(gm.UserOrGroupId);
                        }else{
                            sgNames =  groupSubMap.get(gm.GroupID);
                            sgNames.add(gm.UserOrGroupId);
                                              
                        }
                       // if(g.name!=null && g.name.trim().length()>0){
                            groupSubMap.put(gm.GroupId,sgNames);
                        //}
                    }*/
                }
            }
        }
        //System.Debug('@@@@Group List IS ==>'+groupSubMap);
        mapUser = new Map<Id,User>([select id,name,email from user where id in : userIds]);
        for(Group g : groupList){
            if(g.name!=null && g.name.trim().length()>0){
                ModelGroupUser gu = new ModelGroupUser();
               
                if( g.GroupMembers.size() > 0){
                    for(GroupMember gm : g.GroupMembers){
                        user u = new user();
                        u = Mapuser.get(gm.UserOrGroupId);
                        if(u != null){                        
                            gu.usrList.add(u);
                            gu.groupId = g.id;
                            gu.groupName = g.name;   
                        }
                    }
                    if(gu != null && gu.usrList.size() >0)
                        modelgulist.add(gu);
                }
            }
        }
        system.debug(modelgulist);
    }
    public PageReference exportExcel(){
        return new PageReference('/apex/GroupMemberReportXLS');
    }
    public class ModelGroupUser{
        public Id groupId{get;set;}
        public string groupName{get;set;}
        public List<User> usrList{get;set;}
        public ModelGroupUser(){
            usrList = new List<User>(); 
        }
    }
}