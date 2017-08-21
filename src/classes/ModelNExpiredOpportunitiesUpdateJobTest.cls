/* Last ModifiedBy : Baji
   Last ModifiedDate : 02 Jun 2017
   Description : Updated to remove the test data related to Opportunity Approval Setting.
*/ 

@istest
private class ModelNExpiredOpportunitiesUpdateJobTest {
    @testsetup
    public static void setupTestData(){
        //insert account
        Account acc = new Account(Name='Test Account');    
        Database.SaveResult asr =  Database.insert(acc);
        
        // Insert products
        List<Product2> prods = new List<Product2>();
        for (Integer i = 0; i < 4; i++) {
            prods.add(new Product2(Name = 'Test Product' + i, IsActive = true));
        }            
        List<Database.SaveResult> prodsr = Database.insert(prods);

        //Model N Record type
        RecordType rt = [SELECT Id,Name from RecordType where Name='Model N Oppty'];
        
        //insert opportunity
        List<Opportunity> opptys = new List<Opportunity>();
        for(Integer i = 0; i < 4; i++) {
            Opportunity oppty = new Opportunity(Name = 'Model N Oppty '+i,StageName='Discovery',AccountId=asr.getId(),RecordTypeId=rt.id,Expiration_Date__c=System.today().addDays(-2),CloseDate=System.today().addDays(100), Production_Date__c = Date.newInstance(2016, 04, 30), One_Year_Pieces__c = 1000);  
            opptys.add(oppty);
        }
        
        insert opptys;
        
        List<PricebookEntry> pbes = [select Id from PricebookEntry where Product2Id in :prods and CurrencyIsoCode = 'USD'];
        
        // Insert opportunity products
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        
        for (Opportunity o : opptys) {
        	createOpportunitySchedules(o.Id, 1000);
        	
	        for (PricebookEntry pbe : pbes) {
	            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pbe.Id);
	            oli.UnitPrice = 1;
	            oli.Component_Multiplier__c = 1;
	            olis.add(oli);
	        }
        }
        
        insert olis;
    }
    
    static void createOpportunitySchedules(ID opptyID, Double totalQty) {
    	List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
    	Double qty = totalQty / 4;
    	
    	OpportunitySchedule__c opptySched;
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 01, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 04, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 07, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);
		opptySched = new OpportunitySchedule__c(Opportunity__c = opptyID, Sched_Date__c = Date.newInstance(2016, 10, 01), Oppty_Sched_Qty__c = qty, Frozen_Oppty_Sched_Qty__c = qty);
		opptyScheds.add(opptySched);	
    	
    	insert opptyScheds;
    }
    
    @istest
    public static void testBatchJob(){
        Test.startTest();
        Database.executeBatch(new ModelNExpiredOpportunitiesUpdateJob());
        Test.stopTest();
        List<Opportunity> opptys = [select id,name,stagename,Expiration_Date__c  from opportunity where recordtype.name='Model N Oppty' and isclosed=false and stagename<>'AOP' and Expiration_Date__c < TODAY order by Expiration_Date__c desc];
        System.debug('opptys '+opptys);
        for(Opportunity oppty : opptys){
            System.debug(oppty.Name+' opptys stage '+oppty.StageName+' date '+oppty.Expiration_Date__c);
        }
        System.assert(opptys== null || opptys.size()==0);
    }    
}