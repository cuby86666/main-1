/*********************************************************************
Created by  : Shridevi Badiger
Created date: 20-Oct-2016
Description : SIR 1329-Populate value for Contact Service Level field.

**********************************************************************/
trigger Contact_BeforeTrigger on Contact (before insert,before update) 
{
    if(Trigger.isInsert)
        ContactClass.CSLIdentification(trigger.new);
    else{
        List<Contact> updatedCase = new List<Contact>();
        for(Contact c : Trigger.new){
            if(c.email != Trigger.oldMap.get(c.Id).Email || 
               	c.AccountId != Trigger.oldMap.get(c.Id).AccountId){
               updatedCase.add(c); 
            }
        }
        ContactClass.CSLIdentification(updatedCase);
    }
	
System.debug('trigger.new:::'+trigger.new);
}