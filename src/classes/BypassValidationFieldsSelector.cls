public class BypassValidationFieldsSelector extends ApplicationSelector {
	
	private static List<Bypass_Validation_Field__mdt> bypassValidationFields;
	
	public override Schema.SObjectType getSObjectType() {
		return Bypass_Validation_Field__mdt.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Bypass_Validation_Field__mdt.Field_Name__c,
			Bypass_Validation_Field__mdt.Object_Name__c 
		};
	}
	
	public static List<Schema.SObjectField> selectBySObject(Schema.SObjectType sObjectType) {
		List<Schema.SObjectField> result = new List<Schema.SObjectField>();
		
		if (bypassValidationFields == null) {
			bypassValidationFields = (List<Bypass_Validation_Field__mdt>)new BypassValidationFieldsSelector().selectAll();	
		}
		
		for (Bypass_Validation_Field__mdt bvf : bypassValidationFields) {
			if (bvf.Object_Name__c == sObjectType.getDescribe().getName()) {
				result.add(fflib_SObjectDescribe.getDescribe(sObjectType).getField(bvf.Field_Name__c));
			}
		}
		
		return result;	
	}
    
}