/**********************************************************************************************
@Modified By :    Scarlett Kang    
@Modified Date :  March 09, 2015 
@Description :    Use Funloc # and Sales Org as search key to update SAP CMD (Edit request)
************************************************************************************************
@Modified By :    Baji    
@Modified Date :  January 22, 2016 
@Description :    SIR 622: To send email notification to recipeints based on the group name selected by CMD officer 
                  when CMD request status is changed to completed (for first time) - Phase 1
************************************************************************************************
@Modified By :    Baji    
@Modified Date :  March 30, 2016 
@Description :    SIR 698: To send email notification to recipeints based on the group name selected by CMD officer 
                  when CMD request(New/Edit) status is changed to completed (for first time) - Phase 2
*************************************************************************************************************************
@Modified By :    Jewelslyn   
@Modified Date :  Dec 01, 2016 
@Description :    SFDC 53: To Carry CACC value to SAP CMD for ZORG(Expected ZORG to behave in the Same way as Z012)
-----------------------------------------------------------------------------------------------------------
@Modified By :      Baji
@Modified Date:     23 Mar 2017
@Description:       1704 Release (SFDC 285) - to extend CMD Request completion notification for new funloc request to S&P team.
-----------------------------------------------------------------------------------------------------------
@Modified By :      Baji
@Modified Date:     24 Jul 2017
@Description:       1708 Release (SFDC 729) - To set default value for few of the fieds on SAP CMD New SBE Funloc Request form.
************************************************************************************************************************/
public class CMD_Request_Trigger {
 /*public static List<SAP_CMD__c> liSapCmd {
        get {
            if (liSapCmd == null) liSapCmd = new List<SAP_CMD__c>();
            return liSapCmd;
        }
        set;
    }   */   
    
/***
    private static Map<Id, Account> allParents = new Map<Id, Account>([
        SELECT  Id, Name, 
                NXP_GID__c,
                Customer_Category__c
        FROM   Account
        WHERE  RecordType.Name LIKE 'Parent%'
    ]);
***/
   /*public CMD_Request_Trigger (ApexPages.StandardController controller)
    {
    }*/
    // Variables Declared for the SIR698
    
     Private Static Final string TYPE_New_CmdReq='SAP_New_Funloc_Request';
     Private Static Final String TYPE_Edit_CmdReq='SAP_Funloc_Edit_Request';
     Private Static Final string New_Email_Template='CMD_New_Request_Completed';
     Private Static Final String Edit_Email_Template='CMD_Edit_Request_Completed';
     Private Static Final String OrgWide_Address='Data Admin';
     Private Static Final String CMD_Team='CMD Team';
     Private Static Final String SP_Team ='S&P Team';
     Private Static Final string TYPE_New_SBE_CmdReq='SAP_New_SBE_Funloc_request';
     Private Static Final string TYPE_Edit_SBE_CmdReq='SAP_SBE_Funloc_Edit_request';
     Private Static Final string TYPE_New_MANU_CmdReq='SAP_New_MANU_Funloc_request';
     Private Static Final string TYPE_Edit_MANU_CmdReq='SAP_MANU_Funloc_Edit_request';
     Private static final String SALES_ORG_NL60 = 'NL60 - RSO Europe';
     Private static final String SALES_ORG_US60 = 'US60 - RSO U.S.A.';
     Public Static Id sapNewSBEFun_Id;
     Public Static Id sapEditSBEFun_Id;
     Public Static Id sapNewMANUFun_Id;
     Public Static Id sapEditMANUFun_Id;
     Public Static Id sapNewFun_Id;
     Public Static Id sapEditFun_Id;
     Public Static Id emailNewFun_Id;
     Public Static Id emailEditFun_Id;
     
     
     public CMD_Request_Trigger()
    {
    }
    private static List<Account> allParents = [
        SELECT  Id, Name, 
                NXP_GID__c,
                Customer_Category__c
        FROM   Account
        WHERE  RecordType.Name LIKE 'Parent%'
    ];  
    
    private static List<Customer__c> allCustomers = [
        SELECT  Id, Name
        FROM    Customer__c
    ];
    
    private static List<Hub_Foundation__c> allHub_Foundations = [
        SELECT  Id, Name, Country__c, Region__c
        FROM  Hub_Foundation__c
        WHERE Country__c != NULL
        AND Region__c != NULL
    ];

    private static List<Account> allAccountApprovers = [
        SELECT  Id, Name, 
                NXP_GID__c,
                Account_Manager_AMEC__c,
                Account_Manager_EMEA__c,
                Account_Manager_GC__c,
                Account_Manager_Japan__c,
                Account_Manager_Korea__c,
                Account_Manager_Korea_2__c,
                Account_Manager_SAP__c,
                Account_Manager_SAP_2__c,
                Account_Manager_SAP_3__c,
                Customer_Category__c
        FROM   Account
        WHERE  RecordType.Name LIKE 'Parent%'
    ];        

    private static List<SAP_CMD__c> allSAPCMDs = [
        SELECT  Id, 
                Name,
                RecordType.Name,
                FunLoc__c,
                Customer_FunLoc_Number__c,
                Sales_Organisation__c
        FROM    SAP_CMD__c
        ORDER BY Id
    ];
    
    private static List<Consolidated_Account_Code__c> allCACCs = [
        SELECT  Id, 
                Name,
                Base_Region__c,
                Customer_Category__c,
                PD_Key_Account__c
        FROM    Consolidated_Account_Code__c
        ORDER BY Name
    ];  

    private static List<User> allCMDOfficers = [
        SELECT  Id, 
                Name 
        FROM    User 
        WHERE   Profile.Name LIKE '%CMD Officer%'
    ];
    
