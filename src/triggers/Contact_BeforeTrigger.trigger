/*********************************************************************
Created by  : Shridevi Badiger
Created date: 20-Oct-2016
Description : SIR 1329-Populate value for Contact Service Level field.

**********************************************************************/
trigger Contact_BeforeTrigger on Contact (before insert,before update) 
{

ContactClass.CSLIdentification(trigger.new);

System.debug('trigger.new:::'+trigger.new);
}