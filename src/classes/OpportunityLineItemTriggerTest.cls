/* Why: 15.03 CRM Million Dollar Approval 
 * What: Test Class for OpportunityLineItemTrigger
 * Who: Stan Hsu
 * When: Feb 27, 2015
 */
/********************************************************************
 * Why: Release 1504 - Forecasting Production Management Project
 * Who: Stan Hsu
 * When: May 8th, 2015
 * What: Test Class for Production Management
 * *****************************************************************/
/* 
*  Modified by: Stan Hsu
*  For: Release 2015.10 SIR# 470 Skywalker: Opportunity Cancelled
*/
/* 
*  Modified by: Stan Hsu
*  For: Release 2015.11 SIR# 520 Iactive Product Inactive PricebookEntry
*/

/* 
*  Modified by: Jewelslyn
*  For: Release 2016.8 SIR# 722 clean Up of Region, MAg fields and replaced with Criteria 1, Criteria 2 fields
*/

/*********************************************************************************************
@Modified By :      Venkateshwar G
@Modified Date :    26 July 2016
Description :      Written test methods to cover the AttachmentTrigger and NoteTrigger Triggers functionality of 
                   Attachment and Note object respectively
****************************************************************************************************/

/* 
*  Modified by: Balaji G
*  For: Release 2016.9 SIR# 958 
*  Description: Adjusted test data to comply with validation rule - Competitor, Loss/Cancelled Reason and
                Description required for Lost/Cancelled Opportunities
*/

/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
private class OpportunityLineItemTriggerTest {
    
   
////////////////////////////////////////////////////////////////////////////////////////////////////
//  PRODUCTION MANAGEMENT TESTS
////////////////////////////////////////////////////////////////////////////////////////////////
    private static final String SFDC_OPPTY_RECORD_TYPE_NAME = 'SFDCOppty';
    private final static String REGION_AMEC = 'Americas';
    private final static String REGION_EMEA = 'EMEA';
    private final static String REGION_GC = 'Greater China';
    private final static String REGION_JAPAN = 'Japan';
    private final static String REGION_KOREA = 'Korea';
    private final static String REGION_SAP = 'South Asia Pacific';
    private final static String APPROVER_TYPE_REGIONAL_VP = 'Regional VP';
    private final static String APPROVER_TYPE_REGIONAL_CONTROLLER = 'Regional Controller';
    private final static String APPROVER_TYPE_SEGMENT_VP = 'Segment VP';
    private final static String APPROVER_TYPE_SEGMENT_CONTROLLER = 'Segment Controller';
    private final static String APPROVER_TYPE_PRODUCT_MARKETING = 'Product Marketing';
    private final static String APPROVER_TYPE_PRODUCT_CONTROLLER = 'Product Controller';

    private static Id sfdcOpptyRecordTypeId()
    {
        List<RecordType> listRecordType = new List<RecordType>
            ([
                SELECT Id
                FROM RecordType
                WHERE Name = :SFDC_OPPTY_RECORD_TYPE_NAME
            ]);
        if( listRecordType.size() > 0 )
        {
            return listRecordType[0].Id;
        }
        else
        {
            return null;
        }
    }
    
    private static Product2 testProduct = new Product2();
    private static Id standardPricebookId = Test.getStandardPricebookId();
    private static PricebookEntry testPricebookEntry = new PricebookEntry();
    private static User testUser = new User();
    private static Account testAccount = new Account();
    private static Opportunity testOpportunity2010 = new Opportunity();
    private static Opportunity testOpportunity2011 = new Opportunity();
    private static Opportunity testOpportunity2012 = new Opportunity();
    private static Opportunity testOpportunity2013 = new Opportunity();
    private static Opportunity testOpportunity2014 = new Opportunity();
    private static Opportunity testOpportunity2015 = new Opportunity();
    private static Opportunity testOpportunity2016 = new Opportunity();
    private static Opportunity testOpportunity2017 = new Opportunity();
    private static Opportunity testOpportunity2018 = new Opportunity();
    private static Opportunity testOpportunity2019 = new Opportunity();
    private static Opportunity testOpportunity2020 = new Opportunity();
    private static Opportunity testOpportunity2021 = new Opportunity();
    private static Opportunity testOpportunity2022 = new Opportunity();
    private static Opportunity testOpportunity2023 = new Opportunity();
    private static Opportunity testOpportunityProductionManagementAutomation = new Opportunity();

    private static OpportunityLineItem testOpportunityLineItem2010 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2011 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2012 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2013 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2014 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2015 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2016 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2017 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2018 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2019 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2020 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2021 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2022 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItem2023 = new OpportunityLineItem();
    private static OpportunityLineItem testOpportunityLineItemProductionManagementAutomation = new OpportunityLineItem();

  /*  private static Production_Management__c testProductionManagement2010 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2011 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2012 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2013 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2014 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2015 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2016 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2017 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2018 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2019 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2020 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2021 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2022 = new Production_Management__c();
    private static Production_Management__c testProductionManagement2023 = new Production_Management__c();*/
        
    private static Product2 createProduct( String theMAG )
    {
        Product2 theProduct = new Product2
            (
                Name = 'Test Product',
                Sales_Item__c = '123456789012',
                MAG__c = theMAG,
/*Added for 2015.11 SIR#520*/isActive = True 
            );
        return theProduct;
    }

