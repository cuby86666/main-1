/*************************************************************************
@Modified By: 		Nisha Agrawal
@Modified Date: 	08 Aug 2017
@Description:		Modified class to include PreAccount record type fetching
**************************************************************************/
public class AccountHelper {
	public static final String PARENT_ACCOUNT_STAR = 'STAR';
	public static final String PARENT_ACCOUNT_SAMSUNG = 'Samsung';
	public static final String CBG_AUTOMOTIVE = 'Automotive';
	public static final String REGION_GC = 'Greater China';
	public static final String REGION_SAP = 'South Asia Pacific';
	
	private static final String TYPE_CHILD = 'Child_Account';
	private static final String TYPE_PARENT = 'Parent_Account';  
    private static final string TYPE_PREACCOUNT = 'PreAccount'; //added by Nisha Agrawal to include PreAccount record type fetching
    
	private static ID childRecordTypeID;
	private static ID parentRecordTypeID;
	private static ID preAccountRecordTypeID; //added by Nisha Agrawal to include PreAccount record type fetching
    
	static{
		childRecordTypeID = getChildRecordTypeID();
		parentRecordTypeID = getParentRecordTypeID();
        preAccountRecordTypeID = getPreAccountRecordTypeID(); //added by Nisha Agrawal to include PreAccount record type fetching
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
    
    //code block added by Nisha Agrawal to include PreAccount record type fetching
    public static ID getPreAccountRecordTypeID() {
    	if (preAccountRecordTypeID == null) {
    		setRecordTypeIDs();	
    	}
    	
    	return preAccountRecordTypeID;
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
			} //code block added by Nisha Agrawal to include PreAccount record type fetching
            else if (rt.DeveloperName == TYPE_PREACCOUNT) {
				preAccountRecordTypeID = rt.Id;
		}
	}
  }
}