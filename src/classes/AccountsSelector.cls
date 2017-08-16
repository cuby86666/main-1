public class AccountsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return Account.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Account.Id,
			Account.ParentId,
			Account.CMD_Industry_Segment__c,
			Account.Customer_Category__c,
			Account.Region__c 
		};
	}
	
	public List<Account> selectById(Set<Id> ids) {
		p('selectById');
		return (List<Account>)selectSObjectsById(ids);
	}
    
}