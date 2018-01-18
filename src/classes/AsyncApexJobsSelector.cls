public class AsyncApexJobsSelector extends ApplicationSelector {
	
	public override Schema.SObjectType getSObjectType() {
		return AsyncApexJob.SObjectType;
	}
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			AsyncApexJob.Id,
			AsyncApexJob.ExtendedStatus,
			AsyncApexJob.JobItemsProcessed,
			AsyncApexJob.NumberOfErrors,
			AsyncApexJob.Status,
			AsyncApexJob.TotalJobItems
		};
	}
	
	public List<AsyncApexJob> selectByIdWithCreatedBy(Set<Id> ids) {
		p('selectByIdWithCreatedBy');
		fflib_QueryFactory asyncApexJobsQueryFactory = newQueryFactory();
		
		new UsersSelector().configureQueryFactoryFields(asyncApexJobsQueryFactory, AsyncApexJob.CreatedById.getDescribe().getRelationshipName());
		
		return (List<AsyncApexJob>)Database.query(asyncApexJobsQueryFactory.setCondition('Id in :ids').toSOQL());
	}
    
}