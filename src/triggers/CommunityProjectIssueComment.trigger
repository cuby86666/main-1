trigger CommunityProjectIssueComment on Project_Issue_Comment__c (after insert) {
 
 Set<String> setUserEmail= new Set<String>();
 List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
 for (Project_Issue_Comment__c objProjIssueCmt : Trigger.new)
    {
    	Project_issue__c objProjIss=[ Select id,ownerId,name,createdbyId,project_name__c,title__c,description__c from project_issue__c where id=:objProjIssueCmt.Project_Issue__c LIMIT 1];
    	List<User> lstUser= [Select id, email,name from user where id=:objProjIss.ownerId limit 1];
    	List<User> lstUserCreator= [Select id, email,name from user where id=:objProjIss.CreatedById limit 1];
        setUserEmail.add(lstUser[0].Email);
    	setUserEmail.add(lstUserCreator[0].email);
 	if(setUserEmail.size()!=0)
 	{
     for(String strEmail :setUserEmail) 
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    		String[] strSendTo =new String[]{strEmail};
    		system.debug('sendTo'+strSendTo );
   		    mail.setToAddresses(strSendTo);
    		mail.setReplyTo('engineers.corner@nxp.com');
    		mail.setSubject( 'Project Issue: '+objProjIss.name+' : '+objProjIss.Title__c+' :COMMENT' );
    		mail.setPlainTextBody('Hello,\n\n'
                                +'For your information. A comment has been added to the following Project Issue:\n\n'
								+'*** Project Issue Summary \n\n'
                                +'Issue Number: '+objProjIss.name+'\n'
                          		+'Project Name: '+objProjIss.project_name__c+'\n'
                          		+'Subject: ' +objProjIss.title__c+'\n'
                          		+'Description: '+objProjIss.Description__c+'\n'
                          		+'Comment: '+objProjIssueCmt.Comment__c+'\n\n'
                                + 'Best regards,\n'
                                + 'NXP Project Support team'
                             );
    		mails.add(mail);
        }
   
    
    }
         Messaging.sendEmail(mails);
}
    
}