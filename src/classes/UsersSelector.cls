public class UsersSelector extends ApplicationSelector {
    
    public override Schema.SObjectType getSObjectType() {
		return User.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			User.Id,
			User.Email,
			User.Name,
			User.IsActive,
			User.Username,
			User.MT_1__c,
			User.MT_2__c
		};
	}
	
	public List<User> selectByName(Set<String> names) {
		p('selectByName');
		return (List<User>)Database.query(newQueryFactory().setCondition('Name in :names').toSOQL());
	}

    public List<User> selectSalesforceUsersByUsername(Set<String> usernames) {
		p('selectSalesforceUsersByUsername');
		return (List<User>)Database.query(newQueryFactory().setCondition('Username in :usernames and User_License__c in (\'Salesforce\', \'Salesforce Platform\', \'Chatter Only\')').toSOQL());
    }
    
}