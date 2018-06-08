global class ModelNOpportunityAccountsUpdateJob implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	
	private static final String TYPE_MN_OPPTY = 'Model N Oppty';

    global static final Integer oppStartYear = 2015;
    global static final Integer oppEndYear = Date.today().year() + 2;
    global Integer currentYear;
	
	global ModelNOpportunityAccountsUpdateJob() {
		currentYear = oppStartYear - 1;
	}

	global ModelNOpportunityAccountsUpdateJob(Integer year) {
		currentYear = year;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery = 'RecordType.Name=\'' + TYPE_MN_OPPTY + '\'';
            
        if (currentYear >= oppStartYear)
            strQuery = strQuery + ' and CloseDate >= ' + String.valueOf(Date.parse('1/1/' + currentYear));
        
        if (currentYear < oppEndYear)
            strQuery = strQuery + ' and CloseDate <= ' + String.valueOf(Date.parse('12/31/' + currentYear));

        return new OpportunitiesSelector().selectByConditionWithAccountAndOwnerQueryLocator(strQuery);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
        list<Opportunity> oppties = (list<Opportunity>)scope;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		OpportunityService.updateMnOpportunityAccountsAndOwners(oppties, uow);
        OpportunityService.updateMnOpportunityStages(oppties, uow);
		uow.commitWork();
	}
	
	global void finish(Database.BatchableContext BC) {
        currentYear++; //get next year
        if (currentYear <= oppEndYear)
        { //if next year <= end year, do batch job
            ModelNOpportunityAccountsUpdateJob c = new ModelNOpportunityAccountsUpdateJob(currentYear);//, mapEndCustNameToLoc);
            database.executebatch(c);
        }
	}
	
    global void execute(SchedulableContext sc) 
    {
        ModelNOpportunityAccountsUpdateJob c= new ModelNOpportunityAccountsUpdateJob();
	    database.executebatch(c);
    }
}