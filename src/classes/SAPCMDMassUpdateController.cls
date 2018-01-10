/*********************************************************************************************************************************************/
// Last Modified by      : shridevi
// Last Modification Date: 27-7-2016
// Description           : Optimised the code as part of SIR 1114-to load less data so that hitting the governer limits(Heap size) can be avoided.
/***************************************************************************************************************** */
/*********************************************************************************************************************************************/
// Last Modified by      : shridevi
// Last Modification Date: 27-7-2016
// Description           : Modified the code as part of SIR 1014-to load ZA Picklist Values which starts with "MX" & "CN" & "US5" & "RO" & "CZ" and to load ZS Picklist Values except the values which starts with "MX" & "CN" & "US5" & "RO" & "CZ"
/***************************************************************************************************************** */
/*********************************************************************************************************************************************/
// Last Modified by      : shridevi
// Last Modification Date: 3-8-2016
// Description           : SIR 215- Enable the Delete Row, Copy row, and Add Row buttons irrespective of status for ZS mass update type on SAPCMDMassUpdate page.
/*********************************************************************************************************************************************/
/*********************************************************************************************************************************************/
// Last Modified by      : shridevi
// Last Modification Date: 21-11-2016
// Description           : SIR 1371- Error in saving funlocs
/*********************************************************************************************************************************************
   Last Modified by      : Baji
   Last Modification Date: Mar 03, 2017
   Description           : SFDC 348 - To fix Apex CPU Time limit Exceeded error   
**********************************************************************************************/

public class SAPCMDMassUpdateController {
    
    //private static final String CMD_REQUEST_SAP_MASS_UPDATE_RECORD_TYPE_ID = '012D0000000QmBTIA0';
        
    private final CMD_Request__c theRequest;
    private static final Set<String> statusSet=new Set<String>{'Draft','Ready to Submit','Pending for Approval'};
    private static final List<String> headerZa=new List<String>{'Customer FunLoc Number','SAP CMD','Legal Name','Person Name old','Person Name'};
    private static final List<String> headerZs=new List<String>{'Customer FunLoc Number','SAP CMD','Legal Name','Person Name old','Person Name'};
    private static final List<String> headerAddress=new List<String>{'Customer FunLoc Number','SAP CMD','Legal Name','Name 2','Name 3','Name 4','Street','City','State','Country','Zip'};
                    
    private static final String MASSUPDATETYPE_ZA='ZA';
    private static final String MASSUPDATETYPE_ZS='ZS';
    private static final String MASSUPDATETYPE_ADDRESS='Address';
    private static final Integer COLUMN_SIZE_ZA=5;
    private static final Integer COLUMN_SIZE_ZA_TWO=2;
    private static final Integer COLUMN_SIZE_ZS=5;
    private static final Integer COLUMN_SIZE_ZS_TWO=2;
    private static final Integer COLUMN_SIZE_ADDRESS=12;
    private static final String COLUMN_EXCEEDED_ZA='Number of column exceded in csv file Please mention only 5 columns in csv file';
    private static final String COLUMN_EXCEEDED_ZS='Number of column exceded in csv file Please mention only 5 columns in csv file';
    private static final String COLUMN_EXCEEDED_ADDRESS='Number of column exceded in csv file Please mention only 12 columns in csv file';
    private static final String COLUMN_ORDER_ZA='Order of column or Header name of column is not as per template in csv file Please refer template';
    private static final String COLUMN_ORDER_ZS='Order of column or Header name of column is not as per template in csv file Please refer template';
    private static final String COLUMN_ORDER_ADDRESS='Order of column or Header name of column is not as per template in csv file Please refer template';
   
