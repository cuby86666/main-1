@istest
public class CaseEscalationEmailHandlerTest {
    
   static testMethod void TestinBoundEmail()
   
   {
       Case objCase = new Case();
       objCase= new Case(Status= 'New',Subject='Test Case',Description='Test case description'); 
       Insert objCase;   
       List<Case> cases = [select id,casenumber from case ];
       String casenumber=cases.get(0).casenumber;   
       String caseId = cases.get(0).id;
       Messaging.InboundEmail caseEscalationEmail = new Messaging.InboundEmail() ;
       Messaging.Inboundenvelope envelope = new Messaging.Inboundenvelope();
     
       caseEscalationEmail.plainTextBody = 'Case Got escalated';
       caseEscalationEmail.subject = casenumber;
      
       CaseEscalationEmailHandler  testInbound=new CaseEscalationEmailHandler ();
       testInbound.handleInboundEmail(caseEscalationEmail , envelope);
       
       List<FeedItem> caseFeedItems = [SELECT ID, Body from FeedItem where ParentId= :caseId];
       String feedBody = caseFeedItems.get(0).Body;
       System.debug('caseFeedItems --'+feedBody);
       System.assert(feedBody=='Case Escalated :Case Got escalated');
       
   }
}