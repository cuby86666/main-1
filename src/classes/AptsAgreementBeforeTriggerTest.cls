/**********************************************************************************************
@Modified By :  Scarlett Kang
@Modified Date: 6 July 2016
@Description:   1605 Release SIR 907 - Apttus Changes - Procurement Purchasing Policy
***********************************************************************************************/
@isTest
public class AptsAgreementBeforeTriggerTest {
    private static final String TYPE_Assembly_Testing_Agreement = 'Assembly_Testing_Agreement';//purchase agreement
    private static final String TYPE_NDA_Evaluation_Other = 'NDA_Evaluation_Other';//Corporate agreement
    private static final String TYPE_Design_in_Development = 'Design_in_Development';//sales agreement
    private static final String TYPE_NXP_Software_NDA = 'NXP_Software_NDA';//Software Agreement
    private static final String TYPE_Framework_Distributor_Agreement = 'Framework_Distributor_Agreement';
    private static final String TYPE_Global_Local_Price_Agreement = 'Global_Local_Price_Agreement';
    
    private static RecordType Assembly_Testing_Agreement;
    private static RecordType NDA_Evaluation_Other;
    private static RecordType Design_in_Development;
    private static RecordType NXP_Software_NDA;
    private static RecordType Framework_Distributor_Agreement;
    private static RecordType Global_Local_Price_Agreement;
    
    @isTest(seeAllData = TRUE)
    private static void fetchRecordType(){
        for(RecordType rt : [SELECT Id, DeveloperName, Name FROM RecordType 
                             WHERE IsActive = TRUE AND SobjectType = 'Apttus__APTS_Agreement__c' AND 
                             (DeveloperName =: TYPE_Assembly_Testing_Agreement OR
                              DeveloperName =: TYPE_NDA_Evaluation_Other OR
                              DeveloperName =: TYPE_Design_in_Development OR
                              DeveloperName =: TYPE_NXP_Software_NDA OR
                              DeveloperName =: TYPE_Framework_Distributor_Agreement OR
                              DeveloperName =: TYPE_Global_Local_Price_Agreement
                             )])
        {
            if(rt.DeveloperName == TYPE_Assembly_Testing_Agreement)
                Assembly_Testing_Agreement = rt;
            if(rt.DeveloperName == TYPE_NDA_Evaluation_Other)
                NDA_Evaluation_Other = rt;
            if(rt.DeveloperName == TYPE_Design_in_Development)
                Design_in_Development = rt;
            if(rt.DeveloperName == TYPE_NXP_Software_NDA)
                NXP_Software_NDA = rt;
            if(rt.DeveloperName == TYPE_Framework_Distributor_Agreement)
                Framework_Distributor_Agreement = rt;
            if(rt.DeveloperName == TYPE_Global_Local_Price_Agreement)
                Global_Local_Price_Agreement = rt;
        }
    }
    
    public static List<User> createTestUsers(Id profileId, integer intNumOfUsers){
        List<User> lstUsers = new List<User>();
        
        for(Integer i = 100; i < intNumOfUsers + 100; i++) {
            User objUser = new User(
                alias = 'nUser' + i, 
                email='newuser' + i +'@test.test', 
                emailencodingkey='UTF-8', 
                lastname='test', 
                languagelocalekey='en_US', 
                localesidkey='en_US',
                profileid = profileId, 
                timezonesidkey='America/Los_Angeles', 
                username= 'newuser'+ i + '@test.test'
            );
            lstUsers.add(objUser);                   
        }
        return lstUsers;
    }
    
    public static List<Apttus_Approver_Role__c> createApttusApproverRoleLst(){
        fetchRecordType();
        
        List<RecordType> lstRecordType = [
            SELECT Id, DeveloperName, Name FROM RecordType 
            WHERE IsActive = TRUE AND SobjectType = 'Apttus__APTS_Agreement__c'
        ];
        
        List<Apttus_Approver_Role__c> lstApproverRole = new List<Apttus_Approver_Role__c>();
        
        for(integer i = 0 ; i < lstRecordType.size() ; i++){
            Apttus_Approver_Role__c newRole = new Apttus_Approver_Role__c(
                Name = lstRecordType[i].Name,
                Agreement_Type_Name__c = lstRecordType[i].Name,
                Approver_1_Role__c = 'Coporate Control',    
                Approver_2_Role__c = 'CTC', 
                Approver_3_Role__c = 'Tax Depatment',   
                Approver_4_Role__c = 'Customer Program Manager',    
                Approver_5_Role__c = 'Key Account Manager', 
                Approver_6_Role__c = 'Regional Controller', 
                Approver_7_Role__c = 'RSM', 
                Approver_8_Role__c = 'BU SCM Manager',  
                Approver_9_Role__c = 'GSM Controller'
            );
            lstApproverRole.add(newRole);
        }

        return lstApproverRole;
    }
    
    public static void createAccount(){
        Account testA = new Account( 
            Name = 'Test' ,
            Status_of_D_B_Cleansing__c = null ,
            D_B_Number__c = 'Test DUNS' ,
            D_B_SIC_Code__c = 'Test SIC' ,
            D_B_SIC_Code_Description__c = 'Test SIC Desc' ,
            D_B_NAICS_Code__c = 'Test NAICS' ,
            D_B_NAICS_Code_Description__c = 'Test NAICS Desc' ,
            D_B_Country__c = 'Test Country' ,
            D_B_State_Province__c = 'Test Province' ,
            D_B_City__c = 'Test City' ,
            D_B_Street__c = 'Test Street' ,
            D_B_ZIP_Postal_Code__c = 'Test ZIP'
        );
        insert testA;        
    }
    
