/***************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      10 Apr 2013
@Description:       1. Trigger to Copy Parent Account's Manager to Account Manager Prechild field
					2. Trigger to Copy D&B data to account fields when D&B data Accepted
*******************************************************************************************************/

trigger BeforeTrigger_Account on Account (before insert, before update) 
{
    final static String CHILD_ACCOUNT = 'Child_Account';
    final static String PRECHILD_ACCOUNT = 'Pre_Account';
    
    RecordType childAccount;
    RecordType preChildAccount;
    
    //get the record type
    for(RecordType rt : [Select Id, DeveloperName
                           From RecordType
                           Where SobjectType = 'Account' and ( DeveloperName =: CHILD_ACCOUNT or DeveloperName =: PRECHILD_ACCOUNT ) and IsActive=true
                           Limit 2])
    {
        if(rt.DeveloperName == CHILD_ACCOUNT)
        {
            childAccount = rt;
        }
        else if(rt.DeveloperName == PRECHILD_ACCOUNT)
        {
            preChildAccount = rt;
        }
    }
    
    Set<Id> parentAccountIds = new Set<Id>();
    
    if(Trigger.isInsert)
    {
        for(Account acc : Trigger.New)
        {
            if(acc.RecordTypeId == preChildAccount.Id)         //check if record type is Pre Child
            {
                //add the parent account id to set
                parentAccountIds.add(acc.ParentId);
            }
        }
        
    }
    else if(Trigger.isUpdate)
    {
        for(Account acc : Trigger.New)
        {
            //if record type is "Child" 
            if(acc.RecordTypeId == childAccount.Id && acc.Status_of_D_B_Cleansing__c == 'D&B Data Accepted') //check the status of D&B Cleansing field
            {
                acc.Name  = acc.D_B_Account_Name__c;
                acc.Street__c = acc.D_B_Street__c;
                acc.State_Province__c = acc.D_B_State_Province__c;
                acc.City__c = acc.D_B_City__c;
                acc.Country__c = acc.D_B_Country__c;
                acc.ZIP_Postal_Code__c = acc.D_B_ZIP_Postal_Code__c;
                acc.Sic = acc.D_B_SIC_Code__c;
                acc.SicDesc = acc.D_B_SIC_Code_Description__c;
                acc.NAICS__c = acc.D_B_NAICS_Code__c;
                acc.DUNS_Number__c = acc.D_B_Number__c;  
                acc.NAICS_Description__c=acc.D_B_NAICS_code_Description__c;             
            }
            else if(acc.RecordTypeId == preChildAccount.Id)         //check if record type is Pre Child
            {
                //add the parent account id to set
                parentAccountIds.add(acc.ParentId);
            }
        }
    }
    
    if(parentAccountIds.size() > 0)
    {
        //fetch parent account's manager for all the parent accounts
        Map<Id, Account> mapAccountToManagers = new Map<Id, Account>();
        
        for(Account parentAcc : [Select Id , Account_Manager__c, Segment_Approval__c From Account
                                Where Id IN : parentAccountIds] )
        {
            mapAccountToManagers.put(parentAcc.Id , parentAcc);
        }
        
        //update  Account Manager Prechild with Parent Account's Manager
        for(Account acc : Trigger.New)
        {
            //check if record type is Pre Child
            if(acc.RecordTypeId == preChildAccount.Id)          
            {
                acc.Account_Manager_prechild__c = mapAccountToManagers.get(acc.ParentId).Account_Manager__c;
            }
        }
    }

}