   // pulbic Map<id,Customer__c> mapCustomers=new map<id,Customer__c>();
    public integer count{get;set;}
    public ApexPages.StandardController stdController1 { get; set; }
    public boolean refreshPage{get;set;}
    public boolean blEnableEdit{get; set;}
    public List<FunlocWrapper> listFunlocWrapper { get; set; }
    public Boolean showTextbox { get; set; }
    public static String massUpdateType { get; set; }
    public String RequestStatus { get;set; }
    public Boolean ticketOpen { get;set; }
    public String rowToBeRemoved { get; set; }
    public String rowToBeReplicated { get; set; }
    public String columnToBeReplicated { get; set; }
    public List<String> ZAList { get; set; }
    public List<String> ZSList { get; set; }
    public static Blob contentFile { get; set; }
    public static String fileString { get; set; }
    public static String nameFile { get; set; }
    public List<ProcessInstance> processInstance=new  List<ProcessInstance>();
    public static list<id> customerId=new list<id>();
    private static List<SAP_CMD__c> allSAPCMDs = new List<SAP_CMD__c>();
    private static Map<String,SAP_CMD__c> mapFunlocSAPCMD = new Map<String,SAP_CMD__c>();
    private static List<Partner_Function__c> allPartnerFunctions = new List<Partner_Function__c>();
    private static Map<String,Map<Id,Partner_Function__c>> mapSAPCMDPartnerFunctions = new Map<String,Map<Id,Partner_Function__c>>();
    private static List<FunlocWrapper> theProcessedCSV = new List<FunlocWrapper>();
    public id requestId{get;set;}
    public Map<id,Customer__c> mapCustomers = new Map<id,Customer__c>();
    public String Actor{get;set;}
    public id urlid{get;set;}
    public class FunlocWrapper {
        public String funloc { get; set; }
        public String index { get; set; }
        public Boolean isDupe { get; set; }
        public String rowStyleClass { get; set; }
        public String detailId { get; set; }
        public String sapCMD { get; set; }
        public String sapCMDName { get; set; }
        public String accountName { get; set; }
        public String oldLegalName { get; set; }
        public String newLegalName { get; set; }
        public String oldName2 { get; set; }
        public String newName2 { get; set; }
        public String oldName3 { get; set; }
        public String newName3 { get; set; }
        public String oldName4 { get; set; }
        public String newName4 { get; set; }
        public String oldStreet { get; set; }
        public String newStreet { get; set; }
        public String oldStreet4 { get; set; }
        public String newStreet4 { get; set; }
        public String oldCity { get; set; }
        public String newCity { get; set; }
        public String oldStateProvince { get; set; }
        public String newStateProvince { get; set; }
        public String oldCountry { get; set; }
        public String newCountry { get; set; }
        public String oldZip { get; set; }
        public String newZip { get; set; }
        public String oldZA { get; set; }
        public String newZA { get; set; }
        public String oldZS { get; set; }
        public String newZS { get; set; }
        public String SapCMDRecordType{ get; set; }
        public String Name1ServiceProvider{ get; set;}
        
    }    
public List<ProcessInstanceStep> Processsteps=new List<ProcessInstanceStep>();

public SAPCMDMassUpdateController(ApexPages.StandardController stdController) 
{   
    urlid=apexpages.currentpage().getparameters().get('id');
    system.debug('urlid'+urlid);
    refreshPage=false;
    stdController1= stdController;  
        this.theRequest = (CMD_Request__c)stdController.getRecord();
         //actor='<script> func(); </script>';
         System.debug(' this.theRequest :::'+this.theRequest);
       
        requestId=this.theRequest.id;
        
        CMD_Request__c theCMDRequest = [
            SELECT  Id, 
                    Name,
                    RecordType.Name,
                    Mass_Update_Type__c,
                    Request_Status__c
            FROM    CMD_Request__c
            WHERE IsDeleted = FALSE
            AND     Id = :this.theRequest.Id
        ];
        
      System.debug('theCMDRequest:::'+theCMDRequest );
       
    //Actor='test';
     visibility(theCMDRequest);
     
        //modified by Ghanalingamurthy
        //Add validation to prevent approved tickets from being edited or deleted 
      
       
        
        
        massUpdateType = theCMDRequest.Mass_Update_Type__c;
        System.debug('mass'+theCMDRequest.Mass_Update_Type__c);

        RequestStatus = theCMDRequest.Request_Status__c;
        if( theCMDRequest.Request_Status__c == 'Draft' 
            || theCMDRequest.Request_Status__c == 'Ready to Submit'  
        ){
            ticketOpen = true;  
        } else {
            ticketOpen = false;  
        }

        listFunlocWrapper = new List<FunlocWrapper>();
        
        showTextbox = false;

        querySAPCMD();
        queryPartnerFunction();
    
     /*   
        List<CMD_Request_SAP_Mass_Update_Detail__c> theRequestDetails = [
            SELECT  Id,
                    Funloc__c,
                    Legal_Name_New__c,
                    Name_2_New__c,
                    Name_3_New__c,
                    Name_4_New__c,
                    Street_New__c,
                    Street_4_New__c,
                    City_New__c,
                    State_Province_New__c,
                    Country_New__c,
                    Zip_New__c,
                    ZA_New__c,
                    ZS_New__c
            FROM CMD_Request_SAP_Mass_Update_Detail__c
            WHERE CMD_Request__c = :theRequest.Id
        ];
        */
        for( CMD_Request_SAP_Mass_Update_Detail__c theDetail : [SELECT  Id,Funloc__c,Legal_Name_New__c,Name_2_New__c,Name_3_New__c,Name_4_New__c,Street_New__c,Street_4_New__c,City_New__c,State_Province_New__c,Country_New__c,Zip_New__c,ZA_New__c,ZS_New__c  FROM CMD_Request_SAP_Mass_Update_Detail__c WHERE CMD_Request__c = :theRequest.Id]) 
        {
            FunlocWrapper theFunlocWrapper = new FunlocWrapper();
            if( theDetail.Funloc__c != null ) {
                theFunlocWrapper.funloc = theDetail.Funloc__c;
                theFunlocWrapper.detailId = theDetail.Id;
                if( querySAPCMD( theDetail.Funloc__c ) != null ) {
                    theFunlocWrapper.sapCMD = querySAPCMD( theDetail.Funloc__c ).Id;
                    theFunlocWrapper.sapCMDName = querySAPCMD( theDetail.Funloc__c ).Name;
                    theFunlocWrapper.accountName = querySAPCMD( theDetail.Funloc__c ).Account_Name__c;
                    theFunlocWrapper.oldLegalName = querySAPCMD( theDetail.Funloc__c ).Legal_Name__c;
                    theFunlocWrapper.oldName2 = querySAPCMD( theDetail.Funloc__c ).Name_2__c;
                    theFunlocWrapper.oldName3 = querySAPCMD( theDetail.Funloc__c ).Name_3__c;
                    theFunlocWrapper.oldName4 = querySAPCMD( theDetail.Funloc__c ).Name_4__c;
                    theFunlocWrapper.oldStreet = querySAPCMD( theDetail.Funloc__c ).Street_1__c;
                    theFunlocWrapper.oldStreet4 = querySAPCMD( theDetail.Funloc__c ).Street_2__c;
                    theFunlocWrapper.oldCity = querySAPCMD( theDetail.Funloc__c ).City__c;
                    theFunlocWrapper.oldStateProvince = querySAPCMD( theDetail.Funloc__c ).State_Province__c;
                    theFunlocWrapper.oldCountry = querySAPCMD( theDetail.Funloc__c ).Country__c;
                    theFunlocWrapper.oldZip = querySAPCMD( theDetail.Funloc__c ).Zip__c;
                    theFunlocWrapper.oldZA = queryPartnerFunction( 'ZA', theFunlocWrapper.sapCMD );
                    theFunlocWrapper.oldZS = queryPartnerFunction( 'ZS', theFunlocWrapper.sapCMD );
                    theFunlocWrapper.SapCMDRecordType=querySAPCMD( theDetail.Funloc__c ).RecordType.Name;
                    theFunlocWrapper.Name1ServiceProvider=querySAPCMD( theDetail.Funloc__c ).Name_1_Service_Provider__c;
                    System.debug('rec type:'+theFunlocWrapper.SapCMDRecordType);
                    System.debug('theFunlocWrapper.Name1ServiceProvider:'+theFunlocWrapper.Name1ServiceProvider);
                }
                theFunlocWrapper.newLegalName = theDetail.Legal_Name_New__c;
                theFunlocWrapper.newName2 = theDetail.Name_2_New__c;
                theFunlocWrapper.newName3 = theDetail.Name_3_New__c;
                theFunlocWrapper.newName4 = theDetail.Name_4_New__c;
                theFunlocWrapper.newStreet = theDetail.Street_New__c;
                theFunlocWrapper.newStreet4 = theDetail.Street_4_New__c;
                theFunlocWrapper.newCity = theDetail.City_New__c;
                theFunlocWrapper.newStateProvince = theDetail.State_Province_New__c;
                theFunlocWrapper.newCountry = theDetail.Country_New__c;
                theFunlocWrapper.newZip = theDetail.Zip_New__c;
                theFunlocWrapper.newZA = theDetail.ZA_New__c;
                theFunlocWrapper.newZS = theDetail.ZS_New__c;
                //theFunlocWrapper.Name1ServiceProvider=theDetail.Name_1_Service_Provider__c;
            }
            
             System.debug('the funloc:'+theFunlocWrapper);
            listFunlocWrapper.add( theFunlocWrapper );
        }
        this.reindex();
    }
    