    private static List<RecordType> allCMDRequestRts = [
        SELECT  Id, 
                DeveloperName, 
                Name  
        FROM RecordType 
        WHERE SobjectType = 'CMD_Request__c' AND IsActive = TRUE
    ];
    /*    
    public CMD_Request_Trigger(){
        
    }
    */
    
public static void fetchCMDReqRecordTypes()
    {
      if(sapNewFun_Id == null && sapEditFun_Id  ==null && sapNewSBEFun_Id == null && sapEditSBEFun_Id ==null && sapNewMANUFun_Id== null && sapEditMANUFun_Id == null)
      {        
         For(recordType rt:[Select Id, Name,DeveloperName From RecordType 
                        Where IsActive=true AND (SobjectType = 'CMD_Request__c' and 
                        (DeveloperName =:TYPE_New_CmdReq OR DeveloperName =:TYPE_Edit_CmdReq OR DeveloperName =:TYPE_New_SBE_CmdReq
                         OR DeveloperName =:TYPE_Edit_SBE_CmdReq OR DeveloperName =:TYPE_New_MANU_CmdReq OR DeveloperName =:TYPE_Edit_MANU_CmdReq))])
        {         
            if(rt.DeveloperName ==TYPE_New_CmdReq) 
            {
               sapNewFun_Id=rt.id;  
            }
            else if(rt.DeveloperName ==TYPE_Edit_CmdReq)
            {
               sapEditFun_Id =rt.id;  
            }
            else if(rt.DeveloperName == TYPE_New_SBE_CmdReq)
            {
               sapNewSBEFun_Id = rt.id;
            }
            else if(rt.DeveloperName == TYPE_Edit_SBE_CmdReq)
            {
               sapEditSBEFun_Id = rt.id;
            }
            else if(rt.DeveloperName == TYPE_New_MANU_CmdReq)
            {
               sapNewMANUFun_Id = rt.id;
            }
            else if(rt.DeveloperName == TYPE_Edit_MANU_CmdReq)
            {
               sapEditMANUFun_Id = rt.id;
            }
           
          }
        }
    }
    public static void fetchRegion( List<CMD_Request__c> listCMDRequests ) {
        Map<string , string> mapCountryRegion = new Map<string , string>();    
        for( Hub_Foundation__c theHub_Foundation : allHub_Foundations ) {
            mapCountryRegion.put( theHub_Foundation.Country__c.trim() , theHub_Foundation.Region__c.trim() );
        }

        for( CMD_Request__c theCMDRequest : listCMDRequests ) {
            if( theCMDRequest.Country__c != null && theCMDRequest.Country__c != '' ) {
                theCMDRequest.Region__c = mapCountryRegion.get( theCMDRequest.Country__c );
            } else if ( theCMDRequest.Country__c == null || theCMDRequest.Country__c == '' ) {
                theCMDRequest.Region__c  = null ;
            }
        } 
    }
  
    public static void fetchApprovers( List<CMD_Request__c> listCMDRequests ) {

        Map<Id, Account> mapAllParents = new Map<Id, Account>();
        for( Account theAccount : allAccountApprovers ){
            mapAllParents.put( theAccount.Id , theAccount );
        }

        for( CMD_Request__c theCMDRequest : listCMDRequests ) {
            if( theCMDRequest.Parent_Account_in_CRM__c != null ) {
                Account theParent = mapAllParents.get( theCMDRequest.Parent_Account_in_CRM__c );

                if( theParent != null ) {
                    theCMDRequest.Parent_Account_GID__c = theParent.NXP_GID__c;
                
                    theCMDRequest.Approver_AMEC__c = theParent.Account_Manager_AMEC__c;
                    theCMDRequest.Approver_EMEA__c = theParent.Account_Manager_EMEA__c;
                    theCMDRequest.Approver_GC__c = theParent.Account_Manager_GC__c;
                    theCMDRequest.Approver_Japan__c = theParent.Account_Manager_Japan__c;
                    theCMDRequest.Approver_Korea__c = theParent.Account_Manager_Korea__c;
                    theCMDRequest.Approver_Korea_2__c = theParent.Account_Manager_Korea_2__c;
                    theCMDRequest.Approver_SAP__c = theParent.Account_Manager_SAP__c;
                    theCMDRequest.Approver_SAP_2__c = theParent.Account_Manager_SAP_2__c;
                    theCMDRequest.Approver_SAP_3__c = theParent.Account_Manager_SAP_3__c;
                    theCMDRequest.Customer_Category__c=theParent.Customer_Category__c;
                } else if( theParent == null ) {
                    theCMDRequest.Approver_AMEC__c = null;
                    theCMDRequest.Approver_EMEA__c = null;
                    theCMDRequest.Approver_GC__c = null;
                    theCMDRequest.Approver_Japan__c = null;
                    theCMDRequest.Approver_Korea__c = null;
                    theCMDRequest.Approver_Korea_2__c = null;
                    theCMDRequest.Approver_SAP__c = null;
                    theCMDRequest.Approver_SAP_2__c = null;
                    theCMDRequest.Approver_SAP_3__c = null;
                    theCMDRequest.Customer_Category__c=null;            
                }
            } else if( theCMDRequest.Parent_Account_in_CRM__c == null ) {
                theCMDRequest.Approver_AMEC__c = null;
                theCMDRequest.Approver_EMEA__c = null;
                theCMDRequest.Approver_GC__c = null;
                theCMDRequest.Approver_Japan__c = null;
                theCMDRequest.Approver_Korea__c = null;
                theCMDRequest.Approver_Korea_2__c = null;
                theCMDRequest.Approver_SAP__c = null;
                theCMDRequest.Approver_SAP_2__c = null;
                theCMDRequest.Approver_SAP_3__c = null;
                theCMDRequest.Customer_Category__c=null;            
            }  
        }
    }  
 
