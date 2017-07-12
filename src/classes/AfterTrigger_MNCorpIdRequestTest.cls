/**************************************************************
@Created By :       Ghanalingamurthy Db
@Created Date:      26 Sep 2014
@Description:       Test Class for AfterTrigger_MNCorpIdRequestTest
***************************************************************/
@isTest
private class AfterTrigger_MNCorpIdRequestTest 
{
     private static final String TEST_USER_EMAIL = String.valueOf(Datetime.now().getTime()) + '@testorg.com';
     private static final String TEST_USER_NAME = TEST_USER_EMAIL + '@testorg.com.test';
     
    static testMethod void AfterTrigger_MNCorpIdRequestTest1() 
    {
        //prepare test data        
        //get profile
        List<Profile> lstProfiles = [Select Id, Name From Profile Where Name = 'System Administrator' Limit 1 ];
        if(lstProfiles.size() > 0)
        {
            Profile objProfile = lstProfiles[0];
            
            User objUser = new User(alias = 'UTest', email=TEST_USER_EMAIL, emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', username= TEST_USER_NAME);
                                 
            insert objUser;
            
            //assert the user
            system.assert(objUser.Id != null);
            
            //get the record type for Customer
            List<RecordType> lstRecordTypes = [Select Id, DeveloperName, SobjectType  
                                               From RecordType
                                               Where SobjectType = 'Customer__c' and DeveloperName = 'Global_Enterprise' and IsActive=true
                                               Limit 1];
            RecordType NXPUltimateParent;
            if(lstRecordTypes.size() > 0)
            {
                NXPUltimateParent = lstRecordTypes[0];
            }
            system.runAs(objUser)
            {
                Decimal corpOid=Decimal.valueOf('12345');
                MN_Corp_Id_Request__c objMNCorpIDRequest = new MN_Corp_Id_Request__c(Status__c='Created',Corp_Id__c='GM Test',MN_Corporate_Id_OID__c=corpOid);
                insert objMNCorpIDRequest;
                
                system.assert(objMNCorpIDRequest.Id != null);
                
                system.assert(NXPUltimateParent.Id != null);
                Customer__c objCustomer = new Customer__c(RecordTypeId=NXPUltimateParent.id,Legal_Name__c='A.B. MIKROELEKTRONIK GMBH',Account_Name__c='GM test',Status__c='Active',DNB_Verified__c='DNB Accepted',Street__c='test',City__c='Bangalore',Country__c='India',GSM_Classification__c='Focus',Role__c='OEM',Type__c='Customer',ZIP__c='test',Industry_Segment__c='test');
                insert objCustomer;
                
                system.assert(objCustomer.Id != null);
                //start the Test       
                Test.startTest();
                System.debug('status'+objMNCorpIDRequest.Status__c);
                objMNCorpIDRequest.Customer_GID__c = objCustomer.Id;
                objMNCorpIDRequest.Status__c = 'Completed';
                update objMNCorpIDRequest;
                
                /*
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(objMNCorpIDRequest.id);
                Approval.ProcessResult result = Approval.process(req1);
                System.assert(result.isSuccess());
                */
                
                
                //fetch the MN_Corp_Id_Request__c 
                List<MN_Corp_Id_Request__c> lstMNcorpRequest = [Select Id , Customer_GID__c
                                        From MN_Corp_Id_Request__c 
                                        Where OwnerId =: objUser.Id];
                //assert the results
                system.assert(lstMNcorpRequest.size() > 0);
                system.assert(objMNCorpIDRequest.Customer_GID__c == objCustomer.Id);
                
                //fetch the MN_Corp_ID__c 
                List<MN_Corp_ID__c> lstMNcorpIds = [Select Id,MN_Corporate_Id_OId__c,Name,Global_Customer__c
                                        From MN_Corp_ID__c 
                                        Where MN_Corporate_Id_OId__c=:objMNCorpIDRequest.MN_Corporate_Id_OID__c
                                        and Global_Customer__c=:objMNCorpIDRequest.Customer_GID__c];
                //assert the results
                system.assert(lstMNcorpIds.size() > 0);
                                
                //stop the test
                Test.stopTest();
            }           
        }
    }
}