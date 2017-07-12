/***************************************************************************************************
@Created By :      Balaji G
@Created Date:     11 July 2016
@Description:      Test class for FunnelTrackerSnapshotPopulateBatch
****************************************************************************************************/

/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@isTest
public class FunnelTrackerSnapshotPopulateBatchTest
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
                          
        public static testMethod void FunnelTrackerSnapshotPopulateBatchTest() 
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
                Account ParentStarTest = new Account(Name='Test Account',RecordTypeId=parentAccount.Id);
                Account ChildStarTest = new Account(Name='Test Account',RecordTypeId=childAccount.Id,ParentId=ParentStarTest.Id);
                insert ParentStarTest;
                insert ChildStarTest;
                List<Opportunity> listDWs = new List<Opportunity>();
                Integer numOpptys=6;
                date d2=Date.newInstance(2010, 1, 1);
                date d4=Date.newInstance(2010, 1, 1);
                        Opportunity o = new Opportunity(Name='TestOppty',AccountId=ChildStarTest.Id,CloseDate=d2,StageName='Initial Engagement',Production_Date__c=d4,RecordTypeID=sfdcOptty.Id,X2010_Pieces__c=10,X2011_Pieces__c=11,X2012_Pieces__c=12,X2013_Pieces__c=13,X2014_Pieces__c=14,X2015_Pieces__c=15,X2016_Pieces__c=16,X2017_Pieces__c=17,X2018_Pieces__c=18,X2019_Pieces__c=19,X2020_Pieces__c=20,X2021_Pieces__c=21,X2022_Pieces__c=22,X2023_Pieces__c=23,X2024_Pieces__c=24,X2025_Pieces__c=25,X2026_Pieces__c=26,X2027_Pieces__c=27,X2028_Pieces__c=28,X2029_Pieces__c=29,X2030_Pieces__c=30,Locked_Exchange_Rate__c = 1.00,Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id,CurrencyIsoCode = CCY_CODE_DEFAULT);
                        listDWs.add(o);
                Test.StartTest();
                insert listDWs;
                
                //must create opportunity schedules before creating opportunity products
                List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
                
                List<OpportunityLineItem> listDWsLineItems = new List<OpportunityLineItem>();
                for( Opportunity theOpportunity : listDWs) 
                    {
                        OpportunitySchedule__c opptySched = new OpportunitySchedule__c(Opportunity__c = theOpportunity.ID, Sched_Date__c = Date.newInstance(2017, 01, 01), Oppty_Sched_Qty__c = 250, Frozen_Oppty_Sched_Qty__c = 250);
                        opptyScheds.add(opptySched);
                        OpportunityLineItem oli = new OpportunityLineItem(Opportunityid=theOpportunity.id,PriceBookEntryID=priceBookEntryRecord.id,Quantity=1,UnitPrice=1,Component_Multiplier__c=1);
                        listDWsLineItems.add(oli);
                    }
                insert opptyScheds;
                insert listDWsLineItems ;
                // Insert Custom Setting for top Account  
                Top_Accounts__c top = new Top_Accounts__c();
                top.Name = 'Test Account';
                top.Account_Name__c = 'Test Account';
                insert top;
                FunnelTrackerSnapshotPopulateBatch batchController = new FunnelTrackerSnapshotPopulateBatch();
                Database.BatchableContext bc;
                batchController.start(bc);
                batchController.execute(bc, listDWsLineItems);
                batchController.finish(bc);
    }    
  }