 // Added by Shridevi- SIR 215- to lock the record when the approval goes to cmd officer or status becomes approved.   
public void visibility(CMD_Request__c theCMDRequest)
{

      if(statusSet.contains(theCMDRequest.Request_Status__c))
        {
            blEnableEdit=true;        
        }
        else
        {
            blEnableEdit=false;
        }
          
         for(ProcessInstance instance :[SELECT Id, targetObjectId,(select id,actor.name from Workitems) FROM ProcessInstance where targetObjectId=:requestId])
          {
          for(ProcessInstanceWorkitem Workitems: instance.Workitems)
                { 
                  if(Workitems.Actor.Name=='CMD Officers')
                        blEnableEdit=false; 
                }
          }
      

}
    private static void querySAPCMD() {
    
        
       /************************ Modified by shridevi as part of SIR 1114*********************************/ 
     /*   allSAPCMDs = [
            SELECT  Id, 
                    Name,
                    RecordType.Name,
                    FunLoc__c,
                    Customer_FunLoc_Number__c,
                    Account_Name__c,
                    Legal_Name__c,
                    Name_2__c,
                    Name_3__c,
                    Name_4__c,
                    Street_1__c,
                    Street_2__c,
                    City__c,
                    State_Province__c,
                    Country__c,
                    Zip__c
            FROM    SAP_CMD__c
            WHERE IsDeleted = FALSE
        ];*/
 /*************************************************************************************************************/
        for( SAP_CMD__c theSAPCMD : [SELECT  Id,Name_1_Service_Provider__c,Name,RecordType.Name,HUB_Customer__c,FunLoc__c,Customer_FunLoc_Number__c,Account_Name__c,Legal_Name__c,Name_2__c,Name_3__c,Name_4__c,Street_1__c,Street_2__c,City__c,State_Province__c,Country__c,Zip__c FROM SAP_CMD__c WHERE IsDeleted = FALSE]) //modified as part of SIR 1114- Replaced the list allSAPCMDs by query
         {
            mapFunlocSAPCMD.put( theSAPCMD.Customer_FunLoc_Number__c , theSAPCMD );
            System.debug('RecordType.Name='+theSAPCMD.RecordType.Name);
            System.debug('RecordType.Name='+theSAPCMD.Name_1_Service_Provider__c);
            customerId.add(theSAPCMD.HUB_Customer__c);
        }
    }

    private static SAP_CMD__c querySAPCMD( String theFunloc ) {
        if( mapFunlocSAPCMD.containsKey(theFunloc) ) {
            return mapFunlocSAPCMD.get(theFunloc);
        } else {
            return null;
        }
    }

    private static void queryPartnerFunction() {
    /*********************** Modified by shridevi as part of SIR 1114*********************************/ 
      /* allPartnerFunctions = [
            SELECT  Id, 
                    Partner_Function_Type__c,
                    SAP_Customer__c, 
                    Person_Name__c  
            FROM Partner_Function__c 
            WHERE IsDeleted = FALSE 
        ];*/
     /*****************************************************************************************************/   
        Map<Id,Partner_Function__c> mapZAs = new Map<Id,Partner_Function__c>();
        Map<Id,Partner_Function__c> mapZIs = new Map<Id,Partner_Function__c>();
        Map<Id,Partner_Function__c> mapZSs = new Map<Id,Partner_Function__c>();

        for( Partner_Function__c thePartnerFunction : [SELECT  Id, Partner_Function_Type__c,SAP_Customer__c, Person_Name__c FROM Partner_Function__c  WHERE IsDeleted = FALSE ]) //modified as part of SIR 1114- Replaced the list allPartnerFunctions  by query
        {
            System.debug('GSAS_DEBUG:thePartnerFunction.Partner_Function_Type__c.left(2)='+thePartnerFunction.Partner_Function_Type__c.left(2));
            if( thePartnerFunction.Partner_Function_Type__c.left(2) == 'ZA' ) {
                mapZAs.put( thePartnerFunction.SAP_Customer__c , thePartnerFunction ); 
            } else if( thePartnerFunction.Partner_Function_Type__c.left(2) == 'ZI' ) {
                mapZIs.put( thePartnerFunction.SAP_Customer__c , thePartnerFunction ); 
            } else if( thePartnerFunction.Partner_Function_Type__c.left(2) == 'ZS' ) {
                mapZSs.put( thePartnerFunction.SAP_Customer__c , thePartnerFunction ); 
            }
        }
        mapSAPCMDPartnerFunctions.put( 'ZA' , mapZAs );
        mapSAPCMDPartnerFunctions.put( 'ZI' , mapZIs );
        mapSAPCMDPartnerFunctions.put( 'ZS' , mapZSs );
    }
    
    private static String queryPartnerFunction( String theType , String theSAPCMD ) {
        if( mapSAPCMDPartnerFunctions.get(theType).containsKey(theSAPCMD) ) {
            return mapSAPCMDPartnerFunctions.get(theType).get(theSAPCMD).Person_Name__c;
        } else {
            return null;
        }
    }
/*
    public void getMassUpdateTypes() {
        Schema.DescribeFieldResult fieldResult = CMD_Request__c.Mass_Update_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        massUpdateTypeOptions = new List<SelectOption>();
        for( Schema.PicklistEntry f : ple ) {
            massUpdateTypeOptions.add( new SelectOption( f.getLabel() , f.getLabel() ) );
        }            
    }
 */   
    public List<SelectOption> getCountryOptions() {
        Schema.DescribeFieldResult fieldResult = SAP_CMD__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<SelectOption> theCountryOptions = new List<SelectOption>();
        for( Schema.PicklistEntry f : ple ) {
            theCountryOptions.add( new SelectOption( f.getLabel() , f.getLabel() ) );
        }
        return theCountryOptions;
    }
/*****
    public List<SelectOption> getZAOptions() {
        Schema.DescribeFieldResult fieldResult = Partner_Function__c.Person_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<SelectOption> theZAOptions = new List<SelectOption>();
        for( Schema.PicklistEntry f : ple ) {
            if( f.getLabel().startsWith('HU')
               || f.getLabel().startsWith('TW')
               || f.getLabel().startsWith('US0')
            ) {
                theZAOptions.add( new SelectOption( f.getLabel() , f.getLabel() ) );
            }
        }            
        return theZAOptions;
    }

    public List<SelectOption> getZSOptions() {
        Schema.DescribeFieldResult fieldResult = Partner_Function__c.Person_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<SelectOption> theZSOptions = new List<SelectOption>();
        for( Schema.PicklistEntry f : ple ) {
            if( !(f.getLabel().startsWith('HU'))
               && !(f.getLabel().startsWith('TW'))
               && !(f.getLabel().startsWith('US0'))
            ) {
               theZSOptions.add( new SelectOption( f.getLabel() , f.getLabel() ) );
            }
        }
        return theZSOptions;
    }
*****/

