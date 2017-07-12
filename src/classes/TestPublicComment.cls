/*************************************************************************************************************
Name            :     TestPublicComment
Date            :     11 May, 2011
Author          :
Description     :     This test class covers code for PublicComment Trigger.
*************************************************************************************************************/

@isTest
private class TestPublicComment {

    static testMethod void myUnitTest() {
        //Fetching Record Type Sales CRM
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE isactive =true and Name = 'Sales CRM'];
        
        //Inserts new Case
        Case cas = new Case();
        cas.Status = 'New';
        cas.Origin = 'Email';
        cas.Priority = 'Medium';
        if(recordTypes.size()> 0){
            cas.RecordTypeId = recordTypes.get(0).Id;
        }
        
        insert cas;
        
        //Inserts new CaseComment
        CaseComment cc = new CaseComment();
        cc.CommentBody = 'Test';
        cc.ParentId = cas.Id;
        insert cc;
        
        //Checks trigger PublicComment worked or Not?
        cc = [select id, IsPublished from CaseComment where id =: cc.Id];
        
    }
}