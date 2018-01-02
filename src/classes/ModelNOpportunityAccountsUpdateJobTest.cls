@isTest
private class ModelNOpportunityAccountsUpdateJobTest {

	@testsetup static void setup() {
		User dataAdmin = [Select Id, Name, Email from User Where Name = 'Data Admin' limit 1];
		Profile prf = [Select Id from Profile Where Name = 'Standard User'];
		TestUser usr = new TestUser('myTest', 5, prf.Id);
		List<User> users = (List<User>)usr.getSObject();
		System.debug('@@@@@ Test Data Admin=' + dataAdmin.Id);
		if (dataAdmin == null) {
	        users.get(4).FirstName = 'Data';
	        users.get(4).LastName = 'Admin';
       		dataAdmin = users.get(4); //[select Id, Name, Email from User Where Name = 'Data Admin' limit 1];
		}
		insert users;

		TestAccount acc = new TestAccount('testAccount', 5);
		List<Account> accounts = acc.getSObject();
		//setup Account gid and legacy id
		Object[] gidObjs = new Object[] {'10001','10002','','',''};
		Object[] legacyIdObjs = new Object[] {'','','AVNET ASIA PAC-EMEA','AVNET ASIA PAC-JAPAN',''};
		acc.updateFieldByArray('NXP_GID__c', gidObjs);
		acc.updateFieldByArray('Legacy_Id__c', legacyIdObjs);
		//update distributor account name
		accounts.get(2).Name = 'DistAccount1';
		accounts.get(3).Name = 'DistAccount2';
		//update Unknown account
		accounts.get(4).Name = 'Unknown';
		acc.updateFieldByValue('OwnerId', users.get(1).Id);
		insert accounts;
		
		TestOpportunity opp = new TestOpportunity('testOppty', 5, OpportunitiesSelector.getMnRecordTypeId());
		//opp.updateOpportunityAccounts(accounts);

		//setup Oppty gid, distributr name and end customer region
		Object[] opptyGids = new Object[] {'10001','10002','','',''};
        opp.updateFieldByValue('OwnerId', dataAdmin.Id);
		opp.updateFieldByArray('End_Customer_GID__c', opptyGids);		
		opp.updateFieldByValue('Distributor_Name__c','AVNET ASIA PAC');
		
		Object[] opptyRegions = new Object[] {'EMEA','EMEA','EMEA','EMEA','SAP'};
		opp.updateFieldByArray('End_Customer_Region__c', opptyRegions);

		List<Opportunity> opportunities = opp.getSObject();
        opportunities.get(2).Legacy_Opportunity_Owner__c = users.get(2).Email;       
        opportunities.get(3).Legacy_Opportunity_Owner__c = 'aaa@bbb.com';
        
        opportunities.get(0).AccountId = accounts.get(0).Id;
        opportunities.get(0).OwnerId = users.get(3).Id;
        
		insert opportunities;
	}

/*
	@isTest static void testAccount() {
		DumpAccounts();
		//System.assert(accounts.size() == 10);
	}
	
	@isTest static void testOpportunity() {
		DumpOppties();
		//system.assert(oppties.size() == 1);
	}
	
	@isTest static void testUser() {
		DumpUsers();
	}*/

	@isTest static void testModelNOpportunityAccountsUpdateJob1() {
		DumpOppties();
		Test.startTest();
		ModelNOpportunityAccountsUpdateJob myJob = new ModelNOpportunityAccountsUpdateJob();
		database.executebatch(myJob);
		Test.stopTest();
		DumpOppties();
		DumpUsers();
	}

	@isTest static void testMnOpportunityAccountUpdateNoUnknownAccount() {
		List<Account> unknownAccounts = [Select Id from Account Where Name = 'Unknown'];
		delete unknownAccounts;
		Test.startTest();
		ModelNOpportunityAccountsUpdateJob myJob = new ModelNOpportunityAccountsUpdateJob();
		database.executebatch(myJob);
		Test.stopTest();
	}

	@isTest static void testModelNOpportunityAccountsUpdateJob2() {
		Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2030';
        //schedule the job
        String jobId = System.schedule('testModelNOpportunityAccountsUpdateJob', CRON_EXP, new ModelNOpportunityAccountsUpdateJob());

        List<CronTrigger> lstCrons = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                    FROM CronTrigger WHERE id = :jobId Limit 1];

