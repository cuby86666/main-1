/**************************************************************************************
@Created By :    Nisha Agrawal
@Created Date:   Sep 18, 2018
@Description:    Class for server side controller for lightning component ForwardToDisti component
******************************************************************************************/

public class ForwardLeadToDistiController
{
    @AuraEnabled 
    public static void forwardLeadWithinDisti(Id leadId, Id contactId)
    {
        if(leadId != null && contactId != null)
        {
			//assign it to Distributor Contact and shift the previous values to Previous Assignee Fields
			List<Lead> lstLeads = [Select Id, Distributor_Contact__c, Previous_Assignee__c, Original_Assignee__c From Lead
                              		Where Id =: leadId Limit 1];
			Lead objLead;
            if(lstLeads.size() > 0)
            {
                objLead = lstLeads[0];
                objLead.Previous_Assignee__c = objLead.Distributor_Contact__c;
                if(objLead.Original_Assignee__c == null)
                {
                    objLead.Original_Assignee__c = objLead.Distributor_Contact__c;
                }
                objLead.Distributor_Contact__c = contactId;
                
                try
                {
                    update objLead;
                }
                catch(Exception ex)
                {
                    throw new AuraHandledException('Some error occured while forwarding the lead : ' + ex.getMessage());
                }                
            }
        }
    }
}