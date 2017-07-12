/*
@Created By :       Syed Jameel
@Created Date:      07 Nov 2012
@Description:       Test Class for AfterInsert_Case trigger
*/
/*********************************************************************************************
@Modified By :       Prakhar Gupta
@Modified Date :    15 Dec 2014
Description :       Trigger to set Auto Notification Rules to for Contact When Record types is 'TS_Community'
********************************************************************************************/
@isTest
private class AfterInsert_CaseTest 
{

    //commented the below line as part of SIR 518-Discable Tech Support record Type
    //final static String CASE_TECHSUPPORT = 'Tech_Support';
    final static String CASE_TSWEBMASTER = 'TS_Webmaster';
    final static String CASE_TSCOMMUNITY = 'TS_Community';
    
    private final static String CHILD_ACCOUNT = 'Child_Account';
    private final static String PARENT_ACCOUNT = 'Parent_Account';    
    
    private Static RecordType objAccountChild;
    private static RecordType objAccountParent;
    
     private static void fetchRecordType()
    {        
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType Where IsActive=true and  
                              ((SobjectType = 'Account' and (DeveloperName =: Child_Account or 
                                                             DeveloperName =: Parent_Account))                              
                              ) Limit 2])
         if(rt.DeveloperName == CHILD_ACCOUNT)
        {
            objAccountChild = rt; 
        }
        else if(rt.DeveloperName == PARENT_ACCOUNT)
        {
            objAccountParent = rt;
        }   
        
    } 
    
    static testMethod void AfterInsert_CaseTest1() 
    {
        //prepare test data
        
        fetchRecordType();
        
        Account objNXPAccount = new Account(RecordTypeID= objAccountParent.ID,
                                                Name = 'NXP Community', Customer_Category__c= 'Longtail');
        insert objNXPAccount;
        System.assert(objNXPAccount.Id != null);
        
        Account objOtherAccount = new Account(RecordTypeID= objAccountParent.ID,
                                                Name = 'Other', Customer_Category__c= 'Longtail');
        insert objOtherAccount;
        System.assert(objOtherAccount.Id != null);
        
        Account objTechServicesAccount = new Account(RecordTypeID= objAccountChild.ID,ParentId = objOtherAccount.Id,  
                                            Name = 'Technical Services', Region__c = 'Japan',
                                             Sales_Area__c = 'Japan ID', Industry_Segment__c = 'Mobile',
                                             Country__c = 'Austria');
        insert objTechServicesAccount;
        System.assert(objTechServicesAccount.Id != null);
             
        Account objAccount = new Account(Name = 'unittest_account');
        insert objAccount;
        system.assert(objAccount.Id != null);
        
        Contact objContact = new Contact(LastName = 'test', AccountId = objAccount.Id , Email = 'test.contact@test.com');
        insert objContact;
        system.assert(objContact.Id != null); 
        
        //get the record type
        List<RecordType> lstRecordTypes = [Select Id, DeveloperName 
                                           From RecordType
                                           Where SobjectType = 'Case' and ( DeveloperName =: CASE_TSWEBMASTER  or DeveloperName =: CASE_TSCOMMUNITY) 
                                           and IsActive=true
                                           Limit 2];
        
        system.debug('lstRecordTypes>>'+lstRecordTypes);
        
        List<Case> lstCases = new List<Case>();
                                       
        //start the test        
        Test.startTest();        
        if(lstRecordTypes.size() > 0)
        {
            //lstCases.add(new Case(Subject='test 1', RecordTypeId = lstRecordTypes[0].Id , ContactId = objContact.Id));
            lstCases.add(new Case(Subject='test 2', RecordTypeId = lstRecordTypes[0].Id , ContactId = objContact.Id)); 
            lstCases.add(new Case(Subject='test 3', RecordTypeId = lstRecordTypes[1].Id , ContactId = objContact.Id)); 
        }       
        insert lstCases;
        
        //stop the test
        Test.stopTest();
    }
}