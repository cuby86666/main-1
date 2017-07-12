public class ApproverMatrixHelper {
	private static final String RECORD_TYPE_DIRECT_OPPTY = 'Direct_Oppty';
	private static final String DIRECT_OPPTY_TYPE_MAG_APPROVER = 'MAG Approver';
	private static final String DIRECT_OPPTY_TYPE_BL_APPROVER = 'BL Approver';
	private static final String DIRECT_OPPTY_TYPE_GAM = 'GAM';
	private static final String DIRECT_OPPTY_TYPE_EVP = 'EVP';
	private static final String DIRECT_OPPTY_TYPE_SEGMENT_VP = 'Segment VP';
	private static final String DIRECT_OPPTY_TYPE_GSM_SALES_DIRECTOR = 'GSM Sales Director';
	private static final String DIRECT_OPPTY_TYPE_GSM_VP_1 = 'GSM VP 1';
	private static final String DIRECT_OPPTY_TYPE_GSM_VP_2 = 'GSM VP 2';
	
	private static ID directOpptyRecordTypeID;
	private static Map<ID, Approvers_Matrix__c> directOpptyApproverMatrixes;  
	
	static{
		directOpptyRecordTypeID = getDirectOpptyRecordTypeID();	
		directOpptyApproverMatrixes = getDirectOpptyApproverMatrixes(); 
	}
	
	public static ID getDirectOpptyRecordTypeID() {
    	if (directOpptyRecordTypeID == null) {
    		setRecordTypeIDs();	
    	}
    	
    	return directOpptyRecordTypeID;
    }
    
    private static void setRecordTypeIDs() {
		List<RecordType> recordTypes = [
			select Id, DeveloperName 
		      from RecordType 
		     where IsActive = TRUE 
		       and SobjectType = 'Approvers_Matrix__c'
		]; 
		
		for (RecordType rt : recordTypes) {
			if (rt.DeveloperName == RECORD_TYPE_DIRECT_OPPTY) {
				directOpptyRecordTypeID = rt.Id;
			} 
		}
	}
	
	public static Map<ID, Approvers_Matrix__c> getDirectOpptyApproverMatrixes() {
    	if (directOpptyApproverMatrixes == null) {
    		setDirectOpptyApproverMatrixes();	
    	}
    	
    	return directOpptyApproverMatrixes;
    }
    
    private static void setDirectOpptyApproverMatrixes() {
    	directOpptyApproverMatrixes = new Map<ID, Approvers_Matrix__c>(
    		[select Type__c, Criteria_1__c, Criteria_2__c, Threshold_1__c, Approver__c 
    		   from Approvers_Matrix__c 
    		  where RecordTypeId = :getDirectOpptyRecordTypeID()]
    	);		
    }
    
    public static Approvers_Matrix__c getDirectOpptyGamSTAR() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GAM && am.Criteria_1__c == AccountHelper.PARENT_ACCOUNT_STAR) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyGamSamsung() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GAM && am.Criteria_1__c == AccountHelper.PARENT_ACCOUNT_SAMSUNG) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyEvpSTAR() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_EVP && am.Criteria_1__c == AccountHelper.PARENT_ACCOUNT_STAR) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyEvpSamsung() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_EVP && am.Criteria_1__c == AccountHelper.PARENT_ACCOUNT_SAMSUNG) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptySegmentVpAuto() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_SEGMENT_VP && am.Criteria_1__c == AccountHelper.CBG_AUTOMOTIVE) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyGsmSalesDirector() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GSM_SALES_DIRECTOR) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    }
    
    public static Approvers_Matrix__c getDirectOpptyGsmVp1() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GSM_VP_1) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;	
    }
    
    public static Approvers_Matrix__c getDirectOpptyGsmVp2AutoGC() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GSM_VP_2 && am.Criteria_1__c == AccountHelper.CBG_AUTOMOTIVE && am.Criteria_2__c == AccountHelper.REGION_GC) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    } 
    
    public static Approvers_Matrix__c getDirectOpptyGsmVp2AutoSAP() {
    	Approvers_Matrix__c result;
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_GSM_VP_2 && am.Criteria_1__c == AccountHelper.CBG_AUTOMOTIVE && am.Criteria_2__c == AccountHelper.REGION_SAP) {
    			result = am;
    			break;	
    		}
    	}	
    	
    	return result;
    } 
    
    public static List<Approvers_Matrix__c> getDirectOpptyMagApprovers(Set<String> mags) {
    	List<Approvers_Matrix__c> result = new List<Approvers_Matrix__c>();
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_MAG_APPROVER && mags.contains(am.Criteria_1__c) && am.Criteria_2__c == null) {
    			result.add(am);
    		}
    	}	
    	
    	return result;		
    }
    
    public static List<Approvers_Matrix__c> getDirectOpptyMagApproversSTAR(Set<String> mags) {
    	List<Approvers_Matrix__c> result = new List<Approvers_Matrix__c>();
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_MAG_APPROVER && mags.contains(am.Criteria_1__c) && am.Criteria_2__c == AccountHelper.PARENT_ACCOUNT_STAR) {
    			result.add(am);
    		}
    	}	
    	
    	return result;		
    }
    
    public static List<Approvers_Matrix__c> getDirectOpptyBlApprovers(Set<String> bls) {
    	List<Approvers_Matrix__c> result = new List<Approvers_Matrix__c>();
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_BL_APPROVER && bls.contains(am.Criteria_1__c) && am.Criteria_2__c == null) {
    			result.add(am);
    		}
    	}	
    	
    	return result;		
    }
    
    public static List<Approvers_Matrix__c> getDirectOpptyBlApproversSTAR(Set<String> bls) {
    	List<Approvers_Matrix__c> result = new List<Approvers_Matrix__c>();
    	
    	for (Approvers_Matrix__c am : directOpptyApproverMatrixes.values()) {
    		if (am.Type__c == DIRECT_OPPTY_TYPE_BL_APPROVER && bls.contains(am.Criteria_1__c) && am.Criteria_2__c == AccountHelper.PARENT_ACCOUNT_STAR) {
    			result.add(am);
    		}
    	}	
    	
    	return result;		
    }
}