trigger CommunityProjectDetailUpdateUserType on Project_User__c (before insert) 
{
list<user> lstUser= [select id,usertype from user where id=:trigger.new[0].user__c];
system.debug(lstUser);
 for (Project_User__c objProjUser: Trigger.new)
    {
    
    system.debug('########'+lstUser[0].usertype);
     if(lstUser[0].usertype=='standard')
    {
    objProjUser.User_Type__c='Internal';
    }
    else
    objProjUser.User_Type__c='external';
   
    }
}