    private static PricebookEntry createStandardPricebookEntry( Id theProductId )
    {
        List<PricebookEntry> findPricebookEntry = new List<PricebookEntry>
            ([
                SELECT Id,
                    Product2Id,
                    Pricebook2Id,
                    CurrencyISOCode,
                    UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :standardPricebookId
                AND Product2Id = :theProductId
                AND CurrencyISOCode = 'USD'
            ]);
        
        if( findPricebookEntry.size() > 0 )
        {
            return findPricebookEntry[0];
        }
        else{ 
            PricebookEntry thePricebookEntry = new PricebookEntry
                (
                    Product2Id = theProductId,
                    Pricebook2Id = standardPricebookId,
                    CurrencyISOCode = 'USD',
                    UnitPrice = 1,
                    IsActive = true
                );
            return thePricebookEntry;
        }
    }
    
    private static void insertFXRates()
    {
        FX_Rates__c theUSD = new FX_Rates__c
            (
                Currency_Code__c = 'USD',
                Exchange_Rate__c = 1
            );
        insert theUSD;
    }

    private static void insertTestUser()
    {
        Profile theProfile = [Select p.Name, p.Id From Profile p where Name = 'NXP Sales'];

        testUser = new User
            (
                alias = 'tempt', 
                email='productionmanagement.test@nxp.com.test',
                emailencodingkey='UTF-8', 
                lastname='Testing', 
                languagelocalekey='en_US',
                localesidkey='en_US', 
                profileid = theProfile.Id,
                timezonesidkey='America/Los_Angeles', 
                username='productionmanagement.test@nxp.com.test'
            );
        insert testUser;
    }
    
      
    private static void insertApproverMatrix( Id testUserId )
    {
        List<Approvers_Matrix__c> listApproversToBeInserted = new List<Approvers_Matrix__c>();
        
        Approvers_Matrix__c testApproverRegionalVPAmericas = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_VP,
                criteria_2__c = REGION_AMEC
            );
        listApproversToBeInserted.add( testApproverRegionalVPAmericas );

