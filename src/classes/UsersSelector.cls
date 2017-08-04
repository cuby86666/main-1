public class UsersSelector extends ApplicationSelector {
    
    public Schema.SObjectType getSObjectType() {
		return User.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			User.Name,
			User.MT_1__c,
			User.MT_2__c 
		};
	}
	
	public List<User> selectById(Set<Id> ids) {
		System.debug('//-s UsersSelector.selectById');
		return (List<User>)selectSObjectsById(ids);
	}
    
}