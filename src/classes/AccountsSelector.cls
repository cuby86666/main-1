public class AccountsSelector extends ApplicationSelector {
	
	public enum RecordType {CHILD_ACCOUNT, PARENT_ACCOUNT}
	
	private static final Map<RecordType, String> RECORD_TYPES = new Map<RecordType, String> {
		RecordType.CHILD_ACCOUNT => 'Child Account',
		RecordType.PARENT_ACCOUNT => 'Parent Account'	
	};
	
	private static Id childRecordTypeId;
	private static Id parentRecordTypeId;
	
	public override Schema.SObjectType getSObjectType() {
		return Account.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Account.Id,
			Account.Name,
			Account.OwnerId,
			Account.ParentId,
			Account.CMD_Industry_Segment__c,
			Account.Customer_Category__c,
			Account.Legacy_Id__c,
			Account.NXP_GID__c,
			Account.Region__c
		};
	}
	
	public override String getOrderBy() {
		return 'IsInActive__c DESC';
	}

	public static Id getChildRecordTypeId() {
		if (childRecordTypeId == null) {
			childRecordTypeId = new AccountsSelector().getRecordTypeId(RecordType.CHILD_ACCOUNT); 
		}
		
		return childRecordTypeId;
	}
    
    public static Id getParentRecordTypeId() {
    	if (parentRecordTypeId == null) {
    		parentRecordTypeId = new AccountsSelector().getRecordTypeId(RecordType.PARENT_ACCOUNT); 	
    	}
    	
    	return parentRecordTypeId; 
    }
	
	public Id getRecordTypeId(RecordType recType) {
		p('getRecordTypeId');
		return getRecordTypeId(RECORD_TYPES.get(recType));	
	}
	
	public List<Account> selectById(Set<Id> ids) {
		p('selectById');
		return (List<Account>)selectSObjectsById(ids);
	}

	public List<Account> selectByName(Set<String> names) {
		p('selectByName');
		return (List<Account>)Database.query(newQueryFactory().setCondition('Name in :names').toSOQL());
	}

	public List<Account> selectChildAccountsWithOwnerByGidOrLegacyId(Set<String> gids, Set<String> legacyIds) {
		p('selectChildAccountsWithOwnerByGidOrLegacyId');
		Id childRecTypeId = getChildRecordTypeId();
		fflib_QueryFactory accountsQueryFactory = newQueryFactory();
		new UsersSelector().configureQueryFactoryFields(accountsQueryFactory, Account.OwnerId.getDescribe().getRelationshipName());
		return (List<Account>)Database.query(accountsQueryFactory.setCondition('RecordTypeId = :childRecTypeId and (NXP_GID__c in :gids or Legacy_Id__c in :legacyIds)').toSOQL());
	}
    
}