/*******************************************************************************************************
Name        :     TestUserRegistrationController
Author      :     
Date        :        17 May,2011
Description :     Test class for UserRegistrationController


   @Last Modified By     : Manoj 
   @Last Modified Date   : 09 Mar, 2015 
   @Description : Added @isTest annotation at class level. 

*******************************************************************************************************/
   @isTest
private class TestUserRegistrationController{
 
   static testMethod void TestUserRegistrationController(){
        /*Model_N__c m1 = new Model_N__c();
        m1.name = 'test';
        m1.user_type__c = 'NXP User';
        //m1.CurrencyIsoCode = 'EUR - Euro';
        insert m1;*/
        
        UserRegistrationController urc = new UserRegistrationController();
        urc.getitems();
        /*urc.ModelN.name='Test';*/
        urc.accesstype= 'New User';
        urc.nextAType();
        urc.usertype = 'NXP User';
        urc.Registration();
        urc.modelN.CurrencyIsoCode = String.valueOf('EUR');
        urc.modelN.WBI_account__c = 'Test';
        urc.modelN.Region__c = 'Americas';
        urc.modelN.Country__c = 'United States';
        urc.modelN.Manager_Name__c = 'Test';
        urc.modelN.Manager_email_address__c = 'test@mail.com';
        urc.modelN.Tel_Mobile__c = '123456789';
        urc.modelN.Roles_Category__c = 'Business Lines';
        urc.modelN.Read_Org__c = 'Worldwide distribution';
        urc.modelN.Edit_Org__c = 'Americas';
        urc.modelN.User_Type__c = 'NXP User';
        urc.modelN.First_Name__c = 'Test';
        urc.modelN.Last_Name__c = 'Test';
        urc.modelN.Email_Address__c = 'test@mail.com';
        urc.modelN.Role_Sub_Category__c = 'Field Sales Engineer';
        urc.modelN.BU__c = 'BU Automotive';
        urc.modelN.MAGS__c = 'R32 CAR ENT SOL UNDIVIDED';
        //'USD - U.S. Dollar';
        
        urc.save();
        urc.back();
        urc.backnxp();
        urc.nxtnxp();
        urc.register();
        
        UserRegistrationController urcDisti = new UserRegistrationController();
        urcDisti.getitems();
        urcDisti.accesstype= 'Change Access';
        urcDisti.nextAType();
        urcDisti.usertype = 'Disti User';
        urcDisti.Registration();
        urcDisti.modelN.CurrencyIsoCode = String.valueOf('EUR');
        urcDisti.modelN.First_Name__c = 'Test';
        urcDisti.modelN.Last_Name__c = 'Test';
        urcDisti.modelN.Email_Address__c = 'test@mail.com';
        urcDisti.modelN.Company_Name__c = 'Test';
        urcDisti.modelN.Company_Address__c = 'Test';
        urcDisti.modelN.Country__c = 'United States';
        urcDisti.modelN.Job_Title__c = 'Test';
        urcDisti.modelN.Roles_Disti_new__c = 'Disti - Quoting';
        urcDisti.modelN.Read_Org__c = 'Americas';
        urcDisti.modelN.Edit_Org__c = 'Americas';
        urcDisti.save();
        urcDisti.Flag = true;
        urcDisti.nxp = true;
        urcDisti.back();
        urcDisti.accesstype = 'Change Access';
        urcDisti.backdisti();
        urcDisti.nxtdisti();
        urcDisti.register();
        
        UserRegistrationController urcSales = new UserRegistrationController();
        urcSales.getitems();
        urcSales.usertype = 'Sales Rep';
        urcSales.accesstype= 'New User';
        urcSales.nextAType();
        urcSales.Registration();
        urcSales.modelN.CurrencyIsoCode = String.valueOf('EUR');
        urcSales.modelN.First_Name__c = 'Test';
        urcSales.modelN.Last_Name__c = 'Test';
        urcSales.modelN.Email_Address__c = 'test@mail.com';
        urcSales.modelN.Company_Name__c = 'Test';
        urcSales.modelN.Company_Address__c = 'Test';
        urcSales.modelN.Country__c = 'United States';
        urcSales.modelN.Job_Title__c = 'Test';
        urcSales.modelN.Read_Org__c = 'Americas';
        urcSales.modelN.Edit_Org__c = 'Americas';
        urcSales.modelN.Manager_Name__c = 'Test';
        urcSales.modelN.Manager_email_address__c = 'test@mail.com';
        urcSales.modelN.Tel_Mobile__c = '123456789';
        urcSales.save();
        urcSales.back();
        urcSales.accesstype = 'Change Access';
        urcSales.backSales();
        urcSales.nxtsales();
        urcSales.register();
        
        UserRegistrationController urcVar = new UserRegistrationController();
        urcVar.getitems();
        urcvar.accesstype= 'New User';
        urcvar.nextAType();
        urcVar.usertype = 'var';
        urcVar.Registration();
        urcVar.modelN.CurrencyIsoCode = String.valueOf('EUR');
        urcVar.modelN.First_Name__c = 'Test';
        urcVar.modelN.Last_Name__c = 'Test';
        urcVar.modelN.Email_Address__c = 'test@mail.com';
        urcVar.modelN.Company_Name__c = 'Test';
        urcVar.modelN.Company_Address__c = 'Test';
        urcVar.modelN.Country__c = 'United States';
        urcVar.modelN.Read_Org__c = 'Americas';
        urcVar.modelN.Edit_Org__c = 'Americas';
        urcVar.modelN.Job_Title__c = 'Test';
        urcVar.modelN.Manager_Name__c = 'Test';
        urcVar.modelN.Manager_email_address__c = 'test@mail.com';
        urcVar.modelN.Tel_Mobile__c = '123456789';
        urcVar.save();
        urcVar.back();
        urcVar.nxtvar();
        urcVar.accesstype = 'Change Access';
        urcVar.backVar();
        urcVar.register();
        urcVar.Flag = true;
        urcVar.nxp = true;
        urcVar.back();
        UserRegistrationController urcdemo = new UserRegistrationController();
        urcdemo.Flag = true;
        urcdemo.usertype = '';
        urcdemo.Registration();
    }

