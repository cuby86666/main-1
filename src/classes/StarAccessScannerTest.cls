/***************************************************************************************
 Last ModifiedBy : Baji
 Last ModifiedDate : 02 Jun 2017
 Description : Updated to remove the test data related to Opportunity Approval Setting.
----------------------------------------------------------------------------------------
@Modified By:    Nisha Agrawal
@Modified Date:    Sep 07, 2017
@Description:    Rewrite whole class to remove extra code, invoke methods from util class
          and improve code coverage and qulaity of test class with assert statements
****************************************************************************************/ 

@isTest
public class StarAccessScannerTest 
{
    static testMethod void StarAccessScannerTest1() 
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
        Id sfdcOpptyRecordTypeId = OpportunitiesSelector.getSfdcRecordTypeID();
        Date closeDate = Date.valueOf('2020-06-22');
        List<Opportunity> lstOpportunities = new List<Opportunity>();
                
        for(integer i =0; i < 200; i++)
        {
            Opportunity objOpp = new Opportunity(Name = 'test Opp' + i , AccountId = childAccount.Id, StageName = 'Initial Analysis', 
                                                 CloseDate = closeDate, RecordTypeId = sfdcOpptyRecordTypeId);
            lstOpportunities.add(objOpp );
        }
    
        insert lstOpportunities;
        
        //fetch public group
        List<Group> lstGroups = [Select Id, DeveloperName From Group Where DeveloperName = 'GKAM_STAR' Limit 1];
        system.assert(lstGroups.size() == 1);
        Id groupId = lstGroups[0].Id;
        
        List<OpportunityShare> lstShares = new List<OpportunityShare>();
                
        for(Opportunity obj : lstOpportunities)
        {
            system.assert(obj.Id != null);
            
            OpportunityShare objShare = new OpportunityShare(OpportunityId = obj.Id, UserOrGroupId= groupId, OpportunityAccessLevel= 'Edit');
            lstShares.add(objShare);
        }
                
        insert lstShares;
        for(OpportunityShare obj : lstShares)
        {
            system.assert(obj.Id != null);
        }
        
        //start the test
        Test.startTest();
        Database.executeBatch(new StarAccessScanner(), 1000);
        Test.stopTest();
        
        //assert the results
        List<Star_Access__c> lstResults = [Select Id , Name From Star_Access__c ];
        system.assert(lstResults.size() > 0);
    }
}