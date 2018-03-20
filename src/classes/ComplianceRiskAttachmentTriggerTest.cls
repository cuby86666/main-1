@isTest
public class ComplianceRiskAttachmentTriggerTest {
  private static final String TEST_USER_PROFILE = 'Standard User';
  private static final String TEST_USER = 't_user_1';
  private static final String CCY_CODE_USD = 'USD';
  private static final String CCY_CODE_DEFAULT = CCY_CODE_USD; // @default
  private static final Double EXCH_RATE_USD = 2.0;
  private static final String CCY_CODE_EUR = 'EUR';
  private static final Double EXCH_RATE_EUR = 0.9;
  private static final String PARENT_ACCOUNT_STAR = 'STAR';
  private static final String PARENT_ACCOUNT_SAMSUNG = 'Samsung';
  private static final String CBG_AUTOMOTIVE = 'Automotive';
  private static final Date PRODUCTION_DATE = Date.newInstance(2016, 04, 30);

  static User createUser(String alias, String lastName, ID profileID, Boolean signedARIA) {
      User user = newUser(alias, lastName, profileID, signedARIA); 
      insert user;
        
        return user;  
    }  
  static User newUser(String alias, String lastName, ID profileID, Boolean signedARIA) {
      String email = CommonUtils.generateGUID() + '@nxp.com.test123';
      
      User user = new User(EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
    user.Alias = alias;
    user.LastName = lastName;
    user.ProfileId = profileID;
    user.Email = email;
    user.UserName = email;
    user.Signed_ARIA__c = signedARIA;
            
        return user;  
    } 
    
  static Account createAccount(String name, ID recordTypeID, ID parentID, String cbg) {
      Account account = new Account(Region__c = 'EMEA');
      account.Name = name;
      account.RecordTypeId = recordTypeID;
      account.ParentId = parentID;
      account.CMD_Industry_Segment__c = cbg;
      insert account;
      
      return account;
    }
  
   
   static testmethod void captureFileDetailsTest(){
   
   Profile p = [select Id from Profile where Name = :TEST_USER_PROFILE];
      
      // insert a test user
      User u = createUser(TEST_USER, TEST_USER, p.Id, false);
                
        // insert FX Rates
        // There is a workflow which sets Opportunity.Locked_Exchange_Rate__c to 
        // Opportunity.Currency__r.Exchange_Rate__c, which refers to FX_Rates__c.Exchange_Rate__c
        List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_USD, Currency_Code__c = CCY_CODE_USD, CurrencyIsoCode = CCY_CODE_USD, Exchange_Rate__c = EXCH_RATE_USD));
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_EUR, Currency_Code__c = CCY_CODE_EUR, CurrencyIsoCode = CCY_CODE_EUR, Exchange_Rate__c = EXCH_RATE_EUR));
        insert fxrs;
        
        Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
        fxRates.put(CCY_CODE_USD, fxrs.get(0));
        fxRates.put(CCY_CODE_EUR, fxrs.get(1));
        
        // Insert accounts
        createAccount(PARENT_ACCOUNT_STAR, AccountsSelector.getParentRecordTypeID(), null, null);
        createAccount(PARENT_ACCOUNT_SAMSUNG, AccountsSelector.getParentRecordTypeID(), null, null);
        Account parentGeneral = createAccount('Parent Account - General', AccountsSelector.getParentRecordTypeID(), null, null);
        Account a = createAccount('Test Account', AccountsSelector.getChildRecordTypeID(), parentGeneral.Id, CBG_AUTOMOTIVE);
        
        list<opportunity> lstOpp = new list<opportunity>(); 
        // Insert an opportunity
        Opportunity o1 = new Opportunity(Name = 'Test Oppty1', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o1.Production_Date__c = PRODUCTION_DATE;
        o1.CloseDate = PRODUCTION_DATE - 60;
        o1.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o1.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o1);
        
        Opportunity o2 = new Opportunity(Name = 'Test Oppty2', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o2.Production_Date__c = PRODUCTION_DATE;
        o2.CloseDate = PRODUCTION_DATE - 60;
        o2.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o2.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o2);
        
        Opportunity o3 = new Opportunity(Name = 'Test Oppty3', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o3.Production_Date__c = PRODUCTION_DATE;
        o3.CloseDate = PRODUCTION_DATE - 60;
        o3.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o3.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o3);
        
        Opportunity o4 = new Opportunity(Name = 'Test Oppty4', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o4.Production_Date__c = PRODUCTION_DATE;
        o4.CloseDate = PRODUCTION_DATE - 60;
        o4.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o4.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o4);
        
        Opportunity o5 = new Opportunity(Name = 'Test Oppty5', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o5.Production_Date__c = PRODUCTION_DATE;
        o5.CloseDate = PRODUCTION_DATE - 60;
        o5.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o5.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o5);
        
        Opportunity o6 = new Opportunity(Name = 'Test Oppty6', OwnerId = u.Id, AccountId = a.Id, StageName = 'Commitment');
        o6.Production_Date__c = PRODUCTION_DATE;
        o6.CloseDate = PRODUCTION_DATE - 60;
        o6.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o6.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o6);
        
     Test.startTest();   
        insert lstOpp;
        
        System.debug('// ========== after insert oppty');  
        
     // Insert risk assessment    
        list<Compliance_Risk__c> liriskAsmt = new list<Compliance_Risk__c>();
        
        Compliance_Risk__c riskAsmt1 = new Compliance_Risk__c(Opportunity__c = o1.id);
        liriskAsmt.add(riskAsmt1);
        Compliance_Risk__c riskAsmt2 = new Compliance_Risk__c(Opportunity__c = o2.id);
        liriskAsmt.add(riskAsmt2);
        Compliance_Risk__c riskAsmt3 = new Compliance_Risk__c(Opportunity__c = o3.id);
        liriskAsmt.add(riskAsmt3);
        Compliance_Risk__c riskAsmt4 = new Compliance_Risk__c(Opportunity__c = o4.id);
        liriskAsmt.add(riskAsmt4);
        Compliance_Risk__c riskAsmt5 = new Compliance_Risk__c(Opportunity__c = o5.id);
        liriskAsmt.add(riskAsmt5);
        Compliance_Risk__c riskAsmt6 = new Compliance_Risk__c(Opportunity__c = o6.id);
        liriskAsmt.add(riskAsmt6);
        
        insert liriskAsmt;
      
   

     list<Attachment> lstAtchmt = new list<Attachment>();
            Attachment attach1=new Attachment();  
            attach1.Name='Unit Test Attachment CR001';
            Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body1');
            attach1.body=bodyBlob1;
            attach1.parentId=riskAsmt1.id;
            lstAtchmt.add(attach1);
            
            Attachment attach2=new Attachment();  
            attach2.Name='Unit Test Attachment CR002';
            Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body2');
            attach2.body=bodyBlob2;
            attach2.parentId=riskAsmt2.id;
            lstAtchmt.add(attach2);
            
            Attachment attach3=new Attachment();  
            attach3.Name='Unit Test Attachment CR003';
            Blob bodyBlob3=Blob.valueOf('Unit Test Attachment Body3');
            attach3.body=bodyBlob3;
            attach3.parentId=riskAsmt3.id;
            lstAtchmt.add(attach3);
            
            Attachment attach4=new Attachment();  
            attach4.Name='Unit Test Attachment CR004';
            Blob bodyBlob4=Blob.valueOf('Unit Test Attachment Body4');
            attach4.body=bodyBlob4;
            attach4.parentId=riskAsmt4.id;
            lstAtchmt.add(attach4);
            
            Attachment attach5=new Attachment();  
            attach5.Name='Unit Test Attachment CR005';
            Blob bodyBlob5=Blob.valueOf('Unit Test Attachment Body5');
            attach5.body=bodyBlob5;
            attach5.parentId=riskAsmt5.id;
            lstAtchmt.add(attach5);
      
      insert lstAtchmt;
      
      Test.stopTest();   
    List<Attachment> attachments=[select id, name from Attachment where parentid in :liriskAsmt];
    System.assertEquals(5, attachments.size());
    System.debug('// ^^^^valueattchlistfinal2' +attachments);
    
    
    list<Attachment> lstAtchments = new list<Attachment>();
    Attachment attach6=new Attachment();  
    attach6.Name='Unit Test Attachment CR004';
    Blob bodyBlob6=Blob.valueOf('Unit Test Attachment Body');
    attach6.body=bodyBlob6;
    attach6.parentId=riskAsmt6.id;
    lstAtchments.add(attach6);
    
    Attachment attach7=new Attachment();  
    attach7.Name='Unit Test Attachment CR001';
    Blob bodyBlob7=Blob.valueOf('Unit Test Attachment Body');
    attach7.body=bodyBlob7;
    attach7.parentId=riskAsmt1.id;
    lstAtchments.add(attach7);
    
    Attachment attach8=new Attachment();  
    attach8.Name='Unit Test Attachment CR002';
    Blob bodyBlob8=Blob.valueOf('Unit Test Attachment Body');
    attach8.body=bodyBlob8;
    attach8.parentId=riskAsmt2.id;
    lstAtchments.add(attach8);
    
    Attachment attach9=new Attachment();  
    attach9.Name='Unit Test Attachment CR003';
    Blob bodyBlob9=Blob.valueOf('Unit Test Attachment Body');
    attach9.body=bodyBlob9;
    attach9.parentId=riskAsmt3.id;
    lstAtchments.add(attach9);
    
    Attachment attach10=new Attachment();  
    attach10.Name='Unit Test Attachment CR004';
    Blob bodyBlob10=Blob.valueOf('Unit Test Attachment Body');
    attach10.body=bodyBlob10;
    attach10.parentId=riskAsmt4.id;
    lstAtchments.add(attach10);
    
    Attachment attach11=new Attachment();  
    attach11.Name='Unit Test Attachment CR005';
    Blob bodyBlob11=Blob.valueOf('Unit Test Attachment Body');
    attach11.body=bodyBlob11;
    attach11.parentId=riskAsmt5.id;
    lstAtchments.add(attach11);
   
    try{
    insert lstAtchments;
    } catch(exception e){}
  }
  
  static testmethod void removeFileDetailsTest(){
   
   Profile p = [select Id from Profile where Name = :TEST_USER_PROFILE];
      
      // insert a test user
      User u = createUser(TEST_USER, TEST_USER, p.Id, false);
                
        // insert FX Rates
        // There is a workflow which sets Opportunity.Locked_Exchange_Rate__c to 
        // Opportunity.Currency__r.Exchange_Rate__c, which refers to FX_Rates__c.Exchange_Rate__c
        List<FX_Rates__c> fxrs = new List<FX_Rates__c>();
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_USD, Currency_Code__c = CCY_CODE_USD, CurrencyIsoCode = CCY_CODE_USD, Exchange_Rate__c = EXCH_RATE_USD));
        fxrs.add(new FX_Rates__c(Name = CCY_CODE_EUR, Currency_Code__c = CCY_CODE_EUR, CurrencyIsoCode = CCY_CODE_EUR, Exchange_Rate__c = EXCH_RATE_EUR));
        insert fxrs;
        
        Map<String, FX_Rates__c> fxRates = new Map<String, FX_Rates__c>();
        fxRates.put(CCY_CODE_USD, fxrs.get(0));
        fxRates.put(CCY_CODE_EUR, fxrs.get(1));
        
        // Insert accounts
        createAccount(PARENT_ACCOUNT_STAR, AccountsSelector.getParentRecordTypeID(), null, null);
        createAccount(PARENT_ACCOUNT_SAMSUNG, AccountsSelector.getParentRecordTypeID(), null, null);
        Account parentGeneral = createAccount('Parent Account - General', AccountsSelector.getParentRecordTypeID(), null, null);
        Account a = createAccount('Test Account', AccountsSelector.getChildRecordTypeID(), parentGeneral.Id, CBG_AUTOMOTIVE);
        
        list<opportunity> lstOpp = new list<opportunity>(); 
        // Insert an opportunity
        Opportunity o1 = new Opportunity(Name = 'Test Oppty1', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o1.Production_Date__c = PRODUCTION_DATE;
        o1.CloseDate = PRODUCTION_DATE - 60;
        o1.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o1.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o1);
        
        Opportunity o2 = new Opportunity(Name = 'Test Oppty2', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o2.Production_Date__c = PRODUCTION_DATE;
        o2.CloseDate = PRODUCTION_DATE - 60;
        o2.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o2.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o2);
        
        Opportunity o3 = new Opportunity(Name = 'Test Oppty3', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o3.Production_Date__c = PRODUCTION_DATE;
        o3.CloseDate = PRODUCTION_DATE - 60;
        o3.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o3.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o3);
        
        Opportunity o4 = new Opportunity(Name = 'Test Oppty4', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o4.Production_Date__c = PRODUCTION_DATE;
        o4.CloseDate = PRODUCTION_DATE - 60;
        o4.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o4.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o4);
        
        Opportunity o5 = new Opportunity(Name = 'Test Oppty5', OwnerId = u.Id, AccountId = a.Id, StageName = 'Initial Engagement');
        o5.Production_Date__c = PRODUCTION_DATE;
        o5.CloseDate = PRODUCTION_DATE - 60;
        o5.Currency__c = fxRates.get(CCY_CODE_DEFAULT).Id; // Locked_Exchange_Rate__c will be set to this by workflow.
        o5.CurrencyIsoCode = CCY_CODE_DEFAULT; // CurrencyIsoCode and Currency__c are correlated.
        lstOpp.add(o5);
     Test.startTest();   
        insert lstOpp;
        
        System.debug('// ========== after insert oppty');  
        
     // Insert risk assessment    
        list<Compliance_Risk__c> liriskAsmt = new list<Compliance_Risk__c>();
        
        Compliance_Risk__c riskAsmt1 = new Compliance_Risk__c(Opportunity__c = o1.id);
        liriskAsmt.add(riskAsmt1);
        Compliance_Risk__c riskAsmt2 = new Compliance_Risk__c(Opportunity__c = o2.id);
        liriskAsmt.add(riskAsmt2);
        Compliance_Risk__c riskAsmt3 = new Compliance_Risk__c(Opportunity__c = o3.id);
        liriskAsmt.add(riskAsmt3);
        Compliance_Risk__c riskAsmt4 = new Compliance_Risk__c(Opportunity__c = o4.id);
        liriskAsmt.add(riskAsmt4);
        Compliance_Risk__c riskAsmt5 = new Compliance_Risk__c(Opportunity__c = o5.id);
        liriskAsmt.add(riskAsmt5);
        
        insert liriskAsmt;
      
   

     list<Attachment> lstAtchmt = new list<Attachment>();
            Attachment attach1=new Attachment();  
            attach1.Name='Unit Test Attachment CR001';
            Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body');
            attach1.body=bodyBlob1;
            attach1.parentId=riskAsmt1.id;
            lstAtchmt.add(attach1);
            
            Attachment attach2=new Attachment();  
            attach2.Name='Unit Test Attachment CR002';
            Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
            attach2.body=bodyBlob2;
            attach2.parentId=riskAsmt2.id;
            lstAtchmt.add(attach2);
            
            Attachment attach3=new Attachment();  
            attach3.Name='Unit Test Attachment CR003';
            Blob bodyBlob3=Blob.valueOf('Unit Test Attachment Body');
            attach3.body=bodyBlob3;
            attach3.parentId=riskAsmt3.id;
            lstAtchmt.add(attach3);
            
            Attachment attach4=new Attachment();  
            attach4.Name='Unit Test Attachment CR004';
            Blob bodyBlob4=Blob.valueOf('Unit Test Attachment Body');
            attach4.body=bodyBlob4;
            attach4.parentId=riskAsmt4.id;
            lstAtchmt.add(attach4);
            
            Attachment attach5=new Attachment();  
            attach5.Name='Unit Test Attachment CR005';
            Blob bodyBlob5=Blob.valueOf('Unit Test Attachment Body');
            attach5.body=bodyBlob5;
            attach5.parentId=riskAsmt5.id;
            lstAtchmt.add(attach5);
       
      insert lstAtchmt;
      
     
        List<Attachment> attachments=[select id, name from Attachment where parentid in :liriskAsmt];
        System.assertEquals(5, attachments.size());
        delete attachments;
        Test.stopTest();  
        System.debug('// ^^^^valueattchlistfinal' +attachments);
    
        Attachment attach6=new Attachment();  
        attach6.Name='Unit Test Attachment CR004';
        Blob bodyBlob6=Blob.valueOf('Unit Test Attachment Body');
        attach6.body=bodyBlob6;
        attach6.parentId=riskAsmt5.id;
        insert attach6;
        
        Opportunity opp5 = [select id,name,stagename from opportunity where id=:o5.id];
        opp5.stageName = 'Commitment';
        update opp5;
    
    try{
    delete attach6;
    } catch(exception e){}
  }
}