    private static void setupData(UserRegistrationController urc) {
        urc.getitems();
        /*urc.ModelN.name='Test';*/
        urc.accesstype= 'New User';
        urc.nextAType();
        urc.usertype = 'NXP User';
        urc.Registration();
        urc.modelN.CurrencyIsoCode = String.valueOf('EUR');

        urc.modelN.WBI_account__c = 'Test';
        urc.modelN.Region__c = 'Americas';
        urc.modelN.Country__c = 'United States';
        urc.modelN.Manager_Name__c = 'Test';
        urc.modelN.Manager_email_address__c = 'test@mail.com';
        urc.modelN.Tel_Mobile__c = '123456789';
        urc.modelN.Roles_Category__c = 'Business Lines';
        urc.modelN.Role_Sub_Category__c = 'Test';
        urc.modelN.Read_Org__c = 'Worldwide distribution';
        urc.modelN.Read_Org_Sub_Category__c = 'Test';
        urc.modelN.Requester_Email_Address__c = 'test@mail.com';
        urc.modelN.Edit_Org__c = 'Americas';
        urc.modelN.User_Type__c = 'NXP User';
        urc.modelN.First_Name__c = 'Test';
        urc.modelN.Last_Name__c = 'Test';
        urc.modelN.Email_Address__c = 'test@mail.com';
        urc.modelN.Role_Sub_Category__c = 'Field Sales Engineer';
        urc.modelN.BU__c = 'BU Automotive';
        urc.modelN.MAGS__c = 'R32 CAR ENT SOL UNDIVIDED';
        urc.modelN.Job_Title__c = 'Test';
        urc.modelN.Roles_Disti_new__c = 'Test';
        urc.modelN.Disti_Role_Hierarchy__c = 'Test';
        urc.modelN.Company_Name__c = 'Test';
        urc.modelN.Company_Address__c = 'Test';

        urc.modelN.Role_Hierarchy_Region__c = 'Americas';
        urc.modelN.Role_Hierarchy_Sub_Region__c = 'Test';
        urc.modelN.Role_Hierarchy_Country_Region__c = 'Test';
        urc.modelN.Role_Hierarchy_Country_Sub_Region__c = 'Test';
        
        urc.modelN.Assigned_Org_VAR__c = 'Test';
    }

    @isTest
    private static void testExceptionAll() {
        UserRegistrationController urc = new UserRegistrationController();
        urc.getitems();
        urc.accesstype= 'New User';
        urc.nextAType();
        urc.Registration();
        urc.modelN.CurrencyIsoCode = String.valueOf('EUR');

        urc.nxtNxp();

        urc.nxtSales();

        urc.nxtDisti();

        urc.nxtVar();

        urc.modelN.User_Type__c = 'NXP User';
        urc.save();

        urc.accesstype = 'Change Access';
        urc.backnxp();
        
        urc.modelN.User_Type__c = 'Disti User';
        urc.save();

        urc.modelN.User_Type__c = 'Sales Rep';
        urc.save();

        urc.modelN.User_Type__c = 'Var';
        urc.save();

    }

    @isTest
    private static void testValidAll() {
        UserRegistrationController urc = new UserRegistrationController();
        setupData(urc);

        urc.nxtNxp();

        urc.nxtSales();

        urc.nxtDisti();

        urc.nxtVar();

        urc.save();  

        urc.accesstype = 'Change Access';
        urc.backnxp();
    }

    @isTest
    private static void testSalesValid() {
        UserRegistrationController urc = new UserRegistrationController();
        setupData(urc);

        PageReference myPage = Page.UserRegistration;
        Test.setCurrentPage(myPage);
        myPage.getParameters().put('j_id0:frm:Sales:pbs3:RHSS', '__');
        myPage.getParameters().put('j_id0:frm:Sales:pbs3:RHCS', '__');
        myPage.getParameters().put('j_id0:frm:Sales:pbs3:RHCSS', '__');

        urc.nxtSales();
    }
    
    @isTest
    private static void testNxpException() {
        UserRegistrationController urc = new UserRegistrationController();
        setupData(urc);
        urc.modelN.BU__c = null;
        urc.modelN.MAGS__c = null;
        urc.modelN.Edit_Org__c = 'Worldwide distribution';
        urc.modelN.Edit_Org_Sub_Category__c = null;

        urc.nxtNxp();
    }
}