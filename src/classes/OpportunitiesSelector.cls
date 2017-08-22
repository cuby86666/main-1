public class OpportunitiesSelector extends ApplicationSelector {
	
	public enum RecordType {SFDC_OPPTY, MODEL_N_OPPTY}
	
	private static final Map<RecordType, String> RECORD_TYPES = new Map<RecordType, String> {
		RecordType.SFDC_OPPTY => 'SFDC Oppty',
		RecordType.MODEL_N_OPPTY => 'Model N Oppty'	
	};
	
	public override Schema.SObjectType getSObjectType() {
		return Opportunity.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Opportunity.Id,
			Opportunity.AccountId,
			Opportunity.RecordTypeId,
			Opportunity.StageName,
			Opportunity.BL_Approver_1__c, 
			Opportunity.BL_Approver_2__c,
			Opportunity.Expiration_Date__c,
			Opportunity.Lost_Description__c,
			Opportunity.Lost_Reason__c,
			Opportunity.LT_Value_USD__c,
			Opportunity.MAG_Approver_1__c, 
			Opportunity.MAG_Approver_2__c,
			Opportunity.Production_Date__c,
			Opportunity.Program__c,
			Opportunity.Regional_VP_Approver__c,
			Opportunity.Sales_Director_Approver__c, 
			Opportunity.TMMA_Override__c,
			Opportunity.VP_Approver_2__c
		};
	}
	
	public static Id getSfdcRecordTypeId() {
		return new OpportunitiesSelector().getRecordTypeId(RecordType.SFDC_OPPTY);
    }
    
    public static Id getMnRecordTypeId() {
    	return new OpportunitiesSelector().getRecordTypeId(RecordType.MODEL_N_OPPTY);
    }
	
	public Id getRecordTypeId(RecordType recType) {
		p('getRecordTypeId');
		return getRecordTypeId(RECORD_TYPES.get(recType));	
	}
	
	public List<Opportunity> selectById(Set<Id> ids) {
		p('selectById');
		return (List<Opportunity>)selectSObjectsById(ids);
	}
	
	public List<Opportunity> selectByIdWithProducts(Set<Id> ids) {
		p('selectByIdWithProducts');
		fflib_QueryFactory opptiesQueryFactory = newQueryFactory();	
		
		fflib_QueryFactory opptyLineItemsQueryFactory = 
			new OpportunityLineItemsSelector().addQueryFactorySubselect(opptiesQueryFactory, CommonUtils.getChildRelationshipName(getSObjectType(), OpportunityLineItem.sObjectType));
			
		new OpportunitiesSelector().configureQueryFactoryFields(opptyLineItemsQueryFactory, OpportunityLineItem.OpportunityId.getDescribe().getRelationshipName());				
		
		return (List<Opportunity>)Database.query(opptiesQueryFactory.setCondition('Id in :ids').toSOQL());
	}
	
	public List<Opportunity> selectByIdWithAccountAndOwner(Set<Id> ids) {
		p('selectByIdWithAccountAndOwner');
		fflib_QueryFactory opptiesQueryFactory = newQueryFactory();
		
		new AccountsSelector().configureQueryFactoryFields(opptiesQueryFactory, Opportunity.AccountId.getDescribe().getRelationshipName());
		
		opptiesQueryFactory.selectField(Opportunity.AccountId.getDescribe().getRelationshipName() + '.' + Account.ParentId.getDescribe().getRelationshipName() + '.' + Account.Name);
		
		new UsersSelector().configureQueryFactoryFields(opptiesQueryFactory, Opportunity.OwnerId.getDescribe().getRelationshipName());
		
		return (List<Opportunity>)Database.query(opptiesQueryFactory.setCondition('Id in :ids').toSOQL());	
	}
	
}