/******************************************************************************************************************************************************************************************************************
@Created By :       Avichal Kumar
@Created Date:      7th August 2015
@Description:       Test class for CommunityReply_AfterInsert trigger
******************************************************************************************************************************************************************************************************************/
@isTest
private class CommunityReply_AfterInsertTest {
 private Static question createQuestions()
    {
        Question objQue=new Question();
        objQue.title='test1';
        objQue.body='test1';
        return objQue;
    }
 
 private Static Reply createAnswers()
    {
        Reply objRep=new Reply();
        objRep.body='test';
        return objRep;
    }
    
    //Post Answer
    static testmethod void CommunityReply_AfterInsertTest1()
        
    {
         Test.startTest();
         
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Answer_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
         
        Question objQue1=new Question();
        objQue1=createQuestions();
        objQue1.CommunityId=objCom.id;
        objQue1.Product_Category__c='Automotive';
        insert objQue1;
       
        Reply objRep= new Reply();
        objRep=createAnswers();
        objRep.QuestionId=objQue1.id;
        insert objRep;  
       
        Test.stopTest();
    }
}