/**************************************************************************************************************
Modified By :       Nisha Agrawal
Modified Date :    Jan 26, 2015
Description :       Added code block to make it working with changes on Case owner assignment 
                                functionality.
*****************************************************************************************************************/
/*----------------------------------------------------------------------------------------------------------------------------------------------
Modified By :       Amrutha
Modified Date :    Aug 19, 2015
Description :      Added code block to make it working for new trigger CommunityQuestion_AfterInsert.
*************************************************************************************************************/
@isTest
private class ChatterAnswersEscalationTriggerTest
 {
	static testMethod void validateQuestionEscalation() 
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
		String questionTitle = 'questionTitle';
		String questionBody = 'questionBody';
		Community[] c = [SELECT Id from Community];
		// We cannot create a question without a community
		if (c.size() == 0) { return; }
		String communityId = c[0].Id;
		Question q = new Question();
		q.Title = questionTitle;
		q.Body = questionBody;
		q.CommunityId = communityId;
		insert(q);
		q.Priority = 'high';
		update(q);
		Case ca = [SELECT Origin, CommunityId, Subject, Description from Case where QuestionId =: q.Id];
		// Test that escaltion trigger correctly escalate the question to a case
		System.assertEquals(questionTitle, ca.Subject);
		System.assertEquals(questionBody, ca.Description);
		System.assertEquals('Chatter Answers', ca.Origin);
		System.assertEquals(communityId, ca.CommunityId);
	}
}