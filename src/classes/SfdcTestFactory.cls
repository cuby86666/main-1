@isTest
public class SfdcTestFactory {
	
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
				if (name != null) obj.put('Name', name + i);
				sObjects.add(obj);
			}
			return sObjects;
		}
	}
// TestUser ============================================================================
	public class TestUser extends AbstractTestSObject {
		public TestUser(String name, Integer numOfObjs, Id profileId) {
			create('User', name, numOfObjs);
			Map<String, Object> userDefaultValues = new Map<String, Object>();
			userDefaultValues.put('FirstName', name + 'FirstName');
			userDefaultValues.put('EmailEncodingKey', 'UTF-8');
			userDefaultValues.put('LanguageLocaleKey', 'en_US');
			userDefaultValues.put('LocaleSidKey', 'en_US');
			userDefaultValues.put('TimeZoneSidKey', 'America/Los_Angeles');
			userDefaultValues.put('ProfileId', profileId);
            userDefaultValues.put('IsActive', true);
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

// TestAccount ============================================================================
	public class TestAccount extends AbstractTestSObject {
		public TestAccount(String name, Integer numOfObjs) {
			create('Account', name, numOfObjs);
		}
	}

	public class TestOpportunity extends AbstractTestSObject {
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

// TestProduct ============================================================================
	public class TestProduct extends AbstractTestSObject {
		public TestProduct(String name, Integer numOfObjs) {
			create('Product2', name, numOfObjs);
            updateFieldByValue('IsActive', true);
		}

		public List<PricebookEntry> selectPricebookEntries(String currencyIsoCode) {
			List<Product2> prods = (List<Product2>)this.getSObject();
			List<PriceBookEntry> pricebookEntries = [
				Select Id, CurrencyIsoCode from PriceBookEntry Where CurrencyIsoCode = :currencyIsoCode and Product2Id in :prods
			];
			return pricebookEntries;
		}

		public List<Id> selectPricebookEntryIds(String currencyIsoCode) {
			List<Product2> prods = (List<Product2>)this.getSObject();
			List<PricebookEntry> pricebookEntries = [
				Select Id from PriceBookEntry Where CurrencyIsoCode = :currencyIsoCode and Product2Id in :prods
			];
			List<Id> pricebookEntryIds = new List<Id>();
			for (PricebookEntry pbe : pricebookEntries) {
				pricebookEntryIds.add(pbe.Id);
			}
			return pricebookEntryIds;
		}
	}

	// TestOpportunitySchedule ============================================================================
	public class TestOpportunitySchedule extends AbstractTestSObject {
		public TestOpportunitySchedule(Opportunity oppty, Integer numOfObjs, Integer quarterQty) {
			Integer totalOpptySched = 4;
			if (numOfObjs != null) totalOpptySched = numOfObjs;
			create('OpportunitySchedule__c', null, totalOpptySched);
			//set default value
			Map<String, Object> schedDefaultValues = new Map<String, Object>();
			schedDefaultValues.put('Opportunity__c', oppty.Id);
			schedDefaultValues.put('Oppty_Sched_Qty__c', quarterQty);
			schedDefaultValues.put('Frozen_Oppty_Sched_Qty__c', quarterQty);
			updateFieldsByMap(schedDefaultValues);
			//set oppty sched date
			Date[] schedDates = getOpptySchedDates(oppty.Production_Date__c, totalOpptySched);
			for (Integer i = 0; i < totalOpptySched; i++) {
				sObjects.get(i).put('Sched_Date__c', schedDates[i]);
			}
		}

	    private Date[] getOpptySchedDates(Date productionDate, Integer totalQarters) {
	        Date[] result = new Date[totalQarters];
	        for (Integer i = 0; i < totalQarters; i++) {
	            if (i == 0) {
	                result[0] = productionDate;
	            }
	            else {
	                Date nextQuarter = result[i-1].addMonths(3);
	                Integer nextQtr = Decimal.valueOf(nextQuarter.month()).divide(3.0, 0, System.RoundingMode.UP).intValue();
	                result[i] = Date.newInstance(nextQuarter.year(), (nextQtr-1)*3+1, 1);
	            }
	            //System.debug('@@@@@ oppty sched date[' + i + ']=' + result[i]);
	        }
	        return result;
	    }
	}

// TestOpportunityLineItem ============================================================================
	public class TestOpportunityLineItem extends AbstractTestSObject {
		public TestOpportunityLineItem(Opportunity oppty, Integer numOfObjs) {
			create('OpportunityLineItem', null, numOfObjs);
			updateFieldByValue('OpportunityId', oppty.Id);
		}
	}

// createSfdcOpportunitiesAndLineItems ============================================================================
	public static void createSfdcOpportunitiesAndLineItems(Integer numOfOppty, Integer numOfLineItems) {
		Profile prf = [Select Id from Profile Where Name = 'Standard User'];
		TestUser usr = new TestUser('test', numOfOppty, prf.Id);
        List<User> users = (List<User>)usr.getSObject();
        insert users;

        TestAccount acc = new TestAccount('testAccount', numOfOppty);
        List<Account> accounts = acc.getSObject();
        insert accounts;

        TestOpportunity opp = new TestOpportunity('testOppty', numOfOppty, OpportunitiesSelector.getSfdcRecordTypeId());
        List<Opportunity> opportunities = opp.getSObject();
        opp.updateOpportunityAccounts(accounts);
        opp.updateFieldByValue('OwnerId', users.get(0).Id);
        insert opportunities;

        //products
        TestProduct prod = new TestProduct('testProduct', numOfLineItems);
        List<Product2> products = prod.getSObject();
        insert products;
        
        List<OpportunitySchedule__c> opptyScheds = new List<OpportunitySchedule__c>();
        List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
        
        List<Id> pbeIds = prod.selectPriceBookEntryIds('USD');

        for (Opportunity oppty : opportunities) {
            TestOpportunitySchedule sched = new TestOpportunitySchedule(oppty, 4, 1000);
            opptyScheds.addAll((List<OpportunitySchedule__c>)sched.getSObject());
            TestOpportunityLineItem opptyProd = new TestOpportunityLineItem(oppty, numOfLineItems);
            opptyProd.updateFieldByValue('UnitPrice', 2);
            opptyProd.updateFieldByValue('Component_Multiplier__c', 2);
            opptyProd.updateFieldbyArray('PricebookEntryId', pbeIds);
            opptyProds.addAll((List<OpportunityLineItem>)opptyProd.getSObject());
        }
        insert opptyScheds;
        insert opptyProds;
	}

}