    public static void prepareData(){
        fetchRecordType();
        //Prepare Data
        //createApttusApproverRoleLst();
        //insert Approvers
        List<Profile> lstProfiles =[
            SELECT Id, Name 
            FROM Profile 
            WHERE Name LIKE '%Apttus%' LIMIT 1 
        ];
        
     if(lstProfiles.size() > 0 ){
            Profile objProfile = lstProfiles[0];
            
            List<User> lstApprovers = createTestUsers(objProfile.Id, 40);
            insert lstApprovers;
            
            for(User objUser : lstApprovers)
                system.assert(objUser.Id != null);
            
            User BL_Marketing_Marketing = lstApprovers[0];
            User BU_BL_Marketing_Manager = lstApprovers[1];
            User BU_GM_GM = lstApprovers[2];
            User BU_Quality_Quality = lstApprovers[3];
            User BU_SCM_SCM = lstApprovers[4];
            User Channel_Controller_Controller = lstApprovers[5];
            User Chief_Purchasing_Purchasing = lstApprovers[6];
            User Corporate_Control = lstApprovers[7];
            User CTC = lstApprovers[8];
            User Customer_Program_Program = lstApprovers[9];
            User Director_Marketing_Marketing = lstApprovers[10];
            User EM_Controller_Controller = lstApprovers[11];
            User EM_SVP_SVP = lstApprovers[12];
            User GSM_Controller_Controller = lstApprovers[13];
            User GSM_Credit_Credit = lstApprovers[14];
            User GSM_Global_Disti_GM = lstApprovers[15];
            User GSM_Head_Head = lstApprovers[16];
            User GSM_Process_Operations_Manager = lstApprovers[17];
            User Head_of_Sourcing = lstApprovers[18];
            User IP_Department_Department = lstApprovers[19];
            User Key_Account_Account = lstApprovers[20];
            User Key_User = lstApprovers[21];
            User Legal = lstApprovers[22];
            User Management_Team_Team = lstApprovers[23];
            User Others = lstApprovers[24];
            User Regional_Channel_Channel = lstApprovers[25];
            User Regional_Controller_Controller = lstApprovers[26];
            User RSM = lstApprovers[27];
            User SBMT = lstApprovers[28];
            User Site_Purchasing_Purchasing = lstApprovers[29];
            User Stakeholder = lstApprovers[30];
            User Supplier_Quality_Quality = lstApprovers[31];
            User Sustainability_Officer_Officer = lstApprovers[32];
            User Tax_Department_Department = lstApprovers[33];
            User WW_Sales_Sales = lstApprovers[34];

            System.assert(BL_Marketing_Marketing.Id != null);
            System.assert(BU_BL_Marketing_Manager.Id != null);
            System.assert(BU_GM_GM.Id != null);
            System.assert(BU_Quality_Quality.Id != null);
            System.assert(BU_SCM_SCM.Id != null);
            System.assert(Channel_Controller_Controller.Id != null);
            System.assert(Chief_Purchasing_Purchasing.Id != null);
            System.assert(Corporate_Control.Id != null);
            System.assert(CTC.Id != null);
            System.assert(Customer_Program_Program.Id != null);
            System.assert(Director_Marketing_Marketing.Id != null);
            System.assert(EM_Controller_Controller.Id != null);
            System.assert(EM_SVP_SVP.Id != null);
            System.assert(GSM_Controller_Controller.Id != null);
            System.assert(GSM_Credit_Credit.Id != null);
            System.assert(GSM_Global_Disti_GM.Id != null);
            System.assert(GSM_Head_Head.Id != null);
            System.assert(GSM_Process_Operations_Manager.Id != null);
            System.assert(Head_of_Sourcing.Id != null);
            System.assert(IP_Department_Department.Id != null);
            System.assert(Key_Account_Account.Id != null);
            System.assert(Key_User.Id != null);
            System.assert(Legal.Id != null);
            System.assert(Management_Team_Team.Id != null);
            System.assert(Others.Id != null);
            System.assert(Regional_Channel_Channel.Id != null);
            System.assert(Regional_Controller_Controller.Id != null);
            System.assert(RSM.Id != null);
            System.assert(SBMT.Id != null);
            System.assert(Site_Purchasing_Purchasing.Id != null);
            System.assert(Stakeholder.Id != null);
            System.assert(Supplier_Quality_Quality.Id != null);
            System.assert(Sustainability_Officer_Officer.Id != null);
            System.assert(Tax_Department_Department.Id != null);
            System.assert(WW_Sales_Sales.Id != null);
            
            //Create Apttus Approver Table
            List<Apttus_Approver_Table__c> lstApttusApprover = new List<Apttus_Approver_Table__c>();
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = BL_Marketing_Marketing.Name, Role__c = 'BL Marketing Manager',   User__c = BL_Marketing_Marketing.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = BU_BL_Marketing_Manager.Name, Role__c = 'BU / BL Marketing Manager', User__c = BU_BL_Marketing_Manager.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = BU_GM_GM.Name, Role__c = 'BU GM',    User__c = BU_GM_GM.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = BU_Quality_Quality.Name, Role__c = 'BU Quality Manager', User__c = BU_Quality_Quality.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = BU_SCM_SCM.Name, Role__c = 'BU SCM Manager', User__c = BU_SCM_SCM.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Channel_Controller_Controller.Name, Role__c = 'Channel Controller',  User__c = Channel_Controller_Controller.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Chief_Purchasing_Purchasing.Name, Role__c = 'Chief Purchasing Officer',  User__c = Chief_Purchasing_Purchasing.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Corporate_Control.Name, Role__c = 'Corporate Control',   User__c = Corporate_Control.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = CTC.Name, Role__c = 'CTC',   User__c = CTC.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Customer_Program_Program.Name, Role__c = 'Customer Program Manager', User__c = Customer_Program_Program.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Director_Marketing_Marketing.Name, Role__c = 'Director Marketing',   User__c = Director_Marketing_Marketing.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = EM_Controller_Controller.Name, Role__c = 'EM Controller',    User__c = EM_Controller_Controller.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = EM_SVP_SVP.Name, Role__c = 'EM SVP', User__c = EM_SVP_SVP.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = GSM_Controller_Controller.Name, Role__c = 'GSM Controller',  User__c = GSM_Controller_Controller.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = GSM_Credit_Credit.Name, Role__c = 'GSM Credit Control Manager',  User__c = GSM_Credit_Credit.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = GSM_Global_Disti_GM.Name, Role__c = 'GSM Global Disti GM',   User__c = GSM_Global_Disti_GM.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = GSM_Head_Head.Name, Role__c = 'GSM Head',    User__c = GSM_Head_Head.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = GSM_Process_Operations_Manager.Name, Role__c = 'GSM Process & Operations Manager',   User__c = GSM_Process_Operations_Manager.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Head_of_Sourcing.Name, Role__c = 'Head of Sourcing', User__c = Head_of_Sourcing.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = IP_Department_Department.Name, Role__c = 'IP Department',    User__c = IP_Department_Department.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Key_Account_Account.Name, Role__c = 'Key Account Manager',   User__c = Key_Account_Account.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Key_User.Name, Role__c = 'Key User', User__c = Key_User.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Legal.Name, Role__c = 'Legal',   User__c = Legal.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Management_Team_Team.Name, Role__c = 'Management Team',  User__c = Management_Team_Team.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Others.Name, Role__c = 'Others', User__c = Others.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Regional_Channel_Channel.Name, Role__c = 'Regional Channel Controller',  User__c = Regional_Channel_Channel.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Regional_Controller_Controller.Name, Role__c = 'Regional Controller',    User__c = Regional_Controller_Controller.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = RSM.Name, Role__c = 'RSM',   User__c = RSM.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = SBMT.Name, Role__c = 'SBMT', User__c = SBMT.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Site_Purchasing_Purchasing.Name, Role__c = 'Site Purchasing Manager',    User__c = Site_Purchasing_Purchasing.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Stakeholder.Name, Role__c = 'Stakeholder',   User__c = Stakeholder.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Supplier_Quality_Quality.Name, Role__c = 'Supplier Quality Management',  User__c = Supplier_Quality_Quality.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Sustainability_Officer_Officer.Name, Role__c = 'Sustainability Officer', User__c = Sustainability_Officer_Officer.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = Tax_Department_Department.Name, Role__c = 'Tax Department',  User__c = Tax_Department_Department.Id));
            lstApttusApprover.add(new Apttus_Approver_Table__c( Name = WW_Sales_Sales.Name, Role__c = 'WW Sales Director',  User__c = WW_Sales_Sales.Id));