    public List<SelectOption> getZAOptions() {
        Schema.DescribeFieldResult fieldResult = Partner_Function__c.Person_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> thePicklist = new List<String>();
        List<SelectOption> theZAOptions = new List<SelectOption>();
        for( Schema.PicklistEntry f : ple ) {
            if( f.getLabel().startsWith('HU')
               || f.getLabel().startsWith('TW')
               || f.getLabel().startsWith('US0')
               || f.getLabel().startsWith('MX')
               || f.getLabel().startsWith('CN')            
               || f.getLabel().startsWith('US5')
               || f.getLabel().startsWith('RO')
               || f.getLabel().startsWith('CZ')
            ) {
               // thePicklist.add( f.getLabel().substring(8) );  // commented to fix Apex CPU Time limit Exceeded error(SFDC-348)
                theZAOptions.add( new SelectOption( f.getLabel() , f.getLabel() ) ); // Added to fix Apex CPU Time limit Exceeded error(SFDC-348)
                
            }
        }
        theZAOptions.sort(); // Added to fix Apex CPU Time limit Exceeded error(SFDC-348)
        
     // commented below code to fix Apex CPU Time limit Exceeded error(SFDC-348) 
     /* thePicklist.sort();
       for( String theList : thePicklist ){
            for( Schema.PicklistEntry f : ple ){
                if( f.getLabel().substring(8) == theList ){
                    theZAOptions.add( new SelectOption( f.getLabel() , f.getLabel() ) );
                }
            }
        } */
        return theZAOptions;
    }

    public List<SelectOption> getZSOptions() {
        Schema.DescribeFieldResult fieldResult = Partner_Function__c.Person_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> thePicklist = new List<String>();
        List<SelectOption> theZSOptions = new List<SelectOption>();
        System.debug('PLE'+ple);
        for( Schema.PicklistEntry f : ple ) {
            if( !(f.getLabel().startsWith('HU'))
               && !(f.getLabel().startsWith('TW'))
               && !(f.getLabel().startsWith('US0'))
               && !(f.getLabel().startsWith('MX'))
               && !(f.getLabel().startsWith('CN'))
               && !(f.getLabel().startsWith('US5'))
               && !(f.getLabel().startsWith('RO'))
               && !(f.getLabel().startsWith('CZ'))
           
               ) {
               // thePicklist.add( f.getLabel().substring(8) );   // commented to fix Apex CPU Time limit Exceeded error(SFDC-348) 
                theZSOptions.add( new SelectOption( f.getLabel() , f.getLabel() ) ); // Added to fix Apex CPU Time limit Exceeded error(SFDC-348)
                System.debug(' ZSlabel :::'+f.getLabel());
            }
        }
        theZSOptions.sort(); // Added to fix Apex CPU Time limit Exceeded error(SFDC-348)
        
       // commented below code to fix Apex CPU Time limit Exceeded error(SFDC-348)   
       /* thePicklist.sort();
        for( String theList : thePicklist ){
            for( Schema.PicklistEntry f : ple ){
                if( f.getLabel().substring(8) == theList ){
                    theZSOptions.add( new SelectOption( f.getLabel() , f.getLabel() ) );
                }
            }
        } */
        return theZSOptions;
    }

   public List<SelectOption> getPDKeyOptions() {
        List<SelectOption> theOptions = new List<SelectOption>();
        List<SAP_CMD__c> queriedPDKeys = [
            SELECT PD_Key_Account__c 
            FROM SAP_CMD__c 
            WHERE PD_Key_Account__c != NULL 
            LIMIT 1000
        ];
        for( SAP_CMD__c CMD : queriedPDKeys ) {
            theOptions.add(new SelectOption((String)CMD.get('PD_Key_Account__c'),(String)CMD.get('PD_Key_Account__c')));
        }            
        return theOptions;
    } 
   
    public PageReference addRow() {
        FunlocWrapper newEmptyFunlocWrapper = new FunlocWrapper();
        this.listFunlocWrapper.add( newEmptyFunlocWrapper );
        this.refresh();
        return null;
    }

    public PageReference add5Rows() {
        FunlocWrapper newEmptyFunlocWrapper1 = new FunlocWrapper();
        FunlocWrapper newEmptyFunlocWrapper2 = new FunlocWrapper();
        FunlocWrapper newEmptyFunlocWrapper3 = new FunlocWrapper();
        FunlocWrapper newEmptyFunlocWrapper4 = new FunlocWrapper();
        FunlocWrapper newEmptyFunlocWrapper5 = new FunlocWrapper();
        this.listFunlocWrapper.add( newEmptyFunlocWrapper1 );
        this.listFunlocWrapper.add( newEmptyFunlocWrapper2 );
        this.listFunlocWrapper.add( newEmptyFunlocWrapper3 );
        this.listFunlocWrapper.add( newEmptyFunlocWrapper4 );
        this.listFunlocWrapper.add( newEmptyFunlocWrapper5 );
        this.refresh();
        return null;
    }

    public PageReference removeRow() {
        Map<String,CMD_Request_SAP_Mass_Update_Detail__c> mapRequestDetails = new Map<String,CMD_Request_SAP_Mass_Update_Detail__c>();
        for( CMD_Request_SAP_Mass_Update_Detail__c theRequestDetail : [
            SELECT  Id, Name,
                    CMD_Request__c,
                    Funloc__c,
                    SAP_CMD__c,
                    ZA_Old__c,
                    ZA_New__c,
                    ZS_Old__c,
                    ZS_New__c
            FROM    CMD_Request_SAP_Mass_Update_Detail__c
            WHERE   CMD_Request__c = :theRequest.Id
        ]) {
            mapRequestDetails.put( String.valueOf(theRequestDetail.Id), theRequestDetail );
        }
        
        if( listFunlocWrapper.get( Integer.valueOf(rowToBeRemoved)-1 ).detailId != null ) {
            delete mapRequestDetails.get( listFunlocWrapper.get( Integer.valueOf(rowToBeRemoved)-1 ).detailId );
        }
        this.listFunlocWrapper.remove( Integer.valueOf(rowToBeRemoved)-1 );
        this.refresh();
        return null;
    }
    