        Approvers_Matrix__c testApproverRegionalVPEMEA = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_VP,
                criteria_2__c= REGION_EMEA
            );
        listApproversToBeInserted.add( testApproverRegionalVPEMEA );

        Approvers_Matrix__c testApproverRegionalVPGreaterChina = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_VP,
                criteria_2__c = REGION_GC
            );
        listApproversToBeInserted.add( testApproverRegionalVPGreaterChina );

        Approvers_Matrix__c testApproverRegionalVPJapan = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_VP,
                criteria_2__c = REGION_JAPAN
            );
        listApproversToBeInserted.add( testApproverRegionalVPJapan );

        Approvers_Matrix__c testApproverRegionalVPKorea = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_VP,
                criteria_2__c = REGION_KOREA
            );
        listApproversToBeInserted.add( testApproverRegionalVPKorea );

        Approvers_Matrix__c testApproverRegionalVPSAP = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_VP,
                criteria_2__c = REGION_SAP
            );
        listApproversToBeInserted.add( testApproverRegionalVPSAP );

        Approvers_Matrix__c testApproverRegionalControllerAmericas = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_CONTROLLER,
                criteria_2__c = REGION_AMEC
            );
        listApproversToBeInserted.add( testApproverRegionalControllerAmericas );

        Approvers_Matrix__c testApproverRegionalControllerEMEA = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_CONTROLLER,
                criteria_2__c = REGION_EMEA
            );
        listApproversToBeInserted.add( testApproverRegionalControllerEMEA );

        Approvers_Matrix__c testApproverRegionalControllerGreaterChina = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_CONTROLLER,
                criteria_2__c = REGION_GC
            );
        listApproversToBeInserted.add( testApproverRegionalControllerGreaterChina );

        Approvers_Matrix__c testApproverRegionalControllerJapan = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_CONTROLLER,
                criteria_2__c = REGION_JAPAN
            );
        listApproversToBeInserted.add( testApproverRegionalControllerJapan );

        Approvers_Matrix__c testApproverRegionalControllerKorea = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_CONTROLLER,
                criteria_2__c = REGION_KOREA
            );
        listApproversToBeInserted.add( testApproverRegionalControllerKorea );

        Approvers_Matrix__c testApproverRegionalControllerSAP = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_REGIONAL_CONTROLLER,
                criteria_2__c = REGION_SAP
            );
        listApproversToBeInserted.add( testApproverRegionalControllerSAP );

        Approvers_Matrix__c testApproverSegmentVP = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_SEGMENT_VP
                
            );
        listApproversToBeInserted.add( testApproverSegmentVP );

        Approvers_Matrix__c testApproverSegmentController = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_SEGMENT_CONTROLLER
                
            );
        listApproversToBeInserted.add( testApproverSegmentController );

        Approvers_Matrix__c testApproverProductMarketing = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_PRODUCT_MARKETING,
                Criteria_1__c = 'R33'
            );
        listApproversToBeInserted.add( testApproverProductMarketing );

        Approvers_Matrix__c testApproverProductController = new Approvers_Matrix__c
            (
                Approver__c = testUserId,
                Type__c = APPROVER_TYPE_PRODUCT_CONTROLLER,
                Criteria_1__c = 'R33'
            );
        listApproversToBeInserted.add( testApproverProductController );
        
        insert listApproversToBeInserted;
    }

    private static void insertTestAccount()
    {
        testAccount = new Account
            (
                Name='Test Account',
                Customer_Category__c='Strategic',
                Industry_Segment__c='Mobile',
                Region__c ='Americas'
            );
        upsert testAccount;
    }

    private static Opportunity createOpportunity( Id testAccountId , Integer theYear, String theQuarter )
    {
        Opportunity theOpportunity = new Opportunity 
            (
                Name='Test Opportunity',
                AccountId = testAccountId,
                X2010_Pieces__c = 0,
                X2011_Pieces__c = 0,
                X2012_Pieces__c = 0,
                X2013_Pieces__c = 0,
                X2014_Pieces__c = 0,
                X2015_Pieces__c = 0,
                X2016_Pieces__c = 0,
                X2017_Pieces__c = 0,
                X2018_Pieces__c = 0,
                X2019_Pieces__c = 0,
                X2020_Pieces__c = 0,
                X2021_Pieces__c = 0,
                X2022_Pieces__c = 0,
                X2023_Pieces__c = 0,
                X2024_Pieces__c = 0,
                X2025_Pieces__c = 0,
                StageName = 'Initial Engagement',
                CurrencyIsoCode = 'USD',
                Locked_Exchange_Rate__c = 1
            );
        if( theQuarter == 'Q1' )
        {
            theOpportunity.CloseDate = Date.newInstance( theYear, 1, 1);
            theOpportunity.Production_Date__c = Date.newInstance( theYear, 3, 1);
        }
        else if( theQuarter == 'Q2' )
        {
            theOpportunity.CloseDate = Date.newInstance( theYear, 4, 1);
            theOpportunity.Production_Date__c = Date.newInstance( theYear, 6, 1);
        }
        else if( theQuarter == 'Q3' )
        {
            theOpportunity.CloseDate = Date.newInstance( theYear, 7, 1);
            theOpportunity.Production_Date__c = Date.newInstance( theYear, 9, 1);
        }
        else
        {
            theOpportunity.CloseDate = Date.newInstance( theYear, 10, 1);
            theOpportunity.Production_Date__c = Date.newInstance( theYear, 12, 1);
        }
        if( theYear <= 2010 && theYear+3 >= 2010 )
        {
           theOpportunity.X2010_Pieces__c = 100;
        }
        if( theYear <= 2011 && theYear+3 >= 2011 )
        {
           theOpportunity.X2011_Pieces__c = 100;
        }
        if( theYear <= 2012 && theYear+3 >= 2012 )
        {
           theOpportunity.X2012_Pieces__c = 100;
        }
        if( theYear <= 2013 && theYear+3 >= 2013 )
        {
           theOpportunity.X2013_Pieces__c = 100;
        }
        if( theYear <= 2014 && theYear+3 >= 2014 )
        {
           theOpportunity.X2014_Pieces__c = 100;
        }
        if( theYear <= 2015 && theYear+3 >= 2015 )
        {
           theOpportunity.X2015_Pieces__c = 100;
        }
        if( theYear <= 2016 && theYear+3 >= 2016 )
        {
           theOpportunity.X2016_Pieces__c = 100;
        }
        if( theYear <= 2017 && theYear+3 >= 2017 )
        {
           theOpportunity.X2017_Pieces__c = 100;
        }
        if( theYear <= 2018 && theYear+3 >= 2018 )
        {
           theOpportunity.X2018_Pieces__c = 100;
        }
        if( theYear <= 2019 && theYear+3 >= 2019 )
        {
           theOpportunity.X2019_Pieces__c = 100;
        }
        if( theYear <= 2020 && theYear+3 >= 2020 )
        {
           theOpportunity.X2020_Pieces__c = 100;
        }
        if( theYear <= 2021 && theYear+3 >= 2021 )
        {
           theOpportunity.X2021_Pieces__c = 100;
        }
        if( theYear <= 2022 && theYear+3 >= 2022 )
        {
           theOpportunity.X2022_Pieces__c = 100;
        }
        if( theYear <= 2023 && theYear+3 >= 2023 )
        {
           theOpportunity.X2023_Pieces__c = 100;
        }
        if( theYear <= 2024 && theYear+3 >= 2024 )
        {
           theOpportunity.X2024_Pieces__c = 100;
        }
        if( theYear <= 2025 && theYear+3 >= 2025 )
        {
           theOpportunity.X2025_Pieces__c = 100;
        }
        return theOpportunity;
    }
    
    private static OpportunityLineItem createOpportunityLineItem( Id theOpportunityId, String theMAG )
    {
        OpportunityLineItem theOpportunityLineItem = new OpportunityLineItem
            (
                OpportunityId = theOpportunityId,
                PricebookEntryId = testPricebookEntry.Id,
                Quantity = 1,
                UnitPrice = 1,
                Component_Multiplier__c = 1
            );
        return theOpportunityLineItem;
    }

 /*   private static Production_Management__c createProductionManagement( Id theOpportunityId, Id theOpportunityLineItemId , Id theProduct2Id )
    {
        Production_Management__c theProductionManagement = new Production_Management__c
            (
                Name = 'Test Production Management',
                OpportunityId__c = theOpportunityId,
                OpportunityLineItem_Id__c = theOpportunityLineItemId,
                Product2Id__c = theProduct2Id            
            );
        return theProductionManagement; 
    }*/

    static User addTestUsers(){

        List<User> uList;
        User u;
        uList = [select Id, profileid from User where username = 'temptest@nxp.com.test' limit 1];
        
        if (uList == null || uList.size() < 1){
            Profile standProf = [Select p.Name, p.Id From Profile p where Name = 'Standard User'];
            u = new User(alias = 'tempt', email='temptest@nxp.com.test',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = standProf.Id,
            timezonesidkey='America/Los_Angeles', username='temptest@nxp.com.test');
            insert u;
        }else{
            u = uList[0];
        }           
        return u;
    }
    
   /* static testMethod void testAddingProductionManagement2010Q1() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2010 = createOpportunity( testAccount.Id, 2010, 'Q1' );
        insert testOpportunity2010;
        
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity2010.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;
        
        testOpportunityLineItem2010 = createOpportunityLineItem( testOpportunity2010.Id , 'R33' );
        insert testOpportunityLineItem2010;
        Fullfillment_Part__c testFulfillmentPart2010 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2010.Id,
                Production_Year__c = 2010,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2010;
        testProductionManagement2010 = createProductionManagement( testOpportunity2010.Id, testOpportunityLineItem2010.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2010;
        Test.stopTest();

    }
    
    static testMethod void testAddingProductionManagement2010Q2() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2010 = createOpportunity( testAccount.Id, 2010, 'Q2' );
        insert testOpportunity2010;
        
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity2010.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;
        
        testOpportunityLineItem2010 = createOpportunityLineItem( testOpportunity2010.Id , 'R33' );
        insert testOpportunityLineItem2010;
        Fullfillment_Part__c testFulfillmentPart2010 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2010.Id,
                Production_Year__c = 2010,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2010;
        testProductionManagement2010 = createProductionManagement( testOpportunity2010.Id, testOpportunityLineItem2010.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2010;
        Test.stopTest();

    }
    
    static testMethod void testAddingProductionManagement2010Q3() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2010 = createOpportunity( testAccount.Id, 2010, 'Q3' );
        insert testOpportunity2010;
        
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity2010.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;
        
        testOpportunityLineItem2010 = createOpportunityLineItem( testOpportunity2010.Id , 'R33' );
        insert testOpportunityLineItem2010;
        Fullfillment_Part__c testFulfillmentPart2010 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2010.Id,
                Production_Year__c = 2010,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2010;
        testProductionManagement2010 = createProductionManagement( testOpportunity2010.Id, testOpportunityLineItem2010.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2010;
        Test.stopTest();

    }
    
   static testMethod void testAddingProductionManagement2010Q4() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2010 = createOpportunity( testAccount.Id, 2010, 'Q4' );
        insert testOpportunity2010;
        
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity2010.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;
        
        testOpportunityLineItem2010 = createOpportunityLineItem( testOpportunity2010.Id , 'R33' );
        insert testOpportunityLineItem2010;
        Fullfillment_Part__c testFulfillmentPart2010 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2010.Id,
                Production_Year__c = 2010,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2010;
        testProductionManagement2010 = createProductionManagement( testOpportunity2010.Id, testOpportunityLineItem2010.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2010;
        Test.stopTest();

    }

  /*  static testMethod void testAddingProductionManagement2011() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2011 = createOpportunity( testAccount.Id, 2011, 'Q1' );
        insert testOpportunity2011;
        
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity2011.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;
        
        testOpportunityLineItem2011 = createOpportunityLineItem( testOpportunity2011.Id , 'R33' );
        insert testOpportunityLineItem2011;
        Fullfillment_Part__c testFulfillmentPart2011 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2011.Id,
                Production_Year__c = 2011,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2011;
        testProductionManagement2011 = createProductionManagement( testOpportunity2011.Id, testOpportunityLineItem2011.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2011;
        List<Id> testListProductionmanagementIds = new List<Id>{ testProductionManagement2011.Id };
        ProductionManagementUtility.makeSnapshot( testListProductionmanagementIds );
        Test.stopTest();
    } */