            insert lstApttusApprover;
        
            //Insert Custom Setting
            List<Apttus_Approver_Role__c> lstCustomSettingApprover = new List<Apttus_Approver_Role__c>();
            
            //Purchase agreement (old)
            Apttus_Approver_Role__c Assembly_Testing_AgreementRole = new Apttus_Approver_Role__c(
                Name = Assembly_Testing_Agreement.Name,
                Agreement_Type_Name__c = Assembly_Testing_Agreement.Name,
                Approver_1_Role__c = 'Coporate Control',    
                Approver_2_Role__c = 'CTC', 
                Approver_3_Role__c = 'Tax Depatment',   
                Approver_4_Role__c = 'Customer Program Manager',    
                Approver_5_Role__c = 'Key Account Manager', 
                Approver_6_Role__c = 'Regional Controller', 
                Approver_7_Role__c = 'RSM', 
                Approver_8_Role__c = 'BU SCM Manager',  
                Approver_9_Role__c = 'GSM Controller'
            );
            lstCustomSettingApprover.add(Assembly_Testing_AgreementRole);   
            
            //Purchase agreement
            Apttus_Approver_Role__c Global_Local_Price_AgreementRole = new Apttus_Approver_Role__c(
                Name = Global_Local_Price_Agreement.Name,
                Agreement_Type_Name__c = Global_Local_Price_Agreement.Name,
                Approver_1_Role__c = 'Coporate Control',    
                Approver_2_Role__c = 'CTC', 
                Approver_3_Role__c = 'Tax Depatment',   
                Approver_4_Role__c = 'Customer Program Manager',    
                Approver_5_Role__c = 'Key Account Manager', 
                Approver_6_Role__c = 'Regional Controller', 
                Approver_7_Role__c = 'RSM', 
                Approver_8_Role__c = 'BU SCM Manager',  
                Approver_9_Role__c = 'GSM Controller'
            );
            lstCustomSettingApprover.add(Global_Local_Price_AgreementRole);   
            
            //Corporate agreement
            lstCustomSettingApprover.add( new Apttus_Approver_Role__c(
                Name = NDA_Evaluation_Other.Name,
                Agreement_Type_Name__c = NDA_Evaluation_Other.Name,
                Approver_1_Role__c = 'GSM ControllerCoporate Control',  
                Approver_2_Role__c = 'Regional Controller', 
                Approver_3_Role__c = 'Tax Depatment',   
                Approver_4_Role__c = 'Customer Program Manager',    
                Approver_5_Role__c = 'Key Account Manager', 
                Approver_6_Role__c = 'CTC', 
                Approver_7_Role__c = 'RSM', 
                Approver_8_Role__c = 'BU SCM Manager',  
                Approver_9_Role__c = 'Coporate Control'
            ));
            
            //Sales agreement
            lstCustomSettingApprover.add( new Apttus_Approver_Role__c(
                Name = Design_in_Development.Name,
                Agreement_Type_Name__c = Design_in_Development.Name,
                Approver_1_Role__c = 'GSM ControllerCoporate Control',  
                Approver_2_Role__c = 'Regional Controller', 
                Approver_3_Role__c = 'Tax Depatment',   
                Approver_4_Role__c = 'Customer Program Manager',    
                Approver_5_Role__c = 'BU SCM Manager',  
                Approver_6_Role__c = 'Coporate Control',
                Approver_7_Role__c = 'BU GM',
                Approver_8_Role__c = 'BU GM',
                Approver_9_Role__c = 'BU GM'
            ));
            
            //Sales Agreement: Framework_Distributor_Agreement
            lstCustomSettingApprover.add( new Apttus_Approver_Role__c(
                Name = Framework_Distributor_Agreement.Name,
                Agreement_Type_Name__c = Framework_Distributor_Agreement.Name,
                Approver_1_Role__c = 'GSM ControllerCoporate Control',  
                Approver_2_Role__c = 'Regional Controller', 
                Approver_3_Role__c = 'Tax Depatment',   
                Approver_4_Role__c = 'Customer Program Manager',    
                Approver_5_Role__c = 'BU SCM Manager',  
                Approver_6_Role__c = 'Coporate Control',
                Approver_7_Role__c = 'BU GM',
                Approver_8_Role__c = 'BU GM',
                Approver_9_Role__c = 'BU GM'
            ));
            
