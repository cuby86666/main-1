public class OpportunityTmmaOverrideSettingsSelector extends ApplicationSelector {
    
    public override Schema.SObjectType getSObjectType() {
		return Opportunity_TMMA_Override_Setting__mdt.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Opportunity_TMMA_Override_Setting__mdt.Field_Name__c,
			Opportunity_TMMA_Override_Setting__mdt.Object_Name__c 
		};
	}

}