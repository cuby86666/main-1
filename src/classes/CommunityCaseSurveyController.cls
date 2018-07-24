/*********************************************************************************************
@Created By :      Amrutha R
@Created Date :    27 Oct 2015
Description :      Community case survey controller where user can submit survey feedback after 
                   case has been closed.
****************************************************************************************************/

/***************************************************************************************************
@Modified By :       Amrutha
@Modified Date:      22 Apr 2016
@Description:        Added email to case owner based on survey feedback
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :       Vinanthi
@Modified Date:      29 Jul 2016
@Description:        Added updateSurvey  method to make survey as non-personal as part of SIR 924
*******************************************************************************************************/

public class CommunityCaseSurveyController 
{
    public List<SelectOption> lstQuesValues{get;set;}
    public String strCaseNumber{get;set;}
    public String strCaseSubject{get;set;}
    public String strResolved{get;set;}
    public String strResolutionTime{get;set;}
    public String strSupportPerson{get;set;}
    public String strLikeOurSupport{get;set;}
    public String strComment{get;set;}
    public List<case> lstCase{get;set;}
    public String RedirectionToLoginPage{get;set;}
    Survey_Answer__c objSurveyAns;
    
    public CommunityCaseSurveyController(ApexPages.StandardSetController stdController) {
    objSurveyAns=new Survey_Answer__c();
    objSurveyAns=(Survey_Answer__c)stdController.getRecord();
     }
    //Check if caseid in url null or not
    public CommunityCaseSurveyController()
    {
    //below line is added by shridevi for redirecting to login page instead of communityRegistration page since the page has been deleted.
        RedirectionToLoginPage=(Site.getPathPrefix()+Label.Community_Login_URL);
        if(ApexPages.currentPage().getParameters().get('caseId')==null || ApexPages.currentPage().getParameters().get('caseId')=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error in survey form'));
        }  
        else
        {
            lstCase= [Select id,casenumber,email__c,ownerid,assigned_to__r.id,Subject,Survey_Flag__c,assigned_to__c,
                      assigned_to__r.name,owner.name,owner.email,assigned_to__r.email
                      from case where id=:ApexPages.currentPage().getParameters().get('caseId') LIMIT 1]; 
            if(lstCase.size()!=0 || lstCase!=null)
            {
                strCaseNumber= lstcase[0].caseNumber;
                strCaseSubject= lstcase[0].Subject;       
            }
        }
         strResolved=' 4 Very Satisfied';
         strResolutionTime=' 4 Very Satisfied';
         strSupportPerson=' 4 Very Satisfied';
         strLikeOurSupport=string.valueof('10');
    }
    
    public String getLargePhotoUrl() 
    {
        Id userid = UserInfo.getUserId();
        return ConnectApi.ChatterUsers.getPhoto(
            Network.getNetworkId(), userId).largePhotoUrl;
    }
    
    //create picklist values based on question value field
    public List<SelectOption> getQuesValues()
    {
        lstQuesValues = new List<SelectOption>();
        List<Survey_question__c> objSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Resolved ?' LIMIT 1];
                                           
        Pattern nonAlphanumeric = Pattern.compile('[0-9]');
                                           
        if(objSurveyQues.size()!=0 || objSurveyQues!=null)
        {
            List<String> lstStrQuesValue= objSurveyQues[0].value__c.split(',');
            
            for(string strValue: lstStrQuesValue)
            {
                Matcher matcher = nonAlphanumeric.matcher(strValue);
                lstQuesValues.add(new SelectOption(strValue,matcher.replaceAll('')));
            }            
        }
         
        return lstQuesValues;
    }
    
    //create picklist values based on question value field
    public List<SelectOption> getQuesValues1()
    {
        lstQuesValues = new List<SelectOption>();
        List<Survey_question__c> objSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Share with others ?' LIMIT 1];
        if(objSurveyQues.size()!=0 || objSurveyQues!=null)
        {
            List<String> lstStrQuesValue= objSurveyQues[0].value__c.split(',');
            for(string strValue: lstStrQuesValue)
            {
                lstQuesValues.add(new SelectOption(strValue,strValue));
            }            
        }
         
        return lstQuesValues;
    }
       
