public class UsersSelector extends ApplicationSelector {
    
    public override Schema.SObjectType getSObjectType() {
		return User.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			User.Id,
			User.Name,
			User.IsActive,
			User.MT_1__c,
			User.MT_2__c
		};
	}
	
	public List<User> selectByName(Set<String> names) {
		p('selectByName');
		return (List<User>)Database.query(newQueryFactory().setCondition('Name in :names').toSOQL());
	}

}