            //Software Agreement
            lstCustomSettingApprover.add( new Apttus_Approver_Role__c(
                Name = NXP_Software_NDA.Name,
                Agreement_Type_Name__c = NXP_Software_NDA.Name,
                Approver_1_Role__c = 'GSM ControllerCoporate Control',  
                Approver_2_Role__c = 'Regional Controller', 
                Approver_3_Role__c = 'Tax Depatment',   
                Approver_4_Role__c = 'Customer Program Manager',    
                Approver_5_Role__c = 'BU SCM Manager',  
                Approver_6_Role__c = 'Coporate Control',
                Approver_7_Role__c = 'RSM', 
                Approver_8_Role__c = 'BU SCM Manager'
            ));
            
            insert lstCustomSettingApprover;
            System.assert(lstCustomSettingApprover.Size() > 0);
            
            //Create Account
            Account testA = new Account( 
                Name = 'Test' ,
                Status_of_D_B_Cleansing__c = null ,
                D_B_Number__c = 'Test DUNS' ,
                D_B_SIC_Code__c = 'Test SIC' ,
                D_B_SIC_Code_Description__c = 'Test SIC Desc' ,
                D_B_NAICS_Code__c = 'Test NAICS' ,
                D_B_NAICS_Code_Description__c = 'Test NAICS Desc' ,
                D_B_Country__c = 'Test Country' ,
                D_B_State_Province__c = 'Test Province' ,
                D_B_City__c = 'Test City' ,
                D_B_Street__c = 'Test Street' ,
                D_B_ZIP_Postal_Code__c = 'Test ZIP',
                Customer_Category__c = 'Longtail'
            );
            insert testA;   
            Account testB = new Account( 
                Name = 'Test' ,
                Status_of_D_B_Cleansing__c = null ,
                D_B_Number__c = 'Test DUNS' ,
                D_B_SIC_Code__c = 'Test SIC' ,
                D_B_SIC_Code_Description__c = 'Test SIC Desc' ,
                D_B_NAICS_Code__c = 'Test NAICS' ,
                D_B_NAICS_Code_Description__c = 'Test NAICS Desc' ,
                D_B_Country__c = 'Test Country' ,
                D_B_State_Province__c = 'Test Province' ,
                D_B_City__c = 'Test City' ,
                D_B_Street__c = 'Test Street' ,
                D_B_ZIP_Postal_Code__c = 'Test ZIP',
                Customer_Category__c = 'Global'
            );
            insert testB;   
         
            List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        
            //Create Purchase Agreement
            Apttus__APTS_Agreement__c purchaseAgmt = new Apttus__APTS_Agreement__c(
                RecordTypeId = Assembly_Testing_Agreement.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 5,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver_2_Role__c = lstApttusApprover[1].Role__c,
                Approver_3_Role__c = lstApttusApprover[2].Role__c,
                Approver_4_Role__c = lstApttusApprover[3].Role__c,
                Approver_5_Role__c = lstApttusApprover[4].Role__c,
                Approver_6_Role__c = lstApttusApprover[5].Role__c,
                Approver_7_Role__c = lstApttusApprover[6].Role__c,
                Approver_8_Role__c = lstApttusApprover[7].Role__c,
                Approver_9_Role__c = lstApttusApprover[8].Role__c,
                Legal__c = lstApttusApprover[0].User__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver2__c = lstApttusApprover[1].User__c,
                Approver3__c = lstApttusApprover[2].User__c,
                Approver4__c = lstApttusApprover[3].User__c,
                Approver5__c = lstApttusApprover[4].User__c,
                Approver6__c = lstApttusApprover[5].User__c,
                Approver_7__c = lstApttusApprover[6].User__c,
                Approver8__c = lstApttusApprover[7].User__c,
                Approver_9__c = lstApttusApprover[8].User__c,
                nxp_Additional_Approver__c = lstApttusApprover[9].User__c,
                MT_Approver__c = lstApttusApprover[10].User__c,
                nxp_complete_checked__c = True,
                Apttus__Version_Number__c = 1.0
            );
            LstAgreement.add(purchaseAgmt);
            
            //Create Purchase Agreement with Corporate Control approver
            Apttus__APTS_Agreement__c purchaseAgmt2 = new Apttus__APTS_Agreement__c(
                RecordTypeId = Assembly_Testing_Agreement.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 5,
                nxp_agreement_info__c = 'Test',
//                nxp_Responsible__c = lstApprovers[0].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver_2_Role__c = lstApttusApprover[1].Role__c,
                Approver_3_Role__c = lstApttusApprover[2].Role__c,
                Approver_4_Role__c = lstApttusApprover[3].Role__c,
                Approver_5_Role__c = lstApttusApprover[4].Role__c,
                Approver_6_Role__c = lstApttusApprover[5].Role__c,
                Approver_7_Role__c = lstApttusApprover[6].Role__c,
                Approver_8_Role__c = lstApttusApprover[7].Role__c,
                Legal__c = lstApttusApprover[0].User__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver2__c = lstApttusApprover[1].User__c,
                Approver3__c = lstApttusApprover[2].User__c,
                Approver4__c = lstApttusApprover[3].User__c,
                Approver5__c = lstApttusApprover[4].User__c,
                Approver6__c = lstApttusApprover[5].User__c,
                Approver_7__c = lstApttusApprover[6].User__c,
                Approver8__c = lstApttusApprover[7].User__c,
                nxp_complete_checked__c = True,
                Apttus__Version_Number__c = 0.0
            );
            LstAgreement.add(purchaseAgmt2);
            
            //Create Sales Agreement
            Apttus__APTS_Agreement__c salesAgmt = new Apttus__APTS_Agreement__c(
                RecordTypeId = Design_in_Development.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                //Total_Agreement_Value_in_millions__c = 5,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                /*
                Approver_2_Role__c = lstApttusApprover[1].Role__c,
                Approver_3_Role__c = lstApttusApprover[2].Role__c,
                Approver_4_Role__c = lstApttusApprover[3].Role__c,
                Approver_5_Role__c = lstApttusApprover[4].Role__c,
                Approver_6_Role__c = lstApttusApprover[5].Role__c,
                Approver_7_Role__c = lstApttusApprover[6].Role__c,
                Approver_8_Role__c = lstApttusApprover[7].Role__c,
                Approver_9_Role__c = lstApttusApprover[8].Role__c,
*/
                Legal__c = lstApttusApprover[0].User__c,
                /*
                Approver1__c = lstApttusApprover[0].User__c,
                Approver2__c = lstApttusApprover[1].User__c,
                Approver3__c = lstApttusApprover[2].User__c,
                Approver4__c = lstApttusApprover[3].User__c,
                Approver5__c = lstApttusApprover[4].User__c,
                Approver6__c = lstApttusApprover[5].User__c,
                Approver_7__c = lstApttusApprover[6].User__c,
                Approver8__c = lstApttusApprover[7].User__c,
                Approver_9__c = lstApttusApprover[8].User__c,
*/
                Total_Agreement_Value_in_millions__c = 0.0,
                nxp_Additional_Approver__c = lstApttusApprover[9].User__c,
                MT_Approver__c = lstApttusApprover[10].User__c,
                nxp_complete_checked__c = True,
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True
            );
            LstAgreement.add(salesAgmt);

