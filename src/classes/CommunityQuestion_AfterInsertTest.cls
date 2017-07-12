/*****************************************************************************************************************************************************************************************************************
@Created By :       Avichal Kumar
@Created Date:      7th Aug 2015
@Description:       Test class for CommunityQuestion_AfterInsert Trigger
******************************************************************************************************************************************************************************************************************/
@isTest
private class CommunityQuestion_AfterInsertTest {
   private Static question createQuestions()
    {
        Question objQue=new Question();
        objQue.title='test1';
        objQue.body='test1';
        return objQue;
    } 
    
    //Question Creation
    static testmethod void CommunityQuestion_AfterInsertTest1 ()
        
    {
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        Test.startTest();
         
        Question objQue1=new Question();
        objQue1=createQuestions();
        objQue1.CommunityId=objCom.id;
        objQue1.Product_Category__c='Automotive';
        insert objQue1;
        Test.stopTest();
    }
}