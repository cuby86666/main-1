// 2015-08-11 by Rex: add 
// 
//  
//   
//    
//      function; 
//                      seperate data creation process into several functions;
//                      reduce some record type id query;
//                      change oppty naming rule (put date in oppty name)
// 2015-01-27 by Baji: Merged with single funnel changes.
// 2015-01-12 by Rex: update Top_10_BU__c to BU Automotive; test opportunity close date, production date will be this year.
/*
@Modified By :       Balaji Gunasekaran
@Modified Date:      22 May 2015
@Description:       As Part of CACC code impact analysis LineItem#51
                    - Updated the class to use new Object "Consolidated Account Code" wherever old object CACC Codes were referred as CACC Codes object needs deletion
*/


/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 
/* Last ModifiedBy : Baji
   Last ModifiedDate : 01 Jan 2018
   Description : Updated to remove the hardcoded profile Id.
*/ 



@isTest
public class GSASTestUtility{
    
    public static Opportunity createNewOpportunity(String opptyName, Account childAcc) {
        //createCustomSettings();
        //create opportunity
        //RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'SFDC_Oppty' and IsActive=true Limit 1];
        String strCloseDate = Date.today().year() + '-05-10';
        String strProductionDate = Date.today().year() + '-06-10';
        Opportunity opp = GSASTestUtility.createOpportunity(opptyName, childAcc.Id,'Direct', 
                                                          strProductionDate, strCloseDate,'Commitment');
        opp.Design_Win_Approval_Process__c = 'Open';
        opp.Design_Win_Submission_Date__c = opp.CloseDate;
        opp.RecordTypeId = '012D0000000Qp1VIAS';
        //insert opp;
        //createSAPCustomerAll();
        return opp;        
    }
    
    public static Opportunity createTestDataWithoutFFC() {
        Account childAcc = createEnvironmentData();
      
        createApproversMatrixAll();
        //create opportunity
        //RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'SFDC_Oppty' and IsActive=true Limit 1];
        String strCloseDate = Date.today().year() + '-05-10';
        String strProductionDate = Date.today().year() + '-06-10';
        Opportunity opp = GSASTestUtility.createOpportunity('test opportunity' + Date.today().format(), childAcc.Id,'Direct', 
                                                          strProductionDate, strCloseDate,'Commitment');
        opp.Design_Win_Approval_Process__c = 'Approved';
        opp.Design_Win_Submission_Date__c = opp.CloseDate;
        opp.RecordTypeId = '012D0000000Qp1VIAS';
        insert opp;
        
        createSAPCustomerAll();

        return opp;
    }
    
    public static Account createEnvironmentData() {
        //create customer
        Customer__c myCustomer = createCustomer();
        
        //create account
        List<Account> lstAccounts = new List<Account>();
        Account parentAcc = GSASTestUtility.createParentAccount('Samsung', 'Korea', myCustomer.Id);
        //lstAccounts.add(parentAcc);
        insert parentAcc;
        Account childAcc = GSASTestUtility.createChildAccount('Samsung mobile', 'Korea', parentAcc.Id);
        //lstAccounts.add(childAcc);
        //insert lstAccounts;
        insert childAcc;
                
        return childAcc;
    }
    
    public static void createApproversMatrixAll() {
        //create User
        List<User> lstUsers = new List<User>();
         
        User regionalVP = GSASTestUtility.createUser('Regional VP', 'regionalvp@nxp.com', 'RVP1');
        lstUsers.add(regionalVP);
        User regionalController = GSASTestUtility.createUser('Regional Controller', 'regionalctrl@nxp.com', 'RCtrl');
        lstUsers.add(regionalController);
        insert lstUsers;

        //create Approver Matrix
        List<Approvers_Matrix__c> lstApprovers = new List<Approvers_Matrix__c>();
        lstApprovers.add(GSASTestUtility.createApproversMatrix(regionalVP.Id, 'Korea', 'Regional VP'));
        lstApprovers.add(GSASTestUtility.createApproversMatrix(regionalController.Id, 'Korea', 'Regional Controller'));
        insert lstApprovers;
    }
    
  
    public static void createSAPCustomerAll() {
        //create SAP customer
        List<SAP_Customer__c> lstSAPCustomer = new List<SAP_Customer__c>();
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124717 - SAMSUNG', 'SAM', 'SAMSUNG', 'Z005', '124717', 'OEM', '124717-124864-US60'));
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124717 - SAMSUNG', 'SAM', 'SAMSUNG', 'Z005', '124717', 'OEM', '124717-124867-US60'));
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124718 - SAMSUNG', 'SAM', 'SAMSUNG', 'Z005', '124718', 'DIS', '124718-124865-US60'));
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124718 - SAMSUNG', 'SAM', 'SAMSUNG', 'Z005', '124718', 'DIS', '124718-124867-US60'));
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124719 - SAMSUNG', 'SAM', 'SAMSUNG', 'Z005', '124719', 'EMS', '124719-124866-US60'));
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124719 - SAMSUNG', 'SAM', 'SAMSUNG', 'Z005', '124719', 'EMS', '124719-124867-US60'));
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124864 - SAMSUNG', '', '#N/A', 'Z002', '124864', 'OEM', '124864-124864-US60'));
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124865 - SAMSUNG', '', '#N/A', 'Z002', '124865', 'DIS', '124865-124865-US60'));
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124866 - SAMSUNG', '', '#N/A', 'Z002', '124866', 'EMS', '124866-124866-US60'));
        lstSAPCustomer.add(GSASTestUtility.createSAPCustomer('124867 - SAMSUNG', '', '#N/A', 'Z002', '124867', '', '124867-124867-US60'));
        insert lstSAPCustomer;        
    }
        