/*
    static testMethod void testAddingProductionManagement2012() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2012 = createOpportunity( testAccount.Id, 2012, 'Q1' );
        insert testOpportunity2012;
        
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity2012.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;
        
        testOpportunityLineItem2012 = createOpportunityLineItem( testOpportunity2012.Id , 'R33' );
        insert testOpportunityLineItem2012;
        Fullfillment_Part__c testFulfillmentPart2012 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2012.Id,
                Production_Year__c = 2012,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2012;
        testProductionManagement2012 = createProductionManagement( testOpportunity2012.Id, testOpportunityLineItem2012.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2012;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2013() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
      //  OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2013 = createOpportunity( testAccount.Id, 2013, 'Q1' );
        insert testOpportunity2013;
        
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity2013.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;
        
        testOpportunityLineItem2013 = createOpportunityLineItem( testOpportunity2013.Id , 'R33' );
        insert testOpportunityLineItem2013;
        Fullfillment_Part__c testFulfillmentPart2013 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2013.Id,
                Production_Year__c = 2013,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2013;
        testProductionManagement2013 = createProductionManagement( testOpportunity2013.Id, testOpportunityLineItem2013.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2013;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2014() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
      //  OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2014 = createOpportunity( testAccount.Id, 2014, 'Q2' );
        insert testOpportunity2014;
        testOpportunityLineItem2014 = createOpportunityLineItem( testOpportunity2014.Id , 'R33' );
        insert testOpportunityLineItem2014;
        Fullfillment_Part__c testFulfillmentPart2014 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2014.Id,
                Production_Year__c = 2014,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2014;
        testProductionManagement2014 = createProductionManagement( testOpportunity2014.Id, testOpportunityLineItem2014.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2014;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2015() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2015 = createOpportunity( testAccount.Id, 2015, 'Q1' );
        insert testOpportunity2015;
        testOpportunityLineItem2015 = createOpportunityLineItem( testOpportunity2015.Id , 'R33' );
        insert testOpportunityLineItem2015;
        Fullfillment_Part__c testFulfillmentPart2015 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2015.Id,
                Production_Year__c = 2015,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2015;
        testProductionManagement2015 = createProductionManagement( testOpportunity2015.Id, testOpportunityLineItem2015.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2015;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2016() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2016 = createOpportunity( testAccount.Id, 2016, 'Q1' );
        insert testOpportunity2016;
        testOpportunityLineItem2016 = createOpportunityLineItem( testOpportunity2016.Id , 'R33' );
        insert testOpportunityLineItem2016;
        Fullfillment_Part__c testFulfillmentPart2016 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2016.Id,
                Production_Year__c = 2016,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2016;
        testProductionManagement2016 = createProductionManagement( testOpportunity2016.Id, testOpportunityLineItem2016.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2016;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2017() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
      //  OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2017 = createOpportunity( testAccount.Id, 2017, 'Q1' );
        insert testOpportunity2017;
        testOpportunityLineItem2017 = createOpportunityLineItem( testOpportunity2017.Id , 'R33' );
        insert testOpportunityLineItem2017;
        Fullfillment_Part__c testFulfillmentPart2017 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2017.Id,
                Production_Year__c = 2017,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2017;
        testProductionManagement2017 = createProductionManagement( testOpportunity2017.Id, testOpportunityLineItem2017.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2017;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2018() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2018 = createOpportunity( testAccount.Id, 2018, 'Q3' );
        insert testOpportunity2018;
        testOpportunityLineItem2018 = createOpportunityLineItem( testOpportunity2018.Id , 'R33' );
        insert testOpportunityLineItem2018;
        Fullfillment_Part__c testFulfillmentPart2018 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2018.Id,
                Production_Year__c = 2018,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2018;
        testProductionManagement2018 = createProductionManagement( testOpportunity2018.Id, testOpportunityLineItem2018.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2018;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2019() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
      //  OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2019 = createOpportunity( testAccount.Id, 2019, 'Q1' );
        insert testOpportunity2019;
        testOpportunityLineItem2019 = createOpportunityLineItem( testOpportunity2019.Id , 'R33' );
        insert testOpportunityLineItem2019;
        Fullfillment_Part__c testFulfillmentPart2019 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2019.Id,
                Production_Year__c = 2019,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2019;
        testProductionManagement2019 = createProductionManagement( testOpportunity2019.Id, testOpportunityLineItem2019.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2019;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2020() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
      //  OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2020 = createOpportunity( testAccount.Id, 2020, 'Q4' );
        insert testOpportunity2020;
        testOpportunityLineItem2020 = createOpportunityLineItem( testOpportunity2020.Id , 'R33' );
        insert testOpportunityLineItem2020;
        Fullfillment_Part__c testFulfillmentPart2020 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2020.Id,
                Production_Year__c = 2020,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2020;
        testProductionManagement2020 = createProductionManagement( testOpportunity2020.Id, testOpportunityLineItem2020.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2020;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2021() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
      //  OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2021 = createOpportunity( testAccount.Id, 2021, 'Q4' );
        insert testOpportunity2021;
        testOpportunityLineItem2021 = createOpportunityLineItem( testOpportunity2021.Id , 'R33' );
        insert testOpportunityLineItem2021;
        Fullfillment_Part__c testFulfillmentPart2021 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2021.Id,
                Production_Year__c = 2021,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2021;
        testProductionManagement2021 = createProductionManagement( testOpportunity2021.Id, testOpportunityLineItem2021.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2021;
        Test.stopTest();
    }
    
    static testMethod void testAddingProductionManagement2022() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2022 = createOpportunity( testAccount.Id, 2022, 'Q4' );
        insert testOpportunity2022;
        testOpportunityLineItem2022 = createOpportunityLineItem( testOpportunity2022.Id , 'R33' );
        insert testOpportunityLineItem2022;
        Fullfillment_Part__c testFulfillmentPart2022 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2022.Id,
                Production_Year__c = 2022,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2022;
        testProductionManagement2022 = createProductionManagement( testOpportunity2022.Id, testOpportunityLineItem2022.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2022;
        Test.stopTest();
    }

    static testMethod void testAddingProductionManagement2023() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertFXRates();
        insertTestUser();   
//        insertOpportunityApprovalSettings();
//        insertApproverMatrix( testUser.Id );
        insertTestAccount();
       // OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2023 = createOpportunity( testAccount.Id, 2023, 'Q4' );
        insert testOpportunity2023;
        testOpportunityLineItem2023 = createOpportunityLineItem( testOpportunity2023.Id , 'R33' );
        insert testOpportunityLineItem2023;
        Fullfillment_Part__c testFulfillmentPart2023 = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity2023.Id,
                Production_Year__c = 2023,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPart2023;
        testProductionManagement2023 = createProductionManagement( testOpportunity2023.Id, testOpportunityLineItem2023.Id , testProduct.Id );
        Test.startTest();
        insert testProductionManagement2023;
        Test.stopTest();
    }
    */
