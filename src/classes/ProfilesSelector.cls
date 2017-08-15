public class ProfilesSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return Profile.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Profile.Id,
			Profile.Name 
		};
	}
	
	public List<Profile> selectByName(Set<String> names) {
		p('selectByName');
		return (List<Profile>)Database.query(newQueryFactory().setCondition('Name in :names').toSOQL());
	}
	
}