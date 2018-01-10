/***********************************************************************
 @Last Modified By   : Shridevi Badiger
 @Last Modified Date : 25-Aug-2017
 @Description : As part of SIR 828-Increased the code coverage of CommunityEmailNotificationController
***********************************************************************/

@isTest
public class CommunityEmailNotificationControllerTest
{
   private static final String CASE_TSCOMMUNITY = 'TS_Community';
    private static final String CASE_TSWEBMASTER = 'TS_Webmaster';
    private static final String ACCOUNT_CHILDACCOUNT = 'Child_Account';
    private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
    
    public static RecordType tsCommunity;
    public static RecordType webMaster;
    public static RecordType childAccount;
    public static RecordType parentAccount;
    
    
    public static void fetchRecordTypes()
    {
        for(RecordType rt : [Select Id, DeveloperName
                              From RecordType
                              Where IsActive=true and  
                              ((SobjectType = 'Case' and (DeveloperName =: CASE_TSCOMMUNITY or DeveloperName =: CASE_TSWEBMASTER)) or
                               (SobjectType = 'Account' and (DeveloperName =: ACCOUNT_CHILDACCOUNT or DeveloperName =: ACCOUNT_ParentACCOUNT)) 
                              )
                              Limit 4])
        {
            if(rt.DeveloperName == CASE_TSCOMMUNITY)
            {
                tsCommunity = rt;
            }
            else if(rt.DeveloperName == CASE_TSWEBMASTER)
            {
                webMaster = rt;
            }
            else if(rt.DeveloperName == ACCOUNT_CHILDACCOUNT)
            {
                childAccount = rt;
            }
            else if(rt.DeveloperName == ACCOUNT_ParentACCOUNT)
            {
                parentAccount = rt; 
            }            
        }
    } 
     public static case createCases()
     {
         Case objCase = new Case();
                objCase= new Case(RecordTypeID = tsCommunity.Id, Status= 'New', Priority = 'Medium', 
                              Product_Category__c = 'RF', Product_Sub__c = 'Mixers', 
                              email__c = 'test1@test.com', JobTitle__c = 'Other', Facebook__c = 'test_fb',
                              Company__c = 'test_Company', Linkedin__c = 'test_lnk', Community_Web_Country__c = 'test_country',
                              Twitter__c = 'test_twt', State_Province__c = 'test_state', Product_Type_Number__c = 'test',
                              Subject = 'test_subject', My_Question_is_Related__c = 'test', Description = 'test_subject',
                              Product_application__c = 'test', Expected_annual_unit_volume__c = 'test',
                              Project_Stage__c = 'Development', Web_Region__c = 'Test_region',  origin = 'Self Service Portal',Case_Owner_Name__c='test'); 
         return objCase;
     }
    public static EmailMessage CreateEmailMessage(id caseId)
    {
     EmailMessage objEmail=new EmailMessage();
                objEmail.FromAddress = 'test@example.com';
                objEmail.ToAddress = 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
                objEmail.Subject = 'Test email';
                objEmail.TextBody = 'Hello';
                objEmail.ParentId = caseId; // The inserted test Case Id that you created above
                objEmail.Incoming = true;
                
         return objEmail;
    }

   static testmethod void CommunityEmailNotificationControllerTest1()
    {
        list<Case> listCase = new list<Case>();
        list<EmailMessage> listEmailMessage=new list<EmailMessage>();
        fetchRecordTypes();
        
        Test.startTest();
        {
        User objStandardUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(objStandardUser)
        {
                ListCase.add(createCases());
                ListCase.add(createCases());
                ListCase.add(createCases());
                ListCase.add(createCases());
                Insert ListCase ;
                //case Objcase1=[select Id,ownerId from case where id=:objCase.id];
               // System.debug(Objcase1);
               
                Test.stopTest();
                system.assert(ListCase[0].Id!=null);
                system.assert(ListCase[1].Id!=null);
                system.assert(ListCase[2].Id!=null);
                system.assert(ListCase[3].Id!=null);
                listEmailMessage.add(CreateEmailMessage(ListCase[0].Id));
                listEmailMessage.add(CreateEmailMessage(ListCase[1].Id));
                listEmailMessage.add(CreateEmailMessage(ListCase[2].Id));
                listEmailMessage[1].FromAddress='';
            
                insert listEmailMessage;   
                system.assert(listEmailMessage[0].Id!=null);
                system.assert(listEmailMessage[1].Id!=null);
                
                
                ListCase[0].Status='Close';
                ListCase[1].Status='Close';
                //ListCase[1].Status='Close';
               ListCase[2].ownerId=objStandardUser.id;
               ListCase[3].assigned_to__c=objStandardUser.id;
                Update ListCase;
                System.assertEquals(ListCase[0].Status,'Close');
                System.assertEquals(ListCase[1].Status,'Close');
                listEmailMessage=new list<EmailMessage>();
                listEmailMessage.add(CreateEmailMessage(ListCase[0].Id));
                listEmailMessage.add(CreateEmailMessage(ListCase[2].Id));
                listEmailMessage.add(CreateEmailMessage(ListCase[3].Id));
                insert listEmailMessage;
               system.assert(listEmailMessage[0].Id!=null);
               system.assert(listEmailMessage[1].Id!=null);
               system.assert(listEmailMessage[2].Id!=null);
        }
       }
    }

}