/******************************************************************************
@LastModified By :  Scarlett Kang
@Modified Date :   29 Apr 2015
@Description :     Need to fetch Requester SFDC if request submitter has SFDC account
********************************************************************************/
/******************************************************************************
@LastModified By :  Stan Hsu
@Modified For :   Release 2015.08 SIR#268
@Description :    Fix the issue where user re-click the verification email
@                   may cause the approved request to go into approval again
********************************************************************************/
/******************************************************************************
@LastModified By :  Scarlett Kang
@Modified For :   Release 2015.09 SIR#209
@Description :    Industry Segment & Sub Segment Picklist update for Industry Segment Alignment
********************************************************************************/
/******************************************************************************
@LastModified By :  Scarlett Kang
@Modified For :   Release 2015.010 SIR#493
@Description :    Industry Sub Segment Picklist update (Add new picklist value)
********************************************************************************/
/******************************************************************************
@LastModified By :  Scarlett Kang
@Modified For :   2016.02 Hot-fix SIR#741
@Description :    Not able to submit Account Edit Request
********************************************************************************/
/******************************************************************************
@LastModified By :  Vinanthi
@Modified For :   Release 2016.05  SIR#2
@Description :    Change State/province field from freetext to picklist
********************************************************************************/
/******************************************************************************
@Modified By :       Shridevi Badiger
@Modified Date:       6 Jun 2016
@Description:        To make sales Area field optional for New SFDC Child Account as part of SIR 866.
********************************************************************************/
/******************************************************************************
@Modified By :  Scarlett Kang
@Modified For : SIR 1013
@Description :  Update New Sub CBG on Account request form
********************************************************************************/
/*****************************************************************************************
@Modified By :   Anil Somani
@Modified Date:  15 Feb 2018
@Description:    Validation done for "Street" & "City" field as part of SFDC-1369 & SFDC-731. 
*******************************************************************************************/