 /*  public static void createTestData() {
        Opportunity opp = createTestDataWithoutFFC();
        //create fulfillment channel
        List<Opportunity_Channel__c> lstFulfillmentChannel = new List<Opportunity_Channel__c>();
        List<SAP_Customer__c> lstSoldTo = 
            [Select Id, Name, CACC__c, CACC_Description__c, Group__c, Group_Description__c, Funloc__c, 
                Channel__c, Unique_Key__c 
                From SAP_Customer__c 
                Where CACC_Description__c like '%Samsung%' and Group__c in ('Z001', 'Z005', 'Z011', 'Z012')  order by Unique_Key__c
            ];
        for(SAP_Customer__c soldTo : lstSoldTo) {
            List<String> lstUniqueKey = soldTo.Unique_Key__c.split('-');
            String strShipToFunloc = lstUniqueKey[1];
            List<SAP_Customer__c> lstShipTo =
                [Select Id, Name, CACC__c, CACC_Description__c, Group__c, Group_Description__c, Funloc__c, 
                    Channel__c, Unique_Key__c 
                    From SAP_Customer__c 
                    Where funloc__c =: strShipToFunloc and Group__c not in ('Z001', 'Z005', 'Z011', 'Z012', 'ZORG')                    
                ];
            for(SAP_Customer__c shipTo : lstShipTo) {
                Opportunity_Channel__c channel = createFulfillmentChannel(opp.Id, soldTo.Id, shipTo.Id, soldTo.Channel__c);
                lstFulfillmentChannel.add(channel);
            }
        }
        insert lstFulfillmentChannel;
  } */
  
    public static void updateOpportunityCloseDate() {
        Opportunity opp = [Select Id, CloseDate from Opportunity Where Name like 'test opportunity%' limit 1];
        opp.CloseDate = Date.valueOf((Date.today().year()+1) + '-05-10');
        update opp;
    }
    
   public static User createUser(String strName, String strEmail, String strAlias)
   {
    Profile objProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
    User objUser = new User(alias = strAlias, email=strEmail, emailencodingkey='UTF-8', lastname=strName, languagelocalekey='en_US', localesidkey='en_US', 
                                 profileid = objProfile.Id, timezonesidkey='America/Los_Angeles', username= strEmail);
                                 
    return objUser;
   }
    
   public static Consolidated_Account_Code__c createCACC(String strName, String strCode) {
    Consolidated_Account_Code__c caccCode = new Consolidated_Account_Code__c();
        caccCode.Code_Description__c = strName;
        caccCode.Name = strCode;
    return caccCode;        
    }
    
    public static Account createParentAccount(String strName, String strRegion, String NXPGlobalId) {
        //get parent account RecordType
        /*
        RecordType parentAccountType = new RecordType();
        List<RecordType> lstRecordType = [Select Id, Name from RecordType Where Name = 'Parent Account'];
        for(RecordType recType : lstRecordType) {
            if (recType.Name == 'Parent Account')
                parentAccountType = recType;
        }*/
        Account parentAcc = new Account();
        parentAcc.Name = strName;
        parentAcc.RecordTypeId = '01220000000E4JaAAK';//parentAccountType.Id;
        //parentAcc.CACC_Description__c = strCaccCodeId;
        parentAcc.NXP_Global_ID__c = NXPGlobalId;
        parentAcc.Region__c = strRegion;
        parentAcc.Auto_Update_Fulfillment_Channel_by_CACC__c = true;
    return parentAcc;
    }
    
    public static Account createChildAccount(String strName, String strRegion, String parentAccountId) {
        //get parent account/child account RecordType
        /*
        RecordType childAccountType = new RecordType();
        List<RecordType> lstRecordType = [Select Id, Name from RecordType Where Name = 'Child Account'];
        for(RecordType recType : lstRecordType) {
            if (recType.Name == 'Child Account')
                childAccountType = recType;
        }*/
        Account childAcc = new Account();
        childAcc.Name = strName;
        childAcc.Region__c = strRegion;
        childAcc.RecordTypeId = '01220000000E4JYAA0';//childAccountType.Id;
        childAcc.ParentId = parentAccountId;
    return childAcc;
    }
    
