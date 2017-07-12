/* @Name            :    TestAgreementController
   @Author          :    Syed Jameel
   @Date            :    14 Nov, 2011
   @Description     :    Test class for AgreementController
   --------------------------------------------------------------
   @Last Modified By     : Baji
   @Last Modified Date   : 09 Mar, 2015
   @Description : Added @isTest annotation at class level.
*/

 @isTest
public class TestAgreementController{
    @isTest
    public static void unitTest(){
        List<RecordType> recIdLst=[Select id from RecordType where SobjectType='Apttus__APTS_Agreement__c' and Name='NDA / Evaluation (Sales)'];
        Apttus__APTS_Agreement__c apttus = new Apttus__APTS_Agreement__c();
        apttus.Submitter_Email_Address__c = 'test@gmail.com';
        insert apttus;
        Attachment att = new Attachment();
        att.body = Blob.valueOf('Test');
        att.name = 'test.jpg';
        att.ParentID  = apttus.id;
        insert att;
        AgreementController ap = new AgreementController();
        ap.arg = apttus;
        System.Debug('@@@Record List is '+ap.recIdLst);
        ap.getFileName(); 
        ap.getContentType();        
        //ap.recIDLst = recIdLst;
        ap.next();
        ap.pre();
        ap.Attach = Blob.valueOf('Testing');
        ap.save();
    }
}