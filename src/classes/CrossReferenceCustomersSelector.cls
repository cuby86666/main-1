public class CrossReferenceCustomersSelector extends ApplicationSelector {

    public enum RecordType {MODEL_N_CUSTOMER}
    
    private static final Map<RecordType, String> RECORD_TYPES = new Map<RecordType, String> {
        RecordType.MODEL_N_CUSTOMER => 'Model N Customer'
    };
    
    private static Id mnRecordTypeId;
    
    public override Schema.SObjectType getSObjectType() {
    	return Cross_Reference_Customer__c.SObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
    	return new List<Schema.SObjectField> {
    		Cross_Reference_Customer__c.Id,
    		Cross_Reference_Customer__c.Child_Account__c,
    		Cross_Reference_Customer__c.Customer_Name__c,
    		Cross_Reference_Customer__c.Customer_Location__c,
    		Cross_Reference_Customer__c.End_Customer_Name_and_Location__c
    	};
    }

	public Id getRecordTypeId(RecordType recType) {
		p('getRecordTypeId');
		return getRecordTypeId(RECORD_TYPES.get(recType));
	}
    
    public static Id getModelNRecordTypeId() {
    	if (mnRecordTypeId == null) {
    		mnRecordTypeId = new CrossReferenceCustomersSelector().getRecordTypeId(RecordType.MODEL_N_CUSTOMER);
    	}
    	return mnRecordTypeId;
    }
    
    public List<Cross_Reference_Customer__c> selectByRecordTypeId(Set<Id> recTypeIds) {
    	p('selectByRecordTypeId');
    	return (List<Cross_Reference_Customer__c>)Database.query(newQueryFactory().setCondition('RecordTypeId in :recTypeIds').toSOQL());
    }
    
    public Map<String, Cross_Reference_Customer__c> getByRecordTypeIdToMap(Set<Id> recTypeIds) {
    	p('selectByRecordTypeIdToMap');
    	Map<String, Cross_Reference_Customer__c> CrossRefCustsByEndCustNameLoc = new Map<String, Cross_Reference_Customer__c>(); 
    	for (Cross_Reference_Customer__c cust : selectByRecordTypeId(recTypeIds)) {
    		if(!CrossRefCustsByEndCustNameLoc.containskey(cust.End_Customer_Name_and_Location__c)) {
                CrossRefCustsByEndCustNameLoc.put(cust.End_Customer_Name_and_Location__c,cust);
            }
    	}
    	return CrossRefCustsByEndCustNameLoc;
    }

}