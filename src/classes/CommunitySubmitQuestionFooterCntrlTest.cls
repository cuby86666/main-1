/******************************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     04 Aug 2015
Description :      Test class for CommunitySubmitQuestionFooterController
************************************************************************************************************/
/******************************************************************************************************
@Modified By :      Amrutha R
@ModifiedDate :     01 Oct 2015
Description :       added test code for edit question
************************************************************************************************************/


@isTest
public class CommunitySubmitQuestionFooterCntrlTest 
{

    //Positive case for submit question where category is Automotive
    //Negative case for edit question where title is null
    static testmethod void CommunitySubmitQuestionFooterCntrlTest1()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa7@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa7@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            
            Question objQue1=new Question();
            objQue1.CommunityId= objCom.id;
            objQue1.title='t';
            objQue1.body='test';
            objQue1.Product_Category__c='Interface Products';
            objQue1.Product_Sub_Category__c='General';
            insert objQue1;
            system.assert(objQue1.Id!=null);
            
            PageReference pageRef = Page.CommunitySubmitQuestion;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('strQuesId', objque1.id);
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='test';
            SubmitQuesCntrl.strBody='test';
            SubmitQuesCntrl.strCategory='Automotive';
            SubmitQuesCntrl.strSubCategory='General';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
            
            
            SubmitQuesCntrl.strTitle='';
            SubmitQuesCntrl.editQues();
            
        }
        test.stopTest();
    }
    
    //Positive case where category is I2C
    //Negative case for edit question where body is null
    static testmethod void CommunitySubmitQuestionFooterCntrlTest2()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa8@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa8@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            
            Question objQue1=new Question();
            objQue1.CommunityId= objCom.id;
            objQue1.title='test';
            objQue1.body='t';
            objQue1.Product_Category__c='Interface Products';
            objQue1.Product_Sub_Category__c='General';
            insert objQue1;
            system.assert(objQue1.Id!=null);
            
            PageReference pageRef = Page.CommunitySubmitQuestion;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('strQuesId', objque1.id);
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='test';
            SubmitQuesCntrl.strBody='test';
            SubmitQuesCntrl.strCategory='I2C';
            SubmitQuesCntrl.strSubCategory='Select Sub Category';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
            
            
            SubmitQuesCntrl.strBody='';
            SubmitQuesCntrl.editQues();
            
        }
        test.stopTest();
    }
    
    //Positive case where category is Identification and Security
    //Negative case for edit question where category is null
    static testmethod void CommunitySubmitQuestionFooterCntrlTest3()
    {
         test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa9@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa9@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
           
            Question objQue1=new Question();
            objQue1.CommunityId= objCom.id;
            objQue1.title='test';
            objQue1.body='test';
            objQue1.Product_Category__c='Interface Products';
            objQue1.Product_Sub_Category__c='General';
            insert objQue1;
            system.assert(objQue1.Id!=null);
            
            PageReference pageRef = Page.CommunitySubmitQuestion;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('strQuesId', objque1.id);
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='test';
            SubmitQuesCntrl.strBody='test';
            SubmitQuesCntrl.strCategory='Other Products';
            SubmitQuesCntrl.strSubCategory='General';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
            SubmitQuesCntrl.strCategory='Discretes and Logic';
            SubmitQuesCntrl.strSubCategory='Diodes';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            Attachment objAttach=new Attachment();
            objAttach.Body=Blob.valueOf('Unit Test Attachment Body');
            SubmitQuesCntrl.objAttachment=objAttach;
            SubmitQuesCntrl.submitQues();
            SubmitQuesCntrl.strCategory='Identification and Security';
            SubmitQuesCntrl.strSubCategory='NFC and Reader ICs';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
            
            
            SubmitQuesCntrl.strCategory='';
            SubmitQuesCntrl.editQues();
            
        }
        test.stopTest();
    }
    
    //Positive case where category is Interface Products
    //Positive case for edit question 
    static testmethod void CommunitySubmitQuestionFooterCntrlTest4()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa10@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa10@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            
            Question objQue1=new Question();
            objQue1.CommunityId= objCom.id;
            objQue1.title='test';
            objQue1.body='test';
            objQue1.Product_Category__c='Interface Products';
            objQue1.Product_Sub_Category__c='General';
            insert objQue1;
            system.assert(objQue1.Id!=null);
            
            PageReference pageRef = Page.CommunitySubmitQuestion;
            Test.setCurrentPageReference(pageRef);
            System.currentPageReference().getParameters().put('strQuesId', objque1.id);
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='test';
            SubmitQuesCntrl.strBody='test';
            SubmitQuesCntrl.strCategory='Interface Products';
            SubmitQuesCntrl.strSubCategory='General';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            
            SubmitQuesCntrl.submitQues();
            
            
            SubmitQuesCntrl.editQues();
            
        }
        test.stopTest();
    }
    
    //Positive case where category is Logic
    static testmethod void CommunitySubmitQuestionFooterCntrlTest5()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa11@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa11@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='test';
            SubmitQuesCntrl.strBody='test';
            SubmitQuesCntrl.strCategory='Logic';
            SubmitQuesCntrl.strSubCategory='General';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
            
        }
        test.stopTest();
    }
    
    //Positive case where category is Microcontrollers
    static testmethod void CommunitySubmitQuestionFooterCntrlTest6()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa12@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa12@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='test';
            SubmitQuesCntrl.strBody='test';
            SubmitQuesCntrl.strCategory='Standard Products';
            SubmitQuesCntrl.strSubCategory='Diodes';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
           
        }
         test.stopTest();
    }
    
    //Positive case where category is RF
    static testmethod void CommunitySubmitQuestionFooterCntrlTest7()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa13@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa13@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='test';
            SubmitQuesCntrl.strBody='test';
            SubmitQuesCntrl.strCategory='RF';
            SubmitQuesCntrl.strSubCategory='Diodes';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
            
        }
        test.stopTest();
    }
    
    //Negative case where category is Standard Product and body is null
    static testmethod void CommunitySubmitQuestionFooterCntrlTest8()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa14@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa14@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='test';
            SubmitQuesCntrl.strBody='';
            SubmitQuesCntrl.strCategory='Standard Product';
            SubmitQuesCntrl.strSubCategory='Thyristors';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
            system.assertEquals('Please enter Description for your question',ApexPages.getMessages().get(0).getSummary());
            
        }
        test.stopTest();
    }
    
    //Negative case where category is Other Product and title is null
    static testmethod void CommunitySubmitQuestionFooterCntrlTest9()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa15@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa15@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='';
            SubmitQuesCntrl.strBody='test';
            SubmitQuesCntrl.strCategory='Other Product';
            SubmitQuesCntrl.strSubCategory='General';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
            system.assertEquals('Please enter title for your question',ApexPages.getMessages().get(0).getSummary());
            
        }
         test.stopTest();
    }
    
    //Negative case where category null
    static testmethod void CommunitySubmitQuestionFooterCntrlTest10()
    {
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa16@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa16@test.com');
        insert objUser;
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
            
            CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.strTitle='test';
            SubmitQuesCntrl.strBody='test';
            SubmitQuesCntrl.strCategory='';
            SubmitQuesCntrl.getCategories();
            SubmitQuesCntrl.getsubCategories();
            SubmitQuesCntrl.submitQues();
            system.assertEquals('Please select category',ApexPages.getMessages().get(0).getSummary());
           
        }
        test.stopTest();
    }
    //code added by Avichal Kumar
    static testMethod void  CommunitySubmitQuestionFooterCntrlTest11()
    {   
        test.startTest();
        Profile objProfile= [SELECT Id FROM Profile WHERE name='System Administrator' Limit 1];
        User objUser = new User(alias = 'testing1',email='testingaa16@test.com',emailencodingkey='UTF-8',
        lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',profileid = objProfile.id,
        timezonesidkey='America/Los_Angeles',username='testingaa16@test.com');
        insert objUser;
        
        
        Community objCom= [SELECT Id FROM Community WHERE Name = 'NXP Community'];
        CommunitySettings__c setting = new CommunitySettings__c();
        setting.Name = 'CommunityUrl';
        setting.Question_Post__c= 10;
        insert setting;
        system.assert(setting.Id!=null);
        
        system.runAs(objUser)
        {
         
            Question objQue1=new Question();
            objQue1.CommunityId= objCom.id;
            objQue1.title='test';
            objQue1.body='test';
            objQue1.Product_Category__c='Interface Products';
            objQue1.Product_Sub_Category__c='General';
            insert objQue1;
            system.assert(objQue1.Id!=null);
        
            question_Attachment__c objquesAttachment = new question_Attachment__c();
            objquesAttachment.Question_Attachment__c= objQue1.id;
            insert objquesAttachment;
            system.assert(objquesAttachment.Id!=null);
            
        	CommunitySubmitQuestionFooterController SubmitQuesCntrl=new CommunitySubmitQuestionFooterController();
            SubmitQuesCntrl.submitQues();
        }
        test.stopTest();
    } 
    //Code Added by Avichal Kumar Ends
    
}