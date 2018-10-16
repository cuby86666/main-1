/*------------------------------------------------------------------------------------------------------------------
 * Created By   : Ranganath C N
 * Created Date : 30 Aug,2018
 * Description   : Test class to surveyfeedcase.
 ------------------------------------------------------------------------------------------------------------------*/
@isTest   
private class surveyfeedcasetest {

  static testMethod void testDoGet() {
  
        Profile profileId1 = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
  
             User usr1 = new User(LastName = 'CN',
                           FirstName='rang',
                           Alias = 'ran',
                           Email = 'test@CN.BOSCH.COM',
                           Username = 'test@CN.BOSCH.COM',
                           ProfileId = profileId1.Id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
                           insert usr1;
         
            Account testaccount1 = new Account();
            testaccount1.Name='john';
            insert testaccount1;
            
            Contact testcontact1 = new Contact();
            testcontact1.LastName = 'CNR';
            testcontact1.email='test@CN.BOSCH.COM';
            insert testcontact1;
            
            Product2 testproduct1 = new Product2();
            testproduct1.Name='john';
            insert testproduct1 ;
         
    
            Case cont1 = new Case(       
                                    Case_Owner_Name__c = 'Ranganath CN',
                                    subject = 'testing',
                                    priority = 'Low',
                                    status = ' New',
                                    description= 'testing cases',
                                    origin= 'Phone',
                                    My_Question_is_Related__c= 'Web',
                                    email__c = 'test@CN.BOSCH.COM',
                                    Company__c= 'uyiuyi ',
                                    Community_Web_Country__c= 'yiiuyi',
                                    Product_Category__c = 'RF',
                                    Product_Sub__c = 'Mixers',
                                    JobTitle__c = 'Other',
                                    Facebook__c = 'test_fb',
                                    Twitter__c = 'test_twt',
                                    State_Province__c = 'test_state',
                                     Product_Type_Number__c = 'test',
                                     Product_application__c = 'test', 
                                     Expected_annual_unit_volume__c = 'test',
                                     Project_Stage__c = 'Development',
                                     Web_Region__c = 'Test_region'
                                   );
            insert cont1;
        
        Survey_Question__c surveyquestion = new Survey_Question__c (Name = 'testing',
                                    Question__c = 'what is rate ',
                                    Type__c= 'simple ',
                                    Value__c = '2 satisfied'
                                    );
        
        insert surveyquestion;
        
        
        Survey_Answer__c surveyanswer = new Survey_Answer__c (Name = 'testing1',
                                    Answer__c='test1',
                                    Reason__c='strLastName', 
                                    Case__c = cont1.id,
                                    Survey_Question__c =surveyquestion.id
                                   );
         insert surveyanswer;
         
                                     
        Survey_Answer__c survans = [select id,name,answer__c from Survey_Answer__c where id=:surveyanswer.id];
        
        survans.answer__c = 'test2';
        update survans;
    
     
        
       List<FeedItem> feedItm=[select ParentId,Body from FeedItem];
        feedItm[0].body= 'test';
        try{
        update feedItm;
        }
        catch(exception e){}
        
        feedItm[0].body= 'test';
       try{
        delete feedItm;}
        catch(exception e){}
        
               
           } 

}