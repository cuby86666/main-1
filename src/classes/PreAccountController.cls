/** Stan Hsu
  * Sept 9, 2013
  * For CMD Project - Converting PreAccount to Parent and/or Child Accounts
------------------------------------------------------------------------------
@Modified By: 		Nisha Agrawal
@Modified Date: 	08 Aug 2017
@Description:		Modified class to optimize the code, remove hard coded Ids and 
					improve the code coverage
-------------------------------------------------------------------------------------
@Modified By: 		Nisha Agrawal
@Modified Date: 	27 Sep 2017
@Description:		uncomment the code which got commented in previous release and raising error
***************************************************************************************/
public class PreAccountController {
	/*
    private static final string PRE_ACCOUNT_RECORD_TYPE_ID = '012D0000000QjgkIAC' ;
    private static final string PARENT_ACCOUNT_RECORD_TYPE_ID = '01220000000E4JaAAK' ;
    private static final string CHILD_ACCOUNT_RECORD_TYPE_ID = '01220000000E4JYAA0' ;
    private static final string DATA_ADMIN_USER_ID = '00520000001EuBkAAK' ;
  */ 
    //Code block added by Nisha Agrawal on Aug 08, 2017 to remove hard coded Ids 
    private static final string PRE_ACCOUNT_RECORD_TYPE_ID = AccountHelper.getPreAccountRecordTypeID(); 
    private static final string PARENT_ACCOUNT_RECORD_TYPE_ID = AccountHelper.getParentRecordTypeID();
    private static final string CHILD_ACCOUNT_RECORD_TYPE_ID = AccountHelper.getChildRecordTypeID() ;
    private static final String DATA_ADMIN_USER = 'Data Admin';
    
    private final Account A;
    
    public PreAccountController( ApexPages.StandardController stdController ) {
        this.A = (Account)stdController.getRecord();
    } 
        
    public PreAccountController( Account theA ){
        this.A = theA;
    }
    
    //Code block Commented by Nisha Agrawal on Aug 18 to remove extra code
    /*
    private static final string PRE_ACCOUNT = 'PreAccount';
    private static final string PARENT_ACCOUNT = 'Parent_Account';
    private static final string CHILD_ACCOUNT = 'Child Account';
	    
    private static RecordType preAccountRecordType;
    private static RecordType parentAccountRecordType;
    private static RecordType childAccountRecordType;
    */
    private CMD_Request__c originalCMD_Request;

