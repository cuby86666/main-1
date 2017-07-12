/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
public class StarAccessScannerTest 
{
    private static UserRole createUserRole(String strName)
    {
        UserRole objUserRole = new UserRole( Name = strName );
        return objUserRole;
    }

    private static UserRole createUserRole(String strName, String parentRoleId)
    {
//        UserRole parentRole = [SELECT Id, Name FROM UserRole WHERE Name=:parentRoleName];        
        UserRole objUserRole = new UserRole( Name = strName, ParentRoleId = parentRoleId );
        return objUserRole;
    }
    
    private static User createUser(String strName, String strEmail, String strAlias, 
                                   String userRoleId, String profileName, boolean signedARIA )
    {
        //UserRole userRole = [SELECT Id, Name FROM UserRole WHERE Name=:userRoleName];        
        Profile prof = [SELECT Id,Name FROM Profile WHERE Name=:profileName];        
        User objUser = new User(Signed_ARIA__c = signedARIA, alias = strAlias, email=strEmail,emailencodingkey='UTF-8', lastname=strName,languagelocalekey='en_US',localesidkey='en_US',userRoleId=userRoleId,profileId = prof.Id,timezonesidkey='America/Los_Angeles',username= strEmail);
        return objUser;
    }   

    private static Account createParentAccount(String strName, String strRegion /*, String strCaccCodeId*/) 
    {
        RecordType parentAccountType = new RecordType();
        List<RecordType> lstRecordType = [Select Id, Name from RecordType Where Name = 'Parent Account'];
        for(RecordType recType : lstRecordType) 
        {
            if (recType.Name == 'Parent Account')
            parentAccountType = recType;
         }
         Account parentAcc = new Account();
         parentAcc.Name = strName;
         parentAcc.RecordTypeId = parentAccountType.Id;
//         parentAcc.CACC_Description__c = strCaccCodeId;
         parentAcc.Region__c = strRegion;
         return parentAcc;
    }
    
    private static Account createChildAccount(String strName, String strRegion, String parentAccountId) 
    {
        RecordType childAccountType = new RecordType();
        List<RecordType> lstRecordType = [Select Id, Name from RecordType Where Name = 'Child Account'];
        for(RecordType recType : lstRecordType) 
        {
            if (recType.Name == 'Child Account')
            childAccountType = recType;
        }
        Account childAcc = new Account();
        childAcc.Name = strName;
        childAcc.Region__c = strRegion;
        childAcc.RecordTypeId = childAccountType.Id;
        childAcc.ParentId = parentAccountId;
        return childAcc;
    }

    private static Approvers_Matrix__c createApproversMatrix(String strUserId, String strRegion, String strType)
    {
        Approvers_Matrix__c approver = new Approvers_Matrix__c();
        approver.Approver__c = strUserId;
        approver.criteria_2__c = strRegion;
        approver.Type__c = strType;
        approver.Threshold_1__c = 0;
        return approver;
    }

    private static Opportunity createOpportunity(String strName, String strAccountId, /*String strUserId,*/
                                                String strIndustrySegment, String strSubSegment, 
                                                String strChannel, String strProductionDate,
                                                String strCloseDate, String strStageName) 
    {
        Opportunity opp = new Opportunity();
        opp.Name = strName;
        opp.AccountId = strAccountId;
//        opp.OwnerId = strUserId;
        opp.Industry_Segment__c = strIndustrySegment;
        opp.Sub_Segment__c = strSubSegment;
        opp.Channel__c = strChannel;
        opp.Production_Date__c = Date.valueOf(strProductionDate);
        opp.CloseDate = Date.valueOf(strCloseDate);
        opp.StageName = strStageName;
        return opp;
    }      
    
    private static void createOpportunityShare(String strOpportunityId, String strUserId,
                                              String strAccessLevel, String strRowCause)
    {
        OpportunityShare newShare = new OpportunityShare(OpportunityId=strOpportunityId, UserOrGroupId=strUserId,
                                                        OpportunityAccessLevel=strAccessLevel, RowCause=strRowCause);
        insert newShare;
    }    

   

    static testMethod void StarAccessScannerTest1() 
    {
    
        Account parentAcc = createParentAccount('STAR', 'Americas' /*, caccCode.Id*/);
        insert parentAcc;
        system.assert(parentAcc.Id != null);
        List<Account> lstAccount = [Select Id, Name from Account Where RecordType.Name = 'Parent Account'];
        if (lstAccount.size() > 0) 
        parentAcc = lstAccount[0];
        Account childAcc = createChildAccount('STAR', 'Americas', parentAcc.Id);
        insert childAcc;
        system.assert(childAcc.Id != null); 
        lstAccount = [Select Id, Name from Account Where RecordType.Name = 'Child Account'];
        if (lstAccount.size() > 0) 
        childAcc = lstAccount[0];

        UserRole svpRole = createUserRole('SVP');
//        insert svpRole;
        UserRole amecRole = createUserRole('AMEC',svpRole.Id);
//        insert amecRole;
        User regionalVP = createUser('Regional VP', 'regionalvp@nxp.com', 'RVP1',svpRole.Id,'NXP Sales', True);
        insert regionalVP;
        User regionalController = createUser('Regional Controller', 'regionalctrl@nxp.com', 'RCtrl',amecRole.Id,'NXP Sales', True);
        insert regionalController;
        
        List<User> lstUser = [Select Id, Name from User Where Name in ('Regional VP', 'Regional Controller')];
        for(User u : lstUser) 
        {
            if (u.Name == 'Regional VP') regionalVP = u;
            if (u.Name == 'Regional Controller') regionalController = u;
        }
        
        Approvers_Matrix__c approverRVP = createApproversMatrix(regionalVP.Id, 'Americas', 'Regional VP');
        insert approverRVP;
        Approvers_Matrix__c approverRCtrl = createApproversMatrix(regionalController.Id, 'Americas', 'Regional Controller');
        insert approverRCtrl;

        Opportunity opp = createOpportunity('test opportunity', childAcc.Id, /*regionalController.Id, */
                                            'Mobile','Mobile ', 'Direct', '2015-06-02','2015-05-22','Decision');
        insert opp;
        List<Opportunity> lstOpp = [Select Id, Name from Opportunity where Name = 'test opportunity'];
        opp = lstOpp[0];
        
        createOpportunityShare(opp.Id, regionalController.Id, 'Edit', 'Manual');

        StarAccessScanner theStarAccessScanner = new StarAccessScanner();
        Database.executeBatch(theStarAccessScanner, 500);
    }        
}