/*
@Created By :       Nisha Agrawal
@Created Date:      22 Jan 2013
@Description:       Test Class for the trigger CapturingOppProducts on Opportunity


@Modified By :      Nisha Agrawal
@Modified Date:     26 Feb 2013
@Description:       Modified a s per change in original trigger which will now insert Fulfillment Parts records Per Year Per Line Item. 
*/ 

@isTest//(SeeAllData=true)
private class CapturingOppProductsTest {
    /********************************************************
        CASE - 1 Opportunitiy having 20 Line Items - 16 Quarters
    *********************************************************/
  /*  static testMethod void CapturingOppProductsTest1() {
        //prepare test data     
        //insert product
        List<Product2> lstProducts = new List<Product2>();
        integer numOfLineItems = 20;
        integer i;
        
        //insert product
        for(i=0; i < numOfLineItems; i++)
            lstProducts.add(new Product2(Name = 'unit_test_product' + i, MAG__c = 't' + (i/5), BU__c = 't' + i, BL__c = 't' + i, IsActive = true)); 
        insert lstProducts; 
        
        //assert the results
        for(Product2 obj : lstProducts) system.assert(obj.Id != null);
        
        Pricebook2 pbook = [Select Id, Name From Pricebook2  Where IsActive = true and IsStandard = true limit 1];
        List<PricebookEntry> lstPBEntries = [Select Id From PricebookEntry  Where IsActive = true and CurrencyISOCode='USD' and Pricebook2Id = : pbook.Id and Product2Id in : lstProducts];
        
        //insert opportunity
        RecordType rType = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Parent Account'];
        Account acc = [Select Id From Account Where Segment_Approval__c = true And RecordTypeId =: rType.Id LIMIT 1];
        Opportunity objOpp = New Opportunity(Name='ut_test_opp', StageName = 'Assessment', Industry_Segment__c = 'Healthcare', Sub_Segment__c = 'Clinical Health',
            Production_Date__c = date.newInstance(2011, 1, 21),  CloseDate = date.newInstance(2011, 1, 20), Design_Win_Submission_Date__c = date.newInstance(2011, 1, 10),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 1, 17) , X2010_Pieces__c = 0, X2011_Pieces__c =10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 25, Account = acc);
        insert objOpp;
        system.assert(objOpp.Id != null);
        
        //insert line items
        List<OpportunityLineItem> lstLineItems = new List<OpportunityLineItem>();
        for(i = 0; i < numOfLineItems; i++ )
        {
            lstLineItems.add(new OpportunityLineItem(OpportunityId = objOpp.Id, PriceBookEntryId = lstPBEntries[i].Id, UnitPrice = 500.1234 * (i + 1), Quantity = 10 * (i + 1)));
                
        }
        insert lstLineItems;        
        
        //start the test
        Test.startTest();
        
        //update the opportunity
        objOpp.Design_Win_Approval_Process__c = 'Approved';     
        update objOpp;
        
        //stop the test
        Test.stopTest();
    }
    
    
    /************************************************************
        CASE - 1 Opportunitiy having 20 Line Items - 12 Quarters
    *************************************************************/
    
