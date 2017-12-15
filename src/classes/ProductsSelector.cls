public class ProductsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return Product2.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Product2.Id,
			Product2.Basic_Type__c,
			Product2.Sales_Item__c
		};
	}
    
}