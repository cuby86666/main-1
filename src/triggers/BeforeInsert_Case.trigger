/***************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:    
@Description:      trigger for Before Insert for Case object
-----------------------------------------------------------------------------------------------------------------------
@Modified By :      Prkahar Gupta
@Modified Date:   21 Dec 2014
@Description:       added method for case owner assignment based on other criterias
*******************************************************************************************************/
/******************************************************************************************************
@Modified By  :   Amrutha
@Modified Date:   19 Jan 2014
@Description  :  MERGED CODE FROM BEFOREINSERTCOMMUNITYCASETRIGGER
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :      Avichal Kumar
@Modified Date:     07 Apr 2016
@Description:       Cleanup of case assignment rules
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      Vinanthi
@Modified Date:      Aug 2016
@Description:       For SIR 1080. Grouped email origin cases.
**********************************************************************************************************/
/***************************************************************************************************
@Modified By :      Shridevi Badiger
@Modified Date:     28 Jun 2017
@Description:       SIR-518-Remove the usage of tech support record type to disable it
**********************************************************************************************************/
trigger BeforeInsert_Case on Case (before insert) 
{
    List<Case> lstCases= new List<Case>();
    List<Case> lstCases1= new List<Case>();
    List<Case> lstCases2= new List<Case>();
    
    //------------Merged 7S code------------------------
     MappingCaseRouting objMCR = new MappingCaseRouting();
     objMCR.onBeforeInsert(Trigger.new);
    //--------------------------------------------------
    
    RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
    //commented below line as part of SIR 518
   // RecordType techRecordType=[Select Id,name from recordtype where name='Tech Support' LIMIT 1];
    for (Case objCase: trigger.new) 
    {
    
         if(objCase.Origin != null && objCase.EntitlementId == null && objCase.RecordTypeId==tsRecordType.Id )
         {
             lstCases.add(objCase);
         }
         if(objCase.Origin == 'Email' && objCase.RecordTypeId==tsRecordType.Id )
         {
             lstCases2.add(objCase);
         }
    }
     for (Case objCase: trigger.new) 
    {
         if(objCase.EntitlementId != null )
         {
             lstCases1.add(objCase);
         }
    }
    
    //Method to populate the Product Values based on the Product Type Number to Case
    CaseTrigger.populateProductValuesToCase(lstCases);
    //Method to asssign the Case Owner and Account to Case
    CaseTrigger.newProcessCasesToAssignOwnerAndAccount(trigger.new);
    //method to assign case owner based on related entitlement
    CaseTrigger.CasesOwnerAssignment(lstCases1);
    if(lstCases2.size()>0)
    {
     CaseTrigger.emailToCaseContactCheck(lstCases2);
    }
    
}