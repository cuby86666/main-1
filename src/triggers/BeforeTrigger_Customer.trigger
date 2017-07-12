/***************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      20 Jun 2013
@Description:       To sync Customer from Customer Hub to SF-CRM Account object. 
*******************************************************************************************************/

trigger BeforeTrigger_Customer on Customer__c (before insert, before update) 
{
	if(Trigger.isInsert || Trigger.isUpdate)
	{
		CustomerTrigger.AssignRegionByCountry(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);	
	}	
}