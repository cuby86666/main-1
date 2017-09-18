global class XrfCustomerUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    private static final String TYPE_MN_OPPTY = 'Model N Oppty';
    private static final String TYPE_MN_CUSTOMER = 'Model N Customer';
    private static final String CUSTOMER_TMMA = 'Tier 4 - TMMA';
    private static final String CUSTOMER_TIER1 = 'Tier 1';
    private static final String CUSTOMER_TIER2 = 'Tier 2';
    private static final String CUSTOMER_TIER3 = 'Tier 3';

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
        String strQuery = 'Select id, AccountId, Account.Customer_Category__c, ' + 
            'Legacy_End_Customer_Name_and_Location__c, MN_Account_Id_Old__c from Opportunity ' + 
            'where RecordType.Name=\'' + TYPE_MN_OPPTY + '\'';
            
        if (currentYear >= oppStartYear)
            strQuery = strQuery + ' and CloseDate >= ' + String.valueOf(Date.parse('1/1/' + currentYear));
        
        if (currentYear < oppEndYear)
            strQuery = strQuery + ' and CloseDate <= ' + String.valueOf(Date.parse('12/31/' + currentYear));
        //System.debug('@@@ ' + strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        UNKNOWN_ACCOUNT = getUnknownAccountId();
        list<Opportunity> listOpp = (list<Opportunity>)scope;
        list<Opportunity> lstOppUpdate = new list<Opportunity>();
        list<Id> lstAccountId = new List<Id>();
  		for(Opportunity opp:listOpp) {
            lstAccountId.add(opp.MN_Account_Id_Old__c);
            //check oppty is TMMA child account by end customer name and location
            if(mapEndCustNameToLoc.containsKey(opp.Legacy_End_Customer_Name_and_Location__c)) {
                //oppty account should be TMMA child account
                Cross_Reference_Customer__c cust = mapEndCustNameToLoc.get(opp.Legacy_End_Customer_Name_and_Location__c);
                if (opp.AccountId != cust.Child_Account__c) {
                    //current oppty account is not TMMA account
                	if (opp.MN_Account_Id_Old__c == null) //backup original AccountId, if backup AccountId is null, do backup.
                        opp.MN_Account_Id_Old__c = opp.AccountId;
                    
                    opp.AccountId = cust.Child_Account__c; //assign TMMA account to oppty
                    lstOppUpdate.add(opp); //add oppty to update list
                }
            } else {
                //oppty account should not be TMMA child account
                /*** 2017-09-11 Modified by Rex Lai
                SFDC-815: Including Tier 1, Tier 2, Tier3 ***/
				if (opp.Account.Customer_Category__c == CUSTOMER_TMMA || 
                    opp.Account.Customer_Category__c == CUSTOMER_TIER1 || 
                    opp.Account.Customer_Category__c == CUSTOMER_TIER2 || 
                    opp.Account.Customer_Category__c == CUSTOMER_TIER3) {
                    //if current oppty account is TMMA
                    if (opp.MN_Account_Id_Old__c != null && opp.MN_Account_Id_Old__c.length() > 0) //backup AccountId is not null, rollback oppty AccountId
                        opp.AccountId = opp.MN_Account_Id_Old__c;
                    else //if backup AccountId is null, set oppty AccountId to Unknown
                        opp.AccountId = UNKNOWN_ACCOUNT;
                    lstOppUpdate.add(opp); //add oppty to update list
                }
            }
            lstAccountId.add(opp.AccountId);
        }
        //check invalid account id
        Map<ID, Account> mapAccount = new Map<ID, Account>([SELECT Id, Name FROM Account Where Id =: lstAccountId]);
        for (Opportunity o : lstOppUpdate) {
            if (!mapAccount.containsKey(o.AccountId)) {
                o.AccountId = UNKNOWN_ACCOUNT;
            }
        }
        if (lstOppUpdate.size() > 0) {
            //if update list size > 0, do update
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

    global String getUnknownAccountId() {
        if (UNKNOWN_ACCOUNT == null) {
            //find Unknown AccountId
            List<Account> lstAccount = [Select Id from Account Where Name = 'Unknown'];
            if (lstAccount.size() > 0) UNKNOWN_ACCOUNT = lstAccount.get(0).Id;            
        }
        return UNKNOWN_ACCOUNT;
    }
    
    global Map<string,Cross_Reference_Customer__c> getCrossReferenceCustomer()
    {
        List<Cross_Reference_Customer__c> lstEndCustomer = [select Child_Account__c, Customer_Name__c, Customer_Location__c, End_Customer_Name_and_Location__c 
                                                            from Cross_Reference_Customer__c Where RecordType.Name =: TYPE_MN_CUSTOMER];
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