    //method to submit survey answers for five question records
    public PageReference submitSurvey()
    {
    
       if(ApexPages.currentPage().getParameters().get('options')==null || ApexPages.currentPage().getParameters().get('options')=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have not completed all questions'));
            return null;
        }
        
        if(ApexPages.currentPage().getParameters().get('options1')==null || ApexPages.currentPage().getParameters().get('options1')=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have not completed all questions'));
            return null;
        }
        
        if(ApexPages.currentPage().getParameters().get('options2')==null || ApexPages.currentPage().getParameters().get('options2')=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have not completed all questions'));
            return null;
        }
        
        if(ApexPages.currentPage().getParameters().get('options3')==null || ApexPages.currentPage().getParameters().get('options3')=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have not completed all questions'));
            return null;
        }
    
        
        if(ApexPages.currentPage().getParameters().get('caseId')==null || ApexPages.currentPage().getParameters().get('caseId')=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error in submitting survey,case not found'));
            return null;
        }
        if(lstcase[0].Survey_Flag__c=='False')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Survey has already been submitted for this case'));
            return null;
        }
        List<Survey_question__c> lstSurveyQues = new List<Survey_question__c>();
        List<Survey_answer__c> lstSurveyAns = new List<Survey_answer__c>();
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Resolved ?' LIMIT 1];
        if(lstSurveyQues.size()!=0 || lstSurveyQues!=null)
        {
            Survey_answer__c objAns= new Survey_answer__c();
            objAns.Case__c = ApexPages.currentPage().getParameters().get('caseId');
            objAns.Survey_Question__c = lstSurveyQues[0].id;
            objAns.Answer__c = strResolved;
            lstSurveyAns.add(objAns);
        }
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Resolution Time ?' LIMIT 1];
        if(lstSurveyQues.size()!=0 || lstSurveyQues!=null)
        {
            Survey_answer__c objAns= new Survey_answer__c();
            objAns.Case__c = ApexPages.currentPage().getParameters().get('caseId');
            objAns.Survey_Question__c = lstSurveyQues[0].id;
            objAns.Answer__c = strResolutionTime;
            lstSurveyAns.add(objAns);
        }
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Support Person ?' LIMIT 1];
        if(lstSurveyQues.size()!=0 || lstSurveyQues!=null)
        {
            Survey_answer__c objAns= new Survey_answer__c();
            objAns.Case__c = ApexPages.currentPage().getParameters().get('caseId');
            objAns.Survey_Question__c = lstSurveyQues[0].id;
            objAns.Answer__c = strSupportPerson;
            lstSurveyAns.add(objAns);
        }
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Share with others ?' LIMIT 1];
        if(lstSurveyQues.size()!=0 || lstSurveyQues!=null)
        {
            Survey_answer__c objAns= new Survey_answer__c();
            objAns.Case__c = ApexPages.currentPage().getParameters().get('caseId');
            objAns.Survey_Question__c = lstSurveyQues[0].id;
            objAns.Answer__c = strLikeOurSupport;
            lstSurveyAns.add(objAns);
        }
        lstSurveyQues= [Select id, name, question__c,type__c,value__c from survey_question__c 
                                           where name='Comments' LIMIT 1];
        if((lstSurveyQues.size()!=0 || lstSurveyQues!=null) && (strComment!=null || strComment!=''))
        {
            Survey_answer__c objAns= new Survey_answer__c();
            objAns.Case__c = ApexPages.currentPage().getParameters().get('caseId');
            objAns.Survey_Question__c = lstSurveyQues[0].id;
            objAns.Answer__c = strComment;
            lstSurveyAns.add(objAns);
        }
        
        try 
        {
        System.debug('^^^^^^^survey answers::'+lstSurveyAns);
            insert lstSurveyAns;
            lstCase[0].Survey_Flag__c='False';
            update lstCase; 
            sendSurveyFeedbackEmail(lstCase,lstSurveyAns); 
            
            PageReference pageRef;
            pageRef=new PageReference('/CommunityCaseSurveySuccess');
            pageref.setRedirect(true);
            return pageref;
        }
        catch (DMLException e) 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in submitting survey feedback'));
           
