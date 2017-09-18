/**********************************************************************
@Created By:        Nisha Agrawal
@Created Date:      Aug 29, 2017
@Description:       Batch job to mass delete Star Access object data
***********************************************************************/
global class MassDeleteStarAccessDataBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator('Select Id From Star_Access__c Where CreatedDate < Yesterday');    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //NOTE: This class's functionality is not very critical and 
        //  results of main class is monitered via dashboard so not critically required to notify admins for success/failures        
    }
}