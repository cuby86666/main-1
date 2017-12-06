@isTest
private class ModelNOpportunityAccountsUpdateJobTest {

	@testsetup static void setup() {
		TestAccount acc = new TestAccount('testAccount', 10);
		List<Account> accounts = acc.getSObject();
		insert accounts;
		
		TestOpportunity opp = new TestOpportunity('testOppty', 10, OpportunitiesSelector.getMnRecordTypeId());
		opp.updateOpportunityAccounts(accounts);
		List<Opportunity> opportunities = opp.getSObject();
		insert opportunities;

		Profile prf = [Select Id from Profile Where Name = 'Standard User'];
		TestUser usr = new TestUser('myTestUser', 10, prf.Id);
		List<User> users = (List<User>)usr.getSObject();
		insert users;
	}

	@isTest static void testAccount() {
		List<Account> accounts = [Select Id, Name, RecordType.Name from Account];
		for (Account acc : accounts) {
			System.debug('@@@@@ Name=' + acc.Name + ', RecordType=' + acc.RecordType.Name);
		}
		//System.assert(accounts.size() == 10);
	}
	
	@isTest static void testOpportunity() {
		List<Opportunity> oppties = [Select Id, Name, CloseDate, Account.Name from Opportunity];
		for (Opportunity opp : oppties) {
			System.debug('@@@@@ Name=' + opp.Name + ', CloseDate=' + opp.CloseDate + ', Account=' + opp.Account.Name);
		}
		//system.assert(oppties.size() == 1);
	}
	
	@isTest static void testUser() {
		List<User> users = [Select Id, Name, UserName, Profile.Name from User Where FirstName = 'myTestUser'];
		for (User usr : users) {
			System.debug('@@@@@ Name=' + usr.Name + ', Username=' + usr.UserName + ', profile=' + usr.Profile.Name);
		}
	}

	interface TestSObject {
		List<SObject> create(String objType, String name, Integer numOfObjs);
		//void updateFieldByArray(String fieldName, Object[] values);
		//void updateFieldBySeries(String fieldName);
		List<SObject> getSObject();
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
			for (Integer i = 0; i < sObjects.size(); i++) {
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
			userDefaultValues.put('FirstName', name);
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

			for (Integer i = 0; i < numOfObjs; i++) {
				SObject obj = sObjType.newSObject();
				obj.put('LastName', name + i);
				obj.put('Alias', 'A-' + i); //Alias field max length=8
				String email = CommonUtils.generateGUID() + '@nxptest.com.test';
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
			for (Integer i = 0; i < sObjects.size(); i++) {
				sObjects.get(i).put('AccountId', accounts.get(i).Id);
			}
		}
	}
}