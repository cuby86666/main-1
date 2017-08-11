public class AccountsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return Account.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Account.CMD_Industry_Segment__c,
			Account.Customer_Category__c,
			Account.ParentId,
			Account.Region__c 
		};
	}
    
}