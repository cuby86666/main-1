public class ModelNStageSettingsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return Model_N_Stage_Setting__mdt.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Model_N_Stage_Setting__mdt.Field_Name__c,
			Model_N_Stage_Setting__mdt.Field_Value__c 
		};
	}
    
}