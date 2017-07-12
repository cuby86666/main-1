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