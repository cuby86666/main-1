/***************************************************************************************************************************************************************************************************************** 
@Created By :       Avichal Kumar
@Created Date:      7th August  2015
@Description:       Test class for  CommunityReply_AfterUpdate trigger
******************************************************************************************************************************************************************************************************************/
@isTest
private class CommunityReply_AfterupdateTest {
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
    
    //Answer Likes
    static testmethod void CommunityReply_AfterupdateTest1 ()
        
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
        
        Answer_like__c objAnswerlike = new Answer_like__c();
        objAnswerlike.ReplyID__c=objRep.id;
        insert objAnswerlike;
        
        update objRep;
        
        Test.stopTest();
    }
}