////////////////////////////////////////////////////////////////////////////////////////////////    
/************** 2015.07 Production Management Automation *** Code Block BEGIN ***************************/
/************** 2015.08 SIR#311 Production Management for Model N & SFDC *** Code Block BEGIN ***************************/
  /*  static testMethod void testProductionManagementAutomationSFDCPositiveTest() 
    {
        String recordTypeId = OpportunityHelper.getSfdcRecordTypeID();
        testProduct = createProduct( 'R01' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
        insertTestUser();   
        insertTestAccount();
//        OpportunityApproversUtility.setbDonePopulatingApprovers();
        Opportunity testOpportunity = createOpportunity( testAccount.Id, 2015, 'Q1' );
        testOpportunity.RecordTypeId = recordTypeId;
        testOpportunity.Reference_Design__c = false;
        testOpportunity.StageName = 'Decision';
        testOpportunity.X2015_Pieces__c = 100000;
        testOpportunity.X2016_Pieces__c = 200000;
        testOpportunity.X2017_Pieces__c = 200000;
        Test.startTest();
        insert testOpportunity;
    
      /************** 2016.08 Test Medhods for the the AttachmentTrigger and NoteTrigger *** Code Block BEGIN *******************            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            Attachment attach=new Attachment();
            attach.ParentId=testOpportunity.id;
            attach.Name='Unit Test Attachment';
            attach.body=bodyBlob;            
            insert attach;
            system.assert(attach.Id!=null);
            
            Note note=new Note();
            note.ParentId=testOpportunity.id;
            note.Title='Test Note';
            note.Body='Test Note Body';
            insert note; 
            system.assert(note.Id!=null); 
          Opportunity testOppty= [Select Id,numAtts__c From Opportunity where id =:testOpportunity.Id];
          System.assert( testOppty.numAtts__c == 2 );
    
        testOpportunity.StageName = 'Commitment';
        testOpportunity.Design_Win_Approval_Process__c = 'Approved';
        testOpportunity.Design_Win_Submission_Date__c = Date.today();
        testOpportunity.Design_Win_Approval_Date__c = Date.today();
        update testOpportunity;
        
        Attachment attachDel= [Select Id, Name, Body,ParentId From Attachment where ParentId=:testOpportunity.Id];
        Delete attachDel;
        Note noteDel= [Select Id, Title, Body,ParentId From Note where ParentId=:testOpportunity.Id];
        Delete noteDel;
        System.assertEquals(testOpportunity.numAtts__c,null);
        /************** 2016.08 Test Medhods for the the AttachmentTrigger and NoteTrigger *** Code Block ENDS**************        
                
        Test.stopTest();

    }
    
    static testMethod void testProductionManagementAutomationSFDCPositiveTest1() 
    {
        OpportunityTrigger.fetchOppRecordTypes();
        String recordTypeId = OpportunityTrigger.sfdcRecordtype_Id;
        testProduct = createProduct( 'R01' );
        
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
        insertTestUser();   
        insertTestAccount();
//        OpportunityApproversUtility.setbDonePopulatingApprovers();
        Opportunity testOpportunity = createOpportunity( testAccount.Id, 2015, 'Q1' );
        testOpportunity.RecordTypeId = recordTypeId;
        testOpportunity.Reference_Design__c = false;
        testOpportunity.StageName = 'Decision';
        testOpportunity.X2015_Pieces__c = 100000;
        testOpportunity.X2016_Pieces__c = 200000;
        testOpportunity.X2017_Pieces__c = 200000;
        Test.startTest();
        insert testOpportunity;
    
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;    
    
        OpportunityLineItem testLineItemR01Big = createOpportunityLineItem( testOpportunity.Id , 'R01' );
        testLineItemR01Big.UnitPrice = 2;
        insert testLineItemR01Big;

        Fullfillment_Part__c testFulfillmentPartProductionManagementAutomation = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity.Id,
                Production_Year__c = 2015,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPartProductionManagementAutomation;

        List<Production_Management_Threshold__c> listProductionManagementCustomSettings = new List<Production_Management_Threshold__c>
            ([
                SELECT Id
                FROM Production_Management_Threshold__c
            ]);
            Test.stopTest();
        System.debug('TEST STAN: Production_Management_Threshold__c = '+listProductionManagementCustomSettings.size());

    }

    static testMethod void testProductionManagementAutomationSFDCNegativeTest() 
    {
        String recordTypeId = OpportunityHelper.getSfdcRecordTypeID();
        testProduct = createProduct( 'R01' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
        insertTestUser();   
        insertTestAccount();
      //  OpportunityApproversUtility.setbDonePopulatingApprovers();
        Opportunity testOpportunity = createOpportunity( testAccount.Id, 2015, 'Q1' );
        testOpportunity.RecordTypeId = recordTypeId;
        testOpportunity.Reference_Design__c = false;
        testOpportunity.StageName = 'Decision';
        testOpportunity.X2015_Pieces__c = 100000;
        testOpportunity.X2016_Pieces__c = 200000;
        testOpportunity.X2017_Pieces__c = 200000;
        insert testOpportunity;

        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;

        OpportunityLineItem testLineItemR01Small = createOpportunityLineItem( testOpportunity.Id , 'R01' );
        testLineItemR01Small.UnitPrice = 1;
        insert testLineItemR01Small;

        Fullfillment_Part__c testFulfillmentPartProductionManagementAutomation = new Fullfillment_Part__c
            (
                Opportunity__c = testOpportunity.Id,
                Production_Year__c = 2015,
                Fullfillment_Part__c = testProduct.Id
            ); 
        insert testFulfillmentPartProductionManagementAutomation;

        Test.startTest();
        testOpportunity.StageName = 'Commitment';
        testOpportunity.Design_Win_Approval_Process__c = 'Approved';
        testOpportunity.Design_Win_Submission_Date__c = Date.today();
        testOpportunity.Design_Win_Approval_Date__c = Date.today();
        update testOpportunity;
        Test.stopTest();
        
        List<Production_Management__c> checkProductionManagementSFDCR01Small = new List<Production_Management__c>
            ([
                SELECT Id
                FROM Production_Management__c
                WHERE OpportunityLineItem_Id__c = :testLineItemR01Small.Id
            ]);
//        System.assert( checkProductionManagementSFDCR01Small.size() == 0 );
    }
    
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Opportunity Spin Off Test @@@@@@@@@@@@@@@@@@@@@@@@*/   