    public static void fetchParentCustomerCategory( List<CMD_Request__c> listCMDRequests ) {
/***** moved to class level
        Map<Id, Account> allParentsForThisMethod = new Map<Id, Account>([
                    SELECT  Id, Name, 
                            NXP_GID__c,
                            Customer_Category__c
                    FROM   Account
                    WHERE  RecordType.Name LIKE 'Parent%'
        ]);
*****/
        Map<Id, String> allParentCustomerCategory = new Map<Id, String>();
        
        for( Account theParent : allParents ){
            if( theParent.Customer_Category__c != null ){
                allParentCustomerCategory.put(theParent.Id, theParent.Customer_Category__c );
            }   
        }
        
        for( CMD_Request__c theCMDRequest : listCMDRequests ) {
            if(theCMDRequest.Parent_Account_in_CRM__c != null 
               && allParentCustomerCategory.containsKey(theCMDRequest.Parent_Account_in_CRM__c)    
               && ( theCMDRequest.Customer_Category__c == null
               || theCMDRequest.Customer_Category__c == '' )) {
             theCMDRequest.Customer_Category__c = allParentCustomerCategory.get(theCMDRequest.Parent_Account_in_CRM__c);
//                    = allParentsForThisMethod.get(theCMDRequest.Parent_Account_in_CRM__c).Customer_Category__c;
            }
        }
    }   
    public static void fetchCustomersIDs( List<CMD_Request__c> listCMDRequests ) {
/*
        List<Customer__c> allCustomers = [
            SELECT  Id, Name
            FROM    Customer__c
        ];
*/
        Map<string , string> mapGID_CustomerID = new Map<string , string>();
        for( Customer__c theCustomer : allCustomers ) {
            mapGID_CustomerID.put( theCustomer.Name , String.valueOf(theCustomer.Id).trim() );
        }

        for( CMD_Request__c theCMDRequest : listCMDRequests ) {
            if( theCMDRequest.SP_GID__c != null && theCMDRequest.SP_GID__c != '' ) {
                theCMDRequest.SP_CustomerID__c = mapGID_CustomerID.get( theCMDRequest.SP_GID__c.trim() );
            } 
            else {
                theCMDRequest.SP_CustomerID__c = null;
            }
            if( theCMDRequest.SH_GID__c != null && theCMDRequest.SH_GID__c != '') {
                theCMDRequest.SH_CustomerID__c = mapGID_CustomerID.get( theCMDRequest.SH_GID__c.trim() );
            }
            else {
                theCMDRequest.SH_CustomerID__c = null;
            }
            if( theCMDRequest.BP_GID__c != null && theCMDRequest.BP_GID__c != '') {
                theCMDRequest.BP_CustomerID__c = mapGID_CustomerID.get( theCMDRequest.BP_GID__c.trim() );
            }
            else {
                theCMDRequest.BP_CustomerID__c = null;
            }
            if( theCMDRequest.PY_GID__c != null && theCMDRequest.PY_GID__c != '') {
                theCMDRequest.PY_CustomerID__c = mapGID_CustomerID.get( theCMDRequest.PY_GID__c.trim() );
            }
            else {
                theCMDRequest.PY_CustomerID__c = null;
            }
            if( theCMDRequest.ZI_GID__c != null && theCMDRequest.ZI_GID__c != '') {
                theCMDRequest.ZI_CustomerID__c = mapGID_CustomerID.get( theCMDRequest.ZI_GID__c.trim() );
            }
            else {
                theCMDRequest.ZI_CustomerID__c = null;
            }
            
            //
            if( theCMDRequest.GID__c != null && theCMDRequest.GID__c != ''){
                theCMDRequest.Global_Customer_ID__c = mapGID_CustomerID.get( theCMDRequest.GID__c.trim() );
            }
            else {
                theCMDRequest.Global_Customer_ID__c = null;
            }
        }
    }    

