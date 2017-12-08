/**
 * Applicaiton specific Domain base class. Customize fflib_SObjectSelector and add common behaviour.
 **/
public abstract class ApplicationSelector extends fflib_SObjectSelector {
	
	public ApplicationSelector() {
        this(false);
    }
    
    public ApplicationSelector(Boolean includeFieldSetFields) {
        // Disable the base class read security checking in preference to explicit checking elsewhere        
        this(includeFieldSetFields, false, false);
    }
    
    public ApplicationSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        // Disable sorting of selected fields to aid debugging (performance optimization)
        super(includeFieldSetFields, enforceCRUD, enforceFLS, false);
    }
    
    public List<SObject> selectAll() {
		p('selectAll');
		return Database.query(newQueryFactory().toSOQL());
	}
	
	public List<SObject> selectWhere(String condition) {
		p('selectWhere');
        return Database.query(newQueryFactory().setCondition(condition).toSOQL());        
    }
    
    protected abstract Schema.SObjectType getSObjectType();
    
    protected Id getRecordTypeId(String recTypeName) {
    	Id result = null; 
		
		List<Schema.RecordTypeInfo> recTypes = getSObjectType().getDescribe().getRecordTypeInfos();	
		
		for (Schema.RecordTypeInfo rti : recTypes) {
			if (rti.getName() == recTypeName) {
				result = rti.getRecordTypeId(); 
			}	
		}
		
		return result;	
    }
    
    protected void p(String msg) {
    	CommonUtils.p(this, '//-s', msg);
    }
    
}