/** Stan Hsu For SIR#470 ****** BEGIN ******/
    static testMethod void testOpportunityProductLost() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertTestUser();   
        insertTestAccount();
//        OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2010 = createOpportunity( testAccount.Id, 2010, 'Q1' );
        insert testOpportunity2010;
        
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity2010.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;
        
        testOpportunityLineItem2010 = createOpportunityLineItem( testOpportunity2010.Id , 'R33' );
        insert testOpportunityLineItem2010;
//        testOpportunityLineItem2010.Prod_Lost_Cancelled__c = 'Lost';
//        testOpportunityLineItem2010.Prod_Lost_Cancelled_Reason__c = 'TEST';
//        update testOpportunityLineItem2010;
        testOpportunity2010.StageName = 'Lost';
        testOpportunity2010.Lost_Reason__c = 'TEST';
        testOpportunity2010.Lost_Description__c = 'testtesttesttesttesttesttesttesttesttesttesttesttest';
        testOpportunity2010.Competitors__c = 'CAVIUM'; //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule
        update testOpportunity2010;
    }

    static testMethod void testOpportunityProductCancelled() 
    {
        testProduct = createProduct( 'R33' );
        insert testProduct;
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
//        insertTestUser();   
        insertTestAccount();
//        OpportunityApproversUtility.setbDonePopulatingApprovers();
        testOpportunity2010 = createOpportunity( testAccount.Id, 2010, 'Q1' );
        insert testOpportunity2010;
        
        //must create opportunity schedules before creating opportunity products
        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = testOpportunity2010.Id, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
        insert opptySched;
        
        testOpportunityLineItem2010 = createOpportunityLineItem( testOpportunity2010.Id , 'R33' );
        insert testOpportunityLineItem2010;
//        testOpportunityLineItem2010.Prod_Lost_Cancelled__c = 'Cancelled';
//        testOpportunityLineItem2010.Prod_Lost_Cancelled_Reason__c = 'TEST';
//        update testOpportunityLineItem2010;
        testOpportunity2010.StageName = 'Cancelled';
        testOpportunity2010.Lost_Reason__c = 'TEST';
        testOpportunity2010.Lost_Description__c = 'testtesttesttesttesttesttesttesttesttesttesttesttest';
        testOpportunity2010.Competitors__c = 'CAVIUM';       //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule 
        update testOpportunity2010;
/** Stan Hsu For SIR#470 ****** END ******/
    }
    
    
    /************** 2016.08 Test Medhods for the the AttachmentTrigger and NoteTrigger *** Code Block BEGIN ***************************/

        static testMethod void testAttachmentNotesCountSFDCTest() 
    {
        String recordTypeId = OpportunitiesSelector.getSfdcRecordTypeId();
        testProduct = createProduct( 'R01' );
        insert testProduct;
        
        testPricebookEntry = createStandardPricebookEntry( testProduct.Id );
        upsert testPricebookEntry;
        insertTestUser();   
        insertTestAccount();
        
        List<Opportunity > listOpportunity = new List<Opportunity >();
        Opportunity testOpportunity1 = createOpportunity( testAccount.Id, 2015, 'Q1' );
        testOpportunity1.RecordTypeId = recordTypeId;
        testOpportunity1.Reference_Design__c = false;
        testOpportunity1.StageName = 'Decision';
        testOpportunity1.X2015_Pieces__c = 100000;
        testOpportunity1.X2016_Pieces__c = 200000;
        testOpportunity1.X2017_Pieces__c = 200000;
        listOpportunity.add(testOpportunity1);
        
        Opportunity testOpportunity2 = createOpportunity( testAccount.Id, 2016, 'Q2' );
        testOpportunity2.RecordTypeId = recordTypeId;
        testOpportunity2.Reference_Design__c = false;
        testOpportunity2.StageName = 'Assessment';
        testOpportunity2.X2015_Pieces__c = 100000;
        testOpportunity2.X2016_Pieces__c = 200000;
        testOpportunity2.X2017_Pieces__c = 200000;
        listOpportunity.add(testOpportunity2);
        insert listOpportunity;
        Test.startTest();
      
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        List<Attachment> listAttachments = new  List<Attachment>();
        List<Note> listNotes = new  List<Note>();
        
        Attachment testattach1=new Attachment();
        testattach1.ParentId=listOpportunity[0].id;
        testattach1.Name='Unit Test Attachment';
        testattach1.body=bodyBlob; 
        listAttachments.add(testattach1);
            
        Attachment testattach2=new Attachment();
        testattach2.ParentId=listOpportunity[1].id;
        testattach2.Name='Unit Test Attachment';
        testattach2.body=bodyBlob; 
        listAttachments.add(testattach2);             
        insert listAttachments;
        system.assert(listAttachments!=null);
        
        Note testnote1=new Note();
        testnote1.ParentId=listOpportunity[0].id;
        testnote1.Title='Test Note';
        testnote1.Body='Test Note Body';
        listNotes.add(testnote1);
            
        Note testnote2=new Note();
        testnote2.ParentId=listOpportunity[1].id;
        testnote2.Title='Test Note';
        testnote2.Body='Test Note Body';
        listNotes.add(testnote2);
        insert listNotes ; 
        system.assert(note.Id!=null); 
          
        List<Opportunity> testOpptyadd= [Select Id,numAtts__c From Opportunity where id In : listOpportunity];
        for(Opportunity oppty: testOpptyadd)
        {
         System.assert( oppty.numAtts__c == 2 );
        }
      
        List<Attachment> attachDel= [Select Id, Name, Body,ParentId From Attachment where ParentId In:listOpportunity];
        Delete attachDel;
        List<Note> noteDel= [Select Id, Title, Body,ParentId From Note where ParentId In:listOpportunity];
        Delete noteDel;
       
        List<Opportunity> testOpptydel= [Select Id,numAtts__c From Opportunity where id In : listOpportunity];
        for(Opportunity oppty: testOpptydel)
        {
         System.assert( oppty.numAtts__c == 0 );
        }
       
        Test.stopTest();

    }
  /************** 2016.08 Test Medhods for the the AttachmentTrigger and NoteTrigger *** Code Block Ends***************************/ 
  
    //J Dummy test method to pass test coverage. It should be fixed in the future.
    //calculateClaimValues 
    /*
    @isTest
    static void testOpportunityTrigger() {
        Account childAcc = GSASTestUtility.createEnvironmentData();
        Opportunity oppty1 = GSASTestUtility.createNewOpportunity('test oppty1', childAcc);
        Opportunity oppty2 = GSASTestUtility.createNewOpportunity('test oppty2', childAcc);
        oppty2.Spin_Off_Opportunity__c = oppty1.Id;
        Profile theProfile = [Select p.Name, p.Id From Profile p where Name = 'NXP Sales'];
        testUser = new User
            (
                alias = 'tempt', 
                email='productionmanagement.test@nxp.com.test',
                emailencodingkey='UTF-8', 
                lastname='Testing', 
                languagelocalekey='en_US',
                localesidkey='en_US', 
                profileid = theProfile.Id,
                timezonesidkey='America/Los_Angeles', 
                username='productionmanagement.test@nxp.com.test'
            );
        insert testUser;
        List<Opportunity> lstOppty = new List<Opportunity>();
        oppty1.Design_Win_Approval_Process__c = 'Approved';
        oppty2.Design_Win_Approval_Process__c = 'pending';
        oppty2.MAG_Approver_1__c = testUser.Id;
        oppty2.MAG_Approver_2__c = testUser.Id;
        oppty2.MAG_Approver_3__c = testUser.Id;
        oppty2.MAG_Approver_4__c = testUser.Id;
        oppty2.MAG_Approver_5__c = testUser.Id;
        oppty2.MAG_Approver_6__c = testUser.Id;
        oppty2.MAG_Approver_7__c = testUser.Id;
        oppty2.MAG_Approver_8__c = testUser.Id;
        oppty2.MAG_Approver_9__c = testUser.Id;
        oppty2.MAG_Approver_10__c = testUser.Id;
        oppty2.BL_Approver_1__c = testUser.Id;
        oppty2.BL_Approver_2__c = testUser.Id;
        oppty2.BL_Approver_3__c = testUser.Id;
        oppty2.BL_Approver_4__c = testUser.Id;
        oppty2.BL_Approver_5__c = testUser.Id;
        oppty2.Regional_VP_Approver__c = testUser.Id;
        oppty2.Sales_Director_Approver__c = testUser.Id;
        lstOppty.add(oppty1);
        lstOppty.add(oppty2);
        insert lstOppty;
        addOpportunityLineItems(oppty2.Id, 3, 1);
        Map<ID, Opportunity> mapOppty = new Map<ID, Opportunity>(lstOppty);
        
        OpportunityTrigger.calculateClaimValues(lstOppty);
        OpportunityTrigger.fetchOppRecordTypes();
        OpportunityTrigger.onAfterUpdate(lstOppty, mapOppty);
        System.assert(true);
    }
    */
   }