    public static void fetchSAPCMDids( List<CMD_Request__c> listCMDRequests ) {
        
        Map<string,SAP_CMD__c> mapFunlocSAPCMD = new Map<string,SAP_CMD__c>();
        for( SAP_CMD__c theSAPCMD : allSAPCMDs ) {
            mapFunlocSAPCMD.put( theSAPCMD.Customer_FunLoc_Number__c, theSAPCMD );
        }
        
        Map<Id, String> mapAccountGroup = new Map<Id, String>();
        for( SAP_CMD__c theSAPCMD : allSAPCMDs ){
            mapAccountGroup.put( theSAPCMD.Id, theSAPCMD.RecordType.Name );
        }
        
        //Added by Scarlett on 2015.03.25
        //Use Funloc # and Sales Organisation to find SAP CMD record
        Map<String, Map<String,Id>> mapFunlocSalesOrgSAPCMDIds = new Map<String, Map<String,Id>>();
        for(SAP_CMD__c theSAPCMD : allSAPCMDs){            
            if(mapFunlocSalesOrgSAPCMDIds.containsKey(theSAPCMD.Customer_FunLoc_Number__c)){
                mapFunlocSalesOrgSAPCMDIds.get(theSAPCMD.Customer_FunLoc_Number__c).put(theSAPCMD.Sales_Organisation__c, theSAPCMD.Id);
            } else {
                mapFunlocSalesOrgSAPCMDIds.put(theSAPCMD.Customer_FunLoc_Number__c, new Map<String, Id>{theSAPCMD.Sales_Organisation__c => theSAPCMD.Id});
            }
        }   
        
        for( CMD_Request__c theCMDRequest : listCMDRequests ) {
            if( theCMDRequest.SP_Funloc__c != null && theCMDRequest.SP_Funloc__c != '' ) {
                if( mapFunlocSAPCMD.containsKey(theCMDRequest.SP_Funloc__c) ) {
                    theCMDRequest.SP_Funloc_SAP_CMD__c = mapFunlocSAPCMD.get(theCMDRequest.SP_Funloc__c).Id;
                } else {
                    theCMDRequest.SP_Funloc_SAP_CMD__c = NULL;
                }
            } else {
                theCMDRequest.SP_Funloc_SAP_CMD__c = NULL;
            }
            if( theCMDRequest.SH_Funloc__c != null && theCMDRequest.SH_Funloc__c != '' ) {
                if( mapFunlocSAPCMD.containsKey(theCMDRequest.SH_Funloc__c) ) {
                    theCMDRequest.SH_Funloc_SAP_CMD__c = mapFunlocSAPCMD.get(theCMDRequest.SH_Funloc__c).Id;
                } else {
                    theCMDRequest.SH_Funloc_SAP_CMD__c = NULL;
                }
            } else {
                theCMDRequest.SH_Funloc_SAP_CMD__c = NULL;
            }
            if( theCMDRequest.PY_Funloc__c != null && theCMDRequest.PY_Funloc__c != '' ) {
                if( mapFunlocSAPCMD.containsKey(theCMDRequest.PY_Funloc__c) ) {
                    theCMDRequest.PY_Funloc_SAP_CMD__c = mapFunlocSAPCMD.get(theCMDRequest.PY_Funloc__c).Id;
                } else {
                    theCMDRequest.PY_Funloc_SAP_CMD__c = NULL;
                }
            } else {
                theCMDRequest.PY_Funloc_SAP_CMD__c = NULL;
            }
            if( theCMDRequest.BP_Funloc__c != null && theCMDRequest.BP_Funloc__c != '' ) {
                if( mapFunlocSAPCMD.containsKey(theCMDRequest.BP_Funloc__c) ) {
                    theCMDRequest.BP_Funloc_SAP_CMD__c = mapFunlocSAPCMD.get(theCMDRequest.BP_Funloc__c).Id;
                } else {
                    theCMDRequest.BP_Funloc_SAP_CMD__c = NULL;
                }
            } else {
                theCMDRequest.BP_Funloc_SAP_CMD__c = NULL;
            }
            if( theCMDRequest.ZI_Funloc__c != null && theCMDRequest.ZI_Funloc__c != '' ) {
                if( mapFunlocSAPCMD.containsKey(theCMDRequest.ZI_Funloc__c) ) {
                    theCMDRequest.ZI_Funloc_SAP_CMD__c = mapFunlocSAPCMD.get(theCMDRequest.ZI_Funloc__c).Id;
                } else {
                    theCMDRequest.ZI_Funloc_SAP_CMD__c = NULL;
                }
            } else {
                theCMDRequest.ZI_Funloc_SAP_CMD__c = NULL;
            } 
            
            //Modified by Scarlett - 2014.03.25        
            
            //Modified by Scarlett - 2014.04.03 (For general funloc)
            if( theCMDRequest.Funloc__c != null && theCMDRequest.Funloc__c != '' ) {
                //if( mapFunlocSAPCMD.containsKey(theCMDRequest.Funloc__c) ) {
                if( mapFunlocSalesOrgSAPCMDIds.containsKey(theCMDRequest.Funloc__c) ) {
                    //theCMDRequest.Funloc_SAP_CMD__c = mapFunlocSAPCMD.get(theCMDRequest.Funloc__c).Id;
                    
                    //Added by Scarlett on 2015.03.25 - Funloc # & Sales Organisation as search key
                    // Funloc => Sales Organisation => SAP CMD Id
                    theCMDRequest.Funloc_SAP_CMD__c = mapFunlocSalesOrgSAPCMDIds.get(theCMDRequest.Funloc__c).get(theCMDRequest.Sales_Organisation__c); 
                        
                    theCMDRequest.SAP_CMD_Account_Group__c = mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c);
                    if(mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z001 - Sold To / Ship To / Bill To / Payer' || 
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z005 - Sold To / Bill To / Payer' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z011 - Sold To' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z012 - Sold to / Ship To'||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'ZORG - Organizational Customers')
                        theCMDRequest.FLAG_Sold_to__c = True;
                    else
                        theCMDRequest.FLAG_Sold_to__c = False;                        
                    if(mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z001 - Sold To / Ship To / Bill To / Payer' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z002 - Ship To' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z012 - Sold to / Ship To'||
                        mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'ZORG - Organizational Customers')
                        theCMDRequest.FLAG_Ship_to__c = True;
                    else
                        theCMDRequest.FLAG_Ship_to__c = False;
                    if(mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z001 - Sold To / Ship To / Bill To / Payer' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z004 - Bill To' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z005 - Sold To / Bill To / Payer' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z013 - Payer / Bill To'
                       )
                        theCMDRequest.FLAG_Bill_to__c = True; 
                    else
                        theCMDRequest.FLAG_Bill_to__c = False; 
                    if(mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z001 - Sold To / Ship To / Bill To / Payer' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z003 - Payer' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z005 - Sold To / Bill To / Payer' ||
                       mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z013 - Payer / Bill To'
                       )
                        theCMDRequest.FLAG_Payer__c = True;
                    else
                        theCMDRequest.FLAG_Payer__c = False;
                    if(mapAccountGroup.get(theCMDRequest.Funloc_SAP_CMD__c) == 'Z010 - Intermediate Consignee')
                        theCMDRequest.FLAG_ZI__c = True;
                    else
                        theCMDRequest.FLAG_ZI__c = False;
                } else {
                    theCMDRequest.Funloc_SAP_CMD__c = NULL;
                    theCMDRequest.SAP_CMD_Account_Group__c = NULL;
                    theCMDRequest.FLAG_Sold_to__c = False;
                    theCMDRequest.FLAG_Ship_to__c = False;
                    theCMDRequest.FLAG_Bill_to__c = False; 
                    theCMDRequest.FLAG_Payer__c = False;
                }
            } else {
                theCMDRequest.Funloc_SAP_CMD__c = NULL;
                theCMDRequest.SAP_CMD_Account_Group__c = NULL;
                theCMDRequest.FLAG_Sold_to__c = False;
                theCMDRequest.FLAG_Ship_to__c = False;
                theCMDRequest.FLAG_Bill_to__c = False; 
                theCMDRequest.FLAG_Payer__c = False;
            }
        }
    }

