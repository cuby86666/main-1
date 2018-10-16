/***************************************************************************************************
@Created By :      Ranganath C N
@Created Date:     22 May 2018
@Description:      SFDC-1749-Modify Distributor contact based on the new related object DistributorLeadTracker 
*******************************************************************************************************/
trigger DistributorLeadTracker on Distributor_Lead_Tracker__c(before insert,before update,before delete,after insert,after update) {
    if(Trigger.isDelete){
        for(Distributor_Lead_Tracker__c dlt : Trigger.old ){
            if(dlt.Status__c != 'Queued'){
                Trigger.oldMap.get(dlt.id).addError('Only queued entries are allowed to be deleted');
            }
        }
    }    
    if(Trigger.isBefore && (!Trigger.isDelete)){
        for(Distributor_Lead_Tracker__c leadtrack : Trigger.new)
        {
            if(leadtrack.Status__c=='Assigned'){
                leadtrack.Assigned_Date__c=System.now();    
            }
        }        
    } 
    if(Trigger.isAfter && (!Trigger.isDelete)){
            if(Trigger.IsInsert)
                {
           
                   DistributorLeadTrackerclass.updatedistributorcontact(trigger.new);
 
                   system.debug('1'+'insert');
                }
                                 
           else{
                    List<Distributor_Lead_Tracker__c > distleadtracker = new List<Distributor_Lead_Tracker__c  >();
                    for(Distributor_Lead_Tracker__c leadtrack : Trigger.new)
                    {
                        if(leadtrack.Status__c != Trigger.oldMap.get(leadtrack.Id).Status__c && leadtrack.Status__c=='Assigned')
                            {
                            distleadtracker.add(leadtrack); 
                            }
                    }
                    if(!distleadtracker.isEmpty())
                    {
                        DistributorLeadTrackerclass.updatedistributorcontact(distleadtracker);
                    }
              }        
    }

}