global class XrfCustomerUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    private static final String TYPE_MN_OPPTY = 'Model N Oppty';
    private static final String CUSTOMER_TMMA = 'Tier 4 - TMMA';

    global final map<String,Cross_Reference_Customer__c> mapEndCustNameToLoc;
    global final map<String,String> mapMNAccountId;
    
    global static final Integer oppStartYear = 2015;
    global static final Integer oppEndYear = Date.today().year() + 2;
    global Integer currentYear;
    global static string UNKNOWN_ACCOUNT;
    
    global XrfCustomerUpdateBatch()
    {
        currentYear = oppStartYear - 1;
       	mapEndCustNameToLoc = getCrossReferenceCustomer();
    }

    
    global XrfCustomerUpdateBatch(Integer year, Map<String,Cross_Reference_Customer__c> EndCustName)
    {
        currentYear = year;
       	mapEndCustNameToLoc = EndCustName;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //find Unknown AccountId
        List<Account> lstAccount = [Select Id from Account Where Name = 'Unknown'];
        if (lstAccount.size() > 0) UNKNOWN_ACCOUNT = lstAccount.get(0).Id;
        
        String strQuery = 'Select id, AccountId, Account.Customer_Category__c, ' + 
            'Legacy_End_Customer_Name_and_Location__c, MN_Account_Id_Old__c from Opportunity ' + 
            'where RecordType.Name=\'' + TYPE_MN_OPPTY + '\'';
            
        if (currentYear >= oppStartYear)
            strQuery = strQuery + ' and CloseDate >= ' + String.valueOf(Date.parse('1/1/' + currentYear));
        
        if (currentYear < oppEndYear)
            strQuery = strQuery + ' and CloseDate <= ' + String.valueOf(Date.parse('12/31/' + currentYear));
        System.debug('@@@ ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        list<Opportunity> listOpp = (list<Opportunity>)scope;
        list<Opportunity> lstOppUpdate = new list<Opportunity>();
  		for(Opportunity opp:listOpp)
        {
            //check oppty is TMMA child account by end customer name and location
            if(mapEndCustNameToLoc.containsKey(opp.Legacy_End_Customer_Name_and_Location__c))
            { //oppty account should be TMMA child account
                Cross_Reference_Customer__c cust = mapEndCustNameToLoc.get(opp.Legacy_End_Customer_Name_and_Location__c);
                if (opp.AccountId != cust.Child_Account__c)
                { //current oppty account is not TMMA account
                	if (opp.MN_Account_Id_Old__c == null) //backup original AccountId, if backup AccountId is null, do backup.
                        opp.MN_Account_Id_Old__c = opp.AccountId;
                    
                    opp.AccountId = cust.Child_Account__c; //assign TMMA account to oppty
                    lstOppUpdate.add(opp); //add oppty to update list
                }
            } else {
                //oppty account should not be TMMA child account
				if (opp.Account.Customer_Category__c == CUSTOMER_TMMA)
                { //if current oppty account is TMMA
                    if (opp.MN_Account_Id_Old__c != null) //backup AccountId is not null, rollback oppty AccountId
                        opp.AccountId = opp.MN_Account_Id_Old__c;
                    else //if backup AccountId is null, set oppty AccountId to Unknown
                        opp.AccountId = UNKNOWN_ACCOUNT;
                    lstOppUpdate.add(opp); //add oppty to update list
                }
            }                                                  
        }
        if (lstOppUpdate.size() > 0)
        { //if update list size > 0, do update
            update lstOppUpdate;
        }
    }            
  	global void finish(Database.BatchableContext BC)
  	{
        currentYear++; //get next year
        if (currentYear <= oppEndYear)
        { //if next year <= end year, do batch job
            XrfCustomerUpdateBatch c = new XrfCustomerUpdateBatch(currentYear, mapEndCustNameToLoc);
            database.executebatch(c);
        }
  	}

    global Map<string,Cross_Reference_Customer__c> getCrossReferenceCustomer()
    {
        List<Cross_Reference_Customer__c> lstEndCustomer = [select Child_Account__c, Customer_Name__c, Customer_Location__c, End_Customer_Name_and_Location__c 
                                                            from Cross_Reference_Customer__c];
        Map<string,Cross_Reference_Customer__c> mapEndCustNameToLoc = new map<string,Cross_Reference_Customer__c>();
        for(Cross_Reference_Customer__c cust:lstEndCustomer)
        {                           
            if(!mapEndCustNameToLoc.containskey(cust.End_Customer_Name_and_Location__c))
            {
                mapEndCustNameToLoc.put(cust.End_Customer_Name_and_Location__c,cust);
            }
        }    
		return mapEndCustNameToLoc;
    }
    
    global void execute(SchedulableContext sc) 
    {
        XrfCustomerUpdateBatch c= new XrfCustomerUpdateBatch();
	    database.executebatch(c);
    }
}