    public static void fetchCACCs( List<CMD_Request__c> listCMDRequests ) {
//        Map<string , string> mapCACC_BaseRegion = new Map<string , string>();
        Map<Id , string> mapCACC_BaseRegion = new Map<Id , string>();
        Map<string , string> mapCACC_CustomerCategory = new Map<string , string>();
        Map<string , string> mapCACC_PDKeyAccount = new Map<string , string>();
        Map<string , string> mapCMDRequestRt = new Map<string , string>();
        for( Consolidated_Account_Code__c theCACC : allCACCs ) {
 //           mapCACC_BaseRegion.put( theCACC.Name, theCACC.Base_Region__c );
            mapCACC_BaseRegion.put(theCACC.Id, theCACC.Base_Region__c);
            mapCACC_CustomerCategory.put( theCACC.Name, theCACC.Customer_Category__c );
            mapCACC_PDKeyAccount.put( theCACC.Name, theCACC.PD_Key_Account__c );
        }        
        for(RecordType rt : allCMDRequestRts)
            mapCMDRequestRt.put(rt.DeveloperName, rt.Id);
        /* We are not using Con_Acct_SP_EMS__c anymore. Remarked by Scarlett on 2015.03.18
        for( CMD_Request__c theCMDRequest : listCMDRequests ) {
            if( theCMDRequest.Con_Acct_SP_EMS__c != null && theCMDRequest.Con_Acct_SP_EMS__c != '' ) {
//                if(mapCACC_BaseRegion.containsKey(String.valueOf(theCMDRequest.Con_Acct_SP_EMS__c).left(3))){
//                    theCMDRequest.Base_Region__c = mapCACC_BaseRegion.get(String.valueOf(theCMDRequest.Con_Acct_SP_EMS__c).left(3));
//                }
//                else{
//                    theCMDRequest.Base_Region__c = null;
//                }
                if(mapCACC_CustomerCategory.containsKey(String.valueOf(theCMDRequest.Con_Acct_SP_EMS__c).left(3))){
                    theCMDRequest.Customer_Category__c = mapCACC_CustomerCategory.get(String.valueOf(theCMDRequest.Con_Acct_SP_EMS__c).left(3));
                }
                else{
                    theCMDRequest.Customer_Category__c = null;
                }
                if(mapCACC_PDKeyAccount.containsKey(String.valueOf(theCMDRequest.Con_Acct_SP_EMS__c).left(3))){
                    theCMDRequest.PD_Key_Account__c = mapCACC_PDKeyAccount.get(String.valueOf(theCMDRequest.Con_Acct_SP_EMS__c).left(3));
                }
                else{
                    theCMDRequest.PD_Key_Account__c = null;
                }
            }
        }
        // We are not using Con_Acct_SP_EMS__c anymore. Remarked by Scarlett on 2015.03.18 
        */
        /* Scarlett 2015.03.27 remark for code quality - There is no content with this for loop 
        for( CMD_Request__c theCMDRequest : listCMDRequests ) {
            if( theCMDRequest.Consolidated_Account_Code__c != null){
            // && theCMDRequest.Consolidated_Account_Code__c != '' ){
                if(theCMDRequest.RecordTypeId == mapCMDRequestRt.get('SAP_New_Funloc_Request')){//'SAP_New_Funloc_Request'){
                    if(mapCACC_BaseRegion.containsKey(theCMDRequest.Consolidated_Account_Code__c)){
                        //Do not auto copy Base Region to GSM Controller Approver Group, need to confirm with Edwin
                        //2014.12.04
                        //theCMDRequest.GSM_Controller_Approver_Group__c = mapCACC_BaseRegion.get(theCMDRequest.Consolidated_Account_Code__c);
                    }
                }
            }
        }
        */
    }
    public static void eraseRequestFields( List<CMD_Request__c> listCMDRequests){
        for( CMD_Request__c theCMDRequest : listCMDRequests ){
            if(theCMDRequest.Request_Status__c == 'Approved' || 
               theCMDRequest.Request_Status__c == 'Completed' ||
               theCMDRequest.Request_Status__c == 'Pending for Approval'){
                   theCMDRequest.Effective_Date__c = null;
                   theCMDRequest.Ready_to_Submit__c = False;
                   theCMDRequest.Request_Status__c = 'Draft';     
                   theCMDRequest.Update_SAP_CMD_Failed__c = False;
                   theCMDRequest.Update_SAP_CMD_Error_Message__c = null;
                   theCMDRequest.SAP_CMD_Throughput_Time__c = null;
                   theCMDRequest.Approval_Submission_Date__c = null;
                   theCMDRequest.CMD_Officer_Pending_Since__c = null;
                   theCMDRequest.CMD_Officer_Approved_Rejected_Date__c = null;
                   theCMDRequest.Approval_Completed_Date__c = null;
                   theCMDRequest.Request_Completed_Date__c = null;
                   theCMDRequest.Responsible_CMD_Officer__c = null;
            }
        }
    }

    public static void fetchCMDOfficer( List<CMD_Request__c> listCMDRequests ){
        Map<Id, String> mapCMDOfficer = new Map<Id, String>();
        for(User officer : allCMDOfficers)
            mapCMDOfficer.put(officer.Id, officer.Name);
        
        for(CMD_Request__c theCMDRequest : listCMDRequests){
            if(theCMDRequest.CMD_Officer_Approved_Rejected_Date__c != null && String.valueof(theCMDRequest.CMD_Officer_Approved_Rejected_Date__c) != ''){           
                if(theCMDRequest.LastModifiedById != null && string.valueof(theCMDRequest.LastModifiedById) != ''){
                    if(mapCMDOfficer.containsKey(theCMDRequest.LastModifiedById))
                        theCMDRequest.Responsible_CMD_Officer__c = theCMDRequest.LastModifiedById;
                }
            }              
        }
    }  
    // SFDC-729
    public static void setDefaultValueForNewMANUandSBEFunloc( List<CMD_Request__c> listCMDRequests ){
     fetchCMDReqRecordTypes();
     for(CMD_Request__c theCMDRequest : listCMDRequests)
     {
         if(theCMDRequest.Lockbox__c == null && theCMDRequest.Sales_Organisation__c == SALES_ORG_NL60 && theCMDRequest.RecordtypeId==sapNewSBEFun_Id){
             theCMDRequest.Lockbox__c = 'MUL.CUR';
            }
             if(theCMDRequest.Lockbox__c == null && theCMDRequest.Sales_Organisation__c == SALES_ORG_US60 && theCMDRequest.RecordtypeId==sapNewSBEFun_Id){
             theCMDRequest.Lockbox__c = 'CIT-WIR';
            }
          if(theCMDRequest.Incoterms_2__c == null && theCMDRequest.RecordtypeId==sapNewSBEFun_Id){
             theCMDRequest.Incoterms_2__c = 'Services';
          }
          if(theCMDRequest.Lockbox__c == null && theCMDRequest.RecordtypeId==sapNewMANUFun_Id){
             theCMDRequest.Lockbox__c = 'NOREMIT';
          }
      }  
   }