            return null;
        }
        
    }

    //method to send email to case owner/assigned to based on survey feedback
    //tried with email templates but did not work
    public void sendSurveyFeedbackEmail(List<case> lstCase,List<Survey_answer__c> lstSurveyAns)
    {
        String strSendTo;
        String strSendId;
        String strSendToName;
        String strSubject='Survey received for case #: {Casenumber: '+lstCase[0].casenumber+'} : {Subject: '+lstCase[0].subject+'}';
        if(lstCase[0].assigned_to__c!=null)
        {
            strSendId= lstCase[0].assigned_to__r.id;
            strSendTo= lstCase[0].assigned_to__r.email;
            strSendToName= lstCase[0].assigned_to__r.name;
        }
        else
        {
            strSendId =lstCase[0].ownerId;
            strSendTo= lstCase[0].owner.email;
            strSendToName= lstCase[0].owner.name;
        }
        if(lstSurveyAns[0].answer__c.trim().equalsignorecase('2 Dissatisfied') || 
           lstSurveyAns[0].answer__c.trim().equalsignorecase('1 Very Dissatisfied'))
        {
            strSubject='Dissatisfied ' +strSubject;
        }
        if(string.valueOf(strSendId).startsWith('005'))
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {strSendTo};
            String strBody = 'Dear '+ strSendToName + ',\n\n'
                            +((lstSurveyAns[0].answer__c.trim().equalsignorecase('4 Very Satisfied') || 
                            lstSurveyAns[0].answer__c.trim().equalsignorecase('3 Satisfied'))?
                            'We recently received a customer satisfaction survey response from a customer. \n\n':  
                            'We recently received a customer satisfaction survey response from a dissatisfied customer. \n\n')
                            + 'The customers answers were: \n'
                            + '\t Resolved :\t\t {'+lstSurveyAns[0].answer__c.trim() +'} \n' 
                            + '\t Resolution Time :\t {'+lstSurveyAns[1].answer__c.trim() +'} \n'
                            + '\t Support Person :\t {'+lstSurveyAns[2].answer__c.trim() +'} \n'
                            + '\t Recommend us :\t {'+lstSurveyAns[3].answer__c.trim() +'} \n'
                            + '\t Comments :\t\t {'+lstSurveyAns[4].answer__c.trim() +'} \n\n'
                            +((lstSurveyAns[0].answer__c.trim().equalsignorecase('4 Very Satisfied') || 
                            lstSurveyAns[0].answer__c.trim().equalsignorecase('3 Satisfied'))?
                            + 'Please review the customer comments for any additional inputs or recommendations,' 
                            + 'and potential follow-ups on our side (fixing root causes, improving documentation etc.)':
                            + 'In most cases it is appropriate and expected to follow-up to the customer feedback.\n'
                            + 'Please review the case details and customer comments and contact the customer.\n\n'
                            + 'When contacting the customer by phone - please remember these things:\n'
                            + 'Do\'s and Don\'ts \n'
                            + '+ Thank the customers. Tell them how valuable they are and how much we appreciate their feedback.\n'
                            + '+ Listen to their concerns, check for understanding, and tell them you are preparing a document to be escalated to the appropriate group or team.\n'
                            + '+ Thank them again. This is truly a sincere thank you for their help to improve our products and service.\n'
                            + '+ Do stay cool and always thank them for their time.\n'
                            + '- Don\'t get defensive. Don\'t argue.\n'
                            + '- Don\'t interrupt them when they are talking about the issue.\n'
                            + '- Don\'t demand they answer all of your questions.\n'
                            + '- Don\'t let their negative attitude affect the way you respond to them.\n')
                            + '\n\nThank You. \n\n' + 'Best regards,\n' + 'NXP Technical Support team';
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('NXP Technical Support');
            mail.setSubject(strSubject);
            mail.setPlainTextBody(strBody);
            try
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            catch(System.EmailException ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sorry, some problem occured.'));     
            }
        }
    }
    public pagereference updateSurvey  ()
{


 string str=ApexPages.currentPage().getParameters().get('id');
List<Survey_Answer__c> lstSurvey =[select id,Non_Personal__c from Survey_Answer__c where Case__r.id=:ApexPages.currentPage().getParameters().get('id')];
 if(lstSurvey.size()>0)
    {
    for(Survey_Answer__c objSurvey :lstSurvey )
        {
        objSurvey.Non_Personal__c =objSurveyAns.Non_Personal__c;
        }
   update lstSurvey;
    }
 pageReference pg = new pageReference('/'+str);
 pg.setRedirect(true);
 return pg;

}  
}