    private CMD_Request__c fetchCMD_Request( string theReqId ) {
        for( CMD_Request__c req : [ SELECT  Id, 
                                            Name, 
                                            Requester_SFDC__c
                                    FROM    CMD_Request__c
                                    WHERE   Id = :theReqId
                                ]) {
            return req;
        }
        return null ;               
    }
    
    
    public PageReference makeParentAccount() {
        String theId = ApexPages.currentPage().getParameters().get('id');
        if (theId == null) {
            return null;
        }
        for (Account A : [ SELECT   Id, 
                                    Name, 
                                    RecordTypeId, 
                                    NXP_GID__c,
                                    CMD_Request_Id__c  
                            FROM    Account 
                            WHERE   id =:theId
                        ]) {
            originalCMD_Request = fetchCMD_Request( A.CMD_Request_Id__c );
            if( A.RecordTypeId == PRE_ACCOUNT_RECORD_TYPE_ID ) {
                A.RecordTypeId = PARENT_ACCOUNT_RECORD_TYPE_ID;  
                update A;
            }
            else return null;
        }
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
    }

   
    public PageReference makeChildAccount() {
        String theId = ApexPages.currentPage().getParameters().get('id');
        if (theId == null) {
            return null;
        }
        for (Account A : [ SELECT   Id, 
                                    Name, 
                                    RecordTypeId, 
                                    NXP_GID__c, 
                                    CMD_Request_Id__c 
                            FROM    Account 
                            WHERE   Id =:theId
                        ]) {
            originalCMD_Request  = fetchCMD_Request( A.CMD_Request_Id__c );
            if( A.RecordTypeId == PRE_ACCOUNT_RECORD_TYPE_ID ) {
                A.RecordTypeId = CHILD_ACCOUNT_RECORD_TYPE_ID;  
                if( originalCMD_Request != null )
                    if( originalCMD_Request.Requester_SFDC__c != null )
                        A.OwnerId = originalCMD_Request.Requester_SFDC__c ;
                update A;
            }
            else return null;
        }
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
    }

   
    public PageReference makeAccountCombo() {
        String theId = ApexPages.currentPage().getParameters().get('id');
        if (theId == null) {
            return null;
        }
        
        //Code block added by Nisha Agrawal on Aug 08, 2017 to remove hard coded Ids
        Id DATA_ADMIN_USER_ID ;
    	List<User> lstUsers = [Select Id, Name from User Where Name = : DATA_ADMIN_USER ];
        if(lstUsers.size() == 0 || lstUsers.size() > 1)
        {
            return null;
        }
        else if(lstUsers.size() == 1)
        {
            DATA_ADMIN_USER_ID = lstUsers[0].Id;
        }
        
        for( Account A : [ SELECT   Id, 
                                    Name, 
                                    RecordTypeId, 
                                    NXP_GID__c ,
                                    CMD_Request_Id__c ,
                                    Legal_Name__c ,
                                    DUNS_Number__c ,
                                    House_Number__c ,
                                    Street__c ,
                                    Street2__c ,
                                    Street3__c ,
                                    City__c ,
                                    State_Province__c ,
                                    ZIP_Postal_Code__c ,
                                    Country__c ,
                                    Website ,
                                    Email__c ,
                                    Phone ,
                                    Fax ,
                                    Region__c ,
                                    Sales_Area__c,
                                    Fulfillment_Channel__c ,
                                    Customer_Category__c ,
                                    Role__c ,
                                    Type ,
                                    Industry_Segment__c ,
                                    Sub_Segment__c ,
                                    SIC_Code__c ,
                                    NAICS_Code__c ,
                                    Automotive_OEM__c,
                                    Account_Manager_AMEC__c ,
                                    Account_Manager_EMEA__c ,
                                    Account_Manager_GC__c ,
                                    Account_Manager_Japan__c ,
                                    Account_Manager_Korea__c ,
                                    Account_Manager_Korea_2__c ,
                                    Account_Manager_SAP__c ,
                                    Account_Manager_SAP_2__c ,
                                    Account_Manager_SAP_3__c ,
                                    Service_Manager_AMEC__c ,
                                    Service_Manager_EMEA__c ,
                                    Service_Manager_GC__c ,
                                    Service_Manager_Japan__c ,
                                    Service_Manager_Korea__c ,
                                    Service_Manager_SAP__c                            
                            FROM    Account 
                            WHERE   Id =:theId
                        ]) {
            originalCMD_Request = fetchCMD_Request( A.CMD_Request_Id__c );
            if( A.RecordTypeId == PRE_ACCOUNT_RECORD_TYPE_ID ) {
                A.RecordTypeId = PARENT_ACCOUNT_RECORD_TYPE_ID;  
                A.OwnerId = DATA_ADMIN_USER_ID  ;
                A.ParentId = null ;
                update A;

                Account A2 = New Account(  //making a Child Account copy
                    RecordTypeId = CHILD_ACCOUNT_RECORD_TYPE_ID,
                    ParentId = A.Id ,
                    NXP_GID__c = A.NXP_GID__c ,
                    CMD_Request_Id__c = A.CMD_Request_Id__c ,
                    Name = A.Name ,
                    Legal_Name__c = A.Legal_Name__c ,
                    DUNS_Number__c = A.DUNS_Number__c ,
                    House_Number__c = A.House_Number__c ,
                    Street__c = A.Street__c ,
                    Street2__c = A.Street2__c ,
                    Street3__c = A.Street3__c ,
                    City__c = A.City__c ,
                    State_Province__c = A.State_Province__c ,
                    ZIP_Postal_Code__c = A.ZIP_Postal_Code__c ,
                    Country__c = A.Country__c ,
                    Website = A.Website ,
                    Email__c = A.Email__c ,
                    Phone = A.Phone ,
                    Fax = A.Fax ,
                    Region__c = A.Region__c ,
                    Sales_Area__c = A.Sales_Area__c ,
                    Fulfillment_Channel__c = A.Fulfillment_Channel__c ,
                    Customer_Category__c = A.Customer_Category__c ,
                    Role__c = A.Role__c ,
                    Type = A.Type ,
                    Industry_Segment__c = A.Industry_Segment__c ,
                    Sub_Segment__c = A.Sub_Segment__c ,                        
                    SIC_Code__c = A.SIC_COde__c ,
                    NAICS_Code__c = A.NAICS_Code__c ,
                    Automotive_OEM__c = A.Automotive_OEM__c
/*
                    Account_Manager_AMEC__c = A.Account_Manager_AMEC__c ,
                    Account_Manager_EMEA__c = A.Account_Manager_EMEA__c ,
                    Account_Manager_GC__c = A.Account_Manager_GC__c ,
                    Account_Manager_Japan__c = A.Account_Manager_Japan__c ,
                    Account_Manager_Korea__c = A.Account_Manager_Korea__c ,
                    Account_Manager_Korea_2__c = A.Account_Manager_Korea_2__c ,
                    Account_Manager_SAP__c = A.Account_Manager_SAP__c ,
                    Account_Manager_SAP_2__c = A.Account_Manager_SAP_2__c ,
                    Account_Manager_SAP_3__c = A.Account_Manager_SAP_3__c ,
                    Service_Manager_AMEC__c = A.Service_Manager_AMEC__c ,
                    Service_Manager_EMEA__c = A.Service_Manager_EMEA__c ,
                    Service_Manager_GC__c = A.Service_Manager_GC__c ,
                    Service_Manager_Japan__c = A.Service_Manager_Japan__c ,
                    Service_Manager_Korea__c = A.Service_Manager_Korea__c ,
                    Service_Manager_SAP__c = A.Service_Manager_SAP__c
*/
                );
                insert A2;

                if( originalCMD_Request != null 
                        && originalCMD_Request.Requester_SFDC__c != null ) {
                    A2.OwnerId = originalCMD_Request.Requester_SFDC__c ;
                }
                update A2;
            }
            else return null;
        }
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
    }

}