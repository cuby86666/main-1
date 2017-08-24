public class AccountHelper {
	/*J
	public static final String PARENT_ACCOUNT_STAR = 'STAR';
	public static final String PARENT_ACCOUNT_SAMSUNG = 'Samsung';
	public static final String CBG_AUTOMOTIVE = 'Automotive';
	public static final String REGION_GC = 'Greater China';
	public static final String REGION_SAP = 'South Asia Pacific';
	*/
	/*J
	private static final String TYPE_CHILD = 'Child_Account';
	private static final String TYPE_PARENT = 'Parent_Account';  
				
	private static ID childRecordTypeID;
	private static ID parentRecordTypeID;
	  	
	static{
		childRecordTypeID = getChildRecordTypeID();
		parentRecordTypeID = getParentRecordTypeID();
	}
	
	public static ID getChildRecordTypeID() {
    	if (childRecordTypeID == null) {
    		setRecordTypeIDs();	
    	}
    	
    	return childRecordTypeID;
    }
	
	public static ID getParentRecordTypeID() {
    	if (parentRecordTypeID == null) {
    		setRecordTypeIDs();	
    	}
    	
    	return parentRecordTypeID;
    }
    
    private static void setRecordTypeIDs() {
		List<RecordType> recordTypes = [select Id, DeveloperName 
		                                  from RecordType 
		                                 where IsActive = TRUE 
		                                   and SobjectType = 'Account']; 
		
		for (RecordType rt : recordTypes) {
			if (rt.DeveloperName == TYPE_CHILD) {
				childRecordTypeID = rt.Id;
			} else if (rt.DeveloperName == TYPE_PARENT) {
				parentRecordTypeID = rt.Id;
			} 
		}
	}
	*/  
}