        System.assert(lstCrons.size() > 0);
        System.assert(lstCrons[0].CronExpression == CRON_EXP);
        System.assert(lstCrons[0].TimesTriggered == 0);
	}

	static void DumpUsers() {
		List<User> users = [Select Id, Name, UserName, Profile.Name, Email from User Where CreatedDate = Today];
		for (User usr : users) {
			System.debug('@@@@@ User Name=' + usr.Name + ', Username=' + usr.UserName + ', profile=' + usr.Profile.Name);
		}
	}

	static void DumpAccounts() {
		List<Account> accounts = [Select Id, Name, RecordType.Name, NXP_GID__c, Legacy_Id__c from Account];
		for (Account acc : accounts) {
			System.debug('@@@@@ Account Name=' + acc.Name + ', GID=' + acc.NXP_GID__c + ', Legacy_Id__c=' + acc.Legacy_Id__c);
		}
	}

	static void DumpOppties() {
		List<Opportunity> oppties = [Select Id, Name, CloseDate, Account.Name, End_Customer_GID__c, Legacy_Opportunity_Owner__c, Distributor_Name__c, End_Customer_Region__c, Owner.Name from Opportunity];
		for (Opportunity opp : oppties) {
			System.debug('@@@@@ Oppty Name=' + opp.Name + ', Account=' + opp.Account.Name + ', GID=' + opp.End_Customer_GID__c + ', DR Approver=' + opp.Legacy_Opportunity_Owner__c + ', opp.Legacy_Id__c=' + opp.Distributor_Name__c + '-' + opp.End_Customer_Region__c + ', Owner=' + opp.Owner.Name);
		}
	}

	interface TestSObject {
		List<SObject> create(String objType, String name, Integer numOfObjs);
		List<SObject> getSObject();
		//List<SObject> dumpSObjects();
		//void updateFieldByArray(String fieldName, Object[] values);
		//void updateFieldBySeries(String fieldName);

	}

	abstract class AbstractTestSObject implements TestSObject {
		private List<SObject> sObjects;

		public virtual List<SObject> getSObject() {
			return sObjects;
		}

		//update field by a Map
		public virtual void updateFieldsByMap(Map<String, Object> fieldMap) {
			for (SObject obj : sObjects) {
				for (String key : fieldMap.keySet()) {
					obj.put(key, fieldMap.get(key));
				}
			}
		}

		//update field with a serial number. Ex: prefix=a, value=a1,a2,a3...a10
		public virtual void updateFieldBySeries(String fieldName, String prefix) {
			Object[] values = new Object[sObjects.size()];
			for (Integer i = 0; i < sObjects.size(); i++) {
				values[i] = prefix + i;
			}
			updateFieldByArray(fieldName, values);			
		}

		//update field with a serial number without prefix
		public virtual void updateFieldBySeries(String fieldName) {
			updateFieldBySeries(fieldName, null);
		}

		//update field with a fixed value
		public virtual void updateFieldByValue(String fieldName, Object value) {
			for (Integer i = 0; i < sObjects.size(); i++) {
				sObjects.get(i).put(fieldName, value);
			}
		}

		//update field with a array
		public virtual void updateFieldByArray(String fieldName, Object[] values) {
			for (Integer i = 0; i < values.size(); i++) {
				sObjects.get(i).put(fieldName, values[i]);
			}
		}

		public virtual List<SObject> create(String objType, String name, Integer numOfObjs) {
			sObjects = new List<SObject>();
			Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objType);
			if (sObjType == null) {
				throw new TypeException('Unsupported ObjectType ' + objType);
			}

			for (Integer i = 0; i < numOfObjs; i++) {
				SObject obj = sObjType.newSObject();
				obj.put('Name', name + i);
				sObjects.add(obj);
			}
			return sObjects;
		}
	}

	class TestUser extends AbstractTestSObject {
		public TestUser(String name, Integer numOfObjs, Id profileId) {
			create('User', name, numOfObjs);
			Map<String, Object> userDefaultValues = new Map<String, Object>();
			userDefaultValues.put('FirstName', name + 'FirstName');
			userDefaultValues.put('EmailEncodingKey', 'UTF-8');
			userDefaultValues.put('LanguageLocaleKey', 'en_US');
			userDefaultValues.put('LocaleSidKey', 'en_US');
			userDefaultValues.put('TimeZoneSidKey', 'America/Los_Angeles');
			userDefaultValues.put('ProfileId', profileId);
			updateFieldsByMap(userDefaultValues);
		}

		public override List<SObject> create(String objType, String name, Integer numOfObjs) {
			sObjects = new List<SObject>();
			Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objType);
			if (sObjType == null) {
				throw new TypeException('Unsupported ObjectType ' + objType);
			}
			String emailName = CommonUtils.generateGUID();
			for (Integer i = 0; i < numOfObjs; i++) {
				SObject obj = sObjType.newSObject();
				String email = emailName + i + '@nxptest.com.test';
				obj.put('LastName', name + i);
				obj.put('Alias', 'A-' + i); //Alias field max length=8
				obj.put('Email', email);
				obj.put('UserName', email);
				sObjects.add(obj);
			}
			return sObjects;
		}
	}

	class TestAccount extends AbstractTestSObject {
		public TestAccount(String name, Integer numOfObjs) {
			create('Account', name, numOfObjs);
		}
	}

	class TestOpportunity extends AbstractTestSObject {
		public TestOpportunity(String name, Integer numOfObjs, Id recordTypeId) {
			create('Opportunity', name, numOfObjs);
			/*CloseDate = Date.today(), Production_Date__c = Date.today().addDays(30),
			StageName = 'Discovery', One_Year_Pieces__c = 1000*/
			Map<String, Object> opptyDefaultValues = new Map<String, Object>();
			opptyDefaultValues.put('RecordTypeId', recordTypeId);
			opptyDefaultValues.put('CloseDate', Date.today().addDays(5));
			opptyDefaultValues.put('Production_Date__c', Date.today().addDays(30));
			opptyDefaultValues.put('StageName', 'Discovery');
			opptyDefaultValues.put('One_Year_Pieces__c', 1000);
			updateFieldsByMap(opptyDefaultValues);
		}

		public void updateOpportunityAccounts(List<Account> accounts) {
			Object[] objects = new Object[accounts.size()];
			for (Integer i = 0; i < objects.size(); i++) {
				sObjects.get(i).put('AccountId', accounts.get(i).Id);
			}
		}
	}
}