public class OpportunitiesSelector extends ApplicationSelector {
	
	public enum RecordType {SFDC_OPPTY, MODEL_N_OPPTY}
	
	private static final Map<RecordType, String> RECORD_TYPES = new Map<RecordType, String> {
		RecordType.SFDC_OPPTY => 'SFDC Oppty',
		RecordType.MODEL_N_OPPTY => 'Model N Oppty'	
	};
	
	private static Id sfdcRecordTypeId;
	private static Id mnRecordTypeId;
	
	public override Schema.SObjectType getSObjectType() {
		return Opportunity.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Opportunity.Id,
			Opportunity.AccountId,
			Opportunity.CloseDate,
			Opportunity.Name,
			Opportunity.RecordTypeId,
			Opportunity.StageName,
			Opportunity.BL_Approver_1__c, 
			Opportunity.BL_Approver_2__c,
			Opportunity.Claim_Value__c,
			Opportunity.Claim_Value_USD_SYS__c,
			Opportunity.Design_Reg_Status__c,
			Opportunity.Discovery_Date__c,
			Opportunity.Distributor_Name__c,
			Opportunity.End_Customer_Region__c,
			Opportunity.End_Customer_GID__c,
			Opportunity.Expiration_Date__c,
			Opportunity.Industry_Segment__c,
			Opportunity.Locked_Exchange_Rate__c,
			Opportunity.Lead_Id__c,
			Opportunity.Legacy_End_Customer_Name_and_Location__c,
      		Opportunity.Legacy_Id__c,
			Opportunity.Legacy_Opportunity_Owner__c,
			Opportunity.Locked_Exchange_Rate__c,			
			Opportunity.Lost_Date__c,
			Opportunity.Lost_Description__c,
			Opportunity.Lost_Reason__c,
			Opportunity.LT_Value_USD__c,
			Opportunity.MAG_Approver_1__c, 
			Opportunity.MAG_Approver_2__c,
			Opportunity.MN_Account_Id_Old__c,
			Opportunity.Production_Date__c,
			Opportunity.Program__c,
			Opportunity.Regional_VP_Approver__c,
			Opportunity.Rejected_by__c,
			Opportunity.Sales_Director_Approver__c,
			Opportunity.Sub_Segment__c,
			Opportunity.TMMA_Override__c,
			Opportunity.VP_Approver_2__c,
			Opportunity.War_Room_Completed__c
		};
	}
	
	public static Id getSfdcRecordTypeId() {
		if (sfdcRecordTypeId == null) {
			sfdcRecordTypeId = new OpportunitiesSelector().getRecordTypeId(RecordType.SFDC_OPPTY); 
		}
		
		return sfdcRecordTypeId;
	}
    
    public static Id getMnRecordTypeId() {
    	if (mnRecordTypeId == null) {
    		mnRecordTypeId = new OpportunitiesSelector().getRecordTypeId(RecordType.MODEL_N_OPPTY); 	
    	}
    	
    	return mnRecordTypeId; 
    }
	
	public Id getRecordTypeId(RecordType recType) {
		p('getRecordTypeId');
		return getRecordTypeId(RECORD_TYPES.get(recType));	
	}
	
	public List<Opportunity> selectById(Set<Id> ids) {
		p('selectById');
		return (List<Opportunity>)selectSObjectsById(ids);
	}
	
	public List<Opportunity> selectByLegacyId(Set<String> legacyIds) {
		p('selectByLegacyId');
		return (List<Opportunity>)Database.query(newQueryFactory().setCondition('Legacy_Id__c in :legacyIds').toSOQL());
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
		fflib_QueryFactory opptiesQueryFactory = getOpptiesWithAccountAndOwnerQueryFactory();
		
		return (List<Opportunity>)Database.query(opptiesQueryFactory.setCondition('Id in :ids').toSOQL());	
	}
	
	public Database.QueryLocator selectByConditionWithAccountAndOwnerQueryLocator(String condition) {
		p('selectByConditionWithAccountAndOwnerQueryLocator');
		fflib_QueryFactory opptiesQueryFactory = getOpptiesWithAccountAndOwnerQueryFactory();
		
		return Database.getQueryLocator(opptiesQueryFactory.setCondition(condition).toSOQL());        
    }
    
    private fflib_QueryFactory getOpptiesWithAccountAndOwnerQueryFactory() {
		fflib_QueryFactory result = newQueryFactory();
		
		new AccountsSelector().configureQueryFactoryFields(result, Opportunity.AccountId.getDescribe().getRelationshipName());
		
		result.selectField(Opportunity.AccountId.getDescribe().getRelationshipName() + '.' + Account.ParentId.getDescribe().getRelationshipName() + '.' + Account.Name);
		
		new UsersSelector().configureQueryFactoryFields(result, Opportunity.OwnerId.getDescribe().getRelationshipName());
		
		return result;	
	} 
	
}