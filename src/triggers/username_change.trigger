trigger username_change on User (before insert) {
  
  List<user> newuser_list= trigger.new;
  
    user u = newuser_list.get(0);
    List<user> alluser_list =[select username from user where username=:u.email Limit 1];
    if(alluser_list.size()!=0 )
    u.Username= u.email + '.nxp';
  
}