    public PageReference replicateColumn() {
        String theNewZA ;
        String theNewZS ;
        
        this.refresh();

        if( columnToBeReplicated == 'ZA') {        
            theNewZA = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newZA;
            for( FunlocWrapper theFunlocWrapper : listFunlocWrapper ) {
                if( theFunlocWrapper.sapCMD != null ) {
                    theFunlocWrapper.newZA = theNewZA;    
                } else {
                    theFunlocWrapper.newZA = null;
                }
            }
        }

        if( columnToBeReplicated == 'ZS') {        
            theNewZS = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newZS;
            for( FunlocWrapper theFunlocWrapper : listFunlocWrapper ) {
                if( theFunlocWrapper.sapCMD != null ) {
                    theFunlocWrapper.newZS = theNewZS;    
                } else {
                    theFunlocWrapper.newZS = null;
                }
            }
        }

        if( columnToBeReplicated == 'Address') {        
            for( FunlocWrapper theFunlocWrapper : listFunlocWrapper ) {
                if( theFunlocWrapper.sapCMD != null ) {
                    theFunlocWrapper.newLegalName 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newLegalName;    
                    theFunlocWrapper.newName2 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newName2;    
                    theFunlocWrapper.newName3 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newName3;    
                    theFunlocWrapper.newName4 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newName4;    
                    theFunlocWrapper.newStreet 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newStreet;    
                    theFunlocWrapper.newStreet4 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newStreet4;    
                    theFunlocWrapper.newCity 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newCity;    
                    theFunlocWrapper.newStateProvince 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newStateProvince;    
                    theFunlocWrapper.newCountry 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newCountry;    
                    theFunlocWrapper.newZip 
                        = listFunlocWrapper.get(Integer.valueOf(rowToBeReplicated)-1).newZip;    
                } else {
                    theFunlocWrapper.newLegalName = null;
                    theFunlocWrapper.newStreet = null;
                    theFunlocWrapper.newCity = null;
                    theFunlocWrapper.newCountry = null;
                }
            }
        }

        this.refresh();
        return null;
    }
    
    public void scanForDupes() {
        Map<String, FunlocWrapper> checkedFunlocs = new Map<String, FunlocWrapper>();
        for( FunlocWrapper theFunlocWrapper : listFunlocWrapper ) {
            if( checkedFunlocs.containsKey( theFunlocWrapper.funloc ) && theFunlocWrapper.funloc != '' ) {
                theFunlocWrapper.isDupe = true;
                checkedFunlocs.get( theFunlocWrapper.funloc ).isDupe = true;
            } else {
                theFunlocWrapper.isDupe = false;
                checkedFunlocs.put( theFunlocWrapper.funloc, theFunlocWrapper );
            }
        }
    }
    
    public PageReference refresh() {
        querySAPCMD();
        queryPartnerFunction();
        for( FunlocWrapper theFunlocWrapper : listFunlocWrapper ) {
            if( theFunlocWrapper.funloc != null && querySAPCMD( theFunlocWrapper.funloc ) != null ) {
                theFunlocWrapper.sapCMD = querySAPCMD( theFunlocWrapper.funloc ).Id;
                theFunlocWrapper.sapCMDName = querySAPCMD( theFunlocWrapper.funloc ).Name;
                theFunlocWrapper.accountName = querySAPCMD( theFunlocWrapper.funloc ).Account_Name__c;
                theFunlocWrapper.oldLegalName = querySAPCMD( theFunlocWrapper.funloc ).Legal_Name__c;
                theFunlocWrapper.oldStreet = querySAPCMD( theFunlocWrapper.funloc ).Street_1__c;
                theFunlocWrapper.oldCity = querySAPCMD( theFunlocWrapper.funloc ).City__c;
                theFunlocWrapper.oldCountry = querySAPCMD( theFunlocWrapper.funloc ).Country__c;
                theFunlocWrapper.oldZA = queryPartnerFunction( 'ZA', theFunlocWrapper.sapCMD );
                theFunlocWrapper.oldZS = queryPartnerFunction( 'ZS', theFunlocWrapper.sapCMD );
                theFunlocWrapper.SapCMDRecordType=querySAPCMD( theFunlocWrapper.funloc ).RecordType.Name;
                if(refreshPage==false)
                theFunlocWrapper.Name1ServiceProvider=querySAPCMD( theFunlocWrapper.funloc ).Name_1_Service_Provider__c;
            }
        }
        this.scanForDupes();
        this.reindex();
        return null;        
    }
    
    private void reindex() {
        Integer i = 1;
        for( FunlocWrapper theFunloc : listFunlocWrapper ) {
            theFunloc.index = String.valueOf(i);
            if( Math.mod( i , 2 ) == 1 ) {
                theFunloc.rowStyleClass = 'oddRow';
            } else {
                theFunloc.rowStyleClass = 'evenRow';
            }
            i++;
        }
    }
    
    public PageReference uploadCSV() {    
       if( contentFile != null ){
            fileString = contentFile.toString();
            List<FunlocWrapper> allProcessedCSV = processCSV(fileString, true, theRequest.Mass_Update_Type__c);
            if(allProcessedCSV==null)
            {
                return null;
            }
            for( FunlocWrapper theRow : allProcessedCSV ) {
                this.listFunlocWrapper.add( theRow );
            }
        }
        this.scanForDupes();
        this.reindex();
        this.refresh();
        return null;
    }

    private static List<FunlocWrapper> processCSV(String contents,Boolean skipHeaders, String updateType) {
        System.debug('contents:'+contents);
        querySAPCMD();
        queryPartnerFunction();
        theProcessedCSV = new List<FunlocWrapper>();
        List<List<String>> parsedCSV = parseCSV(contents, skipHeaders, updateType);
        if(parsedCSV==null)
            {
                return null;
            }
        FunlocWrapper theProcessedRow = new FunlocWrapper();
        
        for( List<String> row : parsedCSV ) {
            theProcessedRow = new FunlocWrapper();
            
            if( row[0].trim() != null ) {
                if( row[0].trim().startsWith('0') ||
                    row[0].trim().startsWith('1') ||
                    row[0].trim().startsWith('2') ||
                    row[0].trim().startsWith('3') ||
                    row[0].trim().startsWith('4') ||
                    row[0].trim().startsWith('5') ||
                    row[0].trim().startsWith('6') ||
                    row[0].trim().startsWith('7') ||
                    row[0].trim().startsWith('8') ||
                    row[0].trim().startsWith('9') 
                   ) {
                    theProcessedRow.funloc = row[0].trim();
                    if( updateType == 'ZA' ){
                        //System.debug('');e
                        theProcessedRow.newZA = row[1].trim();
                    }
                    if( updateType == 'ZS' ){
                        //System.debug('');e
                        theProcessedRow.newZS = row[1].trim();
                    }
                    if( updateType == 'Address' ){
                        theProcessedRow.newLegalName = row[1].trim();
                        //theProcessedRow.Name1ServiceProvider= row[2].trim()
                        theProcessedRow.newName2 = row[2].trim();
                        theProcessedRow.newName3 = row[3].trim();
                        theProcessedRow.newName4 = row[4].trim();
                        theProcessedRow.newStreet = row[5].trim();
                        theProcessedRow.newStreet4 = row[6].trim();
                        theProcessedRow.newCity = row[7].trim();
                        theProcessedRow.newStateProvince = row[8].trim();
                        theProcessedRow.newCountry = row[9].trim();
                        theProcessedRow.newZip = row[10].trim();
                        
                    }
                }
            }
            theProcessedCSV.add( theProcessedRow );
        }
        return theProcessedCSV;
    }
    
