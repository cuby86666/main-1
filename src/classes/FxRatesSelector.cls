public class FxRatesSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return FX_Rates__c.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			FX_Rates__c.Id,
			FX_Rates__c.Currency_Code__c,
			FX_Rates__c.Exchange_Rate__c
		};
	}
	
}