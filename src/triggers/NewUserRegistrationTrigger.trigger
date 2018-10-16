trigger NewUserRegistrationTrigger on  New_User_Registration__c (before insert, before update, before delete, after insert, after update,after delete, after undelete) 
{
  TriggerFactory2.createHandler(New_User_Registration__c.sObjectType); 
}