            Apttus__APTS_Agreement__c NDAAgmt = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 5.0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request'
            );
            LstAgreement.add(NDAAgmt);
            
            Apttus__APTS_Agreement__c NDAAgmt2 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                //Total_Agreement_Value_in_millions__c = 5,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c
            );
            LstAgreement.add(NDAAgmt2);
            
            Apttus__APTS_Agreement__c NDAAgmt3 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                //Total_Agreement_Value_in_millions__c = 5,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c
            );
            LstAgreement.add(NDAAgmt3);
            
            Apttus__APTS_Agreement__c NDAAgmt4 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                //Total_Agreement_Value_in_millions__c = 5,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = lstApttusApprover[0].Role__c,
                Approver3__c = lstApttusApprover[0].User__c
            );
            LstAgreement.add(NDAAgmt4);
            
            Apttus__APTS_Agreement__c NDAAgmt5 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                //Total_Agreement_Value_in_millions__c = 5,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = lstApttusApprover[0].Role__c,
                Approver3__c = lstApttusApprover[0].User__c,
                Approver_4_Role__c = lstApttusApprover[0].Role__c,
                Approver4__c = lstApttusApprover[0].User__c
            );
            LstAgreement.add(NDAAgmt5);
            
            Apttus__APTS_Agreement__c NDAAgmt6 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = lstApttusApprover[0].Role__c,
                Approver3__c = lstApttusApprover[0].User__c,
                Approver_4_Role__c = lstApttusApprover[0].Role__c,
                Approver4__c = lstApttusApprover[0].User__c,
                Approver_5_Role__c = lstApttusApprover[0].Role__c,
                Approver5__c = lstApttusApprover[0].User__c
            );
            LstAgreement.add(NDAAgmt6);
            
            Apttus__APTS_Agreement__c NDAAgmt7 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                //Total_Agreement_Value_in_millions__c = 5,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = lstApttusApprover[0].Role__c,
                Approver3__c = lstApttusApprover[0].User__c,
                Approver_4_Role__c = lstApttusApprover[0].Role__c,
                Approver4__c = lstApttusApprover[0].User__c,
                Approver_5_Role__c = lstApttusApprover[0].Role__c,
                Approver5__c = lstApttusApprover[0].User__c,
                Approver_6_Role__c = lstApttusApprover[0].Role__c,
                Approver6__c = lstApttusApprover[0].User__c
            );
            LstAgreement.add(NDAAgmt7);
            
            //Agreement with zero value and Corporate Control
            Apttus__APTS_Agreement__c NDAAgmt8 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0.0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                //Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                //Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = 'Corporate Control'
            );
            LstAgreement.add(NDAAgmt8);
            
            //Agreement with zero value and Corporate Control
            Apttus__APTS_Agreement__c NDAAgmt9 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0.0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                //Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                //Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = 'Corporate Control'
            );
            LstAgreement.add(NDAAgmt9);
            
            //Agreement with zero value and Corporate Control
            Apttus__APTS_Agreement__c NDAAgmt10 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0.0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                //Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                //Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = 'Corporate Control'
            );
            LstAgreement.add(NDAAgmt10);
            
            //Agreement with zero value and Corporate Control
            Apttus__APTS_Agreement__c NDAAgmt11 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0.0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                //Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                //Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = lstApttusApprover[0].Role__c,
                Approver3__c = lstApttusApprover[0].User__c,
                Approver_4_Role__c = 'Corporate Control'
            );
            LstAgreement.add(NDAAgmt11);

            //Agreement with zero value and Corporate Control
            Apttus__APTS_Agreement__c NDAAgmt12 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0.0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                //Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                //Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = lstApttusApprover[0].Role__c,
                Approver3__c = lstApttusApprover[0].User__c,
                Approver_4_Role__c = lstApttusApprover[0].Role__c,
                Approver4__c = lstApttusApprover[0].User__c,
                Approver_5_Role__c = 'Corporate Control'
                //Approver5__c = lstApttusApprover[0].User__c,
                //Approver_6_Role__c = 'Corporate Control',
                //Approver_7_Role__c = 'Corporate Control',
                //Approver_8_Role__c = 'Corporate Control'
            );
            LstAgreement.add(NDAAgmt12);
            
            //Agreement with zero value and Corporate Control
            Apttus__APTS_Agreement__c NDAAgmt13= new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0.0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                //Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                //Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = lstApttusApprover[0].Role__c,
                Approver3__c = lstApttusApprover[0].User__c,
                Approver_4_Role__c = lstApttusApprover[0].Role__c,
                Approver4__c = lstApttusApprover[0].User__c,
                Approver_5_Role__c = lstApttusApprover[0].Role__c,
                Approver_6_Role__c = 'Corporate Control'
                //Approver_7_Role__c = 'Corporate Control',
                //Approver_8_Role__c = 'Corporate Control'
            );
            LstAgreement.add(NDAAgmt13);
            
            //Agreement with zero value and Corporate Control
            Apttus__APTS_Agreement__c NDAAgmt14 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                //Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                //Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = lstApttusApprover[0].Role__c,
                Approver3__c = lstApttusApprover[0].User__c,
                Approver_4_Role__c = lstApttusApprover[0].Role__c,
                Approver4__c = lstApttusApprover[0].User__c,
                Approver_5_Role__c = lstApttusApprover[0].Role__c,
                Approver5__c = lstApttusApprover[0].User__c,
                Approver_6_Role__c = lstApttusApprover[0].Role__c,
                Approver_7_Role__c = 'Corporate Control'
                //Approver_7_Role__c = 'Corporate Control',
                //Approver_8_Role__c = 'Corporate Control'
            );
            LstAgreement.add(NDAAgmt14);
            
                        //Agreement with zero value and Corporate Control
            Apttus__APTS_Agreement__c NDAAgmt15 = new Apttus__APTS_Agreement__c(
                RecordTypeId = NDA_Evaluation_Other.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                //Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True,
                Apttus__Status_Category__c = 'Request',
                //Total_Agreement_Value_in_millions__c = 5.0,
                Approver_1_Role__c = lstApttusApprover[0].Role__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver_2_Role__c = lstApttusApprover[0].Role__c,
                Approver2__c = lstApttusApprover[0].User__c,
                Approver_3_Role__c = lstApttusApprover[0].Role__c,
                Approver3__c = lstApttusApprover[0].User__c,
                Approver_4_Role__c = lstApttusApprover[0].Role__c,
                Approver4__c = lstApttusApprover[0].User__c,
                Approver_5_Role__c = lstApttusApprover[0].Role__c,
                Approver5__c = lstApttusApprover[0].User__c,
                Approver_6_Role__c = lstApttusApprover[0].Role__c,
                Approver6__c = lstApttusApprover[0].User__c,
                Approver_7_Role__c = lstApttusApprover[0].Role__c,
                Approver_7__c = lstApttusApprover[0].User__c,
                Approver_8_Role__c = 'Corporate Control'
            );
            LstAgreement.add(NDAAgmt15);
            
            //Global/Local General Purchase Agreement (GPA) Agreement
            Apttus__APTS_Agreement__c Global_Local_General_Purchase_Agmt = new Apttus__APTS_Agreement__c(
                RecordTypeId = Global_Local_Price_Agreement.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_3_Role__c = 'Head of Sourcing',
                Approver_6_Role__c = 'Corporate Control',
                Approver_7_Role__c = 'Chief Purchasing Officer',
                Legal__c = lstApttusApprover[0].User__c,
                Approver3__c = lstApttusApprover[2].User__c,
                Approver6__c = lstApttusApprover[5].User__c,
                Approver_7__c = lstApttusApprover[6].User__c,
                nxp_Additional_Approver__c = lstApttusApprover[9].User__c,
                MT_Approver__c = lstApttusApprover[10].User__c,
                //nxp_complete_checked__c = True,
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True
            );
            LstAgreement.add(Global_Local_General_Purchase_Agmt);       

            Apttus__APTS_Agreement__c FrameworkDistributorAgmt = new Apttus__APTS_Agreement__c(
                RecordTypeId = Framework_Distributor_Agreement.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 0,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_1_Role__c = 'BU GM',
                Approver_2_Role__c = 'BU GM',
                Approver_3_Role__c = 'BU GM',
                Approver_4_Role__c = 'BU GM',
                Approver_5_Role__c = 'BU GM',
                Approver_6_Role__c = 'BU GM',
                Approver_7_Role__c = 'BU GM',
                Approver_8_Role__c = 'BU GM',
                Approver_9_Role__c = 'BU GM',
                Legal__c = lstApttusApprover[0].User__c,
                Approver1__c = lstApttusApprover[0].User__c,
                Approver2__c = lstApttusApprover[1].User__c,
                Approver3__c = lstApttusApprover[2].User__c,
                Approver4__c = lstApttusApprover[3].User__c,
                Approver5__c = lstApttusApprover[4].User__c,
                Approver6__c = lstApttusApprover[5].User__c,
                Approver_7__c = lstApttusApprover[6].User__c,
                Approver8__c = lstApttusApprover[7].User__c,
                Approver_9__c = lstApttusApprover[8].User__c,
                nxp_Additional_Approver__c = lstApttusApprover[9].User__c,
                MT_Approver__c = lstApttusApprover[10].User__c,
                nxp_complete_checked__c = True,
                Apttus__Version_Number__c = 1.0,
                nxp_Restricted__c = True
            );
            LstAgreement.add(FrameworkDistributorAgmt); 
            
            Apttus__APTS_Agreement__c FrameworkDistributorAgmt2 = new Apttus__APTS_Agreement__c(
                RecordTypeId = Framework_Distributor_Agreement.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_3_Role__c = 'BU GM',
                nxp_Restricted__c = True,
                Total_Agreement_Value_in_millions__c = 0
            );
            LstAgreement.add(FrameworkDistributorAgmt2);        
            
            Apttus__APTS_Agreement__c FrameworkDistributorAgmt3 = new Apttus__APTS_Agreement__c(
                RecordTypeId = Framework_Distributor_Agreement.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_4_Role__c = 'BU GM',
                nxp_Restricted__c = True,
                Total_Agreement_Value_in_millions__c = 0
            );
            LstAgreement.add(FrameworkDistributorAgmt3);    
            
            Apttus__APTS_Agreement__c FrameworkDistributorAgmt4 = new Apttus__APTS_Agreement__c(
                RecordTypeId = Framework_Distributor_Agreement.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_5_Role__c = 'BU GM',
                nxp_Restricted__c = True, 
                Total_Agreement_Value_in_millions__c = 0
            );
            LstAgreement.add(FrameworkDistributorAgmt4);    
            
            Apttus__APTS_Agreement__c FrameworkDistributorAgmt6 = new Apttus__APTS_Agreement__c(
                RecordTypeId = Framework_Distributor_Agreement.Id,
                Apttus__Account__c = testA.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_6_Role__c = 'BU GM',
                nxp_Restricted__c = True,
                Total_Agreement_Value_in_millions__c = 0
            );
            LstAgreement.add(FrameworkDistributorAgmt6);    
            
            Account globalAcc = new Account( 
                Name = 'Test' ,
                Status_of_D_B_Cleansing__c = null ,
                D_B_Number__c = 'Test DUNS' ,
                D_B_SIC_Code__c = 'Test SIC' ,
                D_B_SIC_Code_Description__c = 'Test SIC Desc' ,
                D_B_NAICS_Code__c = 'Test NAICS' ,
                D_B_NAICS_Code_Description__c = 'Test NAICS Desc' ,
                D_B_Country__c = 'Test Country' ,
                D_B_State_Province__c = 'Test Province' ,
                D_B_City__c = 'Test City' ,
                D_B_Street__c = 'Test Street' ,
                D_B_ZIP_Postal_Code__c = 'Test ZIP',
                Customer_Category__c = 'Global'
            );
            insert globalAcc;     
            
            //sales agreement: Framework_Distributor_Agreement with global account
            Apttus__APTS_Agreement__c Framework_Distributor_Agreement2 = new Apttus__APTS_Agreement__c(
                RecordTypeId = Framework_Distributor_Agreement.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_6_Role__c = 'BU GM',
                nxp_Restricted__c = True,
                Total_Agreement_Value_in_millions__c = 0,
                Apttus__Account__c = globalAcc.Id
            );
            LstAgreement.add(Framework_Distributor_Agreement2);    
            
            //Purchase Agreement Global_Local_Price_Agreement with Red flag
            Apttus__APTS_Agreement__c Global_Local_Price_Agreement2 = new Apttus__APTS_Agreement__c(
                RecordTypeId = Global_Local_Price_Agreement.Id,
                nxp_account_Legal_Entity__c = 'Test',
                NXP_Legal_Entity__c = 'Test',
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                nxp_agreement_info__c = 'Test',
                nxp_Responsible__c = lstApprovers[8].Id,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_6_Role__c = 'BU GM',
                nxp_Restricted__c = True,
                Total_Agreement_Value_in_millions__c = 0,
                Apttus__Account__c = globalAcc.Id,
                Management_Team__c = True
            );
            LstAgreement.add(Global_Local_Price_Agreement2);   

            insert LstAgreement;
            System.assert(lstAgreement.size() > 0);
            
            //Chnage Record Type
            purchaseAgmt2.RecordTypeId = NDA_Evaluation_Other.Id;
            purchaseAgmt2.Apttus__Status_Category__c = 'Request';
            purchaseAgmt2.Total_Agreement_Value_in_millions__c = 5.0;
            purchaseAgmt2.nxp_complete_checked__c = false;
            Update purchaseAgmt2;
            
            //Update Status
            purchaseAgmt.Apttus__Status_Category__c = 'Request';
            purchaseAgmt.Apttus__Status__c = 'Request Approval';
            update purchaseAgmt;
            
            //Change Approver to Corporate Control Approver
            purchaseAgmt.Approver_1_Role__c = lstApttusApprover[7].Role__c;
            purchaseAgmt.Approver1__c = lstApttusApprover[7].User__c;
            purchaseAgmt.Management_Team__c = True;
            update purchaseAgmt;

            //Remove Head of Sourcing Approver from approval flow
            Global_Local_Price_Agreement2.Approver_3_Role__c = 'BU GM';
            update Global_Local_Price_Agreement2;
         
            //Update Purchasing Agmt for adding SBMT approver
            //purchaseAgmtSBMT1.Approver_2_Role__c = 'SBMT';
            //update purchaseAgmtSBMT1;
        }//end if
    }
    
    public static void preparePurchasingAgmtSBMT(){
        fetchRecordType();
        
        //Create Purchase Agreement with SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT1 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 5,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_1_Role__c = 'SBMT'
        );
        insert purchaseAgmtSBMT1;
        
        //Create Purchase Agreement with SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT2 = new Apttus__APTS_Agreement__c(
                RecordTypeId = Assembly_Testing_Agreement.Id,
                nxp_Contract_Id__c = '123456',
                Owner_Unit__c = 'Other SBMT',
                Name = 'Test Purchasing Agreement',
                Apttus__Agreement_Category__c = 'Purchase',
                nxp_Amendment_num__c = 123456,
                Total_Agreement_Value_in_millions__c = 5,
                Apttus__Contract_Start_Date__c = date.today(),
                Apttus__Contract_End_Date__c = date.today().addDays(30),
                Approver_2_Role__c = 'SBMT'
            );
        insert purchaseAgmtSBMT2;
        
        //Create Purchase Agreement with SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT3 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 5,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_3_Role__c = 'SBMT'
        );
        insert purchaseAgmtSBMT3;
        
        //Create Purchase Agreement with SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT4 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 5,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_4_Role__c = 'SBMT'
        );
        insert purchaseAgmtSBMT4;
        
        //Create Purchase Agreement with SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT5 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 5,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_5_Role__c = 'SBMT'
        );
        insert purchaseAgmtSBMT5;
        
        //Create Purchase Agreement with SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT6 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 5,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_6_Role__c = 'SBMT'
        );
        insert purchaseAgmtSBMT6;
        
        //Create Purchase Agreement with SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT7 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 5,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_7_Role__c = 'SBMT'
        );
        insert purchaseAgmtSBMT7;
        
       //Create Purchase Agreement with SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT8 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 5,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_8_Role__c = 'SBMT'
        );
        insert purchaseAgmtSBMT8;
        
        //Create Purchase Agreement with SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT9 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Apttus__Status_Category__c = 'Request',
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 5,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_9_Role__c = 'SBMT'
        );
        insert purchaseAgmtSBMT9;
        
        //Create Purchase Agreement without SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT11 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Apttus__Status_Category__c = 'Request',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.2//,
            //Approver_1_Role__c = 'SBMT'
        );
        insert purchaseAgmtSBMT11;
        
        /*
        Apttus__APTS_Agreement__c purchaseAgmtSBMT12 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Apttus__Status_Category__c = 'Request',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.2,
            Approver_1_Role__c = 'Test'
        );
        insert purchaseAgmtSBMT12;
        //System.assertEquals('SBMT', purchaseAgmtSBMT12.Approver_2_Role__c);
        //Create Purchase Agreement without SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT12 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.2,
            Approver_1_Role__c = 'Test',
            Approver_3_Role__c = 'Test',
            Approver_4_Role__c = 'Test',
            Approver_5_Role__c = 'Test',
            Approver_6_Role__c = 'Test',
            Approver_7_Role__c = 'Test',
            Approver_8_Role__c = 'Test',
            Approver_9_Role__c = 'Test'
        );
        insert purchaseAgmtSBMT12;
        
        //Create Purchase Agreement without SBMT Approver
        Apttus__APTS_Agreement__c purchaseAgmtSBMT13 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.2,
            Approver_1_Role__c = 'Test',
            Approver_2_Role__c = 'Test',
            Approver_4_Role__c = 'Test',
            Approver_5_Role__c = 'Test',
            Approver_6_Role__c = 'Test',
            Approver_7_Role__c = 'Test',
            Approver_8_Role__c = 'Test',
            Approver_9_Role__c = 'Test'
        );
        insert purchaseAgmtSBMT13;*/
    }
    
    public static void preparePurchasingAgmtCPO(){
        fetchRecordType();
        
        //Create Purchase Agreement with CPO Approver
        Apttus__APTS_Agreement__c purchaseAgmtCPO1 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 0.5,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_1_Role__c = 'Chief Purchasing Officer'
        );
        insert purchaseAgmtCPO1;
        
        Apttus__APTS_Agreement__c purchaseAgmtCPO2 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.5,            
            Approver_2_Role__c = 'Chief Purchasing Officer'
        );
        insert purchaseAgmtCPO2;
        
        Apttus__APTS_Agreement__c purchaseAgmtCPO3 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.5,            
            Approver_3_Role__c = 'Chief Purchasing Officer'
        );
        insert purchaseAgmtCPO3;
        
        Apttus__APTS_Agreement__c purchaseAgmtCPO4 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.5,            
            Approver_5_Role__c = 'Chief Purchasing Officer'
        );
        insert purchaseAgmtCPO4;
        
        Apttus__APTS_Agreement__c purchaseAgmtCPO5 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.5,            
            Approver_6_Role__c = 'Chief Purchasing Officer'
        );
        insert purchaseAgmtCPO5; 
        
        Apttus__APTS_Agreement__c purchaseAgmtCPO6 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.5,            
            Approver_7_Role__c = 'Chief Purchasing Officer'
        );
        insert purchaseAgmtCPO6;
        
        Apttus__APTS_Agreement__c purchaseAgmtCPO7 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.5,            
            Approver_9_Role__c = 'Chief Purchasing Officer'
        );
        insert purchaseAgmtCPO7;        
        
        //Purchasing Agmt without CPO
        Apttus__APTS_Agreement__c purchaseAgmtCPO8 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 2
        );
        insert purchaseAgmtCPO8;   
        purchaseAgmtCPO8.Total_Agreement_Value_in_millions__c = 5;
        update purchaseAgmtCPO8;
        system.assertEquals(5, purchaseAgmtCPO8.Total_Agreement_Value_in_millions__c);
        system.debug('****Approver 1 Role: ' + purchaseAgmtCPO8.Approver_1_Role__c);
        system.debug('****Approver 2 Role: ' + purchaseAgmtCPO8.Approver_2_Role__c);
        system.debug('****Approver 3 Role: ' + purchaseAgmtCPO8.Approver_3_Role__c);
        system.debug('****Approver 4 Role: ' + purchaseAgmtCPO8.Approver_4_Role__c);
        system.debug('****Approver 5 Role: ' + purchaseAgmtCPO8.Approver_5_Role__c);
        system.debug('****Approver 6 Role: ' + purchaseAgmtCPO8.Approver_6_Role__c);
        system.debug('****Approver 7 Role: ' + purchaseAgmtCPO8.Approver_7_Role__c);
        system.debug('****Approver 8 Role: ' + purchaseAgmtCPO8.Approver_8_Role__c);
        system.debug('****Approver 9 Role: ' + purchaseAgmtCPO8.Approver_9_Role__c);
    }
    
    public static void preparePurchasingAgmtHeadofourcing(){
        fetchRecordType();
        
        //Create Purchase Agreement with CPO Approver
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing1 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            nxp_Contract_Id__c = '123456',
            Owner_Unit__c = 'Other SBMT',
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            nxp_Amendment_num__c = 123456,
            Total_Agreement_Value_in_millions__c = 0.1,
            Apttus__Contract_Start_Date__c = date.today(),
            Apttus__Contract_End_Date__c = date.today().addDays(30),
            Approver_1_Role__c = 'Head of Sourcing'
        );
        insert purchaseAgmtHeadofSourcing1;
        
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing2 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.1,            
            Approver_2_Role__c = 'Head of Sourcing'
        );
        insert purchaseAgmtHeadofSourcing2;
        
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing3 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.1,            
            Approver_3_Role__c = 'Head of Sourcing'
        );
        insert purchaseAgmtHeadofSourcing3;
        
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing4 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.1,            
            Approver_4_Role__c = 'Head of Sourcing'
        );
        insert purchaseAgmtHeadofSourcing4;
        
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing5 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.1,            
            Approver_5_Role__c = 'Head of Sourcing'
        );
        insert purchaseAgmtHeadofSourcing5; 
        
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing6 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.1,            
            Approver_6_Role__c = 'Head of Sourcing'
        );
        insert purchaseAgmtHeadofSourcing6;
        
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing7 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.1,            
            Approver_7_Role__c = 'Head of Sourcing'
        );
        insert purchaseAgmtHeadofSourcing7;
        
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing8 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.1,            
            Approver_8_Role__c = 'Head of Sourcing'
        );
        insert purchaseAgmtHeadofSourcing8;           
        
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing9 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 0.1,            
            Approver_9_Role__c = 'Head of Sourcing'
        );
        insert purchaseAgmtHeadofSourcing9;
        
        Apttus__APTS_Agreement__c purchaseAgmtHeadofSourcing11 = new Apttus__APTS_Agreement__c(
            RecordTypeId = Assembly_Testing_Agreement.Id,
            Name = 'Test Purchasing Agreement',
            Apttus__Agreement_Category__c = 'Purchase',
            Total_Agreement_Value_in_millions__c = 1
        );
        insert purchaseAgmtHeadofSourcing11;
    }
    
    static testmethod void apttusTest(){
        test.startTest();
        prepareData();
        test.stopTest();   
    }
    
    static testmethod void purchasingAgmtSBMTApproverTest(){
        test.startTest();
        preparePurchasingAgmtSBMT();
        test.stopTest();   
    }
    
    static testmethod void purchasingAgmtCPOApproverTest(){
        test.startTest();
        preparePurchasingAgmtCPO();
        test.stopTest();   
    }
 
    static testmethod void purchasingAgmtHeadofSourcingApproverTest(){
        test.startTest();
        preparePurchasingAgmtHeadofourcing();
        test.stopTest();   
    }
}