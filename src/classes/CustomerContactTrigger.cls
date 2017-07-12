/***********************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      04 Sep 2013
@Description:       Class for all Customer Contact Trigger Methods
**************************************************************************************/


public with sharing class CustomerContactTrigger 
{
	public final static String PARENT_ACCOUNT = 'Parent_Account';
	public final static String PRE_ACCOUNT = 'PreAccount';
	
	public final static String ROLE_ACCOUNT_MANAGER = 'Account Manager';
	public final static String ROLE_SERVICE_MANAGER = 'Account Service Manager';
	
	public final static String REGION_GLOBAL = 'Global';
	public final static String REGION_AMEC = 'AM - AMEC';
	public final static String REGION_EMEA = 'EU - EMEA';
	public final static String REGION_GC = 'AP - GC';
	public final static String REGION_JAPAN = 'AP - JAPAN';
	public final static String REGION_KOREA = 'AP - KOREA';
	public final static String REGION_SAP = 'AP - SAP';	
	
	private static RecordType parentAccount;
	private static RecordType preAccount;
	
	private static void fetchAccountRecordTypes()
	{
		//get the record type
	    for(RecordType rt : [Select Id, DeveloperName
	                           From RecordType
	                           Where SobjectType = 'Account' and (DeveloperName =: PARENT_ACCOUNT OR DeveloperName =: PRE_ACCOUNT)and IsActive=true
	                           Limit 2])
	    {
	    	if(rt.DeveloperName == PARENT_ACCOUNT)
	    	{
	    		parentAccount = rt;	
	    	}
	    	else
	    	{
	    		preAccount = rt;
	    	}
	    }		
	}
	
	private static Id fetchHubContactUserId(Id hubContactId , Map<Id, String> mapContactIdToEmail, Map<String, Id> mapContactEmailToUserId)
	{	
		Id contactUserId;
		
		if(hubContactId != null && mapContactIdToEmail.containsKey(hubContactId))
		{
			String managerEmail = mapContactIdToEmail.get(hubContactId);
			
			if(mapContactEmailToUserId.containsKey(managerEmail))
			{
				contactUserId = mapContactEmailToUserId.get(managerEmail); 
			}
		}		
		return contactUserId;
	}
	
	
	
	private static void clearManagerFromAccount(Account acc , Customer_Contact__c objContact)
	{
		if(objContact.Role__c == ROLE_ACCOUNT_MANAGER)
		{
			if(objContact.Region__c == REGION_GLOBAL)
			{
				acc.Account_Manager__c = null;
			}
			else if(objContact.Region__c == REGION_AMEC)
			{
				acc.Account_Manager_AMEC__c = null;
			}
			else if(objContact.Region__c == REGION_EMEA)
			{
				acc.Account_Manager_EMEA__c = null;
			}
			else if(objContact.Region__c == REGION_GC)
			{
				acc.Account_Manager_GC__c = null;
			}
			else if(objContact.Region__c == REGION_JAPAN)
			{
				acc.Account_Manager_Japan__c = null;
			}
			else if(objContact.Region__c == REGION_KOREA)
			{
				if(acc.Account_Manager_Korea_2__c != null)
				{
					acc.Account_Manager_Korea_2__c = null;
				}
				else
				{
					acc.Account_Manager_Korea__c = null;
				}
			}
			else if(objContact.Region__c == REGION_SAP)
			{
				if(acc.Account_Manager_SAP_3__c != null)
				{
					acc.Account_Manager_SAP_3__c = null;
				}
				else if(acc.Account_Manager_SAP_2__c != null)
				{
					acc.Account_Manager_SAP_2__c = null;
				}
				else
				{
					acc.Account_Manager_SAP__c = null;
				}
			}
		}
		else if(objContact.Role__c == ROLE_SERVICE_MANAGER)
		{
			if(objContact.Region__c == REGION_GLOBAL)
			{
				acc.Service_Manager__c = null;
			}
			else if(objContact.Region__c == REGION_AMEC)
			{
				acc.Service_Manager_AMEC__c = null;
			}
			else if(objContact.Region__c == REGION_EMEA)
			{
				acc.Service_Manager_EMEA__c = null;										
			}
			else if(objContact.Region__c == REGION_GC)
			{
				acc.Service_Manager_GC__c = null;
			}
			else if(objContact.Region__c == REGION_JAPAN)
			{
				acc.Service_Manager_Japan__c = null;
			}
			else if(objContact.Region__c == REGION_KOREA)
			{
				acc.Service_Manager_Korea__c = null;
			}
			else if(objContact.Region__c == REGION_SAP)
			{
				acc.Service_Manager_SAP__c = null;
			}
		}			
	}
	
	private static void assignManagerToAccount(Account acc, Customer_Contact__c objContact, Id contactUserId)
	{
		if(acc!= null && objContact != null && contactUserId != null)
		{
			if(objContact.Role__c == ROLE_ACCOUNT_MANAGER)
			{
				if(objContact.Region__c == REGION_GLOBAL)
				{
					acc.Account_Manager__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_AMEC)
				{
					acc.Account_Manager_AMEC__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_EMEA)
				{
					acc.Account_Manager_EMEA__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_GC)
				{
					acc.Account_Manager_GC__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_JAPAN)
				{
					acc.Account_Manager_Japan__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_KOREA)
				{
					if(acc.Account_Manager_Korea__c == null)
					{
						acc.Account_Manager_Korea__c = contactUserId;
					}
					else
					{
						acc.Account_Manager_Korea_2__c = contactUserId;
					}
				}
				else if(objContact.Region__c == REGION_SAP)
				{
					if(acc.Account_Manager_SAP__c == null)
					{
						acc.Account_Manager_SAP__c = contactUserId;
					}
					else if(acc.Account_Manager_SAP_2__c == null)
					{
						acc.Account_Manager_SAP_2__c = contactUserId;
					}
					else
					{
						acc.Account_Manager_SAP_3__c = contactUserId;
					}
				}
			}
			else if(objContact.Role__c == ROLE_SERVICE_MANAGER)
			{
				if(objContact.Region__c == REGION_GLOBAL)
				{
					acc.Service_Manager__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_AMEC)
				{
					acc.Service_Manager_AMEC__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_EMEA)
				{
					acc.Service_Manager_EMEA__c = contactUserId;										
				}
				else if(objContact.Region__c == REGION_GC)
				{
					acc.Service_Manager_GC__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_JAPAN)
				{
					acc.Service_Manager_Japan__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_KOREA)
				{
					acc.Service_Manager_Korea__c = contactUserId;
				}
				else if(objContact.Region__c == REGION_SAP)
				{
					acc.Service_Manager_SAP__c = contactUserId;
				}
			}
		}
	}
	
	public static void syncContactToSfCrm(List<Customer_Contact__c> lstCustomerContacts, Map<Id, Customer_Contact__c> oldCustomerContacts)
	{
		if(lstCustomerContacts != null && lstCustomerContacts.size() > 0)
		{
			 //fetch the record types for Account(Std Object) in SF-CRM
			fetchAccountRecordTypes();
			
			//prepare a set of all customer ids
			Set<Id> customerIds = new Set<Id>();
			Set<Id> contactIds = new Set<Id>();
			
			for(Customer_Contact__c objContact : lstCustomerContacts)
			{
				customerIds.add(objContact.Customer__c);
				contactIds.add(objContact.Contact__c);	
			}
			
			//fetch NXP GID of all unique customers
			Map<Id, String> mapCustomerIdToGid = new Map<Id, String>();	
			Map<String, Id> mapGidToCustomerId = new Map<String, Id>();
					
			for(Customer__c objCustomer : [Select Id, Name From Customer__c Where Id in :customerIds])
			{
				mapCustomerIdToGid.put(objCustomer.Id, objCustomer.Name);
				mapGidToCustomerId.put(objCustomer.Name , objCustomer.Id);
			}
			
			//fetch EmailId of all unique contacts
			Map<Id, String> mapContactIdToEmail = new Map<Id, String>();
			for(Hub_Contact__c objContact : [Select Id, Email__c From Hub_Contact__c Where Id in :contactIds])
			{
				mapContactIdToEmail.put(objContact.Id, objContact.Email__c);
			}
			
			//map of HubContact Email To User Ids
		    Map<String, Id> mapContactEmailToUserId = new Map<String, Id>();
		    	    
		    //fetch all Active Users in SF-CRM correspoding to Managers (Hub Contact)
		    for(User objUser : [Select Id, Email From User Where IsActive = true and Email in : mapContactIdToEmail.values()])
		    {
		    	mapContactEmailToUserId.put(objUser.Email, objUser.Id);	
		    }		    		
			
			Map<String , Account> mapCustomerGidToAccount = new Map<String, Account>();
			
			//fetch all SF-CRM Account records matching NXP-GIDs
			for(Account acc : [Select Id, NXP_GID__c,Account_Manager__c , Account_Manager_AMEC__c, Account_Manager_EMEA__c ,
									Account_Manager_GC__c , Account_Manager_Japan__c , Account_Manager_Korea__c , Account_Manager_Korea_2__c , Account_Manager_SAP__c ,
	        						Account_Manager_SAP_2__c , Account_Manager_SAP_3__c , Service_Manager__c  , Service_Manager_AMEC__c , Service_Manager_EMEA__c ,
			    					Service_Manager_GC__c , Service_Manager_Japan__c , Service_Manager_Korea__c , Service_Manager_SAP__c
								From Account 
								Where NXP_GID__c in : mapCustomerIdToGid.values() 
								 	and (RecordTypeId =: parentAccount.Id OR RecordTypeId =: preAccount.Id)])
		 	{
		 		mapCustomerGidToAccount.put(acc.NXP_GID__c , acc);
		 	}
			
			
			//Assign Customer Contacts 
			
			Map<Id , Account> accountsToBeUpdated = new Map<Id , Account>();
			
			for(Customer_Contact__c objContact : lstCustomerContacts)
			{
				//find Customer GID for this contact
				if(mapCustomerIdToGid.containsKey(objContact.Customer__c))
				{
					String strGid = mapCustomerIdToGid.get(objContact.Customer__c);
					
					//find Account record for this Customer GID
					if(mapCustomerGidToAccount.containsKey(strGid))
					{
						Account acc = mapCustomerGidToAccount.get(strGid);
						//assign to new field
						if(objContact.Role__c == ROLE_ACCOUNT_MANAGER || objContact.Role__c == ROLE_SERVICE_MANAGER)
						{
							Id contactUserId = fetchHubContactUserId(objContact.Contact__c, mapContactIdToEmail, mapContactEmailToUserId);
							if(contactUserId != null)
							{
								assignManagerToAccount(acc, objContact, contactUserId);	
								if(!accountsToBeUpdated.containsKey(acc.Id))
								{
									accountsToBeUpdated.put(acc.Id, acc);	
								}
							}
						}
						
						//check if its update
						if(oldCustomerContacts != null && oldCustomerContacts.size() > 0)
						{
							//check for old role. if its Account/Service Manager previously
							if(oldCustomerContacts.containsKey(objContact.Id))
							{
								Customer_Contact__c oldContact = oldCustomerContacts.get(objContact.Id);
								clearManagerFromAccount(acc, oldContact);
								if(!accountsToBeUpdated.containsKey(acc.Id))
								{
									accountsToBeUpdated.put(acc.Id, acc);	
								}
							}	
						}
					}
				}
			}
					 	
		 	//update account records
		    if(accountsToBeUpdated.size() > 0)
		    {
		    	List<Account> lstAccountsToBeUpdated = accountsToBeUpdated.values();
		    	Database.SaveResult[] lstResults = Database.update(lstAccountsToBeUpdated , false);
		    	
		    	integer i=0;
				
				customerIds = new Set<Id>();
					
				for(Database.SaveResult result : lstResults)
				{
		            if(result.isSuccess())
		            {
		            	if(mapGidToCustomerId.containsKey(lstAccountsToBeUpdated[i].NXP_GID__c))
		    			{
		    				customerIds.add(mapGidToCustomerId.get(lstAccountsToBeUpdated[i].NXP_GID__c));	
		    			}
					}
		            i++;
		    	}
		    	
		    	if(customerIds.size() > 0)
		    	{
		    		List<Customer__c> lstCustomersToBeUpdated = [Select Id, Last_Updated_IT_systems_for_Sales__c
		    														From Customer__c
		    														Where Id in  : customerIds];
					for(Customer__c obj :  lstCustomersToBeUpdated)
					{
						obj.Last_Updated_IT_systems_for_Sales__c = 	Datetime.now();
					}
										
					if(lstCustomersToBeUpdated.size() > 0)
					{
						CustomerTrigger.IsFirstRun_AfterUpdate = true;
						update lstCustomersToBeUpdated;	
					}				
		    	}		    			    	
		    }	
		}	
	}
	
	public static void syncContactToSfCrmOnDelete(List<Customer_Contact__c> lstCustomerContacts)
	{
		if(lstCustomerContacts != null && lstCustomerContacts.size() > 0)
		{
			//fetch the record types for Account(Std Object) in SF-CRM
			fetchAccountRecordTypes();
			
			//prepare a set of all customer ids
			Set<Id> customerIds = new Set<Id>();
			Set<Id> contactIds = new Set<Id>();
			
			for(Customer_Contact__c objContact : lstCustomerContacts)
			{
				customerIds.add(objContact.Customer__c);
				contactIds.add(objContact.Contact__c);	
			}
			
			//fetch NXP GID of all unique customers
			Map<Id, String> mapCustomerIdToGid = new Map<Id, String>();	
			Map<String, Id> mapGidToCustomerId = new Map<String, Id>();
					
			for(Customer__c objCustomer : [Select Id, Name From Customer__c Where Id in :customerIds])
			{
				mapCustomerIdToGid.put(objCustomer.Id, objCustomer.Name);
				mapGidToCustomerId.put(objCustomer.Name , objCustomer.Id);
			}
			
			Map<String , Account> mapCustomerGidToAccount = new Map<String, Account>();
			
			//fetch all SF-CRM Account records matching NXP-GIDs
			for(Account acc : [Select Id, NXP_GID__c,Account_Manager__c , Account_Manager_AMEC__c, Account_Manager_EMEA__c ,
									Account_Manager_GC__c , Account_Manager_Japan__c , Account_Manager_Korea__c , Account_Manager_Korea_2__c , Account_Manager_SAP__c ,
	        						Account_Manager_SAP_2__c , Account_Manager_SAP_3__c , Service_Manager__c  , Service_Manager_AMEC__c , Service_Manager_EMEA__c ,
			    					Service_Manager_GC__c , Service_Manager_Japan__c , Service_Manager_Korea__c , Service_Manager_SAP__c
								From Account 
								Where NXP_GID__c in : mapCustomerIdToGid.values() 
								 	and (RecordTypeId =: parentAccount.Id OR RecordTypeId =: preAccount.Id)])
		 	{
		 		mapCustomerGidToAccount.put(acc.NXP_GID__c , acc);
		 	}
		 	
		 	Map<Id , Account> accountsToBeUpdated = new Map<Id , Account>();
		 	
			for(Customer_Contact__c objContact : lstCustomerContacts)
			{
				//find Customer GID for this contact
				if(mapCustomerIdToGid.containsKey(objContact.Customer__c))
				{
					String strGid = mapCustomerIdToGid.get(objContact.Customer__c);
					//find Account record for this Customer GID
					if(mapCustomerGidToAccount.containsKey(strGid))
					{
						Account acc = mapCustomerGidToAccount.get(strGid);
						clearManagerFromAccount(acc, objContact);
						if(!accountsToBeUpdated.containsKey(acc.Id))
						{
							accountsToBeUpdated.put(acc.Id, acc);	
						}
					}
				}
			}
		 	
		 	//update account records
		    if(accountsToBeUpdated.size() > 0)
		    {
		    	List<Account> lstAccountsToBeUpdated = accountsToBeUpdated.values();
		    	Database.SaveResult[] lstResults = Database.update(lstAccountsToBeUpdated , false);
		    	
		    	integer i=0;
				
				customerIds = new Set<Id>();
					
				for(Database.SaveResult result : lstResults)
				{
		            if(result.isSuccess())
		            {
		            	if(mapGidToCustomerId.containsKey(lstAccountsToBeUpdated[i].NXP_GID__c))
		    			{
		    				customerIds.add(mapGidToCustomerId.get(lstAccountsToBeUpdated[i].NXP_GID__c));	
		    			}
					}
		            i++;
		    	}
		    	
		    	if(customerIds.size() > 0)
		    	{
		    		List<Customer__c> lstCustomersToBeUpdated = [Select Id, Last_Updated_IT_systems_for_Sales__c
		    														From Customer__c
		    														Where Id in  : customerIds];
					
					for(Customer__c obj :  lstCustomersToBeUpdated)
					{
						obj.Last_Updated_IT_systems_for_Sales__c = 	Datetime.now();
					}
										
					if(lstCustomersToBeUpdated.size() > 0)
					{
						CustomerTrigger.IsFirstRun_AfterUpdate = true;
						update lstCustomersToBeUpdated;	
					}				
		    	}		    			    	
		    }			
		}
	}

}