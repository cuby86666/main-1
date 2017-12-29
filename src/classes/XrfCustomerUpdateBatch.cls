global class XrfCustomerUpdateBatch //implements Database.Batchable<sObject>, Database.Stateful, Schedulable
{
    /* After One FUnnel 2.0, Cross reference related code should be obsoleted.

    private static final String TYPE_MN_OPPTY = 'Model N Oppty';
    
    global static final Integer oppStartYear = 2015;
    global static final Integer oppEndYear = Date.today().year() + 2;
    global Integer currentYear;
    
    global XrfCustomerUpdateBatch()
    {
        currentYear = oppStartYear - 1;
    }

    
    global XrfCustomerUpdateBatch(Integer year)
    {
        currentYear = year;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
       String strQuery = 'RecordType.Name=\'' + TYPE_MN_OPPTY + '\'';
            
        if (currentYear >= oppStartYear)
            strQuery = strQuery + ' and CloseDate >= ' + String.valueOf(Date.parse('1/1/' + currentYear));
        
        if (currentYear < oppEndYear)
            strQuery = strQuery + ' and CloseDate <= ' + String.valueOf(Date.parse('12/31/' + currentYear));
        //System.debug('@@@ ' + strQuery);
        //return Database.getQueryLocator(strQuery);
        return new OpportunitiesSelector().selectByConditionWithAccountAndOwnerQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        list<Opportunity> opptys = (list<Opportunity>)scope;
		OpportunityService.updateEndCustomerAccounts(opptys, true);
    }            
  	global void finish(Database.BatchableContext BC)
  	{
        currentYear++; //get next year
        if (currentYear <= oppEndYear)
        { //if next year <= end year, do batch job
            XrfCustomerUpdateBatch c = new XrfCustomerUpdateBatch(currentYear);//, mapEndCustNameToLoc);
            database.executebatch(c);
        }
  	}
    
    global void execute(SchedulableContext sc) 
    {
        XrfCustomerUpdateBatch c= new XrfCustomerUpdateBatch();
	    database.executebatch(c);
    }*/
}