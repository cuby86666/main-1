// 12-02-15 by Manoj : Introduced the recordtype changes for Opportunity.
// Moded for 1505 STAR Tracker Sprint 2
// 31-05-16 by Balaji : Added BU filter and removed cancelled opttys display in Tracker - SIR699 and SIR974 1606 Release
// 13-07-16 by Balaji : Rel 1607 SIR1024 Replaced 'Prod. Claim Value (USD) - SYSTEM USED' field with 'Prod. Claim Value (USD)'
// 01-08-16 by Balaji : SIR960 Enhanced class to support Account Tracker functonality
// 16-08-2016 by Jewelslyn : SIR 1126 Updated to replace with 'Next Step' Field
// 19-10-2016 by Balaji : SIR 1275 Updated to add 'Probability to Win' and 'Help needed' Fields to the Tracker
// Jan-25-2017 by Scarlett Kang: Oppty 2.0 revision
// May-15-2017 By Nisha Agrawal	: various changes for performance improvement - SFDC-432
// 					1. Obsoleted Stages Recommendation and Assessment
// 					2. Optimized opportunity and line item related queries for redundant filters and unwanted fields
// 					3. Optimized Task Fetching queries for directing fetching for opportunities rather than account
// 					4. Obsoleted code for fetching % DW to completion for prior week calculation
// 					5. Obsoleted various section where variables were calculated/assigned but never used
// 					6. Obsoleted Help Needed field from data table
public with Sharing class TrackingSheetController 
{
    public static Account theParentAccount {get;set;}
    public List<Opportunity> listOpportunities = new List<Opportunity>();
    public static String paramAccountId {get;set;}
    public static String paramOwner {get;set;}
    public static String paramStage {get;set;}
    public static String paramMAG {get;set;}
    public static String paramBU {get;set;}
    public String theAccountId {get;set;}
    public String theOwner {get;set;}
    public String theStage {get;set;}
    public String theMAG {get;set;}
    public String theBU {get;set;}
    public Transient Decimal AOP1HY1 {get;set;}
    public Transient Decimal AOP2HY1 {get;set;}
    public Transient Decimal AOP1HY2 {get;set;}
    public Transient Decimal AOP2HY2 {get;set;}
    public Transient Decimal AOP1HY3 {get;set;}
    public Transient Decimal AOP2HY3 {get;set;}
    public Transient Decimal DW1HY1 {get;set;}
    public Transient Decimal DW2HY1 {get;set;}
    public Transient Decimal DW1HY2 {get;set;}
    public Transient Decimal DW2HY2 {get;set;}
    public Transient Decimal DW1HY3 {get;set;}
    public Transient Decimal DW2HY3 {get;set;}
    public Transient Decimal TH1HY1 {get;set;}
    public Transient Decimal TH2HY1 {get;set;}
    public Transient Decimal TH1HY2 {get;set;}
    public Transient Decimal TH2HY2 {get;set;}
    public Transient Decimal TH1HY3 {get;set;}
    public Transient Decimal TH2HY3 {get;set;}
    public Transient Decimal Com1HY1 {get;set;}
    public Transient Decimal Com2HY1 {get;set;}
    public Transient Decimal Com1HY2 {get;set;}
    public Transient Decimal Com2HY2 {get;set;}
    public Transient Decimal Com1HY3 {get;set;}
    public Transient Decimal Com2HY3 {get;set;}
    public Transient Decimal Dec1HY1 {get;set;}
    public Transient Decimal Dec2HY1 {get;set;}
    public Transient Decimal Dec1HY2 {get;set;}
    public Transient Decimal Dec2HY2 {get;set;}
    public Transient Decimal Dec1HY3 {get;set;}
    public Transient Decimal Dec2HY3 {get;set;}
    public Transient Decimal Dis1HY1 {get;set;} 
    public Transient Decimal Dis2HY1 {get;set;}
    public Transient Decimal Dis1HY2 {get;set;}
    public Transient Decimal Dis2HY2 {get;set;}
    public Transient Decimal Dis1HY3 {get;set;}
    public Transient Decimal Dis2HY3 {get;set;}
    public Transient Decimal Eng1HY1 {get;set;} 
    public Transient Decimal Eng2HY1 {get;set;}
    public Transient Decimal Eng1HY2 {get;set;}
    public Transient Decimal Eng2HY2 {get;set;}
    public Transient Decimal Eng1HY3 {get;set;}
    public Transient Decimal Eng2HY3 {get;set;}
    public class DWwrapper
    {
        //public Transient Integer dwYear {get;set;}
        //public Transient Integer dwHalf {get;set;}
        //public Transient Integer dwQuarter {get;set;}
        public Transient Opportunity DW {get;set;}
        public Transient String dwStage {get;set;}
        public Transient List<OpportunityLineItem> listLineItems {get;set;}
        //public Transient List<OpportunityFieldHistory> listFieldHistories {get;set;}
        //public Transient List<Task> listTasks {get;set;}
        //public Transient String Percentage_to_DW_Completion_Prior_Week {get;set;}
        public Transient Integer tasksTotal {get;set;}
        public Transient Integer tasksOpen {get;set;}
        public Transient Decimal pricePerProgram {get;set;}
        public Transient Decimal entryVolume {get;set;}
        public Transient Decimal totalValue {get;set;}
        //public Transient String probToWin{get;set;}
        //SIR1275 updates. Balaji G Date: 19-Oct-2016
        //public Transient String helpNeeded{get;set;}
        public Transient String nextStep{get;set;}        
    }
    public Transient List<DWwrapper> listDWwrapper {get;set;}

    //private static Map<Id,Account> mapAccounts = new Map<Id,Account>();
    public Transient static Map<Id,List<OpportunityLineItem>> mapOpportunityLineItems = new Map<Id,List<OpportunityLineItem>>();
    //public Transient static Map<Id,List<OpportunityFieldHistory>> mapOpportunityFieldHistories = new Map<Id,List<OpportunityFieldHistory>>();
    public Transient static Map<Id,List<Task>> mapOpportunityTasksTotal = new Map<Id,List<Task>>();
	public Transient static Map<Id,List<Task>> mapOpportunityTasksOpen = new Map<Id,List<Task>>();
    
    private Transient static Date CurrentYear = Date.newInstance(Date.today().year(),1,1);
    private Transient static Date PreviousYear = Date.newInstance(Date.today().year()-1,1,1);
        
    public PageReference landingPageRedirect()
    { //Redirecting to STAR
        PageReference p = new PageReference('/apex/TrackingSheet?id=' + this.theAccountId);
        return p;
    }

    public TrackingSheetController(ApexPages.StandardController stdController)
    {
        theParentAccount = (Account)stdController.getRecord();
        paramAccountId = ApexPages.currentPage().getParameters().get('id'); 
        this.theAccountId = paramAccountId; 
        paramOwner = ApexPages.currentPage().getParameters().get('own');
        this.theOwner = paramOwner;
        paramStage = ApexPages.currentPage().getParameters().get('stg');
        this.theStage = paramStage;
        paramMAG = ApexPages.currentPage().getParameters().get('mag'); 
        this.theMAG = paramMAG;
        paramBU = ApexPages.currentPage().getParameters().get('bu'); 
        this.theBU = paramBU;
        generateDetails();
    }

    public PageReference filterButton()
    {
        String theURL = '/apex/TrackingSheet?id=' + this.theAccountId ;
        if( theOwner != 'All')
        {
            theURL = theURL + '&own=' + this.theOwner;
        }    
        if( theStage != 'All')
        {
            theURL = theURL + '&stg=' + this.theStage;
        }    
        if( theMAG != 'All' )
        {
            theURL = theURL + '&mag=' + this.theMAG;
        }
        if( theBU != 'All' )
        {
            theURL = theURL + '&bu=' + this.theBU;
        }        
        PageReference thePage = new PageReference(theURL);
        thePage.setRedirect(true);
        return thePage;    
    }
    
    public void generateDetails()        
    {
        String sfdcRecordTypeId = OpportunitiesSelector.getSfdcRecordTypeId();
        AOP1HY1 = 0;
        AOP2HY1 = 0;
        AOP1HY2 = 0;
        AOP2HY2 = 0;
        AOP1HY3 = 0;
        AOP2HY3 = 0;
        DW1HY1 = 0;
        DW2HY1 = 0;
        DW1HY2 = 0;
        DW2HY2 = 0;
        DW1HY3 = 0;
        DW2HY3 = 0;
        TH1HY1 = 0;
        TH2HY1 = 0;
        TH1HY2 = 0;
        TH2HY2 = 0;
        TH1HY3 = 0;
        TH2HY3 = 0;
        Com1HY1 = 0;
        Com2HY1 = 0;
        Com1HY2 = 0;
        Com2HY2 = 0;
        Com1HY3 = 0;
        Com2HY3 = 0;
        Dec1HY1 = 0;
        Dec2HY1 = 0;
        Dec1HY2 = 0;
        Dec2HY2 = 0;
        Dec1HY3 = 0;
        Dec2HY3 = 0;
        Dis1HY1 = 0;
        Dis2HY1 = 0;
        Dis1HY2 = 0;
        Dis2HY2 = 0;
        Dis1HY3 = 0;
        Dis2HY3 = 0;
        Eng1HY1 = 0;
        Eng2HY1 = 0;
        Eng1HY2 = 0;
        Eng2HY2 = 0;
        Eng1HY3 = 0;
        Eng2HY3 = 0;
        //Decimal lineItemValue = 0;
        //Decimal lineItemClaimValue = 0;
        listDWwrapper = new List<DWwrapper>();
        String queryStringOpportunities = 
            'SELECT  Id, Name, StageName, CloseDate, OwnerId, Owner.Name, Account.NXP_GID__c, Percentage_to_DW_Completion__c, '+
            ' LT_Value_USD__c, Claim_Value_USD__c, MAG__c, BU__c, Next_Steps__c, Last_Business_Modified_Date__c  '+                   
            '    FROM Opportunity '+
            '    WHERE Account.ParentId = \''+ String.valueOf(theParentAccount.Id) +'\' '+
            '    AND RecordTypeID = \''+ String.valueOf(sfdcRecordTypeId) +'\' '+
            '    AND Reference_Design__c = false '+
            '    AND ( ( NOT( StageName = \'AOP\' ) ) '+
            '                AND ( NOT( StageName = \'Cancelled\' ) ) ) '+
            '    AND ( CloseDate >= ' + String.valueOf(CurrentYear) + ' )';
        if( paramOwner != null )
        {
            queryStringOpportunities = queryStringOpportunities + ' AND Owner.Name = \''+ paramOwner +'\' ';
        }
        if( paramStage != null )
        {
            queryStringOpportunities = queryStringOpportunities + ' AND StageName = \''+ paramStage +'\' ';
        }
        if( paramMAG != null )
        {
            queryStringOpportunities = queryStringOpportunities + ' AND MAG__c LIKE \'%'+ paramMAG +'%\' ';
        }
        if( paramBU != null )
        {
            queryStringOpportunities = queryStringOpportunities + ' AND BU__c LIKE \'%'+ paramBU +'%\' ';
        }
        queryStringOpportunities += ' ORDER BY CloseDate ASC ';
        System.debug(logginglevel.ERROR,queryStringOpportunities+'************');
        System.debug(logginglevel.ERROR,theParentAccount.Id+'************');
        //List<Opportunity>
        listOpportunities = Database.query(queryStringOpportunities);
        System.debug(logginglevel.ERROR,listOpportunities.size());        
        String queryStringOpportunityLineItems =
            'SELECT  Id, OpportunityId, Opportunity.StageName, Opportunity.CloseDate, Opportunity.MAG__c, Opportunity.BU__c, '+            
            '         Product2.Basic_Type__c, UnitPrice, Component_Multiplier__c,   ' + // add - 2017.01
            '        MAG__c, BU__c, LT_Value_USD__c, ' + // Prod Lifetime excl Thrust USD
            '        Claim_Value_USD__c, '+ // Prod Claim Value excl Thrust USD
// Obsoleted            '        Product_Thrust_Non_Thrust_DW_Value_USD__c'+ // Prod Claim Value incl Thrust USD
                        '                Quantity, ' + // Added by Scarlett on Jan 24, 2017
                        '                Prod_Lost__c ' + // Added by Scarlett on Jan 24, 2017
            '    FROM OpportunityLineItem '+
            '    WHERE Opportunity.Account.ParentId = \''+ String.valueOf(theParentAccount.Id) +'\' '+
            '    AND Opportunity.RecordTypeID = \''+ String.valueOf(sfdcRecordTypeId) +'\' '+
            '    AND Opportunity.Reference_Design__c = false '+
            '    AND '+
            '            ( '+
            '                ( NOT( Opportunity.StageName = \'AOP\' ) ) '+
            '                AND '+
            '                ( NOT( Opportunity.StageName = \'Cancelled\' ) ) '+
            '                AND '+
            '                ( NOT( Opportunity.StageName = \'Lost\' ) ) '+            
            '            ) '+
            '    AND ( Opportunity.CloseDate >= ' + String.valueOf(CurrentYear) + ' )';
			
        List<OpportunityLineItem> listOpportunityLineItems = Database.query(queryStringOpportunityLineItems);
        System.debug('Size Of oppty'+listOpportunityLineItems.size());
        for( OpportunityLineItem theOpportunityLineItem : listOpportunityLineItems ) 
        {
            if(               
                ( 
                    ( paramOwner != null && paramOwner.replace('+','') == theOpportunityLineItem.Opportunity.Owner.Name )
                    || paramOwner == null
                )
                && ( 
                    ( paramStage != null && paramStage.replace('+','') == theOpportunityLineItem.Opportunity.StageName )
                    || paramStage == null
                )
                && ( 
                    (paramMAG != null && theOpportunityLineItem.MAG__c.contains(paramMAG) )
                    || paramMAG == null
                )
                && ( 
                    (paramBU != null && theOpportunityLineItem.BU__c.contains(paramBU) )
                    || paramBU == null
                )
            ){      
                if( !mapOpportunityLineItems.containsKey( theOpportunityLineItem.OpportunityId ) 
                ){
                    List<OpportunityLineItem> listOLI = new List<OpportunityLineItem>();
                    listOLI.add( theOpportunityLineItem );  //starting a new list of LineItems for each Oppo
                    mapOpportunityLineItems.put(theOpportunityLineItem.OpportunityId , listOLI );
                } 
                else
                {
                    mapOpportunityLineItems.get(theOpportunityLineItem.OpportunityId).add(theOpportunityLineItem);
                }

                if( (theOpportunityLineItem.Opportunity.CloseDate.year() == Date.today().year() 
                    && theOpportunityLineItem.Opportunity.CloseDate.month() <= 6 
                    && theOpportunityLineItem.Opportunity.StageName != 'Lost'
                    && theOpportunityLineItem.Prod_Lost__c != true
                    ))
                    {

                    DW1HY1 += theOpportunityLineItem.LT_Value_USD__c;
                    TH1HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    if( theOpportunityLineItem.Opportunity.StageName == 'Commitment' ){
                        Com1HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Decision' ){
                        Dec1HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Discovery' ){
                        Dis1HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Initial Engagement' ){
                        Eng1HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    }
                } 
                else if( theOpportunityLineItem.Opportunity.CloseDate.year() == Date.today().year() 
                    && theOpportunityLineItem.Opportunity.CloseDate.month() >= 7 
                    && theOpportunityLineItem.Opportunity.StageName != 'Lost'
                    && theOpportunityLineItem.Prod_Lost__c != true
                ){
                    DW2HY1 += theOpportunityLineItem.LT_Value_USD__c;
                    TH2HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    if( theOpportunityLineItem.Opportunity.StageName == 'Commitment' ){
                        Com2HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Decision' ){
                        Dec2HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Discovery' ){
                        Dis2HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Initial Engagement' ){
                        Eng2HY1 += theOpportunityLineItem.Claim_Value_USD__c;
                    }
                } 
                else if( theOpportunityLineItem.Opportunity.CloseDate.year() == Date.today().addYears(1).year() 
                    && theOpportunityLineItem.Opportunity.CloseDate.month() <= 6 
                    && theOpportunityLineItem.Opportunity.StageName != 'Lost'
                    && theOpportunityLineItem.Prod_Lost__c != true
                ){
                    DW1HY2 += theOpportunityLineItem.LT_Value_USD__c;
                    TH1HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    if( theOpportunityLineItem.Opportunity.StageName == 'Commitment' ){
                        Com1HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Decision' ){
                        Dec1HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Discovery' ){
                        Dis1HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Initial Engagement' ){
                        Eng1HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    }
                } 
                else if( theOpportunityLineItem.Opportunity.CloseDate.year() == Date.today().addYears(1).year() 
                    && theOpportunityLineItem.Opportunity.CloseDate.month() >= 7 
                    && theOpportunityLineItem.Opportunity.StageName != 'Lost'
                    && theOpportunityLineItem.Prod_Lost__c != true
                ){
                    DW2HY2 += theOpportunityLineItem.LT_Value_USD__c;
                    TH2HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    if( theOpportunityLineItem.Opportunity.StageName == 'Commitment' ){
                        Com2HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Decision' ){
                        Dec2HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Discovery' ){
                        Dis2HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Initial Engagement' ){
                        Eng2HY2 += theOpportunityLineItem.Claim_Value_USD__c;
                    }
                }
                else if( theOpportunityLineItem.Opportunity.CloseDate.year() == Date.today().addYears(2).year() 
                    && theOpportunityLineItem.Opportunity.CloseDate.month() <= 6 
                    && theOpportunityLineItem.Opportunity.StageName != 'Lost'
                    && theOpportunityLineItem.Prod_Lost__c != true
                ){
                    DW1HY3 += theOpportunityLineItem.LT_Value_USD__c;
                    TH1HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    if( theOpportunityLineItem.Opportunity.StageName == 'Commitment' ){
                        Com1HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Decision' ){
                        Dec1HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Discovery' ){
                        Dis1HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Initial Engagement' ){
                        Eng1HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    }
                } 
                else if( theOpportunityLineItem.Opportunity.CloseDate.year() == Date.today().addYears(2).year() 
                    && theOpportunityLineItem.Opportunity.CloseDate.month() >= 7 
                    && theOpportunityLineItem.Opportunity.StageName != 'Lost'
                    && theOpportunityLineItem.Prod_Lost__c != true
                ){
                    DW2HY3 += theOpportunityLineItem.LT_Value_USD__c;
                    TH2HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    if( theOpportunityLineItem.Opportunity.StageName == 'Commitment' ){
                        Com2HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Decision' ){
                        Dec2HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Discovery' ){
                        Dis2HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    } else if ( theOpportunityLineItem.Opportunity.StageName == 'Initial Engagement' ){
                        Eng2HY3 += theOpportunityLineItem.Claim_Value_USD__c;
                    }
                }
            }
        } //for( OpportunityLineItem theOpportunityLineItem : listOpportunityLineItems )

        /*
        List<OpportunityFieldHistory> listOpportunityFieldHistories = 
            [
                SELECT  Id,
                        OpportunityId,
                        OldValue,
                        NewValue,
                        CreatedDate
                FROM OpportunityFieldHistory
                WHERE Opportunity.Account.ParentId = :theParentAccount.Id
                AND Field = 'Percentage_to_DW_Completion__c'
                AND Opportunity.StageName != 'AOP'
                AND opportunity.RecordTypeID = :sfdcRecordTypeId
                AND Opportunity.CloseDate >= :PreviousYear 
                ORDER BY Opportunity.CloseDate ASC, CreatedDate DESC
            ];
    
        for( OpportunityFieldHistory theOpportunityFieldHistory : listOpportunityFieldHistories )
        {
            if( !mapOpportunityFieldHistories.containsKey( theOpportunityFieldHistory.OpportunityId ) )
            {
                List<OpportunityFieldHistory> listOFH = new List<OpportunityFieldHistory>();
                listOFH.add( theOpportunityFieldHistory );
                mapOpportunityFieldHistories.put(theOpportunityFieldHistory.OpportunityId , listOFH );
            } 
            else 
            {
                mapOpportunityFieldHistories.get(theOpportunityFieldHistory.OpportunityId).add(theOpportunityFieldHistory);
            }
        }
*/
        for( Task theTask : [SELECT Id, WhatId, Status 
                				FROM Task
                				WHERE WhatId IN : mapOpportunityLineItems.keySet()] )
        {
			Id OpptyId = theTask.WhatId;
            if( mapOpportunityTasksTotal.containsKey(OpptyId))
            {
				mapOpportunityTasksTotal.get(OpptyId).add(theTask);
            } 
            else 
            {   
                mapOpportunityTasksTotal.put(OpptyId , new List<Task>{theTask} );
            }
			
			if( theTask.Status != 'Completed')
			{
				if( mapOpportunityTasksOpen.containsKey(OpptyId))
				{
					mapOpportunityTasksOpen.get(OpptyId).add(theTask);
				} 
				else 
				{   
					mapOpportunityTasksOpen.put(OpptyId , new List<Task>{theTask} );
				}
			}
        }

        List<Opportunity> listAOPs = 
            [
                SELECT  Id,
                        Name,
                        StageName,
                        CloseDate,
                        AOP_value__c
                FROM Opportunity
                WHERE Account.ParentId = :theParentAccount.Id
                AND StageName = 'AOP'
                AND Opportunity.CloseDate >= :CurrentYear 
                ORDER BY CloseDate ASC
            ];
            System.debug(listAOPs+'*********');

        for( Opportunity theAOP : listAOPs )
        {
            if( theAOP.CloseDate.year() == Date.today().year() && theAOP.CloseDate.month() <= 6 )
            {
                AOP1HY1 += theAOP.AOP_value__c;
            } 
            else if( theAOP.CloseDate.year() == Date.today().year() && theAOP.CloseDate.month() >= 7 )
            {
                AOP2HY1 += theAOP.AOP_value__c;
            } 
            else if( theAOP.CloseDate.year() == Date.today().addYears(1).year() && theAOP.CloseDate.month() <= 6 )
            {
                AOP1HY2 += theAOP.AOP_value__c;
            } 
            else if( theAOP.CloseDate.year() == Date.today().addYears(1).year() && theAOP.CloseDate.month() >= 7 )
            {
                AOP2HY2 += theAOP.AOP_value__c;
            }
            else if( theAOP.CloseDate.year() == Date.today().addYears(2).year() && theAOP.CloseDate.month() <= 6 )
            {
                AOP1HY3 += theAOP.AOP_value__c;
            } 
            else if( theAOP.CloseDate.year() == Date.today().addYears(2).year() && theAOP.CloseDate.month() >= 7 )
            {
                AOP2HY3 += theAOP.AOP_value__c;
            }
        }
        
        for( Opportunity theOpportunity : listOpportunities ) 
        {
            DWwrapper theDWwrapper = new DWwrapper();
            //theDWwrapper.dwYear = theOpportunity.CloseDate.year();
            //theDWwrapper.dwHalf = (theOpportunity.CloseDate.month()+5)/6;
            //theDWwrapper.dwQuarter = (theOpportunity.CloseDate.month()+2)/3;
            theDWwrapper.DW = theOpportunity;
            theDWwrapper.dwStage = theOpportunity.StageName.substring(0,4); 
            theDWwrapper.listLineItems = mapOpportunityLineItems.get( theOpportunity.Id );
            //theDWwrapper.listFieldHistories = mapOpportunityFieldHistories.get( theOpportunity.Id );
            //theDWwrapper.listTasks = mapOpportunityTasks.get( theOpportunity.Id );
            //theDWwrapper.Percentage_to_DW_Completion_Prior_Week = findFieldHistoryFromPriorWeek( theOpportunity.Id );
            //theDWwrapper.tasksTotal = summarizeTasksTotal( theOpportunity.Id , theOpportunity.Name );
            //theDWwrapper.tasksOpen = summarizeTasksOpen( theOpportunity.Id , theOpportunity.Name );
            
            theDWwrapper.tasksTotal = (mapOpportunityTasksTotal.containsKey(theOpportunity.Id) ? mapOpportunityTasksTotal.get(theOpportunity.Id).size() : 0) ;
			theDWwrapper.tasksOpen = (mapOpportunityTasksOpen.containsKey(theOpportunity.Id) ? mapOpportunityTasksOpen.get(theOpportunity.Id).size() : 0) ;
			
			theDWwrapper.pricePerProgram = summarizePricePerProgram( theOpportunity.Id );
            theDWwrapper.entryVolume = summarizeEntryVolume( theOpportunity.Id );
            theDWwrapper.totalValue = summarizeTotalValue( theOpportunity.Id );
            //SIR1275 updates. Balaji G Date: 19-Oct-2016
            /*if(theOpportunity.Help_Needed__c <> null && (theOpportunity.Help_Needed__c.length() > Integer.ValueOf(System.Label.Tracker_Long_Text_Truncate_Limit)))
            {
              theDWWrapper.helpNeeded=theOpportunity.Help_Needed__c.subString(0,Integer.ValueOf(System.Label.Tracker_Long_Text_Truncate_Limit))+'(...)';
             }
            else
            {
              theDWWrapper.helpNeeded=theOpportunity.Help_Needed__c;
            }
*/
            if(theOpportunity.Next_Steps__c <> null && (theOpportunity.Next_Steps__c.length() > Integer.ValueOf(System.Label.Tracker_Long_Text_Truncate_Limit)))
            {
              theDWWrapper.nextStep=theOpportunity.Next_Steps__c.subString(0,Integer.ValueOf(System.Label.Tracker_Long_Text_Truncate_Limit))+'(...)';
             }
            else
            {
              theDWWrapper.nextStep=theOpportunity.Next_Steps__c;
            }            
            listDWwrapper.add( theDWwrapper );
        }
    } //TrackingSheetController(ApexPages.StandardController stdController)

    public static List<SelectOption> getOwners() 
    {
        String sfdcRecordTypeId = OpportunitiesSelector.getSfdcRecordTypeId();
        List<SelectOption> theOptions = new List<SelectOption>();
        Set<String> setOwners = new Set<String>();
        String accountIdString = ApexPages.currentPage().getParameters().get('id');
        for( Opportunity theOpportunity : 
            [
                 SELECT  Id,
                     Name,
                     OwnerId,
                     Owner.Name
                  FROM Opportunity
                  WHERE Account.ParentId = :accountIdString //:theParentAccount.Id 
                  AND RecordTypeID = :sfdcRecordTypeId
                  AND Reference_Design__c = false
                  AND (
                      (NOT(StageName ='AOP'))
                      AND
                      (NOT(StageName ='Cancelled'))
                      )
                  AND (CloseDate >= :CurrentYear )  
                  ORDER BY Owner.Name
            ])
        {
            if( ! setOwners.contains(theOpportunity.Owner.Name) )
            {
                theOptions.add(new SelectOption(theOpportunity.Owner.Name, theOpportunity.Owner.Name));
                setOwners.add(theOpportunity.Owner.Name);
            }
        }

        return theOptions;
    }

    public static List<SelectOption> getMAGs() 
    {
        String sfdcRecordTypeId = OpportunitiesSelector.getSfdcRecordTypeId();
        List<SelectOption> theOptions = new List<SelectOption>();
        Set<String> setMAGs = new Set<String>();
        String accountIdString = ApexPages.currentPage().getParameters().get('id');
        for( OpportunityLineItem theOpportunityLineItem : 
            [
               SELECT  Id,
                       OpportunityId,
                       MAG__c
                FROM OpportunityLineItem
                  WHERE Opportunity.Account.ParentId = :accountIdString //:theParentAccount.Id 
                  AND Opportunity.RecordTypeID = :sfdcRecordTypeId
                  AND Opportunity.Reference_Design__c = false
                  AND (
                      (NOT(Opportunity.StageName ='AOP'))
                      AND
                      (NOT(Opportunity.StageName ='Cancelled'))
                      )
                  AND (
                       Opportunity.CloseDate >= :CurrentYear 
                        OR
                       (
                       Opportunity.CloseDate < :CurrentYear 
                        AND
                        (
                         (NOT(Opportunity.StageName ='Lost')) 
                          AND
                         (NOT(Opportunity.StageName ='Commitment'))
                        )
                       )
                      )  
                  ORDER BY MAG__c
            ])
        {
            if( ! setMAGs.contains(theOpportunityLineItem.MAG__c) )
            {
                theOptions.add(new SelectOption(theOpportunityLineItem.MAG__c, theOpportunityLineItem.MAG__c));
                setMAGs.add(theOpportunityLineItem.MAG__c);
            }
        }

        return theOptions;
    }
    
	public static List<SelectOption> getBUs() 
    {
        String sfdcRecordTypeId = OpportunitiesSelector.getSfdcRecordTypeId();
        List<SelectOption> theOptions = new List<SelectOption>();
        Set<String> setBUs = new Set<String>();
        String accountIdString = ApexPages.currentPage().getParameters().get('id');
        for( OpportunityLineItem theOpportunityLineItem : 
            [
                SELECT  Id,
                       OpportunityId,
                       BU__c
                FROM OpportunityLineItem
                  WHERE Opportunity.Account.ParentId = :accountIdString //:theParentAccount.Id 
                  AND Opportunity.RecordTypeID = :sfdcRecordTypeId
                  AND Opportunity.Reference_Design__c = false
                  AND (
                      (NOT(Opportunity.StageName ='AOP'))
                      AND
                      (NOT(Opportunity.StageName ='Cancelled'))
                      )
                  AND (
                       Opportunity.CloseDate >= :CurrentYear 
                        OR
                       (
                       Opportunity.CloseDate < :CurrentYear 
                        AND
                        (
                         (NOT(Opportunity.StageName ='Lost')) 
                          AND
                         (NOT(Opportunity.StageName ='Commitment'))
                        )
                       )
                      )  
                  ORDER BY BU__c
            ])
        {
            if( ! setBUs.contains(theOpportunityLineItem.BU__c) )
            {
                theOptions.add(new SelectOption(theOpportunityLineItem.BU__c, theOpportunityLineItem.BU__c));
                setBUs.add(theOpportunityLineItem.BU__c);
            }
        }

        return theOptions;
    }
    
    /*
    public static String findFieldHistoryFromPriorWeek( Id theOpportunityId )
    {
        if( mapOpportunityFieldHistories.containsKey(theOpportunityId) )
        {
            for( OpportunityFieldHistory theFH : mapOpportunityFieldHistories.get(theOpportunityId) )
            {
                if( theFH.CreatedDate < Date.today().addDays(-7) ) 
                { 
                    if( theFH.OldValue != null && theFH.OldValue != '' )
                    {
                        return String.valueOf( theFH.OldValue )+'%';
                    } 
                    else 
                    {
                        return String.valueOf( theFH.NewValue )+'%';            
                    }
                }
            }
        }
        return null;     
    }
*/
    /*   
    public static Integer summarizeTasksTotal( Id theOpportunityId , String theOpportunityName)
    {
        Integer numberOfTasks = 0;

        if( mapOpportunityTasks.containsKey(theOpportunityId) )
        {
            for( Task theT : mapOpportunityTasks.get(theOpportunityId) )
            {
                if( theT.Subject != theOpportunityName ) 
                {
                    numberOfTasks++ ;
                }
            }
        }
        return numberOfTasks;     
    }

    public static Integer summarizeTasksOpen( Id theOpportunityId , String theOpportunityName )
    {
        Integer numberOfTasksOpen = 0;

        if( mapOpportunityTasks.containsKey(theOpportunityId) )
        {
            for( Task theT : mapOpportunityTasks.get(theOpportunityId) )
            {
                if( theT.Status != 'Completed' && theT.Subject != theOpportunityName ) 
                {
                    numberOfTasksOpen++ ;
                }
            }
        }
        return numberOfTasksOpen;     
    }
*/
    public static Decimal summarizePricePerProgram( Id theOpportunityId )
    {
        Decimal pricePerProgram = 0;

        if( mapOpportunityLineItems.containsKey(theOpportunityId) )
        {
            for( OpportunityLineItem theOLI : mapOpportunityLineItems.get(theOpportunityId) )
            {
                if( theOLI.UnitPrice != null && theOLI.Prod_Lost__c != true && theOLI.Opportunity.StageName!='Lost' ) 
                {
                    pricePerProgram += theOLI.UnitPrice * theOLI.Component_Multiplier__c ;
                }
            }
        }
        return pricePerProgram;     
    }

    public static Decimal summarizeEntryVolume( Id theOpportunityId )
    {
        Decimal entryVolume = 0;

        if( mapOpportunityLineItems.containsKey(theOpportunityId) )
        {
            for( OpportunityLineItem theOLI : mapOpportunityLineItems.get(theOpportunityId) )
            {
                /* Oppty 2 - Modified by Scarlett Jan 24, 2017
                if( theOLI.UnitPrice != null ) 
                {
                    entryVolume = theOLI.Opportunity.X2010_Pieces__c
                        + theOLI.Opportunity.X2011_Pieces__c
                        + theOLI.Opportunity.X2012_Pieces__c
                        + theOLI.Opportunity.X2013_Pieces__c
                        + theOLI.Opportunity.X2014_Pieces__c
                        + theOLI.Opportunity.X2015_Pieces__c
                        + theOLI.Opportunity.X2016_Pieces__c
                        + theOLI.Opportunity.X2017_Pieces__c
                        + theOLI.Opportunity.X2018_Pieces__c
                        + theOLI.Opportunity.X2019_Pieces__c
                        + theOLI.Opportunity.X2020_Pieces__c
                        + theOLI.Opportunity.X2021_Pieces__c
                        + theOLI.Opportunity.X2022_Pieces__c
                        + theOLI.Opportunity.X2023_Pieces__c
                        + theOLI.Opportunity.X2024_Pieces__c
                        + theOLI.Opportunity.X2025_Pieces__c
                        + theOLI.Opportunity.X2026_Pieces__c
                        + theOLI.Opportunity.X2027_Pieces__c
                        + theOLI.Opportunity.X2028_Pieces__c
                        + theOLI.Opportunity.X2029_Pieces__c
                        + theOLI.Opportunity.X2030_Pieces__c ;
                }
                Oppty 2 - Modified by Scarlett Jan 24, 2017 */
                
                entryVolume = theOLI.Quantity;// Oppty 2 - Added by Scarlett Jan 24, 2017
            }
        }
        return entryVolume;     
    }

    public static Decimal summarizeTotalValue( Id theOpportunityId )
    {
        Decimal totalValue = 0;

        if( mapOpportunityLineItems.containsKey(theOpportunityId) )
        {
            for( OpportunityLineItem theOLI : mapOpportunityLineItems.get(theOpportunityId) )
            {
                /* Oppty 2 - Modified by Scarlett Jan 24, 2017
                if( theOLI.UnitPrice != null && theOLI.Prod_Lost__c != true && theOLI.Opportunity.StageName!='Lost' ) 
                {
                    totalValue += theOLI.UnitPrice * theOLI.Component_Multiplier__c 
                        * ( theOLI.Opportunity.X2010_Pieces__c
                        + theOLI.Opportunity.X2011_Pieces__c
                        + theOLI.Opportunity.X2012_Pieces__c
                        + theOLI.Opportunity.X2013_Pieces__c
                        + theOLI.Opportunity.X2014_Pieces__c
                        + theOLI.Opportunity.X2015_Pieces__c
                        + theOLI.Opportunity.X2016_Pieces__c
                        + theOLI.Opportunity.X2017_Pieces__c
                        + theOLI.Opportunity.X2018_Pieces__c
                        + theOLI.Opportunity.X2019_Pieces__c
                        + theOLI.Opportunity.X2020_Pieces__c
                        + theOLI.Opportunity.X2021_Pieces__c
                        + theOLI.Opportunity.X2022_Pieces__c
                        + theOLI.Opportunity.X2023_Pieces__c
                        + theOLI.Opportunity.X2024_Pieces__c
                        + theOLI.Opportunity.X2025_Pieces__c
                        + theOLI.Opportunity.X2026_Pieces__c
                        + theOLI.Opportunity.X2027_Pieces__c
                        + theOLI.Opportunity.X2028_Pieces__c
                        + theOLI.Opportunity.X2029_Pieces__c
                        + theOLI.Opportunity.X2030_Pieces__c
                        );
                }
                Oppty 2 - Modified by Scarlett Jan 24, 2017 */
                
                totalValue += theOLI.LT_Value_USD__c;// Oppty 2 - Added by Scarlett Jan 24, 2017
            }
        }
        return totalValue;     
    }
}