public without sharing class CMD_Request_Controller
{
    private static final string WEB_FORM_URL = 'http://nxpsemiconductors.force.com/cmd';
//    private static final string WEB_FORM_URL = 'http://full-nxpsemiconductors.cs83.force.com/cmd';
//    private static final string WEB_FORM_URL = 'http://gsas-nxpsemiconductors.cs83.force.com/cmd';

    private static final string SFDC_INSTANCE_URL = 'https://nxp.my.salesforce.com/';
//    private static final string SFDC_INSTANCE_URL = 'https://nxp--full.cs83.my.salesforce.com/';
//private static final string SFDC_INSTANCE_URL = 'https://nxp--gsas.cs83.my.salesforce.com/';

    private static final string NEW_SFDC_PARENT_ACCOUNT = 'New_SFDC_Parent_Account';
    private static final string NEW_SFDC_CHILD_ACCOUNT = 'New_SFDC_Child_Account';
    private static final string EDIT_SFDC_PARENT_ACCOUNT = 'Edit_SFDC_Parent_Account';
    private static final string EDIT_SFDC_CHILD_ACCOUNT = 'Edit_SFDC_Child_Account';

    private static final string NEW_SAP_RECORD_TYPE_ID = '012M00000000QgaIAE' ;
    private static final string NEW_SFDC_PARENT_ACCOUNT_RECORD_TYPE_ID = '012D0000000QjYHIA0' ;
    private static final string EDIT_SFDC_PARENT_ACCOUNT_RECORD_TYPE_ID = '012D0000000QjYMIA0' ;
    private static final string NEW_SFDC_CHILD_ACCOUNT_RECORD_TYPE_ID = '012D0000000QjYRIA0' ;
    private static final string EDIT_SFDC_CHILD_ACCOUNT_RECORD_TYPE_ID = '012D0000000QjYWIA0' ;
    
    private static RecordType newSfdcParentAccountRecordType = new RecordType();
    private static RecordType editSfdcParentAccountRecordType = new RecordType();
    private static RecordType newSfdcChildAccountRecordType = new RecordType();
    private static RecordType editSfdcChildAccountRecordType = new RecordType();

    public CMD_Request__c CMD {get;set;}
    public CMD_Request__c objCMDreq{get;set;}
    public string source {get;set;}
    public boolean Submitted {get;set;}
    public string RequesterValidation {get;set;}  
    private string VerificationCode {get;set;}   
    public string VerificationCodeInput {get;set;}
    public boolean VerificationCodeInvalid {get;set;}
    public string rType {get;set;}
    public boolean Verified {get;set;}
    public boolean requestAlreadyProcessed {get;set;}
    public string RequestId {get;set;}
    public string UserId {get;set;}
    public boolean managersValidated {get;set;}
    public boolean requiredValidated {get;set;}
    public boolean InternalUserSubmission {get;set;}
    
    public string RequestType {get;set;}
    public string RecordTypeId {get;set;}

    public string Requester_Name {get;set;}
    public string Requester_Email {get;set;}
    private User Requester_SFDC {get;set;}
    public string New_Owner_Name {get;set;}
    public string New_Owner_Email {get;set;}
    private User New_Owner_SFDC {get;set;}
    public string New_Owner_Validation {get;set;}

    public string AccountId {get;set;}
    private Account Edited_Account;
    public string NXP_Global_ID {get;set;}
    private Customer__c Edited_Customer {get;set;}
    public string Edited_Customer_Id {get;set;}

    public string SP_Account_Name {get;set;}
    public string SP_Name_2 {get;set;}
    public string SP_House_Number {get;set;}
    public string SP_Street {get;set;}
    public string SP_City {get;set;}
    public string SP_ZIP {get;set;}
    public string SP_Country {get;set;}
    public string SP_POBox {get;set;}
    public string SP_Email {get;set;}
    public string SP_VAT_Registration_Number {get;set;}

    public string SH_Account_Name {get;set;}
    public string SH_Name_2 {get;set;}
    public string SH_House_Number {get;set;}
    public string SH_Street {get;set;}
    public string SH_City {get;set;}
    public string SH_ZIP {get;set;}
    public string SH_Country {get;set;}
    public string SH_Region {get;set;}
    public string SH_Transportation_Zone {get;set;}

    public string BP_Account_Name {get;set;}
    public string BP_Name_2 {get;set;}
    public string BP_House_Number {get;set;}
    public string BP_Street {get;set;}
    public string BP_City {get;set;}
    public string BP_ZIP {get;set;}
    public string BP_Country {get;set;}
    public string BP_Region {get;set;}
    public string BP_POBox {get;set;}

    public string PY_Account_Name {get;set;}
    public string PY_Name_2 {get;set;}
    public string PY_House_Number {get;set;}
    public string PY_Street {get;set;}
    public string PY_City {get;set;}
    public string PY_ZIP {get;set;}
    public string PY_Country {get;set;}
    public string PY_Email {get;set;}
    public string PY_POBox {get;set;}

    public string Sales_Organization {get;set;}
    public string Sales_Office {get;set;}
    public string BP_Funloc {get;set;}
    public string PY_Funloc {get;set;}
    public string SMO_Indicator {get;set;}
    public string EDI_Customer {get;set;}

    public string Predict_Sales_Amount {get;set;}
    public string Business_Background {get;set;}

    public string Account_Name {get;set;}
    public boolean Account_Name_Invalid {get;set;}
    public boolean Account_Name_too_Long {get;set;}
    public string Legal_Name {get;set;}
    public boolean Legal_Name_Invalid {get;set;}

    public string Parent_Account_Name {get;set;}
    public boolean Parent_Account_Name_Empty {get;set;}
    public string Parent_Account_GID {get;set;}
    public boolean Parent_Account_GID_Invalid {get;set;}
    public string ParentId {get;set;}
    public Customer__c NUP {get;set;}

    public string DUNS {get;set;}
    public string House_Number {get;set;}
    public boolean House_Number_too_Long {get;set;}
    public string Street {get;set;}
    public boolean Street_empty {get;set;}
    public boolean Street_too_Long {get;set;}
    public string Street_2 {get;set;}
    public boolean Street_2_too_Long {get;set;}
    public string Street_3 {get;set;}
    public boolean Street_3_too_Long {get;set;}
    public string City {get;set;}
    public boolean City_empty {get;set;}
    public boolean City_too_Long {get;set;}
    public string State {get;set;}
    public string Country {get;set;}
    public boolean Country_Empty {get;set;}
    public string Postal_Code {get;set;}

    public string Website {get;set;}
    //added Website_Empty variable by GHANALINGAMURTHY
    public boolean Website_Empty {get;set;}
    public string Email {get;set;}
    public boolean Email_invalid {get;set;}
    public string Telephone {get;set;}
    public string Fax {get;set;}

    public string Fulfillment_Channel {get;set;}
    public boolean Fulfillment_Channel_Empty {get;set;}
    public string Customer_Category {get;set;}
    public boolean Customer_Category_Empty {get;set;}
    public string Role {get;set;}
    public boolean Role_Empty {get;set;}
    public String Type {get;set;}
    public string Industry_Segment {get;set;}
    public boolean Industry_Segment_Empty {get;set;}
    public string Industry_Sub_Segment {get;set;}
    public boolean Industry_Sub_Segment_Empty {get;set;}
    public string Region {get;set;}
    public boolean Region_Empty {get;set;}
    public string Sales_Area {get;set;}
    public boolean Sales_Area_Empty {get;set;}
    public boolean Automotive_OEM {get;set;}
    
    public string Background_of_This_Request {get;set;}
    public boolean Background_of_This_Request_Empty {get;set;}
        
    public string AM_AMEC {get;set;}
    public string AM_EMEA {get;set;}
    public string AM_GC {get;set;}
    public string AM_Japan {get;set;}
    public string AM_Korea {get;set;}
    public string AM_Korea_2 {get;set;}
    public string AM_SAP {get;set;}
    public string AM_SAP_2 {get;set;}
    public string AM_SAP_3 {get;set;}

    public string SM_AMEC {get;set;}
    public string SM_EMEA {get;set;}
    public string SM_GC {get;set;}
    public string SM_Japan {get;set;}
    public string SM_Korea {get;set;}
    public string SM_Korea_2 {get;set;}
    public string SM_SAP {get;set;}
    public string SM_SAP_2 {get;set;}
    public string SM_SAP_3 {get;set;}

    public string AM_AMEC_Validation {get;set;}  
    public string AM_EMEA_Validation {get;set;}  
    public string AM_GC_Validation {get;set;}  
    public string AM_Japan_Validation {get;set;}  
    public string AM_Korea_Validation {get;set;}  
    public string AM_Korea_2_Validation {get;set;}
    public string AM_SAP_Validation {get;set;}  
    public string AM_SAP_2_Validation {get;set;}
    public string AM_SAP_3_Validation {get;set;}

    public string SM_AMEC_Validation {get;set;}
    public string SM_EMEA_Validation {get;set;}
    public string SM_GC_Validation {get;set;}
    public string SM_Japan_Validation {get;set;}
    public string SM_Korea_Validation {get;set;}
    public string SM_Korea_2_Validation {get;set;}
    public string SM_SAP_Validation {get;set;}  
    public string SM_SAP_2_Validation {get;set;}
    public string SM_SAP_3_Validation {get;set;}
/******
    private void fetchNewSfdcParentAccountRecordType()
    {
        for( RecordType nprt : 
            [   
                Select Id, DeveloperName
                From RecordType
                WHERE SobjectType = 'CMD_Request__c' 
                AND DeveloperName = :NEW_SFDC_PARENT_ACCOUNT
                AND IsActive=true
                Limit 1
            ]
        )
        {
            newSfdcParentAccountRecordType = nprt;
        }    
    }

    private void fetchEditSfdcParentAccountRecordType()
    {
        for( RecordType eprt : 
            [   
                Select Id, DeveloperName
                From RecordType
                WHERE SobjectType = 'CMD_Reuqest__c' 
                AND DeveloperName = :EDIT_SFDC_PARENT_ACCOUNT 
                AND IsActive=true
                Limit 1
            ]
        )
        {
            editSfdcParentAccountRecordType = eprt;
        }    
    }

    private void fetchNewSfdcChildAccountRecordType()
    {
        for( RecordType ncrt : 
            [   
                Select Id, DeveloperName
                From RecordType
                WHERE SobjectType = 'CMD_Reuqest__c' 
                AND DeveloperName = :NEW_SFDC_CHILD_ACCOUNT 
                AND IsActive=true
                Limit 1
            ]
        )
        {
            newSfdcChildAccountRecordType = ncrt;
        }    
    }

    private void fetchEditSfdcChildAccountRecordType()
    {
        for( RecordType ecrt : 
            [   
                Select Id, DeveloperName
                From RecordType
                WHERE SobjectType = 'CMD_Reuqest__c' 
                AND DeveloperName = :EDIT_SFDC_CHILD_ACCOUNT 
                AND IsActive=true
                Limit 1
            ]
        )
        {
            editSfdcChildAccountRecordType = ecrt;
        }    
    }
*****/
public void CMDMethodForConstructor()
{
    CMD = new CMD_Request__c();
        Submitted = false;
        VerificationCodeInvalid = false ;
        RequesterValidation = null;
        New_Owner_Validation = null;
        source = ApexPages.CurrentPage().getParameters().get('src');
        if( source != null && source != '' ) 
            InternalUserSubmission = true; // for controlling the page display
        else
            InternalUserSubmission = false;
        RequestType = ApexPages.CurrentPage().getParameters().get('rt');
        RequestId = ApexPages.CurrentPage().getParameters().get('rid');
        UserId = ApexPages.CurrentPage().getParameters().get('uid');
        Requester_Name = ApexPages.CurrentPage().getParameters().get('rn');
        Requester_Email = ApexPages.CurrentPage().getParameters().get('re');
        RecordTypeId = ApexPages.CurrentPage().getParameters().get('rtid');
        AccountId = ApexPages.CurrentPage().getParameters().get('aid');
        if( AccountId != null )
        {
            Edited_Account = fetchAccount( AccountId ); 
            if( Edited_Account.NXP_GID__c != null )
            {
                Edited_Customer = queryCustomerId( Edited_Account.NXP_GID__c );
                Edited_Customer_Id = String.valueOf( Edited_Customer.Id );   
            }
        }
        Parent_Account_Name = ApexPages.CurrentPage().getParameters().get('pn');
        Parent_Account_GID = ApexPages.CurrentPage().getParameters().get('pgid');
        if( Parent_Account_GID != null )
            NUP = queryCustomerId( Parent_Account_GID );
            
        ParentId = ApexPages.CurrentPage().getParameters().get('pid');
        Account_Name = ApexPages.CurrentPage().getParameters().get('an'); 
        Legal_Name = ApexPages.CurrentPage().getParameters().get('ln'); 
        DUNS = ApexPages.CurrentPage().getParameters().get('duns'); 
        House_Number = ApexPages.CurrentPage().getParameters().get('hn'); 
        Street = ApexPages.CurrentPage().getParameters().get('s1'); 
        Street_2 = ApexPages.CurrentPage().getParameters().get('s2'); 
        Street_3 = ApexPages.CurrentPage().getParameters().get('s3'); 
        City = ApexPages.CurrentPage().getParameters().get('ct'); 
        State = ApexPages.CurrentPage().getParameters().get('st'); 
        Country = ApexPages.CurrentPage().getParameters().get('cntry'); 
        Postal_Code = ApexPages.CurrentPage().getParameters().get('zip'); 
        Website = ApexPages.CurrentPage().getParameters().get('web'); 
        Email = ApexPages.CurrentPage().getParameters().get('em'); 
        Telephone = ApexPages.CurrentPage().getParameters().get('tp'); 
        Fax = ApexPages.CurrentPage().getParameters().get('fx'); 
        Fulfillment_Channel = ApexPages.CurrentPage().getParameters().get('fc'); 
        Customer_Category = ApexPages.CurrentPage().getParameters().get('cc');
        Role = ApexPages.CurrentPage().getParameters().get('rl'); 
        Type = ApexPages.CurrentPage().getParameters().get('typ');
        Industry_Segment = ConvertIndustryCode(ApexPages.CurrentPage().getParameters().get('is')); 
        Industry_Sub_Segment = ConvertSubSegmentCode(ApexPages.CurrentPage().getParameters().get('ss')); 
        Region = ConvertRegionCode(ApexPages.CurrentPage().getParameters().get('reg')); 
        Sales_Area = ApexPages.CurrentPage().getParameters().get('sa');
        if (ApexPages.CurrentPage().getParameters().get('ao') != null) 
            Automotive_OEM = Boolean.valueOf(ApexPages.CurrentPage().getParameters().get('ao'));
        else
            Automotive_OEM = false;
        
        AM_AMEC = ApexPages.CurrentPage().getParameters().get('aam'); 
        AM_EMEA = ApexPages.CurrentPage().getParameters().get('aeu'); 
        AM_GC = ApexPages.CurrentPage().getParameters().get('agc'); 
        AM_Japan = ApexPages.CurrentPage().getParameters().get('ajp'); 
        AM_Korea = ApexPages.CurrentPage().getParameters().get('akr'); 
        AM_Korea_2 = ApexPages.CurrentPage().getParameters().get('akr2'); 
        AM_SAP = ApexPages.CurrentPage().getParameters().get('asa'); 
        AM_SAP_2 = ApexPages.CurrentPage().getParameters().get('asa2'); 
        AM_SAP_3 = ApexPages.CurrentPage().getParameters().get('asa3'); 
        SM_AMEC = ApexPages.CurrentPage().getParameters().get('sam'); 
        SM_EMEA = ApexPages.CurrentPage().getParameters().get('seu'); 
        SM_GC = ApexPages.CurrentPage().getParameters().get('sgc'); 
        SM_Japan = ApexPages.CurrentPage().getParameters().get('sjp'); 
        SM_Korea = ApexPages.CurrentPage().getParameters().get('skr'); 
        SM_SAP = ApexPages.CurrentPage().getParameters().get('ssa'); 
        
        AM_AMEC_Validation = null;
        AM_EMEA_Validation = null;
        AM_GC_Validation = null;
        AM_Japan_Validation = null;
        AM_Korea_Validation = null;
        AM_Korea_2_Validation = null;
        AM_SAP_Validation = null;
        AM_SAP_2_Validation = null;
        AM_SAP_3_Validation = null;
        
        SM_AMEC_Validation = null;
        SM_EMEA_Validation = null;
        SM_GC_Validation = null;
        SM_Japan_Validation = null;
        SM_Korea_Validation = null;
        SM_Korea_2_Validation = null;
        SM_SAP_Validation = null;
        SM_SAP_2_Validation = null;
        SM_SAP_3_Validation = null;
        checkRequestType();
}
public CMD_Request_Controller()
{
     CMDMethodForConstructor();
}

    public CMD_Request_Controller(ApexPages.StandardController controller)
    {
    // code added by vinanthi
    objCMDreq=new CMD_Request__c();
  objCMDreq=(CMD_Request__c)controller.getRecord();
     // code added by vinanthi ends  
        CMDMethodForConstructor();
       /*
        CMD = new CMD_Request__c();
        Submitted = false;
        VerificationCodeInvalid = false ;
        RequesterValidation = null;
        New_Owner_Validation = null;
        source = ApexPages.CurrentPage().getParameters().get('src');
        if( source != null && source != '' ) 
            InternalUserSubmission = true; // for controlling the page display
        else
            InternalUserSubmission = false;
        RequestType = ApexPages.CurrentPage().getParameters().get('rt');
        RequestId = ApexPages.CurrentPage().getParameters().get('rid');
        UserId = ApexPages.CurrentPage().getParameters().get('uid');
        Requester_Name = ApexPages.CurrentPage().getParameters().get('rn');
        Requester_Email = ApexPages.CurrentPage().getParameters().get('re');
        RecordTypeId = ApexPages.CurrentPage().getParameters().get('rtid');
        AccountId = ApexPages.CurrentPage().getParameters().get('aid');
        if( AccountId != null )
        {
            Edited_Account = fetchAccount( AccountId ); 
            if( Edited_Account.NXP_GID__c != null )
            {
                Edited_Customer = queryCustomerId( Edited_Account.NXP_GID__c );
                Edited_Customer_Id = String.valueOf( Edited_Customer.Id );   
            }
        }
        Parent_Account_Name = ApexPages.CurrentPage().getParameters().get('pn');
        Parent_Account_GID = ApexPages.CurrentPage().getParameters().get('pgid');
        if( Parent_Account_GID != null )
            NUP = queryCustomerId( Parent_Account_GID );
            
        ParentId = ApexPages.CurrentPage().getParameters().get('pid');
        Account_Name = ApexPages.CurrentPage().getParameters().get('an'); 
        Legal_Name = ApexPages.CurrentPage().getParameters().get('ln'); 
        DUNS = ApexPages.CurrentPage().getParameters().get('duns'); 
        House_Number = ApexPages.CurrentPage().getParameters().get('hn'); 
        Street = ApexPages.CurrentPage().getParameters().get('s1'); 
        Street_2 = ApexPages.CurrentPage().getParameters().get('s2'); 
        Street_3 = ApexPages.CurrentPage().getParameters().get('s3'); 
        City = ApexPages.CurrentPage().getParameters().get('ct'); 
        State = ApexPages.CurrentPage().getParameters().get('st'); 
        Country = ApexPages.CurrentPage().getParameters().get('cntry'); 
        Postal_Code = ApexPages.CurrentPage().getParameters().get('zip'); 
        Website = ApexPages.CurrentPage().getParameters().get('web'); 
        Email = ApexPages.CurrentPage().getParameters().get('em'); 
        Telephone = ApexPages.CurrentPage().getParameters().get('tp'); 
        Fax = ApexPages.CurrentPage().getParameters().get('fx'); 
        Fulfillment_Channel = ApexPages.CurrentPage().getParameters().get('fc'); 
        Customer_Category = ApexPages.CurrentPage().getParameters().get('cc');
        Role = ApexPages.CurrentPage().getParameters().get('rl'); 
        Type = ApexPages.CurrentPage().getParameters().get('typ');
        Industry_Segment = ConvertIndustryCode(ApexPages.CurrentPage().getParameters().get('is')); 
        Industry_Sub_Segment = ConvertSubSegmentCode(ApexPages.CurrentPage().getParameters().get('ss')); 
        Region = ConvertRegionCode(ApexPages.CurrentPage().getParameters().get('reg')); 
        Sales_Area = ApexPages.CurrentPage().getParameters().get('sa');
        if (ApexPages.CurrentPage().getParameters().get('ao') != null) 
            Automotive_OEM = Boolean.valueOf(ApexPages.CurrentPage().getParameters().get('ao'));
        else
            Automotive_OEM = false;
        
        AM_AMEC = ApexPages.CurrentPage().getParameters().get('aam'); 
        AM_EMEA = ApexPages.CurrentPage().getParameters().get('aeu'); 
        AM_GC = ApexPages.CurrentPage().getParameters().get('agc'); 
        AM_Japan = ApexPages.CurrentPage().getParameters().get('ajp'); 
        AM_Korea = ApexPages.CurrentPage().getParameters().get('akr'); 
        AM_Korea_2 = ApexPages.CurrentPage().getParameters().get('akr2'); 
        AM_SAP = ApexPages.CurrentPage().getParameters().get('asa'); 
        AM_SAP_2 = ApexPages.CurrentPage().getParameters().get('asa2'); 
        AM_SAP_3 = ApexPages.CurrentPage().getParameters().get('asa3'); 
        SM_AMEC = ApexPages.CurrentPage().getParameters().get('sam'); 
        SM_EMEA = ApexPages.CurrentPage().getParameters().get('seu'); 
        SM_GC = ApexPages.CurrentPage().getParameters().get('sgc'); 
        SM_Japan = ApexPages.CurrentPage().getParameters().get('sjp'); 
        SM_Korea = ApexPages.CurrentPage().getParameters().get('skr'); 
        SM_SAP = ApexPages.CurrentPage().getParameters().get('ssa'); 
        
        AM_AMEC_Validation = null;
        AM_EMEA_Validation = null;
        AM_GC_Validation = null;
        AM_Japan_Validation = null;
        AM_Korea_Validation = null;
        AM_Korea_2_Validation = null;
        AM_SAP_Validation = null;
        AM_SAP_2_Validation = null;
        AM_SAP_3_Validation = null;
        
        SM_AMEC_Validation = null;
        SM_EMEA_Validation = null;
        SM_GC_Validation = null;
        SM_Japan_Validation = null;
        SM_Korea_Validation = null;
        SM_Korea_2_Validation = null;
        SM_SAP_Validation = null;
        SM_SAP_2_Validation = null;
        SM_SAP_3_Validation = null;
        checkRequestType();
        */
    }
    
    private Account fetchAccount( String AccId )
    {
        List<Account> fetchedAccounts = 
        [
            SELECT  Id, 
                    Name,
                    NXP_GID__c,
                    NXP_GID_GE__c,
                    Legal_Name__c,
                    ParentId,
                    DUNS_Number__c,  
                    House_Number__c,
                    Street__c,
                    Street2__c,
                    Street3__c,
                    City__c,
                    State_Province__c,
                    ZIP_Postal_Code__c,
                    Country__c,
                    Sales_Area__c,
                    Website,
                    Email__c,
                    Phone,
                    Fax,
                    Fulfillment_Channel__c,
                    Customer_Category__c,
                    Role__c,
                    Type,
            /***1602 Hot-dix SIR741 - Modified by Scarlett***/
                    //Industry_Segment__c,            
                    //Sub_Segment__c,
                    CMD_Industry_Segment__c,
                    CMD_Sub_Segment__c,
             /***1602 Hot-dix SIR741 - Modified by Scarlett***/
                    Account_Manager_AMEC__r.Email,
                    Account_Manager_EMEA__r.Email,
                    Account_Manager_GC__r.Email,
                    Account_Manager_Japan__r.Email,
                    Account_Manager_Korea__r.Email,
                    Account_Manager_Korea_2__r.Email,
                    Account_Manager_SAP__r.Email,
                    Account_Manager_SAP_2__r.Email,
                    Account_Manager_SAP_3__r.Email,
                    Service_Manager_AMEC__r.Email,
                    Service_Manager_EMEA__r.Email,
                    Service_Manager_GC__r.Email,
                    Service_Manager_Japan__r.Email,
                    Service_Manager_Korea__r.Email,
                    Service_Manager_SAP__r.Email
            FROM    Account
            WHERE   Id = :AccId 
        ];
        if( fetchedAccounts.size() > 0 )
            return fetchedAccounts[0];
        else 
            return null;
    }
    
    private Customer__c queryCustomerId( string NXP_GID )
    {
        List<Customer__c> queryCustomers = 
        [
            SELECT  Id, Name
            FROM    Customer__c
            WHERE   Name = :NXP_GID 
        ];
        if( queryCustomers .size() > 0 )
            return queryCustomers[0];
        else
            return null;
    }
/**    
    public boolean ValidateRequester()
    {
        string UserQryStr = 'SELECT Id, Email, IsActive, Username FROM User '
                            +'WHERE IsActive = true AND Email = \''
                            + Requester_Email + '\'' ;
        List<User> findUser = Database.query(UserQryStr);
                            
        string RequesterQryStr = 'SELECT Id, Email__c, isActive__c '
                        + 'FROM CMD_Requester__c WHERE isActive__c = true AND Email__c = \''
                        + Requester_Email + '\'' ;
        List<CMD_Requester__c> findRequester = Database.query(RequesterQryStr);

        if( findUser.size() > 0 )
        {
            for( User theUser : findUser )
            {
                if( string.valueOf(theUser.Username).startsWith( string.valueOf(theUser.Email) ) )
                {
                    Requester_SFDC = theUser;
                }   
            } 
        }

        if( Requester_Email != null && ( findUser.size() > 0 || findRequester.size() > 0 ) ) 
        {
            RequesterValidation = 'valid';
            return true;
        }
        else
        {
            RequesterValidation = 'invalid';
            return false;
        }
    }
**/    
    public user ValidateUser( string userEmail )
    {
        string UserQryStr = 'SELECT Id, Email, IsActive, Username FROM User '
                            +'WHERE IsActive = true AND Email = \''
                            + userEmail + '\'' ;
        List<User> findUser = Database.query(UserQryStr);
                            
        if( findUser.size() > 0 )
        {
            User foundUser = new User();
            for( User theUser : findUser )
            {
//                if( string.valueOf(theUser.Email).startsWith( userEmail ) )
//                {
                foundUser = theUser;        
//                }   
            } 
//          return null;
            return foundUser;
        }
        else
        {
            return null;
        }
    }

    private boolean isEmailInvalid( String theEmail ) 
    {
        Boolean flag = false;
        if( theEmail != null ) 
        {
            String  emailRegex   = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
            Pattern emailPattern = Pattern.compile(emailRegex);
            Matcher emailMatcher = emailPattern.matcher(theEmail.trim());
                    flag         = !(emailMatcher.matches());
        }
        return flag;
    }
    
    public List<SelectOption> getCountryPicklist() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Hub_Foundation__c.Country__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }
    
    public List<SelectOption> getFulfillment_ChannelPicklist() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Account.Fulfillment_Channel__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }
    
    public List<SelectOption> getCustomer_CategoryPicklist() {
        List<SelectOption> options = new List<SelectOption>();
//        Schema.DescribeFieldResult F = Customer__c.GSM_Classification__c.getDescribe();
        Schema.DescribeFieldResult F = Account.Customer_Category__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }
    
    public List<SelectOption> getRolePicklist() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Account.Role__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }
    
    public List<SelectOption> getTypePicklist() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Account.Type.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }
    
    public List<SelectOption> getIndustry_SegmentPicklist() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = Customer__c.Industry_Segment__c.getDescribe();
             List<Schema.PicklistEntry> Ple = F.getPicklistValues();
             for(Schema.PicklistEntry p : ple){
                options.add(new SelectOption(p.getlabel(),p.getlabel()));
              }
        return options;
    }
    
    public List<SelectOption> getIndustry_Sub_SegmentPicklist()
    {
        List<SelectOption> options = new List<SelectOption>();
        /***Start - Modified by Scarlett for 2015.09 Release***/
        /*
        if( Industry_Segment == 'AA - Appliances')
        {       
            options.add(new SelectOption('A1 - Major Home Appliances','A1 - Major Home Appliances'));
            options.add(new SelectOption('A2 - Small Domestic Appliances (selective)','A2 - Small Domestic Appliances (selective)'));
            options.add(new SelectOption('A3 - Consumer Power Tool','A3 - Consumer Power Tool'));
        }
        else if( Industry_Segment == 'BB - Energy Management')
        {       
            options.add(new SelectOption('B1 - Smart Energy/Grid','B1 - Smart Energy/Grid'));
            options.add(new SelectOption('B2 - Power Supply','B2 - Power Supply'));
        }
        else if( Industry_Segment == 'CC - Home/Building Automation (HABA)')
        {       
            options.add(new SelectOption('C1 - Building Automation','C1 - Building Automation'));
            options.add(new SelectOption('C2 - Home Automation','C2 - Home Automation'));
            options.add(new SelectOption('C3 - Lighting (including Solid state lighting, etc.)','C3 - Lighting (including Solid state lighting, etc.)'));
            options.add(new SelectOption('C4 - Smart Lighting','C4 - Smart Lighting'));
        }
        else if( Industry_Segment == 'DD - Automotive & Transportation')
        {       
            options.add(new SelectOption('D1 - Body, Safety and Comfort','D1 - Body, Safety and Comfort'));
            options.add(new SelectOption('D2 - Car Infotainment','D2 - Car Infotainment'));
            options.add(new SelectOption('D3 - Chassis','D3 - Chassis'));
            options.add(new SelectOption('D4 - Intelligent transportation systems (ITS)','D4 - Intelligent transportation systems (ITS)'));
            options.add(new SelectOption('D5 - Powertrain','D5 - Powertrain'));
            options.add(new SelectOption('D6 - Telematics','D6 - Telematics'));
            options.add(new SelectOption('D7 - Transportation','D7 - Transportation'));
        }
        else if( Industry_Segment == 'EE - Consumer')
        {       
            options.add(new SelectOption('E1 - TV','E1 - TV'));
            options.add(new SelectOption('E2 - Set Top Box','E2 - Set Top Box'));
            options.add(new SelectOption('E3 - Gaming (Home Gaming Console)','E3 - Gaming (Home Gaming Console)'));
            options.add(new SelectOption('E4 - Home Audio','E4 - Home Audio'));
            options.add(new SelectOption('E5 - Portable','E5 - Portable'));
            options.add(new SelectOption('E6 - Others (DVD/BR, Music Instruments, Specialty TV)','E6 - Others (DVD/BR, Music Instruments, Specialty TV)'));
        }
        else if( Industry_Segment == 'FF - Computing')
        {       
            options.add(new SelectOption('F1 - Desktop','F1 - Desktop'));
            options.add(new SelectOption('F2 - Notebook','F2 - Notebook'));
            options.add(new SelectOption('F3 - Netbook','F3 - Netbook'));
            options.add(new SelectOption('F4 - Ultrabook','F4 - Ultrabook'));
            options.add(new SelectOption('F5 - Server','F5 - Server'));
            options.add(new SelectOption('F6 - Storage','F6 - Storage'));
            options.add(new SelectOption('F7 - Monitor','F7 - Monitor'));
            options.add(new SelectOption('F8 - Printer','F8 - Printer'));
            options.add(new SelectOption('F9 - PC Peripherals (keyboards, mice, webcams)','F9 - PC Peripherals (keyboards, mice, webcams)'));
        }
        else if( Industry_Segment == 'GG - Secure Transactions')
        {       
            options.add(new SelectOption('G1 - Secure transactions - AFC','G1 - Secure transactions - AFC'));
            options.add(new SelectOption('G2 - Secure transactions - Mobile Transaction','G2 - Secure transactions - Mobile Transaction'));
            options.add(new SelectOption('G3 - Secure transactions - Banking','G3 - Secure transactions - Banking'));
            options.add(new SelectOption('G4 - Secure transactions - Infrastructure','G4 - Secure transactions - Infrastructure'));
        }
        else if( Industry_Segment == 'HH - Secure Identity')
        {       
            options.add(new SelectOption('H1 - Secure identity - eGov','H1 - Secure identity - eGov'));
            options.add(new SelectOption('H2 - Secure identity - PayTV','H2 - Secure identity - PayTV'));
        }
        else if( Industry_Segment == 'II - Tagging & Authentication')
        {       
            options.add(new SelectOption('I1 - Tag and Label','I1 - Tag and Label'));
            options.add(new SelectOption('I2 - Authentication','I2 - Authentication'));
        }
        else if( Industry_Segment == 'JJ - Wireless Infrastructure and RF')
        {       
            options.add(new SelectOption('J1 - RF Energy','J1 - RF Energy'));
            options.add(new SelectOption('J2 - Aerospace and Defense','J2 - Aerospace and Defense'));
            options.add(new SelectOption('J3 - Military/Space/Avionics','J3 - Military/Space/Avionics'));
            options.add(new SelectOption('J4 - Base station','J4 - Base station'));
            options.add(new SelectOption('J5 - Broadcast','J5 - Broadcast'));
            options.add(new SelectOption('J6 - CATV','J6 - CATV'));
            options.add(new SelectOption('J7 - ISM','J7 - ISM'));
            options.add(new SelectOption('J8 - Wireless Connectivity','J8 - Wireless Connectivity'));
            options.add(new SelectOption('J9 - Satellite','J9 - Satellite'));
            options.add(new SelectOption('JA - Point-to-point','JA - Point-to-point'));
            options.add(new SelectOption('JB - Broadband Access','JB - Broadband Access'));
            options.add(new SelectOption('JO - Tuning','JO - Tuning'));
        }
        else if( Industry_Segment == 'KK - Mobile')
        {       
            options.add(new SelectOption('K1 - Mobile Handset','K1 - Mobile Handset'));
            options.add(new SelectOption('K2 - Mobile Accessories','K2 - Mobile Accessories'));
            options.add(new SelectOption('K3 - Tablets','K3 - Tablets'));
            options.add(new SelectOption('K4 - Others','K4 - Others'));
        }
        else if( Industry_Segment == 'LL - EMS')
        {       
            options.add(new SelectOption('L1 - EMS','L1 - EMS'));
        }
        else if( Industry_Segment == 'MM - Distribution')
        {       
            options.add(new SelectOption('M1 - Distribution','M1 - Distribution'));
        }
        else if( Industry_Segment == 'NN - Healthcare')
        {       
            options.add(new SelectOption('N1 - Consumer Health Device','N1 - Consumer Health Device'));
            options.add(new SelectOption('N2 - Clinical Health','N2 - Clinical Health'));
            options.add(new SelectOption('N3 - Medical Imaging','N3 - Medical Imaging'));
            options.add(new SelectOption('N4 - Medical Instrumentation','N4 - Medical Instrumentation'));
        }
        else if( Industry_Segment == 'OO - Industrial')
        {       
            options.add(new SelectOption('O1 - Robot','O1 - Robot'));
            options.add(new SelectOption('O2 - industrial machinery','O2 - industrial machinery'));
            options.add(new SelectOption('O3 - Control system','O3 - Control system'));
        }
        */
        
        if( Industry_Segment == 'AA - Automotive'){
            options.add(new SelectOption('A1 - Automotive', 'A1 - Automotive'));
        }
        else if( Industry_Segment == 'BB - C&I'){
            options.add(new SelectOption('B1 - Consumer & HA', 'B1 - Consumer & HA'));
            options.add(new SelectOption('B2 - Gaming', 'B2 - Gaming'));
            options.add(new SelectOption('B3 - Imaging', 'B3 - Imaging'));
            options.add(new SelectOption('B4 - Industrial', 'B4 - Industrial'));
            options.add(new SelectOption('B5 - Lighting', 'B5 - Lighting'));
            options.add(new SelectOption('B6 - Power Supply', 'B6 - Power Supply'));
            options.add(new SelectOption('B7 - White Goods', 'B7 - White Goods'));
            /***1510 Release - SIR 493 - Modified by Scarlett***/
            options.add(new SelectOption('B8 - Healthcare', 'B8 - Healthcare'));
            /***1510 Release - SIR 493 - Modified by Scarlett - END***/
            options.add(new SelectOption('B9 - Smart Home&Building', 'B9 - Smart Home&Building'));//SIR 1013 - Added by Scarlett
        }
        else if( Industry_Segment == 'CC - Computing'){
            options.add(new SelectOption('C1 - Computing', 'C1 - Computing'));
            options.add(new SelectOption('C2 - Computing - Power Supply', 'C2 - Computing - Power Supply'));//SIR 1013 - Added by Scarlett
            options.add(new SelectOption('C3 - Data Center', 'C3 - Data Center'));//SIR 1013 - Added by Scarlett
        }
        else if( Industry_Segment == 'DD - Distribution'){
            options.add(new SelectOption('D1 - Distribution', 'D1 - Distribution'));
        }
        else if( Industry_Segment == 'EE - EMS'){
            options.add(new SelectOption('E1 - EMS', 'E1 - EMS'));
        }
        else if( Industry_Segment == 'FF - Infrastructure'){
            options.add(new SelectOption('F1 - Infrastructure', 'F1 - Infrastructure'));
        }
        else if( Industry_Segment == 'GG - Mobile'){
            options.add(new SelectOption('G1 - Mobile', 'G1 - Mobile'));
        }
        else if( Industry_Segment == 'HH - Payment'){
            options.add(new SelectOption('H1 - Payment', 'H1 - Payment'));
        }
        
        /***End - Modified by Scarlett for 2015.09 Release***/
        return options;
    }    
           
    public List<SelectOption> getRegionPicklist() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult F = CMD_Request__c.Region__c.getDescribe();
            List<Schema.PicklistEntry> Ple = F.getPicklistValues();
            for(Schema.PicklistEntry p : ple){
                if( p.getlabel() != 'AM - Americas' //SAP
                    && p.getlabel() != 'AP - Asia Pacific'  //SAP
                    && p.getlabel() != 'EU - Europe' //SAP
                ) {
                    options.add(new SelectOption(p.getlabel(),p.getlabel()));
                }
            }
        return options;
    }
           
    public List<SelectOption> getSales_AreaPicklist() {
        List<SelectOption> options = new List<SelectOption>();
        if( Region == 'AP - GC')
        {
            options.add(new SelectOption('GC Taiwan','GC Taiwan'));
            options.add(new SelectOption('GC S. China','GC S. China'));
            options.add(new SelectOption('GC N. China','GC N. China'));
            options.add(new SelectOption('GC Wire. Infra.','GC Wire. Infra.'));
            options.add(new SelectOption('GC Foxconn','GC Foxconn'));
            options.add(new SelectOption('GC Automotive','GC Automotive'));
            options.add(new SelectOption('GC Identification','GC Identification'));
            options.add(new SelectOption('GC Mass Market Taiwan','GC Mass Market Taiwan'));
            options.add(new SelectOption('GC Mass Market China','GC Mass Market China'));
        }
        else if (Region == 'AP - SAP')
        {
            options.add(new SelectOption('Singapore','Singapore'));
            options.add(new SelectOption('Malaysia','Malaysia'));
            options.add(new SelectOption('Thailand','Thailand'));
            options.add(new SelectOption('India','India'));
            options.add(new SelectOption('North Vietnam','North Vietnam'));
            options.add(new SelectOption('Vietnam','Vietnam'));
            options.add(new SelectOption('Cambodia','Cambodia'));
            options.add(new SelectOption('Indonesia','Indonesia'));
            options.add(new SelectOption('Philippines','Philippines'));
            options.add(new SelectOption('Australia','Australia'));
            options.add(new SelectOption('New Zealand','New Zealand'));
            options.add(new SelectOption('Others','Others'));      
        }
        else if (Region == 'AM - AMEC')
        {
            options.add(new SelectOption('AUTO','AUTO'));
            options.add(new SelectOption('BAY','BAY'));
            options.add(new SelectOption('CENTRAL','CENTRAL'));
            options.add(new SelectOption('EAST','EAST'));
            options.add(new SelectOption('SIS','SIS'));
            options.add(new SelectOption('STAR','STAR'));
            options.add(new SelectOption('WEST','WEST'));         
        }
        else if (Region == 'EU - EMEA')
        {
            options.add(new SelectOption('AUTO CAR OEM','AUTO CAR OEM'));
            options.add(new SelectOption('AUTO EMEA','AUTO EMEA'));
            options.add(new SelectOption('AUTO EMEA MM','AUTO EMEA MM'));
            options.add(new SelectOption('BOSCH','BOSCH'));
            options.add(new SelectOption('CONTINENTAL','CONTINENTAL'));
            options.add(new SelectOption('EMEA CIS','EMEA CIS'));
            options.add(new SelectOption('EMEA ID Remaining','EMEA ID Remaining'));
            options.add(new SelectOption('EMEA North/Central','EMEA North/Central'));
            options.add(new SelectOption('EMEA South/East','EMEA South/East'));
            options.add(new SelectOption('EMEA Strategic','EMEA Strategic'));
            options.add(new SelectOption('VALEO','VALEO'));
            options.add(new SelectOption('ZF TRW','ZF TRW'));      
        }
        else if (Region == 'AP - JAPAN')
        {
            options.add(new SelectOption('Japan Strategic','Japan Strategic'));
            options.add(new SelectOption('Japan ID','Japan ID'));
            options.add(new SelectOption('Japan Automotive','Japan Automotive'));
            options.add(new SelectOption('Japan HPMS & SP','Japan HPMS & SP'));
        }
        else if (Region == 'AP - KOREA')
        {
            options.add(new SelectOption('Korea','Korea'));
        }
        return options;
    }

           
    public string ValidateManagerEmail( string managerEmailAddress )
    {
        string HubContactQryStr = 'SELECT Id, Email__c '
                        + 'FROM Hub_Contact__c '
                        + 'WHERE Email__c = \''
                        + managerEmailAddress + '\'' ;
        List<Hub_Contact__c> findManager = Database.query(HubContactQryStr);

        if( findManager.size() > 0 ) 
            return 'valid';
        else
            return 'invalid';
    }
    
    public void ValidateManagers()
    {
        integer invalidEmails = 0;
        
        if( AM_AMEC != null && AM_AMEC != '' )
        {
            if( isEmailInvalid( AM_AMEC ) )
            {
                AM_AMEC_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_AMEC_Validation = 'valid';
            }
        } 
        else { AM_AMEC_Validation = null; }

        if( AM_EMEA != null && AM_EMEA != '' )
        {
            if( isEmailInvalid( AM_EMEA ) )
            {
                AM_EMEA_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_EMEA_Validation = 'valid';
            }
        }
        else { AM_EMEA_Validation = null; }

        if( AM_GC != null && AM_GC != '' )
        {
            if( isEmailInvalid( AM_GC ) )
            {
                AM_GC_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_GC_Validation = 'valid';
            }
        }
        else { AM_GC_Validation = null; }

        if( AM_Japan != null && AM_Japan != '' )
        {
            if( isEmailInvalid( AM_Japan ) )
            {
                AM_Japan_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_Japan_Validation = 'valid';
            }
        }
        else { AM_Japan_Validation = null; }

        if( AM_Korea != null && AM_Korea != '' )
        {
            if( isEmailInvalid( AM_Korea ) )
            {
                AM_Korea_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_Korea_Validation = 'valid';
            }
        }
        else { AM_Korea_Validation = null; }

        if( AM_Korea_2 != null && AM_Korea_2 != '' )
        {
            if( isEmailInvalid( AM_Korea_2 ) )
            {
                AM_Korea_2_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_Korea_2_Validation = 'valid';
            }
        }
        else { AM_Korea_2_Validation = null; }

        if( AM_SAP != null && AM_SAP != '' )
        {
            if( isEmailInvalid( AM_SAP ) )
            {
                AM_SAP_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_SAP_Validation = 'valid';
            }
        }
        else { AM_SAP_Validation = null; }

        if( AM_SAP_2 != null && AM_SAP_2 != '' )
        {
            if( isEmailInvalid( AM_SAP_2 ) )
            {
                AM_SAP_2_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_SAP_2_Validation = 'valid';
            }
        }
        else { AM_SAP_2_Validation = null; }

        if( AM_SAP_3 != null && AM_SAP_3 != '' )
        {
            if( isEmailInvalid( AM_SAP_3 ) )
            {
                AM_SAP_3_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_SAP_3_Validation = 'valid';
            }
        }
        else { AM_SAP_3_Validation = null; }
             
        if( SM_AMEC != null && SM_AMEC != '' )
        {
            if( isEmailInvalid( AM_AMEC ) )
            {
                AM_AMEC_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_AMEC_Validation = 'valid';
            }
        }
        else { SM_AMEC_Validation = null; }

        if( SM_EMEA != null && SM_EMEA != '' )
        {
            if( isEmailInvalid( AM_EMEA ) )
            {
                AM_EMEA_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_EMEA_Validation = 'valid';
            }
        }
        else { SM_EMEA_Validation = null; }

        if( SM_GC != null && SM_GC != '' )
        {
            if( isEmailInvalid( AM_GC ) )
            {
                AM_GC_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_GC_Validation = 'valid';
            }
        }
        else { SM_GC_Validation = null; }

        if( SM_Japan != null && SM_Japan != '' )
        {
            if( isEmailInvalid( AM_Japan ) )
            {
                AM_Japan_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_Japan_Validation = 'valid';
            }
        }
        else { SM_Japan_Validation = null; }

        if( SM_Korea != null && SM_Korea != '' )
        {
            if( isEmailInvalid( AM_Korea ) )
            {
                AM_Korea_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                AM_Korea_Validation = 'valid';
            }
        }
        else { SM_Korea_Validation = null; }

        if( SM_SAP != null && SM_SAP != '' )
        {
            if( isEmailInvalid( SM_SAP ) )
            {
                SM_SAP_Validation = 'invalid';
                invalidEmails++ ;
            } 
            else
            {
                SM_SAP_Validation = 'valid';
            }
        }
        else { SM_SAP_Validation = null; }
        
        if( invalidEmails > 0 )
            managersValidated = false;
        else
            managersValidated = true;
    }

    public void ValidateRequired()
    {
        integer ReqFieldsEmpty  = 0;
        
            if( Account_Name == null || Account_Name == '' )
            {
                Account_Name_Invalid = true;
                ReqFieldsEmpty++;
            }
            else    
                Account_Name_Invalid = false;
            
            if( Account_Name != null && Account_Name != '' )
            {
                if( Account_Name.length() > 30 )
                {
                    Account_Name_too_Long = true;
                    ReqFieldsEmpty++;
                }
                else Account_Name_too_Long = false;     
            }
            else    
                Account_Name_too_Long = false;

            if( ( Parent_Account_Name == null || Parent_Account_Name == '')
                && ( RequestType == 'New SFDC Child Account' || RequestType == 'Edit SFDC Child Account' ) )
            {
                Parent_Account_Name_Empty = true;
                ReqFieldsEmpty++;
            }
            else
                Parent_Account_Name_Empty = false;

            if( House_Number != null && House_Number != '' )
            {
                if( House_Number.length() > 10 )
                {
                    House_Number_too_Long = true;
                    ReqFieldsEmpty++;
                }
                else House_Number_too_Long = false;     
            }
            else    
                House_Number_too_Long = false;
                

           if( Street == null || Street == '' )
            {
                Street_Empty = true;
                ReqFieldsEmpty++;
            }
           else 
                 Street_Empty = false;
            
           if(Street != null && Street.length() > 35 )
             {
                Street_too_Long = true;
                ReqFieldsEmpty++;
             }
           else 
                 Street_too_Long = false; 
     
            if( Street_2 != null && Street_2 != '' )
            {
                if( Street_2.length() > 35 )
                {
                    Street_2_too_Long = true;
                    ReqFieldsEmpty++;
                }
                else Street_2_too_Long = false;     
            }
            else    
                Street_2_too_Long = false;

            if( Street_3 != null && Street_3 != '' )
            {
                if( Street_3.length() > 35 )
                {
                    Street_3_too_Long = true;
                    ReqFieldsEmpty++;
                }
                else Street_3_too_Long = false;     
            }
            else    
                Street_3_too_Long = false;
            
            if( City == null || City == '' )
            {
                City_Empty = true;
                ReqFieldsEmpty++;
            }
            else   
            City_Empty = false;
            
            if(City != null && City.length() > 30 )
            {
                 City_too_Long = true;
                 ReqFieldsEmpty++;
            }
            else 
            City_too_Long = false;
                    
            if( objCMDreq.country__c== null || objCMDreq.country__c== '' )
            {
                Country_Empty = true;
                ReqFieldsEmpty++;
            }
            else    
                Country_Empty = false;
            
            //added this if else statement for website field by GHANALINGAMURTHY        
            if( Website == null || Website == '' )
            {
                Website_Empty = true;
                ReqFieldsEmpty++;
            }
            else
                Website_Empty = false;
        
            if( isEmailInvalid(Email) && Email != null && Email != '' )
            {
                Email_Invalid = true;
                ReqFieldsEmpty++;
            }
            else    
                Email_Invalid = false;

            if( (RequestType == 'New SFDC Parent Account' || RequestType == 'Edit SFDC Parent Account') && 
            (Fulfillment_Channel == null || Fulfillment_Channel == '') )
            {
                Fulfillment_Channel_Empty = true;
                ReqFieldsEmpty++;
            }
            else    
                Fulfillment_Channel_Empty = false;
            
            if( (RequestType == 'New SFDC Parent Account' || RequestType == 'Edit SFDC Parent Account') && 
            (Customer_Category == null || Customer_Category == '') )
            {
                Customer_Category_Empty = true;
                ReqFieldsEmpty++;
            }
            else    
                Customer_Category_Empty = false;
            
            if( Role == null || Role == '' )
            {
                Role_Empty = true;
                ReqFieldsEmpty++;
            }
            else
                Role_Empty = false;

            if( Industry_Segment == null || Industry_Segment == '' )
            {
                Industry_Segment_Empty = true;
                ReqFieldsEmpty++;
            }
            else
                Industry_Segment_Empty = false;

            if( ( RequestType == 'New SFDC Child Account' || RequestType == 'Edit SFDC Child Account' )
                && (Industry_Sub_Segment == null || Industry_Sub_Segment == '') )
            {
                Industry_Sub_Segment_Empty = true;
                ReqFieldsEmpty++;
            }
            else
                Industry_Sub_Segment_Empty = false;

            if( (RequestType == 'New SFDC Child Account' || RequestType == 'Edit SFDC Child Account') 
                && (Region == null || Region == '') )
            {
                Region_Empty = true;
                ReqFieldsEmpty++;
            }
            else
                Region_Empty = false;

            /********************Modified by Shridevi-SIR 866- To make sales area field optional for New SFDC Child Account *************************/
          /**
             if( (RequestType == 'New SFDC Child Account') 
                && (Sales_Area == null || Sales_Area == '') )
            {
                Sales_Area_Empty = true;
                //ReqFieldsEmpty++;
            }
            else
                Sales_Area_Empty = false;
                
            if( ( RequestType == 'Edit SFDC Child Account') 
                && (Sales_Area == null || Sales_Area == '') )
            {
                Sales_Area_Empty = true;
                ReqFieldsEmpty++;
            }
            else
                Sales_Area_Empty = false;
          */      
         /*****************************************************************************************************/

            if( Background_of_This_Request == null || Background_of_This_Request == '' )
            {
                Background_of_This_Request_Empty = true;
                ReqFieldsEmpty++;
            }
            else
                Background_of_This_Request_Empty = false;
                
        if( ReqFieldsEmpty == 0 )
            requiredValidated = true;
        else 
            requiredValidated = false;
    }
    
    public void SubmitSAP()
    {
//        ValidateRequester();

        if( RequesterValidation == 'valid'  )
        {
            Submitted = true;

            CMD.Request_Type__c = RequestType;
            
            if( RequestType == 'New SAP' )
            {
                RecordTypeId = NEW_SAP_RECORD_TYPE_ID;
            }        
            CMD.RecordTypeId = RecordTypeId;
            
//            CMD.SP_Account_Name__c = SP_Account_Name;

//            CMD.SH_Account_Name__c = SH_Account_Name;

//            CMD.BP_Account_Name__c = BP_Account_Name;

            insert CMD;
            
            if( source == null ) // if users fill out the web form from scratch from outside of sfdc we will check em
            {
                EmailVerification();
            }
        }
    }

    public void SubmitRequest()
    {
//        fetchNewSfdcParentAccountRecordType();
//        fetchEditSfdcParentAccountRecordType();
//        fetchNewSfdcChildAccountRecordType();
//        fetchEditSfdcChildAccountRecordType();


        System.debug('*********** InternalUserSubmission: ' + InternalUserSubmission);
        
        if( ! InternalUserSubmission )
        {
            Requester_SFDC = ValidateUser( Requester_Email );
            //System.Debug('******** Requester SFDC:' + Requester_SFDC.Id);
            
            if( Requester_SFDC != null ) {
                RequesterValidation = 'valid';
            } else {
                RequesterValidation = 'invalid';
            }
        }    
        else if( InternalUserSubmission )
        {
            /***Added by Scarlett - START****/
            Requester_SFDC = ValidateUser( Requester_Email );
            //System.Debug('******** Requester SFDC:' + Requester_SFDC.Id);
            /***Added by Scarlett - END****/
            RequesterValidation = 'valid' ;
        }
        
        if( New_Owner_Email != null &&  New_Owner_Email != '' )
        {
            New_Owner_SFDC = ValidateUser( New_Owner_Email );
            if( New_Owner_SFDC != null ) {
                New_Owner_Validation = 'valid';
            } else {
//                New_Owner_Validation = 'invalid';  TEMPORARILY STOP CHECKING
                New_Owner_Validation = 'valid';
            }
        }
        else if( ( New_Owner_Name != null && New_Owner_Name != '' )
            && ( New_Owner_Email == null || New_Owner_Email == '' ) ) 
        {
//            New_Owner_Validation = 'invalid';  TEMPORARILY STOP CHECKING
            New_Owner_Validation = 'valid';
        }
        else
        {
//            New_Owner_Validation = null;  TEMPORARILY STOP CHECKING
            New_Owner_Validation = 'valid';
        }
            
        ValidateManagers();
//        if( RequestType == 'New SFDC Parent Account' || RequestType == 'New SFDC Child Account' )
//            ValidateRequired();
//        else if( RequestType == 'Edit SFDC Parent Account' || RequestType == 'Edit SFDC Child Account' )
        ValidateRequired();
        
        if( RequesterValidation == 'valid' && requiredValidated == true && New_Owner_Validation != 'invalid' )
        {
            Submitted = true;

            CMD.Request_Type__c = RequestType;
            
            if( RequestType == 'New SFDC Parent Account' )
            {
                RecordTypeId = NEW_SFDC_PARENT_ACCOUNT_RECORD_TYPE_ID;
            }
            if( RequestType == 'Edit SFDC Parent Account' )
            {
                RecordTypeId = EDIT_SFDC_PARENT_ACCOUNT_RECORD_TYPE_ID;
            }
            if( RequestType == 'New SFDC Child Account' )
            {
                RecordTypeId = NEW_SFDC_CHILD_ACCOUNT_RECORD_TYPE_ID;
            }
            if( RequestType == 'Edit SFDC Child Account' )
            {
                RecordTypeId = EDIT_SFDC_CHILD_ACCOUNT_RECORD_TYPE_ID;
            }

            if( Edited_Account != null &&
                ( RequestType == 'Edit SFDC Parent Account'     // compare the user input from the original account data,
                || RequestType == 'Edit SFDC Child Account' ) )     // if a field value isunchanged, we will leave a blank field in CMD Request 
            {
                if( Account_Name == Edited_Account.Name )
                    Account_Name = null;
                if( Legal_Name == Edited_Account.Legal_Name__c )
                    Legal_Name = null;

                if( ParentId == Edited_Account.ParentId )
                    ParentId = null;
                if( Parent_Account_Name == Edited_Account.Name )
                    Parent_Account_Name = null;
                if( Parent_Account_GID == Edited_Account.NXP_GID__c )
                    Parent_Account_GID = null;
                if( NUP != null)    
                    if( NUP.Name == Edited_Account.NXP_GID_GE__c )
                        NUP = null;

                if( DUNS == Edited_Account.DUNS_Number__c )
                    DUNS = null;
                if( House_Number == Edited_Account.House_Number__c )
                    House_Number = null;
                if( Street == Edited_Account.Street__c )
                    Street = null;
                if( Street_2 == Edited_Account.Street2__c )
                    Street_2 = null;
                if( Street_3 == Edited_Account.Street3__c )
                    Street_3 = null;
                if( City == Edited_Account.City__c )
                    City = null;
                if( State == Edited_Account.State_Province__c )
                    State = null;
                if( Postal_Code == Edited_Account.ZIP_Postal_Code__c )
                    Postal_Code = null;
                if( Country == Edited_Account.Country__c )
                    Country = null;
                if( Sales_Area == Edited_Account.Sales_Area__c )
                    Sales_Area = null;

                if( Website == Edited_Account.Website )
                    Website = null;
                if( Email == Edited_Account.Email__c )
                    Email = null;
                if( Telephone == Edited_Account.Phone )
                    Telephone = null;
                if( Fax == Edited_Account.Fax )
                    Fax = null;

                if( Fulfillment_Channel == Edited_Account.Fulfillment_Channel__c )
                    Fulfillment_Channel = null;
                if( Customer_Category == Edited_Account.Customer_Category__c )
                    Customer_Category = null;
                if( Role == Edited_Account.Role__c )
                    Role = null;
                if( Type == Edited_Account.Type )
                    Type = null;
                /***1602 Hot-fix - Modified by Scarlett***/
                if( Edited_Account.CMD_Industry_Segment__c != NULL && Edited_Account.CMD_Industry_Segment__c != ''){
                    if(Industry_Segment != null && Industry_Segment.contains( Edited_Account.CMD_Industry_Segment__c ))
                        Industry_Segment = null;               
                }
                if( Edited_Account.CMD_Sub_Segment__c != NULL && Edited_Account.CMD_Sub_Segment__c != ''){
                    if(Industry_Sub_Segment != null && Industry_Sub_Segment.contains( Edited_Account.CMD_Sub_Segment__c ) )
                        Industry_Sub_Segment = null;
                }
                /***1602 Hot-fix - Modified by Scarlett -END***/
                if( AM_AMEC == Edited_Account.Account_Manager_AMEC__r.Email )
                    AM_AMEC = null;
                if( AM_EMEA == Edited_Account.Account_Manager_EMEA__r.Email )
                    AM_EMEA = null;
                if( AM_GC == Edited_Account.Account_Manager_GC__r.Email )
                    AM_GC = null;
                if( AM_Japan == Edited_Account.Account_Manager_Japan__r.Email )
                    AM_Japan = null;
                if( AM_Korea == Edited_Account.Account_Manager_Korea__r.Email )
                    AM_Korea = null;
                if( AM_Korea_2 == Edited_Account.Account_Manager_Korea_2__r.Email )
                    AM_Korea_2 = null;
                if( AM_SAP == Edited_Account.Account_Manager_SAP__r.Email )
                    AM_SAP = null;
                if( AM_SAP_2 == Edited_Account.Account_Manager_SAP_2__r.Email )
                    AM_SAP_2 = null;
                if( AM_SAP_3 == Edited_Account.Account_Manager_SAP_3__r.Email )
                    AM_SAP_3 = null;

                if( SM_AMEC == Edited_Account.Service_Manager_AMEC__r.Email )
                    SM_AMEC = null;
                if( SM_EMEA == Edited_Account.Service_Manager_EMEA__r.Email )
                    SM_EMEA = null;
                if( SM_GC == Edited_Account.Service_Manager_GC__r.Email )
                    SM_GC = null;
                if( SM_Japan == Edited_Account.Service_Manager_Japan__r.Email )
                    SM_Japan = null;
                if( SM_Korea == Edited_Account.Service_Manager_Korea__r.Email )
                    SM_Korea = null;
                if( SM_SAP == Edited_Account.Service_Manager_SAP__r.Email )
                    SM_SAP = null;
            }
        
            CMD.RecordTypeId = RecordTypeId;
            
            CMD.Requester_Name__c = Requester_Name;
            CMD.Requester_Email__c = Requester_Email;
            if( Requester_SFDC != null ) {
                CMD.Requester_SFDC__c = Requester_SFDC.Id;
            }            
            
            if( New_Owner_Name != null ) {
                CMD.New_Account_Owner_Name__c = New_Owner_Name;
            }
            if( New_Owner_Email != null ) {
                CMD.New_Account_Owner_Email__c = New_Owner_Email;
            }
            if( New_Owner_SFDC != null ) {
                CMD.New_Account_Owner_SFDC__c = New_Owner_SFDC.Id;
            }

            CMD.NXP_Global_ID__c = NXP_Global_ID;
            if( NXP_Global_ID != null )
                CMD.Edited_Customer_Id__c = Edited_Customer_Id;
            CMD.AccountId__c = AccountId;
            CMD.Account_Name__c = Account_Name;
            CMD.Legal_Name__c = Legal_Name;

            CMD.Parent_Account_Name__c = Parent_Account_Name;
            CMD.Parent_Account_GID__c = Parent_Account_GID;
            CMD.Parent_Account_in_CRM__c = ParentId;
            if( NUP != null )
                CMD.NUP_Id__c = NUP.Id;

            CMD.DUNS_Number__c = DUNS;
            CMD.House_Number__c = House_Number;
            CMD.Street__c = Street;
            CMD.Street_2__c = Street_2;
            CMD.Street_3__c = Street_3;
            CMD.City__c = City;
            //CMD.State__c = State; //changed to below line as per SIR#2
             
            CMD.State__c =objCMDreq.State_Province__c;
       
           system.debug('$$$Country'+country);
            //CMD.Country__c = Country; //changed to below line as per SIR#2
             
            CMD.Country__c =objCMDreq.country__c;
           
            CMD.Postal_Code__c = Postal_Code;

            CMD.Website__c = Website;
            CMD.Email__c = Email;
            CMD.Telephone__c = Telephone;
            CMD.Fax__c = Fax;

            CMD.Fulfillment_Channel__c = Fulfillment_Channel;
            CMD.Customer_Category__c = Customer_Category;
            CMD.Role__c = Role;
            CMD.Type__c = Type;
            CMD.Industry_Segment__c = Industry_Segment;            
            CMD.Industry_Sub_Segment__c = Industry_Sub_Segment;            
            CMD.Region__c = Region;
            CMD.Sales_Area__c = Sales_Area;
            CMD.Automotive_OEM__c = Automotive_OEM;
            
            CMD.Background_of_This_Request__c = Background_of_This_Request;

            CMD.AM_AMEC_Email__c = AM_AMEC ;
            CMD.AM_EMEA_Email__c = AM_EMEA ;
            CMD.AM_GC_Email__c = AM_GC ;
            CMD.AM_Japan_Email__c = AM_Japan ;
            CMD.AM_Korea_Email__c = AM_Korea ;
            CMD.AM_Korea_2_Email__c = AM_Korea_2 ;
            CMD.AM_SAP_Email__c = AM_SAP ;
            CMD.AM_SAP_2_Email__c = AM_SAP_2 ;
            CMD.AM_SAP_3_Email__c = AM_SAP_3 ;
            
            CMD.SM_AMEC_Email__c = SM_AMEC ;
            CMD.SM_EMEA_Email__c = SM_EMEA ;
            CMD.SM_GC_Email__c = SM_GC ;
            CMD.SM_Japan_Email__c = SM_Japan ;
            CMD.SM_Korea_Email__c = SM_Korea ;
            CMD.SM_SAP_Email__c = SM_SAP ;
            
            insert CMD;
            
            if( source == null ) // if users fill out the web form from scratch from outside of sfdc we will check em
            {
                EmailVerification();
            }
            else if( source != null ) // if the user fill out this form from within sfdc, we will skip email check 
            {
                submitForApproval();
            }
        }
    }

    private void EmailVerification()
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { Requester_Email }; 
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('NXP GSAS-CMD');
        mail.setReplyTo('globalsales.appsupport@nxp.com');
        mail.setSubject( RequestType + ' for ' + Account_Name );
        mail.setPlainTextBody('Hello '+ Requester_Name + '\n'
                                +'Please click on this following link to complete the email verification process, then your Customer Master Data Request for '
                                + String.valueOf(CMD.Account_Name__c) + ' will be submitted for approval.\n' 
                                + WEB_FORM_URL 
                                + '/CMD_Verification'
                                + '?rid=' + String.valueOf(CMD.id) 
                                + '&rtid=' + String.valueOf(CMD.RecordTypeId)
                                + '&uid=' + String.valueOf(CMD.Requester_SFDC__c)
                                );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public void ConfirmRequest()
    {
        if( RequestId != null && UserId != null )
        {
            List<CMD_Request__c> fetchCMD_Request = 
            [
                SELECT Id, Requester_Email__c, Request_Status__c, Request_Type__c 
                FROM CMD_Request__c
                WHERE Id = :RequestId
                AND RecordTypeId = :RecordTypeId
                AND Requester_SFDC__c =:UserId
            ];
            if( fetchCMD_Request.size() > 0 )
            {
                Verified = true;
                CMD = fetchCMD_Request[0];
                //Modified by Vinay:If condition
                if(CMD.Request_Status__c == 'Submitted' || CMD.Request_Status__c == '' || CMD.Request_Status__c == null )
                {
                    CMD.Request_Status__c = 'Verified';
                    update CMD;
                    requestAlreadyProcessed = false;
                    if( CMD.RecordTypeId == NEW_SFDC_PARENT_ACCOUNT_RECORD_TYPE_ID || CMD.RecordTypeId == EDIT_SFDC_PARENT_ACCOUNT_RECORD_TYPE_ID )
                    {
                        submitForApproval();
                    }
                    else if( CMD.RecordTypeId == NEW_SFDC_CHILD_ACCOUNT_RECORD_TYPE_ID || CMD.RecordTypeId == EDIT_SFDC_CHILD_ACCOUNT_RECORD_TYPE_ID )
                    {
//                      EmailCMD();  // 2015.08 SIR#268
                        submitForApproval(); // 2015.08 SIR#268
                    }
                    else if( CMD.RecordTypeId == NEW_SAP_RECORD_TYPE_ID )
                    {
                        EmailCMD();
                    }
                }
/********** 2015.08 SIR#268 **************** Code Block BEGIN ***************************/
                else
                {
                    requestAlreadyProcessed = true;
                }
/********** 2015.08 SIR#268 **************** Code Block END ***************************/
            }
            else Verified = false;
        } 
    }

    public void submitForApproval()
    {
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(CMD.id);
        Approval.ProcessResult result = Approval.process(req1);
    }

    public void EmailCMD()
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { 'christy.chiang@nxp.com', 'heather.liang@nxp.com','ines.knu@nxp.com','stan.hsu@nxp.com' }; 
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('NXP GSAS-CMD');
        mail.setReplyTo('globalsales.appsupport@nxp.com');
        mail.setSubject( 'NXP GCM Request'  );
        mail.setPlainTextBody(
            'Dear CMD Officer,\n\n'
            + SFDC_INSTANCE_URL
            + String.valueOf(CMD.id)
            + '\n\nPlease verify this request then submit for approval, '
            + '\n and most importantly please find the correct Parent Account in CRM, '
        );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public pageReference Refresh()
    {
        PageReference PR = new PageReference( ApexPages.CurrentPage().getUrl() );
        PR.setRedirect(true);
        return PR;
    }
    
    //CRM to GCM Industry Segment code convertor
    public static String ConvertIndustryCode(String code)
    {
        if (code == null) return code;
        Schema.DescribeFieldResult F = Customer__c.Industry_Segment__c.getDescribe();
        List<Schema.PicklistEntry> Ple = F.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        {
            if (p.getlabel().indexOf(code) > -1)
                return p.getlabel();
        }
        return code;
    }

    //CRM to GCM Industry Sub Segment code convertor
    public static String ConvertSubSegmentCode(String code)
    {
        if (code == null) return code;
        Schema.DescribeFieldResult F = Customer__c.Industry_Sub_Segment__c.getDescribe();
        List<Schema.PicklistEntry> Ple = F.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        {
            if (p.getlabel().indexOf(code) > -1)
                return p.getlabel();
        }
        return code;
    }
    
    //CRM to GCM region code convertor
    public static String ConvertRegionCode(String sapCode)
    {
        if (sapCode == null) return sapCode;
        if (sapCode.equalsIgnoreCase('EMEA'))
        {
            return 'EU - EMEA';
        } 
        else if (sapCode.equalsIgnoreCase('Japan'))
        {
            return 'AP - JAPAN';
        }
        else if (sapCode.equalsIgnoreCase('Korea'))
        {
            return 'AP - KOREA';
        }
        else if (sapCode.equalsIgnoreCase('Greater China'))
        {
            return 'AP - GC';
        }
        else if (sapCode.equalsIgnoreCase('Americas'))
        {
            return 'AM - AMEC';
        }
        else if (sapCode.equalsIgnoreCase('South Asia Pacific'))
        {
            return 'AP - SAP';
        }
        return sapCode;
    }
    
    public void checkRequestType()
    {
        if ( RequestType == 'New SFDC Parent Account' )
            Customer_Category = 'Longtail';
            
        if ( Type == '' || Type == null)
            Type = 'Customer';
    }
    
}