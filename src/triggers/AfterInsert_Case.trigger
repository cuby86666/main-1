/*
@Created By :       Syed Jameel
@Created Date:      07 Nov 2012
@Description:       Trigger to set Auto Notification Rules to for Contact When Record types is 'Tech_Support' or 'TS_Webmaster'                 
*/
/*********************************************************************************************
@Modified By :      Prakhar Gupta
@Modified Date :    15 Dec 2014
@Description :      Trigger to set Auto Notification Rules for Contact When Record type is 'TS_Community' and 
                    It will assign the Case Owner and Account to Case 
********************************************************************************************/
/***************************************************************************************************
@Modified By :      Shridevi Badiger
@Modified Date:     28 Jun 2017
@Description:       SIR-518-Remove the usage of tech support record type to disable it
**********************************************************************************************************/
trigger AfterInsert_Case on Case (after insert) 
{                                                                         
    
    /********************************************************************************************************
    NOTE : NOT SURE WHO HAS WRITTEN THIS CODE ANDWHAT'S THE BUSINESS REQUIREMENT
    NEED TO BE TAKEN CARE DURING CODE CLEANUP
    *********************************************************************************************************/
  //commented below line and removed its usage in the query as part of SIR 518.
    //Private final String CASE_TECHSUPPORT = 'Tech_Support';
    Private final String CASE_TSWEBMASTER = 'TS_Webmaster';
    Private final String CASE_TSCOMMUNITY = 'TS_Community';
    Public List<Case> listDeleteCase=new List<case>();
    
    //---------------------Merged 7S Code----------------
    MappingCaseRouting objMCR = new MappingCaseRouting();
    objMCR.onAfterInsert(Trigger.new);
    //---------------------------------------------------
   
    //Get the record type
    Private List<RecordType> lstRecordTypes = [Select Id, DeveloperName 
                                              From RecordType Where SobjectType = 'Case' and 
                                              (
                                              DeveloperName =: CASE_TSWEBMASTER 
                                              or DeveloperName=: CASE_TSCOMMUNITY) and IsActive=true
                                              Limit 2];
    
    Private List<Case> lstCases = new List<Case>();
    Private Set<Id> caseRecordTypeSet = new Set<Id>();    
   
    if(lstRecordTypes.size() > 0)
    {
        for(RecordType rt : lstRecordTypes)
        {
            caseRecordTypeSet.add(rt.Id);
        }        
        for(Case objCase : Trigger.New)
        {
            if(caseRecordTypeSet.contains(objCase.RecordTypeId))
            {
                Case objCse = new Case(Id = objCase.Id);
                lstCases.add(objCse);
            }              
        }
        
        if(lstCases.size() > 0)
        {
           Database.DMLOptions dmlOptions = new Database.DMLOptions();           
           dmlOptions.EmailHeader.triggerAutoResponseEmail = true;           
           for(Case objCase : lstCases)
           {
                objCase.setOptions(dmlOptions);
           }
            
             update lstCases;
        }
    }
    //Added by vinanthi to remove UnknownContact cases
    for(Case objCase : Trigger.New)
        {
        if(objCase.origin=='UnknownContact')
        listDeleteCase.add(objCase);
       
        }
    if(listDeleteCase.size()>0)
    {
    CaseTrigger.DeleteCases();
   }
}