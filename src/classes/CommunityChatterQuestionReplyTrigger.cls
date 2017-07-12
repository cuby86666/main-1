/***************************************************************************************************
@Created By :      Amrutha R
@Created Date:     27 May 2015
@Description:      Class for all the methods for triggers on question and reply
*******************************************************************************************************/

public class CommunityChatterQuestionReplyTrigger 
{
    public static String emailVerficationLink;
    
    //method used in trigger- before insert question and reply.
    //To replace abuse word with * in tilte and body field of question and reply. 
    public static String splitAndConcatenate(String strBody, String strFilter)
    {
        List<String> words = new List<String>();
        words= strBody.split('\\s+');
        strBody=' ';
        for (integer i = 0; i < words.size(); i++) 
        {
           if(words[i].equalsIgnoreCase(strFilter)|| words[i].containsIgnoreCase(strFilter))
           {
               words[i]= words[i].replace(words[i], '*');  
           }
          strBody=strBody+' '+words[i];
        }
        return strBody;
    }
    
    //Method to send email if abuse words are found while posting question and reply. 
    //Email is sent to users having community_moderator permission set assigned
    public Static void sendEmailToModerators(String strTitle,String strBody,Id strId)
    {
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        emailVerficationLink= cs.EmailVerficationLink__c;
        List<String> lstUserEmail= new List<String>();
        List<String> lstPermSetEmail= new List<String>();
        List<PermissionSetAssignment> lstPermSet= new List<PermissionSetAssignment>();
        lstPermSet= [Select Assignee.email,Assignee.id, PermissionSet.Name From PermissionSetAssignment Where permissionset.name='Community_Moderator'];
        for(PermissionSetAssignment objPermSet: lstPermSet)
        {
            if(objPermSet.Assignee.email!=null)
            {
                lstPermSetEmail.add(objPermSet.Assignee.email);
            }
        } 
        List<User> lstUser= [Select Id,email,IsActive from User Where email IN:lstPermSetEmail and IsActive=true LIMIT 1];
        if(lstUser.size()>0)
        {
            lstUserEmail.add(lstUser[0].email);
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(strId!=null)
        {
        for(String strEmail :lstUserEmail) 
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {strEmail};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('NXP Technical Support');
            mail.setSubject( 'NXP Community - Abuse Filter' );
            mail.setPlainTextBody('Dear Moderators,\n\n'
                                +'Someone has posted a question/answer which contained abusive words to the community discussion. \n'
                                +'\nOriginal Post: \nTitle: ' +strTitle+ '\n'
                                + strBody
                                +'\n\n'
                                + emailVerficationLink
                                + '/CommunitiesHomePage#!/feedtype=SINGLE_QUESTION_DETAIL&dc=All&criteria=ALLQUESTIONS&id='+strId
                                +'\n\nPlease review and moderate. Thank you.'
                                +'\n\nBest Regards,\n'
                                +'NXP Community'
                                );
            mails.add(mail);
        }
        }
        else if(strId==null)
        {
        for(String strEmail :lstUserEmail) 
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {strEmail};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('NXP Technical Support');
            mail.setSubject( 'NXP Community - Abuse Filter' );
            mail.setPlainTextBody('Dear Moderators,\n\n'
                                +'Someone has posted a question/answer which contained abusive words to the community discussion. \n'
                                +'\nOriginal Post: \nTitle: ' +strTitle+ '\n'
                                + strBody
                                +'\n\n'
                                + emailVerficationLink
                                + '/CommunitiesHomePage#!/feedtype=RECENT&dc=All&criteria=ALLQUESTIONS'
                                +'\n\nPlease review and moderate. Thank you.'
                                +'\n\nBest Regards,\n'
                                +'NXP Community'
                                );
            mails.add(mail);
        }
        }
        Messaging.sendEmail(mails);
        
    }   
}