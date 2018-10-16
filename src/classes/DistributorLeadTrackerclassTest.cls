/***************************************************************************************************
@Created By :      Ranganath C N
@Created Date:     24 May 2018
@Description:      SFDC-1749-Modify Distributor contact based on the new related object DistributorLeadTracker 
*******************************************************************************************************/
@isTest
private class DistributorLeadTrackerclassTest{
public static testMethod void BeforeinsertDistributorLeadTrackerclassTest()
{
        Account acc = new Account(Name='test Account');
        insert acc;

        Contact cont = new Contact(FirstName='Julian',LastName='Rogers',Accountid= acc.id,Email='ranganath.cn@nxp.com');
        insert cont;
        
        List<Lead> lstLead =   new List<Lead>{
                          new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open',Email='ranganath.cn@nxp.com',
                                      Distributor_Contact__c= cont.Id),
                          new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open',Email='ranganath1.cn@nxp.com',
                                      Distributor_Contact__c= cont.Id)
                          };  
        insert lstLead;
        
        List<Distributor_Lead_Tracker__c> distileadtracker = new List<Distributor_Lead_Tracker__c>{
                             new Distributor_Lead_Tracker__c(Lead_Id__c=lstLead[0].Id,Distributor_Contact__c=cont.Id,Status__c='Assigned'),
                             new Distributor_Lead_Tracker__c(Lead_Id__c=lstLead[0].Id,Distributor_Contact__c=cont.Id,Status__c='Expired')
                            };
        insert distileadtracker; 
        
        distileadtracker[1].Status__c='Assigned';
        distileadtracker[1].Lead_Id__c=lstLead[1].Id;
        update distileadtracker;
        
        
        
  
}
}