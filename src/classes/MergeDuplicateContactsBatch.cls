global with sharing class MergeDuplicateContactsBatch implements Database.Batchable<String> , 
                                                            Database.AllowsCallouts ,
                                                            Database.Stateful    
{
    global Id NXP_COMMUNITY_ID;
	global Id NXP_ID;
	global set<Id> DUMMY_ACCOUNT_IDS;
	    
    global static string COMMUNITY_PROFILE = 'NXP Customer Community Login User';
	global static string ACCOUNT_DUMMY = 'Dummy';
	global static string ACCOUNT_CRM = 'CRM';
	
    global Map<Contact, String> mapFailedContactToReason = new Map<Contact, String>();
    //Email -> {Key -> {contacts}}
    global Map<String, Map<String, List<Contact>>> mapEmailToContacts = new Map<String, Map<String, List<Contact>>>();
    global Map<String, Set<Id>> mapEmailToAccountIds = new Map<String, Set<Id>>();
	global Map<String, Map<Id, Contact>> mapEmailToContactIds = new Map<String, Map<Id, Contact>>();
	
    global string strIndex;
    global MergeDuplicateContactsBatch(string str)
    {
    	strIndex = str;
    }
    
    global MergeDuplicateContactsBatch()
    {
    }
    
    global Iterable<String> start(Database.BatchableContext BC)
    {
		DUMMY_ACCOUNT_IDS = new Set<Id>();
		for(Account obj : [Select Id, Name from Account Where Name ='Technical Services' or Name = 'NXP Community' or Name = 'Training' or Name = 'NXP Semiconductors' or Name = 'NXP'])
		{
			DUMMY_ACCOUNT_IDS.add(obj.Id);
			if(obj.Name == 'NXP Community')
			{
				NXP_COMMUNITY_ID = obj.Id;
			}
			//else if(obj.Name == 'NXP')
			//{
			//	NXP_ID = obj.Id;
		//	}
		}
		        
        String strQuery = 'SELECT Id, LastName, FirstName, Email, AccountId FROM Contact' +
            				' Where AccountId != null AND Email != \'\' and Email like \'%@nxp.com\'' + 
                           	' ORDER BY Email, AccountId';
        
        system.debug('=== strQuery ' + strQuery);
        
        List<Contact> lstContacts = database.query(strQuery);
      
        for(Contact obj : lstContacts)
        {
			String strKey = (DUMMY_ACCOUNT_IDS.contains(obj.AccountId) ? ACCOUNT_DUMMY : ACCOUNT_CRM);
			
            if(mapEmailToContacts.containsKey(obj.Email))
            {
				mapEmailToAccountIds.get(obj.Email).add(obj.AccountId);
				
				mapEmailToContactIds.get(obj.Email).put(obj.Id, obj);
				
				if(mapEmailToContacts.get(obj.Email).containsKey(strKey))
				{
					mapEmailToContacts.get(obj.Email).get(strKey).add(obj);
				}
				else
				{
                    mapEmailToContacts.get(obj.Email).put(strKey, new List<Contact>{obj});
				}
            }
            else
            {
                mapEmailToAccountIds.put(obj.Email, new set<Id>{obj.AccountId});
				
				mapEmailToContactIds.put(obj.Email, new Map<Id, Contact>{obj.Id => obj});
				
				mapEmailToContacts.put(obj.Email, new Map<String, list<Contact>> {strKey => new list<Contact>{obj}});                
            }
        }
        
        for(String strEmail : mapEmailToContacts.keySet())
        {
            //if only CRM contact
            if( mapEmailToContacts.get(strEmail).containsKey(ACCOUNT_CRM))
            {
                mapEmailToContacts.remove(strEmail);
				mapEmailToAccountIds.remove(strEmail);
                mapEmailToContactIds.remove(strEmail);
            }
            else if ( (mapEmailToContacts.get(strEmail).containsKey(ACCOUNT_DUMMY)) &&
                mapEmailToContacts.get(strEmail).get(ACCOUNT_DUMMY).size() <= 1)
            {
                mapEmailToContacts.remove(strEmail);
				mapEmailToAccountIds.remove(strEmail);
                mapEmailToContactIds.remove(strEmail);
            }
        }
        
        system.debug('=== duplicate contacts ' + mapEmailToContacts.size());
        return new List<String>(mapEmailToContacts.keySet());       
    }
        
    global void execute(Database.BatchableContext BC, List<String> scope)
    {
        for(String strEmail : scope)
        {
			if(! mapEmailToContacts.get(strEmail).containsKey(ACCOUNT_CRM) && mapEmailToContacts.get(strEmail).containsKey(ACCOUNT_DUMMY))
			{
				List<Contact> lstDuplicateContacts = mapEmailToContacts.get(strEmail).get(ACCOUNT_DUMMY);
				Contact objMasterContact;
                
                //check if any contact associated with NXP Community account
                if(mapEmailToAccountIds.containsKey(strEmail) && mapEmailToAccountIds.get(strEmail).contains(NXP_COMMUNITY_ID))
                {
                    //community user might exists so retrieve community users
                    List<User> lstUsers = [Select Id, Email, ContactId from User Where Email = : strEmail AND Profile.Name =: COMMUNITY_PROFILE ];
                    if(lstUsers.size() > 0)
                    {
                        User communityUser = lstUsers[0];
                        objMasterContact = mapEmailToContactIds.get(strEmail).get(communityUser.ContactId);
                    }
                }
                if(objMasterContact == null)
                {
                    objMasterContact = lstDuplicateContacts[0];
                }
    
                for(Contact objDuplicateContact : lstDuplicateContacts )
                {
                    system.debug('===objDuplicateContact ' + objDuplicateContact.Id + ' ' + objDuplicateContact.LastName + ' ' + objDuplicateContact.FirstName + ' ' + objDuplicateContact.AccountId); // + ' ' + objCRMContact.LastModifiedDate );
                    
                    if(objDuplicateContact.Id == objMasterContact.Id)
                    {
                        continue;
                    }
                    
                    Database.MergeResult objResult = Database.merge(objMasterContact, objDuplicateContact, false);
                    
                    if(!objResult.isSuccess())
                    {
                        mapFailedContactToReason.put(objDuplicateContact, objResult.getErrors()[0].getMessage());
                    }
                }
			}
        }       
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //fetch the ApexJob Details from the database
        AsyncApexJob batchJob = [Select CreatedBy.Email, Status, ExtendedStatus,  TotalJobItems , JobItemsProcessed, NumberOfErrors 
                                    From AsyncApexJob
                                    Where Id = :BC.getJobId()];            
        
        Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();            
        objMail.setToAddresses(new String[] {batchJob.CreatedBy.Email});
        objMail.setSubject('CRM Contact Record Merge ' + batchJob.Status + ' for index ' + strIndex);
        
        String strHtml = '<html><body><p>CRM Contact Record Merge ' + batchJob.Status + '.</p><br />';
        strHtml = strHtml + '<p><strong>Total Job Items : </strong>' + batchJob.TotalJobItems + '<br /><strong>Total Jobs Processed : </strong>' + batchJob.JobItemsProcessed + '<br /><strong>Number Of Errors : </strong>' + batchJob.NumberOfErrors + '</p>';
        
        if(batchJob.ExtendedStatus != null && batchJob.ExtendedStatus.trim() != '')
        {
            strHtml = strHtml + '<p><strong>Detailed Status : </strong>' + batchJob.ExtendedStatus +  '</p>'    ;
        }
        
        //Add Job Failure Details
                
        if(mapFailedContactToReason.size() > 0 )
        {           
            System.Debug('===Generating Report for failed Record  =========');
            strHtml =  strHtml + '<p><strong>Contact Records Failed To merge</strong></p>' + '<table cellspacing=\'2\' cellpadding=\'2\' width=\'98%\' border=\'1\' >' + + '<tr><th>Contact Id</th><th>Email/th><th>Error Description</th></tr>';           
                       
            for(Contact objContact : mapFailedContactToReason.keySet())
            {
                strHtml = strHtml + '<tr><td>' + objContact.Id + '</td><td>' + objContact.Email + '</td><td>' + mapFailedContactToReason.get(objContact) +'</td></tr>'; 
            }
            strHtml = strHtml + '</table>';               
        } 
        
        strHtml = strHtml + '</body></html>';
    
        objMail.setHtmlBody(strHtml);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });    
    }
}