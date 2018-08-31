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
	
	public List<Opportunity_TMMA_Override_Setting__mdt> selectByObjectName(Set<String> objNames) {
		p('selectByObjectName');
		return (List<Opportunity_TMMA_Override_Setting__mdt>)Database.query(newQueryFactory().setCondition('Object_Name__c in :objNames').toSOQL());
	}
	
	public Set<String> selectFieldNamesByObjectName(String objName) {
		p('selectFieldNamesByObjectName');
		Set<String> result = new Set<String>();
		
		for (Opportunity_TMMA_Override_Setting__mdt otos : selectByObjectName(new Set<String> {objName})) {
			result.add(otos.Field_Name__c);	
		}
		
		return result;
	}

}