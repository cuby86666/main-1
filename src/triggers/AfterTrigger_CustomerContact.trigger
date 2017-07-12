/***********************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      05 Sep 2013
@Description:       To sync Customer Contact from Customer Hub to SF-CRM Account object. 
**************************************************************************************/

trigger AfterTrigger_CustomerContact on Customer_Contact__c (after insert, after update, after delete) 
{
	List<Customer_Contact__c> lstCustomerContacts = new List<Customer_Contact__c>();
	
	if(Trigger.isInsert)
    {
    	for(Customer_Contact__c objCustomerContact : Trigger.new)
    	{
    		if(objCustomerContact.Role__c == CustomerContactTrigger.ROLE_ACCOUNT_MANAGER || objCustomerContact.Role__c == CustomerContactTrigger.ROLE_SERVICE_MANAGER)
    		{
    			lstCustomerContacts.add(objCustomerContact);
    		}		
    	}
    	
    	if(lstCustomerContacts.size() > 0)
		{
			CustomerContactTrigger.syncContactToSfCrm(lstCustomerContacts, null);	
		}
    }
    else if(Trigger.isUpdate)
    {
    	Customer_Contact__c oldContact;
    	
    	for(Customer_Contact__c objCustomerContact : Trigger.new)
    	{
    		oldContact = Trigger.oldMap.get(objCustomerContact.Id);
    		if((oldContact.Role__c == CustomerContactTrigger.ROLE_ACCOUNT_MANAGER || oldContact.Role__c == CustomerContactTrigger.ROLE_SERVICE_MANAGER ||
    			objCustomerContact.Role__c == CustomerContactTrigger.ROLE_ACCOUNT_MANAGER || objCustomerContact.Role__c == CustomerContactTrigger.ROLE_SERVICE_MANAGER) 
    				&& (oldContact.Role__c <> objCustomerContact.Role__c || oldContact.Region__c <> objCustomerContact.Region__c))
    		{
    			lstCustomerContacts.add(objCustomerContact);
    		}		
    	}
    	if(lstCustomerContacts.size() > 0)
		{
			CustomerContactTrigger.syncContactToSfCrm(lstCustomerContacts, Trigger.oldMap);	
		}
    }
    else if(Trigger.isDelete)
    {
    	for(Customer_Contact__c objCustomerContact : Trigger.old)
    	{
    		if(objCustomerContact.Role__c == CustomerContactTrigger.ROLE_ACCOUNT_MANAGER || objCustomerContact.Role__c == CustomerContactTrigger.ROLE_SERVICE_MANAGER)
    		{
    			lstCustomerContacts.add(objCustomerContact);
    		}		
    	}
    	if(lstCustomerContacts.size() > 0)
		{
			CustomerContactTrigger.syncContactToSfCrmOnDelete(lstCustomerContacts);	
		}
    }
}