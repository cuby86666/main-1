public class OpportunityClaimValueMagSettingsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return Opportunity_Claim_Value_MAG_Setting__mdt.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Opportunity_Claim_Value_MAG_Setting__mdt.Claim_Value_Quarters__c,
			Opportunity_Claim_Value_MAG_Setting__mdt.MAG__c 
		};
	}
	
	public List<Opportunity_Claim_Value_MAG_Setting__mdt> selectAll() {
		p('selectAll');
        return (List<Opportunity_Claim_Value_MAG_Setting__mdt>)Database.query(newQueryFactory().toSOQL());        
    }
    
}