 /*   static testMethod void CapturingOppProductsTest2() 
    {
        //prepare test data     
        //insert product
        List<Product2> lstProducts = new List<Product2>();
        integer numOfLineItems = 20;
        integer i;
        
        //insert product
        for(i=0; i < numOfLineItems; i++)
        {
            lstProducts.add(new Product2(Name = 'unit_test_product' + i, MAG__c = 't' + (i/5), BU__c = 't' + i, BL__c = 't' + i, IsActive = true));
        }    
        insert lstProducts; 
        
        //assert the results
        for(Product2 obj : lstProducts)
        {
          system.assert(obj.Id != null);
        }
        
        Pricebook2 pbook = [Select Id, Name From Pricebook2  Where IsActive = true and IsStandard = true limit 1];
        List<PricebookEntry> lstPBEntries = [Select Id From PricebookEntry  Where IsActive = true and CurrencyISOCode='USD' and Pricebook2Id = : pbook.Id and Product2Id in : lstProducts];
        
        //insert opportunity
        RecordType rType = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Parent Account'];
        Account acc = [Select Id From Account Where Segment_Approval__c = true And RecordTypeId =: rType.Id LIMIT 1];
        Opportunity objOpp = New Opportunity(Name='ut_test_opp', StageName = 'Assessment', Industry_Segment__c = 'Computing' , Sub_Segment__c = 'Ultrabook',
            Production_Date__c = date.newInstance(2011, 1, 21),  CloseDate = date.newInstance(2011, 1, 18), Design_Win_Submission_Date__c = date.newInstance(2011, 1, 15),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 1, 19) , X2010_Pieces__c = 0, X2011_Pieces__c =10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 0, Account = acc);
        insert objOpp;
        system.assert(objOpp.Id != null);
        
        //insert line items
        List<OpportunityLineItem> lstLineItems = new List<OpportunityLineItem>();
        for(i = 0; i < numOfLineItems; i++ )
        {
            lstLineItems.add(new OpportunityLineItem(OpportunityId = objOpp.Id, PriceBookEntryId = lstPBEntries[i].Id, UnitPrice = 500.1234 * (i + 1), Quantity = 10 * (i + 1)));
                
        }
        insert lstLineItems;        
        
        //start the test
        Test.startTest();
        
        //update the opportunity
        objOpp.Design_Win_Approval_Process__c = 'Approved';     
        update objOpp;
        
        //stop the test
        Test.stopTest();
    }
    
    /********************************************************
        CASE - 8 Opportunities each having 10 Line Items 
    *********************************************************/
    
