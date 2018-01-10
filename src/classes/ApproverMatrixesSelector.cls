public class ApproverMatrixesSelector extends ApplicationSelector {
	
	public enum RecordType {DIRECT_OPPTY}
	
	private static final Map<RecordType, String> RECORD_TYPES = new Map<RecordType, String> {
		RecordType.DIRECT_OPPTY => 'Direct Oppty'
	};
	
	public override Schema.SObjectType getSObjectType() {
		return Approvers_Matrix__c.SObjectType;
	}
 	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Approvers_Matrix__c.Id,
			Approvers_Matrix__c.Approver__c,
			Approvers_Matrix__c.Criteria_1__c, 
			Approvers_Matrix__c.Criteria_2__c, 
			Approvers_Matrix__c.Threshold_1__c, 
			Approvers_Matrix__c.Type__c,
			Approvers_Matrix__c.Account__c
		};
	}
	
	public Id getRecordTypeId(RecordType recType) {
		p('getRecordTypeId');
		return getRecordTypeId(RECORD_TYPES.get(recType)); 	
	}
	
	public List<Approvers_Matrix__c> selectByRecordTypeId(Set<Id> recTypeIds) {
		p('selectByRecordTypeId');
		return (List<Approvers_Matrix__c>)Database.query(newQueryFactory().setCondition('RecordTypeId in :recTypeIds').toSOQL());	
	}
    
}