    /*
    public static void fetchCustomerType( List<CMD_Request__c> listCMDRequests ){
        List<Customer__c> allCustomers = [
            SELECT  Id,
                    Type__c
            FROM    Customer__c
        ];
        
        List<SAP_CMD__c> allSAPCMDs = [
            SELECT  Id,
                    HUB_Customer__c
            FROM    SAP_CMD__c
            WHERE   HUB_Customer__c != Null
        ];
        
        Map<Id, String> mapSAPCMD = new Map<Id, String>();
        for(SAP_CMD__c theSAPCMD : allSAPCMDs)
            mapSAPCMD.put(theSAPCMD.Id, theSAPCMD.HUB_Customer__c);
        
        Map<Id, String> mapCustomerType = new Map<Id, String>();
        for(Customer__C theCustomer : allCustomers)
            mapCustomerType.put(theCustomer.Id, theCustomer.Type__c);
        
        for(CMD_Request__c theCMDRequest : listCMDRequests){
            if( theCMDRequest.Funloc_SAP_CMD__c != null && theCMDRequest.Funloc__c != '' ){
                if( mapCustomerType.containsKey(mapSAPCMD.get(theCMDRequest.Funloc_SAP_CMD__c)) )
                    theCMDRequest.Customer_Type__c = mapCustomerType.get(mapSAPCMD.get(theCMDRequest.Funloc_SAP_CMD__c));
            }
        }

    }
    */
    /**
    public static void fetchFunlocIDs( List<CMD_Request__c> listCMDRequests ) {

        List<FunLoc__c> allFunLocs = [
            SELECT  Id, FunLoc_Number_Text__c
            FROM    FunLoc__c
            WHERE   FunLoc_Number__c >= 0
            AND     FunLoc_Number__c < 120000 
            ORDER BY FunLoc_Number__c
        ];        List<FunLoc__c> allFunLocs12k = [
            SELECT  Id, FunLoc_Number_Text__c
            FROM    FunLoc__c
            WHERE   FunLoc_Number__c >= 120000
            AND     FunLoc_Number__c < 140000 
            ORDER BY FunLoc_Number__c
        ];
        List<FunLoc__c> allFunLocs14k = [
            SELECT  Id, FunLoc_Number_Text__c
            FROM    FunLoc__c
            WHERE   FunLoc_Number__c >= 140000
            AND     FunLoc_Number__c < 170000 
            ORDER BY FunLoc_Number__c
        ];
        List<FunLoc__c> allFunLocs17k = [
            SELECT  Id, FunLoc_Number_Text__c
            FROM    FunLoc__c
            WHERE   FunLoc_Number__c >= 170000
            AND     FunLoc_Number__c < 230000 
            ORDER BY FunLoc_Number__c
        ];
        Map<string , string> mapFunloc_FunlocID = new Map<string , string>();
        for( FunLoc__c theFunLoc : allFunLocs ) {
            mapFunloc_FunlocID.put( theFunLoc.FunLoc_Number_Text__c, String.valueOf(theFunLoc.Id).trim() );
        }
        for( FunLoc__c theFunLoc : allFunLocs12k ) {
            mapFunloc_FunlocID.put( theFunLoc.FunLoc_Number_Text__c, String.valueOf(theFunLoc.Id).trim() );
        }
        for( FunLoc__c theFunLoc : allFunLocs14k ) {
            mapFunloc_FunlocID.put( theFunLoc.FunLoc_Number_Text__c, String.valueOf(theFunLoc.Id).trim() );
        }
        for( FunLoc__c theFunLoc : allFunLocs17k ) {
            mapFunloc_FunlocID.put( theFunLoc.FunLoc_Number_Text__c, String.valueOf(theFunLoc.Id).trim() );
        }

        for( CMD_Request__c theCMDRequest : listCMDRequests ) {
            if( theCMDRequest.SP_Funloc__c != null && theCMDRequest.SP_Funloc__c != '' ) {
                theCMDRequest.SP_Funloc_Id__c = [
                    SELECT  Id, FunLoc_Number_Text__c
                    FROM    FunLoc__c
                    WHERE   FunLoc_Number_Text__c = :theCMDRequest.SP_Funloc__c
                    LIMIT 1
                ].FunLoc_Number_Text__c;
            }
            if( theCMDRequest.SH_Funloc__c != null && theCMDRequest.SH_Funloc__c != '' ) {
            }
            if( theCMDRequest.PY_Funloc__c != null && theCMDRequest.PY_Funloc__c != '' ) {
            }
            if( theCMDRequest.BP_Funloc__c != null && theCMDRequest.BP_Funloc__c != '' ) {
            }
            if( theCMDRequest.ZI_Funloc__c != null && theCMDRequest.ZI_Funloc__c != '' ) {
            }
        }
    }
**/   

  

  
  
  
   /* To send email notification to recipeints based on the group name selected by CMD officer 
      when CMD request status is changed to completed (for first time)  */  
     