    private static List<List<String>> parseCSV(String contents,Boolean skipHeaders,String updateType) {
        List<List<String>> allFields = new List<List<String>>();
//  if( contents.contains('\n')
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            if( contents.contains('\n') ){
                lines = contents.split('\n'); //correction: this only accomodates windows files
            }
            if( contents.contains('\r') ){
                lines = contents.split('\r'); // using carriage return accomodates windows, unix, and mac files
            }
            //http://www.maxi-pedia.com/Line+termination+line+feed+versus+carriage+return+0d0a
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        
        Integer num = 0;
        
       if(lines.get(0).Contains(','))
        {
            String[] inputvalues = new String[]{};
            inputvalues.clear();
            inputvalues = lines.get(0).split(',');
            System.debug('inputvalues :'+inputvalues+'::size::'+inputvalues.size());
            
            if(updateType.equalsIgnoreCase(MASSUPDATETYPE_ZA))
            {
                if(!((inputvalues.size()==COLUMN_SIZE_ZA) || (inputvalues.size()==COLUMN_SIZE_ZA_TWO)))
                {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_EXCEEDED_ZA));
                        return null;
                }
                if(inputvalues.size()==COLUMN_SIZE_ZA_TWO)
                {
                    if(((headerZa.get(0).equalsIgnoreCase(inputvalues[0])) && (headerZa.get(4).equalsIgnoreCase(inputvalues[1])))) 
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ZA));
                        return null;
                    }
                }
                else if(inputvalues.size()== COLUMN_SIZE_ZA)
                {
                    if(     (headerZa.get(0).equalsIgnoreCase(inputvalues[0]))
                         && (headerZa.get(1).equalsIgnoreCase(inputvalues[1]))
                         && (headerZa.get(2).equalsIgnoreCase(inputvalues[2])) 
                         && (headerZa.get(3).equalsIgnoreCase(inputvalues[3])) 
                         && (headerZa.get(4).equalsIgnoreCase(inputvalues[4])) 
                        )
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ZA));
                        return null;
                    }
                }
            }
            else if(updateType.equalsIgnoreCase(MASSUPDATETYPE_ZS))
            {
                if(!((inputvalues.size()==COLUMN_SIZE_ZS) || (inputvalues.size()==COLUMN_SIZE_ZS_TWO)))
                {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_EXCEEDED_ZS));
                        return null;
                }
                if(inputvalues.size()==COLUMN_SIZE_ZS_TWO)
                {
                    if(((headerZs.get(0).equalsIgnoreCase(inputvalues[0])) && (headerZs.get(4).equalsIgnoreCase(inputvalues[1])))) 
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ZS));
                        return null;
                    }
                }
                else if(inputvalues.size()== COLUMN_SIZE_ZS)
                {
                    if(     (headerZs.get(0).equalsIgnoreCase(inputvalues[0]))
                         && (headerZs.get(1).equalsIgnoreCase(inputvalues[1]))
                         && (headerZs.get(2).equalsIgnoreCase(inputvalues[2])) 
                         && (headerZs.get(3).equalsIgnoreCase(inputvalues[3])) 
                         && (headerZs.get(4).equalsIgnoreCase(inputvalues[4])) 
                        )
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ZS));
                        return null;
                    }
                }
            }
            else if(updateType.equalsIgnoreCase(MASSUPDATETYPE_ADDRESS))
            {
                if(inputvalues.size()!=COLUMN_SIZE_ADDRESS)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_EXCEEDED_ADDRESS));
                    return null;
                }
                if(inputvalues.size()==COLUMN_SIZE_ADDRESS)
                {
                   
                    if((( (headerAddress.get(0).equalsIgnoreCase(inputvalues[0])) && (headerAddress.get(1).equalsIgnoreCase(inputvalues[1])) && (headerAddress.get(2).equalsIgnoreCase(inputvalues[2])) && (headerAddress.get(3).equalsIgnoreCase(inputvalues[3])) && (headerAddress.get(4).equalsIgnoreCase(inputvalues[4]))
                         &&(headerAddress.get(5).equalsIgnoreCase(inputvalues[5])) &&  (headerAddress.get(6).equalsIgnoreCase(inputvalues[6])) &&  (headerAddress.get(7).equalsIgnoreCase(inputvalues[7]))&&  (headerAddress.get(8).equalsIgnoreCase(inputvalues[8]))
                         &&  (headerAddress.get(9).equalsIgnoreCase(inputvalues[9]))&&  (headerAddress.get(10).equalsIgnoreCase(inputvalues[10]))&&  (headerAddress.get(11).equalsIgnoreCase(inputvalues[11]))
                        )))
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ADDRESS));
                        return null;
                    }
                }
            }
            
        for(String line: lines) {
            // check for blank CSV lines (only commas)
            if( line.replaceAll(',','').trim().length() == 0 ) 
                break;
            List<String> fields = line.split(',');
            System.debug('fields'+fields);
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            allFields.add(cleanFields);
        }
        }
        else
        {
            String[] inputvalues = new String[]{};        
            inputvalues = lines.get(0).split(';');

            if(updateType.equalsIgnoreCase(MASSUPDATETYPE_ZA))
            {
                if(!((inputvalues.size()==COLUMN_SIZE_ZA) || (inputvalues.size()==COLUMN_SIZE_ZA_TWO)))
                {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_EXCEEDED_ZA));
                        return null;
                }
                if(inputvalues.size()==COLUMN_SIZE_ZA_TWO)
                {
                    if(((headerZa.get(0).equalsIgnoreCase(inputvalues[0])) && (headerZa.get(4).equalsIgnoreCase(inputvalues[1])))) 
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ZA));
                        return null;
                    }
                }
                else if(inputvalues.size()==COLUMN_SIZE_ZA)
                {
                    if((( (headerZa.get(0).equalsIgnoreCase(inputvalues[0]))&&(headerZa.get(1).equalsIgnoreCase(inputvalues[1])) && (headerZa.get(2).equalsIgnoreCase(inputvalues[2])) && (headerZa.get(3).equalsIgnoreCase(inputvalues[3]))  && (headerZa.get(4).equalsIgnoreCase(inputvalues[4])))))
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ZA));
                        return null;
                    }
                }
               
            }
            if(updateType.equalsIgnoreCase(MASSUPDATETYPE_ZS))
            {
                if(!((inputvalues.size()==COLUMN_SIZE_ZS) || (inputvalues.size()==COLUMN_SIZE_ZS_TWO)))
                {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_EXCEEDED_ZS));
                        return null;
                }
                if(inputvalues.size()==COLUMN_SIZE_ZS_TWO)
                {
                    if(((headerZs.get(0).equalsIgnoreCase(inputvalues[0])) && (headerZs.get(4).equalsIgnoreCase(inputvalues[1])))) 
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ZS));
                        return null;
                    }
                }
                else if(inputvalues.size()==COLUMN_SIZE_ZS)
                {
                    if((( (headerZs.get(0).equalsIgnoreCase(inputvalues[0]))&&(headerZs.get(1).equalsIgnoreCase(inputvalues[1])) && (headerZs.get(2).equalsIgnoreCase(inputvalues[2])) && (headerZs.get(3).equalsIgnoreCase(inputvalues[3]))  && (headerZs.get(4).equalsIgnoreCase(inputvalues[4])))))
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ZS));
                        return null;
                    }
                }
               
            }
            else if(updateType.equalsIgnoreCase(MASSUPDATETYPE_ADDRESS))
            {
                if(inputvalues.size()!=COLUMN_SIZE_ADDRESS)
                {
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_EXCEEDED_ADDRESS));
                        return null;
                }
                if(inputvalues.size()==COLUMN_SIZE_ADDRESS)
                {
                   
                    if((( (headerAddress.get(0).equalsIgnoreCase(inputvalues[0])) && (headerAddress.get(1).equalsIgnoreCase(inputvalues[1])) && (headerAddress.get(2).equalsIgnoreCase(inputvalues[2])) && (headerAddress.get(3).equalsIgnoreCase(inputvalues[3])) && (headerAddress.get(4).equalsIgnoreCase(inputvalues[4]))
                         &&(headerAddress.get(5).equalsIgnoreCase(inputvalues[5])) &&  (headerAddress.get(6).equalsIgnoreCase(inputvalues[6])) &&  (headerAddress.get(7).equalsIgnoreCase(inputvalues[7]))&&  (headerAddress.get(8).equalsIgnoreCase(inputvalues[8]))
                         &&  (headerAddress.get(9).equalsIgnoreCase(inputvalues[9]))&&  (headerAddress.get(10).equalsIgnoreCase(inputvalues[10]))&&  (headerAddress.get(11).equalsIgnoreCase(inputvalues[11]))
                        )))
                    {
                        
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,COLUMN_ORDER_ADDRESS));
                        return null;
                    }
                }
            }
            for(String line: lines) {
            // check for blank CSV lines (only commas)
            if( line.replaceAll(';','').trim().length() == 0 ) 
                break;
            List<String> fields = line.split(';');
            System.debug('fields'+fields);
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            allFields.add(cleanFields);
        }    
        }
        
        
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    } 

    public void save() {
        refreshPage=true;
        this.refresh();
        
        Map<String,CMD_Request_SAP_Mass_Update_Detail__c> mapRequestDetails = new Map<String,CMD_Request_SAP_Mass_Update_Detail__c>();
        for( CMD_Request_SAP_Mass_Update_Detail__c theRequestDetail : [
            SELECT  Id, Name,
                    CMD_Request__c,
                    Funloc__c,
                    SAP_CMD__c,
                    Legal_Name_Old__c,
                    Legal_Name_New__c,
                    Name_2_New__c,
                    Name_2_Old__c,
                    Name_3_New__c,
                    Name_3_Old__c,
                    Name_4_New__c,
                    Name_4_Old__c,
                    Street_New__c,
                    Street_Old__c,
                    Street_4_New__c,
                    Street_4_Old__c,
                    City_New__c,
                    City_Old__c,
                    State_Province_New__c,
                    State_Province_Old__c,
                    Country_New__c,
                    Country_Old__c,
                    Zip_New__c,
                    Zip_Old__c,
                    ZA_Old__c,
                    ZA_New__c,
                    ZS_Old__c,
                    ZS_New__c
            FROM    CMD_Request_SAP_Mass_Update_Detail__c
            WHERE   CMD_Request__c = :theRequest.Id
        ]) {
            mapRequestDetails.put( String.valueOf(theRequestDetail.Id), theRequestDetail );
        }
        List<CMD_Request_SAP_Mass_Update_Detail__c> detailsToBeUpdated = new List<CMD_Request_SAP_Mass_Update_Detail__c>(); 
        List<CMD_Request_SAP_Mass_Update_Detail__c> detailsToBeInserted = new List<CMD_Request_SAP_Mass_Update_Detail__c>(); 
        List<SAP_CMD__c> detailsToBeUpdatedToSAPCMD= new List<SAP_CMD__c>();
        List<id> sapCmdId=new List<id>();
        Map<id,string> mapSapCmd=new Map<id,string>();
        for( FunlocWrapper theFunlocWrapper : listFunlocWrapper ) {
            if( mapRequestDetails.containsKey( theFunlocWrapper.detailId ) ) {
             System.debug('Entered If-1');
                mapRequestDetails.get( theFunlocWrapper.detailId ).Funloc__c = theFunlocWrapper.funloc;
                mapRequestDetails.get( theFunlocWrapper.detailId ).SAP_CMD__c = theFunlocWrapper.sapCMD;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Legal_Name_Old__c = theFunlocWrapper.oldLegalName;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Legal_Name_New__c = theFunlocWrapper.newLegalName;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Name_2_Old__c = theFunlocWrapper.oldName2;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Name_2_New__c = theFunlocWrapper.newName2;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Name_3_Old__c = theFunlocWrapper.oldName3;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Name_3_New__c = theFunlocWrapper.newName3;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Name_4_Old__c = theFunlocWrapper.oldName4;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Name_4_New__c = theFunlocWrapper.newName4;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Street_New__c = theFunlocWrapper.newStreet;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Street_Old__c = theFunlocWrapper.newStreet;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Street_4_New__c = theFunlocWrapper.newStreet4;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Street_4_Old__c = theFunlocWrapper.newStreet4;
                mapRequestDetails.get( theFunlocWrapper.detailId ).City_Old__c = theFunlocWrapper.oldCity;
                mapRequestDetails.get( theFunlocWrapper.detailId ).City_New__c = theFunlocWrapper.newCity;
                mapRequestDetails.get( theFunlocWrapper.detailId ).State_Province_Old__c = theFunlocWrapper.oldStateProvince;
                mapRequestDetails.get( theFunlocWrapper.detailId ).State_Province_New__c = theFunlocWrapper.newStateProvince;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Country_Old__c = theFunlocWrapper.oldCountry;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Country_New__c = theFunlocWrapper.newCountry;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Zip_Old__c = theFunlocWrapper.oldZip;
                mapRequestDetails.get( theFunlocWrapper.detailId ).Zip_New__c = theFunlocWrapper.newZip;
                mapRequestDetails.get( theFunlocWrapper.detailId ).ZA_Old__c = theFunlocWrapper.oldZA;
                mapRequestDetails.get( theFunlocWrapper.detailId ).ZA_New__c = theFunlocWrapper.newZA;
                mapRequestDetails.get( theFunlocWrapper.detailId ).ZS_Old__c = theFunlocWrapper.oldZS;
                mapRequestDetails.get( theFunlocWrapper.detailId ).ZS_New__c = theFunlocWrapper.newZS;
                //mapRequestDetails.get( theFunlocWrapper.detailId ).ZS_Old__c = theFunlocWrapper.oldZS;
               // mapRequestDetails.get( theFunlocWrapper.detailId ).ZS_New__c = theFunlocWrapper.newZS;
                
               
                 
                detailsToBeUpdated.add( mapRequestDetails.get( theFunlocWrapper.detailId ) );
            } else if( theFunlocWrapper.isDupe == false && theFunlocWrapper.sapCMD != null ) {
            System.debug('Entered If2');
                CMD_Request_SAP_Mass_Update_Detail__c newRequestDetail = new CMD_Request_SAP_Mass_Update_Detail__c(
                    CMD_Request__c = theRequest.Id,
                    Funloc__c = theFunlocWrapper.funloc,
                    SAP_CMD__c = theFunlocWrapper.sapCMD,
                    Legal_Name_Old__c = theFunlocWrapper.oldLegalName,
                    Legal_Name_New__c = theFunlocWrapper.newLegalName,
                    Name_2_Old__c = theFunlocWrapper.oldName2,
                    Name_2_New__c = theFunlocWrapper.newName2,
                    Name_3_Old__c = theFunlocWrapper.oldName3,
                    Name_3_New__c = theFunlocWrapper.newName3,
                    Name_4_Old__c = theFunlocWrapper.oldName4,
                    Name_4_New__c = theFunlocWrapper.newName4,
                    Street_New__c = theFunlocWrapper.newStreet,
                    Street_Old__c = theFunlocWrapper.newStreet,
                    Street_4_New__c = theFunlocWrapper.newStreet4,
                    Street_4_Old__c = theFunlocWrapper.newStreet4,
                    City_Old__c = theFunlocWrapper.oldCity,
                    City_New__c = theFunlocWrapper.newCity,
                    State_Province_Old__c = theFunlocWrapper.oldStateProvince,
                    State_Province_New__c = theFunlocWrapper.newStateProvince,
                    Country_Old__c = theFunlocWrapper.oldCountry,
                    Country_New__c = theFunlocWrapper.newCountry,
                    Zip_Old__c = theFunlocWrapper.oldZip,
                    Zip_New__c = theFunlocWrapper.newZip,
                    ZA_Old__c = theFunlocWrapper.oldZA,
                    ZA_New__c = theFunlocWrapper.newZA,
                    ZS_Old__c = theFunlocWrapper.oldZS,
                    ZS_New__c = theFunlocWrapper.newZS
                    //theFunlocWrapper.SapCMDRecordType
                   // Name_1_Service_Provider__c=theFunlocWrapper.Name1ServiceProvider
                );
                
                detailsToBeInserted.add( newRequestDetail );
            }
             System.debug('theFunlocWrapper::'+theFunlocWrapper);
             SapCmdId.add(theFunlocWrapper.sapCMD);
             System.debug('SAP CMD ID:'+SapCmdId);
             mapSapCmd.put(theFunlocWrapper.sapCMD,theFunlocWrapper.Name1ServiceProvider);
        }
        
     
       if(theRequest.Mass_Update_Type__c=='Address')
       {
        for(SAP_CMD__c SapCmdRecord:[select id,Type__c,Name_1_Service_Provider__c,HUB_Customer__C,Customer_FunLoc_Number__c from SAP_CMD__c where id in:SapCmdId])
            {
               System.debug('SapCmdRecord::'+SapCmdRecord);
                    if(SapCmdRecord.Type__c=='Service Provider' && (mapSapCmd.get(SapCmdRecord.id)!=null && mapSapCmd.get(SapCmdRecord.id)!=''))
                      {
                        SapCmdRecord.Name_1_Service_Provider__c=mapSapCmd.get(SapCmdRecord.id);
                        detailsToBeUpdatedToSAPCMD.add(SapCmdRecord);
                        System.debug('updates::'+mapSapCmd.get(SapCmdRecord.id));
                      }
                   /* else if(mapSapCmd.get(SapCmdRecord.id)!=null && mapSapCmd.get(SapCmdRecord.id)!='')
                      { 
                         System.debug('else error updates');
                         refreshPage=false;
                         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Funloc-'+SapCmdRecord.Customer_FunLoc_Number__c+': Name1(Service Provider) field can be filled only if the Customer is of type Service Provider.'));
                          
                      }*/
                }
            
        if( detailsToBeUpdatedToSAPCMD.size()!=0)
            update detailsToBeUpdatedToSAPCMD;
        System.debug(detailsToBeUpdatedToSAPCMD);
        }
        
       
        
        update detailsToBeUpdated;
        insert detailsToBeInserted;
         System.debug(detailsToBeUpdatedToSAPCMD);
         // this.reindex();
         // refreshPage=true;
         // if(refreshPage==true)
         //  {
        actor='<script> pageReload(); </script>';
       
         //  }
         //stdController1.save();
       
       
        // PageReference pageRef = ApexPages.currentPage();
        // pageRef.setRedirect(true);
        //return pageRef;
    }
}