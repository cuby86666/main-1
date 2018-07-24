global class CaseEscalationEmailHandler implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail caseEscalationEmail, 
                                                         Messaging.Inboundenvelope envelope) {
            String caseNumber = caseEscalationEmail.Subject;
            System.debug(' caseNumber '+caseNumber);                                                  
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();                                                 
            List<Case> cases = [select id from case where casenumber=:caseNumber];
            System.debug(' cases '+cases);                                                 
            if(cases !=null && (!cases.isEmpty())){
               Case c = cases.get(0); 
                FeedItem post = new FeedItem();
                post.ParentId = c.id;
                post.Body = 'Case Escalated :' +caseEscalationEmail.plainTextBody;
                insert post;
            } 
            result.success=true;
            return result;                                                           
  }
  }