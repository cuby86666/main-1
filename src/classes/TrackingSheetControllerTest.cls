// 12-02-15 by Manoj : Introduced the recordtype changes for Opportunity.
// 31-05-16 by Balaji: SIR974 AND SIR699 changes.
// 31-05-16 by Balaji: 1. Optimized test class to use own test data and remove dependancy on org data. 2. Added code coverage for getBUs() method
/* 
*  Modified by: Balaji G
*  For: Release 2016.9 SIR# 958 
*  Description: Adjusted test data to comply with validation rule - Competitor, Loss/Cancelled Reason and
                Description required for Lost/Cancelled Opportunities

*  Modified by: Balaji G
*  For: Release 2016.10 SIR# 1275 
*  Description: Updated to add test data for fields 'Probability to Win' and 'Help needed'

*  Modified by: Nisha Agrawal 
*  For: Release 2017.06 SFDC-432 
*  Description: Updated to obsolete method call findFieldHistoryFromPriorWeek for performance improvement

*  Modified by: Baji 
*  For: Release 2017.06 SFDC-500 
*  Description: Updated to remove the test data related to Opportunity Approval Setting.
*/

@isTest
public class TrackingSheetControllerTest
   {
        private static final String CCY_CODE_USD = 'USD';
        private static final String CCY_CODE_EUR = 'EUR';
        private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
        private static final Double EXCH_RATE_USD = 1.0;
        private static final Double EXCH_RATE_EUR = 0.9;
        private static final Double EXCH_RATE_DEFAULT = EXCH_RATE_USD; // @default
        private static final String ACCOUNT_CHILDACCOUNT = 'Child_Account';
        private static final String ACCOUNT_ParentACCOUNT = 'Parent_Account';
        private static final String Optty_sfdcOptty = 'SFDC_Oppty';
        public static RecordType sfdcOptty = [Select Id, DeveloperName
                                  From RecordType
                                  Where IsActive=true and
                                   (SobjectType = 'Opportunity' and (DeveloperName =: Optty_sfdcOptty ))
                                  Limit 1];
        public static RecordType childAccount = [Select Id, DeveloperName
                                  From RecordType
                                  Where IsActive=true and
                                   (SobjectType = 'Account' and (DeveloperName =: ACCOUNT_CHILDACCOUNT))
                                  Limit 1];                                  
        public static RecordType parentAccount= [Select Id, DeveloperName
                                  From RecordType
                                  Where IsActive=true and
                                   (SobjectType = 'Account' and (DeveloperName =: ACCOUNT_ParentACCOUNT))
                                  Limit 1];    
                          
        public static testMethod void TrackingSheetTest() 
          {
                List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
                fxrs.add(new FX_Rates__c(Name = CCY_CODE_USD, Currency_Code__c = CCY_CODE_USD, CurrencyIsoCode = CCY_CODE_USD, Exchange_Rate__c = EXCH_RATE_USD));
                fxrs.add(new FX_Rates__c(Name = CCY_CODE_EUR, Currency_Code__c = CCY_CODE_EUR, CurrencyIsoCode = CCY_CODE_EUR, Exchange_Rate__c = EXCH_RATE_EUR));
                insert fxrs;
                Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
                fxRates.put(CCY_CODE_USD, fxrs.get(0));
                fxRates.put(CCY_CODE_EUR, fxrs.get(1));  

                Pricebookentry priceBookEntryRecord =new Pricebookentry();
                Product2 testProduct;
                Id testPriceBookId = Test.getStandardPricebookId();
                product2 listProduct=new product2();
                integer BlVal=11;
                integer MAGValue=33;
                String BUvalue='510';
                listProduct = new Product2(Name = 'testName',IsActive=true, MAG__c='R'+MAGvalue++, Bl__c='BL'+BlVal++,BU__c=BUvalue,CurrencyISOCode = 'USD');                
                insert listProduct;  
                priceBookEntryRecord = [select id from PriceBookentry where Product2Id=:listProduct.id and CurrencyISOCode='USD'];
                Account ParentStarTest = new Account(Name='Star',RecordTypeId=parentAccount.Id);
                insert ParentStarTest;
                Account ChildStarTest = new Account(Name='Star',RecordTypeId=childAccount.Id,ParentId=ParentStarTest.Id);
                insert ChildStarTest;
                List<Opportunity> listAOPs = new List<Opportunity>();
                Integer numAOPOpptys=24;
                date d1=Date.newInstance(2010, 1, 1);
                date d3=Date.newInstance(2010, 1, 1);
                for(Integer i=0;i<numAOPOpptys;i++)
                 {
                    Opportunity o1 = new Opportunity(Name='AOP_TestOppty' + i,AccountId=ChildStarTest.Id,CloseDate=d1,StageName='AOP',Production_Date__c=d3,RecordTypeID=sfdcOptty.Id,AOP_value__c=1000,Locked_Exchange_Rate__c = 1.00,Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT);
                    listAOPs.add(o1);
                    d1=d1.addYears(1);
                    d3=d3.addYears(1);
                 }
                insert listAOPs;
                List<Opportunity> listAOPsToBeUpdated = new List<Opportunity>();
                for( Opportunity theAOP : listAOPs )
                  {
                    theAOP.CloseDate =  theAOP.CloseDate.addYears(1);
                    listAOPsToBeUpdated.add( theAOP );
                  }
                update listAOPsToBeUpdated;
                List<Opportunity> listDWs = new List<Opportunity>();
                Integer numOpptys=4;
                date d2=Date.newInstance(date.today().year() - 1, 1, 1);
                date d4=Date.newInstance(date.today().year() - 1, 1, 1);
                for(Integer i=0;i<numOpptys;i++) 
                    {
                        /*
                        //SIR1275 updates. Balaji G Date: 19-Oct-2016. Added test data for 'Probability to Win' and 'Help needed' fields
                        Opportunity o = new Opportunity(Name='TestOppty' + i,AccountId=ChildStarTest.Id,CloseDate=d2,StageName='Initial Engagement',Help_Needed__c='Test',Next_Steps__c='Test',Production_Date__c=d4,RecordTypeID=sfdcOptty.Id,X2010_Pieces__c=10,X2011_Pieces__c=11,X2012_Pieces__c=12,X2013_Pieces__c=13,X2014_Pieces__c=14,X2015_Pieces__c=15,X2016_Pieces__c=16,X2017_Pieces__c=17,X2018_Pieces__c=18,X2019_Pieces__c=19,X2020_Pieces__c=20,X2021_Pieces__c=21,X2022_Pieces__c=22,X2023_Pieces__c=23,X2024_Pieces__c=24,X2025_Pieces__c=25,X2026_Pieces__c=26,X2027_Pieces__c=27,X2028_Pieces__c=28,X2029_Pieces__c=29,X2030_Pieces__c=30,Locked_Exchange_Rate__c = 1.00,Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT);
                        Opportunity o1 = new Opportunity(Name='TestOppty' + i,AccountId=ChildStarTest.Id,CloseDate=d2,StageName='Commitment',Help_Needed__c='Test',Next_Steps__c='Test',Production_Date__c=d4,RecordTypeID=sfdcOptty.Id,X2010_Pieces__c=10,X2011_Pieces__c=11,X2012_Pieces__c=12,X2013_Pieces__c=13,X2014_Pieces__c=14,X2015_Pieces__c=15,X2016_Pieces__c=16,X2017_Pieces__c=17,X2018_Pieces__c=18,X2019_Pieces__c=19,X2020_Pieces__c=20,X2021_Pieces__c=21,X2022_Pieces__c=22,X2023_Pieces__c=23,X2024_Pieces__c=24,X2025_Pieces__c=25,X2026_Pieces__c=26,X2027_Pieces__c=27,X2028_Pieces__c=28,X2029_Pieces__c=29,X2030_Pieces__c=30,Locked_Exchange_Rate__c = 1.00,Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT);
                        Opportunity o2 = new Opportunity(Name='TestOppty' + i,AccountId=ChildStarTest.Id,CloseDate=d2,StageName='Decision',Help_Needed__c='Test',Next_Steps__c='Test',Production_Date__c=d4,RecordTypeID=sfdcOptty.Id,X2010_Pieces__c=10,X2011_Pieces__c=11,X2012_Pieces__c=12,X2013_Pieces__c=13,X2014_Pieces__c=14,X2015_Pieces__c=15,X2016_Pieces__c=16,X2017_Pieces__c=17,X2018_Pieces__c=18,X2019_Pieces__c=19,X2020_Pieces__c=20,X2021_Pieces__c=21,X2022_Pieces__c=22,X2023_Pieces__c=23,X2024_Pieces__c=24,X2025_Pieces__c=25,X2026_Pieces__c=26,X2027_Pieces__c=27,X2028_Pieces__c=28,X2029_Pieces__c=29,X2030_Pieces__c=30,Locked_Exchange_Rate__c = 1.00,Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT);            
                        Opportunity o3 = new Opportunity(Name='TestOppty' + i,AccountId=ChildStarTest.Id,CloseDate=d2,StageName='Recommendation',Help_Needed__c='Test',Next_Steps__c='Test',Production_Date__c=d4,RecordTypeID=sfdcOptty.Id,X2010_Pieces__c=10,X2011_Pieces__c=11,X2012_Pieces__c=12,X2013_Pieces__c=13,X2014_Pieces__c=14,X2015_Pieces__c=15,X2016_Pieces__c=16,X2017_Pieces__c=17,X2018_Pieces__c=18,X2019_Pieces__c=19,X2020_Pieces__c=20,X2021_Pieces__c=21,X2022_Pieces__c=22,X2023_Pieces__c=23,X2024_Pieces__c=24,X2025_Pieces__c=25,X2026_Pieces__c=26,X2027_Pieces__c=27,X2028_Pieces__c=28,X2029_Pieces__c=29,X2030_Pieces__c=30,Locked_Exchange_Rate__c = 1.00,Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT);            
                        Opportunity o4 = new Opportunity(Name='TestOppty' + i,AccountId=ChildStarTest.Id,CloseDate=d2,StageName='Assessment',Help_Needed__c='Test',Next_Steps__c='Test',Production_Date__c=d4,RecordTypeID=sfdcOptty.Id,X2010_Pieces__c=10,X2011_Pieces__c=11,X2012_Pieces__c=12,X2013_Pieces__c=13,X2014_Pieces__c=14,X2015_Pieces__c=15,X2016_Pieces__c=16,X2017_Pieces__c=17,X2018_Pieces__c=18,X2019_Pieces__c=19,X2020_Pieces__c=20,X2021_Pieces__c=21,X2022_Pieces__c=22,X2023_Pieces__c=23,X2024_Pieces__c=24,X2025_Pieces__c=25,X2026_Pieces__c=26,X2027_Pieces__c=27,X2028_Pieces__c=28,X2029_Pieces__c=29,X2030_Pieces__c=30,Locked_Exchange_Rate__c = 1.00,Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT);            
                        Opportunity o5 = new Opportunity(Name='TestOppty' + i,AccountId=ChildStarTest.Id,CloseDate=d2,StageName='Discovery',Help_Needed__c='Test',Next_Steps__c='Test',Production_Date__c=d4,RecordTypeID=sfdcOptty.Id,X2010_Pieces__c=10,X2011_Pieces__c=11,X2012_Pieces__c=12,X2013_Pieces__c=13,X2014_Pieces__c=14,X2015_Pieces__c=15,X2016_Pieces__c=16,X2017_Pieces__c=17,X2018_Pieces__c=18,X2019_Pieces__c=19,X2020_Pieces__c=20,X2021_Pieces__c=21,X2022_Pieces__c=22,X2023_Pieces__c=23,X2024_Pieces__c=24,X2025_Pieces__c=25,X2026_Pieces__c=26,X2027_Pieces__c=27,X2028_Pieces__c=28,X2029_Pieces__c=29,X2030_Pieces__c=30,Locked_Exchange_Rate__c = 1.00,Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT);            
                        Opportunity o6 = new Opportunity(Name='TestOppty' + i,AccountId=ChildStarTest.Id,CloseDate=d2,StageName='Lost',Help_Needed__c='Test',Next_Steps__c='Test',
                                         Competitors__c = 'CAVIUM',  //2016.9 SIR# 958 added competitor for lost opportunity to comply with validation rule
                                         Lost_Reason__c='Price',Lost_Description__c='testtesttesttesttesttesttesttesttesttesttesttesttest',Production_Date__c=d4,RecordTypeID=sfdcOptty.Id,X2010_Pieces__c=10,X2011_Pieces__c=11,X2012_Pieces__c=12,X2013_Pieces__c=13,X2014_Pieces__c=14,X2015_Pieces__c=15,X2016_Pieces__c=16,X2017_Pieces__c=17,X2018_Pieces__c=18,X2019_Pieces__c=19,X2020_Pieces__c=20,X2021_Pieces__c=21,X2022_Pieces__c=22,X2023_Pieces__c=23,X2024_Pieces__c=24,X2025_Pieces__c=25,X2026_Pieces__c=26,X2027_Pieces__c=27,X2028_Pieces__c=28,X2029_Pieces__c=29,X2030_Pieces__c=30,Locked_Exchange_Rate__c = 1.00,Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT);            
                        */
                        
                        Opportunity o = new Opportunity(
                            Name='TestOppty' + i,
                            AccountId=ChildStarTest.Id,
                            CloseDate = d2,
                            Production_Date__c = d4,
                            StageName ='Initial Engagement',
                            Help_Needed__c ='Test',
                            Next_Steps__c ='Test',
                            RecordTypeID=sfdcOptty.Id,
                            Locked_Exchange_Rate__c = 1.00,
                            Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,
                            CurrencyIsoCode = CCY_CODE_DEFAULT,
                            Bypass_Validation_Sched_Start_Date__c = true
                        );
                        
                        Opportunity o1 = new Opportunity(
                            Name='TestOppty' + i,
                            AccountId=ChildStarTest.Id,
                            CloseDate = d2,
                            Production_Date__c = d4,
                            StageName ='Discovery',
                            Help_Needed__c ='Test',
                            Next_Steps__c ='Test',
                            RecordTypeID=sfdcOptty.Id,
                            Locked_Exchange_Rate__c = 1.00,
                            Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,
                            CurrencyIsoCode = CCY_CODE_DEFAULT,
                            Bypass_Validation_Sched_Start_Date__c = true
                        );
                        
                        Opportunity o2 = new Opportunity(
                            Name='TestOppty' + i,
                            AccountId=ChildStarTest.Id,
                            CloseDate = d2,
                            Production_Date__c = d4,
                            StageName ='Decision',
                            Help_Needed__c ='Test',
                            Next_Steps__c ='Test',
                            RecordTypeID=sfdcOptty.Id,
                            Locked_Exchange_Rate__c = 1.00,
                            Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,
                            CurrencyIsoCode = CCY_CODE_DEFAULT,
                            Bypass_Validation_Sched_Start_Date__c = true
                        );
                        
                        Opportunity o3 = new Opportunity(
                            Name='TestOppty' + i,
                            AccountId=ChildStarTest.Id,
                            CloseDate = d2,
                            Production_Date__c = d4,
                            StageName ='Commitment',
                            Help_Needed__c ='Test',
                            Next_Steps__c ='Test',
                            RecordTypeID=sfdcOptty.Id,
                            Locked_Exchange_Rate__c = 1.00,
                            Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,
                            CurrencyIsoCode = CCY_CODE_DEFAULT,
                            Bypass_Validation_Sched_Start_Date__c = true
                        );
                        
                        Opportunity o4 = new Opportunity(
                            Name='TestOppty' + i,
                            AccountId=ChildStarTest.Id,
                            CloseDate = d2,
                            Production_Date__c = d4,
                            StageName ='Lost',
                            Help_Needed__c ='Test',
                            Next_Steps__c ='Test',
                            RecordTypeID=sfdcOptty.Id,
                            Locked_Exchange_Rate__c = 1.00,
                            Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,
                            CurrencyIsoCode = CCY_CODE_DEFAULT,
                            Bypass_Validation_Sched_Start_Date__c = true
                        );
                        
                        listDWs.add(o);
                        listDWs.add(o1);
                        listDWs.add(o2);
                        listDWs.add(o3);                                              
                        listDWs.add(o4);
                        //listDWs.add(o5);
                        //listDWs.add(o6);               
                                 
                        d2=d2.adddays(185);
                        d4=d4.adddays(200);
                    }
                insert listDWs;
                
                // Create Opportunity Schedules
                createOpportunitySchedules(listDWs);
              
                Test.StartTest();

                
                List<OpportunityLineItem> listDWsLineItems = new List<OpportunityLineItem>();
                for( Opportunity theOpportunity : listDWs) 
                    {
                        OpportunityLineItem oli = new OpportunityLineItem(Opportunityid=theOpportunity.id,PriceBookEntryID=priceBookEntryRecord.id,Quantity=1,UnitPrice=1,Component_Multiplier__c=1);
                        listDWsLineItems.add(oli);
                    }
                insert listDWsLineItems ;
                List<Opportunity> listDWsToBeUpdatedTo= new List<Opportunity>();
                for( Opportunity theDW : listDWs)
                    {
                        Opportunity newUpdatedDWP = new Opportunity();
                        theDW.CloseDate = theDW.CloseDate.addYears(1); 
                        listDWsToBeUpdatedTo.add(theDW);
                    }
                Database.update(listDWsToBeUpdatedTo);
                ApexPages.StandardController sc = new ApexPages.standardController(ParentStarTest);
                TrackingSheetController tsc = new TrackingSheetController(sc);
                tsc.landingPageRedirect();
                tsc.theOwner = 'Brian Failing';
                tsc.theMAG = 'R33';
                tsc.theBU = '510';
                tsc.filterButton();
                Test.setCurrentPageReference(new PageReference('TrackingSheet'));
                System.currentPageReference().getParameters().put('id', ParentStarTest.id);
                TrackingSheetController.getOwners();
                TrackingSheetController.getMAGs();
                TrackingSheetController.getBUs();
                //TrackingSheetController.findFieldHistoryFromPriorWeek(listDWs[0].id);
                Test.StopTest();
        }

        static void createOpportunitySchedules(List<Opportunity> opptys) {
            List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
            List<Double> yearQtys = new List<Double>{2000, 3000, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200};
            Integer prodQtr;
            OpportunitySchedule__c opptySched;
            
            for (Opportunity oppty : opptys) {
                prodQtr = ((oppty.Production_Date__c.month() - 1) / 3) + 1;
                
                if (prodQtr == 1) {
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
                    opptyScheds.add(opptySched);
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 04, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
                    opptyScheds.add(opptySched);
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 07, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
                    opptyScheds.add(opptySched);
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
                    opptyScheds.add(opptySched);    
                } else if (prodQtr == 2) {
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 04, 01), Oppty_Sched_Qty__c = 200, Frozen_Oppty_Sched_Qty__c = 200);
                    opptyScheds.add(opptySched);
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 07, 01), Oppty_Sched_Qty__c = 400, Frozen_Oppty_Sched_Qty__c = 400);
                    opptyScheds.add(opptySched);
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = 400, Frozen_Oppty_Sched_Qty__c = 400);
                    opptyScheds.add(opptySched);
                } else if (prodQtr == 3) {
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 07, 01), Oppty_Sched_Qty__c = 500, Frozen_Oppty_Sched_Qty__c = 500);
                    opptyScheds.add(opptySched);
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = 500, Frozen_Oppty_Sched_Qty__c = 500);
                    opptyScheds.add(opptySched);
                } else if (prodQtr == 4) {
                    opptySched = new OpportunitySchedule__c(Opportunity__c = oppty.ID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = 1000, Frozen_Oppty_Sched_Qty__c = 1000);
                    opptyScheds.add(opptySched);
                }
                
                for (Integer i = 0; i < yearQtys.size(); i++) {
                    Double quarterQty = yearQtys[i] / 4;
                    Integer year = 2017 + i;
                    
                    for (Integer j = 0; j < 4; j++) {
                        Integer month = 1 + (3 * j);
                        Date schedDate = Date.newInstance(year, month, 1);
                        opptySched = new OpportunitySchedule__c();
                        opptySched.Opportunity__c = oppty.ID;
                        opptySched.Sched_Date__c = schedDate;
                        opptySched.Oppty_Sched_Qty__c = quarterQty;
                        opptySched.Frozen_Oppty_Sched_Qty__c = quarterQty;
                        opptyScheds.add(opptySched);    
                    }   
                }
            }
            
            insert opptyScheds;
        }
    }