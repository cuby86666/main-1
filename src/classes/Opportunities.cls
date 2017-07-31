public class Opportunities extends ApplicationDomain {
	
	public Opportunities(List<Opportunity> oppties) {
		super(oppties);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new Opportunities(sObjectList);
		}
	}
	
	public override void onBeforeInsert() {
		System.debug('//- Opportunities.onBeforeInsert');
		updateLastBusinessModifiedInfo();	
	}
	
	public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
		System.debug('//- Opportunities.onBeforeUpdate');
		bypassValidation((Map<Id, Opportunity>)existingRecords);	
		
		if (!CommonUtils.isAdminOrIntegrationUser()) {
			updateLastBusinessModifiedInfo();	
		}
	}
	
	public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
		System.debug('//- Opportunities.onAfterUpdate');
		updateOpptyProdPrograms((Map<Id, Opportunity>)existingRecords);
	}
	
	private void bypassValidation(Map<Id, Opportunity> existingRecords) {
		for (Opportunity oppty : (List<Opportunity>)records) {
			oppty.Bypass_Validation__c = false;
			
			Opportunity oldOppty = existingRecords.get(oppty.Id);
			
			if (oppty.Program__c != oldOppty.Program__c) {
				// Check if any other field is changed. If no, bypass the validation.
				Map<String, Schema.SObjectField> opptyFields = fflib_SObjectDescribe.getDescribe(getSObjectType()).getFieldsMap();
				Boolean otherFieldsChanged = false; 	
		
				for (Schema.SObjectField field : opptyFields.values()) {
					if (field != Opportunity.Program__c && field != Opportunity.Bypass_Validation__c && field.getDescribe().isUpdateable()) {
						String fieldName = field.getDescribe().getName();
						
						if (oppty.get(fieldName) != oldOppty.get(fieldName)) {
							otherFieldsChanged = true;
							break;
						}	
					}
				}
				
				if (!otherFieldsChanged) {
					oppty.Bypass_Validation__c = true;	
				}
			}
		}
	}
	
	private void updateLastBusinessModifiedInfo() {
		for (Opportunity oppty : (List<Opportunity>)records) {
			oppty.Last_Business_Modified_By_Id__c = UserInfo.getUserId();
	        oppty.Last_Business_Modified_Date__c = Datetime.now();	
		}	
	}
	
	private void updateOpptyProdPrograms(Map<Id, Opportunity> existingRecords) {
		Set<Id> opptyIds = new Set<Id>();
		
		for (Opportunity oppty : (List<Opportunity>)records) {
			Opportunity oldOppty = existingRecords.get(oppty.Id);
			
			if (oppty.Program__c != oldOppty.Program__c) {
				opptyIds.add(oppty.Id);	
			}
		}
		
		if (opptyIds.size() > 0) {
			List<OpportunityLineItem> opptyProds = new List<OpportunityLineItem>();
        
	        for (Opportunity oppty : new OpportunitiesSelector().selectByIdWithProducts(opptyIds)) {
	        	opptyProds.addAll(oppty.OpportunityLineItems);
	        }
	        
	        if (opptyProds.size() > 0) {
	        	fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
	        	new OpportunityLineItems(opptyProds).updatePrograms(uow);	
	        	uow.commitWork();
	        }	
		}	
	}
    
}