  /*  static testMethod void CapturingOppProductsTest3() 
    {
        //prepare test data
        
        //insert product
        List<Product2> lstProducts = new List<Product2>();
        integer numOfLineItems = 10;
        integer i;
        
        //insert product
        for(i=0; i < numOfLineItems; i++)
        {
          lstProducts.add(new Product2(Name = 'unit_test_product' + i, MAG__c = 't' + (i/5), BU__c = 't' + i, BL__c = 't' + i, IsActive = true));
        }        
        insert lstProducts; 
        
        //assert the results
        for(Product2 obj : lstProducts)
        {
          system.assert(obj.Id != null);
        }
        
        Pricebook2 pbook = [Select Id, Name From Pricebook2  Where IsActive = true and IsStandard = true limit 1];
        List<PricebookEntry> lstPBEntries = [Select Id From PricebookEntry  Where IsActive = true and CurrencyISOCode='USD' and Pricebook2Id = : pbook.Id and Product2Id in : lstProducts];
        
        //insert opportunities
        RecordType rType = [Select Id From RecordType Where SObjectType = 'Account' And Name = 'Parent Account'];
        Account acc = [Select Id From Account Where Segment_Approval__c = true And RecordTypeId =: rType.Id LIMIT 1];
        List<Opportunity> lstOpps = new List<Opportunity>();
            
        lstOpps.add(New Opportunity(Name='ut_test_opp_1' , StageName = 'Assessment', Industry_Segment__c = 'Computing' , Sub_Segment__c = 'Ultrabook' ,
            Production_Date__c = date.newInstance(2011, 1, 21),  CloseDate = date.newInstance(2011, 1, 18), Design_Win_Submission_Date__c = date.newInstance(2011, 1, 15),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 1, 19) , X2010_Pieces__c = 0, X2011_Pieces__c = 10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 0, Account = acc));
        lstOpps.add(New Opportunity(Name='ut_test_opp_2' , StageName = 'Assessment', Industry_Segment__c = 'Computing' , Sub_Segment__c = 'Ultrabook' ,
            Production_Date__c = date.newInstance(2011, 5, 21),  CloseDate = date.newInstance(2011, 5, 18), Design_Win_Submission_Date__c = date.newInstance(2011, 5, 15),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 5, 19) , X2010_Pieces__c = 0, X2011_Pieces__c = 10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 25, Account = acc));
        lstOpps.add(New Opportunity(Name='ut_test_opp_3' , StageName = 'Assessment', Industry_Segment__c = 'Computing' , Sub_Segment__c = 'Ultrabook' ,
            Production_Date__c = date.newInstance(2011, 8, 21),  CloseDate = date.newInstance(2011, 8, 18), Design_Win_Submission_Date__c = date.newInstance(2011, 8, 15),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 8, 19) , X2010_Pieces__c = 0, X2011_Pieces__c = 10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 25, Account = acc));
        lstOpps.add(New Opportunity(Name='ut_test_opp_4' , StageName = 'Assessment', Industry_Segment__c = 'Computing' , Sub_Segment__c = 'Ultrabook' ,
            Production_Date__c = date.newInstance(2011, 11, 21),  CloseDate = date.newInstance(2011, 11, 18), Design_Win_Submission_Date__c = date.newInstance(2011, 11, 15),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 11, 19) , X2010_Pieces__c = 0, X2011_Pieces__c = 10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 25, Account = acc));
        
        lstOpps.add(New Opportunity(Name='ut_test_opp_5', StageName = 'Assessment', Industry_Segment__c = 'Healthcare', Sub_Segment__c = 'Clinical Health' ,  
            Production_Date__c = date.newInstance(2011, 1, 21),  CloseDate = date.newInstance(2011, 1, 20), Design_Win_Submission_Date__c = date.newInstance(2011, 1, 10),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 1, 17) , X2010_Pieces__c = 0, X2011_Pieces__c =10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 25 , X2015_Pieces__c = 0, Account = acc));
        lstOpps.add(New Opportunity(Name='ut_test_opp_6', StageName = 'Assessment', Industry_Segment__c = 'Healthcare', Sub_Segment__c = 'Clinical Health' ,  
            Production_Date__c = date.newInstance(2011, 5, 21),  CloseDate = date.newInstance(2011, 5, 20), Design_Win_Submission_Date__c = date.newInstance(2011, 5, 10),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 5, 17) , X2010_Pieces__c = 0, X2011_Pieces__c =10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 25, X2015_Pieces__c = 30, Account = acc));
        lstOpps.add(New Opportunity(Name='ut_test_opp_7', StageName = 'Assessment', Industry_Segment__c = 'Healthcare', Sub_Segment__c = 'Clinical Health' ,  
            Production_Date__c = date.newInstance(2011, 8, 21),  CloseDate = date.newInstance(2011, 8, 20), Design_Win_Submission_Date__c = date.newInstance(2011, 8, 10),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 8, 17) , X2010_Pieces__c = 0, X2011_Pieces__c =10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 25, X2015_Pieces__c = 30, Account = acc));
        lstOpps.add(New Opportunity(Name='ut_test_opp_8', StageName = 'Assessment', Industry_Segment__c = 'Healthcare', Sub_Segment__c = 'Clinical Health' ,  
            Production_Date__c = date.newInstance(2011, 11, 21),  CloseDate = date.newInstance(2011, 11, 20), Design_Win_Submission_Date__c = date.newInstance(2011, 11, 10),  
            Design_Win_Approval_Process__c = 'Open', Design_Win_Approval_Date__c = date.newInstance(2011, 11, 17) , X2010_Pieces__c = 0, X2011_Pieces__c =10, 
            X2012_Pieces__c = 15, X2013_Pieces__c = 20, X2014_Pieces__c = 25, X2015_Pieces__c = 30, Account = acc));
        
        insert lstOpps;
        
        for(Opportunity opp : lstOpps) system.assert(opp.Id != null);
        
        //insert line items
        List<OpportunityLineItem> lstLineItems = new List<OpportunityLineItem>();
        for(i = 0; i < numOfLineItems; i++ )
        {
            for(integer j=0; j < lstOpps.size(); j++)
            {
                lstLineItems.add(new OpportunityLineItem(OpportunityId = lstOpps[j].Id, PriceBookEntryId = lstPBEntries[i].Id, UnitPrice = 500.1234 * (i + 1), Quantity = 10 * (i + 1)));   
            }               
        }
        insert lstLineItems;        
        
        //start the test
        Test.startTest();
        
        //update opportunities
        for(Opportunity objOpp : lstOpps)
        {
            objOpp.Design_Win_Approval_Process__c = 'Approved';
        }
        
        update lstOpps;
        
        //stop the test
        Test.stopTest();
    } */
}