    public static Approvers_Matrix__c createApproversMatrix(String strUserId, String strRegion, String strType) {
        Approvers_Matrix__c approver = new Approvers_Matrix__c();
        approver.Approver__c = strUserId;
        approver.criteria_2__c = strRegion;
        approver.Type__c = strType;
        approver.Threshold_1__c = 0;
        return approver;
    }
    
    public static Opportunity createOpportunity(String strName, String strAccountId, String strChannel, 
                                                String strProductionDate, String strCloseDate, String strStageName) {
         //RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'SFDC_Oppty' and IsActive=true Limit 1];
        Opportunity opp = new Opportunity();
        opp.Name = strName;
        opp.AccountId = strAccountId;
        opp.Channel__c = strChannel;
        opp.Production_Date__c = Date.valueOf(strProductionDate);
        opp.CloseDate = Date.valueOf(strCloseDate);
        opp.StageName = strStageName;
        //opp.RecordTypeId = RecType.Id ;
        //opp.Top_10_BU__c = 'BU Automotive';
        opp.Locked_Exchange_Rate__c = 1;
        opp.X2016_Pieces__c = 1;    // Added by Jason Tsai on June 2, 2016. Total Opportunity Yearly Pieces must be greater than 0.                                           
        return opp;
    }
    
    public static SAP_Customer__c createSAPCustomer(String strName, String strCACC, String strCACCDescription,
                                            String strGroup, String strFunloc, String strChannel,
                                            String strUniqueKey) {
        SAP_Customer__c funloc = new SAP_Customer__c();
        funloc.Name = strName;
        funloc.CACC__c = strCACC;
        funloc.CACC_Description__c = strCACCDescription;
        funloc.Group__c = strGroup;
        funloc.Funloc__c = strFunloc;
        funloc.Channel__c = strChannel;
        funloc.Unique_Key__c = strUniqueKey;
        return funloc;
    }
    
  /*  public static Opportunity_Channel__c createFulfillmentChannel(String strOpportunityId, 
      String strSoldToId, String strShipToId, String strType) {
        Opportunity_Channel__c channel = new Opportunity_Channel__c();
        channel.Opportunity__c = strOpportunityId;
        if (strType == 'OEM') {
            channel.Fullfillment_Channel_Type__c = 'NXP - OEM';
            channel.OEM_Sold_To__c = strSoldToId;
            channel.OEM_Ship_To__c = strShipToId;           
        } else if (strType == 'DIS') {
            channel.Fullfillment_Channel_Type__c = 'NXP - Disti - OEM';
            channel.DIS_Sold_To__c = strSoldToId;
            channel.DIS_Ship_To__c = strShipToId;                       
        } else if (strType == 'EMS') {
            channel.Fullfillment_Channel_Type__c = 'NXP - EMS';
            channel.EMS_Sold_To__c = strSoldToId;
            channel.EMS_Ship_To__c = strShipToId;           
        }
        return channel;
    } */
    
    public static Customer__c createCustomer()
    {
        /*
        RecordType globalCustomer = new RecordType();
        List<RecordType> lstRecordType = [Select Id, Name from RecordType Where Name = 'NXP Ultimate Parent'];
        for(RecordType recType : lstRecordType) {
            if (recType.Name == 'NXP Ultimate Parent')
                globalCustomer = recType;
        }*/
        Customer__c objCustomer = new Customer__c(RecordTypeId = '012D0000000kW93IAE', Account_Name__c = 'Samsung',
                                        Legal_Name__c = 'Samsung', DUNS__c = 'ut_123', 
                                        Status__c = 'Active' ,  DNB_Verified__c = 'D&B Accepted' ,
                                        House_Number__c = 'ut', Street__c = 'ut_street_1',
                                        City__c = 'ut_city', Country__c = 'ANDORRA', 
                                        Zip__c = 'ut_zip', Industry_Segment__c = 'Computing' ,
                                        Type__c = 'Customer' , Role__c = 'OEM',GSM_Classification__c = 'Global',
                                        Fulfillment_Channel__c = 'Disti', Sales__c = true,Street_2__c = 'ut_street_2',
                                        Street_3__c = 'ut_street_3' ,State__c = 'test',Industry_Sub_Segment__c = 'F1 - Desktop',
                                        SIC_Code__c = 't1', NAICS_Code__c = 'ut', 
                                        Website__c = 'http://www.test.com', EMail__c  = 'test.test12345@test.com',
                                        Fax__c = '+1234567890', Telephone__c = '+1234567890', Consolidated_Account_Code__c = 'SAM');                                            
        insert objCustomer;
        return objCustomer;
    }
}