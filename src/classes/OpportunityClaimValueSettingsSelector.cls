public class OpportunityClaimValueSettingsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return Opportunity_Claim_Value_Setting__mdt.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Opportunity_Claim_Value_Setting__mdt.Account_CBG__c,
			Opportunity_Claim_Value_Setting__mdt.Cross_Update_Allowed__c 
		};
	}
	
	public List<Opportunity_Claim_Value_Setting__mdt> selectWhere(String condition) {
		p('selectWhere');
        return (List<Opportunity_Claim_Value_Setting__mdt>)Database.query(newQueryFactory().setCondition(condition).toSOQL());        
    }
    
}