/*************************************************************************************************************
Name            :     TestUpdateIdeas
Date            :     11 May, 2011
Author          :
Description     :     This test class covers code for UpdateIdeas Trigger.
----------------------------------------------------------------------------------------------------------------------------------------------
Modified By :       Nisha Agrawal
Modified Date :    Jan 26, 2015
Description :      Added code block to make it working with changes on Case owner assignment 
                                functionality.
----------------------------------------------------------------------------------------------------------------------------------------------
Modified By :       Amrutha
Modified Date :    Aug 19, 2015
Description :      Added code block to make it working for new trigger CommunityQuestion_AfterInsert.
*************************************************************************************************************/

@isTest
private class TestUpdateIdeas {
    
    static testMethod void testTrigger()
    {
        /**********Added by Nisha Agrawal on Jan 26 2015 *******/
        Account objAccount =  new Account(Name = 'Technical Services');
        insert objAccount;
        
        system.assert(objAccount.Id !=null);
        /**********Ends here ***************************************/
        
        /**********Added by Amrutha on Aug 19 2015 *******/
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        /**********Ends here ***************************************/
        
        //Query for Community Id
        List<Community> communities = [Select Id From Community limit 1];
        
        //Inserts Idea
        Idea ida = new Idea();
        ida.Title = 'test12341';
        if(!communities.isEmpty())
            ida.CommunityId = communities.get(0).Id;
            
        ida.Feedback_from_Support__c = 'TestFeedback';
        insert ida;
        
        //Fetching Record Type Sales CRM
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE isactive =true and Name = 'Sales CRM'];
        
        //Inserts new Case
        Case cas = new Case();
        cas.Status = 'Ideas - Approved';
        cas.Origin = 'Email';
        cas.Priority = 'Medium';
        cas.Type = 'Ideas';
        cas.suppliedEmail='test@test.com';
        cas.Related_Idea__c = ida.Id;
        cas.Assigned_to__c= userinfo.getUserId();
        if(recordTypes.size()> 0){
            cas.RecordTypeId = recordTypes.get(0).Id;
        }
        
        insert cas;
        
        //Inserts New Solution
        Solution sol = new Solution();
        sol.IsPublished = true;
        sol.SolutionName = 'Test';
        sol.SolutionNote = 'Testing Solution Note';
        insert sol;
        
        //Inserts New CaseSolution
        CaseSolution cs = new CaseSolution(CaseId = cas.Id, SolutionId = sol.Id);
        insert cs;
        
        //Update Solution
        List<Case> caseList = [SELECT id, Subject, Type, Origin, Status, RecordTypeId, Assigned_to__c FROM Case WHERE id =: cas.id];
        if(caseList.size() > 0){
            Case c = caseList[0];
            c.Description = 'Test case1234';
            c.Assigned_to__c = UserInfo.getUserId();
            update c;
        }
        
        
        
        //Checks trigger worked or not?
        ida = [select id, Feedback_from_Support__c from idea where id =: ida.Id];
        //system.assert(ida.Feedback_from_Support__c == 'Testing Solution Note' ,'Invalid Trigger or Test Class!');
    }
}