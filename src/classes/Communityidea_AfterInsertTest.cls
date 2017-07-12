/******************************************************************************************************************************************************************************************************************
@Created By :       Avichal Kumar
@Created Date:      11th August 2015
@Description:       Test class for Communityidea_AfterInsert trigger
******************************************************************************************************************************************************************************************************************/
@isTest
private class Communityidea_AfterInsertTest {
    private Static idea createstories()
    {
        idea objidea=new idea();
        objidea.title='test1';
        objidea.body='test1';
        return objidea;
    }
    //Story Post
    static testmethod void Communityidea_AfterInsert1()   
    {
         Test.startTest();
         
        Community objCom= [SELECT Id FROM Community WHERE Name = 'success stories'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Answer_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
         
         idea objidea1=new idea();
         objidea1=createstories();
         objidea1.title='test1';
         objidea1.body='test1';
         objidea1.CommunityId=objCom.id;
         insert objidea1; 
        

        Test.stopTest();
    }
}