/***************************************************************************************************************************************************************************************************************** 
@Created By :       Avichal Kumar
@Created Date:      7th August  2015
@Description:       Test class for  CommunityQuestion_AfterUpdate trigger
******************************************************************************************************************************************************************************************************************/
@isTest
private class CommunityQuestion_AfterUpdateTest {
   private Static question createQuestions()
    {
        Question objQue=new Question();
        objQue.title='testing1';
        objQue.body='testing1';
        return objQue;
    } 
    
    private Static Reply createAnswers()
    {
        Reply objRep=new Reply();
        objRep.body='testing';
        return objRep;
    }
    //Question Likes And Best Answer
    static testmethod void CommunityQuestion_AfterUpdateTest1 ()
        
    {
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_BestReply__c= 20;
        insert setting;
        system.assert(setting.Id!=null);
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        Test.startTest();
         
        Question objQue1=new Question();
        objQue1=createQuestions();
        objQue1.CommunityId=objCom.id;
        objQue1.Product_Category__c='Automotive';
        insert objQue1;
        
        Reply objRep= new Reply();
        objRep=createAnswers();
        objRep.QuestionId=objQue1.id;
        insert objRep; 
        
        Question_like__c objQuestionlike = new question_like__c();
        objQuestionlike.QuestionID__c=objQue1.id;
        insert objQuestionlike;
        
        objque1.bestReplyid=objrep.id;
        update objque1;

        Test.stopTest();
    }
}