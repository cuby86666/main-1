/***************************************************************************************************
@Created By :      Avichal Kumar
@Created Date:     28 jun 2016
@Description:      Atfer update trigger on case to update related entitlement
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :      Shridevi Badiger
@Modified Date:     28 Jun 2017
@Description:       SIR-518-Remove the usage of tech support record type to disable it
**********************************************************************************************************/
trigger UpdateEntitlement on Case (after update)
{
    List<Case> lstCases= new List<Case>();
    List<Case> lstoldCases= new List<Case>();
    RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
    //commented the below code as part of SIR 518 
   // RecordType techRecordType=[Select Id,name from recordtype where name='Tech Support' LIMIT 1];
    for (Case objCase: trigger.new) 
    {
         if(objCase.Hours_spent_by_Support_person__c != null && objCase.EntitlementId != null )
         {
             lstCases.add(objCase);
         }
    }
    
    for (Case objoldCase: trigger.old) 
    {
         if(objoldCase.EntitlementId != null)
         {
             lstoldCases.add(objoldCase);
         }
    }
    //Method to populate the Product Values based on the Product Type Number to Case
    CommunityEntitlementController.EntitlementUpdate(lstoldCases,lstCases);
}