   public static void DispatchEmail(List<CMD_Request__c> listCMDRequests, map<Id, CMD_Request__c> mapOldCMDReq){
     system.debug('entered1');
   /*  For(recordType rt:[Select Id, Name,DeveloperName From RecordType 
                        Where IsActive=true AND (SobjectType = 'CMD_Request__c' and 
                        (DeveloperName =:TYPE_New_CmdReq OR DeveloperName =:TYPE_Edit_CmdReq OR DeveloperName =:TYPE_New_SBE_CmdReq))])
       {
         if(rt.DeveloperName == TYPE_New_CmdReq) 
            {
               sapNewFun_Id = rt.id;  
            }
         else if(rt.DeveloperName == TYPE_Edit_CmdReq)
            {
               sapEditFun_Id = rt.id;  
            }
         else if(rt.DeveloperName == TYPE_New_SBE_CmdReq)
            {
               sapNewSBEFun_Id = rt.id;
            }
       } */
    fetchCMDReqRecordTypes();
    string[] lstCcEmailIds = new list<String> ();
    List<List<String>> listStrEmailIds= new List<List<String>>();
       
    for( CMD_Request__c objCMDReq : listCMDRequests)
    {
     string[] lstEmailIds = new list<String> ();
     string[] lstFinalEmailIds = new list<String> ();     
     CMD_Request__c oldobjCMDReq = mapOldCMDReq.get(objCMDReq.Id); 
        
     If(objCMDReq.Request_Status__c=='Completed' && oldobjCMDReq.Request_Status__c!='Completed' )
     { 
      If(objCMDReq.Recipient_List__c!= null &&
        (objCMDReq.RecordTypeId == sapEditFun_Id||objCMDReq.RecordTypeId ==sapNewFun_Id||objCMDReq.RecordTypeId == sapNewSBEFun_Id||objCMDReq.RecordTypeId ==sapEditSBEFun_Id||objCMDReq.RecordTypeId == sapNewMANUFun_Id||objCMDReq.RecordTypeId ==sapEditMANUFun_Id))
      {    
      
       system.debug('entered2' + objCMDReq.RecordTypeId);          
       String[] lsttoReceipient= objCMDReq.Recipient_List__c.split(';');
     
       // Preparing list of recipients based on the group name selected by CMD officer  
            
        for(String recepient:lsttoReceipient)
        {
         CMD_Request_Completion_Mails__c  csLog =  CMD_Request_Completion_Mails__c.getValues(recepient);
         lstEmailIds = new list<String> (); //new
         if(csLog.Email_Ids__c!= null && csLog.Email_Ids__c!= '')
         {
          lstEmailIds = csLog.Email_Ids__c.split(';');
          lstFinalEmailIds.addall(lstEmailIds);
         
         } 
        }
        lstFinalEmailIds.add(objCMDReq.ownerid);
      } 
       //only for new funloc request (SFDC 285)
       
       string[] lstSPEmailIds = new list<String> ();
       
      If(objCMDReq.RecordTypeId ==sapNewFun_Id)
       {   
          CMD_Request_Completion_Mails__c  csLogSP =  CMD_Request_Completion_Mails__c.getValues(SP_Team);
          lstSPEmailIds = new list<String> (); 
          
       if(csLogSP!=null)
       {
        if(csLogSP.Email_Ids__c != null && csLogSP.Email_Ids__c != '')
         {
           lstSPEmailIds = csLogSP.Email_Ids__c.split(';'); 
           lstFinalEmailIds.addall(lstSPEmailIds);  
           system.debug('enteredSPteam2' + lstFinalEmailIds);      
         }  
       } 
     } 
      listStrEmailIds.add(lstFinalEmailIds) ;
    
  }
 } 
    
     if(!hasEmailAlreadySent()){
        
        if(listStrEmailIds != null && listStrEmailIds.size()>0)
        {
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
         list<CMD_Request__c> lstCmdReq = new list<CMD_Request__c>();
         
         for(Integer i=0;i<listCMDRequests.size();i++)
         {
          // Get the email message with the New Request Email Template
          if(listCMDRequests[i].RecordTypeId == sapNewFun_Id ||listCMDRequests[i].RecordTypeId == sapNewSBEFun_Id||listCMDRequests[i].RecordTypeId == sapNewMANUFun_Id)
          {
            message = getEmail(listStrEmailIds[i],listCMDRequests[i],true);  
          }
          // Get the email message with the Edit Request Email Template   
          else if(listCMDRequests[i].RecordTypeId == sapEditFun_Id ||listCMDRequests[i].RecordTypeId == sapEditSBEFun_Id||listCMDRequests[i].RecordTypeId == sapEditMANUFun_Id)
          {
            message = getEmail(listStrEmailIds[i],listCMDRequests[i],false);  
          }
             
           if(message.getToAddresses()!=null)
           {
            mails.add(message); 
           }              
         } 
     
       Savepoint sp = Database.setSavepoint();    
      
        //Sending the email list in a single call.
       If(mails!=null)
       {
       Messaging.sendEmail(mails);
      
       Database.rollback(sp);  
                       
       CMD_Request_Completion_Mails__c  csLogCmd =  CMD_Request_Completion_Mails__c.getValues(CMD_Team); 
       lstCcEmailIds = new list<String> (); //new
       if(csLogCmd!=null)
       {
        if(csLogCmd.Email_Ids__c != null && csLogCmd.Email_Ids__c != '')
         {
          lstCcEmailIds = csLogCmd.Email_Ids__c.split(';');        
         }  
       } 
       List<Messaging.SingleEmailMessage> msgListToBeSend = new
       List<Messaging.SingleEmailMessage>();
       for (Messaging.SingleEmailMessage email : mails) 
       {
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setToAddresses(email.getToAddresses());
        emailToSend.setCcAddresses(lstCcEmailIds);
        emailToSend.setPlainTextBody(email.getPlainTextBody());
        emailToSend.setHTMLBody(email.getHTMLBody());
        emailToSend.setSubject(email.getSubject());
        emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());   
        msgListToBeSend.add(emailToSend);
       }
        
        Messaging.sendEmail(msgListToBeSend);
    system.debug('entered4' + msgListToBeSend);
       
        setEmailAlreadySent();
       } 
      }
   }   
        
  }
  
     
     // Method to send email based the visualforce email template and email id's provided by dispatchemail method 
   public static Messaging.SingleEmailMessage getEmail(String[] listEmailId,cmd_request__c cmdReqId, Boolean isNewRequest) {    
    Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
    Id templateId ;   
    for(EmailTemplate em:[Select Id, Name,DeveloperName From EmailTemplate 
                          Where (DeveloperName =:New_Email_Template OR DeveloperName =:Edit_Email_Template )])
     {
         if(em.DeveloperName == New_Email_Template) 
            {
               emailNewFun_Id = em.id;  
            }
         else if(em.DeveloperName == Edit_Email_Template)
            {
               emailEditFun_Id = em.id;  
            }
         
     }
       
    if(isNewRequest == true)
     {
        templateId = emailNewFun_Id; //Get the "CMD_New_Request_Completed" Email Template for New Requests
     }
    
    if(isNewRequest == false )
     {
        templateId = emailEditFun_Id; //Get the "CMD_Edit_Request_Completed" Email Template for Edit Requests
     }
       
    OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where displayname=: OrgWide_Address];

    String[] toAddresses = new List<String>();
    toAddresses= listEmailId ;
 
    if(toAddresses!= null &&toAddresses.size()>0)
    {system.debug('entered5' + toAddresses);
     mailMessage.setTargetObjectId(cmdReqId.ownerid);
     mailMessage.setTemplateID(templateId);
     mailMessage.setToAddresses(toAddresses);
     mailMessage.setWhatID(cmdReqId.id);
     mailMessage.setSaveAsActivity(false);
    if ( owea.size() > 0 ) 
    {
     mailMessage.setOrgWideEmailAddressId(owea.get(0).Id);
    }
   }
   return mailMessage; 
  }
  
  /* Method to fetch the SAP CMD Title and Output Message from the SAP CMD record and to store the value in the CMD Request record   */  
  
 public static void fetchSapCmdTitle(list<CMD_Request__c> newCMDReqList, map<Id, CMD_Request__c> mapOldCMDReq )
 {    
      set<string> setCmdReqId = new set<string>();
      map<string,map<id,string>>  mapCMDReqIdTitle = new map<string,map<id,string>>();
      map<string,map<id,string>>  mapCMDReqIdOutput = new map<string,map<id,string>>();
      list<sap_cmd__c> lstSapCmd = new list<sap_cmd__c>();
      list<CMD_Request__c> lstCmdReq = new list<CMD_Request__c>();
       if(newCMDReqList!= null && newCMDReqList.size()>0)
       {
       for (CMD_Request__c  objCMDReq :newCMDReqList)
        {          
           CMD_Request__c oldObjCMDReqRec = mapOldCMDReq.get(objCMDReq.Id);
           If(objCMDReq.Request_Status__c=='Completed' && oldobjCMDReqRec.Request_Status__c!='Completed') 
            { 
                setCmdReqId.add(objCMDReq.id);
                
            }         
       }
        
       if(!setCmdReqId.isEmpty()) 
       {
       lstSapCmd = [select CMD_Request_ID_Text__c,SAP_CMD_Title__c,output_message__c from sap_cmd__c where CMD_Request_ID_Text__c = :setCmdReqId]; 
            
       }  
                      
        if(lstSapCmd!= null && lstSapCmd.size()>0)
       {     
           for(sap_cmd__c sapCmd:lstSapCmd)
           {  
           
           if(mapCMDReqIdTitle.containskey(sapCmd.CMD_Request_ID_Text__c))
            {
               
                If(!mapCMDReqIdTitle.get(sapCmd.CMD_Request_ID_Text__c).containskey(sapCmd.id))
                     {
                         mapCMDReqIdTitle.get(sapCmd.CMD_Request_ID_Text__c).put(sapCmd.id,sapCmd.SAP_CMD_Title__c);                    
                     }
             }
             else
                {
                      mapCMDReqIdTitle.put((sapCmd.CMD_Request_ID_Text__c),new map<id,string>{sapCmd.id => sapCmd.SAP_CMD_Title__c});                    
                }
         
            }
         
          for(sap_cmd__c sapCmd:lstSapCmd){  
           
           if(mapCMDReqIdOutput.containskey(sapCmd.CMD_Request_ID_Text__c))
            {
             
                If(!mapCMDReqIdOutput.get(sapCmd.CMD_Request_ID_Text__c).containskey(sapCmd.id))
                     {
                         mapCMDReqIdOutput.get(sapCmd.CMD_Request_ID_Text__c).put(sapCmd.id,sapCmd.output_message__c);                     
                     }
               }
             else
                {
                      mapCMDReqIdOutput.put((sapCmd.CMD_Request_ID_Text__c),new map<id,string>{sapCmd.id => sapCmd.output_message__c});
                }
         }
         
      }  
         
   
       for(CMD_Request__c cmdReq : newCMDReqList){ 
    
        string strTitle ='';
        string strOutput='';
            for(sap_cmd__c sapCmdRec:lstSapCmd){ 
         
             if(mapCMDReqIdTitle.containskey(cmdReq.id) && cmdReq.id==sapCmdRec.CMD_Request_ID_Text__c && sapCmdRec.SAP_CMD_Title__c!= null && sapCmdRec.SAP_CMD_Title__c!= '' )
             {
                 string strTempTitle = mapCMDReqIdTitle.get(cmdReq.id).get(sapCmdRec.id);
                 strTitle += strTempTitle + '\n';
                   cmdReq.Title__c= strTitle;             
            }  
            if(mapCMDReqIdOutput.containskey(cmdReq.id) && cmdReq.id==sapCmdRec.CMD_Request_ID_Text__c && sapCmdRec.output_message__c!= null && sapCmdRec.output_message__c!= '' )
             {
           
                CMD_Request_Completion_Output__c csLog =  CMD_Request_Completion_Output__c.getValues(mapCMDReqIdOutput.get(cmdReq.id).get(sapCmdRec.id));
                if(csLog.Output__c!= null && csLog.Output__c!= '')
                {
                 string strTempOutput= csLog.Output__c;
                 strOutput += strTempOutput + '\n';
                } 
                   cmdReq.Output__c= strOutput;    
             }  
         }
       } 
    }
  }
  
  
/* To verify that the Dispacthing of Emails to the respective is sent or not to the recipeints based on the group name selected by CMD officer 
   when CMD request status is changed to completed (for first time) , Thus to avoid the redunduncy of Emails sent
*/

     private static boolean emailAlreadySent = false; 
      public static boolean hasEmailAlreadySent()
      { 
         return emailAlreadySent; 
      }
    
     public static void setEmailAlreadySent() 
      {
         emailAlreadySent = true;
      } 

          
 }