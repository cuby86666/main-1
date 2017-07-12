@isTest
public class TestChatterAnswersController{
    
    private static testMethod void TestChatterAnswersController(){
        PageReference pageRef = new PageReference('http://nxpsemiconductors.develop17.cs8.force.com/TestSite');
        Test.setCurrentPage(pageRef);
        Account acc= new Account();
        acc.Name = 'Testing';
        insert acc;
        Profile p = [select id from Profile where name = 'System Administrator' limit 1];
        User u = [select id from User where Profile.Id =: p.id and isActive = true Limit 1];
		System.runAs(u){	
        chatterAnswersController chAns = new chatterAnswersController();
		chAns.cAnsAct  = [select ca.BestAnswerReceivedCount, ca.QuestionUpVotesReceivedCount, ca.UserId
							from chatterAnswersActivity ca
							where UserId IN (select Id from User where AccountID != '')
							and (BestAnswerReceivedCount > 0 or QuestionUpVotesReceivedCount > 0)
							order by ca.BestAnswerReceivedCount Desc
							LIMIT 5];
		chAns.calculateScores();
		chAns.calculateFinalScores();
		string getTb = chAns.getTb();
		//insert ca;	
        
		}
    }
}