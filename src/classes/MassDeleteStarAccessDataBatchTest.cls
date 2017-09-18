/**********************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      04 Sep 2017
@Description:       Test Class for the class MassDeleteStarAccessDataBatch
**********************************************************************************/
@isTest
private class MassDeleteStarAccessDataBatchTest 
{
    static testMethod void MassDeleteStarAccessDataBatchTest1()
    {
        //prepare test data
        
        Id parentAccountRecordTypeId = AccountHelper.getParentRecordTypeID();
        Id childAccountRecordTypeId = AccountHelper.getChildRecordTypeID();
        
        //create parent account
        Account parentAccount =  new Account(Name = 'STAR', RecordTypeId = parentAccountRecordTypeId, Region__c = 'Americas'); 
        insert parentAccount;
        system.assert(parentAccount.Id != null);
        
        //create child account
        Account childAccount =  new Account(Name = 'STAR', ParentId = parentAccount.Id,  RecordTypeId = childAccountRecordTypeId); 
        insert childAccount;
        system.assert(childAccount.Id != null);
        
        //create opportunities
        
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        Date closeDate = Date.valueOf('2020-06-22');
        for(integer i =0; i < 200; i++)
        {
            Opportunity objOpp = new Opportunity(Name = 'test Opp' + i , AccountId = childAccount.Id, StageName = 'Initial Analysis', CloseDate = closeDate );
            lstOpportunities.add(objOpp );
        }
        
        insert lstOpportunities;
        for(Opportunity obj : lstOpportunities)
        {
            system.assert(obj.Id != null);
        }
        
        
        //create StarAccessScanner records
        List<Star_Access__c> lstStarAccess = new List<Star_Access__c>();
        String strKey;
        Date createdDate = date.today().addDays(-8);
        
        for( OpportunityShare objShare : [SELECT  OpportunityId,UserOrGroupId, OpportunityAccessLevel, RowCause FROM OpportunityShare])
        {
            if( String.valueOf(objShare.UserOrGroupId).left(3) == '005' )
            {
                strKey = String.valueOf(objShare.OpportunityId) + String.valueOf(objShare.UserOrGroupId);
                
                lstStarAccess.add(new STAR_Access__c (Name = strKey, OpportunityId__c = objShare.OpportunityId,
                        UserId__c = objShare.UserOrGroupId,OpportunityAccessLevel__c = objShare.OpportunityAccessLevel,
                        RowCause__c = objShare.RowCause , createdDate = createdDate ));
            }
       }
        
        insert lstStarAccess;
        
        for(Star_Access__c obj : lstStarAccess)
        {
            system.assert(obj.Id != null);
        }
        
        //start the test
        Test.startTest();
        Database.executeBatch(new MassDeleteStarAccessDataBatch(), 2000);
        Test.stopTest();
        
    //assert the results
    List<Star_Access__c> lstResults = [Select Id , Name From Star_Access__c];
        system.assert(lstResults.size() ==0);
  }
}