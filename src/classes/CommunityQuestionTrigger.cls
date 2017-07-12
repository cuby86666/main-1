/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     25 Sep 2015
Description :      Class for question triggers
************************************************************************************************************/

public class CommunityQuestionTrigger 
{
     //method to send email to public group- after insert question
     public void sendMailToGroup(Question objQues) 
     {
        List<String> lstUserEmail= new List<String>();
        lstUserEmail=  getEmailAddresses(objQues);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        CommunitySettings__c cs=  CommunitySettings__c.getValues('CommunityUrl');
        String emailVerficationLink= cs.EmailVerficationLink__c;
         
        for(String strEmail :lstUserEmail) 
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {strEmail};
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('NXP Technical Support');
            mail.setSubject( 'NXP Community - Question Posted' );
            mail.setPlainTextBody('Dear User,\n\n'
                                + userinfo.getName() + ' has posted a question to Community Forum. \n'
                                + '\nQuestion Details: '
                                +'\n\nTitle: '+objQues.Title+ '\n' 
                                +'Body: '+objQues.Body+ '\n'
                                +'Category: '+objQues.Product_Category__c+ '\n'
                                +'Sub Category: '+objQues.Product_Sub_Category__c+ '\n'
                                +'\n'
                                + emailVerficationLink
                                + '/CommunityQuestionView?id='+objQues.id
                                +'\n\nPlease check. Thank you.'
                                +'\n\nBest Regards,\n'
                                +'NXP Community'
                                );
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
         
     }
    
    //method to fetch email address of users in public group- public group is fetched based on category of the question posted
    private List<String> getEmailAddresses(Question objQues) 
    {
        Set<Id> setUserId = new Set<Id>();
        List<String> mailToAddresses = new List<String>();
        List<Group> lstGroup = [SELECT (select userOrGroupId from groupMembers),name FROM group WHERE name like 'Community%'];
        for(Group objGroup: lstGroup)
        {
            if((objQues.Product_Category__c!= '' || objQues.Product_Category__c!='Select Category') && 
               (objQues.Product_Sub_Category__c=='Select Sub Category' || objQues.Product_Sub_Category__c=='--None--'))
            {
                //Public group name is same as category name which is prefixed by Community
                if(objGroup.Name.substringafter('Community ').equalsIgnoreCase(objQues.Product_Category__c))
                {
                    setUserId=(GetUserIdsFromGroup(objGroup.Id));
                    List <user> lstUser = [SELECT email FROM user WHERE id IN :setUserId];
                    for(User objUser : lstUser) 
                    {
                        mailToAddresses.add(objUser.email);
                    }
                }
            }
            else if((objQues.Product_Category__c!= '' || objQues.Product_Category__c!='Select Category') && 
                    (objQues.Product_Sub_Category__c!='Select Sub Category' || objQues.Product_Sub_Category__c!='--None--'))
            {
                if(objQues.Product_Sub_Category__c=='General' || objQues.Product_Sub_Category__c=='Diodes')
                {
                    String strCategory= objQues.Product_Category__c +' '+ objQues.Product_Sub_Category__c;
                    //Public group name is same as category + sub category name which is prefixed by Community
                    if(objGroup.Name.substringafter('Community ').equalsIgnoreCase(strCategory))
                    {
                        setUserId=(GetUserIdsFromGroup(objGroup.Id));
                        List <user> lstUser = [SELECT email FROM user WHERE id IN :setUserId];
                        for(User objUser : lstUser) 
                        {
                            mailToAddresses.add(objUser.email);
                        }
                    } 
                }  
                else if((objGroup.Name=='Community Security and Surveillance IP C' && objQues.Product_Sub_Category__c=='Security and Surveillance IP Camera')||
                            (objGroup.Name=='Community ESD, EMI and Signal Conditioni' && objQues.Product_Sub_Category__c=='ESD, EMI and Signal Conditioning'))
                {
                    setUserId=(GetUserIdsFromGroup(objGroup.Id));
                    List <user> lstUser = [SELECT email FROM user WHERE id IN :setUserId];
                    for(User objUser : lstUser) 
                    {
                        mailToAddresses.add(objUser.email);
                    }
                }
                else
                {
                    //Public group name is same as sub category name which is prefixed by Community
                    if(objGroup.Name.substringafter('Community ').equalsIgnoreCase(objQues.Product_Sub_Category__c))
                    {
                        setUserId=(GetUserIdsFromGroup(objGroup.Id));
                        List <user> lstUser = [SELECT email FROM user WHERE id IN :setUserId];
                        for(User objUser : lstUser) 
                        {
                            mailToAddresses.add(objUser.email);
                        }
                    }
                }
            }
        }
        
        return mailToAddresses;
    }  
    
    //method to check and fetch user ids from public group
    public Static Set<id> GetUserIdsFromGroup(Id groupId)
    {
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
                
        for (GroupMember objGrpMem : [Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId])
        {   
            // If the user or group id is a user
            if (((String)objGrpMem.UserOrGroupId).startsWith(userType))
            {
                result.add(objGrpMem.UserOrGroupId);
            }
            // If the user or group id is a group
            else if (((String)objGrpMem.UserOrGroupId).startsWith(groupType))
            {
                result.addAll(GetUSerIdsFromGroup(objGrpMem.UserOrGroupId));
            }
        }
         
        return result; 
    }
}