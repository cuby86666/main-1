/***************************************************************************************************
@Created By :      Ranganath C N
@Created Date:     23 May 2018
@Description:      SFDC-1749-Modify Distributor contact based on the new related object DistributorLeadTracker 
*******************************************************************************************************/
public class DistributorLeadTrackerclass
{

 public static void updatedistributorcontact (List<Distributor_Lead_Tracker__c > distleads)
    {
            system.debug('2'+'insert'+distleads);
            List<Lead> leads = new List<Lead>();
            Set<Id> s1 = new Set<Id>();
            Map<Id,String > mapOfleads = new Map<Id,String>();
        	Map<Id,String> additionalEmail = new Map<Id,String>();
            for(Distributor_Lead_Tracker__c objdist: distleads)
                {
                    if(objdist.Status__c =='Assigned')
                        {
                            mapOfleads.put(objdist.Lead_Id__c,objdist.Distributor_Contact__c);
                            additionalEmail.put(objdist.Lead_Id__c,objdist.Additional_Email__c);
                            s1.add(objdist.Lead_Id__c);
                        }
                 }
            leads=[select id,Distributor_Contact__c  from lead where id =: s1];
            system.debug('3'+'insert'+leads);
            List<Lead> leadUpdateList = new List<Lead>();
            for(Lead updatelead: leads)
                {
                    system.debug('3'+'insert'+updatelead.Distributor_Contact__c);
                    String maplead = mapOfleads.get(updatelead.Id);
                    updatelead.Distributor_Contact__c = maplead;
                    updatelead.Original_Assignee__c = null;
                    updatelead.Previous_Assignee__c = null;
                    if(additionalEmail.get(updatelead.Id)!=null && additionalEmail.get(updatelead.Id).trim().length()>0)
                    	updatelead.CC_Address__c=additionalEmail.get(updatelead.Id);
                    system.debug('4'+'insert'+updatelead.Distributor_Contact__c);
                    leadUpdateList.add(updatelead);
                }  
                
              update leadUpdateList;  
                                 
                
    } 
}