/*********************************************************************************************
@Created By :      Venkateshwar G
@Created Date :    27 Oct 2015
Description :      Community Live Chat survey controller test class.
****************************************************************************************************/

@isTest
public class CommunityLiveChatSurveyControllerTest 
{
    //Positive Test to submit Chat survey
    static testmethod void CommunityLiveChatSurveyControllerTest1()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingnew7@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingnew7@test.com');
        insert objUser;
    
        List<survey_question__c> lstQues= new list<survey_question__c>();

        Survey_question__c objSurveyQues1= new Survey_question__c();
        objSurveyQues1.Name='Chat Resolved ?';
        objSurveyQues1.Question__c='How satisfied are you with the answer you received in this chat?';
        objSurveyQues1.Type__c='Picklist';
        objSurveyQues1.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        lstQues.add(objSurveyQues1);
        
        Survey_question__c objSurveyQues2= new Survey_question__c();
        objSurveyQues2.Name='Chat Resolution Time ?';
        objSurveyQues2.Question__c='How satisfied are you with the request resolution time of the chat?';
        objSurveyQues2.Type__c='Picklist';
        objSurveyQues2.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        lstQues.add(objSurveyQues2);
        
        Survey_question__c objSurveyQues3= new Survey_question__c();
        objSurveyQues3.Name='Chat Support Person ?';
        objSurveyQues3.Question__c='How satisfied are you with the support person’s ability to answer your question in the chat?';
        objSurveyQues3.Type__c='Picklist';
        objSurveyQues3.Value__c='Very Satisfied, Satisfied, Dissatisfied, Very Dissatisfied';
        lstQues.add(objSurveyQues3);
        
        Survey_question__c objSurveyQues4= new Survey_question__c();
        objSurveyQues4.Name='Chat Share with others ?';
        objSurveyQues4.Question__c='Based on your experience with our support, would you tell others  “You should use it” ?';
        objSurveyQues4.Type__c='Picklist';
        objSurveyQues4.Value__c='0,1,2,3,4,5,6,7,8,9,10';
        lstQues.add(objSurveyQues4);
        
        Survey_question__c objSurveyQues5= new Survey_question__c();
        objSurveyQues5.Name='Chat Comments';
        objSurveyQues5.Question__c='Any additional comments you would like to share with us regading the chat?';
        objSurveyQues5.Type__c='Textarea';
        lstQues.add(objSurveyQues5);

        insert lstQues;
        
        system.runAs(objUser)
        {
            //create a new Chat Visitor
            LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;
            //create a Live Chat Transcript
            LiveChatTranscript trans = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,
                                                            Email__c = 'test@test.com',
                                                            First_Name__c = 'Venky',
                                                            Last_Name__c = 'Guna',
                                                            Country__c  = 'INDIA',
                                                            Company__c  = 'Test'
                                                            );                                                             
    
            CommunityLiveAgentChatSurveyController  comSurvey= new CommunityLiveAgentChatSurveyController();
            comSurvey.getQuesValues();
            comSurvey.getQuesValues1();
            comSurvey.strResolved='3 Satisfied';
            comSurvey.strResolutionTime='3 Satisfied';
            comSurvey.strSupportPerson='3 Satisfied';
            comSurvey.strLikeOurSupport='9';
            comSurvey.strComment='test';
            comSurvey.flgChinese = True;
            comSurvey.submitSurvey();
            insert trans;
            
        }
        test.stopTest();
    }
    //Positive Test to Delete the Survey if Chat Transcript is deleted Chat survey
    static testmethod void CommunityLiveChatSurveyControllerTest2()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingnew7@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingnew7@test.com');
        insert objUser;
    
        List<survey_question__c> lstQues= new list<survey_question__c>();

        Survey_question__c objSurveyQues1= new Survey_question__c();
        objSurveyQues1.Name='Chat Resolved ?';
        objSurveyQues1.Question__c='How satisfied are you with the answer you received in this chat?';
        objSurveyQues1.Type__c='Picklist';
        objSurveyQues1.Value__c='1 Very Dissatisfied, 2 Dissatisfied, 3 Satisfied, 4 Very Satisfied';
        lstQues.add(objSurveyQues1);
        
        Survey_question__c objSurveyQues2= new Survey_question__c();
        objSurveyQues2.Name='Chat Resolution Time ?';
        objSurveyQues2.Question__c='How satisfied are you with the request resolution time of the chat?';
        objSurveyQues2.Type__c='Picklist';
        objSurveyQues2.Value__c='1 Very Dissatisfied, 2 Dissatisfied, 3 Satisfied, 4 Very Satisfied';
        lstQues.add(objSurveyQues2);
        
        Survey_question__c objSurveyQues3= new Survey_question__c();
        objSurveyQues3.Name='Chat Support Person ?';
        objSurveyQues3.Question__c='How satisfied are you with the support person’s ability to answer your question in the chat?';
        objSurveyQues3.Type__c='Picklist';
        objSurveyQues3.Value__c='1 Very Dissatisfied, 2 Dissatisfied, 3 Satisfied, 4 Very Satisfied';
        lstQues.add(objSurveyQues3);
        
        Survey_question__c objSurveyQues4= new Survey_question__c();
        objSurveyQues4.Name='Chat Share with others ?';
        objSurveyQues4.Question__c='Based on your experience with our support, would you tell others  “You should use it” ?';
        objSurveyQues4.Type__c='Picklist';
        objSurveyQues4.Value__c='0,1,2,3,4,5,6,7,8,9,10';
        lstQues.add(objSurveyQues4);
        
        Survey_question__c objSurveyQues5= new Survey_question__c();
        objSurveyQues5.Name='Chat Comments';
        objSurveyQues5.Question__c='Any additional comments you would like to share with us regading the chat?';
        objSurveyQues5.Type__c='Textarea';
        lstQues.add(objSurveyQues5);

        insert lstQues;
        
        system.runAs(objUser)
        {
            //create a new Chat Visitor
            LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;
            //create a Live Chat Transcript
            LiveChatTranscript trans = new LiveChatTranscript(LiveChatVisitorId = visitor.Id,
                                                            Email__c = 'test@test.com',
                                                            First_Name__c = 'Venky',
                                                            Last_Name__c = 'Guna',
                                                            Country__c  = 'INDIA',
                                                            Company__c  = 'Test'
                                                            );                                                             
    
            CommunityLiveAgentChatSurveyController  comSurvey= new CommunityLiveAgentChatSurveyController();
            comSurvey.getQuesValues();
            comSurvey.getQuesValues1();
            comSurvey.strResolved='3 Satisfied';
            comSurvey.strResolutionTime='3 Satisfied';
            comSurvey.strSupportPerson='3 Satisfied';
            comSurvey.strLikeOurSupport='9';
            comSurvey.strComment='test';
            comSurvey.flgChinese = True;
            comSurvey.submitSurvey();
            insert trans;
            
            delete trans;
        }
        test.stopTest();
    }
    
   
}